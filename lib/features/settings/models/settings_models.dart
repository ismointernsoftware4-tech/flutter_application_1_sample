class SystemConfiguration {
  String organizationName;
  String currency;
  String timeZone;
  bool emailAlerts;
  bool lowStockWarnings;

  SystemConfiguration({
    required this.organizationName,
    required this.currency,
    required this.timeZone,
    this.emailAlerts = true,
    this.lowStockWarnings = true,
  });

  SystemConfiguration copyWith({
    String? organizationName,
    String? currency,
    String? timeZone,
    bool? emailAlerts,
    bool? lowStockWarnings,
  }) {
    return SystemConfiguration(
      organizationName: organizationName ?? this.organizationName,
      currency: currency ?? this.currency,
      timeZone: timeZone ?? this.timeZone,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      lowStockWarnings: lowStockWarnings ?? this.lowStockWarnings,
    );
  }
}

class RoleDefinition {
  final String name;
  final String description;
  final int usersAssigned;

  const RoleDefinition({
    required this.name,
    required this.description,
    required this.usersAssigned,
  });
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String lastLogin;
  final String password;

  User({
    this.id = '',
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastLogin,
    this.password = '',
  });
}

class NewUserForm {
  String fullName;
  String email;
  String role;
  String status;
  String password;

  NewUserForm({
    this.fullName = '',
    this.email = '',
    this.role = 'Requester',
    this.status = 'Active',
    this.password = '',
  });
}

