import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/services/firebase_service.dart';

class ClinicService {
  ClinicService({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;

  Future<void> saveClinic(Map<String, dynamic> data) async {
    await _firebaseService.saveClinic(data);
  }

  Stream<List<Map<String, dynamic>>> listenClinics() {
    if (!_firebaseService.isAvailable) {
      return Stream.value(_seedClinics());
    }
    return FirebaseFirestore.instance
        .collection('clinics') // Firestore path uses lowercase 'clinics'
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return _seedClinics();
          }
          final List<Map<String, dynamic>> clinics = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            String? name = (data['clinicName'] as String?)?.trim();
            clinics.add({
              'id': doc.id,
              'name': name?.isNotEmpty == true ? name : doc.id,
            });
          }
          return clinics;
        });
  }

  List<Map<String, dynamic>> _seedClinics() {
    return const [
      {
        'id': 'clinic_1',
        'name': 'Sunrise Fertility Center',
      },
      {
        'id': 'clinic_2',
        'name': 'Sample Clinic 2',
      },
    ];
  }

}

