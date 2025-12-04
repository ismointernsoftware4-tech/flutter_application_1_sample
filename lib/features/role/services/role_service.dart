import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/role_model.dart';

class RoleService {
  RoleService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new role document under:
  /// /clinics/{clinicId}/Roles/{roleId}
  Future<String> createRole({
    required String clinicId,
    required RoleModel role,
  }) async {
    final rolesCollection =
        _firestore.collection('clinics').doc(clinicId).collection('Roles');

    final now = DateTime.now();
    final data = {
      'roleName': role.roleName,
      'description': role.description,
      'status': role.status,
      'permissions': role.permissions,
      'createdAt': now,
      'updatedAt': now,
    };

    final docRef = await rolesCollection.add(data);
    return docRef.id;
  }

  /// Get stream of roles for a clinic
  /// Path: /clinics/{clinicId}/Roles
  Stream<List<RoleModel>> getRolesStream(String clinicId) {
    return _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('Roles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RoleModel(
          id: doc.id,
          roleName: data['roleName'] ?? '',
          description: data['description'] ?? '',
          status: data['status'] ?? 'Active',
          permissions: List<String>.from(data['permissions'] ?? []),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Get a role by roleName from Firestore
  /// Path: /clinics/{clinicId}/Roles (query by roleName)
  Future<RoleModel?> getRoleByName({
    required String clinicId,
    required String roleName,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('Roles')
          .where('roleName', isEqualTo: roleName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      return RoleModel(
        id: doc.id,
        roleName: data['roleName'] ?? '',
        description: data['description'] ?? '',
        status: data['status'] ?? 'Active',
        permissions: List<String>.from(data['permissions'] ?? []),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting role by name: $e');
      return null;
    }
  }

  /// Get all role names for a clinic (for dropdown)
  /// Returns unique, sorted role names
  Future<List<String>> getRoleNames(String clinicId) async {
    try {
      final snapshot = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('Roles')
          .where('status', isEqualTo: 'Active')
          .get();

      // Extract role names, filter empty, remove duplicates, and sort
      final roleNames = snapshot.docs
          .map((doc) => doc.data()['roleName'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toSet() // Remove duplicates
          .toList();
      roleNames.sort();
      return roleNames;
    } catch (e) {
      debugPrint('Error getting role names: $e');
      return [];
    }
  }

  /// Delete a role
  Future<void> deleteRole({
    required String clinicId,
    required String roleId,
  }) async {
    await _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('Roles')
        .doc(roleId)
        .delete();
  }
}

