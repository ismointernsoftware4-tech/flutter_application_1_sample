import 'package:flutter/material.dart';

import '../../form_builder/models/dynamic_form_models.dart';
import '../../../shared/services/firebase_service.dart';

class ClinicFormProvider extends ChangeNotifier {
  ClinicFormProvider({String? clinicId}) : _clinicId = clinicId;

  final FirebaseService _firebaseService = FirebaseService();
  static const String _formId = 'clinic_form';
  final String? _clinicId;

  DynamicFormDefinition? _definition;
  bool _isLoading = false;
  int _version = 0;

  DynamicFormDefinition? get definition => _definition;
  bool get isLoading => _isLoading;
  int get version => _version;

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
        _definition = await _loadFromAsset();
      }
      _version++;
    } catch (e) {
      debugPrint('Clinic form load failed: $e');
      _definition ??= await _loadFromAsset();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DynamicFormDefinition> _loadFromAsset() async {
    // Asset file has been migrated to Firebase
    // Return empty form definition as fallback
    debugPrint('Clinic form not found in Firebase. Using empty form definition.');
    return DynamicFormDefinition(
      id: _formId,
      name: 'Clinic Registration Form',
      sections: [],
    );
  }

}

