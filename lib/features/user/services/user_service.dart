import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../shared/services/firebase_service.dart';
import '../../role/services/role_service.dart';

class UserService {
  UserService({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;
  final RoleService _roleService = RoleService();

  // Create a new user in /Users/{uid} collection
  Future<void> createUser(String clinicId, String uid, Map<String, dynamic> userData) async {
    if (!_firebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      // Hash password if provided
      if (userData.containsKey('password') && userData['password'] != null) {
        final plainPassword = userData['password'] as String;
        userData['password'] = _firebaseService.hashPassword(plainPassword);
      }

      // Get roleId from roleName to create reference
      DocumentReference? roleReference;
      if (userData.containsKey('role') && userData['role'] != null) {
        final roleName = userData['role'] as String;
        try {
          // Get role document ID
          final role = await _roleService.getRoleByName(
            clinicId: clinicId,
            roleName: roleName,
          );
          if (role != null && role.id.isNotEmpty) {
            // Create reference: /clinics/{clinicId}/Roles/{roleId}
            roleReference = FirebaseFirestore.instance
                .collection('clinics')
                .doc(clinicId)
                .collection('Roles')
                .doc(role.id);
          }
        } catch (e) {
          debugPrint('Error getting role for reference: $e');
        }
      }

      // Prepare user data
      final userDocData = <String, dynamic>{
        'name': userData['name'] ?? '',
        'email': userData['email'] ?? '',
        'phone': userData['phone'],
        'username': userData['username'],
        'password': userData['password'], // Already hashed
        'clinicId': clinicId,
        'branchId': userData['branchId'],
        'status': userData['status'] ?? 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

      // Add role as reference if available
      if (roleReference != null) {
        userDocData['role'] = roleReference;
      }

      // Save to /Users/{uid}
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .set(userDocData);

      debugPrint('User created successfully at /Users/$uid/');
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Error creating user: $e');
    }
  }

  // Update an existing user
  Future<void> updateUser(String clinicId, String uid, Map<String, dynamic> userData) async {
    if (!_firebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      // Hash password if being updated
      if (userData.containsKey('password') && userData['password'] != null) {
        final plainPassword = userData['password'] as String;
        userData['password'] = _firebaseService.hashPassword(plainPassword);
      }

      // Update role reference if role is being updated
      if (userData.containsKey('role') && userData['role'] != null) {
        final roleName = userData['role'] as String;
        try {
          final role = await _roleService.getRoleByName(
            clinicId: clinicId,
            roleName: roleName,
          );
          if (role != null && role.id.isNotEmpty) {
            final roleRef = FirebaseFirestore.instance
                .collection('clinics')
                .doc(clinicId)
                .collection('Roles')
                .doc(role.id);
            userData['role'] = roleRef;
          }
        } catch (e) {
          debugPrint('Error updating role reference: $e');
        }
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update({
        ...userData,
      });

      debugPrint('User updated successfully at /Users/$uid/');
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Error updating user: $e');
    }
  }

  // Get user by UID
  Future<UserModel?> getUserById(String clinicId, String uid) async {
    if (!_firebaseService.isAvailable) {
      return null;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['uid'] = doc.id;
      
      // Resolve role reference if it exists
      if (data['role'] is DocumentReference) {
        try {
          final roleRef = data['role'] as DocumentReference;
          final roleDoc = await roleRef.get();
          if (roleDoc.exists) {
            final roleData = roleDoc.data() as Map<String, dynamic>?;
            data['role'] = roleData?['roleName'] ?? 'END_USER';
          }
        } catch (e) {
          debugPrint('Error resolving role reference: $e');
          data['role'] = 'END_USER';
        }
      }
      
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Get users by branch ID for a clinic
  Stream<List<UserModel>> getUsersByBranch(String clinicId, String branchId) {
    if (!_firebaseService.isAvailable) {
      return Stream.value([]);
    }
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .where('clinicId', isEqualTo: clinicId)
          .where('branchId', isEqualTo: branchId)
          .where('status', isEqualTo: 'Active')
          .snapshots()
          .asyncMap((snapshot) async {
        final users = <UserModel>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['uid'] = doc.id;
          
          // Resolve role reference
          if (data['role'] is DocumentReference) {
            try {
              final roleRef = data['role'] as DocumentReference;
              final roleDoc = await roleRef.get();
              if (roleDoc.exists) {
                final roleData = roleDoc.data() as Map<String, dynamic>?;
                data['role'] = roleData?['roleName'] ?? 'END_USER';
              }
            } catch (e) {
              debugPrint('Error resolving role reference: $e');
              data['role'] = 'END_USER';
            }
          }
          
          users.add(UserModel.fromJson(data));
        }
        // Sort by createdAt in memory (descending)
        users.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        return users;
      });
    } catch (e) {
      debugPrint('Error getting users by branch: $e');
      return Stream.value([]);
    }
  }

  // Get all system admins for a clinic
  Stream<List<UserModel>> getSystemAdmins(String clinicId) {
    if (!_firebaseService.isAvailable) {
      return Stream.value([]);
    }
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .where('clinicId', isEqualTo: clinicId)
          .where('status', isEqualTo: 'Active')
          .snapshots()
          .asyncMap((snapshot) async {
        final users = <UserModel>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['uid'] = doc.id;
          
          // Resolve role reference and filter for SYSTEM_ADMIN
          if (data['role'] is DocumentReference) {
            try {
              final roleRef = data['role'] as DocumentReference;
              final roleDoc = await roleRef.get();
              if (roleDoc.exists) {
                final roleData = roleDoc.data() as Map<String, dynamic>?;
                final roleName = roleData?['roleName'] ?? '';
                if (roleName == 'SYSTEM_ADMIN') {
                  data['role'] = roleName;
                  users.add(UserModel.fromJson(data));
                }
              }
            } catch (e) {
              debugPrint('Error resolving role reference: $e');
            }
          }
        }
        // Sort by createdAt in memory (descending)
        users.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        return users;
      });
    } catch (e) {
      debugPrint('Error getting system admins: $e');
      return Stream.value([]);
    }
  }

  // Get all branch admins for a clinic
  Stream<List<UserModel>> getBranchAdmins(String clinicId) {
    if (!_firebaseService.isAvailable) {
      return Stream.value([]);
    }
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .where('clinicId', isEqualTo: clinicId)
          .where('status', isEqualTo: 'Active')
          .snapshots()
          .asyncMap((snapshot) async {
        final users = <UserModel>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['uid'] = doc.id;
          
          // Resolve role reference and filter for BRANCH_ADMIN
          if (data['role'] is DocumentReference) {
            try {
              final roleRef = data['role'] as DocumentReference;
              final roleDoc = await roleRef.get();
              if (roleDoc.exists) {
                final roleData = roleDoc.data() as Map<String, dynamic>?;
                final roleName = roleData?['roleName'] ?? '';
                if (roleName == 'BRANCH_ADMIN') {
                  data['role'] = roleName;
                  users.add(UserModel.fromJson(data));
                }
              }
            } catch (e) {
              debugPrint('Error resolving role reference: $e');
            }
          }
        }
        // Sort by createdAt in memory (descending)
        users.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        return users;
      });
    } catch (e) {
      debugPrint('Error getting branch admins: $e');
      return Stream.value([]);
    }
  }

  // Get all users for a clinic
  Stream<List<UserModel>> getAllUsers(String clinicId) {
    if (!_firebaseService.isAvailable) {
      return Stream.value([]);
    }
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .where('clinicId', isEqualTo: clinicId)
          .snapshots()
          .asyncMap((snapshot) async {
        final users = <UserModel>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['uid'] = doc.id;
          
          // Resolve role reference
          if (data['role'] is DocumentReference) {
            try {
              final roleRef = data['role'] as DocumentReference;
              final roleDoc = await roleRef.get();
              if (roleDoc.exists) {
                final roleData = roleDoc.data() as Map<String, dynamic>?;
                data['role'] = roleData?['roleName'] ?? 'END_USER';
              }
            } catch (e) {
              debugPrint('Error resolving role reference: $e');
              data['role'] = 'END_USER';
            }
          }
          
          users.add(UserModel.fromJson(data));
        }
        // Sort by createdAt in memory (descending)
        users.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        return users;
      });
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return Stream.value([]);
    }
  }

  // Delete user (soft delete by setting status to Inactive)
  Future<void> deleteUser(String clinicId, String uid) async {
    await updateUser(clinicId, uid, {'status': 'Inactive'});
  }
}
