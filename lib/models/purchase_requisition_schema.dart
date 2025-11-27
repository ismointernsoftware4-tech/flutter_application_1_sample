import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Row model for a single Purchase Requisition entry loaded from JSON.
class PurchaseRequisitionRow {
  final Map<String, dynamic> raw;

  const PurchaseRequisitionRow(this.raw);

  /// Safely resolve a value for a given key into a displayable string.
  String valueFor(String key) {
    final value = raw[key];
    if (value == null) return '';

    // Common pattern: { "label": "...", "color": "..." }
    if (value is Map && value['label'] != null) {
      return value['label'].toString();
    }

    if (value is num) return value.toString();
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is List) return value.join(', ');

    return value.toString();
  }
}

/// Root schema model describing the PR table, loaded from JSON.
class PurchaseRequisitionSchema {
  final List<String> tableColumns;
  final List<PurchaseRequisitionRow> rows;

  PurchaseRequisitionSchema({
    required this.tableColumns,
    required this.rows,
  });

  factory PurchaseRequisitionSchema.fromJson(Map<String, dynamic> json) {
    final columns = (json['tableColumns'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    final sampleData = (json['sampleData'] as List<dynamic>? ?? const [])
        .where((entry) => entry is Map)
        .map((entry) => PurchaseRequisitionRow(
              Map<String, dynamic>.from(entry as Map),
            ))
        .toList();

    return PurchaseRequisitionSchema(
      tableColumns: columns,
      rows: sampleData,
    );
  }
}

/// Loader that reads the PR schema JSON from bundled assets.
class PurchaseRequisitionSchemaLoader {
  const PurchaseRequisitionSchemaLoader({
    this.path = 'schemas/purchase_requisition_schema.json',
  });

  final String path;

  Future<PurchaseRequisitionSchema> load() async {
    final jsonString = await rootBundle.loadString(path);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return PurchaseRequisitionSchema.fromJson(map);
  }
}


