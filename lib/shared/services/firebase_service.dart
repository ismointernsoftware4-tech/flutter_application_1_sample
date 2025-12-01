import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../firebase_options.dart';
import '../../features/dashboard/models/dashboard_models.dart';

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

  // System-level form path for superadmin forms
  static const String _systemId = 'n2tuBgzuKuNTO1INt8rJ';
  static const String _systemCollection = 'system';

  // Password hashing method using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Public method to hash password
  String hashPassword(String password) {
    return _hashPassword(password);
  }

  // Verify password by comparing hashes
  bool verifyPassword(String plainPassword, String hashedPassword) {
    if (plainPassword.isEmpty || hashedPassword.isEmpty) return false;
    return _hashPassword(plainPassword) == hashedPassword;
  }

  // Create Firebase Auth user and get UID
  Future<String> createAuthUserAndGetUid(String email, String password) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    
    try {
      final fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user?.uid != null) {
        return userCredential.user!.uid;
      } else {
        throw Exception('Failed to create Firebase Auth user - no UID returned');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // User already exists, try to sign in to get UID
        try {
          final auth = fb_auth.FirebaseAuth.instance;
          final userCredential = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return userCredential.user!.uid;
        } catch (_) {
          throw Exception('Email already in use');
        }
      }
      throw Exception('Failed to create user: ${e.message}');
    }
  }

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

  // Save user to Firestore at /Users/{uid}
  // Password will be hashed before storing
  Future<void> saveUserToFirestore({
    required String uid,
    required String name,
    required String email,
    required String password, // Plain password - will be hashed
    required String role,
    required String status,
    List<String>? accessiblePages,
  }) async {
    if (!isAvailable) {
      print('Firebase not available. User not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    
    try {
      // Hash the password before storing
      final hashedPassword = _hashPassword(password);
      
      // Path: /Users/{uid}
      final usersCollection = _firestore!.collection('Users');
      
      // Save user with UID as document ID
      await usersCollection.doc(uid).set({
        'name': name,
        'email': email,
        'password': hashedPassword, // Store hashed password
        'role': role,
        'status': status,
        'accessiblePages': accessiblePages ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('User saved successfully to /Users/$uid');
    } catch (e) {
      print('Error saving user to Firebase: $e');
      throw Exception('Error saving user: $e');
    }
  }

  // Legacy method - kept for backward compatibility
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

  // Get all users from Firebase - path: /Users/{uid}
  Stream<List<User>> getUsers() {
    if (!isAvailable) {
      return Stream.value([]);
    }
    try {
      return _firestore!
          .collection('Users')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return User(
            id: doc.id, // This is the UID
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            role: data['role'] ?? '',
            status: data['status'] ?? '',
            lastLogin: data['lastLogin']?.toString() ?? '',
            password: data['password'] ?? '', // This is hashed
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

  // Get user by UID from /Users/{uid}
  Future<User?> getUserByUid(String uid) async {
    if (!isAvailable || uid.isEmpty) return null;
    try {
      final doc = await _firestore!
          .collection('Users')
          .doc(uid)
          .get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        status: data['status'] ?? '',
        lastLogin: data['lastLogin']?.toString() ?? '',
        password: data['password'] ?? '', // This is hashed
      );
    } catch (e) {
      print('Error getting user by UID: $e');
      return null;
    }
  }

  // Find user by email from /Users/{uid}
  Future<User?> findUserByEmail(String email) async {
    if (!isAvailable || email.isEmpty) return null;
    try {
      final snapshot = await _firestore!
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final doc = snapshot.docs.first;
      final data = doc.data();
      return User(
        id: doc.id, // This is the UID
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        status: data['status'] ?? '',
        lastLogin: data['lastLogin']?.toString() ?? '',
        password: data['password'] ?? '', // This is hashed
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
      // Path: /Users/{uid}
      final userDocRef = _firestore!
          .collection('Users')
          .doc(userId);
      
      final doc = await userDocRef.get();
      if (doc.exists) {
        await userDocRef.set({
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }
      
      // Fallback to old path
      final oldUserDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .doc(userId);
      await oldUserDocRef.set({
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
      // Path: /Users/{uid}
      final userDocRef = _firestore!
          .collection('Users')
          .doc(userId);
      
      final doc = await userDocRef.get();
      if (doc.exists) {
        await userDocRef.delete();
        return;
      }
      
      // Fallback to old path
      final oldUserDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc(_userDocumentId)
          .collection(_usersSubcollection)
          .doc(userId);
      await oldUserDocRef.delete();
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

  // Get accessible pages for a role based on permissions
  Future<List<String>> getAccessiblePagesForRole(String role) async {
    if (!isAvailable || role.isEmpty) {
      return [];
    }
    try {
      final rolePermissions = await getRolePermissions(role);
      final accessiblePages = <String>[];
      
      // Extract pages where permission is true
      rolePermissions.permissions.forEach((pageTitle, hasAccess) {
        if (hasAccess == true) {
          accessiblePages.add(pageTitle);
        }
      });
      
      print('Accessible pages for role $role: $accessiblePages');
      return accessiblePages;
    } catch (e) {
      print('Error getting accessible pages for role $role: $e');
      return [];
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

  // Save item to Firebase: Item Management -> item_Master (document) -> Item_List (subcollection)
  // Path: /Item Management/item_Master/Item_List/{documentId}
  Future<String> saveItem(Map<String, dynamic> itemData) async {
    if (!isAvailable) {
      print('Firebase not available. Item not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Ensure the item_Master document exists (required for subcollections in Firestore)
      final itemMasterDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc('item_Master');
      
      // Create item_Master document if it doesn't exist
      await itemMasterDocRef.set({'type': 'item_master'}, SetOptions(merge: true));
      
      // Add item as a document in Item_List subcollection under item_Master document
      final docRef = await itemMasterDocRef
          .collection('Item_List')
          .add({
        ...itemData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Item saved successfully to Item Management -> item_Master -> Item_List -> ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving item to Firebase: $e');
      throw Exception('Error saving item: $e');
    }
  }

  // Fetch all items from Firebase: Item Management -> item_Master -> Item_List
  // Path: /Item Management/item_Master/Item_List/{documentId}
  Stream<List<Map<String, dynamic>>> getItems() {
    if (!isAvailable) {
      return Stream.value([]);
    }
    try {
      return _firestore!
          .collection(_inventoryManagementCollection)
          .doc('item_Master')
          .collection('Item_List')
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
          .collection(_inventoryManagementCollection)
          .doc('item_Master')
          .collection('Item_List')
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

  // Save vendor to Firebase: Item Management -> VendorMangement (document) -> Felids (subcollection) -> Vendor Name (document)
  // Path: /Item Management/VendorMangement/Felids/{vendorName}
  Future<String> saveVendor(Map<String, dynamic> vendorData) async {
    if (!isAvailable) {
      print('Firebase not available. Vendor not saved to Firebase.');
      throw Exception('Firebase not available');
    }
    try {
      // Get vendor name from data (use vendor_name field or vendorName)
      final vendorName = vendorData['vendor_name'] ?? 
                         vendorData['vendorName'] ?? 
                         vendorData['name'] ?? 
                         'Unknown Vendor';
      
      // Ensure the VendorMangement document exists (required for subcollections in Firestore)
      final vendorManagementDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc('VendorMangement');
      
      // Create VendorMangement document if it doesn't exist
      await vendorManagementDocRef.set({'type': 'vendor_management'}, SetOptions(merge: true));
      
      // Save vendor data as a document in Felids subcollection with vendor name as document ID
      await vendorManagementDocRef
          .collection('Felids')
          .doc(vendorName)
          .set({
        ...vendorData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Vendor saved successfully to Item Management -> VendorMangement -> Felids -> $vendorName');
      return vendorName;
    } catch (e) {
      print('Error saving vendor to Firebase: $e');
      throw Exception('Error saving vendor: $e');
    }
  }

  // Save storage location to Firebase with hierarchical path structure
  // Path: /Item Management/Storage/{type}/{locationName}/{nestedLevels}...
  // Example: /Item Management/Storage/Warehouse/Fridge1/section1/rack1
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
      // Ensure the Storage document exists
      final storageDocRef = _firestore!
          .collection(_inventoryManagementCollection)
          .doc('Storage');
      
      await storageDocRef.set({'type': 'storage'}, SetOptions(merge: true));
      
      DocumentReference locationRef;
      
      // Simple case: save at type level
      // Path: /Item Management/Storage/{type}/{locationName}
      // For nested locations, the parentLocation field stores the hierarchy info
      final typeCollection = storageDocRef.collection(type);
      locationRef = typeCollection.doc(name);
      
      // Save location data
      await locationRef.set({
        'name': name,
        'type': type,
        'parentLocation': parentLocation,
        'capacity': capacity,
        'status': status,
        'manager': manager,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      final path = locationPath != null 
          ? 'Item Management -> Storage -> ${locationPath.join(' -> ')} -> $name'
          : 'Item Management -> Storage -> $type -> $name';
      print('Location saved successfully to $path');
      return name;
    } catch (e) {
      print('Error saving location to Firebase: $e');
      throw Exception('Error saving location: $e');
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

  Future<Map<String, dynamic>?> fetchFormDefinition(
    String formId, {
    String? clinicId,
  }) async {
    if (!isAvailable) return null;
    try {
      // First, try to fetch from system-level (superadmin forms)
      final systemDocRef = _firestore!
          .collection(_systemCollection)
          .doc(_systemId)
          .collection('forms')
          .doc(formId);
      
      final systemDoc = await systemDocRef.get();
      if (systemDoc.exists && systemDoc.data() != null) {
        print('Found system-level form: /system/$_systemId/forms/$formId');
        return systemDoc.data();
      }
      
      // If not found in system, check clinic-level (if clinicId provided)
      if (clinicId != null && clinicId.isNotEmpty) {
        final clinicDoc = _firestore!.collection('clinics').doc(clinicId);
        await clinicDoc.set({'type': 'clinic'}, SetOptions(merge: true));
        final clinicFormDoc = await clinicDoc.collection('forms').doc(formId).get();
        if (clinicFormDoc.exists && clinicFormDoc.data() != null) {
          print('Found clinic-level form: /clinics/$clinicId/forms/$formId');
          return clinicFormDoc.data();
        }
      }
      
      // Fallback to legacy path
      final baseDoc = _firestore!
          .collection(_inventoryManagementCollection)
          .doc('form_definitions');
      await baseDoc.set({'type': 'forms'}, SetOptions(merge: true));
      final legacyDoc = await baseDoc.collection('forms').doc(formId).get();
      if (legacyDoc.exists && legacyDoc.data() != null) {
        print('Found legacy form: /Item Management/form_definitions/forms/$formId');
        return legacyDoc.data();
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
    {String? clinicId}
  ) async {
    if (!isAvailable) {
      print('Firebase not available. Form definition not saved.');
      return;
    }
    try {
      DocumentReference<Map<String, dynamic>> docRef;
      if (clinicId != null && clinicId.isNotEmpty) {
        final clinicDoc = _firestore!.collection('clinics').doc(clinicId);
        await clinicDoc.set({'type': 'clinic'}, SetOptions(merge: true));
        docRef = clinicDoc.collection('forms').doc(formId);
      } else {
      final baseDoc = _firestore!
          .collection(_inventoryManagementCollection)
          .doc('form_definitions');
      await baseDoc.set({'type': 'forms'}, SetOptions(merge: true));
        docRef = baseDoc.collection('forms').doc(formId);
      }
      await docRef.set({
        ...definition,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving form definition: $e');
      throw Exception('Error saving form definition: $e');
    }
  }

  // Generate next clinic code (CLN-0001, CLN-0002, etc.)
  Future<String> _generateNextClinicCode() async {
    if (!isAvailable) {
      throw Exception('Firebase not available');
    }
    try {
      final clinicsCollection = _firestore!.collection('clinics');
      final snapshot = await clinicsCollection.get();
      
      if (snapshot.docs.isEmpty) {
        return 'CLN-0001';
      }
      
      // Extract all existing clinic codes and find the highest number
      int maxNumber = 0;
      for (var doc in snapshot.docs) {
        final docId = doc.id;
        if (docId.startsWith('CLN-')) {
          try {
            final numberStr = docId.substring(4); // Remove "CLN-" prefix
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
      return 'CLN-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      print('Error generating clinic code: $e');
      throw Exception('Error generating clinic code: $e');
    }
  }

  Future<String> saveClinic(Map<String, dynamic> clinicData) async {
    if (!isAvailable) {
      print('Firebase not available. Clinic not saved.');
      throw Exception('Firebase not available');
    }
    try {
      // Generate next clinic code
      final clinicCode = await _generateNextClinicCode();
      
      // Flatten customFields into main document if it exists
      final Map<String, dynamic> flattenedData = {...clinicData};
      if (flattenedData.containsKey('customFields') && 
          flattenedData['customFields'] is Map) {
        final customFields = flattenedData.remove('customFields') as Map<String, dynamic>;
        // Merge customFields into main document
        flattenedData.addAll(customFields);
      }
      
      // Use lowercase 'clinics' collection and clinic code as document ID
      final clinicsCollection = _firestore!.collection('clinics');
      await clinicsCollection.doc(clinicCode).set({
        ...flattenedData,
        'clinicCode': clinicCode, // Ensure clinicCode is set in the data
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Clinic saved successfully at /clinics/$clinicCode/');
      print('Total fields saved: ${flattenedData.length}');
      return clinicCode;
    } catch (e) {
      print('Error saving clinic: $e');
      throw Exception('Error saving clinic: $e');
    }
  }

  // Get all clinic IDs from Firestore
  Future<List<String>> getAllClinicIds() async {
    if (!isAvailable) {
      return [];
    }
    try {
      final snapshot = await _firestore!.collection('clinics').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting clinic IDs: $e');
      return [];
    }
  }


  /// Save form definition to system-level path (superadmin forms)
  /// Path: /system/{systemId}/forms/{formId}
  Future<void> saveSystemFormDefinition(
    String formId,
    Map<String, dynamic> definition,
  ) async {
    if (!isAvailable) {
      print('Firebase not available. Form definition not saved.');
      return;
    }
    try {
      final systemDoc = _firestore!
          .collection(_systemCollection)
          .doc(_systemId);
      
      // Ensure system document exists
      await systemDoc.set({
        'type': 'system',
        'systemId': _systemId,
      }, SetOptions(merge: true));
      
      // Save form definition
      await systemDoc.collection('forms').doc(formId).set({
        ...definition,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('System form saved: /system/$_systemId/forms/$formId');
    } catch (e) {
      print('Error saving system form definition: $e');
      throw Exception('Error saving system form definition: $e');
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

