import 'package:flutter/material.dart';

import '../services/clinic_service.dart';

class ClinicFormController extends ChangeNotifier {
  ClinicFormController({ClinicService? clinicService})
      : _clinicService = clinicService ?? ClinicService();

  final ClinicService _clinicService;
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);

  void updateData(Map<String, dynamic> data) {
    _formData.addAll(data);
    notifyListeners();
  }

  void reset() {
    _formData.clear();
    _isSubmitting = false;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    notifyListeners();
    try {
      // Ensure all accumulated form data is included
      final dataToSave = Map<String, dynamic>.from(_formData);
      print('Submitting clinic data with ${dataToSave.length} fields');
      print('Fields: ${dataToSave.keys.toList()}');
      await _clinicService.saveClinic(dataToSave);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

