import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class StorageLocationRow {
  StorageLocationRow(this.raw);

  final Map<String, dynamic> raw;

  String valueFor(String key) {
    final value = raw[key];
    if (value == null) return '';
    if (value is num) return value.toString();
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is List) return value.join(', ');
    return value.toString();
  }

  num? numericValue(String key) {
    final value = raw[key];
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  bool actionEnabled(String action) {
    final actions = raw['actions'];
    if (actions is Map<String, dynamic>) {
      final value = actions[action];
      if (value is bool) return value;
    }
    return false;
  }
}

class StorageLocationSchema {
  StorageLocationSchema({
    required this.formName,
    required this.tableColumns,
    required this.rows,
  });

  final String formName;
  final List<String> tableColumns;
  final List<StorageLocationRow> rows;

  factory StorageLocationSchema.fromJson(Map<String, dynamic> json) {
    final columns = (json['tableColumns'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toList();

    final sampleRows = (json['sampleData'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => StorageLocationRow(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();

    return StorageLocationSchema(
      formName: json['formName']?.toString() ?? '',
      tableColumns: columns,
      rows: sampleRows,
    );
  }
}

class StorageLocationSchemaLoader {
  const StorageLocationSchemaLoader({
    this.path = 'schemas/storage_location_schema.json',
  });

  final String path;

  Future<StorageLocationSchema> load() async {
    final jsonString = await rootBundle.loadString(path);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return StorageLocationSchema.fromJson(map);
  }
}



