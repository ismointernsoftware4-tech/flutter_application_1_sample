import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';

class FormBuilderWorkspaceProvider extends ChangeNotifier {
  FormBuilderWorkspaceProvider();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DynamicFormSection> _sections = [];
  String? _selectedFormId;
  String? _selectedSectionId;
  String? _selectedFieldId;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _clinicId;
  String? _lastLoadedClinicId; // Track which clinic's data is currently loaded

  List<DynamicFormSection> get sections => _sections;
  String? get selectedFormId => _selectedFormId;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  DynamicFormSection? get selectedSection {
    if (_sections.isEmpty) return null;
    if (_selectedSectionId == null) return _sections.first;
    return _sections.firstWhere(
      (section) => section.id == _selectedSectionId,
      orElse: () => _sections.first,
    );
  }

  DynamicFormField? get selectedField {
    if (_selectedSectionId == null || _selectedFieldId == null) return null;
    final section = selectedSection;
    if (section == null || section.fields.isEmpty) return null;
    return section.fields.firstWhere(
      (field) => field.id == _selectedFieldId,
      orElse: () => section.fields.first,
    );
  }

  void setClinicId(String? clinicId) {
    if (_clinicId == clinicId) return;
    
    // If clinicId is changing, clear the cached form data
    // This ensures we load the correct clinic's form data
    final clinicChanged = _clinicId != null && _clinicId != clinicId;
    _clinicId = clinicId;
    _lastLoadedClinicId = null; // Reset to force reload
    
    if (clinicChanged) {
      // Clear cached form data when clinic changes
      _sections = [];
      _selectedFormId = null;
      _selectedSectionId = null;
      _selectedFieldId = null;
      notifyListeners();
    }
  }

  CollectionReference<Map<String, dynamic>> _formsCollection() {
    if (_clinicId != null && _clinicId!.isNotEmpty) {
      return _firestore.collection('clinics').doc(_clinicId).collection('forms');
    }
    return _firestore.collection('forms');
  }

  Future<void> loadForm(String formId) async {
    // Check if we need to reload:
    // 1. FormId changed
    // 2. ClinicId changed (different clinic's data)
    // 3. Sections are empty
    // 4. ClinicId is not set
    final clinicChanged = _lastLoadedClinicId != _clinicId;
    final formChanged = formId != _selectedFormId;
    final shouldReload = formChanged || 
                        clinicChanged ||
                        _sections.isEmpty ||
                        _clinicId == null;
    
    if (!shouldReload) return;
    
    _isLoading = true;
    _selectedFormId = formId;
    _lastLoadedClinicId = _clinicId; // Track which clinic we're loading for
    notifyListeners();
    try {
      final doc = await _formsCollection().doc(formId).get();

      if (doc.exists &&
          (doc.data()?['sections'] as List?)?.isNotEmpty == true) {
        final data = doc.data();
        _sections = (data!['sections'] as List<dynamic>)
            .map(
              (section) => DynamicFormSection.fromMap(
                Map<String, dynamic>.from(section as Map),
              ),
            )
            .toList();
      } else {
        _sections = await _loadFromAsset(formId);
      }
      if (_sections.isNotEmpty) {
        _selectedSectionId = _sections.first.id;
        _selectedFieldId = _sections.first.fields.isNotEmpty
            ? _sections.first.fields.first.id
            : null;
      } else {
        _selectedSectionId = null;
        _selectedFieldId = null;
      }
    } catch (e) {
      debugPrint('Error loading form $formId: $e');
      _sections = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSection() {
    final section = DynamicFormSection(
      id: UniqueKey().toString(),
      title: 'Untitled Section',
      description: '',
      fields: const [],
    );
    _sections = [..._sections, section];
    _selectedSectionId = section.id;
    _selectedFieldId = null;
    notifyListeners();
  }

  void updateSection(DynamicFormSection updated) {
    _sections = _sections.map((section) {
      if (section.id == updated.id) {
        return updated;
      }
      return section;
    }).toList();
    notifyListeners();
  }

  void removeSection(String sectionId) {
    _sections = _sections.where((section) => section.id != sectionId).toList();
    if (_selectedSectionId == sectionId) {
      _selectedSectionId = _sections.isNotEmpty ? _sections.first.id : null;
      _selectedFieldId =
          _sections.isNotEmpty && _sections.first.fields.isNotEmpty
          ? _sections.first.fields.first.id
          : null;
    }
    notifyListeners();
  }

  void selectSection(String sectionId) {
    _selectedSectionId = sectionId;
    _selectedFieldId = null;
    notifyListeners();
  }

  void selectField(String sectionId, String fieldId) {
    _selectedSectionId = sectionId;
    _selectedFieldId = fieldId;
    notifyListeners();
  }

  void addFieldToSection(DynamicFieldType type, {String? sectionId}) {
    if (_sections.isEmpty && sectionId == null) {
      addSection();
    }
    final targetSectionId =
        sectionId ?? _selectedSectionId ?? _sections.first.id;
    final sectionIndex = _sections.indexWhere(
      (section) => section.id == targetSectionId,
    );
    if (sectionIndex == -1) return;
    final field = _createField(type);
    final updatedSection = _sections[sectionIndex].copyWith(
      fields: [..._sections[sectionIndex].fields, field],
    );
    _sections[sectionIndex] = updatedSection;
    _selectedSectionId = updatedSection.id;
    _selectedFieldId = field.id;
    notifyListeners();
  }

  void updateField(DynamicFormField updatedField) {
    final sectionIndex = _sections.indexWhere(
      (section) => section.fields.any((field) => field.id == updatedField.id),
    );
    if (sectionIndex == -1) return;
    final fields = _sections[sectionIndex].fields.map((field) {
      if (field.id == updatedField.id) return updatedField;
      return field;
    }).toList();
    _sections[sectionIndex] = _sections[sectionIndex].copyWith(fields: fields);
    _selectedSectionId = _sections[sectionIndex].id;
    _selectedFieldId = updatedField.id;
    notifyListeners();
  }

  void removeField(String fieldId) {
    for (var i = 0; i < _sections.length; i++) {
      final fields = _sections[i].fields;
      if (fields.any((field) => field.id == fieldId)) {
        final updatedFields = fields
            .where((field) => field.id != fieldId)
            .toList();
        _sections[i] = _sections[i].copyWith(fields: updatedFields);
        if (_selectedFieldId == fieldId) {
          if (updatedFields.isNotEmpty) {
            _selectedFieldId = updatedFields.first.id;
          } else {
            _selectedFieldId = null;
          }
        }
        break;
      }
    }
    notifyListeners();
  }

  void reorderSections(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _sections.removeAt(oldIndex);
    _sections.insert(newIndex, item);
    notifyListeners();
  }

  void reorderFields(String sectionId, int oldIndex, int newIndex) {
    final sectionIndex = _sections.indexWhere(
      (section) => section.id == sectionId,
    );
    if (sectionIndex == -1) return;
    final fields = [..._sections[sectionIndex].fields];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = fields.removeAt(oldIndex);
    fields.insert(newIndex, item);
    _sections[sectionIndex] = _sections[sectionIndex].copyWith(fields: fields);
    notifyListeners();
  }

  void moveField({
    required String fromSectionId,
    required String toSectionId,
    required String fieldId,
    required int targetIndex,
  }) {
    if (fromSectionId == toSectionId) {
      final sectionIndex = _sections.indexWhere(
        (section) => section.id == fromSectionId,
      );
      if (sectionIndex == -1) return;
      reorderFields(
        fromSectionId,
        _sections[sectionIndex].fields.indexWhere(
          (field) => field.id == fieldId,
        ),
        targetIndex,
      );
      return;
    }

    final sourceIndex = _sections.indexWhere(
      (section) => section.id == fromSectionId,
    );
    final targetIndexSection = _sections.indexWhere(
      (section) => section.id == toSectionId,
    );
    if (sourceIndex == -1 || targetIndexSection == -1) return;

    final sourceFields = [..._sections[sourceIndex].fields];
    final fieldPosition = sourceFields.indexWhere(
      (field) => field.id == fieldId,
    );
    if (fieldPosition == -1) return;
    final field = sourceFields.removeAt(fieldPosition);
    _sections[sourceIndex] = _sections[sourceIndex].copyWith(
      fields: sourceFields,
    );

    final targetFields = [..._sections[targetIndexSection].fields];
    final boundedIndex = targetIndex.clamp(0, targetFields.length);
    targetFields.insert(boundedIndex, field);
    _sections[targetIndexSection] = _sections[targetIndexSection].copyWith(
      fields: targetFields,
    );

    _selectedSectionId = toSectionId;
    _selectedFieldId = fieldId;
    notifyListeners();
  }

  Future<void> save() async {
    if (_selectedFormId == null) return;
    _isSaving = true;
    notifyListeners();
    try {
      if (_clinicId != null && _clinicId!.isNotEmpty) {
        await _firestore
            .collection('clinics')
            .doc(_clinicId)
            .set({'type': 'clinic'}, SetOptions(merge: true));
      }
      final formData = <String, dynamic>{
        'id': _selectedFormId,
        'sections': _sections.map((section) => section.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Preserve form name if it exists
      final existingDoc = await _formsCollection().doc(_selectedFormId).get();
      if (existingDoc.exists && existingDoc.data() != null) {
        final existingData = existingDoc.data()!;
        if (existingData.containsKey('name')) {
          formData['name'] = existingData['name'];
        }
        if (existingData.containsKey('createdAt')) {
          formData['createdAt'] = existingData['createdAt'];
        }
      } else {
        // If form doesn't exist, set name from formId
        formData['name'] = _selectedFormId?.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ') ?? 'Untitled Form';
        formData['createdAt'] = FieldValue.serverTimestamp();
      }
      
      await _formsCollection().doc(_selectedFormId).set(formData);
    } catch (e) {
      debugPrint('Failed to save form: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  DynamicFormField _createField(DynamicFieldType type) {
    // Use sanitized field name for both id and key
    final fieldName = sanitizeFieldName('untitled_field_${DateTime.now().microsecondsSinceEpoch}');
    return DynamicFormField(
      id: fieldName,
      key: fieldName,
      label: 'Untitled Field',
      hint: 'Placeholder',
      type: type,
      options:
          type == DynamicFieldType.dropdown || type == DynamicFieldType.radio
          ? ['Option 1', 'Option 2']
          : const [],
      required: false,
      isCustom: true,
      isShowTable: false,
      extra: _defaultExtras(type),
    );
  }

  Map<String, dynamic> _defaultExtras(DynamicFieldType type) {
    final extras = <String, dynamic>{'helpText': ''};
    switch (type) {
      case DynamicFieldType.number:
        extras.addAll({'numberFormat': 'integer', 'min': null, 'max': null});
        break;
      case DynamicFieldType.dropdown:
      case DynamicFieldType.radio:
        extras.addAll({'displayPlaceholder': true});
        break;
      case DynamicFieldType.date:
        extras.addAll({'minDate': null, 'maxDate': null});
        break;
      case DynamicFieldType.checkbox:
        extras.addAll({'defaultChecked': false});
        break;
      case DynamicFieldType.file:
        extras.addAll({
          'allowedTypes': ['pdf', 'jpg', 'png'],
          'maxSizeMb': 10.0,
          'minSizeMb': null,
          'allowMultiple': false,
        });
        break;
      default:
        break;
    }
    return extras;
  }

  Future<List<DynamicFormSection>> _loadFromAsset(String formId) async {
    // Asset files have been migrated to Firebase
    // Return empty list as fallback
    debugPrint('Form schema not found in Firebase for $formId. Using empty form definition.');
    return [];
  }

  /// Get all available forms from Firebase
  Future<List<Map<String, String>>> getAvailableForms() async {
    try {
      final snapshot = await _formsCollection().get();
      final forms = <Map<String, String>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        forms.add({
          'id': doc.id,
          'name': data['name'] as String? ?? doc.id,
        });
      }
      
      return forms;
    } catch (e) {
      debugPrint('Error fetching available forms: $e');
      return [];
    }
  }

  /// Create a new form with the given name
  Future<String> createNewForm(String formName) async {
    try {
      // Generate form ID from name (lowercase, replace spaces with underscores)
      final formId = formName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
      
      // Check if form already exists
      final existingDoc = await _formsCollection().doc(formId).get();
      if (existingDoc.exists) {
        throw Exception('A form with this name already exists');
      }
      
      // Create new form with empty sections
      await _formsCollection().doc(formId).set({
        'id': formId,
        'name': formName,
        'sections': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Load the newly created form
      _selectedFormId = formId;
      _sections = [];
      _selectedSectionId = null;
      _selectedFieldId = null;
      _lastLoadedClinicId = _clinicId;
      notifyListeners();
      
      return formId;
    } catch (e) {
      debugPrint('Error creating new form: $e');
      rethrow;
    }
  }
}

