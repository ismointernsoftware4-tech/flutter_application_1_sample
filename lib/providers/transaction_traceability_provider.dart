import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../models/transaction_traceability_schema.dart';

class TransactionTraceabilityProvider extends ChangeNotifier {
  TransactionTraceabilityProvider({
    TransactionTraceabilitySchemaLoader? loader,
  }) : _loader = loader ?? const TransactionTraceabilitySchemaLoader() {
    _load();
  }

  final TransactionTraceabilitySchemaLoader _loader;

  bool _isLoading = true;
  String? _error;
  List<String> _columns = const [];
  List<TraceabilityRecord> _records = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get columns => List.unmodifiable(_columns);
  List<TraceabilityRecord> get records => List.unmodifiable(_records);

  Future<void> reload() => _load();

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schema = await _loader.load();
      _columns = schema.tableColumns;
      _records = schema.records;
    } catch (error, stackTrace) {
      debugPrint('Failed to load traceability schema: $error, $stackTrace');
      _columns = const [];
      _records = const [];
      _error = 'Unable to load traceability data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


