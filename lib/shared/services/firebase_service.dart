import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../core/firebase_options.dart';
import '../../features/settings/models/settings_models.dart';
import '../../features/approvals/models/approvals_models.dart';

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

  // Save item to Firebase: /clinics/CLN-0004/branch/BRN-001/items/{documentId}
  // Path: /clinics/CLN-0004/branch/BRN-001/items/{auto-generated-documentId}
  Future<String> saveItem(Map<String, dynamic> itemData) async {
    if (!isAvailable) {
      print('Firebase not available. Item not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Ensure the clinic, branch, and items collection exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');
      
      // Create clinic document if it doesn't exist
      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));
      
      // Ensure branch document exists
      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');
      
      // Create branch document if it doesn't exist
      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));
      
      // Add item as a document in items subcollection under branch document
      // Firestore will auto-generate the document ID (e.g., Q0D5Ib08DkoH68LKi8Q9)
      final docRef = await branchDocRef
          .collection('items')
          .add({
        ...itemData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Item saved successfully to /clinics/CLN-0004/branch/BRN-001/items/${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving item to Firebase: $e');
      throw Exception('Error saving item: $e');
    }
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> itemData) async {
    if (!isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      // Update item in the new path: /clinics/CLN-0004/branch/BRN-001/items/{documentId}
      await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('items')
          .doc(documentId)
          .set({
        ...itemData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Item updated successfully: $documentId');
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String documentId) async {
    if (!isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      // Delete item from the new path: /clinics/CLN-0004/branch/BRN-001/items/{documentId}
      await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('items')
          .doc(documentId)
          .delete();
      
      print('Item deleted successfully: $documentId');
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Error deleting item: $e');
    }
  }

  // Save Purchase Requisition to a fixed path:
  // /clinics/CLN-0004/branch/BRN-001/Procurements/e7JdRHE9irT96y6GzhCW
  Future<String> savePR(Map<String, dynamic> prData) async {
    if (!isAvailable) {
      print('Firebase not available. PR not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');
      
      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));
      
      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');
      
      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the Procurements collection
      final procurementCollection = branchDocRef.collection('Procurements');
      final docRef = await procurementCollection.add({
        ...prData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('PR saved successfully to /clinics/CLN-0004/branch/BRN-001/Procurements/${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving PR to Firebase: $e');
      throw Exception('Error saving PR: $e');
    }
  }

  // Fetch all Purchase Requisitions from Firebase
  Future<List<Map<String, dynamic>>> fetchPRs() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('Procurements')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'documentId': doc.id, // Store Firebase document ID separately (won't be overwritten)
          'id': doc.id, // Override 'id' with Firebase document ID for updates
        };
      }).toList();
    } catch (e) {
      print('Error fetching PRs from Firebase: $e');
      return [];
    }
  }

  // Update PR status in Firebase
  Future<void> updatePRStatus(String documentId, String newStatus) async {
    if (!isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('Procurements')
          .doc(documentId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('PR status updated successfully: $documentId -> $newStatus');
    } catch (e) {
      print('Error updating PR status: $e');
      throw Exception('Error updating PR status: $e');
    }
  }

  // Stream all Purchase Requisitions from Firebase
  Stream<List<Map<String, dynamic>>> getPRsStream() {
    if (!isAvailable) {
      print('Firebase not available for PRs stream');
      return Stream.value([]);
    }
    try {
      final stream = _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('Procurements')
          .orderBy('createdAt', descending: true)
          .snapshots();
      
      return stream.map((snapshot) {
        print('PRs stream update: ${snapshot.docs.length} documents');
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          print('PR doc ${doc.id}: status = ${data['status']}');
          return {
            ...data,
            'documentId': doc.id, // Store Firebase document ID separately (won't be overwritten)
            'id': doc.id, // Override 'id' with Firebase document ID for updates
          };
        }).toList();
        return docs;
      }).handleError((error) {
        print('ERROR in PRs stream: $error');
        // If orderBy fails, try without it
        if (error.toString().contains('index') || 
            error.toString().contains('orderBy') ||
            error.toString().contains('requires an index')) {
          print('Retrying PRs stream without orderBy due to index error');
          return _firestore!
              .collection('clinics')
              .doc('CLN-0004')
              .collection('branch')
              .doc('BRN-001')
              .collection('Procurements')
              .snapshots()
              .map((snapshot) {
            print('PRs stream (no orderBy): ${snapshot.docs.length} documents');
            final docs = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            }).toList();
            // Sort in memory by createdAt if available
            docs.sort((a, b) {
              final aTime = a['createdAt'];
              final bTime = b['createdAt'];
              if (aTime == null || bTime == null) return 0;
              if (aTime is Timestamp && bTime is Timestamp) {
                return bTime.compareTo(aTime); // descending
              }
              return 0;
            });
            return docs;
          });
        }
        return Stream.value(<Map<String, dynamic>>[]);
      });
    } catch (e) {
      print('Error setting up PRs stream: $e');
      return Stream.value([]);
    }
  }

  /// Fetch the Purchase Requisition used for approvals:
  /// /clinics/CLN-0004/branch/BRN-001/Procurements/e7JdRHE9irT96y6GzhCW
  Future<Map<String, dynamic>?> fetchApprovalPR() async {
    if (!isAvailable) {
      print('Firebase not available. Cannot fetch approval PR.');
      return null;
    }

    try {
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      const String procurementId = 'e7JdRHE9irT96y6GzhCW';

      final snapshot = await branchDocRef
          .collection('Procurements')
          .doc(procurementId)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        print('Approval PR not found at /clinics/CLN-0004/branch/BRN-001/Procurements/$procurementId');
        return null;
      }

      final data = snapshot.data()!;
      return {
        'id': snapshot.id,
        ...data,
      };
    } catch (e) {
      print('Error fetching approval PR: $e');
      return null;
    }
  }

  /// Stream the Purchase Requisition used for approvals as an ApprovalWorkflowItem.
  Stream<ApprovalWorkflowItem?> approvalPRStream() {
    if (!isAvailable) {
      print('Firebase not available. Using empty approvals stream.');
      return Stream.value(null);
    }

    final clinicDocRef = _firestore!
        .collection('clinics')
        .doc('CLN-0004');

    final branchDocRef = clinicDocRef
        .collection('branch')
        .doc('BRN-001');

    const String procurementId = 'e7JdRHE9irT96y6GzhCW';

    return branchDocRef
        .collection('Procurements')
        .doc(procurementId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;
          final data = snapshot.data()!;
          final now = DateTime.now();
          final dateString = (data['date'] as String?) ??
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

          return ApprovalWorkflowItem(
            priority: (data['priority'] as String?) ?? 'Routine',
            id: (data['id'] as String?) ??
                (data['prNumber'] as String?) ??
                'PR',
            date: dateString,
            title: (data['title'] as String?) ??
                (data['name'] as String?) ??
                'Purchase Requisition',
            description: (data['description'] as String?) ??
                (data['purpose'] as String?) ??
                '',
            requestedBy: (data['requestedBy'] as String?) ??
                (data['createdBy'] as String?) ??
                '',
            status: (data['status'] as String?) ?? 'Pending',
            prDocumentId: snapshot.id, // Store original Firebase document ID
          );
        });
  }

  // Save Goods Receipt Note to a fixed path:
  // /clinics/CLN-0004/branch/BRN-001/GoodsReciveNotes/H5VaxHSS53SDQfEp6jCa
  Future<String> saveGRN(Map<String, dynamic> grnData) async {
    if (!isAvailable) {
      print('Firebase not available. GRN not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the GoodsReciveNotes collection
      final grnCollection = branchDocRef.collection('GoodsReciveNotes');
      final docRef = await grnCollection.add({
        ...grnData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'GRN saved successfully to /clinics/CLN-0004/branch/BRN-001/GoodsReciveNotes/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving GRN to Firebase: $e');
      throw Exception('Error saving GRN: $e');
    }
  }

  // Fetch all Goods Receipt Notes from Firebase
  Future<List<Map<String, dynamic>>> fetchGRNs() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('GoodsReciveNotes')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching GRNs from Firebase: $e');
      return [];
    }
  }

  /// Attach PO fields directly to an existing PR document under:
  /// /clinics/CLN-0004/branch/BRN-001/Procurements/{prDocumentId}
  /// This is used when a PR is approved and we want to keep PR + PO
  /// data in the same document.
  Future<void> attachPOToPR(
    String prDocumentId,
    Map<String, dynamic> poFields,
  ) async {
    if (!isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('Procurements')
          .doc(prDocumentId)
          .set(
        {
          ...poFields,
          'poUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      print(
        'PO fields attached to PR /clinics/CLN-0004/branch/BRN-001/Procurements/$prDocumentId',
      );
    } catch (e) {
      print('Error attaching PO fields to PR: $e');
      throw Exception('Error attaching PO fields to PR: $e');
    }
  }

  /// Update PO status fields that are attached to a PR document in the
  /// Procurements collection (used by PO approval in the Approvals UI).
  Future<void> updatePOStatusOnPR(
    String prDocumentId,
    String newStatus,
  ) async {
    if (!isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('Procurements')
          .doc(prDocumentId)
          .update({
        'poStatus': newStatus,
        'poUpdatedAt': FieldValue.serverTimestamp(),
      });
      print(
        'PO status on PR updated successfully: $prDocumentId -> $newStatus',
      );
    } catch (e) {
      print('Error updating PO status on PR: $e');
      throw Exception('Error updating PO status on PR: $e');
    }
  }

  // Fetch all items from Firebase: /clinics/CLN-0004/branch/BRN-001/items
  // Path: /clinics/CLN-0004/branch/BRN-001/items/{documentId}
  Stream<List<Map<String, dynamic>>> getItems() {
    if (!isAvailable) {
      return Stream.value([]);
    }
    try {
      return _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching items from Firebase: $e');
      return Stream.value([]);
    }
  }

  // Fetch all items once (non-streaming)
  Future<List<Map<String, dynamic>>> fetchItems() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching items from Firebase: $e');
      return [];
    }
  }

  // Stream items from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> getItemsStream() {
    if (!isAvailable) {
      return Stream.value([]);
    }
    try {
      return _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching items from Firebase: $e');
      return Stream.value([]);
    }
  }

  // Save vendor to Firebase: /clinics/CLN-0004/vendor/o8fuXAcbHshmrkQHHFKq
  // Path: /clinics/CLN-0004/vendor/o8fuXAcbHshmrkQHHFKq
  /// Save vendor directly under /clinics/CLN-0004/vendor/{vendorId}
  Future<String> saveVendor(Map<String, dynamic> vendorData) async {
    if (!isAvailable) {
      print('Firebase not available. Vendor not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Ensure clinic exists
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');
      
      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));
      
      // Collection: /clinics/CLN-0004/vendor
      final vendorCollectionRef = clinicDocRef.collection('vendor');
      
      // Get vendor ID from data or generate new one
      final vendorId = vendorData['id'] as String? ??
          'VND-${DateTime.now().millisecondsSinceEpoch}';
      
      // Each vendor is a document directly in the vendor collection
      final vendorDocRef = vendorCollectionRef.doc(vendorId);
      
      await vendorDocRef.set({
        ...vendorData,
        'id': vendorId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Vendor saved successfully to /clinics/CLN-0004/vendor/$vendorId');
      return vendorId;
    } catch (e) {
      print('Error saving vendor to Firebase: $e');
      throw Exception('Error saving vendor: $e');
    }
  }

  /// Fetch all vendors from Firebase
  /// Path: /clinics/CLN-0004/vendor/{vendorId}
  Future<List<Map<String, dynamic>>> fetchVendors() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('vendor')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching vendors from Firebase: $e');
      return [];
    }
  }

  /// Fetch the single vendor document stored at:
  /// /clinics/CLN-0004/vendor/o8fuXAcbHshmrkQHHFKq
  Future<Map<String, dynamic>?> fetchVendor() async {
    if (!isAvailable) {
      print('Firebase not available. Cannot fetch vendor.');
      return null;
    }

    try {
      final clinicDocRef =
          _firestore!.collection('clinics').doc('CLN-0004');

      final vendorDocRef =
          clinicDocRef.collection('vendor').doc('o8fuXAcbHshmrkQHHFKq');

      final snapshot = await vendorDocRef.get();
      if (!snapshot.exists) {
        print('Vendor document does not exist at /clinics/CLN-0004/vendor/o8fuXAcbHshmrkQHHFKq');
        return null;
      }

      final data = snapshot.data();
      if (data == null) return null;

      return {
        'id': snapshot.id,
        ...data,
      };
    } catch (e) {
      print('Error fetching vendor from Firebase: $e');
      return null;
    }
  }

  // Save Stock Audit to: /clinics/CLN-0004/branch/BRN-001/audit
  Future<String> saveStockAudit(Map<String, dynamic> auditData) async {
    if (!isAvailable) {
      print('Firebase not available. Stock audit not saved to Firebase.');
      throw Exception('Firebase not available');
    }

    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the audit collection
      final auditCollection = branchDocRef.collection('audit');
      final docRef = await auditCollection.add({
        ...auditData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Stock audit saved successfully to '
        '/clinics/CLN-0004/branch/BRN-001/audit/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving stock audit to Firebase: $e');
      throw Exception('Error saving stock audit: $e');
    }
  }

  // Fetch all Stock Audits from Firebase
  Future<List<Map<String, dynamic>>> fetchStockAudits() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('audit')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching stock audits from Firebase: $e');
      return [];
    }
  }

  // Stream all Stock Audits from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> getStockAuditsStream() {
    if (!isAvailable) {
      print('Firebase not available for stock audits stream');
      return Stream.value(<Map<String, dynamic>>[]);
    }
    try {
      final stream = _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('audit')
          .orderBy('createdAt', descending: true)
          .snapshots();

      return stream.map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      print('Error setting up stock audits stream: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  // Save Stock Adjustment to: /clinics/CLN-0004/branch/BRN-001/adjustment
  Future<String> saveStockAdjustment(Map<String, dynamic> adjustmentData) async {
    if (!isAvailable) {
      print('Firebase not available. Stock adjustment not saved to Firebase.');
      throw Exception('Firebase not available');
    }

    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the adjustment collection
      final adjustmentCollection = branchDocRef.collection('adjustment');
      final docRef = await adjustmentCollection.add({
        ...adjustmentData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Stock adjustment saved successfully to '
        '/clinics/CLN-0004/branch/BRN-001/adjustment/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving stock adjustment to Firebase: $e');
      throw Exception('Error saving stock adjustment: $e');
    }
  }

  // Fetch all Stock Adjustments from Firebase
  Future<List<Map<String, dynamic>>> fetchStockAdjustments() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('adjustment')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching stock adjustments from Firebase: $e');
      return [];
    }
  }

  // Save Internal Transfer to: /clinics/CLN-0004/branch/BRN-001/internal_transfer
  Future<String> saveInternalTransfer(Map<String, dynamic> transferData) async {
    if (!isAvailable) {
      print('Firebase not available. Internal transfer not saved to Firebase.');
      throw Exception('Firebase not available');
    }

    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the internal_transfer collection
      final transferCollection = branchDocRef.collection('internal_transfer');
      final docRef = await transferCollection.add({
        ...transferData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Internal transfer saved successfully to '
        '/clinics/CLN-0004/branch/BRN-001/internal_transfer/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving internal transfer to Firebase: $e');
      throw Exception('Error saving internal transfer: $e');
    }
  }

  // Fetch all Internal Transfers from Firebase
  Future<List<Map<String, dynamic>>> fetchInternalTransfers() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('internal_transfer')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching internal transfers from Firebase: $e');
      return [];
    }
  }

  // Save Branch Transfer to: /clinics/CLN-0004/branch/BRN-001/branch_transfer
  Future<String> saveBranchTransfer(Map<String, dynamic> transferData) async {
    if (!isAvailable) {
      print('Firebase not available. Branch transfer not saved to Firebase.');
      throw Exception('Firebase not available');
    }

    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the branch_transfer collection
      final transferCollection = branchDocRef.collection('branch_transfer');
      final docRef = await transferCollection.add({
        ...transferData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Branch transfer saved successfully to '
        '/clinics/CLN-0004/branch/BRN-001/branch_transfer/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving branch transfer to Firebase: $e');
      throw Exception('Error saving branch transfer: $e');
    }
  }

  // Fetch all Branch Transfers from Firebase
  Future<List<Map<String, dynamic>>> fetchBranchTransfers() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('branch_transfer')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching branch transfers from Firebase: $e');
      return [];
    }
  }

  // Save Stock Return to Vendor to: /clinics/CLN-0004/branch/BRN-001/return_vendor
  Future<String> saveStockReturnToVendor(Map<String, dynamic> returnData) async {
    if (!isAvailable) {
      print('Firebase not available. Stock return not saved to Firebase.');
      throw Exception('Firebase not available');
    }

    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the return_vendor collection
      final returnCollection = branchDocRef.collection('return_vendor');
      final docRef = await returnCollection.add({
        ...returnData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Stock return saved successfully to '
        '/clinics/CLN-0004/branch/BRN-001/return_vendor/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving stock return to Firebase: $e');
      throw Exception('Error saving stock return: $e');
    }
  }

  // Fetch all Stock Returns to Vendor from Firebase
  Future<List<Map<String, dynamic>>> fetchStockReturns() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('return_vendor')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching stock returns from Firebase: $e');
      return [];
    }
  }

  // Save Internal Consumption to: /clinics/CLN-0004/branch/BRN-001/consumption
  Future<String> saveInternalConsumption(
      Map<String, dynamic> consumptionData) async {
    if (!isAvailable) {
      print('Firebase not available. Internal consumption not saved to Firebase.');
      throw Exception('Firebase not available');
    }

    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the consumption collection
      final consumptionCollection = branchDocRef.collection('consumption');
      final docRef = await consumptionCollection.add({
        ...consumptionData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Internal consumption saved successfully to '
        '/clinics/CLN-0004/branch/BRN-001/consumption/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving internal consumption to Firebase: $e');
      throw Exception('Error saving internal consumption: $e');
    }
  }

  // Fetch all Internal Consumptions from Firebase
  Future<List<Map<String, dynamic>>> fetchInternalConsumptions() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('consumption')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching internal consumptions from Firebase: $e');
      return [];
    }
  }

  // Save storage location to: /clinics/CLN-0004/branch/BRN-001/storageLocations
  Future<String> saveStorageLocation({
    required String name,
    required String type,
    required String parentLocation,
    required int capacity,
    required String status,
    String manager = '',
    String description = '',
    List<String>? locationPath, // Optional: full path for nested locations
  }) async {
    if (!isAvailable) {
      print('Firebase not available. Location not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Ensure clinic and branch exist
      final clinicDocRef = _firestore!
          .collection('clinics')
          .doc('CLN-0004');

      await clinicDocRef.set({'type': 'clinic'}, SetOptions(merge: true));

      final branchDocRef = clinicDocRef
          .collection('branch')
          .doc('BRN-001');

      await branchDocRef.set({'type': 'branch'}, SetOptions(merge: true));

      // Create a new document in the storageLocations collection
      final locationCollection = branchDocRef.collection('storageLocations');
      final docRef = await locationCollection.add({
        'name': name,
        'type': type,
        'parentLocation': parentLocation,
        'capacity': capacity,
        'status': status,
        'manager': manager,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'Storage location saved successfully to /clinics/CLN-0004/branch/BRN-001/storageLocations/${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      print('Error saving storage location to Firebase: $e');
      throw Exception('Error saving storage location: $e');
    }
  }

  // Fetch all Storage Locations from Firebase
  Future<List<Map<String, dynamic>>> fetchStorageLocations() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('branch')
          .doc('BRN-001')
          .collection('storageLocations')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching storage locations from Firebase: $e');
      return [];
    }
  }

  // Save item at a specific location with full hierarchical path
  // Path: /Item Management/Storage/{type}/{locationName}/{nestedLevels}/{itemCode}/{itemName}
  // Example: /Item Management/Storage/Warehouse/Fridge1/section1/rack1/item001/Paracetamol 500mg
  Future<void> saveItemAtLocation({
    required String itemCode,
    required String itemName,
    required List<String> locationPath, // e.g., ['Warehouse', 'Fridge1', 'section1', 'rack1']
  }) async {
    if (!isAvailable) {
      print('Firebase not available. Item location not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      if (locationPath.isEmpty) {
        throw Exception('Location path cannot be empty');
      }
      
      // Ensure the Storage document exists
      final storageDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc('Storage');
      
      await storageDocRef.set({'type': 'storage'}, SetOptions(merge: true));
      
      // Navigate through the hierarchical path
      DocumentReference currentRef = storageDocRef;
      
      // Navigate through location hierarchy
      for (int i = 0; i < locationPath.length; i++) {
        final levelName = locationPath[i];
        if (i == 0) {
          // First level is the type (subcollection)
          currentRef = currentRef.collection(levelName).doc(locationPath.length > 1 ? locationPath[1] : levelName);
        } else if (i < locationPath.length - 1) {
          // Intermediate levels are subcollections
          currentRef = currentRef.collection(levelName).doc(locationPath[i + 1]);
        } else {
          // Last location level
          currentRef = currentRef.collection(levelName).doc(itemCode);
        }
      }
      
      // Create itemCode subcollection and save item
      await currentRef
          .collection(itemCode)
          .doc(itemName)
          .set({
        'itemCode': itemCode,
        'itemName': itemName,
        'locationPath': locationPath,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Item saved at location: Item Management -> Storage -> ${locationPath.join(' -> ')} -> $itemCode -> $itemName');
    } catch (e) {
      print('Error saving item at location to Firebase: $e');
      throw Exception('Error saving item at location: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchFormDefinition(String formId) async {
    if (!isAvailable) return null;
    try {
      // Map formId to Firebase document ID if needed
      // Firebase uses 'inter_branch_transfers' but code uses 'branch_transfer_form'
      // Firebase uses 'internal_consumption' but code uses 'internal_consumption_form'
      // Firebase uses 'storage_location' but code uses 'storage_location_form'
      // Firebase uses 'vendor' but code uses 'vendor_form'
      // Firebase uses 'stock_returns_to_vendors' but code uses 'stock_return_form'
      // Firebase uses 'stock_adjustment' but code uses 'stock_adjustment_form'
      // Firebase uses 'form_add_item' but code uses 'item_master'
      String firebaseFormId = formId;
      if (formId == 'branch_transfer_form') {
        firebaseFormId = 'inter_branch_transfers';
      } else if (formId == 'internal_consumption_form') {
        firebaseFormId = 'internal_consumption';
      } else if (formId == 'storage_location_form') {
        firebaseFormId = 'storage_location';
      } else if (formId == 'vendor_form') {
        firebaseFormId = 'vendor';
      } else if (formId == 'stock_return_form') {
        firebaseFormId = 'stock_returns_to_vendors';
      } else if (formId == 'stock_adjustment_form') {
        firebaseFormId = 'stock_adjustment';
      } else if (formId == 'item_master') {
        firebaseFormId = 'form_add_item';
      }
      
      // Use Firebase path: /clinics/CLN-0004/forms/{firebaseFormId} for all forms
      final doc = await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('forms')
          .doc(firebaseFormId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        // Map 'description' to 'title' for each section if needed
        if (data != null && data['sections'] != null) {
          final sections = List<Map<String, dynamic>>.from(data['sections']);
          for (var section in sections) {
            // If section has 'description' but no 'title', map it
            if (section.containsKey('description') && !section.containsKey('title')) {
              section['title'] = section['description'];
            }
          }
          data['sections'] = sections;
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching form definition: $e');
      return null;
    }
  }

  Future<void> saveFormDefinition(
    String formId,
    Map<String, dynamic> definition,
  ) async {
    if (!isAvailable) {
      print('Firebase not available. Form definition not saved.');
      return;
    }
    try {
      // Map formId to Firebase document ID if needed
      // Firebase uses 'inter_branch_transfers' but code uses 'branch_transfer_form'
      // Firebase uses 'internal_consumption' but code uses 'internal_consumption_form'
      // Firebase uses 'storage_location' but code uses 'storage_location_form'
      // Firebase uses 'vendor' but code uses 'vendor_form'
      // Firebase uses 'stock_returns_to_vendors' but code uses 'stock_return_form'
      // Firebase uses 'stock_adjustment' but code uses 'stock_adjustment_form'
      // Firebase uses 'form_add_item' but code uses 'item_master'
      String firebaseFormId = formId;
      if (formId == 'branch_transfer_form') {
        firebaseFormId = 'inter_branch_transfers';
      } else if (formId == 'internal_consumption_form') {
        firebaseFormId = 'internal_consumption';
      } else if (formId == 'storage_location_form') {
        firebaseFormId = 'storage_location';
      } else if (formId == 'vendor_form') {
        firebaseFormId = 'vendor';
      } else if (formId == 'stock_return_form') {
        firebaseFormId = 'stock_returns_to_vendors';
      } else if (formId == 'stock_adjustment_form') {
        firebaseFormId = 'stock_adjustment';
      } else if (formId == 'item_master') {
        firebaseFormId = 'form_add_item';
      }
      
      // Save to Firebase path: /clinics/CLN-0004/forms/{firebaseFormId}
      await _firestore!
          .collection('clinics')
          .doc('CLN-0004')
          .collection('forms')
          .doc(firebaseFormId)
          .set({
        ...definition,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Form definition saved successfully to /clinics/CLN-0004/forms/$firebaseFormId');
    } catch (e) {
      print('Error saving form definition: $e');
      throw Exception('Error saving form definition: $e');
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

