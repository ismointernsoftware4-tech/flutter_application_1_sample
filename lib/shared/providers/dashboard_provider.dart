import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/navigation_items.dart';
import '../models/dashboard_models.dart';
import '../../features/dashboard/models/dashboard_models.dart' as dashboard_feature_models;
import '../../features/traceability/models/traceability_models.dart';
import '../../features/vendor_management/models/vendor_models.dart';
import '../../features/grn_receiving/models/grn_models.dart';
import '../../features/storage_locations/models/storage_location_models.dart';
import '../../features/stock_management/models/stock_models.dart';
import '../../features/approvals/models/approvals_models.dart';
import '../../features/reports/models/reports_models.dart';
import '../../features/settings/models/settings_models.dart';
import '../services/firebase_service.dart';
import '../utils/csv_file_helper.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardSummary _summary = DashboardSummary(
    totalItems: 3,
    lowStockAlerts: 1,
    pendingPOs: 2,
    pendingApprovals: 3,
  );

  List<CategoryInventory> _inventoryByCategory = [
    CategoryInventory(category: 'Analgesic', quantity: 5000, value: 400),
    CategoryInventory(category: 'Antidiabetic', quantity: 50, value: 1700),
    CategoryInventory(category: 'Surgical', quantity: 30, value: 400),
  ];

  StockStatus _stockStatus = StockStatus(active: 75, lowStock: 25);

  PurchaseOrderStatus _poStatus = PurchaseOrderStatus(draft: 65, issued: 35);

  List<Transaction> _transactions = [
    Transaction(
      date: '2023-11-01 10:30',
      type: 'GRN',
      item: 'Paracetamol 500mg',
      quantity: '1000',
      user: 'Store Manager',
    ),
    Transaction(
      date: '2023-11-02 14:15',
      type: 'Adjustment',
      item: 'Insulin Glargine',
      quantity: '-2',
      user: 'Store Keeper',
    ),
  ];

  List<Map<String, dynamic>> _itemMasterList = [
    {
      'itemCode': 'ITM001',
      'itemName': 'Paracetamol 500mg',
      'manufacturer': 'PharmaCorp',
      'type': 'Drug',
      'category': 'Analgesic',
      'unit': 'Tablet',
      'storage': 'RT',
      'stock': 5000,
      'status': 'Active',
    },
    {
      'itemCode': 'ITM002',
      'itemName': 'Insulin Glargine',
      'manufacturer': 'BioMed',
      'type': 'Drug',
      'category': 'Antidiabetic',
      'unit': 'Vial',
      'storage': '2-8°C',
      'stock': 120,
      'status': 'Active',
    },
    {
      'itemCode': 'ITM003',
      'itemName': 'Surgical Gloves',
      'manufacturer': 'SafeHands',
      'type': 'Consumable',
      'category': 'Surgical',
      'unit': 'Box',
      'storage': 'RT',
      'stock': 50,
      'status': 'Low Stock',
    },
  ];

  ItemMasterFilter _itemMasterFilter = const ItemMasterFilter();
  String _itemSearchQuery = '';
  VendorFilter _vendorFilter = const VendorFilter();
  String _vendorSearchQuery = '';
  GRNFilter _grnFilter = const GRNFilter();
  String _grnSearchQuery = '';
  StorageLocationFilter _storageLocationFilter = const StorageLocationFilter();
  String _storageLocationSearchQuery = '';

  // Traceability filter state
  TraceabilityFilter _traceabilityFilter = const TraceabilityFilter();
  String _traceabilitySearchQuery = '';

  List<User> _usersList = [
    User(
      id: 'local-1',
      name: 'Admin User',
      email: 'admin@hospital.com',
      role: 'Administrator',
      status: 'Active',
      lastLogin: '2023-11-21 09:00',
      password: 'secret123',
    ),
    User(
      id: 'local-2',
      name: 'Dr. Sarah Smith',
      email: 'sarah.smith@hospital.com',
      role: 'Requester',
      status: 'Active',
      lastLogin: '2023-11-20 14:30',
      password: 'password1',
    ),
    User(
      id: 'local-3',
      name: 'John Store',
      email: 'john.store@hospital.com',
      role: 'Store Keeper',
      status: 'Active',
      lastLogin: '2023-11-21 08:15',
      password: 'storePass',
    ),
    User(
      id: 'local-4',
      name: 'Jane Procurement',
      email: 'jane.proc@hospital.com',
      role: 'Procurement Officer',
      status: 'Active',
      lastLogin: '2023-11-19 16:45',
      password: 'procure@123',
    ),
  ];

  String _selectedNavItem = 'Dashboard';
  // Navigator key for the main dashboard content area so the sidebar stays static
  final GlobalKey<NavigatorState> contentNavigatorKey =
      GlobalKey<NavigatorState>();
  bool _showAddUserForm = false;
  bool _showAddItemSidebar = false;
  bool _showAddLocationSidebar = false;
  NewUserForm _newUserForm = NewUserForm();
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _rolesList = [];
  final List<String> _defaultRoles = [
    'Administrator',
    'Requester',
    'Store Keeper',
    'Procurement Officer',
  ];

  // Start with an empty vendor list; vendors will be loaded/saved dynamically
  List<Map<String, dynamic>> _vendors = [];

  final List<VendorFormSection> _vendorSections = [
    VendorFormSection(
      id: 'company',
      title: 'COMPANY INFORMATION',
      fields: [
        VendorFormField(
          id: 'vendor_name',
          label: 'Vendor Name',
          required: true,
        ),
        VendorFormField(
          id: 'vendor_category',
          label: 'Vendor Category',
          required: true,
          type: VendorFieldType.dropdown,
          options: [
            'Medical Supplies',
            'Pharmaceuticals',
            'Consumables',
            'Equipment',
          ],
        ),
        VendorFormField(id: 'tax_id', label: 'Tax ID / GSTIN'),
        VendorFormField(id: 'website', label: 'Website'),
        VendorFormField(id: 'phone', label: 'Phone Number', required: true),
      ],
    ),
    VendorFormSection(
      id: 'contact',
      title: 'CONTACT PERSON',
      fields: [
        VendorFormField(
          id: 'contact_name',
          label: 'Contact Name',
          required: true,
        ),
        VendorFormField(
          id: 'contact_email',
          label: 'Email Address',
          required: true,
        ),
        VendorFormField(
          id: 'address',
          label: 'Address',
          type: VendorFieldType.textarea,
        ),
      ],
    ),
    VendorFormSection(
      id: 'financial',
      title: 'FINANCIAL & COMPLIANCE',
      fields: [
        VendorFormField(
          id: 'payment_terms',
          label: 'Payment Terms',
          type: VendorFieldType.dropdown,
          options: ['Net 30', 'Net 45', 'Net 60', 'Advance'],
        ),
        VendorFormField(id: 'bank_name', label: 'Bank Name'),
        VendorFormField(id: 'account_number', label: 'Account Number'),
        VendorFormField(id: 'compliance_docs', label: 'Compliance Documents'),
      ],
    ),
  ];

  final Map<String, bool> _vendorSectionsExpanded = {
    'company': true,
    'contact': true,
    'financial': true,
  };

  // PR / PO / GRN tables start empty and are filled dynamically
  List<Map<String, dynamic>> _purchaseRequisitions = [];
  List<Map<String, dynamic>> _purchaseOrders = [];
  List<GoodsReceipt> _goodsReceipts = [];
  final Map<String, String> _vendorFieldValues = {};

  final List<dashboard_feature_models.InventoryQuickAction> _inventoryActions = const [
    dashboard_feature_models.InventoryQuickAction(
      title: 'Start Audit',
      icon: Icons.assignment_outlined,
      iconColor: Color(0xFF2563EB),
      backgroundColor: Color(0xFFE0ECFF),
      navTarget: 'Stock Audits',
    ),
    dashboard_feature_models.InventoryQuickAction(
      title: 'Adjustment',
      icon: Icons.autorenew,
      iconColor: Color(0xFF111827),
      backgroundColor: Color(0xFFECECEC),
      navTarget: 'Stock Adjustment',
    ),
    dashboard_feature_models.InventoryQuickAction(
      title: 'Internal Transfer',
      icon: Icons.compare_arrows,
      iconColor: Color(0xFF1D4ED8),
      backgroundColor: Color(0xFFE0ECFF),
      navTarget: 'Internal Transfers',
    ),
    dashboard_feature_models.InventoryQuickAction(
      title: 'Branch Transfer',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFF7C3AED),
      backgroundColor: Color(0xFFEDE9FE),
      navTarget: 'Branch Transfers',
    ),
    dashboard_feature_models.InventoryQuickAction(
      title: 'Return to Vendor',
      icon: Icons.undo,
      iconColor: Color(0xFF111827),
      backgroundColor: Color(0xFFECECEC),
      navTarget: 'Stock Returns',
    ),
    dashboard_feature_models.InventoryQuickAction(
      title: 'Consumption',
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFF047857),
      backgroundColor: Color(0xFFDCFCE7),
      navTarget: 'Internal Consumption',
    ),
  ];

  // Dashboard/stock tables also start empty and are filled dynamically
  List<InventoryAudit> _recentAudits = [];
  List<InventoryAdjustment> _recentAdjustments = [];
  List<StockAuditRecord> _stockAudits = [];
  List<StockTransferRecord> _stockTransfers = [];
  List<BranchTransferRecord> _branchTransfers = [];
  List<StockReturnRecord> _stockReturns = [];
  List<InternalConsumptionRecord> _internalConsumptions = [];
  List<StorageLocation> _storageLocations = [];

  // Traceability and approvals start empty; populated when real data is available
  final List<TraceabilityRecord> _traceabilityRecords = const [];
  List<ApprovalWorkflowItem> _approvalWorkflows = [];

  final List<ReportSummary> _reportSummaries = const [
    ReportSummary(label: 'LOW STOCK ITEMS', value: '1'),
    ReportSummary(label: 'PENDING APPROVALS', value: '3'),
    ReportSummary(label: 'ACTIVE VENDORS', value: '2'),
    ReportSummary(label: 'TOTAL PO VALUE', value: '\$6,200'),
  ];

  final List<ReportCategory> _reportCategories = const [
    ReportCategory(
      groupTitle: 'Inventory Reports',
      description: 'Real-time stock insights',
      reports: [
        ReportDownload(
          title: 'Current Stock Status',
          subtitle: 'Real-time stock levels and value',
        ),
        ReportDownload(
          title: 'Low Stock & Reorder',
          subtitle: 'Items below minimum level',
        ),
        ReportDownload(
          title: 'Expiry Analysis',
          subtitle: 'Items expiring in next 30/60/90 days',
        ),
        ReportDownload(
          title: 'Stock Movement History',
          subtitle: 'In/Out flow per item',
        ),
      ],
    ),
    ReportCategory(
      groupTitle: 'Procurement Reports',
      description: 'Fulfillment KPIs',
      reports: [
        ReportDownload(
          title: 'Purchase Order Summary',
          subtitle: 'PO status and fulfillment rates',
        ),
        ReportDownload(
          title: 'Vendor Performance',
          subtitle: 'Delivery times and quality ratings',
        ),
        ReportDownload(
          title: 'Spending Analysis',
          subtitle: 'Expenditure by category/department',
        ),
      ],
    ),
    ReportCategory(
      groupTitle: 'Audit & Compliance',
      description: 'Governance insights',
      reports: [
        ReportDownload(
          title: 'Audit Discrepancies',
          subtitle: 'Differences found in last audit',
        ),
        ReportDownload(
          title: 'User Activity Log',
          subtitle: 'System access and transaction logs',
        ),
        ReportDownload(
          title: 'Adjustment History',
          subtitle: 'Approved stock adjustments',
        ),
      ],
    ),
  ];
  final List<RoleDefinition> _roleDefinitions = const [
    RoleDefinition(
      name: 'Administrator',
      description: 'Full access to all modules',
      usersAssigned: 1,
    ),
    RoleDefinition(
      name: 'Store Keeper',
      description: 'Manage Inventory, GRN, and Adjustments',
      usersAssigned: 3,
    ),
    RoleDefinition(
      name: 'Procurement Officer',
      description: 'Manage Vendors, POs, and Contracts',
      usersAssigned: 2,
    ),
    RoleDefinition(
      name: 'Requester',
      description: 'Can create Purchase Requisitions only',
      usersAssigned: 15,
    ),
  ];

  SystemConfiguration _systemConfiguration = SystemConfiguration(
    organizationName: 'City General Hospital',
    currency: 'USD (\$)',
    timeZone: 'UTC',
    emailAlerts: true,
    lowStockWarnings: true,
  );

  DashboardSummary get summary => _summary;
  List<CategoryInventory> get inventoryByCategory => _inventoryByCategory;
  StockStatus get stockStatus => _stockStatus;
  PurchaseOrderStatus get poStatus => _poStatus;
  List<Transaction> get transactions => _transactions;
  List<Map<String, dynamic>> get itemMasterList => _itemMasterList;
  List<Map<String, dynamic>> get filteredItemMasterList =>
      _itemMasterList.where(_applyItemMasterFilters).toList();
  ItemMasterFilter get itemMasterFilter => _itemMasterFilter;
  String get itemSearchQuery => _itemSearchQuery;
  List<String> get itemMasterStatuses =>
      _itemMasterList.map((e) => (e['status'] ?? '').toString()).where((s) => s.isNotEmpty).toSet().toList()..sort();
  List<String> get itemMasterCategories =>
      _itemMasterList.map((e) => (e['category'] ?? '').toString()).where((s) => s.isNotEmpty).toSet().toList()..sort();
  List<String> get itemMasterTypes =>
      _itemMasterList.map((e) => (e['type'] ?? '').toString()).where((s) => s.isNotEmpty).toSet().toList()..sort();
  List<User> get usersList => _usersList;
  String get selectedNavItem => _selectedNavItem;
  bool get showAddUserForm => _showAddUserForm;
  bool get showAddItemSidebar => _showAddItemSidebar;
  bool get showAddLocationSidebar => _showAddLocationSidebar;

  // Sidebar visibility state
  bool _sidebarVisible = true;
  bool get sidebarVisible => _sidebarVisible;

  void toggleSidebar() {
    _sidebarVisible = !_sidebarVisible;
    notifyListeners();
  }

  NewUserForm get newUserForm => _newUserForm;
  List<String> get rolesList => _rolesList;
  List<Map<String, dynamic>> get vendors => List.unmodifiable(_vendors);
  FirebaseService get firebaseService => _firebaseService;
  List<Map<String, dynamic>> get purchaseRequisitions =>
      List.unmodifiable(_purchaseRequisitions);
  List<Map<String, dynamic>> get purchaseOrders => List.unmodifiable(_purchaseOrders);
  List<GoodsReceipt> get goodsReceipts => List.unmodifiable(_goodsReceipts);
  List<dashboard_feature_models.InventoryQuickAction> get inventoryActions =>
      List.unmodifiable(_inventoryActions);
  List<InventoryAudit> get recentAudits => List.unmodifiable(_recentAudits);
  List<InventoryAdjustment> get recentAdjustments =>
      List.unmodifiable(_recentAdjustments);
  List<StorageLocation> get storageLocations =>
      List.unmodifiable(_storageLocations);
  List<TraceabilityRecord> get traceabilityRecords =>
      List.unmodifiable(_traceabilityRecords);
  List<ApprovalWorkflowItem> get approvalWorkflows =>
      List.unmodifiable(_approvalWorkflows);

  /// Real-time approvals stream derived from PR documents in the
  /// Procurements collection.
  ///
  /// - For each PR we create a "Purchase Requisition" item.
  /// - If that PR has attached PO fields (poStatus, poId, etc.), we also
  ///   create a "Purchase Order" item. Both share the same PR document
  ///   ID so approvals can update the same document in Firebase.
  Stream<List<ApprovalWorkflowItem>> get approvalWorkflowsStream =>
      _firebaseService.getPRsStream().map((prsList) {
        print(
          'DEBUG approvalWorkflowsStream: Received ${prsList.length} PRs (for PR + PO cards)',
        );

        final now = DateTime.now();
        final items = <ApprovalWorkflowItem>[];

        for (var i = 0; i < prsList.length; i++) {
          final pr = prsList[i];
          final index = i + 1;

          // Resolve PR date
          String dateString;
          if (pr['date'] != null && pr['date'] is String) {
            dateString = pr['date'] as String;
          } else if (pr['createdAt'] != null) {
            try {
              if (pr['createdAt'] is Timestamp) {
                final timestamp = pr['createdAt'] as Timestamp;
                final date = timestamp.toDate();
                dateString =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              } else {
                dateString =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
              }
            } catch (e) {
              dateString =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
            }
          } else {
            dateString =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          }

          // Format PR ID as "AP-001", "AP-002", etc.
          final prId = (pr['id'] as String?) ?? '';
          final formattedPrId = prId.isNotEmpty
              ? (prId.startsWith('PR-')
                  ? prId.replaceFirst('PR-', 'AP-')
                  : prId.startsWith('AP-')
                      ? prId
                      : 'AP-$prId')
              : 'AP-${index.toString().padLeft(3, '0')}';

          final prDocumentId = pr['documentId'] as String? ??
              pr['id'] as String? ??
              '';

          // 1) PR approval item
          items.add(
            ApprovalWorkflowItem(
              priority: (pr['priority'] as String?) ?? 'Routine',
              id: formattedPrId,
              date: dateString,
              title: 'Purchase Requisition',
              description: (pr['department'] as String?) ??
                  (pr['description'] as String?) ??
                  (pr['purpose'] as String?) ??
                  'Purchase Requisition',
              requestedBy: (pr['requestedBy'] as String?) ??
                  (pr['createdBy'] as String?) ??
                  'Unknown',
              status: (pr['status'] as String?) ?? 'Pending',
              prDocumentId: prDocumentId,
            ),
          );

          // 2) Optional PO approval item, if PR has attached PO fields
          final poStatus = (pr['poStatus'] as String?) ?? '';
          if (poStatus.isNotEmpty) {
            final poIdField =
                (pr['poId'] as String?) ?? (pr['poNumber'] as String?) ?? prId;
            final formattedPoId = poIdField.isNotEmpty
                ? (poIdField.startsWith('PO-') ? poIdField : 'PO-$poIdField')
                : 'PO-${index.toString().padLeft(3, '0')}';

            final poDate = (pr['poDate'] as String?) ?? dateString;
            final poVendor = (pr['poVendor'] as String?) ??
                (pr['vendor'] as String?) ??
                '';

            items.add(
              ApprovalWorkflowItem(
                priority: (pr['priority'] as String?) ?? 'Routine',
                id: formattedPoId,
                date: poDate,
                title: 'Purchase Order',
                description: poVendor.isNotEmpty ? poVendor : 'Purchase Order',
                requestedBy: (pr['createdBy'] as String?) ??
                    (pr['requestedBy'] as String?) ??
                    'Unknown',
                status: poStatus,
                // For POs, this is still the PR document ID, since PO
                // fields live on the same document.
                prDocumentId: prDocumentId,
              ),
            );
          }
        }

        return items;
      });
  List<ReportSummary> get reportSummaries =>
      List.unmodifiable(_reportSummaries);
  List<ReportCategory> get reportCategories =>
      List.unmodifiable(_reportCategories);
  List<RoleDefinition> get roleDefinitions =>
      List.unmodifiable(_roleDefinitions);
  SystemConfiguration get systemConfiguration =>
      _systemConfiguration.copyWith();
  List<StockAuditRecord> get stockAudits => List.unmodifiable(_stockAudits);
  List<StockTransferRecord> get stockTransfers =>
      List.unmodifiable(_stockTransfers);
  List<BranchTransferRecord> get branchTransfers =>
      List.unmodifiable(_branchTransfers);
  List<StockReturnRecord> get stockReturns =>
      List.unmodifiable(_stockReturns);
  List<InternalConsumptionRecord> get internalConsumptions =>
      List.unmodifiable(_internalConsumptions);
  List<VendorFormSection> get vendorSections =>
      _vendorSections.map((section) => section.copyWith()).toList();
  Map<String, bool> get vendorSectionsExpanded =>
      Map.unmodifiable(_vendorSectionsExpanded);
  String vendorFieldValue(String fieldId) => _vendorFieldValues[fieldId] ?? '';

  bool _applyItemMasterFilters(Map<String, dynamic> item) {
    final query = _itemSearchQuery.trim().toLowerCase();
    final itemCode = (item['itemCode'] ?? '').toString().toLowerCase();
    final itemName = (item['itemName'] ?? '').toString().toLowerCase();
    final manufacturer = (item['manufacturer'] ?? '').toString().toLowerCase();
    
    final matchesQuery =
        query.isEmpty ||
        itemCode.contains(query) ||
        itemName.contains(query) ||
        manufacturer.contains(query);

    final nameFilter = _itemMasterFilter.nameQuery?.trim().toLowerCase();
    final matchesName =
        nameFilter == null ||
        nameFilter.isEmpty ||
        itemName.contains(nameFilter);

    return matchesQuery && matchesName && _itemMasterFilter.matchesMap(item);
  }

  void updateItemMasterFilter(ItemMasterFilter filter) {
    _itemMasterFilter = filter;
    notifyListeners();
  }

  void resetItemMasterFilter() {
    _itemMasterFilter = const ItemMasterFilter();
    notifyListeners();
  }

  void updateItemSearchQuery(String query) {
    _itemSearchQuery = query;
    notifyListeners();
  }

  Future<String> exportItemMasterCsv() async {
    final rows = <List<String>>[
      [
        'Item Code',
        'Item Name',
        'Manufacturer',
        'Type',
        'Category',
        'Unit',
        'Stock',
        'Status',
      ],
      ...filteredItemMasterList.map(
        (item) => [
          (item['itemCode'] ?? '').toString(),
          (item['itemName'] ?? '').toString(),
          (item['manufacturer'] ?? '').toString(),
          (item['type'] ?? '').toString(),
          (item['category'] ?? '').toString(),
          (item['unit'] ?? '').toString(),
          (item['stock'] ?? 0).toString(),
          (item['status'] ?? '').toString(),
        ],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    final fileName = 'item_master_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  String _escapeCsv(String value) {
    final safe = value.replaceAll('"', '""');
    return '"$safe"';
  }

  // Vendor filter methods
  List<Map<String, dynamic>> get filteredVendorList =>
      _vendors.where(_applyVendorFilters).toList();
  VendorFilter get vendorFilter => _vendorFilter;
  String get vendorSearchQuery => _vendorSearchQuery;
  List<String> get vendorStatuses =>
      _vendors.map((e) => (e['status'] ?? '').toString()).where((s) => s.isNotEmpty).toSet().toList()..sort();
  List<String> get vendorCategories =>
      _vendors.map((e) => (e['category'] ?? '').toString()).where((s) => s.isNotEmpty).toSet().toList()..sort();

  bool _applyVendorFilters(Map<String, dynamic> vendor) {
    final query = _vendorSearchQuery.trim().toLowerCase();
    final name = (vendor['name'] ?? '').toString().toLowerCase();
    final category = (vendor['category'] ?? '').toString().toLowerCase();
    final contactName = (vendor['contactName'] ?? '').toString().toLowerCase();
    
    final matchesQuery =
        query.isEmpty ||
        name.contains(query) ||
        category.contains(query) ||
        contactName.contains(query);

    return matchesQuery && _vendorFilter.matchesMap(vendor);
  }

  void updateVendorFilter(VendorFilter filter) {
    _vendorFilter = filter;
    notifyListeners();
  }

  void resetVendorFilter() {
    _vendorFilter = const VendorFilter();
    notifyListeners();
  }

  void updateVendorSearchQuery(String query) {
    _vendorSearchQuery = query;
    notifyListeners();
  }

  Future<String> exportVendorsCsv() async {
    final rows = <List<String>>[
      ['Name', 'Category', 'Contact Name', 'Email', 'Phone', 'Status'],
      ...filteredVendorList.map(
        (v) => [
          (v['name'] ?? '').toString(),
          (v['category'] ?? '').toString(),
          (v['contactName'] ?? '').toString(),
          (v['email'] ?? '').toString(),
          (v['phone'] ?? '').toString(),
          (v['status'] ?? '').toString(),
        ],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    final fileName = 'vendors_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  // GRN filter methods
  List<GoodsReceipt> get filteredGRNList =>
      _goodsReceipts.where(_applyGRNFilters).toList();
  GRNFilter get grnFilter => _grnFilter;
  String get grnSearchQuery => _grnSearchQuery;
  List<String> get grnStatuses =>
      _goodsReceipts.map((e) => e.status).toSet().toList()..sort();
  List<String> get grnVendors =>
      _goodsReceipts.map((e) => e.vendor).toSet().toList()..sort();
  List<String> get grnPOReferences =>
      _goodsReceipts.map((e) => e.poReference).toSet().toList()..sort();

  bool _applyGRNFilters(GoodsReceipt grn) {
    final query = _grnSearchQuery.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        grn.grnId.toLowerCase().contains(query) ||
        grn.poReference.toLowerCase().contains(query) ||
        grn.vendor.toLowerCase().contains(query) ||
        grn.receivedBy.toLowerCase().contains(query);
    return matchesQuery && _grnFilter.matches(grn);
  }

  void updateGRNFilter(GRNFilter filter) {
    _grnFilter = filter;
    notifyListeners();
  }

  void resetGRNFilter() {
    _grnFilter = const GRNFilter();
    notifyListeners();
  }

  void updateGRNSearchQuery(String query) {
    _grnSearchQuery = query;
    notifyListeners();
  }

  Future<String> exportGRNCsv() async {
    final rows = <List<String>>[
      [
        'GRN ID',
        'PO Reference',
        'Vendor',
        'Date Received',
        'Received By',
        'Status',
      ],
      ...filteredGRNList.map(
        (grn) => [
          grn.grnId,
          grn.poReference,
          grn.vendor,
          grn.dateReceived,
          grn.receivedBy,
          grn.status,
        ],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    final fileName =
        'grn_receiving_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  // Storage Location filter methods
  List<StorageLocation> get filteredStorageLocationList =>
      _storageLocations.where(_applyStorageLocationFilters).toList();
  StorageLocationFilter get storageLocationFilter => _storageLocationFilter;
  String get storageLocationSearchQuery => _storageLocationSearchQuery;
  List<String> get storageLocationStatuses =>
      _storageLocations.map((e) => e.status).toSet().toList()..sort();
  List<String> get storageLocationTypes =>
      _storageLocations.map((e) => e.type).toSet().toList()..sort();
  List<String> get storageLocationParents =>
      _storageLocations
          .map((e) => e.parentLocation)
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  // Flag to avoid reloading inventory-control related data multiple times
  bool _inventoryControlDataLoaded = false;

  bool get inventoryControlDataLoaded => _inventoryControlDataLoaded;

  bool _applyStorageLocationFilters(StorageLocation location) {
    final query = _storageLocationSearchQuery.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        location.id.toLowerCase().contains(query) ||
        location.name.toLowerCase().contains(query) ||
        location.type.toLowerCase().contains(query) ||
        location.parentLocation.toLowerCase().contains(query);
    return matchesQuery && _storageLocationFilter.matches(location);
  }

  void updateStorageLocationFilter(StorageLocationFilter filter) {
    _storageLocationFilter = filter;
    notifyListeners();
  }

  void resetStorageLocationFilter() {
    _storageLocationFilter = const StorageLocationFilter();
    notifyListeners();
  }

  void updateStorageLocationSearchQuery(String query) {
    _storageLocationSearchQuery = query;
    notifyListeners();
  }

  Future<String> exportStorageLocationsCsv() async {
    final rows = <List<String>>[
      [
        'ID',
        'Name',
        'Type',
        'Parent Location',
        'Capacity',
        'Status',
        'Manager',
      ],
      ...filteredStorageLocationList.map(
        (loc) => [
          loc.id,
          loc.name,
          loc.type,
          loc.parentLocation,
          loc.capacity.toString(),
          loc.status,
          loc.manager,
        ],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    final fileName =
        'storage_locations_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  // Traceability filter getters
  List<TraceabilityRecord> get filteredTraceabilityList =>
      _traceabilityRecords.where(_applyTraceabilityFilters).toList();
  TraceabilityFilter get traceabilityFilter => _traceabilityFilter;
  String get traceabilitySearchQuery => _traceabilitySearchQuery;
  List<String> get traceabilityTypes =>
      _traceabilityRecords.map((e) => e.type).toSet().toList()..sort();
  List<String> get traceabilityUsers =>
      _traceabilityRecords.map((e) => e.user).toSet().toList()..sort();
  List<String> get traceabilityLocations =>
      _traceabilityRecords.map((e) => e.location).toSet().toList()..sort();

  bool _applyTraceabilityFilters(TraceabilityRecord record) {
    final query = _traceabilitySearchQuery.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        record.reference.toLowerCase().contains(query) ||
        record.itemDetails.toLowerCase().contains(query) ||
        record.type.toLowerCase().contains(query) ||
        record.user.toLowerCase().contains(query);
    return matchesQuery && _traceabilityFilter.matches(record);
  }

  void updateTraceabilityFilter(TraceabilityFilter filter) {
    _traceabilityFilter = filter;
    notifyListeners();
  }

  void resetTraceabilityFilter() {
    _traceabilityFilter = const TraceabilityFilter();
    notifyListeners();
  }

  void updateTraceabilitySearchQuery(String query) {
    _traceabilitySearchQuery = query;
    notifyListeners();
  }

  Future<String> exportTraceabilityCsv() async {
    final rows = <List<String>>[
      [
        'Date & Time',
        'Type',
        'Reference',
        'Item Details',
        'Quantity',
        'User',
        'Location',
      ],
      ...filteredTraceabilityList.map(
        (record) => [
          record.dateTime,
          record.type,
          record.reference,
          record.itemDetails,
          record.quantity,
          record.user,
          record.location,
        ],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    final fileName =
        'traceability_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  void setSelectedNavItem(String item) {
    _selectedNavItem = item;
    notifyListeners();
  }

  void showAddUserFormDialog() {
    _showAddUserForm = true;
    _newUserForm = NewUserForm();
    notifyListeners();
  }

  void hideAddUserFormDialog() {
    _showAddUserForm = false;
    _newUserForm = NewUserForm();
    notifyListeners();
  }

  void openAddItemSidebar() {
    _showAddItemSidebar = true;
    notifyListeners();
  }

  void closeAddItemSidebar() {
    _showAddItemSidebar = false;
    notifyListeners();
  }

  void openAddLocationSidebar() {
    _showAddLocationSidebar = true;
    notifyListeners();
  }

  void closeAddLocationSidebar() {
    _showAddLocationSidebar = false;
    notifyListeners();
  }


  void updateNewUserForm({
    String? fullName,
    String? email,
    String? role,
    String? status,
    String? password,
  }) {
    if (fullName != null) _newUserForm.fullName = fullName;
    if (email != null) _newUserForm.email = email;
    if (role != null) _newUserForm.role = role;
    if (status != null) _newUserForm.status = status;
    if (password != null) _newUserForm.password = password;
    notifyListeners();
  }

  Future<void> createUser() async {
    if (_newUserForm.fullName.isEmpty ||
        _newUserForm.email.isEmpty ||
        _newUserForm.password.length < 6) {
      throw Exception(
        'Please fill all fields and use a password with at least 6 characters.',
      );
    }

    try {
      final now = DateTime.now();
      final formattedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final newUser = User(
        name: _newUserForm.fullName,
        email: _newUserForm.email,
        role: _newUserForm.role,
        status: _newUserForm.status,
        lastLogin: formattedDate,
        password: _newUserForm.password,
      );

      await _firebaseService.createAuthUser(newUser.email, newUser.password);

      // Always add to local list for immediate UI update
      _usersList.add(newUser);

      // Try to save to Firebase (non-blocking)
      try {
        await _firebaseService.saveUser(newUser);
      } catch (e) {
        // Handle error - Firebase save failed but user is still added locally
        print('Error saving user to Firebase: $e');
      }

      hideAddUserFormDialog();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Map<String, bool> _emptyPermissionsMap() {
    final map = <String, bool>{};
    for (final item in NavigationItems.sidebarItems) {
      map[item['title'] as String] = false;
    }
    return map;
  }

  Map<String, String> _defaultPermissionLabels() {
    final map = <String, String>{};
    for (final item in NavigationItems.sidebarItems) {
      final title = item['title'] as String;
      map[title] = title;
    }
    return map;
  }

  void _ensureSelectedRoleValid() {
    if (_rolesList.isEmpty) {
      _newUserForm.role = '';
    } else if (!_rolesList.contains(_newUserForm.role)) {
      _newUserForm.role = _rolesList.first;
    }
  }

  Future<void> loadRoles() async {
    try {
      _rolesList = await _firebaseService.fetchRoles();
      if (_rolesList.isEmpty) {
        for (final role in _defaultRoles) {
          await _firebaseService.createRole(
            role,
            _emptyPermissionsMap(),
            _defaultPermissionLabels(),
          );
        }
        _rolesList = await _firebaseService.fetchRoles();
      }
      _ensureSelectedRoleValid();
      notifyListeners();
    } catch (e) {
      print('Error loading roles: $e');
      if (_rolesList.isEmpty) {
        _rolesList = List.from(_defaultRoles);
        _ensureSelectedRoleValid();
        notifyListeners();
      }
    }
  }

  Future<void> addRole(String role) async {
    final trimmed = role.trim();
    if (trimmed.isNotEmpty && !_rolesList.contains(trimmed)) {
      _rolesList.add(trimmed);
      _rolesList.sort();
      _ensureSelectedRoleValid();
      notifyListeners();
      try {
        await _firebaseService.createRole(
          trimmed,
          _emptyPermissionsMap(),
          _defaultPermissionLabels(),
        );
      } catch (e) {
        print('Error saving role to Firebase: $e');
      }
    }
  }

  Future<void> updateRole(int index, String newRole) async {
    final trimmed = newRole.trim();
    if (trimmed.isNotEmpty &&
        index >= 0 &&
        index < _rolesList.length &&
        (!_rolesList.contains(trimmed) || _rolesList[index] == trimmed)) {
      final oldName = _rolesList[index];
      _rolesList[index] = trimmed;
      _rolesList.sort();
      _ensureSelectedRoleValid();
      notifyListeners();
      try {
        if (oldName != trimmed) {
          await _firebaseService.renameRole(oldName, trimmed);
        }
      } catch (e) {
        print('Error updating role in Firebase: $e');
      }
    }
  }

  Future<void> deleteRole(int index) async {
    if (index >= 0 && index < _rolesList.length) {
      final roleName = _rolesList[index];
      _rolesList.removeAt(index);
      _ensureSelectedRoleValid();
      notifyListeners();
      try {
        await _firebaseService.deleteRole(roleName);
      } catch (e) {
        print('Error deleting role from Firebase: $e');
      }
    }
  }

  Future<void> updateUserRole(User user, String newRole) async {
    final trimmedRole = newRole.trim();
    if (trimmedRole.isEmpty) return;

    final localIndex = _usersList.indexWhere((u) => u.email == user.email);
    if (localIndex != -1) {
      final existing = _usersList[localIndex];
      _usersList[localIndex] = User(
        id: existing.id,
        name: existing.name,
        email: existing.email,
        role: trimmedRole,
        status: existing.status,
        lastLogin: existing.lastLogin,
        password: existing.password,
      );
      notifyListeners();
    }

    if (user.id.isEmpty) return;

    try {
      await _firebaseService.updateUserRole(user.id, trimmedRole);
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> deleteUser(User user) async {
    _usersList.removeWhere((u) => u.email == user.email);
    notifyListeners();
    if (user.id.isEmpty) {
      return;
    }
    try {
      await _firebaseService.deleteUser(user.id);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  void toggleVendorSection(String sectionId) {
    if (_vendorSectionsExpanded.containsKey(sectionId)) {
      _vendorSectionsExpanded[sectionId] = !_vendorSectionsExpanded[sectionId]!;
      notifyListeners();
    }
  }

  void updateVendorField(String fieldId, String value) {
    _vendorFieldValues[fieldId] = value;
  }

  void resetVendorFormFields() {
    _vendorFieldValues.clear();
    for (final section in _vendorSections) {
      for (final field in section.fields) {
        if (field.type == VendorFieldType.dropdown &&
            field.options.isNotEmpty) {
          _vendorFieldValues[field.id] = field.options.first;
        }
      }
    }
    _vendorSectionsExpanded.updateAll((key, value) => true);
    notifyListeners();
  }

  Future<void> addStorageLocation({
    required String name,
    required String type,
    required String parentLocation,
    required int capacity,
    required String status,
    String manager = '',
    String description = '',
  }) async {
    // Save to Firestore
    try {
      await _firebaseService.saveStorageLocation(
        name: name,
        type: type,
        parentLocation: parentLocation,
        capacity: capacity,
        status: status,
        manager: manager,
        description: description,
      );
    } catch (e) {
      print('Error saving location to Firestore: $e');
      // Continue with local save even if Firestore fails
    }

    // Also add to local list for immediate UI update
    final nextNumber = _storageLocations.length + 1;
    final id = 'LOC${nextNumber.toString().padLeft(3, '0')}';
    final location = StorageLocation(
      id: id,
      name: name,
      type: type,
      parentLocation: parentLocation,
      capacity: capacity,
      status: status,
      manager: manager,
      description: description,
    );
    _storageLocations = [..._storageLocations, location];
    notifyListeners();
  }

  void updateSystemConfiguration(SystemConfiguration config) {
    _systemConfiguration = config;
    notifyListeners();
  }

  Future<void> addVendorFromFields() async {
    final vendorName = vendorFieldValue('vendor_name');
    final contactName = vendorFieldValue('contact_name');
    final phone = vendorFieldValue('phone');
    final email = vendorFieldValue('contact_email');
    if (vendorName.isEmpty ||
        contactName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty) {
      throw Exception('Please fill in all required fields.');
    }

    // Collect all vendor field data for Firestore
    final vendorData = <String, dynamic>{};
    for (final section in _vendorSections) {
      for (final field in section.fields) {
        final value = vendorFieldValue(field.id);
        if (value.isNotEmpty) {
          vendorData[field.id] = value;
        }
      }
    }

    // Add vendor name explicitly
    vendorData['vendor_name'] = vendorName;
    vendorData['name'] = vendorName;

    // Save to Firestore
    try {
      await _firebaseService.saveVendor(vendorData);
    } catch (e) {
      print('Error saving vendor to Firestore: $e');
      // Continue with local save even if Firestore fails
    }

    final vendorMap = {
      'id': 'VND-${DateTime.now().millisecondsSinceEpoch}',
      'name': vendorName,
      'category': vendorFieldValue('vendor_category').isNotEmpty
          ? vendorFieldValue('vendor_category')
          : 'General',
      'contactName': contactName,
      'email': email,
      'phone': phone,
      'status': 'Pending',
    };
    _vendors = [..._vendors, vendorMap];
    notifyListeners();
    resetVendorFormFields();
  }

  void updateVendorSection(
    String sectionId, {
    String? title,
    List<VendorFormField>? fields,
  }) {
    final index = _vendorSections.indexWhere((s) => s.id == sectionId);
    if (index == -1) return;
    final current = _vendorSections[index];
    final newFields = fields ?? current.fields;

    final oldIds = current.fields.map((f) => f.id).toSet();
    final newIds = newFields.map((f) => f.id).toSet();
    for (final removed in oldIds.difference(newIds)) {
      _vendorFieldValues.remove(removed);
    }

    _vendorSections[index] = current.copyWith(
      title: title ?? current.title,
      fields: newFields.map((f) => f.copyWith()).toList(),
    );
    notifyListeners();
  }

  void deleteVendorSection(String sectionId) {
    if (_vendorSections.length <= 1) return;
    final index = _vendorSections.indexWhere((s) => s.id == sectionId);
    if (index == -1) return;
    final section = _vendorSections.removeAt(index);
    for (final field in section.fields) {
      _vendorFieldValues.remove(field.id);
    }
    _vendorSectionsExpanded.remove(sectionId);
    notifyListeners();
  }

  // Delete old Inventory Management collection
  Future<void> deleteOldInventoryManagement() async {
    try {
      await _firebaseService.deleteInventoryManagement();
    } catch (e) {
      print('Error deleting old Inventory Management: $e');
    }
  }

  // Load items from Firestore
  Future<void> loadVendors() async {
    try {
      final vendorsData = await _firebaseService.fetchVendors();
      if (vendorsData.isNotEmpty) {
        // Normalize every vendor loaded from Firebase so UI widgets
        // (like VendorCard) always receive consistent keys.
        _vendors = vendorsData.map(_normalizeVendorData).toList();
      } else {
        _vendors = [];
      }
      notifyListeners();
      print('Vendors loaded successfully: ${_vendors.length} vendors');
    } catch (e) {
      print('Error loading vendors: $e');
      // Keep empty list on error
      _vendors = [];
    }
  }

  Future<void> loadItems() async {
    try {
      final itemsData = await _firebaseService.fetchItems();
      _itemMasterList = itemsData.map((data) {
        // Normalize field names first
        final normalized = {
          'id': data['id'],
          'itemCode': data['itemCode'] ?? data['item_code'] ?? '',
          'itemName': data['itemName'] ?? data['item_name'] ?? '',
          'manufacturer': data['manufacturer'] ?? '',
          'type': data['itemType'] ?? data['type'] ?? '',
          'category': data['category'] ?? '',
          'unit': data['unitOfMeasure'] ?? data['unit'] ?? '',
          'storage': data['storageConditions'] ?? data['storage'] ?? '',
          'stock': (data['stock'] ?? data['quantity'] ?? 0) is int
              ? (data['stock'] ?? data['quantity'] ?? 0)
              : int.tryParse(
                      (data['stock'] ?? data['quantity'] ?? '0').toString(),
                    ) ??
                  0,
          'status': data['status'] ?? 'Active',
        };
        
        // Exclude keys that we've normalized to prevent overwriting
        final excludedKeys = {
          'id', 'itemCode', 'item_code', 'itemName', 'item_name',
          'manufacturer', 'itemType', 'type', 'category',
          'unitOfMeasure', 'unit', 'storageConditions', 'storage',
          'stock', 'quantity', 'status'
        };
        
        // Get additional fields that weren't normalized
        final additionalData = <String, dynamic>{};
        data.forEach((key, value) {
          if (!excludedKeys.contains(key)) {
            additionalData[key] = value;
          }
        });
        
        // Return normalized values first, then additional fields
        return {
          ...normalized,
          ...additionalData,
        };
      }).toList();
      notifyListeners();
      print('Items loaded successfully: ${_itemMasterList.length} items');
    } catch (e) {
      print('Error loading items: $e');
      // No fallback to local storage - Firebase only
    }
  }

  // Save item to Firestore
  Future<void> saveItem(Map<String, dynamic> itemData) async {
    try {
      // Save to Firestore
      final docId = await _firebaseService.saveItem(itemData);

      // Reload items from Firestore to get the latest data
      await loadItems();

      print('Item saved successfully with ID: $docId');
    } catch (e) {
      print('Error saving item: $e');
      throw Exception('Error saving item: $e');
    }
  }

  // Update item in Firestore
  Future<void> updateItem(String documentId, Map<String, dynamic> itemData) async {
    try {
      await _firebaseService.updateItem(documentId, itemData);
      await loadItems(); // Reload to refresh UI
      print('Item updated successfully');
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Error updating item: $e');
    }
  }

  // Delete item from Firestore
  Future<void> deleteItem(String documentId) async {
    try {
      await _firebaseService.deleteItem(documentId);
      _itemMasterList.removeWhere((item) => item['id'] == documentId);
      notifyListeners();
      print('Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Error deleting item: $e');
    }
  }

  Future<void> saveAudit(Map<String, dynamic> auditData) async {
    try {
      // Save to Firestore if available (fixed path)
      try {
        await _firebaseService.saveStockAudit(auditData);
      } catch (e) {
        print('Error saving audit to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        return int.tryParse(value.toString()) ?? 0;
      }

      final now = DateTime.now();
      final record = StockAuditRecord(
        id: auditData['id'] as String? ??
            'AUD-${DateTime.now().millisecondsSinceEpoch}',
        date: auditData['date'] as String? ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        type: auditData['type'] as String? ??
            auditData['auditType'] as String? ??
            'Systemic',
        auditor: auditData['auditor'] as String? ?? '',
        status: auditData['status'] as String? ?? 'Scheduled',
        discrepancies: _parseInt(auditData['discrepancies']),
      );
      _stockAudits = [record, ..._stockAudits];
      notifyListeners();
      print('Audit saved successfully with ID: ${record.id}');
    } catch (e) {
      print('Error saving audit: $e');
      throw Exception('Error saving audit: $e');
    }
  }

  Future<void> saveInternalTransfer(Map<String, dynamic> transferData) async {
    try {
      // Save to Firestore if available (fixed path)
      try {
        await _firebaseService.saveInternalTransfer(transferData);
      } catch (e) {
        print('Error saving internal transfer to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        return int.tryParse(value.toString()) ?? 0;
      }

      final now = DateTime.now();
      final transfer = StockTransferRecord(
        id: transferData['id'] as String? ??
            'TRF-${DateTime.now().millisecondsSinceEpoch}',
        date: transferData['date'] as String? ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        fromLocation: transferData['fromLocation'] as String? ?? '',
        toLocation: transferData['toLocation'] as String? ?? '',
        quantity: _parseInt(transferData['quantity']),
        status: transferData['status'] as String? ?? 'Pending',
      );
      _stockTransfers = [transfer, ..._stockTransfers];
      notifyListeners();
      print('Transfer saved successfully with ID: ${transfer.id}');
    } catch (e) {
      print('Error saving transfer: $e');
      throw Exception('Error saving transfer: $e');
    }
  }

  Future<void> saveBranchTransfer(Map<String, dynamic> transferData) async {
    try {
      // Save to Firestore if available (fixed path)
      try {
        await _firebaseService.saveBranchTransfer(transferData);
      } catch (e) {
        print('Error saving branch transfer to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        return int.tryParse(value.toString()) ?? 0;
      }

      final now = DateTime.now();
      final transfer = BranchTransferRecord(
        id: transferData['id'] as String? ??
            'IBT-${DateTime.now().millisecondsSinceEpoch}',
        date: transferData['date'] as String? ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        sourceBranch: transferData['sourceBranch'] as String? ?? '',
        destinationBranch: transferData['destinationBranch'] as String? ?? '',
        quantity: _parseInt(transferData['quantity']),
        status: transferData['status'] as String? ?? 'Pending',
      );
      _branchTransfers = [transfer, ..._branchTransfers];
      notifyListeners();
      print('Branch transfer saved successfully with ID: ${transfer.id}');
    } catch (e) {
      print('Error saving branch transfer: $e');
      throw Exception('Error saving branch transfer: $e');
    }
  }

  Future<void> saveStockReturn(Map<String, dynamic> returnData) async {
    try {
      // Save to Firestore if available (fixed path)
      try {
        await _firebaseService.saveStockReturnToVendor(returnData);
      } catch (e) {
        print('Error saving stock return to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        return int.tryParse(value.toString()) ?? 0;
      }

      final now = DateTime.now();
      final record = StockReturnRecord(
        id: returnData['id'] as String? ??
            'RET-${DateTime.now().millisecondsSinceEpoch}',
        date: returnData['date'] as String? ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        vendor: returnData['vendor'] as String? ?? '',
        item: returnData['item'] as String? ?? '',
        quantity: _parseInt(returnData['quantity']),
        reason: returnData['reason'] as String? ??
            returnData['returnType'] as String? ??
            'Damaged',
        status: returnData['status'] as String? ?? 'Pending',
      );
      _stockReturns = [record, ..._stockReturns];
      notifyListeners();
      print('Stock return saved successfully with ID: ${record.id}');
    } catch (e) {
      print('Error saving stock return: $e');
      throw Exception('Error saving stock return: $e');
    }
  }

  Future<void> saveInternalConsumption(Map<String, dynamic> consumptionData) async {
    try {
      // Save to Firestore if available (fixed path)
      try {
        await _firebaseService.saveInternalConsumption(consumptionData);
      } catch (e) {
        print('Error saving internal consumption to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        return int.tryParse(value.toString()) ?? 0;
      }

      final now = DateTime.now();
      final record = InternalConsumptionRecord(
        id: consumptionData['id'] as String? ??
            'CON-${DateTime.now().millisecondsSinceEpoch}',
        date: consumptionData['date'] as String? ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        department: consumptionData['department'] as String? ?? '',
        item: consumptionData['item'] as String? ?? '',
        quantity: _parseInt(consumptionData['quantity']),
        purpose: consumptionData['purpose'] as String? ?? '',
        user: consumptionData['user'] as String? ?? '',
      );
      _internalConsumptions = [record, ..._internalConsumptions];
      notifyListeners();
      print('Internal consumption saved with ID: ${record.id}');
    } catch (e) {
      print('Error saving internal consumption: $e');
      throw Exception('Error saving internal consumption: $e');
    }
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Load approval workflow items from the Purchase Requisition document
  /// stored at /clinics/CLN-0004/branch/BRN-001/Procurements/e7JdRHE9irT96y6GzhCW.
  Future<void> loadApprovalWorkflowsFromFirebase() async {
    try {
      final data = await _firebaseService.fetchApprovalPR();
      final items = <ApprovalWorkflowItem>[];

      if (data != null) {
        final now = DateTime.now();
        final dateString = (data['date'] as String?) ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        items.add(
          ApprovalWorkflowItem(
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
            prDocumentId: (data['id'] as String?) ?? '', // Store original Firebase document ID
          ),
        );
      }

      _approvalWorkflows
        ..clear()
        ..addAll(items);
      notifyListeners();

      print('Approval workflows loaded from Firebase. Count: ${_approvalWorkflows.length}');
    } catch (e) {
      print('Error loading approval workflows from Firebase: $e');
    }
  }

  /// Load vendor data from Firebase (single fixed document) into the local list.
  Future<void> loadVendorsFromFirebase() async {
    // Use the new loadVendors method which fetches all vendors from collection
    await loadVendors();
  }

  // Load all Purchase Requisitions from Firebase
  Future<void> loadPRsFromFirebase() async {
    try {
      final prsData = await _firebaseService.fetchPRs();
      _purchaseRequisitions = prsData;
      notifyListeners();
      print('PRs loaded from Firebase. Count: ${_purchaseRequisitions.length}');
    } catch (e) {
      print('Error loading PRs from Firebase: $e');
    }
  }

  // Load all Goods Receipt Notes from Firebase
  Future<void> loadGRNsFromFirebase() async {
    try {
      final grnsData = await _firebaseService.fetchGRNs();
      _goodsReceipts = grnsData.map((data) {
        return GoodsReceipt(
          grnId: _asString(data['grnId']) ?? _asString(data['id']) ?? '',
          poReference: _asString(data['poReference']) ?? '',
          vendor: _asString(data['vendor']) ?? '',
          dateReceived: _asString(data['dateReceived']) ?? '',
          receivedBy: _asString(data['receivedBy']) ?? '',
          status: _asString(data['status']) ?? 'Pending',
        );
      }).toList();
      notifyListeners();
      print('GRNs loaded from Firebase. Count: ${_goodsReceipts.length}');
    } catch (e) {
      print('Error loading GRNs from Firebase: $e');
    }
  }

  // Load all Stock Audits from Firebase
  Future<void> loadStockAuditsFromFirebase() async {
    try {
      final auditsData = await _firebaseService.fetchStockAudits();
      _stockAudits = auditsData.map((data) {
        return StockAuditRecord(
          id: _asString(data['id']) ?? '',
          date: _asString(data['date']) ?? _asString(data['auditDate']) ?? '',
          type: _asString(data['type']) ?? '',
          auditor: _asString(data['auditor']) ?? '',
          status: _asString(data['status']) ?? 'Pending',
          discrepancies: (data['discrepancies'] ?? 0) is int
              ? (data['discrepancies'] ?? 0) as int
              : int.tryParse((data['discrepancies'] ?? '0').toString()) ?? 0,
        );
      }).toList();
      // Build recent audits list (e.g., latest 5) from the same stock audits
      _recentAudits = _stockAudits
          .take(5)
          .map(
            (audit) => InventoryAudit(
              date: audit.date,
              type: audit.type,
              status: audit.status,
              discrepancies: audit.discrepancies,
            ),
          )
          .toList();
      notifyListeners();
      print('Stock audits loaded from Firebase. Count: ${_stockAudits.length}');
    } catch (e) {
      print('Error loading stock audits from Firebase: $e');
    }
  }

  // Load all Stock Adjustments from Firebase
  Future<void> loadStockAdjustmentsFromFirebase() async {
    try {
      final adjustmentsData = await _firebaseService.fetchStockAdjustments();
      _recentAdjustments = adjustmentsData.map((data) {
        return InventoryAdjustment(
          date: _asString(data['date']) ?? '',
          reason: _asString(data['reason']) ?? '',
          status: _asString(data['status']) ?? 'Pending',
          quantity: (data['quantity'] ?? 0) is int
              ? (data['quantity'] ?? 0).toString()
              : (data['quantity'] ?? '0').toString(),
        );
      }).toList();
      notifyListeners();
      print('Stock adjustments loaded from Firebase. Count: ${_recentAdjustments.length}');
    } catch (e) {
      print('Error loading stock adjustments from Firebase: $e');
    }
  }

  // Load all Internal Transfers from Firebase
  Future<void> loadInternalTransfersFromFirebase() async {
    try {
      final transfersData = await _firebaseService.fetchInternalTransfers();
      _stockTransfers = transfersData.map((data) {
        return StockTransferRecord(
          id: _asString(data['id']) ?? '',
          date: _asString(data['date']) ?? '',
          fromLocation: _asString(data['fromLocation']) ?? '',
          toLocation: _asString(data['toLocation']) ?? '',
          quantity: (data['quantity'] ?? 0) is int
              ? (data['quantity'] ?? 0) as int
              : int.tryParse((data['quantity'] ?? '0').toString()) ?? 0,
          status: _asString(data['status']) ?? 'Pending',
        );
      }).toList();
      notifyListeners();
      print('Internal transfers loaded from Firebase. Count: ${_stockTransfers.length}');
    } catch (e) {
      print('Error loading internal transfers from Firebase: $e');
    }
  }

  // Load all Branch Transfers from Firebase
  Future<void> loadBranchTransfersFromFirebase() async {
    try {
      final transfersData = await _firebaseService.fetchBranchTransfers();
      _branchTransfers = transfersData.map((data) {
        return BranchTransferRecord(
          id: _asString(data['id']) ?? '',
          date: _asString(data['date']) ?? '',
          sourceBranch: _asString(data['fromBranch']) ?? _asString(data['sourceBranch']) ?? '',
          destinationBranch: _asString(data['toBranch']) ?? _asString(data['destinationBranch']) ?? '',
          quantity: (data['quantity'] ?? 0) is int
              ? (data['quantity'] ?? 0) as int
              : int.tryParse((data['quantity'] ?? '0').toString()) ?? 0,
          status: _asString(data['status']) ?? 'Pending',
        );
      }).toList();
      notifyListeners();
      print('Branch transfers loaded from Firebase. Count: ${_branchTransfers.length}');
    } catch (e) {
      print('Error loading branch transfers from Firebase: $e');
    }
  }

  // Load all Stock Returns from Firebase
  Future<void> loadStockReturnsFromFirebase() async {
    try {
      final returnsData = await _firebaseService.fetchStockReturns();
      _stockReturns = returnsData.map((data) {
        return StockReturnRecord(
          id: _asString(data['id']) ?? '',
          date: _asString(data['date']) ?? '',
          vendor: _asString(data['vendor']) ?? '',
          item: _asString(data['item']) ?? '',
          quantity: (data['quantity'] ?? 0) is int
              ? (data['quantity'] ?? 0) as int
              : int.tryParse((data['quantity'] ?? '0').toString()) ?? 0,
          reason: _asString(data['reason']) ?? '',
          status: _asString(data['status']) ?? 'Pending',
        );
      }).toList();
      notifyListeners();
      print('Stock returns loaded from Firebase. Count: ${_stockReturns.length}');
    } catch (e) {
      print('Error loading stock returns from Firebase: $e');
    }
  }

  // Load all Internal Consumptions from Firebase
  Future<void> loadInternalConsumptionsFromFirebase() async {
    try {
      final consumptionsData = await _firebaseService.fetchInternalConsumptions();
      _internalConsumptions = consumptionsData.map((data) {
        return InternalConsumptionRecord(
          id: _asString(data['id']) ?? '',
          date: _asString(data['date']) ?? '',
          department: _asString(data['department']) ?? '',
          item: _asString(data['item']) ?? '',
          quantity: (data['quantity'] ?? 0) is int
              ? (data['quantity'] ?? 0) as int
              : int.tryParse((data['quantity'] ?? '0').toString()) ?? 0,
          purpose: _asString(data['purpose']) ?? '',
          user: _asString(data['user']) ?? '',
        );
      }).toList();
      notifyListeners();
      print('Internal consumptions loaded from Firebase. Count: ${_internalConsumptions.length}');
    } catch (e) {
      print('Error loading internal consumptions from Firebase: $e');
    }
  }

  /// Ensure all Inventory Control related collections are loaded once.
  /// This is used by the Inventory Control screen so that the detail
  /// screens (audits, transfers, returns, consumption) immediately show
  /// existing rows in their tables.
  Future<void> ensureInventoryControlDataLoaded() async {
    if (_inventoryControlDataLoaded) return;
    try {
      await Future.wait([
        loadStockAuditsFromFirebase(),
        loadStockAdjustmentsFromFirebase(),
        loadInternalTransfersFromFirebase(),
        loadBranchTransfersFromFirebase(),
        loadStockReturnsFromFirebase(),
        loadInternalConsumptionsFromFirebase(),
      ]);
      _inventoryControlDataLoaded = true;
      print('Inventory Control data loaded successfully');
    } catch (e) {
      print('Error loading Inventory Control data: $e');
    }
  }

  // Load all Storage Locations from Firebase
  Future<void> loadStorageLocationsFromFirebase() async {
    try {
      final locationsData = await _firebaseService.fetchStorageLocations();
      _storageLocations = locationsData.map((data) {
        return StorageLocation(
          id: _asString(data['id']) ?? '',
          name: _asString(data['name']) ?? '',
          type: _asString(data['type']) ?? '',
          parentLocation: _asString(data['parentLocation']) ?? '',
          capacity: (data['capacity'] ?? 0) is int
              ? (data['capacity'] ?? 0) as int
              : int.tryParse((data['capacity'] ?? '0').toString()) ?? 0,
          status: _asString(data['status']) ?? 'Active',
          manager: _asString(data['manager']) ?? '',
          description: _asString(data['description']) ?? '',
        );
      }).toList();
      notifyListeners();
      print('Storage locations loaded from Firebase. Count: ${_storageLocations.length}');
    } catch (e) {
      print('Error loading storage locations from Firebase: $e');
    }
  }

  // Load all data from Firebase (comprehensive method)
  Future<void> loadAllDataFromFirebase() async {
    try {
      await Future.wait([
        loadItems(),
        loadVendorsFromFirebase(),
        loadPRsFromFirebase(),
        loadGRNsFromFirebase(),
        loadStockAuditsFromFirebase(),
        loadStockAdjustmentsFromFirebase(),
        loadInternalTransfersFromFirebase(),
        loadBranchTransfersFromFirebase(),
        loadStockReturnsFromFirebase(),
        loadInternalConsumptionsFromFirebase(),
        loadStorageLocationsFromFirebase(),
      ]);
      print('All data loaded from Firebase successfully');
    } catch (e) {
      print('Error loading all data from Firebase: $e');
    }
  }

  Future<void> saveVendor(Map<String, dynamic> vendorData) async {
    try {
      // Save to Firestore if available
      try {
        await _firebaseService.saveVendor(vendorData);
      } catch (e) {
        print('Error saving vendor to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      // Normalize and add to local list so UI updates immediately
      final vendorMap = _normalizeVendorData(vendorData);
      _vendors = [vendorMap, ..._vendors];
      notifyListeners();
      print('Vendor saved successfully: ${vendorMap['name']}');
    } catch (e) {
      print('Error saving vendor: $e');
      throw Exception('Error saving vendor: $e');
    }
  }

  /// Normalize vendor data coming either from the dynamic form or Firebase.
  /// This ensures the Vendor model and VendorCard always receive the same keys.
  Map<String, dynamic> _normalizeVendorData(Map<String, dynamic> vendorData) {
    return {
      'id': _asString(vendorData['id']) ??
          'VND-${DateTime.now().millisecondsSinceEpoch}',
      // Dynamic form field IDs from Firestore schema:
      //  - Vendor Name:       untitled_field_1764420889986000
      //  - Vendor Category:   untitled_field_1764420918572000
      //  - Phone number:      untitled_field_1764420957425000
      'name': _asString(
            vendorData['untitled_field_1764420889986000'],
          ) ??
          _asString(vendorData['vendorName']) ??
          _asString(vendorData['name']) ??
          '',
      'category': _asString(
            vendorData['untitled_field_1764420918572000'],
          ) ??
          _asString(vendorData['category']) ??
          _asString(vendorData['vendorCategory']) ??
          '',
      // No dedicated contact person field in some schemas,
      // so fall back to vendor name if contactName is missing.
      'contactName': _asString(vendorData['contactName']) ??
          _asString(vendorData['untitled_field_1764420957425000']) ??
          _asString(vendorData['untitled_field_1764420889986000']) ??
          '',
      'email': _asString(vendorData['contactEmail']) ??
          _asString(vendorData['email']) ??
          '',
      'phone': _asString(vendorData['untitled_field_1764420957425000']) ??
          _asString(vendorData['phone']) ??
          _asString(vendorData['contactPhone']) ??
          '',
      'status': _asString(vendorData['status']) ?? 'Active',
      'address': _asString(vendorData['address']) ?? '',
      'paymentTerms': _asString(vendorData['paymentTerms']) ?? '',
      'notes': _asString(vendorData['notes']) ?? '',
      // Keep all other original fields too
      ...vendorData,
    };
  }

  Future<void> saveStockAdjustment(Map<String, dynamic> adjustmentData) async {
    try {
      // Save to Firestore if available (fixed path)
      try {
        await _firebaseService.saveStockAdjustment(adjustmentData);
      } catch (e) {
        print('Error saving stock adjustment to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      final now = DateTime.now();
      final adjustment = InventoryAdjustment(
        date: adjustmentData['date'] as String? ??
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        reason: adjustmentData['specificReason'] as String? ??
            adjustmentData['reason'] as String? ??
            adjustmentData['adjustmentType'] as String? ??
            'Adjustment',
        status: adjustmentData['status'] as String? ?? 'Pending Approval',
        quantity: (adjustmentData['adjustQty'] ??
                adjustmentData['quantity'] ??
                '0')
            .toString(),
      );
      _recentAdjustments = [adjustment, ..._recentAdjustments];
      notifyListeners();
      print('Stock adjustment saved successfully.');
    } catch (e) {
      print('Error saving stock adjustment: $e');
      throw Exception('Error saving stock adjustment: $e');
    }
  }

  // Save Purchase Requisition
  Future<void> savePR(Map<String, dynamic> prData) async {
    try {
      // Save to Firestore if available
      try {
        await _firebaseService.savePR(prData);
      } catch (e) {
        print('Error saving PR to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      // Add to local list as map
      final prMap = {
        'id': prData['id'] as String? ?? 'PR-${DateTime.now().millisecondsSinceEpoch}',
        'requestedBy': prData['requestedBy'] as String? ?? '',
        'department': prData['department'] as String? ?? '',
        'date': prData['date'] as String? ?? DateTime.now().toString().split(' ')[0],
        'priority': prData['priority'] as String? ?? 'Routine',
        'status': prData['status'] as String? ?? 'Pending Approval',
        ...prData, // Keep all other fields
      };
      _purchaseRequisitions = [..._purchaseRequisitions, prMap];
      notifyListeners();

      print('PR saved successfully with ID: ${prMap['id']}');
    } catch (e) {
      print('Error saving PR: $e');
      throw Exception('Error saving PR: $e');
    }
  }

  // Approve a Purchase Requisition (update status to "Approved")
  Future<void> approvePR(String prDocumentId) async {
    try {
      print('DEBUG approvePR: Starting approval for PR documentId: $prDocumentId');
      
      // Update PR status to "Approved" in Firebase
      await _firebaseService.updatePRStatus(prDocumentId, 'Approved');
      
      // Update local PR list - check both 'id' and 'documentId'
      final prIndex = _purchaseRequisitions.indexWhere(
        (pr) => (pr['id'] == prDocumentId) || (pr['documentId'] == prDocumentId),
      );
      
      Map<String, dynamic> prData;
      if (prIndex != -1) {
        final updatedPR = {
          ..._purchaseRequisitions[prIndex],
          'status': 'Approved',
        };
        _purchaseRequisitions[prIndex] = updatedPR;
        prData = updatedPR;
        print('DEBUG approvePR: Found PR in local list at index $prIndex');
      } else {
        // PR not in local list - fetch it from Firebase or use documentId
        print('DEBUG approvePR: PR not found in local list, fetching from Firebase');
        final prsData = await _firebaseService.fetchPRs();
        final foundPR = prsData.firstWhere(
          (pr) => (pr['id'] == prDocumentId) || (pr['documentId'] == prDocumentId),
          orElse: () => <String, dynamic>{},
        );
        if (foundPR.isNotEmpty) {
          prData = {
            ...foundPR,
            'status': 'Approved',
          };
          print('DEBUG approvePR: Found PR in Firebase');
        } else {
          print('DEBUG approvePR: PR not found in Firebase either, using documentId only');
          // Create minimal PR data from documentId
          prData = {
            'id': prDocumentId,
            'documentId': prDocumentId,
            'status': 'Approved',
          };
        }
      }
      
      notifyListeners();

      // Create PO fields and attach them to the PR document (not a separate PO doc)
      print('DEBUG approvePR: Creating PO fields on PR document');
      
      // Check multiple vendor field name variations (case-insensitive, label-style, etc.)
      final vendor = (prData['vendor'] ??
              prData['vendorName'] ??
              prData['supplier'] ??
              prData['Vendor'] ??
              prData['Vendor Name'] ??
              prData['vendor_name'] ??
              '')
          .toString();
      final poDate = (prData['date'] ??
              prData['poDate'] ??
              DateTime.now().toString().split(' ').first)
          .toString();
      final amount = (prData['amount'] ??
              prData['totalAmount'] ??
              prData['grandTotal'] ??
              prData['poAmount'] ??
              '\$0.00')
          .toString();
      final poId = 'PO-$prDocumentId';

      // Attach PO fields to the PR document in Firebase
      await _firebaseService.attachPOToPR(prDocumentId, {
        'poId': poId,
        'poStatus': 'Pending Approval',
        'poVendor': vendor,
        'poDate': poDate,
        'poAmount': amount,
      });

      // Also update local PR list with PO fields
      final localIndex = _purchaseRequisitions.indexWhere(
        (pr) => (pr['id'] == prDocumentId) || (pr['documentId'] == prDocumentId),
      );
      if (localIndex != -1) {
        _purchaseRequisitions[localIndex] = {
          ..._purchaseRequisitions[localIndex],
          'poId': poId,
          'poStatus': 'Pending Approval',
          'poVendor': vendor,
          'poDate': poDate,
          'poAmount': amount,
        };
        notifyListeners();
      }

      print('DEBUG approvePR: PO fields attached to PR document');
      print('PR approved successfully: $prDocumentId');
    } catch (e, stackTrace) {
      print('Error approving PR: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error approving PR: $e');
    }
  }

  // Reject a Purchase Requisition (update status to "Rejected")
  Future<void> rejectPR(String prDocumentId) async {
    try {
      // Update PR status to "Rejected" in Firebase
      await _firebaseService.updatePRStatus(prDocumentId, 'Rejected');
      
      // Update local PR list
      final prIndex = _purchaseRequisitions.indexWhere((pr) => pr['id'] == prDocumentId);
      if (prIndex != -1) {
        _purchaseRequisitions[prIndex] = {
          ..._purchaseRequisitions[prIndex],
          'status': 'Rejected',
        };
        notifyListeners();
      }
      
      print('PR rejected successfully: $prDocumentId');
    } catch (e) {
      print('Error rejecting PR: $e');
      throw Exception('Error rejecting PR: $e');
    }
  }

  // Approve a Purchase Order (update poStatus on the underlying PR)
  Future<void> approvePO(String prDocumentId) async {
    try {
      // Update attached PO status on the PR document in Firebase
      await _firebaseService.updatePOStatusOnPR(prDocumentId, 'Approved');

      // Update local PR list (poStatus field)
      final prIndex = _purchaseRequisitions.indexWhere(
        (pr) =>
            (pr['id'] == prDocumentId) || (pr['documentId'] == prDocumentId),
      );
      if (prIndex != -1) {
        _purchaseRequisitions[prIndex] = {
          ..._purchaseRequisitions[prIndex],
          'poStatus': 'Approved',
        };
        notifyListeners();
      }

      print('PO approved successfully for PR: $prDocumentId');
    } catch (e) {
      print('Error approving PO: $e');
      throw Exception('Error approving PO: $e');
    }
  }

  // Reject a Purchase Order (update poStatus on the underlying PR)
  Future<void> rejectPO(String prDocumentId) async {
    try {
      // Update attached PO status on the PR document in Firebase
      await _firebaseService.updatePOStatusOnPR(prDocumentId, 'Rejected');

      // Update local PR list (poStatus field)
      final prIndex = _purchaseRequisitions.indexWhere(
        (pr) =>
            (pr['id'] == prDocumentId) || (pr['documentId'] == prDocumentId),
      );
      if (prIndex != -1) {
        _purchaseRequisitions[prIndex] = {
          ..._purchaseRequisitions[prIndex],
          'poStatus': 'Rejected',
        };
        notifyListeners();
      }

      print('PO rejected successfully for PR: $prDocumentId');
    } catch (e) {
      print('Error rejecting PO: $e');
      throw Exception('Error rejecting PO: $e');
    }
  }

  // Save Purchase Order
  //
  // NOTE: This method is still used for standalone POs (created from the
  /// Save PO from the Create PO screen.
  /// NOTE: We no longer create a separate Firestore collection for POs.
  /// - POs linked to PRs are stored on the PR document in "Procurements"
  ///   via FirebaseService.attachPOToPR (poStatus, poId, etc.).
  /// - This method only updates local state so the UI can show the new PO.
  Future<void> savePO(Map<String, dynamic> poData) async {
    try {
      // Preserve the status from poData if it exists, otherwise default to 'Draft'
      final status = poData['status'] as String? ?? 'Draft';
      
      // Ensure status is in the map we keep locally
      final poDataWithStatus = {
        ...poData,
        'status': status,
      };
      
      // DO NOT call _firebaseService.savePO anymore
      // to avoid creating /transactions/.../purchaseOrders in Firestore.

      // Add to local list as map
      final poMap = {
        'id': poDataWithStatus['id'] as String? ?? 'PO-${DateTime.now().millisecondsSinceEpoch}',
        'vendor': poDataWithStatus['vendor'] as String? ?? '',
        'date': poDataWithStatus['date'] as String? ?? DateTime.now().toString().split(' ')[0],
        'amount': poDataWithStatus['amount'] as String? ?? '\$0.00',
        'status': status, // Use the preserved status
        ...poDataWithStatus, // Keep all other fields (status will be overwritten with the same value, which is fine)
      };
      _purchaseOrders = [..._purchaseOrders, poMap];
      notifyListeners();

      print('PO (local only) saved with ID: ${poMap['id']}, status: ${poMap['status']}');
    } catch (e) {
      print('Error saving PO: $e');
      throw Exception('Error saving PO: $e');
    }
  }

  // Save Goods Receipt Note
  Future<void> saveGRN(Map<String, dynamic> grnData) async {
    try {
      // Save to Firestore if available
      try {
        await _firebaseService.saveGRN(grnData);
      } catch (e) {
        print('Error saving GRN to Firestore: $e');
        // Continue with local save even if Firestore fails
      }

      // Add to local list
      final grn = GoodsReceipt(
        grnId:
            grnData['grnId'] as String? ??
            'GRN-${DateTime.now().millisecondsSinceEpoch}',
        poReference: grnData['poReference'] as String? ?? '',
        vendor: grnData['vendor'] as String? ?? '',
        dateReceived:
            grnData['dateReceived'] as String? ??
            DateTime.now().toString().split(' ')[0],
        receivedBy: grnData['receivedBy'] as String? ?? '',
        status: grnData['status'] as String? ?? 'Pending',
      );
      _goodsReceipts = [..._goodsReceipts, grn];
      notifyListeners();

      print('GRN saved successfully with ID: ${grn.grnId}');
    } catch (e) {
      print('Error saving GRN: $e');
      throw Exception('Error saving GRN: $e');
    }
  }
}
