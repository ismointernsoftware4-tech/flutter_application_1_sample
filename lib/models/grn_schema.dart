import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Represents a single GRN row loaded from the schema.
class GrnTableRow {
  final Map<String, dynamic> raw;

  GrnTableRow(this.raw);

  String valueFor(String key) {
    final value = raw[key];
    if (value == null) return '';

    if (value is Map && value['label'] != null) {
      return value['label'].toString();
    }
    if (value is num) return value.toString();
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is List) return value.join(', ');

    return value.toString();
  }

  bool actionEnabled(String actionKey) {
    final actions = raw['actions'];
    if (actions is Map<String, dynamic>) {
      final value = actions[actionKey];
      if (value is bool) return value;
    }
    return false;
  }
}

class GrnSchema {
  final String formName;
  final List<String> tableColumns;
  final List<GrnTableRow> rows;

  GrnSchema({
    required this.formName,
    required this.tableColumns,
    required this.rows,
  });

  factory GrnSchema.fromJson(Map<String, dynamic> json) {
    final columns = (json['tableColumns'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toList();

    final sampleRows = (json['sampleData'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => GrnTableRow(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();

    return GrnSchema(
      formName: json['formName']?.toString() ?? '',
      tableColumns: columns,
      rows: sampleRows,
    );
  }
}

class GrnSchemaLoader {
  const GrnSchemaLoader({
    this.path = 'schemas/grn_schema.json',
  });

  final String path;

  Future<GrnSchema> load() async {
    final jsonString = await rootBundle.loadString(path);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return GrnSchema.fromJson(map);
  }
}


