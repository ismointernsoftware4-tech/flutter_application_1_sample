import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

import '../models/auth_models.dart';
import '../../../shared/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Temporary credentials that work without Firestore
  static const String _tempEmail = 'suriya@gmail.com';
  static const String _tempPassword = '123456';

  AuthCredentials _loginData = const AuthCredentials();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _sessionEmail;
  String? _sessionName;
  String? _sessionRole;

  AuthCredentials get loginData => _loginData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasCheckedAuth => true;
  String? get errorMessage => _errorMessage;
  String get sessionEmail => _sessionEmail ?? '';
  String get sessionName => _sessionName ?? 'User';
  String get sessionRole => _sessionRole ?? 'User';

  AuthProvider();

  void updateLoginEmail(String value) {
    _loginData = _loginData.copyWith(email: value.trim());
    _clearError();
    notifyListeners();
  }

  void updateLoginPassword(String value) {
    _loginData = _loginData.copyWith(password: value);
    _clearError();
    notifyListeners();
  }

  Future<void> login() async {
    if (!_loginData.isValid) {
      _errorMessage = 'Enter a valid email and password (min 6 characters).';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check temporary credentials first (works without Firestore)
      if (_loginData.email.toLowerCase().trim() == _tempEmail.toLowerCase() &&
          _loginData.password == _tempPassword) {
        _sessionEmail = _tempEmail;
        _sessionName = 'Temporary Admin';
        _sessionRole = 'Super Admin';
        _isAuthenticated = true;
        _errorMessage = null;
        // Try to sign in to Firebase Auth (optional, won't fail if it doesn't work)
        _syncWithFirebaseAuth(_tempEmail, _tempPassword);
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Regular Firestore-based authentication
      final matchedUser =
          await _firebaseService.findUserByEmail(_loginData.email);
      if (matchedUser == null) {
        _errorMessage = 'Account not found. Please check the email.';
      } else if (!_firebaseService.verifyPassword(
        _loginData.password,
        matchedUser.password, // This is the hashed password from Firestore
      )) {
        _errorMessage = 'Incorrect password. Please try again.';
      } else {
        _sessionEmail = matchedUser.email;
        _sessionName = matchedUser.name.isNotEmpty
            ? matchedUser.name
            : matchedUser.email.split('@').first;
        _sessionRole =
            matchedUser.role.isNotEmpty ? matchedUser.role : 'User';
        _isAuthenticated = true;
        _errorMessage = null;
        // Sign in to Firebase Auth using plain password
        _syncWithFirebaseAuth(matchedUser.email, _loginData.password);
      }
    } catch (e) {
      _errorMessage = 'Unable to login. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncWithFirebaseAuth(String email, String plainPassword) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: plainPassword, // Use plain password for Firebase Auth
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // User exists in Firestore but not in Auth - this shouldn't happen with new flow
        debugPrint('User not found in Firebase Auth: $e');
      }
    } catch (e) {
      debugPrint('Auth sync error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    _isAuthenticated = false;
    _errorMessage = null;
    _loginData = const AuthCredentials();
    _sessionEmail = null;
    _sessionName = null;
    _sessionRole = null;
    notifyListeners();
  }

  void clearFormData() {
    _loginData = const AuthCredentials();
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }
}

