import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class ItemMasterSchema {
  final String formName;
  final bool isActive;
  final List<SchemaSection> sections;
  final List<String> tableColumns;
  final List<Map<String, dynamic>> sampleData;

  ItemMasterSchema({
    required this.formName,
    required this.isActive,
    required this.sections,
    required this.tableColumns,
    required this.sampleData,
  });

  factory ItemMasterSchema.fromJson(Map<String, dynamic> json) {
    return ItemMasterSchema(
      formName: json['formName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .map((section) {
            final map = _safeMap(section);
            if (map == null) return null;
            return SchemaSection.fromJson(map);
          })
          .whereType<SchemaSection>()
          .toList(),
      tableColumns: (json['tableColumns'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      sampleData: (json['sampleData'] as List<dynamic>? ?? const [])
          .map((entry) => _safeMap(entry))
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }
}

class SchemaSection {
  final String label;
  final List<SchemaField> fields;

  SchemaSection({
    required this.label,
    required this.fields,
  });

  factory SchemaSection.fromJson(Map<String, dynamic> json) {
    return SchemaSection(
      label: json['sectionLabel'] as String? ?? '',
      fields: (json['fields'] as List<dynamic>? ?? const [])
          .map((field) {
            final map = _safeMap(field);
            if (map == null) return null;
            return SchemaField.fromJson(map);
          })
          .whereType<SchemaField>()
          .toList(),
    );
  }
}

class SchemaField {
  final String key;
  final String label;
  final String type;
  final dynamic defaultValue;
  final String? placeholder;
  final bool isRequired;
  final bool isShowInTable;
  final int? order;
  final List<String> options;
  final List<String> fileTypes;
  final bool allowsMultipleFiles;

  SchemaField({
    required this.key,
    required this.label,
    required this.type,
    required this.defaultValue,
    required this.placeholder,
    required this.isRequired,
    required this.isShowInTable,
    required this.order,
    required this.options,
    required this.fileTypes,
    required this.allowsMultipleFiles,
  });

  factory SchemaField.fromJson(Map<String, dynamic> json) {
    return SchemaField(
      key: json['fieldKey'] as String? ?? '',
      label: json['fieldLabel'] as String? ?? '',
      type: json['fieldType'] as String? ?? 'text',
      defaultValue: json['defaultValue'],
      placeholder: json['placeholder'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      isShowInTable: json['isShowInTable'] as bool? ?? false,
      order: json['order'] as int?,
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      fileTypes: (json['fileTypes'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      allowsMultipleFiles: json['multiple'] as bool? ?? false,
    );
  }
}

class ItemMasterSchemaLoader {
  const ItemMasterSchemaLoader({this.schemaPath = 'lib/assets/item_master_schema.json'});

  final String schemaPath;

  Future<ItemMasterSchema> load() async {
    final jsonString = await _readSchema();
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return ItemMasterSchema.fromJson(json);
  }

  Future<String> _readSchema() async {
    if (!kIsWeb) {
      final fileContents = await _tryReadFromDisk();
      if (fileContents != null) {
        return fileContents;
      }
    }

    return rootBundle.loadString(schemaPath);
  }

  Future<String?> _tryReadFromDisk() async {
    final normalizedSchemaPath =
        schemaPath.replaceAll('\\', Platform.pathSeparator).replaceAll(
              '/',
              Platform.pathSeparator,
            );

    Future<String?> readFile(File file) async {
      try {
        if (await file.exists()) {
          return await file.readAsString();
        }
      } catch (_) {
        // Ignore and try next candidate
      }
      return null;
    }

    // Try relative to current directory
    final directFile = File(normalizedSchemaPath);
    final directResult = await readFile(directFile);
    if (directResult != null) return directResult;

    // Walk up to 5 parent directories to find the project root
    var parent = Directory.current;
    for (var i = 0; i < 5; i++) {
      final parentPath = _joinPath(parent.path, normalizedSchemaPath);
      final candidate = File(parentPath);
      final candidateResult = await readFile(candidate);
      if (candidateResult != null) return candidateResult;
      parent = parent.parent;
    }

    debugPrint('Schema not found on disk; using bundled asset.');
    return null;
  }

  String _joinPath(String base, String relative) {
    final hasSeparator = base.endsWith(Platform.pathSeparator);
    final sanitizedRelative = relative.startsWith(Platform.pathSeparator)
        ? relative.substring(1)
        : relative;
    final normalizedBase = hasSeparator ? base : '$base${Platform.pathSeparator}';
    return '$normalizedBase$sanitizedRelative';
  }
}

Map<String, dynamic>? _safeMap(dynamic source) {
  if (source is Map) {
    return Map<String, dynamic>.from(source);
  }
  return null;
}

