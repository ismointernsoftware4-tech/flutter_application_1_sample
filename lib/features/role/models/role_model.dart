class RoleModel {
  final String id;
  final String roleName;
  final String description;
  final String status; // "Active" | "Inactive"
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoleModel({
    this.id = '',
    required this.roleName,
    required this.description,
    required this.status,
    required this.permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'roleName': roleName,
      'description': description,
      'status': status,
      'permissions': permissions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

