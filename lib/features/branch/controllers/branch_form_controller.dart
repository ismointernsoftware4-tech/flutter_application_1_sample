import 'package:flutter/material.dart';

import '../services/branch_service.dart';

class BranchFormController extends ChangeNotifier {
  BranchFormController({BranchService? branchService, String? clinicId})
      : _branchService = branchService ?? BranchService(),
        _clinicId = clinicId;

  final BranchService _branchService;
  final String? _clinicId;
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

  Future<String> submit() async {
    if (_isSubmitting) return '';
    _isSubmitting = true;
    notifyListeners();
    try {
      // Ensure all accumulated form data is included
      final dataToSave = Map<String, dynamic>.from(_formData);
      
      // Flatten customFields if exists
      if (dataToSave.containsKey('customFields') && 
          dataToSave['customFields'] is Map) {
        final customFields = dataToSave.remove('customFields') as Map<String, dynamic>;
        dataToSave.addAll(customFields);
      }
      
      if (_clinicId == null || _clinicId.isEmpty) {
        throw Exception('Clinic ID is required');
      }
      
      print('Submitting branch data with ${dataToSave.length} fields');
      print('Fields: ${dataToSave.keys.toList()}');
      final branchId = await _branchService.createBranch(_clinicId, dataToSave);
      return branchId;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

