import 'package:flutter/foundation.dart';

import '../../../shared/models/column_config.dart';
import '../services/item_table_schema_service.dart';

class ItemColumnVisibilityProvider extends ChangeNotifier {
  final ItemTableSchemaService _schemaService = ItemTableSchemaService();
  List<ColumnConfig> _columns;
  bool _isLoading = false; // Start with false - we have default columns

  ItemColumnVisibilityProvider() : _columns = ItemTableSchemaService().defaultColumns {
    // Initialize with default columns immediately
    // Then load saved columns in the background
    _loadColumns();
  }

  List<ColumnConfig> get columns => _columns;
  List<ColumnConfig> get visibleColumns =>
      _columns.where((column) => column.visible).toList();
  bool get isLoading => _isLoading;

  Future<void> _loadColumns() async {
    // Don't show loading - we already have default columns showing
    try {
      final data = await _schemaService.loadColumns();
      // Only update if we got different columns (not just defaults)
      if (data.isNotEmpty) {
        _columns = data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading columns: $e');
      // Keep default columns on error
    }
  }

  Future<void> toggleColumn(String key, bool visible) async {
    _columns = _columns
        .map(
          (column) => column.key == key
              ? column.copyWith(visible: visible)
              : column,
        )
        .toList(growable: false);
    notifyListeners();
    await _schemaService.saveColumns(_columns);
  }

  Future<void> setAll(bool visible) async {
    _columns = _columns
        .map((column) => column.copyWith(visible: visible))
        .toList(growable: false);
    notifyListeners();
    await _schemaService.saveColumns(_columns);
  }

  Future<void> resetToDefault() async {
    _columns = _schemaService.defaultColumns;
    notifyListeners();
    await _schemaService.saveColumns(_columns);
  }
}

