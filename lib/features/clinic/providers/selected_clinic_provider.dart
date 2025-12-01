import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/clinic_models.dart';
import '../models/clinic_summary_info.dart';

class SelectedClinicProvider extends ChangeNotifier {
  SelectedClinicProvider() {
    _loadClinics();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ClinicSummaryInfo> _availableClinics = [];

  List<ClinicSummaryInfo> get availableClinics => _availableClinics;
  ClinicData? _clinic;
  bool _isLoading = false;
  String? _currentSource;

  ClinicData? get clinic => _clinic;
  bool get isLoading => _isLoading;
  String? get currentSource => _currentSource;

  void _registerClinicSummary(String id, String name) {
    final exists = _availableClinics.any((clinic) => clinic.id == id);
    if (exists) return;
    _availableClinics.add(ClinicSummaryInfo(id: id, name: name));
  }

  Future<void> _loadClinics() async {
    try {
      final snapshot = await _firestore.collection('clinics').get();
      _availableClinics.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = data['clinicName'] as String? ?? doc.id;
        _registerClinicSummary(doc.id, name);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load clinics: $e');
    }
  }

  Future<void> loadClinicFromAsset(String assetPath, {String? overrideClinicId}) async {
    if (_currentSource == assetPath && _clinic != null && overrideClinicId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString(assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      
      // Override clinicId if provided (from Firestore selection)
      // This ensures the selected clinicId is used, not the one from the asset file
      if (overrideClinicId != null && overrideClinicId.isNotEmpty) {
        data['clinicId'] = overrideClinicId;
        data['clinicCode'] = overrideClinicId; // Also update clinicCode to match
      }
      
      _clinic = ClinicData.fromJson(data);
      _currentSource = assetPath;
      if (_clinic != null) {
        // Register with the actual clinicId (which may have been overridden)
        _registerClinicSummary(_clinic!.clinicId, _clinic!.clinicName);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load clinic asset $assetPath: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load clinic directly from Firestore by clinicId
  /// This ensures the clinicId from Firestore is used for all form storage paths
  Future<void> loadClinicFromFirestore(String clinicId) async {
    if (_clinic?.clinicId == clinicId) return;
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('clinics').doc(clinicId).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Convert Firestore Timestamps to strings
        final jsonData = Map<String, dynamic>.from(data);
        jsonData['clinicId'] = clinicId; // Ensure clinicId matches Firestore doc ID
        
        // Convert Timestamp fields to strings
        if (jsonData['createdAt'] is Timestamp) {
          jsonData['createdAt'] = (jsonData['createdAt'] as Timestamp).toDate().toIso8601String();
        } else if (jsonData['createdAt'] == null) {
          jsonData['createdAt'] = '';
        }
        if (jsonData['updatedAt'] is Timestamp) {
          jsonData['updatedAt'] = (jsonData['updatedAt'] as Timestamp).toDate().toIso8601String();
        } else if (jsonData['updatedAt'] == null) {
          jsonData['updatedAt'] = '';
        }
        
        _clinic = ClinicData.fromJson(jsonData);
        _currentSource = 'firestore:$clinicId';
        _registerClinicSummary(clinicId, _clinic!.clinicName);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load clinic from Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the current selected clinic ID
  String? get selectedClinicId => _clinic?.clinicId;

  void clear() {
    _clinic = null;
    _currentSource = null;
    notifyListeners();
  }
}

