import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ApprovalWorkflowRow {
  ApprovalWorkflowRow(this.raw);

  final Map<String, dynamic> raw;

  String valueFor(String key) {
    final value = raw[key];
    if (value == null) return '';
    if (value is num) return value.toString();
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is List) return value.join(', ');
    return value.toString();
  }

  List<String> listValue(String key) {
    final value = raw[key];
    if (value is List) {
      return value.map((entry) => entry.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return const [];
  }

  bool hasAction(String action) {
    final actions = listValue('actions');
    return actions.any((entry) => entry.toLowerCase() == action.toLowerCase());
  }
}

class ApprovalWorkflowSchema {
  ApprovalWorkflowSchema({
    required this.tableColumns,
    required this.rows,
  });

  final List<String> tableColumns;
  final List<ApprovalWorkflowRow> rows;

  factory ApprovalWorkflowSchema.fromJson(Map<String, dynamic> json) {
    final columns = (json['tableColumns'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toList();

    final sampleRows = (json['sampleData'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => ApprovalWorkflowRow(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();

    return ApprovalWorkflowSchema(
      tableColumns: columns,
      rows: sampleRows,
    );
  }
}

class ApprovalWorkflowSchemaLoader {
  const ApprovalWorkflowSchemaLoader({
    this.path = 'schemas/approval_workflows_schema.json',
  });

  final String path;

  Future<ApprovalWorkflowSchema> load() async {
    final jsonString = await rootBundle.loadString(path);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return ApprovalWorkflowSchema.fromJson(map);
  }
}



