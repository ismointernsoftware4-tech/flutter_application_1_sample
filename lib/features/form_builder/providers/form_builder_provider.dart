import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';
import '../../../shared/services/firebase_service.dart';

class FormBuilderProvider extends ChangeNotifier {
  FormBuilderProvider({String formId = 'item_master', String? clinicId})
      : _formId = formId,
        _clinicId = clinicId;

  final FirebaseService _firebaseService = FirebaseService();
  final String _formId;
  final String? _clinicId;
  DynamicFormDefinition? _definition;
  bool _isLoading = false;
  bool _isSaving = false;
  int _version = 0;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  int get version => _version;
  DynamicFormDefinition? get definition => _definition;
  List<DynamicFormSection> get sections => _definition?.sections ?? [];

  List<FormFieldTemplate> get availableTemplates {
    final assignedKeys = <String>{
      for (final section in sections)
        for (final field in section.fields)
          if (!field.isCustom) field.key,
    };
    return kFormFieldCatalog
        .where((template) => !assignedKeys.contains(template.key))
        .toList();
  }

  Future<void> loadDefinition() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _firebaseService.fetchFormDefinition(
        _formId,
        clinicId: _clinicId,
      );
      if (data != null) {
        _definition = DynamicFormDefinition.fromMap(data);
      } else {
        _definition = defaultDynamicFormDefinition();
      }
      _version++;
    } catch (e) {
      _definition = defaultDynamicFormDefinition();
      debugPrint('Error loading form definition: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateDefinition(List<DynamicFormSection> updatedSections) {
    if (_definition == null) return;
    _definition = _definition!.copyWith(sections: updatedSections);
    _version++;
    notifyListeners();
  }

  void addSection() {
    if (_definition == null) return;
    final newSection = DynamicFormSection(
      id: UniqueKey().toString(),
      title: 'New Section',
      description: '',
      fields: const [],
    );
    final updated = [...sections, newSection];
    _updateDefinition(updated);
  }

  void removeSection(String sectionId) {
    if (_definition == null) return;
    final updated = sections
        .where((section) => section.id != sectionId)
        .toList();
    if (updated.isEmpty) return;
    _updateDefinition(updated);
  }

  void updateSectionTitle(String sectionId, String title) {
    if (_definition == null) return;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        return section.copyWith(title: title);
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  void addFieldToSection(String sectionId, FormFieldTemplate template) {
    if (_definition == null) return;
    final fieldKey = template.key.isEmpty
        ? 'custom_${DateTime.now().microsecondsSinceEpoch}'
        : template.key;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        // Use fieldKey for both id and key
        final fieldName = fieldKey.isNotEmpty ? fieldKey : sanitizeFieldName(template.label.isEmpty ? 'Custom Field' : template.label);
        final newField = DynamicFormField(
          id: fieldName,
          key: fieldName,
          label: template.label.isEmpty ? 'Custom Field' : template.label,
          hint: template.hint,
          type: template.type,
          options: template.options,
          required: template.required,
          isCustom: !template.isSystemField,
          isShowTable: false,
          extra: template.extra,
        );
        return section.copyWith(fields: [...section.fields, newField]);
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  void addCustomField(String sectionId) {
    addFieldToSection(
      sectionId,
      const FormFieldTemplate(
        key: '',
        label: 'Custom Field',
        isSystemField: false,
      ),
    );
  }

  void removeField(String sectionId, String fieldId) {
    if (_definition == null) return;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        return section.copyWith(
          fields: section.fields.where((field) => field.id != fieldId).toList(),
        );
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  void updateFieldLabel(String sectionId, String fieldId, String label) {
    _mutateField(sectionId, fieldId, (field) => field.copyWith(label: label));
  }

  void updateFieldHint(String sectionId, String fieldId, String hint) {
    _mutateField(sectionId, fieldId, (field) => field.copyWith(hint: hint));
  }

  void updateFieldRequired(String sectionId, String fieldId, bool value) {
    _mutateField(
      sectionId,
      fieldId,
      (field) => field.copyWith(required: value),
    );
  }

  void updateFieldType(
    String sectionId,
    String fieldId,
    DynamicFieldType type,
  ) {
    _mutateField(
      sectionId,
      fieldId,
      (field) => field.copyWith(
        type: type,
        options:
            type == DynamicFieldType.dropdown ||
                type == DynamicFieldType.checkbox
            ? (field.options.isEmpty ? ['Option 1', 'Option 2'] : field.options)
            : const [],
      ),
    );
  }

  void updateFieldOptions(
    String sectionId,
    String fieldId,
    List<String> options,
  ) {
    _mutateField(
      sectionId,
      fieldId,
      (field) => field.copyWith(options: options),
    );
  }

  void _mutateField(
    String sectionId,
    String fieldId,
    DynamicFormField Function(DynamicFormField field) transformer,
  ) {
    if (_definition == null) return;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        final newFields = section.fields.map((field) {
          if (field.id == fieldId) {
            return transformer(field);
          }
          return field;
        }).toList();
        return section.copyWith(fields: newFields);
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  Future<bool> saveDefinition() async {
    if (_definition == null || _isSaving) return false;
    final allKeys = <String>{
      for (final section in sections)
        for (final field in section.fields) field.key,
    };
    final missingRequired = kMandatoryFieldKeys.difference(allKeys);
    if (missingRequired.isNotEmpty) {
      throw Exception(
        'Please include required fields: ${missingRequired.join(', ')}',
      );
    }

    _isSaving = true;
    notifyListeners();
    try {
      await _firebaseService.saveFormDefinition(
        _formId,
        _definition!.toMap(),
        clinicId: _clinicId,
      );
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<DynamicFormDefinition?> fetchDefinitionById(String formId) async {
    try {
      final data = await _firebaseService.fetchFormDefinition(
        formId,
        clinicId: _clinicId,
      );
      if (data != null) {
        return DynamicFormDefinition.fromMap(data);
      }
    } catch (e) {
      debugPrint('Error fetching form definition for $formId: $e');
    }
    if (formId == _formId && _definition != null) {
      return _definition;
    }
    return null;
  }

  Future<DynamicFormDefinition?> fetchDefinitionFromAsset(String formId) async {
    // Asset files have been migrated to Firebase
    // Return null to use default form definition
    debugPrint('Form schema not found in Firebase for $formId. Using default form definition.');
    return null;
  }
}

