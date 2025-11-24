import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';
import '../models/dashboard_models.dart';

class FirebaseService {
  FirebaseFirestore? _firestore;
  final String _apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
  
  FirebaseService() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      print('Firebase not initialized: $e');
      _firestore = null;
    }
  }
  
  bool get isAvailable => _firestore != null;

  // Structure: Item Management -> User (document) -> users (subcollection)
  // Roles also live under the same User document: Item Management -> User -> roles
  String get _inventoryManagementCollection => 'Item Management';
  String get _userDocumentId => 'User';
  String get _usersSubcollection => 'users';
  String get _rolesSubcollection => 'roles';
  String get _legacyRolesDocumentId => 'Roles';

  Future<CollectionReference<Map<String, dynamic>>?> _rolesCollection() async {
    if (!isAvailable) return null;
    final docRef = _firestore!
        .collection(_inventoryManagementCollection)
        .doc(_userDocumentId);
    // Ensure base document exists without overriding existing fields
    await docRef.set({'type': 'users'}, SetOptions(merge: true));
    return docRef.collection(_rolesSubcollection);
  }

  CollectionReference<Map<String, dynamic>>? _legacyRolesCollection() {
    if (!isAvailable) return null;
    return _firestore!
        .collection(_inventoryManagementCollection)
        .doc(_legacyRolesDocumentId)
        .collection(_rolesSubcollection);
  }

  Future<void> _migrateLegacyRolesIfNeeded(
    CollectionReference<Map<String, dynamic>> rolesCollection,
  ) async {
    final legacyCollection = _legacyRolesCollection();
    if (legacyCollection == null) return;
    final legacySnapshot = await legacyCollection.get();
    if (legacySnapshot.docs.isEmpty) return;

    final batch = _firestore!.batch();
    for (final doc in legacySnapshot.docs) {
      batch.set(rolesCollection.doc(doc.id), doc.data());
    }
    await batch.commit();
  }

  // Save user to Firebase: Item Management -> User (document) -> users (subcollection)
  // Each user is saved as a separate document in the users subcollection
  Future<void> saveUser(User user) async {
    if (!isAvailable) {
      print('Firebase not available. User not saved to Firebase.');
      return;
    }
    try {
      // Ensure the User document exists (required for subcollections in Firestore)
      final userDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId);
      
      // Create User document if it doesn't exist (with minimal data)
      await userDocRef.set({'type': 'users'}, SetOptions(merge: true));
      
      // Add user as a document in users subcollection under User document
      // Each user will be a separate document that you can click to view
      await userDocRef
          .collection(_usersSubcollection)
          .add({
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'status': user.status,
        'lastLogin': user.lastLogin,
        'password': user.password,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('User saved successfully: ${user.name} to Item Management -> User -> users');
    } catch (e) {
      print('Error saving user to Firebase: $e');
      throw Exception('Error saving user: $e');
    }
  }

  // Get all users from Firebase
  Stream<List<User>> getUsers() {
    if (!isAvailable) {
      return Stream.value([]);
    }
    try {
      return _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return User(
            id: doc.id,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            role: data['role'] ?? '',
            status: data['status'] ?? '',
            lastLogin: data['lastLogin'] ?? '',
            password: data['password'] ?? '',
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting users from Firebase: $e');
      return Stream.value([]);
    }
  }

  Future<void> createAuthUser(String email, String password) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    if (_apiKey.isEmpty) {
      throw Exception('Firebase API key missing. Configure firebase_options.dart.');
    }

    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': false,
      }),
    );

    if (response.statusCode >= 400) {
      print('Auth signup failed: ${response.statusCode} ${response.body}');
      try {
        final data = jsonDecode(response.body);
        final message = data['error']?['message'] as String?;
        if (message == 'EMAIL_EXISTS') {
          return;
        }
        throw Exception(message ?? 'Failed to create Firebase Auth user.');
      } catch (_) {
        throw Exception('Failed to create Firebase Auth user.');
      }
    }
    print('Auth signup success for $email');
  }

  Future<User?> findUserByEmail(String email) async {
    if (!isAvailable || email.isEmpty) return null;
    try {
      final snapshot = await _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        status: data['status'] ?? '',
        lastLogin: data['lastLogin'] ?? '',
        password: data['password'] ?? '',
      );
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    if (!isAvailable || userId.isEmpty) {
      return;
    }
    try {
      final userDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .doc(userId);
      await userDocRef.set({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Error updating user role: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    if (!isAvailable || userId.isEmpty) {
      return;
    }
    try {
      final userDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .doc(userId);
      await userDocRef.delete();
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Error deleting user: $e');
    }
  }

  // Get all unique roles from Firebase
  Future<List<String>> getRoles() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .get();

      final roles = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String?;
        if (role != null && role.isNotEmpty) {
          roles.add(role);
        }
      }
      return roles.toList()..sort();
    } catch (e) {
      print('Error getting roles from Firebase: $e');
      return [];
    }
  }

  // Stream roles from Firebase
  Stream<List<String>> getRolesStream() {
    if (!isAvailable) {
      return Stream.value([]);
    }
    try {
      return _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .snapshots()
          .map((snapshot) {
        final roles = <String>{};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final role = data['role'] as String?;
          if (role != null && role.isNotEmpty) {
            roles.add(role);
          }
        }
        return roles.toList()..sort();
      });
    } catch (e) {
      print('Error streaming roles from Firebase: $e');
      return Stream.value([]);
    }
  }

  // Fetch all roles (each role is a document under Item Management -> Roles -> roles)
  Future<List<String>> fetchRoles() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final rolesCollection = await _rolesCollection();
      if (rolesCollection == null) return [];
      var snapshot = await rolesCollection.get();
      if (snapshot.docs.isEmpty) {
        await _migrateLegacyRolesIfNeeded(rolesCollection);
        snapshot = await rolesCollection.get();
      }
      return snapshot.docs.map((doc) => doc.id).toList()..sort();
    } catch (e) {
      print('Error fetching roles: $e');
      return [];
    }
  }

  // Create a new role document with default permissions and labels
  Future<void> createRole(
    String roleName,
    Map<String, bool> defaultPermissions,
    Map<String, String> defaultLabels,
  ) async {
    if (!isAvailable) {
      print('Firebase not available. Role not created.');
      return;
    }
    try {
      final rolesCollection = await _rolesCollection();
      if (rolesCollection == null) return;
      await rolesCollection.doc(roleName).set({
        'permissions': defaultPermissions,
        'labels': defaultLabels,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating role: $e');
      throw Exception('Error creating role: $e');
    }
  }

  // Rename a role by copying data to a new document
  Future<void> renameRole(String oldName, String newName) async {
    if (!isAvailable) {
      print('Firebase not available. Role not renamed.');
      return;
    }
    try {
      final rolesCollection = await _rolesCollection();
      if (rolesCollection == null) return;
      final oldDoc = await rolesCollection.doc(oldName).get();
      if (!oldDoc.exists) {
        throw Exception('Role $oldName does not exist');
      }
      final data = oldDoc.data() ?? {};
      await rolesCollection.doc(newName).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await rolesCollection.doc(oldName).delete();
    } catch (e) {
      print('Error renaming role: $e');
      throw Exception('Error renaming role: $e');
    }
  }

  // Delete a role document
  Future<void> deleteRole(String roleName) async {
    if (!isAvailable) {
      print('Firebase not available. Role not deleted.');
      return;
    }
    try {
      final rolesCollection = await _rolesCollection();
      if (rolesCollection == null) return;
      await rolesCollection.doc(roleName).delete();
    } catch (e) {
      print('Error deleting role: $e');
      throw Exception('Error deleting role: $e');
    }
  }

  // Save role permissions to Firebase: Item Management -> Roles -> roles -> [roleName]
  Future<void> saveRolePermissions(
    String roleName,
    Map<String, bool> permissions,
    Map<String, String> labels,
  ) async {
    if (!isAvailable) {
      print('Firebase not available. Permissions not saved to Firebase.');
      return;
    }
    try {
      final rolesCollection = await _rolesCollection();
      if (rolesCollection == null) return;
      await rolesCollection.doc(roleName).set({
        'permissions': permissions,
        'labels': labels,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving permissions to Firebase: $e');
      throw Exception('Error saving permissions: $e');
    }
  }

  // Get role permissions from Firebase
  Future<RolePermissionsData> getRolePermissions(String roleName) async {
    if (!isAvailable) {
      return RolePermissionsData.empty();
    }
    try {
      final rolesCollection = await _rolesCollection();
      if (rolesCollection == null) return RolePermissionsData.empty();
      var doc = await rolesCollection.doc(roleName).get();

      if (!doc.exists) {
        final legacyCollection = _legacyRolesCollection();
        final legacyDoc = await legacyCollection?.doc(roleName).get();
        if (legacyDoc != null && legacyDoc.exists) {
          final legacyData = legacyDoc.data();
          if (legacyData != null) {
            await rolesCollection.doc(roleName).set(legacyData);
            doc = await rolesCollection.doc(roleName).get();
          }
        }
      }

      if (doc.exists) {
        final data = doc.data();
        final permissionsMap =
            data?['permissions'] as Map<String, dynamic>? ?? {};
        final labelsMap = data?['labels'] as Map<String, dynamic>? ?? {};
        return RolePermissionsData(
          permissions: permissionsMap.map(
            (key, value) => MapEntry(key, value == true),
          ),
          labels: labelsMap.map(
            (key, value) => MapEntry(key, value?.toString() ?? key),
          ),
        );
      }
      return RolePermissionsData.empty();
    } catch (e) {
      print('Error getting permissions from Firebase: $e');
      return RolePermissionsData.empty();
    }
  }

  // Delete the old 'Inventory Management' collection/document if it exists
  Future<void> deleteInventoryManagement() async {
    if (!isAvailable) {
      print('Firebase not available. Cannot delete Inventory Management.');
      return;
    }
    try {
      const oldCollection = 'Inventory Management';
      
      // Get all documents in the old collection
      final snapshot = await _firestore!
          .collection(oldCollection)
          .get();
      
      // Delete all documents (this will also delete their subcollections in Firestore)
      final batch = _firestore!.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      print('Inventory Management collection deleted successfully');
    } catch (e) {
      print('Error deleting Inventory Management: $e');
      // Don't throw - this is a cleanup operation
    }
  }
}

class RolePermissionsData {
  final Map<String, bool> permissions;
  final Map<String, String> labels;

  RolePermissionsData({
    required this.permissions,
    required this.labels,
  });

  factory RolePermissionsData.empty() =>
      RolePermissionsData(permissions: {}, labels: {});
}

