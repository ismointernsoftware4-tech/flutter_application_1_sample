class ClinicDocument {
  final String name;
  final String url;

  const ClinicDocument({required this.name, required this.url});

  factory ClinicDocument.fromJson(Map<String, dynamic> json) => ClinicDocument(
    name: json['name'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );
}

class ClinicContact {
  final String phone;
  final String email;
  final String website;
  final String primaryContactPerson;
  final String primaryContactNumber;

  const ClinicContact({
    required this.phone,
    required this.email,
    required this.website,
    required this.primaryContactPerson,
    required this.primaryContactNumber,
  });

  factory ClinicContact.fromJson(Map<String, dynamic> json) => ClinicContact(
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    website: json['website'] as String? ?? '',
    primaryContactPerson: json['primaryContactPerson'] as String? ?? '',
    primaryContactNumber: json['primaryContactNumber'] as String? ?? '',
  );
}

class ClinicAddress {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final double? latitude;
  final double? longitude;

  const ClinicAddress({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory ClinicAddress.fromJson(Map<String, dynamic> json) => ClinicAddress(
    addressLine1: json['addressLine1'] as String? ?? '',
    addressLine2: json['addressLine2'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    pincode: json['pincode'] as String? ?? '',
    country: json['country'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}

class ClinicLicense {
  final String gstNumber;
  final String panNumber;
  final String drugLicenseNo;
  final String fssaiNumber;
  final String registrationDate;
  final String licenseExpiryDate;
  final List<ClinicDocument> documents;

  const ClinicLicense({
    required this.gstNumber,
    required this.panNumber,
    required this.drugLicenseNo,
    required this.fssaiNumber,
    required this.registrationDate,
    required this.licenseExpiryDate,
    required this.documents,
  });

  factory ClinicLicense.fromJson(Map<String, dynamic> json) => ClinicLicense(
    gstNumber: json['gstNumber'] as String? ?? '',
    panNumber: json['panNumber'] as String? ?? '',
    drugLicenseNo: json['drugLicenseNo'] as String? ?? '',
    fssaiNumber: json['fssaiNumber'] as String? ?? '',
    registrationDate: json['registrationDate'] as String? ?? '',
    licenseExpiryDate: json['licenseExpiryDate'] as String? ?? '',
    documents: (json['documents'] as List<dynamic>? ?? const [])
        .map((doc) => ClinicDocument.fromJson(doc as Map<String, dynamic>))
        .toList(),
  );
}

class ClinicSettings {
  final String timezone;
  final String workingHoursStart;
  final String workingHoursEnd;
  final bool allowMultiBranch;
  final String defaultCurrency;
  final bool enableStockTracking;
  final bool enableBatchManagement;
  final bool enableExpiryManagement;

  const ClinicSettings({
    required this.timezone,
    required this.workingHoursStart,
    required this.workingHoursEnd,
    required this.allowMultiBranch,
    required this.defaultCurrency,
    required this.enableStockTracking,
    required this.enableBatchManagement,
    required this.enableExpiryManagement,
  });

  factory ClinicSettings.fromJson(Map<String, dynamic> json) => ClinicSettings(
    timezone: json['timezone'] as String? ?? '',
    workingHoursStart: json['workingHoursStart'] as String? ?? '',
    workingHoursEnd: json['workingHoursEnd'] as String? ?? '',
    allowMultiBranch: json['allowMultiBranch'] as bool? ?? false,
    defaultCurrency: json['defaultCurrency'] as String? ?? '',
    enableStockTracking: json['enableStockTracking'] as bool? ?? false,
    enableBatchManagement: json['enableBatchManagement'] as bool? ?? false,
    enableExpiryManagement: json['enableExpiryManagement'] as bool? ?? false,
  );
}

class ClinicBilling {
  final String billingPrefix;
  final String poPrefix;
  final String grnPrefix;
  final String invoicePrefix;
  final String financialYearStart;
  final String financialYearEnd;

  const ClinicBilling({
    required this.billingPrefix,
    required this.poPrefix,
    required this.grnPrefix,
    required this.invoicePrefix,
    required this.financialYearStart,
    required this.financialYearEnd,
  });

  factory ClinicBilling.fromJson(Map<String, dynamic> json) => ClinicBilling(
    billingPrefix: json['billingPrefix'] as String? ?? '',
    poPrefix: json['poPrefix'] as String? ?? '',
    grnPrefix: json['grnPrefix'] as String? ?? '',
    invoicePrefix: json['invoicePrefix'] as String? ?? '',
    financialYearStart: json['financialYearStart'] as String? ?? '',
    financialYearEnd: json['financialYearEnd'] as String? ?? '',
  );
}

class ClinicModules {
  final Map<String, bool> modules;

  const ClinicModules(this.modules);

  factory ClinicModules.fromJson(Map<String, dynamic> json) {
    final map = <String, bool>{};
    json.forEach((key, value) {
      map[key] = value == true;
    });
    return ClinicModules(map);
  }

  Iterable<String> get enabledModules =>
      modules.entries.where((e) => e.value).map((e) => e.key);
}

class TodayTransactions {
  final int stockIn;
  final int stockOut;

  const TodayTransactions({required this.stockIn, required this.stockOut});

  factory TodayTransactions.fromJson(Map<String, dynamic> json) =>
      TodayTransactions(
        stockIn: json['stockIn'] as int? ?? 0,
        stockOut: json['stockOut'] as int? ?? 0,
      );
}

class ClinicSummary {
  final int totalBranches;
  final int totalUsers;
  final int totalVendors;
  final int totalItems;
  final int lowStockAlerts;
  final int expiringSoon;
  final int pendingPO;
  final int pendingGRN;
  final TodayTransactions todayTransactions;

  const ClinicSummary({
    required this.totalBranches,
    required this.totalUsers,
    required this.totalVendors,
    required this.totalItems,
    required this.lowStockAlerts,
    required this.expiringSoon,
    required this.pendingPO,
    required this.pendingGRN,
    required this.todayTransactions,
  });

  factory ClinicSummary.fromJson(Map<String, dynamic> json) => ClinicSummary(
    totalBranches: json['totalBranches'] as int? ?? 0,
    totalUsers: json['totalUsers'] as int? ?? 0,
    totalVendors: json['totalVendors'] as int? ?? 0,
    totalItems: json['totalItems'] as int? ?? 0,
    lowStockAlerts: json['lowStockAlerts'] as int? ?? 0,
    expiringSoon: json['expiringSoon'] as int? ?? 0,
    pendingPO: json['pendingPO'] as int? ?? 0,
    pendingGRN: json['pendingGRN'] as int? ?? 0,
    todayTransactions: TodayTransactions.fromJson(
      json['todayTransactions'] as Map<String, dynamic>? ?? const {},
    ),
  );
}

class ClinicAdmin {
  final String adminId;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String? lastLogin;
  final List<String> permissions;

  const ClinicAdmin({
    required this.adminId,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.lastLogin,
    required this.permissions,
  });

  factory ClinicAdmin.fromJson(Map<String, dynamic> json) => ClinicAdmin(
    adminId: json['adminId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    status: json['status'] as String? ?? '',
    lastLogin: json['lastLogin'] as String?,
    permissions: (json['permissions'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );
}

class ClinicRole {
  final String roleId;
  final String name;
  final String description;
  final List<String> accessiblePages;

  const ClinicRole({
    required this.roleId,
    required this.name,
    required this.description,
    required this.accessiblePages,
  });

  factory ClinicRole.fromJson(Map<String, dynamic> json) => ClinicRole(
    roleId: json['roleId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    accessiblePages: (json['accessiblePages'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );
}

class ClinicData {
  final String clinicId;
  final String clinicName;
  final String clinicCode;
  final String legalName;
  final String shortName;
  final String description;
  final String clinicLogoUrl;
  final String status;
  final ClinicContact contact;
  final ClinicAddress address;
  final ClinicLicense license;
  final ClinicSettings settings;
  final ClinicBilling billing;
  final ClinicModules modules;
  final ClinicSummary summary;
  final List<ClinicAdmin> clinicAdmins;
  final List<ClinicRole> roles;
  final List<ClinicBranch> branches;
  final String updatedAt;
  final String createdAt;

  const ClinicData({
    required this.clinicId,
    required this.clinicName,
    required this.clinicCode,
    required this.legalName,
    required this.shortName,
    required this.description,
    required this.clinicLogoUrl,
    required this.status,
    required this.contact,
    required this.address,
    required this.license,
    required this.settings,
    required this.billing,
    required this.modules,
    required this.summary,
    required this.clinicAdmins,
    required this.roles,
    required this.branches,
    required this.updatedAt,
    required this.createdAt,
  });

  factory ClinicData.fromJson(Map<String, dynamic> json) => ClinicData(
    clinicId: json['clinicId'] as String? ?? '',
    clinicName: json['clinicName'] as String? ?? '',
    clinicCode: json['clinicCode'] as String? ?? '',
    legalName: json['legalName'] as String? ?? '',
    shortName: json['shortName'] as String? ?? '',
    description: json['description'] as String? ?? '',
    clinicLogoUrl: json['clinicLogoUrl'] as String? ?? '',
    status: json['status'] as String? ?? '',
    contact: ClinicContact.fromJson(
      json['contact'] as Map<String, dynamic>? ?? const {},
    ),
    address: ClinicAddress.fromJson(
      json['address'] as Map<String, dynamic>? ?? const {},
    ),
    license: ClinicLicense.fromJson(
      json['license'] as Map<String, dynamic>? ?? const {},
    ),
    settings: ClinicSettings.fromJson(
      json['settings'] as Map<String, dynamic>? ?? const {},
    ),
    billing: ClinicBilling.fromJson(
      json['billing'] as Map<String, dynamic>? ?? const {},
    ),
    modules: ClinicModules.fromJson(
      json['modules'] as Map<String, dynamic>? ?? const {},
    ),
    summary: ClinicSummary.fromJson(
      json['summary'] as Map<String, dynamic>? ?? const {},
    ),
    clinicAdmins: (json['clinicAdmins'] as List<dynamic>? ?? const [])
        .map((admin) => ClinicAdmin.fromJson(admin as Map<String, dynamic>))
        .toList(),
    roles: (json['roles'] as List<dynamic>? ?? const [])
        .map((role) => ClinicRole.fromJson(role as Map<String, dynamic>))
        .toList(),
    branches: (json['branches'] as List<dynamic>? ?? const [])
        .map((branch) => ClinicBranch.fromJson(branch as Map<String, dynamic>))
        .toList(),
    updatedAt: json['updatedAt'] as String? ?? '',
    createdAt: json['createdAt'] as String? ?? '',
  );
}

class ClinicBranch {
  final String branchId;
  final String branchName;
  final String branchCode;
  final String type;
  final String status;
  final String phone;
  final String email;
  final ClinicAddress address;

  const ClinicBranch({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.type,
    required this.status,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory ClinicBranch.fromJson(Map<String, dynamic> json) => ClinicBranch(
    branchId: json['branchId'] as String? ?? '',
    branchName: json['branchName'] as String? ?? '',
    branchCode: json['branchCode'] as String? ?? '',
    type: json['type'] as String? ?? '',
    status: json['status'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    address: ClinicAddress.fromJson(
      json['address'] as Map<String, dynamic>? ?? const {},
    ),
  );

  ClinicBranch copyWith({
    String? branchId,
    String? branchName,
    String? branchCode,
    String? type,
    String? status,
    String? phone,
    String? email,
    ClinicAddress? address,
  }) {
    return ClinicBranch(
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      type: type ?? this.type,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}

