import 'package:flutter/foundation.dart';

import '../constants/item_column_keys.dart';

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

  ItemColumnVisibilityProvider() {
    _seedDefaults();
  }

  void _seedDefaults() {
    _columns
      ..clear()
      ..addAll([
      const ColumnConfig(
        key: ItemColumnKeys.itemCode,
        label: 'Item Code',
        description: 'Unique identifier for the stock keeping unit',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.itemName,
        label: 'Item Name',
        description: 'Display name shown on forms and reports',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.type,
        label: 'Type',
        description: 'Material, service, raw material, etc.',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.category,
        label: 'Category',
        description: 'Group or department classification',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.manufacturer,
        label: 'Manufacturer',
        description: 'Primary supplier or manufacturer',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.unit,
        label: 'UOM',
        description: 'Base unit of measure',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.storage,
        label: 'Storage',
        description: 'Storage or temperature requirement',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.stock,
        label: 'Stock',
        description: 'Current on-hand quantity',
        visible: true,
      ),
      const ColumnConfig(
        key: ItemColumnKeys.status,
        label: 'Status',
        description: 'Active, draft, blocked, etc.',
        visible: true,
      ),
    ]);
    _defaultOrder
      ..clear()
      ..addAll(_columns.map((column) => column.key));
    _customOrder.clear();
    _highlightedKeys.clear();
    _panelExpanded = true;
  }

  List<ColumnConfig> get columns => List.unmodifiable(_columns);

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

  void resetToDefault() {
    _seedDefaults();
    notifyListeners();
  }

  bool get panelExpanded => _panelExpanded;

  void togglePanelExpanded() {
    _panelExpanded = !_panelExpanded;
    notifyListeners();
  }
}

