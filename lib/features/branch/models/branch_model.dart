import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  // Basic Information
  final String branchId;
  final String branchName;
  final String branchCode;
  final String branchType; // Main, Sub Branch, Pharmacy, Lab, Warehouse
  final String status; // Active, Inactive
  final String ownershipType; // Owned, Partnered
  final String? description;

  // Address
  final String addressLine1;
  final String? addressLine2;
  final String? area;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? googleMapLink;

  // Contact
  final String contactPerson;
  final String? contactDesignation;
  final String contactNumber;
  final String? whatsappNumber;
  final String email;
  final String? alternateEmail;

  // Operational
  final String? workingHours;
  final List<String>? operatingDays; // Mon, Tue, Wed, etc.
  final String timeZone;
  final String operationalStatus; // Open, Closed, Maintenance
  final int? maxStaffLimit;

  // Inventory Config
  final int? storageCapacity;
  final bool coldStorageAvailable;
  final int? coldStorageCapacity;
  final int? noOfRacks;
  final String? rackFormat;
  final String? warehouseType; // Main Storage, Sub Store, Pharmacy Store, Lab Store
  final bool binLevelTracking;
  final bool batchRequired;
  final bool expiryRequired;
  final bool allowNegativeStock;
  final bool reorderAlertsEnabled;
  final bool autoGenerateItemCode;
  final String? defaultPurchaseMode; // Centralised, Decentralised

  // Procurement
  final bool approvalRequiredForPR;
  final bool approvalRequiredForPO;
  final bool approvalRequiredForGRN;
  final String? defaultApproverRole; // BranchAdmin, SystemAdmin
  final double? maxApprovalLimit;
  final String? defaultVendorId;
  final bool autoClosePO;
  final String? paymentTerms; // Immediate, 7 Days, 15 Days, 30 Days

  // Compliance
  final String? gstNumber;
  final String? drugLicenseNumber;
  final String? branchRegistrationCertificate; // file URL
  final String? fireSafetyCertificate; // file URL
  final String? accreditationCertificate; // file URL
  final String? licenseValidTill; // date
  final String? lastAuditDate; // date
  final String? nextAuditDate; // date

  // System fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BranchModel({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.branchType,
    required this.status,
    required this.ownershipType,
    this.description,
    required this.addressLine1,
    this.addressLine2,
    this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.latitude,
    this.longitude,
    this.googleMapLink,
    required this.contactPerson,
    this.contactDesignation,
    required this.contactNumber,
    this.whatsappNumber,
    required this.email,
    this.alternateEmail,
    this.workingHours,
    this.operatingDays,
    this.timeZone = 'Asia/Kolkata',
    this.operationalStatus = 'Open',
    this.maxStaffLimit,
    this.storageCapacity,
    this.coldStorageAvailable = false,
    this.coldStorageCapacity,
    this.noOfRacks,
    this.rackFormat,
    this.warehouseType,
    this.binLevelTracking = false,
    this.batchRequired = true,
    this.expiryRequired = true,
    this.allowNegativeStock = false,
    this.reorderAlertsEnabled = true,
    this.autoGenerateItemCode = true,
    this.defaultPurchaseMode,
    this.approvalRequiredForPR = true,
    this.approvalRequiredForPO = true,
    this.approvalRequiredForGRN = true,
    this.defaultApproverRole,
    this.maxApprovalLimit,
    this.defaultVendorId,
    this.autoClosePO = false,
    this.paymentTerms,
    this.gstNumber,
    this.drugLicenseNumber,
    this.branchRegistrationCertificate,
    this.fireSafetyCertificate,
    this.accreditationCertificate,
    this.licenseValidTill,
    this.lastAuditDate,
    this.nextAuditDate,
    this.createdAt,
    this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      branchId: json['branchId'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      branchCode: json['branchCode'] as String? ?? '',
      branchType: json['branchType'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      ownershipType: json['ownershipType'] as String? ?? '',
      description: json['description'] as String?,
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      googleMapLink: json['googleMapLink'] as String?,
      contactPerson: json['contactPerson'] as String? ?? '',
      contactDesignation: json['contactDesignation'] as String?,
      contactNumber: json['contactNumber'] as String? ?? '',
      whatsappNumber: json['whatsappNumber'] as String?,
      email: json['email'] as String? ?? '',
      alternateEmail: json['alternateEmail'] as String?,
      workingHours: json['workingHours'] as String?,
      operatingDays: (json['operatingDays'] as List?)?.cast<String>(),
      timeZone: json['timeZone'] as String? ?? 'Asia/Kolkata',
      operationalStatus: json['operationalStatus'] as String? ?? 'Open',
      maxStaffLimit: json['maxStaffLimit'] as int?,
      storageCapacity: json['storageCapacity'] as int?,
      coldStorageAvailable: json['coldStorageAvailable'] as bool? ?? false,
      coldStorageCapacity: json['coldStorageCapacity'] as int?,
      noOfRacks: json['noOfRacks'] as int?,
      rackFormat: json['rackFormat'] as String?,
      warehouseType: json['warehouseType'] as String?,
      binLevelTracking: json['binLevelTracking'] as bool? ?? false,
      batchRequired: json['batchRequired'] as bool? ?? true,
      expiryRequired: json['expiryRequired'] as bool? ?? true,
      allowNegativeStock: json['allowNegativeStock'] as bool? ?? false,
      reorderAlertsEnabled: json['reorderAlertsEnabled'] as bool? ?? true,
      autoGenerateItemCode: json['autoGenerateItemCode'] as bool? ?? true,
      defaultPurchaseMode: json['defaultPurchaseMode'] as String?,
      approvalRequiredForPR: json['approvalRequiredForPR'] as bool? ?? true,
      approvalRequiredForPO: json['approvalRequiredForPO'] as bool? ?? true,
      approvalRequiredForGRN: json['approvalRequiredForGRN'] as bool? ?? true,
      defaultApproverRole: json['defaultApproverRole'] as String?,
      maxApprovalLimit: (json['maxApprovalLimit'] as num?)?.toDouble(),
      defaultVendorId: json['defaultVendorId'] as String?,
      autoClosePO: json['autoClosePO'] as bool? ?? false,
      paymentTerms: json['paymentTerms'] as String?,
      gstNumber: json['gstNumber'] as String?,
      drugLicenseNumber: json['drugLicenseNumber'] as String?,
      branchRegistrationCertificate: json['branchRegistrationCertificate'] as String?,
      fireSafetyCertificate: json['fireSafetyCertificate'] as String?,
      accreditationCertificate: json['accreditationCertificate'] as String?,
      licenseValidTill: json['licenseValidTill'] as String?,
      lastAuditDate: json['lastAuditDate'] as String?,
      nextAuditDate: json['nextAuditDate'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'branchName': branchName,
      'branchCode': branchCode,
      'branchType': branchType,
      'status': status,
      'ownershipType': ownershipType,
      'description': description,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapLink': googleMapLink,
      'contactPerson': contactPerson,
      'contactDesignation': contactDesignation,
      'contactNumber': contactNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'alternateEmail': alternateEmail,
      'workingHours': workingHours,
      'operatingDays': operatingDays,
      'timeZone': timeZone,
      'operationalStatus': operationalStatus,
      'maxStaffLimit': maxStaffLimit,
      'storageCapacity': storageCapacity,
      'coldStorageAvailable': coldStorageAvailable,
      'coldStorageCapacity': coldStorageCapacity,
      'noOfRacks': noOfRacks,
      'rackFormat': rackFormat,
      'warehouseType': warehouseType,
      'binLevelTracking': binLevelTracking,
      'batchRequired': batchRequired,
      'expiryRequired': expiryRequired,
      'allowNegativeStock': allowNegativeStock,
      'reorderAlertsEnabled': reorderAlertsEnabled,
      'autoGenerateItemCode': autoGenerateItemCode,
      'defaultPurchaseMode': defaultPurchaseMode,
      'approvalRequiredForPR': approvalRequiredForPR,
      'approvalRequiredForPO': approvalRequiredForPO,
      'approvalRequiredForGRN': approvalRequiredForGRN,
      'defaultApproverRole': defaultApproverRole,
      'maxApprovalLimit': maxApprovalLimit,
      'defaultVendorId': defaultVendorId,
      'autoClosePO': autoClosePO,
      'paymentTerms': paymentTerms,
      'gstNumber': gstNumber,
      'drugLicenseNumber': drugLicenseNumber,
      'branchRegistrationCertificate': branchRegistrationCertificate,
      'fireSafetyCertificate': fireSafetyCertificate,
      'accreditationCertificate': accreditationCertificate,
      'licenseValidTill': licenseValidTill,
      'lastAuditDate': lastAuditDate,
      'nextAuditDate': nextAuditDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  BranchModel copyWith({
    String? branchId,
    String? branchName,
    String? branchCode,
    String? branchType,
    String? status,
    String? ownershipType,
    String? description,
    String? addressLine1,
    String? addressLine2,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? country,
    double? latitude,
    double? longitude,
    String? googleMapLink,
    String? contactPerson,
    String? contactDesignation,
    String? contactNumber,
    String? whatsappNumber,
    String? email,
    String? alternateEmail,
    String? workingHours,
    List<String>? operatingDays,
    String? timeZone,
    String? operationalStatus,
    int? maxStaffLimit,
    int? storageCapacity,
    bool? coldStorageAvailable,
    int? coldStorageCapacity,
    int? noOfRacks,
    String? rackFormat,
    String? warehouseType,
    bool? binLevelTracking,
    bool? batchRequired,
    bool? expiryRequired,
    bool? allowNegativeStock,
    bool? reorderAlertsEnabled,
    bool? autoGenerateItemCode,
    String? defaultPurchaseMode,
    bool? approvalRequiredForPR,
    bool? approvalRequiredForPO,
    bool? approvalRequiredForGRN,
    String? defaultApproverRole,
    double? maxApprovalLimit,
    String? defaultVendorId,
    bool? autoClosePO,
    String? paymentTerms,
    String? gstNumber,
    String? drugLicenseNumber,
    String? branchRegistrationCertificate,
    String? fireSafetyCertificate,
    String? accreditationCertificate,
    String? licenseValidTill,
    String? lastAuditDate,
    String? nextAuditDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchModel(
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      branchType: branchType ?? this.branchType,
      status: status ?? this.status,
      ownershipType: ownershipType ?? this.ownershipType,
      description: description ?? this.description,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapLink: googleMapLink ?? this.googleMapLink,
      contactPerson: contactPerson ?? this.contactPerson,
      contactDesignation: contactDesignation ?? this.contactDesignation,
      contactNumber: contactNumber ?? this.contactNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      alternateEmail: alternateEmail ?? this.alternateEmail,
      workingHours: workingHours ?? this.workingHours,
      operatingDays: operatingDays ?? this.operatingDays,
      timeZone: timeZone ?? this.timeZone,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      maxStaffLimit: maxStaffLimit ?? this.maxStaffLimit,
      storageCapacity: storageCapacity ?? this.storageCapacity,
      coldStorageAvailable: coldStorageAvailable ?? this.coldStorageAvailable,
      coldStorageCapacity: coldStorageCapacity ?? this.coldStorageCapacity,
      noOfRacks: noOfRacks ?? this.noOfRacks,
      rackFormat: rackFormat ?? this.rackFormat,
      warehouseType: warehouseType ?? this.warehouseType,
      binLevelTracking: binLevelTracking ?? this.binLevelTracking,
      batchRequired: batchRequired ?? this.batchRequired,
      expiryRequired: expiryRequired ?? this.expiryRequired,
      allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
      reorderAlertsEnabled: reorderAlertsEnabled ?? this.reorderAlertsEnabled,
      autoGenerateItemCode: autoGenerateItemCode ?? this.autoGenerateItemCode,
      defaultPurchaseMode: defaultPurchaseMode ?? this.defaultPurchaseMode,
      approvalRequiredForPR: approvalRequiredForPR ?? this.approvalRequiredForPR,
      approvalRequiredForPO: approvalRequiredForPO ?? this.approvalRequiredForPO,
      approvalRequiredForGRN: approvalRequiredForGRN ?? this.approvalRequiredForGRN,
      defaultApproverRole: defaultApproverRole ?? this.defaultApproverRole,
      maxApprovalLimit: maxApprovalLimit ?? this.maxApprovalLimit,
      defaultVendorId: defaultVendorId ?? this.defaultVendorId,
      autoClosePO: autoClosePO ?? this.autoClosePO,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      gstNumber: gstNumber ?? this.gstNumber,
      drugLicenseNumber: drugLicenseNumber ?? this.drugLicenseNumber,
      branchRegistrationCertificate: branchRegistrationCertificate ?? this.branchRegistrationCertificate,
      fireSafetyCertificate: fireSafetyCertificate ?? this.fireSafetyCertificate,
      accreditationCertificate: accreditationCertificate ?? this.accreditationCertificate,
      licenseValidTill: licenseValidTill ?? this.licenseValidTill,
      lastAuditDate: lastAuditDate ?? this.lastAuditDate,
      nextAuditDate: nextAuditDate ?? this.nextAuditDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

