import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'dashboard_models.dart';

class TransactionTraceabilitySchema {
  const TransactionTraceabilitySchema({
    required this.formName,
    required this.tableColumns,
    required this.records,
  });

  final String formName;
  final List<String> tableColumns;
  final List<TraceabilityRecord> records;

  factory TransactionTraceabilitySchema.fromJson(Map<String, dynamic> json) {
    final columns = (json['tableColumns'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false);

    final records = (json['sampleData'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => TraceabilityRecord(
            dateTime: entry['dateTime']?.toString() ?? '',
            type: entry['type']?.toString() ?? '',
            reference: entry['reference']?.toString() ?? '',
            itemDetails: entry['item']?.toString() ?? '',
            quantity: entry['quantity']?.toString() ?? '',
            user: entry['user']?.toString() ?? '',
            location: entry['location']?.toString() ?? '',
          ),
        )
        .toList(growable: false);

    return TransactionTraceabilitySchema(
      formName: json['formName']?.toString() ?? '',
      tableColumns: columns,
      records: records,
    );
  }
}

class TransactionTraceabilitySchemaLoader {
  const TransactionTraceabilitySchemaLoader({
    this.path = 'schemas/transaction_traceability_schema.json',
  });

  final String path;

  Future<TransactionTraceabilitySchema> load() async {
    final jsonString = await rootBundle.loadString(path);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return TransactionTraceabilitySchema.fromJson(map);
  }
}


