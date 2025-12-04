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
  final String amount;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.vendor,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class ProcurementFilter {
  final String? status;
  final String? priority; // For PR
  final String? vendor; // For PO
  final String? department; // For PR
  final String? category; // For Vendor
  final String? searchQuery; // Generic search

  const ProcurementFilter({
    this.status,
    this.priority,
    this.vendor,
    this.department,
    this.category,
    this.searchQuery,
  });

  ProcurementFilter copyWith({
    String? status,
    String? priority,
    String? vendor,
    String? department,
    String? category,
    String? searchQuery,
  }) {
    return ProcurementFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      vendor: vendor ?? this.vendor,
      department: department ?? this.department,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool matchesPR(PurchaseRequisition pr) {
    final statusOk = status == null || pr.status == status;
    final priorityOk = priority == null || pr.priority == priority;
    final deptOk = department == null || pr.department == department;
    final searchOk =
        searchQuery == null ||
        pr.id.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        pr.requestedBy.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && priorityOk && deptOk && searchOk;
  }

  bool matchesPRMap(Map<String, dynamic> pr) {
    final prStatus = (pr['status'] ?? '').toString();
    final prPriority = (pr['priority'] ?? '').toString();
    final prDepartment = (pr['department'] ?? '').toString();
    final prId = (pr['id'] ?? '').toString().toLowerCase();
    final prRequestedBy = (pr['requestedBy'] ?? '').toString().toLowerCase();
    
    final statusOk = status == null || prStatus == status;
    final priorityOk = priority == null || prPriority == priority;
    final deptOk = department == null || prDepartment == department;
    final searchOk =
        searchQuery == null ||
        searchQuery!.isEmpty ||
        prId.contains(searchQuery!.toLowerCase()) ||
        prRequestedBy.contains(searchQuery!.toLowerCase());
    return statusOk && priorityOk && deptOk && searchOk;
  }

  bool matchesPO(PurchaseOrder po) {
    final statusOk = status == null || po.status == status;
    final vendorOk = vendor == null || po.vendor == vendor;
    final searchOk =
        searchQuery == null ||
        po.id.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        po.vendor.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && vendorOk && searchOk;
  }

  bool matchesPOMap(Map<String, dynamic> po) {
    final poStatus = (po['status'] ?? '').toString();
    final poVendor = (po['vendor'] ?? '').toString();
    final poId = (po['id'] ?? '').toString().toLowerCase();
    
    final statusOk = status == null || poStatus == status;
    final vendorOk = vendor == null || poVendor == vendor;
    final searchOk =
        searchQuery == null ||
        searchQuery!.isEmpty ||
        poId.contains(searchQuery!.toLowerCase()) ||
        poVendor.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && vendorOk && searchOk;
  }

  bool matchesVendor(dynamic v) {
    // This method references Vendor which is in vendor_management
    // We'll keep it for compatibility but it should use Vendor from vendor_management
    return true;
  }

  bool matchesVendorMap(Map<String, dynamic> v) {
    final vendorStatus = (v['status'] ?? '').toString();
    final vendorCategory = (v['category'] ?? '').toString();
    final vendorName = (v['name'] ?? '').toString().toLowerCase();
    
    final statusOk = status == null || vendorStatus == status;
    final categoryOk = category == null || vendorCategory == category;
    final searchOk =
        searchQuery == null ||
        searchQuery!.isEmpty ||
        vendorName.contains(searchQuery!.toLowerCase()) ||
        vendorCategory.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && categoryOk && searchOk;
  }
}

