import 'package:flutter/material.dart';

enum DynamicFieldType {
  text,
  textarea,
  dropdown,
  number,
  checkboxList,
}

class FormFieldTemplate {
  final String key;
  final String label;
  final String hint;
  final DynamicFieldType type;
  final List<String> options;
  final bool required;
  final Map<String, dynamic> extra;
  final bool isSystemField;

  const FormFieldTemplate({
    required this.key,
    required this.label,
    this.hint = '',
    this.type = DynamicFieldType.text,
    this.options = const [],
    this.required = false,
    this.isSystemField = true,
    this.extra = const {},
  });
}

class DynamicFormField {
  final String id;
  final String key;
  final String label;
  final String hint;
  final DynamicFieldType type;
  final List<String> options;
  final bool required;
  final bool isCustom;
  final Map<String, dynamic> extra;

  const DynamicFormField({
    required this.id,
    required this.key,
    required this.label,
    this.hint = '',
    this.type = DynamicFieldType.text,
    this.options = const [],
    this.required = false,
    this.isCustom = false,
    this.extra = const {},
  });

  DynamicFormField copyWith({
    String? id,
    String? key,
    String? label,
    String? hint,
    DynamicFieldType? type,
    List<String>? options,
    bool? required,
    bool? isCustom,
    Map<String, dynamic>? extra,
  }) {
    return DynamicFormField(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      type: type ?? this.type,
      options: options ?? this.options,
      required: required ?? this.required,
      isCustom: isCustom ?? this.isCustom,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'label': label,
      'hint': hint,
      'type': type.name,
      'options': options,
      'required': required,
      'isCustom': isCustom,
      'extra': extra,
    };
  }

  factory DynamicFormField.fromMap(Map<String, dynamic> map) {
    return DynamicFormField(
      id: map['id'] as String? ?? UniqueKey().toString(),
      key: map['key'] as String? ?? '',
      label: map['label'] as String? ?? '',
      hint: map['hint'] as String? ?? '',
      type: DynamicFieldType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => DynamicFieldType.text,
      ),
      options: List<String>.from(map['options'] as List? ?? const []),
      required: map['required'] == true,
      isCustom: map['isCustom'] == true,
      extra: Map<String, dynamic>.from(map['extra'] as Map? ?? const {}),
    );
  }
}

class DynamicFormSection {
  final String id;
  final String title;
  final List<DynamicFormField> fields;

  const DynamicFormSection({
    required this.id,
    required this.title,
    required this.fields,
  });

  DynamicFormSection copyWith({
    String? id,
    String? title,
    List<DynamicFormField>? fields,
  }) {
    return DynamicFormSection(
      id: id ?? this.id,
      title: title ?? this.title,
      fields: fields ?? this.fields,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fields': fields.map((f) => f.toMap()).toList(),
    };
  }

  factory DynamicFormSection.fromMap(Map<String, dynamic> map) {
    return DynamicFormSection(
      id: map['id'] as String? ?? UniqueKey().toString(),
      title: map['title'] as String? ?? '',
      fields: (map['fields'] as List? ?? const [])
          .map((field) => DynamicFormField.fromMap(field))
          .toList(),
    );
  }
}

class DynamicFormDefinition {
  final String id;
  final String name;
  final List<DynamicFormSection> sections;

  const DynamicFormDefinition({
    required this.id,
    required this.name,
    required this.sections,
  });

  DynamicFormDefinition copyWith({
    String? id,
    String? name,
    List<DynamicFormSection>? sections,
  }) {
    return DynamicFormDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sections': sections.map((s) => s.toMap()).toList(),
    };
  }

  factory DynamicFormDefinition.fromMap(Map<String, dynamic> map) {
    return DynamicFormDefinition(
      id: map['id'] as String? ?? 'item_master',
      name: map['name'] as String? ?? 'Item Master Form',
      sections: (map['sections'] as List? ?? const [])
          .map((section) => DynamicFormSection.fromMap(section))
          .toList(),
    );
  }
}

const List<FormFieldTemplate> kFormFieldCatalog = [
  FormFieldTemplate(
    key: 'itemName',
    label: 'Item Name',
    hint: 'e.g. Paracetamol 500mg',
    required: true,
  ),
  FormFieldTemplate(
    key: 'itemType',
    label: 'Item Type',
    hint: 'Choose an item type',
    type: DynamicFieldType.dropdown,
    options: ['Drug', 'Consumable'],
    required: true,
  ),
  FormFieldTemplate(
    key: 'category',
    label: 'Category',
    hint: 'e.g. Analgesic',
  ),
  FormFieldTemplate(
    key: 'hsCode',
    label: 'HS Code',
    hint: 'Harmonized System Code',
  ),
  FormFieldTemplate(
    key: 'storageConditions',
    label: 'Storage Conditions',
    type: DynamicFieldType.dropdown,
    options: ['Room Temperature (RT)', 'Cold Chain (2-8°C)'],
    required: true,
  ),
  FormFieldTemplate(
    key: 'shelfLife',
    label: 'Shelf Life (Months)',
    hint: '24',
    type: DynamicFieldType.number,
  ),
  FormFieldTemplate(
    key: 'specifications',
    label: 'Specifications',
    hint: 'General specifications...',
    type: DynamicFieldType.textarea,
  ),
  FormFieldTemplate(
    key: 'strength',
    label: 'Strength / Concentration',
    hint: 'e.g. 500mg or 100IU/ml',
  ),
  FormFieldTemplate(
    key: 'unitOfMeasure',
    label: 'Unit of Measure',
    type: DynamicFieldType.dropdown,
    options: ['Tablet', 'Bottle'],
    required: true,
  ),
  FormFieldTemplate(
    key: 'composition',
    label: 'Composition / Description',
    hint: 'Detailed composition or description...',
    type: DynamicFieldType.textarea,
  ),
  FormFieldTemplate(
    key: 'inventoryNotes',
    label: 'Inventory & Supply',
    hint: 'General inventory notes...',
    type: DynamicFieldType.textarea,
  ),
  FormFieldTemplate(
    key: 'manufacturer',
    label: 'Manufacturer',
    hint: 'Manufacturer Name',
  ),
  FormFieldTemplate(
    key: 'leadTime',
    label: 'Lead Time (Days)',
    hint: 'e.g. 7',
    type: DynamicFieldType.number,
  ),
  FormFieldTemplate(
    key: 'unitPrice',
    label: 'Unit Price',
    hint: '0.00',
    type: DynamicFieldType.number,
  ),
  FormFieldTemplate(
    key: 'taxRate',
    label: 'Tax Rate (%)',
    hint: '0',
    type: DynamicFieldType.number,
  ),
  FormFieldTemplate(
    key: 'minReorderLevel',
    label: 'Min Reorder Level',
    hint: '100',
    type: DynamicFieldType.number,
  ),
  FormFieldTemplate(
    key: 'maxReorderLevel',
    label: 'Max Reorder Level',
    hint: '1000',
    type: DynamicFieldType.number,
  ),
  FormFieldTemplate(
    key: 'barcode',
    label: 'Barcode / QR',
    hint: 'Scan or enter code',
  ),
  FormFieldTemplate(
    key: 'complianceNotes',
    label: 'Compliance & Documents',
    hint: 'General compliance notes...',
    type: DynamicFieldType.textarea,
  ),
  FormFieldTemplate(
    key: 'hazardClassification',
    label: 'Hazard Classification',
    type: DynamicFieldType.dropdown,
    options: ['None', 'Chemical', 'Biohazard'],
  ),
  FormFieldTemplate(
    key: 'storageLocation',
    label: 'Storage Location',
    hint: 'Select storage',
    type: DynamicFieldType.dropdown,
    options: ['Main Warehouse', 'Cold Room', 'Cabinet A'],
    isSystemField: false,
  ),
  FormFieldTemplate(
    key: 'inventoryChecklist',
    label: 'Inventory Checklist',
    type: DynamicFieldType.checkboxList,
    options: ['Batch no. verified', 'Expiry checked', 'Condition OK'],
    isSystemField: false,
    extra: {'minSelection': 0},
  ),
];

const Set<String> kMandatoryFieldKeys = {
  'itemName',
  'itemType',
  'category',
  'unitOfMeasure',
  'manufacturer',
};

DynamicFormDefinition defaultDynamicFormDefinition() {
  DynamicFormSection section({
    required String id,
    required String title,
    required List<String> fieldKeys,
  }) {
    final fields = fieldKeys.map((key) {
      final template = kFormFieldCatalog.firstWhere(
        (element) => element.key == key,
        orElse: () => FormFieldTemplate(key: key, label: key, isSystemField: false),
      );
      return DynamicFormField(
        id: '${id}_$key',
        key: template.key,
        label: template.label,
        hint: template.hint,
        type: template.type,
        options: template.options,
        required: template.required,
        isCustom: !template.isSystemField,
        extra: template.extra,
      );
    }).toList();
    return DynamicFormSection(id: id, title: title, fields: fields);
  }

  return DynamicFormDefinition(
    id: 'item_master',
    name: 'Item Master Form',
    sections: [
      section(
        id: 'basic',
        title: 'BASIC INFORMATION',
        fieldKeys: [
          'itemName',
          'itemType',
          'category',
          'hsCode',
          'storageConditions',
          'shelfLife',
        ],
      ),
      section(
        id: 'specs',
        title: 'SPECIFICATIONS',
        fieldKeys: [
          'specifications',
          'strength',
          'unitOfMeasure',
          'composition',
        ],
      ),
      section(
        id: 'inventory',
        title: 'INVENTORY & SUPPLY',
        fieldKeys: [
          'inventoryNotes',
          'manufacturer',
          'leadTime',
          'unitPrice',
          'taxRate',
          'minReorderLevel',
          'maxReorderLevel',
          'barcode',
        ],
      ),
      section(
        id: 'compliance',
        title: 'COMPLIANCE & DOCUMENTS',
        fieldKeys: [
          'complianceNotes',
          'hazardClassification',
        ],
      ),
    ],
  );
}

