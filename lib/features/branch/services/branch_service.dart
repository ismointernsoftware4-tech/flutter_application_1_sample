import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/branch_model.dart';
import '../../../shared/services/firebase_service.dart';

class BranchService {
  BranchService({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;

  // Generate next branch code (BRN-0001, BRN-0002, etc.) for a specific clinic
  Future<String> generateBranchCode(String clinicId) async {
    if (!_firebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      final clinicDoc = FirebaseFirestore.instance.collection('clinics').doc(clinicId);
      await clinicDoc.set({'type': 'clinic'}, SetOptions(merge: true));
      final branchesCollection = clinicDoc.collection('branch');
      final snapshot = await branchesCollection.get();

      if (snapshot.docs.isEmpty) {
        return 'BRN-0001';
      }

      // Extract all existing branch codes and find the highest number
      int maxNumber = 0;
      for (var doc in snapshot.docs) {
        final docId = doc.id;
        if (docId.startsWith('BRN-')) {
          try {
            final numberStr = docId.substring(4); // Remove "BRN-" prefix
            final number = int.parse(numberStr);
            if (number > maxNumber) {
              maxNumber = number;
            }
          } catch (e) {
            // Skip invalid format
            continue;
          }
        }
      }

      // Generate next code
      final nextNumber = maxNumber + 1;
      return 'BRN-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      print('Error generating branch code: $e');
      throw Exception('Error generating branch code: $e');
    }
  }

  // Create a new branch under a clinic
  Future<String> createBranch(String clinicId, Map<String, dynamic> branchData) async {
    if (!_firebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      // Ensure clinic document exists
      final clinicDoc = FirebaseFirestore.instance.collection('clinics').doc(clinicId);
      await clinicDoc.set({'type': 'clinic'}, SetOptions(merge: true));
      
      // Generate branch code
      final branchCode = await generateBranchCode(clinicId);
      final branchId = branchCode; // Use branchCode as document ID

      final branchesCollection = clinicDoc.collection('branch');
      await branchesCollection.doc(branchId).set({
        ...branchData,
        'branchId': branchId,
        'branchCode': branchCode,
        'clinicId': clinicId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Branch created successfully at /clinics/$clinicId/branch/$branchId/');
      return branchId;
    } catch (e) {
      print('Error creating branch: $e');
      throw Exception('Error creating branch: $e');
    }
  }

  // Update an existing branch
  Future<void> updateBranch(String clinicId, String branchId, Map<String, dynamic> branchData) async {
    if (!_firebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      final branchDoc = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('branch')
          .doc(branchId);
      await branchDoc.update({
        ...branchData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Branch updated successfully at /clinics/$clinicId/branch/$branchId/');
    } catch (e) {
      print('Error updating branch: $e');
      throw Exception('Error updating branch: $e');
    }
  }

  // Get branch by ID
  Future<BranchModel?> getBranchById(String clinicId, String branchId) async {
    if (!_firebaseService.isAvailable) {
      return null;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('branch')
          .doc(branchId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['branchId'] = doc.id;
      return BranchModel.fromJson(data);
    } catch (e) {
      print('Error getting branch: $e');
      return null;
    }
  }

  // Get all branches for a clinic
  Stream<List<BranchModel>> getAllBranches(String clinicId) {
    if (!_firebaseService.isAvailable) {
      debugPrint('Firebase not available for getAllBranches');
      return Stream.value([]);
    }
    
    if (clinicId.isEmpty) {
      debugPrint('ClinicId is empty, cannot fetch branches');
      return Stream.value([]);
    }
    
    try {
      debugPrint('Fetching branches for clinic: $clinicId from path: /clinics/$clinicId/branch');
      return FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('branch')
          .snapshots()
          .map((snapshot) {
        debugPrint('Received ${snapshot.docs.length} branch documents');
        
        final branches = <BranchModel>[];
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            if (data.isEmpty) {
              debugPrint('Branch document ${doc.id} has no data');
              continue;
            }
            
            data['branchId'] = doc.id; // Use document ID as branchId (BRN-001, BRN-002, etc.)
            debugPrint('Branch document ID: ${doc.id}, branchName: ${data['branchName']}, status: ${data['status']}');
            
            final branch = BranchModel.fromJson(data);
            
            // Validate required fields
            if (branch.branchName.isEmpty) {
              debugPrint('Warning: Branch ${doc.id} has empty branchName');
            }
            
            branches.add(branch);
          } catch (e, stackTrace) {
            debugPrint('Error parsing branch document ${doc.id}: $e');
            debugPrint('Stack trace: $stackTrace');
            debugPrint('Document data: ${doc.data()}');
          }
        }
        
        debugPrint('Successfully parsed ${branches.length} branches: ${branches.map((b) => '${b.branchId} (${b.branchName})').toList()}');
        return branches;
      }).handleError((error, stackTrace) {
        debugPrint('Error in getAllBranches stream: $error');
        debugPrint('Stack trace: $stackTrace');
        return <BranchModel>[];
      });
    } catch (e, stackTrace) {
      debugPrint('Error getting branches: $e');
      debugPrint('Stack trace: $stackTrace');
      return Stream.value([]);
    }
  }

  // Get branches by status for a clinic
  Stream<List<BranchModel>> getBranchesByStatus(String clinicId, String status) {
    if (!_firebaseService.isAvailable) {
      return Stream.value([]);
    }
    try {
      return FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('branch')
          .where('status', isEqualTo: status)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['branchId'] = doc.id;
          return BranchModel.fromJson(data);
        }).toList();
      });
    } catch (e) {
      print('Error getting branches by status: $e');
      return Stream.value([]);
    }
  }

  // Delete branch (soft delete by setting status to Inactive)
  Future<void> deleteBranch(String clinicId, String branchId) async {
    await updateBranch(clinicId, branchId, {'status': 'Inactive'});
  }
}

