import 'package:flutter/foundation.dart';

import '../models/approval_workflows_schema.dart';

class ApprovalWorkflowTableProvider extends ChangeNotifier {
  ApprovalWorkflowTableProvider({
    ApprovalWorkflowSchemaLoader? loader,
  }) : _loader = loader ?? const ApprovalWorkflowSchemaLoader() {
    _load();
  }

  final ApprovalWorkflowSchemaLoader _loader;

  bool _isLoading = true;
  List<String> _columns = const [];
  List<ApprovalWorkflowRow> _rows = const [];

  bool get isLoading => _isLoading;
  List<String> get columns => List.unmodifiable(_columns);
  List<ApprovalWorkflowRow> get rows => List.unmodifiable(_rows);

  Future<void> reload() => _load();

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schema = await _loader.load();
      _columns = schema.tableColumns;
      _rows = schema.rows;
    } catch (error) {
      debugPrint('Failed to load approval workflow schema: $error');
      _columns = const [];
      _rows = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



