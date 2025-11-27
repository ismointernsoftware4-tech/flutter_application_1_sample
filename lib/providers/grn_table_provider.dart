import 'package:flutter/foundation.dart';

import '../models/grn_schema.dart';

class GrnTableProvider extends ChangeNotifier {
  GrnTableProvider({
    GrnSchemaLoader? loader,
  }) : _loader = loader ?? const GrnSchemaLoader() {
    _load();
  }

  final GrnSchemaLoader _loader;

  bool _isLoading = true;
  List<String> _columns = const [];
  List<GrnTableRow> _rows = const [];

  bool get isLoading => _isLoading;
  List<String> get columns => List.unmodifiable(_columns);
  List<GrnTableRow> get rows => List.unmodifiable(_rows);

  Future<void> reload() => _load();

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schema = await _loader.load();
      _columns = schema.tableColumns;
      _rows = schema.rows;
    } catch (error) {
      debugPrint('Failed to load GRN schema: $error');
      _columns = const [];
      _rows = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



