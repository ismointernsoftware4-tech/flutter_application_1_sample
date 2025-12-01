import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../services/user_service.dart';
import '../../../shared/services/firebase_service.dart';

class UserFormController extends ChangeNotifier {
  UserFormController({UserService? userService, FirebaseService? firebaseService, String? clinicId})
      : _userService = userService ?? UserService(),
        _firebaseService = firebaseService ?? FirebaseService(),
        _clinicId = clinicId;

  final UserService _userService;
  final FirebaseService _firebaseService;
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
      
      // Get email and password for creating auth user
      final email = dataToSave['email'] as String? ?? '';
      final password = dataToSave['password'] as String? ?? '';
      
      if (email.isEmpty) {
        throw Exception('Email is required');
      }
      
      // Create Firebase Auth user if password is provided
      String uid;
      if (password.isNotEmpty && password.length >= 6) {
        uid = await _firebaseService.createAuthUserAndGetUid(email, password);
      } else {
        // If no password, try to get existing user or create without password
        try {
          final user = fb_auth.FirebaseAuth.instance.currentUser;
          if (user != null && user.email == email) {
            uid = user.uid;
          } else {
            // Create user without password (they'll need to reset password)
            uid = await _firebaseService.createAuthUserAndGetUid(email, 'TempPassword123!');
          }
        } catch (e) {
          throw Exception('Could not create or find user: $e');
        }
      }
      
      // Get clinicId from data or use stored clinicId
      final clinicId = dataToSave['clinicId'] as String? ?? _clinicId ?? '';
      
      if (clinicId.isEmpty) {
        throw Exception('Clinic ID is required');
      }
      
      // Remove password from data before saving to Firestore (will be hashed in service)
      // Keep it for now as service will hash it
      
      debugPrint('Submitting user data with ${dataToSave.length} fields');
      debugPrint('Fields: ${dataToSave.keys.toList()}');
      debugPrint('ClinicId: $clinicId');
      await _userService.createUser(clinicId, uid, dataToSave);
      return uid;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

