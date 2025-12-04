import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

import '../../../shared/models/auth_models.dart';
import '../../settings/models/settings_models.dart' as settings_models;
import '../../../shared/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  AuthCredentials _loginData = const AuthCredentials();
  bool _isLoading = false;
  bool _isAuthenticated = true; // Set to true to skip login screen
  String? _errorMessage;
  String? _sessionEmail = 'user@example.com'; // Default email for sidebar
  String? _sessionName = 'User'; // Default name for sidebar

  AuthCredentials get loginData => _loginData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasCheckedAuth => true;
  String? get errorMessage => _errorMessage;
  String get sessionEmail => _sessionEmail ?? '';
  String get sessionName => _sessionName ?? 'User';

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
      final matchedUser =
          await _firebaseService.findUserByEmail(_loginData.email);
      if (matchedUser == null) {
        _errorMessage = 'Account not found. Please check the email.';
      } else if (matchedUser.password != _loginData.password) {
        _errorMessage = 'Incorrect password. Please try again.';
      } else {
        _sessionEmail = matchedUser.email;
        _sessionName = matchedUser.name.isNotEmpty
            ? matchedUser.name
            : matchedUser.email.split('@').first;
        _isAuthenticated = true;
        _errorMessage = null;
        _syncWithFirebaseAuth(matchedUser);
      }
    } catch (e) {
      _errorMessage = 'Unable to login. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncWithFirebaseAuth(settings_models.User user) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        try {
          await _firebaseService.createAuthUser(user.email, user.password);
          await _firebaseAuth.signInWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
        } catch (e) {
          debugPrint('Auth sync error: $e');
        }
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

