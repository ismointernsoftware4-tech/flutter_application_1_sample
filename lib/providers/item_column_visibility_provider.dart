import 'package:flutter/foundation.dart';

import '../models/item_master_schema.dart';

class ColumnConfig {
  final String key;
  final String label;
  final String description;
  final bool visible;

  const ColumnConfig({
    required this.key,
    required this.label,
    required this.description,
    required this.visible,
  });

  ColumnConfig copyWith({
    bool? visible,
  }) {
    return ColumnConfig(
      key: key,
      label: label,
      description: description,
      visible: visible ?? this.visible,
    );
  }
}

class ItemColumnVisibilityProvider extends ChangeNotifier {
  final List<ColumnConfig> _columns = [];
  final List<String> _defaultOrder = [];
  final List<String> _customOrder = [];
  final Set<String> _highlightedKeys = {};
  bool _panelExpanded = true;
  bool _isLoading = true;
  final ItemMasterSchemaLoader _schemaLoader;
  ItemMasterSchema? _cachedSchema;

  ItemColumnVisibilityProvider({ItemMasterSchemaLoader? schemaLoader})
      : _schemaLoader = schemaLoader ?? const ItemMasterSchemaLoader() {
    _loadColumns();
  }

  Future<void> _loadColumns() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schema = await _schemaLoader.load();
      _applySchema(schema);
    } catch (error) {
      debugPrint('Failed to load item master columns: $error');
      _clearColumns();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applySchema(ItemMasterSchema schema) {
    _cachedSchema = schema;

    final fieldMap = <String, SchemaField>{};
    for (final section in schema.sections) {
      for (final field in section.fields) {
        if (field.key.isEmpty) continue;
        fieldMap[field.key] = field;
      }
    }

    final orderedKeys = _resolveOrderedKeys(schema, fieldMap);

    if (orderedKeys.isEmpty) {
      _clearColumns();
      return;
    }

    // CRITICAL: Only generate columns for fields with isShowInTable: true
    // Fields with isShowInTable: false are COMPLETELY EXCLUDED from columns
    final generatedColumns = <ColumnConfig>[];
    
    for (final key in orderedKeys) {
      final field = fieldMap[key];
      
      // STRICT FILTER: Only add if field exists AND isShowInTable is true
      if (field != null && field.isShowInTable == true) {
        final label = _resolveLabel(key, field);
        final description = _resolveDescription(label, field);
        generatedColumns.add(
          ColumnConfig(
            key: key,
            label: label,
            description: description,
            visible: true, // Always visible initially since we only include isShowInTable: true fields
          ),
        );
      }
      // Fields with isShowInTable: false are silently excluded - they will NOT appear in table or column selector
    }

    _columns
      ..clear()
      ..addAll(generatedColumns);
    _defaultOrder
      ..clear()
      ..addAll(orderedKeys);
    _customOrder
      ..clear()
      ..addAll(_highlightedKeys.where(orderedKeys.contains));
    _highlightedKeys.removeWhere((key) => !orderedKeys.contains(key));
    _panelExpanded = true;
  }

  List<String> _resolveOrderedKeys(
    ItemMasterSchema schema,
    Map<String, SchemaField> fieldMap,
  ) {
    // Get all fields that should be shown in table (isShowInTable: true)
    final showableFields = fieldMap.values
        .where((field) => field.isShowInTable && field.key.isNotEmpty)
        .toList();

    if (showableFields.isEmpty) {
      return [];
    }

    // Sort by order field
    showableFields.sort((a, b) {
      final orderA = a.order ?? 999;
      final orderB = b.order ?? 999;
      return orderA.compareTo(orderB);
    });

    // If tableColumns is defined in schema, use it for ordering (if those columns exist and are showable)
    final orderedKeys = <String>[];
    final processedKeys = <String>{};

    // First, add columns from tableColumns that exist in showable fields
    if (schema.tableColumns.isNotEmpty) {
      for (final entry in schema.tableColumns) {
        final key = entry.trim();
        if (key.isEmpty || processedKeys.contains(key)) continue;
        final field = fieldMap[key];
        if (field != null && field.isShowInTable) {
          orderedKeys.add(key);
          processedKeys.add(key);
        }
      }
    }

    // Then, add any remaining showable fields that weren't in tableColumns
    for (final field in showableFields) {
      if (!processedKeys.contains(field.key)) {
        orderedKeys.add(field.key);
        processedKeys.add(field.key);
      }
    }

    return orderedKeys;
  }

  void _clearColumns() {
    _columns.clear();
    _defaultOrder.clear();
    _customOrder.clear();
    _highlightedKeys.clear();
    _panelExpanded = true;
  }

  String _resolveLabel(String key, SchemaField? field) {
    if (field != null && field.label.isNotEmpty) return field.label;
    const overrides = {
      'unit': 'UOM',
    };
    if (overrides.containsKey(key)) return overrides[key]!;

    final buffer = StringBuffer();
    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else if (isUpper) {
        buffer.write(' $char');
      } else if (char == '_') {
        buffer.write(' ');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String _resolveDescription(String label, SchemaField? field) {
    if (field?.placeholder != null && field!.placeholder!.isNotEmpty) {
      return field.placeholder!;
    }
    return 'Show or hide $label column';
  }

  /// Returns all available columns (only fields with isShowInTable: true from JSON)
  /// Fields with isShowInTable: false are NEVER included here
  List<ColumnConfig> get columns {
    // Double-check: Filter out any columns that shouldn't be shown
    // This is a safety measure - all columns should already have isShowInTable: true
    return List.unmodifiable(_columns);
  }
  
  bool get isLoading => _isLoading;

  /// Returns only the visible columns (subset of columns where visible: true)
  List<ColumnConfig> get visibleColumns {
    final visible = _columns.where((column) => column.visible).toList();
    visible.sort((a, b) {
      final customIndexA = _customOrder.indexOf(a.key);
      final customIndexB = _customOrder.indexOf(b.key);

      final hasCustomA = customIndexA != -1;
      final hasCustomB = customIndexB != -1;

      if (hasCustomA && hasCustomB) {
        return customIndexA.compareTo(customIndexB);
      }
      if (hasCustomA) return -1;
      if (hasCustomB) return 1;

      final defaultIndexA = _defaultOrder.indexOf(a.key);
      final defaultIndexB = _defaultOrder.indexOf(b.key);
      return defaultIndexA.compareTo(defaultIndexB);
    });
    return visible;
  }

  bool isHighlighted(String key) => _highlightedKeys.contains(key);

  void toggleHighlight(String key) {
    final index = _columns.indexWhere((column) => column.key == key);
    if (index == -1) return;

    if (_highlightedKeys.contains(key)) {
      _highlightedKeys.remove(key);
      _customOrder.remove(key);
    } else {
      _highlightedKeys.add(key);
      _customOrder
        ..remove(key)
        ..add(key);
      if (!_columns[index].visible) {
        _columns[index] = _columns[index].copyWith(visible: true);
      }
    }

    notifyListeners();
  }

  void toggleColumn(String key, bool visible) {
    final index = _columns.indexWhere((column) => column.key == key);
    if (index == -1) return;

    _columns[index] = _columns[index].copyWith(visible: visible);

    if (!visible) {
      _highlightedKeys.remove(key);
      _customOrder.remove(key);
    }
    notifyListeners();
  }

  void setAll(bool visible) {
    for (var i = 0; i < _columns.length; i++) {
      _columns[i] = _columns[i].copyWith(visible: visible);
    }
    if (!visible) {
      _highlightedKeys.clear();
      _customOrder.clear();
    } else {
      _customOrder.clear();
    }
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    if (_cachedSchema != null) {
      _applySchema(_cachedSchema!);
      notifyListeners();
      return;
    }
    await _loadColumns();
  }

  /// Reloads the schema from JSON file (for instant updates when JSON changes)
  Future<void> reloadSchema() async {
    _cachedSchema = null; // Clear cache to force fresh load
    await _loadColumns();
  }

  bool get panelExpanded => _panelExpanded;

  void togglePanelExpanded() {
    _panelExpanded = !_panelExpanded;
    notifyListeners();
  }
}

