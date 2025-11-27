import 'package:flutter/foundation.dart';

import '../models/storage_location_schema.dart';

class StorageLocationTableProvider extends ChangeNotifier {
  StorageLocationTableProvider({
    StorageLocationSchemaLoader? loader,
  }) : _loader = loader ?? const StorageLocationSchemaLoader() {
    _load();
  }

  final StorageLocationSchemaLoader _loader;

  bool _isLoading = true;
  List<String> _columns = const [];
  List<StorageLocationRow> _rows = const [];

  bool get isLoading => _isLoading;
  List<String> get columns => List.unmodifiable(_columns);
  List<StorageLocationRow> get rows => List.unmodifiable(_rows);

  Future<void> reload() => _load();

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schema = await _loader.load();
      _columns = schema.tableColumns;
      _rows = schema.rows;
    } catch (error) {
      debugPrint('Failed to load storage location schema: $error');
      _columns = const [];
      _rows = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



