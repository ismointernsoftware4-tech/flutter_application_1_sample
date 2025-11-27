import 'package:flutter/foundation.dart';

import '../models/purchase_requisition_schema.dart';

/// Provider that exposes a JSON-driven Purchase Requisition table.
class PurchaseRequisitionListProvider extends ChangeNotifier {
  final PurchaseRequisitionSchemaLoader _loader;

  bool _isLoading = true;
  List<String> _columns = const [];
  List<PurchaseRequisitionRow> _rows = const [];

  bool get isLoading => _isLoading;
  List<String> get columns => List.unmodifiable(_columns);
  List<PurchaseRequisitionRow> get rows => List.unmodifiable(_rows);

  PurchaseRequisitionListProvider({
    PurchaseRequisitionSchemaLoader? loader,
  }) : _loader = loader ?? const PurchaseRequisitionSchemaLoader() {
    _load();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schema = await _loader.load();
      _columns = schema.tableColumns;
      _rows = schema.rows;
    } catch (error) {
      debugPrint('Failed to load purchase requisition schema: $error');
      _columns = const [];
      _rows = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}




