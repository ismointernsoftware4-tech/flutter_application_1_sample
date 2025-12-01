# Forward and Backward Compatibility Guide

This document explains how the codebase handles forward and backward compatibility to ensure smooth transitions during schema changes, API updates, and data migrations.

## Table of Contents
1. [Backward Compatibility](#backward-compatibility)
2. [Forward Compatibility](#forward-compatibility)
3. [Data Model Compatibility](#data-model-compatibility)
4. [Firebase Path Migration](#firebase-path-migration)
5. [Best Practices](#best-practices)

---

## Backward Compatibility

Backward compatibility ensures that the current code can work with data created by older versions of the application.

### 1. Legacy Path Fallbacks

The codebase maintains support for old Firebase collection paths while migrating to new structures:

#### Example: Role Management (`firebase_service.dart`)

```dart
// New path: /Item Management/User/roles/{roleName}
// Legacy path: /Item Management/Roles/roles/{roleName}

Future<CollectionReference<Map<String, dynamic>>?> _rolesCollection() async {
  // Returns new collection path
}

CollectionReference<Map<String, dynamic>>? _legacyRolesCollection() {
  // Returns legacy collection path
}

Future<void> _migrateLegacyRolesIfNeeded(...) async {
  // Automatically migrates data from legacy to new path
}
```

**Key Methods:**
- `_legacyRolesCollection()` - Access to old role collection
- `_migrateLegacyRolesIfNeeded()` - Automatic migration on first access
- `getRolePermissions()` - Checks legacy path if new path doesn't exist

#### Example: User Management (`firebase_service.dart`)

```dart
Future<void> updateUserRole(String userId, String newRole) async {
  // Try new path first: /Users/{uid}
  final userDocRef = _firestore!.collection('Users').doc(userId);
  final doc = await userDocRef.get();
  
  if (doc.exists) {
    await userDocRef.set({'role': newRole}, SetOptions(merge: true));
    return;
  }
  
  // Fallback to old path: /Item Management/User/users/{userId}
  final oldUserDocRef = _firestore!
      .collection(_inventoryManagementCollection)
      .doc(_userDocumentId)
      .collection(_usersSubcollection)
      .doc(userId);
  await oldUserDocRef.set({'role': newRole}, SetOptions(merge: true));
}
```

#### Example: Form Definitions (`firebase_service.dart`)

```dart
Future<Map<String, dynamic>?> fetchFormDefinition(String formId, {String? clinicId}) async {
  // 1. Try system-level path: /system/{systemId}/forms/{formId}
  final systemDoc = await systemDocRef.get();
  if (systemDoc.exists) return systemDoc.data();
  
  // 2. Try clinic-level path: /clinics/{clinicId}/forms/{formId}
  if (clinicId != null) {
    final clinicFormDoc = await clinicDoc.collection('forms').doc(formId).get();
    if (clinicFormDoc.exists) return clinicFormDoc.data();
  }
  
  // 3. Fallback to legacy path: /Item Management/form_definitions/forms/{formId}
  final legacyDoc = await baseDoc.collection('forms').doc(formId).get();
  if (legacyDoc.exists) return legacyDoc.data();
  
  return null;
}
```

### 2. Legacy Method Preservation

Old methods are kept for backward compatibility:

```dart
// Legacy method - kept for backward compatibility
Future<void> saveUser(User user) async {
  // Old implementation using /Item Management/User/users subcollection
}
```

---

## Forward Compatibility

Forward compatibility ensures that the current code can handle data with new fields that didn't exist in older versions.

### 1. Null-Safe Field Parsing

All models use null-safe parsing with default values:

#### Example: UserModel (`user_model.dart`)

```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    uid: json['uid'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,  // Optional - can be null
    username: json['username'] as String?,  // Optional - can be null
    role: json['role'] as String? ?? 'END_USER',  // Default fallback
    permissions: (json['permissions'] as List?)?.cast<String>() ?? [],
    branchId: json['branchId'] as String?,
    status: json['status'] as String? ?? 'Active',
    profilePhoto: json['profilePhoto'] as String?,  // New field - gracefully handles missing
    createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
  );
}
```

**Key Patterns:**
- `as String? ?? ''` - Provides empty string default for required fields
- `as String?` - Allows null for optional fields
- `(json['field'] as List?)?.cast<String>() ?? []` - Safe list parsing
- `(json['field'] as Timestamp?)?.toDate()` - Safe timestamp conversion

#### Example: BranchModel (`branch_model.dart`)

```dart
factory BranchModel.fromJson(Map<String, dynamic> json) {
  return BranchModel(
    // Required fields with defaults
    branchId: json['branchId'] as String? ?? '',
    branchName: json['branchName'] as String? ?? '',
    
    // Optional fields
    description: json['description'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    
    // Fields with sensible defaults
    country: json['country'] as String? ?? 'India',
    timeZone: json['timeZone'] as String? ?? 'Asia/Kolkata',
    operationalStatus: json['operationalStatus'] as String? ?? 'Open',
    
    // Boolean fields with defaults
    coldStorageAvailable: json['coldStorageAvailable'] as bool? ?? false,
    batchRequired: json['batchRequired'] as bool? ?? true,
    expiryRequired: json['expiryRequired'] as bool? ?? true,
    
    // New fields added later - gracefully handled if missing
    googleMapLink: json['googleMapLink'] as String?,
    maxStaffLimit: json['maxStaffLimit'] as int?,
  );
}
```

### 2. Merge Updates (SetOptions.merge: true)

Using `SetOptions(merge: true)` ensures new fields don't overwrite existing data:

```dart
// In firebase_service.dart
await userDocRef.set({
  'role': newRole,
  'updatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));  // Preserves existing fields
```

### 3. Type Checking and Fallbacks

The code handles different data types that may exist in the database:

#### Example: Role Reference Resolution (`user_service.dart`)

```dart
// Handle both DocumentReference (new) and String (old) role formats
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
    data['role'] = 'END_USER';  // Fallback to default
  }
}
// If it's already a String, it will be used as-is
```

### 4. Graceful Error Handling

Methods return safe defaults instead of throwing errors:

```dart
// In user_service.dart
Stream<List<UserModel>> getUsersByBranch(String clinicId, String branchId) {
  if (!_firebaseService.isAvailable) {
    return Stream.value([]);  // Return empty list instead of error
  }
  try {
    // ... implementation
  } catch (e) {
    debugPrint('Error getting users by branch: $e');
    return Stream.value([]);  // Safe fallback
  }
}
```

---

## Data Model Compatibility

### 1. Optional Fields

All new fields added to models are optional to maintain forward compatibility:

```dart
class UserModel {
  final String? phone;  // Optional - added later
  final String? username;  // Optional - added later
  final String? profilePhoto;  // Optional - added later
  final DateTime? createdAt;  // Optional - added later
  final DateTime? updatedAt;  // Optional - added later
}
```

### 2. Default Values

Sensible defaults ensure models work even with minimal data:

```dart
const UserModel({
  // ...
  this.permissions = const [],  // Default empty list
  this.status = 'Active',  // Default status
  this.role = 'END_USER',  // Default role
});
```

### 3. CopyWith Pattern

The `copyWith` method allows partial updates without breaking existing code:

```dart
UserModel copyWith({
  String? uid,
  String? name,
  // ... all fields optional
}) {
  return UserModel(
    uid: uid ?? this.uid,  // Preserve existing if not provided
    name: name ?? this.name,
    // ...
  );
}
```

---

## Firebase Path Migration

### Migration Strategy

The codebase uses a progressive migration approach:

1. **Dual Path Support**: Both old and new paths are supported simultaneously
2. **Automatic Migration**: Data is migrated on first access
3. **Fallback Logic**: Always check new path first, then fallback to old path
4. **No Data Loss**: Old data remains accessible until fully migrated

### Example Migration Flow

```dart
// Step 1: Check new path
final rolesCollection = await _rolesCollection();
var snapshot = await rolesCollection.get();

// Step 2: If empty, migrate from legacy
if (snapshot.docs.isEmpty) {
  await _migrateLegacyRolesIfNeeded(rolesCollection);
  snapshot = await rolesCollection.get();
}

// Step 3: Return results
return snapshot.docs.map((doc) => doc.id).toList();
```

---

## Best Practices

### ✅ DO

1. **Always provide defaults for required fields:**
   ```dart
   name: json['name'] as String? ?? '',
   ```

2. **Use optional types for new fields:**
   ```dart
   final String? newField;  // Not final String newField;
   ```

3. **Check for null before accessing:**
   ```dart
   if (data['field'] != null) {
     // Use field
   }
   ```

4. **Use SetOptions.merge for updates:**
   ```dart
   await docRef.set(data, SetOptions(merge: true));
   ```

5. **Provide fallback paths for data access:**
   ```dart
   // Try new path, then old path
   ```

6. **Return safe defaults on errors:**
   ```dart
   catch (e) {
     return Stream.value([]);  // Not throw
   }
   ```

### ❌ DON'T

1. **Don't assume fields exist:**
   ```dart
   // BAD
   final name = json['name'] as String;
   
   // GOOD
   final name = json['name'] as String? ?? '';
   ```

2. **Don't throw errors for missing optional data:**
   ```dart
   // BAD
   if (json['phone'] == null) throw Exception('Phone required');
   
   // GOOD
   phone: json['phone'] as String?,
   ```

3. **Don't overwrite existing data:**
   ```dart
   // BAD
   await docRef.set(newData);  // Overwrites everything
   
   // GOOD
   await docRef.set(newData, SetOptions(merge: true));
   ```

4. **Don't remove legacy methods immediately:**
   ```dart
   // Keep for backward compatibility
   // Mark as deprecated instead
   @Deprecated('Use newMethod instead')
   Future<void> oldMethod() async { ... }
   ```

---

## Version Compatibility Matrix

| Feature | Old Path | New Path | Migration Status |
|---------|----------|----------|------------------|
| Users | `/Item Management/User/users` | `/Users/{uid}` | ✅ Dual support |
| Roles | `/Item Management/Roles/roles` | `/Item Management/User/roles` | ✅ Auto-migrate |
| Forms | `/Item Management/form_definitions/forms` | `/clinics/{id}/forms` or `/system/{id}/forms` | ✅ Fallback support |
| User Role | String | DocumentReference | ✅ Type checking |

---

## Testing Compatibility

When adding new fields or changing schemas:

1. **Test with old data**: Ensure existing data still parses correctly
2. **Test with new data**: Ensure new fields work as expected
3. **Test with mixed data**: Ensure both old and new formats work together
4. **Test migration paths**: Verify automatic migration works correctly

---

## Summary

The codebase implements comprehensive forward and backward compatibility through:

- ✅ Legacy path fallbacks
- ✅ Null-safe field parsing with defaults
- ✅ Optional field types
- ✅ Merge updates (SetOptions.merge)
- ✅ Type checking and fallbacks
- ✅ Graceful error handling
- ✅ Automatic data migration
- ✅ Safe default returns

This ensures smooth transitions during updates and maintains data integrity across versions.

