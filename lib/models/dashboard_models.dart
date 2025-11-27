import 'package:flutter/material.dart';

class DashboardSummary {
  final int totalItems;
  final int lowStockAlerts;
  final int pendingPOs;
  final int pendingApprovals;

  DashboardSummary({
    required this.totalItems,
    required this.lowStockAlerts,
    required this.pendingPOs,
    required this.pendingApprovals,
  });
}

class CategoryInventory {
  final String category;
  final int quantity;
  final double value;

  CategoryInventory({
    required this.category,
    required this.quantity,
    required this.value,
  });
}

class StockStatus {
  final int active;
  final int lowStock;

  StockStatus({
    required this.active,
    required this.lowStock,
  });
}

class PurchaseOrderStatus {
  final int draft;
  final int issued;

  PurchaseOrderStatus({
    required this.draft,
    required this.issued,
  });
}

class Transaction {
  final String date;
  final String type;
  final String item;
  final String quantity;
  final String user;

  Transaction({
    required this.date,
    required this.type,
    required this.item,
    required this.quantity,
    required this.user,
  });
}

class NavigationItem {
  final String title;
  final IconData icon;
  final bool isActive;

  NavigationItem({
    required this.title,
    required this.icon,
    this.isActive = false,
  });
}

class ItemMaster {
  final String itemCode;
  final String itemName;
  final String manufacturer;
  final String type;
  final String category;
  final String unit;
  final String storage;
  final int stock;
  final String status;
  final Map<String, dynamic> rawValues;

  ItemMaster({
    required this.itemCode,
    required this.itemName,
    required this.manufacturer,
    required this.type,
    required this.category,
    required this.unit,
    required this.storage,
    required this.stock,
    required this.status,
    Map<String, dynamic>? rawValues,
  }) : rawValues = Map.unmodifiable(rawValues ?? const {});

  ItemMaster copyWith({
    String? itemCode,
    String? itemName,
    String? manufacturer,
    String? type,
    String? category,
    String? unit,
    String? storage,
    int? stock,
    String? status,
    Map<String, dynamic>? rawValues,
  }) {
    return ItemMaster(
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      manufacturer: manufacturer ?? this.manufacturer,
      type: type ?? this.type,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      storage: storage ?? this.storage,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      rawValues: rawValues ?? this.rawValues,
    );
  }

  String valueFor(String key) {
    // First, check rawValues which contains all JSON data dynamically
    final value = rawValues[key];
    if (value != null) {
      if (value is num) {
        return value.toString();
      }
      if (value is bool) {
        return value ? 'Yes' : 'No';
      }
      if (value is List) {
        return value.isEmpty ? '-' : value.join(', ');
      }
      return value.toString();
    }

    // Fallback to check for common field key variations
    final variations = _getFieldKeyVariations(key);
    for (final variation in variations) {
      final variantValue = rawValues[variation];
      if (variantValue != null) {
        if (variantValue is num) {
          return variantValue.toString();
        }
        if (variantValue is bool) {
          return variantValue ? 'Yes' : 'No';
        }
        return variantValue.toString();
      }
    }

    // Legacy fallback for hardcoded fields (backward compatibility)
    switch (key) {
      case 'itemCode':
        return itemCode;
      case 'itemName':
        return itemName;
      case 'type':
      case 'itemType':
        return type;
      case 'category':
        return category;
      case 'manufacturer':
        return manufacturer;
      case 'unit':
      case 'unitOfMeasure':
        return unit;
      case 'storage':
      case 'storageConditions':
        return storage;
      case 'stock':
        return stock.toString();
      case 'status':
        return status;
      default:
        return '';
    }
  }

  List<String> _getFieldKeyVariations(String key) {
    // Return common variations of the key for flexible matching
    switch (key) {
      case 'type':
        return ['itemType'];
      case 'itemType':
        return ['type'];
      case 'unit':
        return ['unitOfMeasure', 'uom'];
      case 'unitOfMeasure':
        return ['unit', 'uom'];
      case 'storage':
        return ['storageConditions'];
      case 'storageConditions':
        return ['storage'];
      default:
        return [];
    }
  }
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

class NewVendorForm {
  String vendorName;
  String category;
  String taxId;
  String website;
  String phone;
  String contactName;
  String contactEmail;
  String address;
  String paymentTerms;
  String bankName;
  String accountNumber;
  String complianceDocs;

  NewVendorForm({
    this.vendorName = '',
    this.category = 'Medical Supplies',
    this.taxId = '',
    this.website = '',
    this.phone = '',
    this.contactName = '',
    this.contactEmail = '',
    this.address = '',
    this.paymentTerms = 'Net 30',
    this.bankName = '',
    this.accountNumber = '',
    this.complianceDocs = '',
  });
}

class PurchaseRequisition {
  final String id;
  final String requestedBy;
  final String department;
  final String date;
  final String priority;
  final String status;

  PurchaseRequisition({
    required this.id,
    required this.requestedBy,
    required this.department,
    required this.date,
    required this.priority,
    required this.status,
  });
}

class PurchaseOrder {
  final String id;
  final String vendor;
  final String date;
  final String? deliveryDate;
  final String amount;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.vendor,
    required this.date,
    this.deliveryDate,
    required this.amount,
    required this.status,
  });
}

class GoodsReceipt {
  final String grnId;
  final String poReference;
  final String vendor;
  final String dateReceived;
  final String receivedBy;
  final String status;

  GoodsReceipt({
    required this.grnId,
    required this.poReference,
    required this.vendor,
    required this.dateReceived,
    required this.receivedBy,
    required this.status,
  });
}

class ReceivingTask {
  final IconData icon;
  final String title;
  final String reference;
  final String meta;
  final List<String> itemTags;
  final String primaryLabel;
  final String? secondaryLabel;
  final Color primaryColor;
  final Color? secondaryColor;

  const ReceivingTask({
    required this.icon,
    required this.title,
    required this.reference,
    required this.meta,
    required this.itemTags,
    required this.primaryLabel,
    this.secondaryLabel,
    this.primaryColor = const Color(0xFF0057B7),
    this.secondaryColor,
  });
}

class InventoryQuickAction {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String navTarget;

  const InventoryQuickAction({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.navTarget = '',
  });
}

class InventoryAudit {
  final String date;
  final String type;
  final String status;
  final int discrepancies;

  const InventoryAudit({
    required this.date,
    required this.type,
    required this.status,
    required this.discrepancies,
  });
}

class InventoryAdjustment {
  final String date;
  final String reason;
  final String status;
  final String quantity;

  const InventoryAdjustment({
    required this.date,
    required this.reason,
    required this.status,
    required this.quantity,
  });
}

class StorageLocation {
  final String id;
  final String name;
  final String type;
  final String parentLocation;
  final int capacity;
  final String status;
  final String manager;
  final String description;

  const StorageLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.parentLocation,
    required this.capacity,
    required this.status,
    this.manager = '',
    this.description = '',
  });
}

class TraceabilityRecord {
  final String dateTime;
  final String type;
  final String reference;
  final String itemDetails;
  final String quantity;
  final String user;
  final String location;

  const TraceabilityRecord({
    required this.dateTime,
    required this.type,
    required this.reference,
    required this.itemDetails,
    required this.quantity,
    required this.user,
    required this.location,
  });
}

class ApprovalWorkflowItem {
  final String priority;
  final String id;
  final String date;
  final String title;
  final String description;
  final String requestedBy;
  final String status;

  const ApprovalWorkflowItem({
    required this.priority,
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.requestedBy,
    required this.status,
  });
}

class ReportSummary {
  final String label;
  final String value;

  const ReportSummary({
    required this.label,
    required this.value,
  });
}

class ReportDownload {
  final String title;
  final String subtitle;

  const ReportDownload({
    required this.title,
    required this.subtitle,
  });
}

class ReportCategory {
  final String groupTitle;
  final String description;
  final List<ReportDownload> reports;

  const ReportCategory({
    required this.groupTitle,
    required this.description,
    required this.reports,
  });
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

class StockAuditRecord {
  final String id;
  final String date;
  final String type;
  final String auditor;
  final String status;
  final int discrepancies;

  const StockAuditRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.auditor,
    required this.status,
    required this.discrepancies,
  });
}

class StockTransferRecord {
  final String id;
  final String date;
  final String fromLocation;
  final String toLocation;
  final int quantity;
  final String status;

  const StockTransferRecord({
    required this.id,
    required this.date,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.status,
  });
}

class BranchTransferRecord {
  final String id;
  final String date;
  final String sourceBranch;
  final String destinationBranch;
  final int quantity;
  final String status;

  const BranchTransferRecord({
    required this.id,
    required this.date,
    required this.sourceBranch,
    required this.destinationBranch,
    required this.quantity,
    required this.status,
  });
}

class StockReturnRecord {
  final String id;
  final String date;
  final String vendor;
  final String item;
  final int quantity;
  final String reason;
  final String status;

  const StockReturnRecord({
    required this.id,
    required this.date,
    required this.vendor,
    required this.item,
    required this.quantity,
    required this.reason,
    required this.status,
  });
}

class InternalConsumptionRecord {
  final String id;
  final String date;
  final String department;
  final String item;
  final int quantity;
  final String purpose;
  final String user;

  const InternalConsumptionRecord({
    required this.id,
    required this.date,
    required this.department,
    required this.item,
    required this.quantity,
    required this.purpose,
    required this.user,
  });
}

enum VendorFieldType { text, dropdown, textarea }

class VendorFormField {
  final String id;
  String label;
  VendorFieldType type;
  bool required;
  List<String> options;

  VendorFormField({
    required this.id,
    required this.label,
    this.type = VendorFieldType.text,
    this.required = false,
    List<String>? options,
  }) : options = options ?? const [];

  VendorFormField copyWith({
    String? id,
    String? label,
    VendorFieldType? type,
    bool? required,
    List<String>? options,
  }) {
    return VendorFormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      options: options ?? this.options,
    );
  }
}

class VendorFormSection {
  final String id;
  String title;
  List<VendorFormField> fields;

  VendorFormSection({
    required this.id,
    required this.title,
    required this.fields,
  });

  VendorFormSection copyWith({
    String? id,
    String? title,
    List<VendorFormField>? fields,
  }) {
    return VendorFormSection(
      id: id ?? this.id,
      title: title ?? this.title,
      fields: fields ?? this.fields.map((f) => f.copyWith()).toList(),
    );
  }
}

class Vendor {
  final String name;
  final String category;
  final String contactName;
  final String email;
  final String phone;
  final String status;

  const Vendor({
    required this.name,
    required this.category,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.status,
  });
}

