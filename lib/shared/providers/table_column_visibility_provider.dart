import 'package:flutter/foundation.dart';

import '../models/column_config.dart';
import '../services/table_schema_service.dart';

class TableColumnVisibilityProvider extends ChangeNotifier {
  final TableSchemaService _schemaService;
  List<ColumnConfig> _columns = const [];
  bool _isLoading = false;

  bool _disposed = false;

  TableColumnVisibilityProvider(String tableType)
      : _schemaService = TableSchemaService(tableType) {
    // Initialize with default columns immediately to avoid loading screen
    _columns = _schemaService.defaultColumns;
    // Load saved columns in the background
    _loadColumns();
  }

  List<ColumnConfig> get columns => _columns;
  List<ColumnConfig> get visibleColumns =>
      _columns.where((column) => column.visible).toList();
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadColumns() async {
    // Load saved columns in the background without showing loading state
    final data = await _schemaService.loadColumns();
    if (_disposed) return;
    // Only update if different from defaults to avoid unnecessary rebuilds
    if (data != _columns) {
      _columns = data;
      notifyListeners();
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
    if (!_disposed) notifyListeners();
    await _schemaService.saveColumns(_columns);
  }

  Future<void> setAll(bool visible) async {
    _columns = _columns
        .map((column) => column.copyWith(visible: visible))
        .toList(growable: false);
    if (!_disposed) notifyListeners();
    await _schemaService.saveColumns(_columns);
  }

  Future<void> resetToDefault() async {
    _columns = _schemaService.defaultColumns;
    if (!_disposed) notifyListeners();
    await _schemaService.saveColumns(_columns);
  }
}

