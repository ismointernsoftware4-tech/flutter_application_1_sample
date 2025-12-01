import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? username;
  final String role; // SYSTEM_ADMIN, BRANCH_ADMIN, END_USER
  final List<String> permissions;
  final String? branchId; // null for SYSTEM_ADMIN
  final String status; // Active, Inactive
  final String? profilePhoto; // file URL
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.username,
    required this.role,
    this.permissions = const [],
    this.branchId,
    this.status = 'Active',
    this.profilePhoto,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      role: json['role'] as String? ?? 'END_USER',
      permissions: (json['permissions'] as List?)?.cast<String>() ?? [],
      branchId: json['branchId'] as String?,
      status: json['status'] as String? ?? 'Active',
      profilePhoto: json['profilePhoto'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'role': role,
      'permissions': permissions,
      'branchId': branchId,
      'status': status,
      'profilePhoto': profilePhoto,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? username,
    String? role,
    List<String>? permissions,
    String? branchId,
    String? status,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      branchId: branchId ?? this.branchId,
      status: status ?? this.status,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isSystemAdmin => role == 'SYSTEM_ADMIN';
  bool get isBranchAdmin => role == 'BRANCH_ADMIN';
  bool get isEndUser => role == 'END_USER';
  bool get isActive => status == 'Active';
}

