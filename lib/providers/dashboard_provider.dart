import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../services/firebase_service.dart';
import '../constants/navigation_items.dart';

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

  List<ItemMaster> _itemMasterList = [
    ItemMaster(
      itemCode: 'ITM001',
      itemName: 'Paracetamol 500mg',
      manufacturer: 'PharmaCorp',
      type: 'Drug',
      category: 'Analgesic',
      unit: 'Tablet',
      storage: 'RT',
      stock: 5000,
      status: 'Active',
    ),
    ItemMaster(
      itemCode: 'ITM002',
      itemName: 'Insulin Glargine',
      manufacturer: 'BioMed',
      type: 'Drug',
      category: 'Antidiabetic',
      unit: 'Vial',
      storage: '2-8°C',
      stock: 120,
      status: 'Active',
    ),
    ItemMaster(
      itemCode: 'ITM003',
      itemName: 'Surgical Gloves',
      manufacturer: 'SafeHands',
      type: 'Consumable',
      category: 'Surgical',
      unit: 'Box',
      storage: 'RT',
      stock: 50,
      status: 'Low Stock',
    ),
  ];

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
  bool _showAddUserForm = false;
  NewUserForm _newUserForm = NewUserForm();
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _rolesList = [];
  final List<String> _defaultRoles = [
    'Administrator',
    'Requester',
    'Store Keeper',
    'Procurement Officer',
  ];

  List<Vendor> _vendors = [
    Vendor(
      name: 'PharmaCorp Ltd',
      category: 'Pharmaceuticals',
      contactName: 'Alice Johnson',
      email: 'alice@pharmacorp.com',
      phone: '+1 555-0123',
      status: 'Approved',
    ),
    Vendor(
      name: 'BioMed Supplies',
      category: 'Medical Supplies',
      contactName: 'Bob Smith',
      email: 'sales@biomed.com',
      phone: '+1 555-0124',
      status: 'Approved',
    ),
    Vendor(
      name: 'SafeHands Inc',
      category: 'Consumables',
      contactName: 'Charlie Brown',
      email: 'charlie@safehands.com',
      phone: '+1 555-0125',
      status: 'Pending',
    ),
  ];

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
          options: ['Medical Supplies', 'Pharmaceuticals', 'Consumables', 'Equipment'],
        ),
        VendorFormField(
          id: 'tax_id',
          label: 'Tax ID / GSTIN',
        ),
        VendorFormField(
          id: 'website',
          label: 'Website',
        ),
        VendorFormField(
          id: 'phone',
          label: 'Phone Number',
          required: true,
        ),
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
        VendorFormField(
          id: 'bank_name',
          label: 'Bank Name',
        ),
        VendorFormField(
          id: 'account_number',
          label: 'Account Number',
        ),
        VendorFormField(
          id: 'compliance_docs',
          label: 'Compliance Documents',
        ),
      ],
    ),
  ];

  final Map<String, bool> _vendorSectionsExpanded = {
    'company': true,
    'contact': true,
    'financial': true,
  };

  final List<PurchaseRequisition> _purchaseRequisitions = [
    PurchaseRequisition(
      id: 'PR-2023-001',
      requestedBy: 'Dr. Sarah Smith',
      department: 'IVF Lab',
      date: '2023-10-25',
      priority: 'Routine',
      status: 'Pending Approval',
    ),
    PurchaseRequisition(
      id: 'PR-2023-002',
      requestedBy: 'John Doe',
      department: 'Pharmacy',
      date: '2023-10-26',
      priority: 'Urgent',
      status: 'Approved',
    ),
  ];

  final List<PurchaseOrder> _purchaseOrders = [
    PurchaseOrder(
      id: 'PO-2023-010',
      vendor: 'PharmaCorp Ltd',
      date: '2023-10-28',
      amount: '\$12,450',
      status: 'Draft',
    ),
    PurchaseOrder(
      id: 'PO-2023-011',
      vendor: 'BioMed Supplies',
      date: '2023-10-29',
      amount: '\$7,320',
      status: 'Issued',
    ),
  ];
  final List<GoodsReceipt> _goodsReceipts = [
    GoodsReceipt(
      grnId: 'GRN-2023-001',
      poReference: 'PO-2023-001',
      vendor: 'PharmaCorp Ltd',
      dateReceived: '2023-11-01',
      receivedBy: 'Store Manager',
      status: 'Completed',
    ),
  ];
  final Map<String, String> _vendorFieldValues = {};

  final List<InventoryQuickAction> _inventoryActions = const [
    InventoryQuickAction(
      title: 'Start Audit',
      icon: Icons.assignment_outlined,
      iconColor: Color(0xFF2563EB),
      backgroundColor: Color(0xFFE0ECFF),
      navTarget: 'Stock Audits',
    ),
    InventoryQuickAction(
      title: 'Adjustment',
      icon: Icons.autorenew,
      iconColor: Color(0xFF111827),
      backgroundColor: Color(0xFFECECEC),
      navTarget: 'Stock Adjustment',
    ),
    InventoryQuickAction(
      title: 'Internal Transfer',
      icon: Icons.compare_arrows,
      iconColor: Color(0xFF1D4ED8),
      backgroundColor: Color(0xFFE0ECFF),
      navTarget: 'Internal Transfers',
    ),
    InventoryQuickAction(
      title: 'Branch Transfer',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFF7C3AED),
      backgroundColor: Color(0xFFEDE9FE),
      navTarget: 'Branch Transfers',
    ),
    InventoryQuickAction(
      title: 'Return to Vendor',
      icon: Icons.undo,
      iconColor: Color(0xFF111827),
      backgroundColor: Color(0xFFECECEC),
      navTarget: 'Stock Returns',
    ),
    InventoryQuickAction(
      title: 'Consumption',
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFF047857),
      backgroundColor: Color(0xFFDCFCE7),
      navTarget: 'Internal Consumption',
    ),
  ];

  final List<InventoryAudit> _recentAudits = const [
    InventoryAudit(
      date: '2023-10-30',
      type: 'Systemic',
      status: 'Completed',
      discrepancies: 2,
    ),
    InventoryAudit(
      date: '2023-11-15',
      type: 'Random',
      status: 'Pending Approval',
      discrepancies: 0,
    ),
  ];

  final List<InventoryAdjustment> _recentAdjustments = const [
    InventoryAdjustment(
      date: '2023-11-02',
      reason: 'Damage',
      status: 'Approved',
      quantity: '-2',
    ),
  ];

  final List<StockAuditRecord> _stockAudits = const [
    StockAuditRecord(
      id: 'AUD-2023-001',
      date: '2023-10-30',
      type: 'Systemic',
      auditor: 'John Doe',
      status: 'Completed',
      discrepancies: 2,
    ),
    StockAuditRecord(
      id: 'AUD-2023-002',
      date: '2023-11-15',
      type: 'Random',
      auditor: 'Jane Smith',
      status: 'Pending Approval',
      discrepancies: 0,
    ),
  ];

  final List<StockTransferRecord> _stockTransfers = const [
    StockTransferRecord(
      id: 'TRF-001',
      date: '2023-11-20',
      fromLocation: 'Main Store',
      toLocation: 'Pharmacy',
      quantity: 5,
      status: 'Completed',
    ),
    StockTransferRecord(
      id: 'TRF-002',
      date: '2023-11-21',
      fromLocation: 'Main Store',
      toLocation: 'Ward A',
      quantity: 2,
      status: 'Pending',
    ),
  ];

  final List<BranchTransferRecord> _branchTransfers = const [
    BranchTransferRecord(
      id: 'IBT-001',
      date: '2023-11-15',
      sourceBranch: 'Main Branch',
      destinationBranch: 'North Wing Branch',
      quantity: 150,
      status: 'In Transit',
    ),
  ];

  final List<StockReturnRecord> _stockReturns = const [
    StockReturnRecord(
      id: 'RET-001',
      date: '2023-11-10',
      vendor: 'PharmaCorp Ltd',
      item: 'Paracetamol 500mg',
      quantity: 50,
      reason: 'Damaged',
      status: 'Approved',
    ),
  ];

  final List<InternalConsumptionRecord> _internalConsumptions = const [
    InternalConsumptionRecord(
      id: 'CON-001',
      date: '2023-11-22',
      department: 'Housekeeping',
      item: 'Surgical Gloves',
      quantity: 2,
      purpose: 'Cleaning',
      user: 'John Doe',
    ),
  ];

  List<StorageLocation> _storageLocations = [
    StorageLocation(
      id: 'LOC001',
      name: 'Main Warehouse',
      type: 'Warehouse',
      parentLocation: '-',
      capacity: 100,
      status: 'Active',
      manager: 'Alex Morgan',
      description: 'Primary storage for dry inventory',
    ),
    StorageLocation(
      id: 'LOC002',
      name: 'Cold Storage Room',
      type: 'Room',
      parentLocation: 'Main Warehouse',
      capacity: 45,
      status: 'Active',
      manager: 'Dr. Kelly',
      description: '2-8°C storage',
    ),
    StorageLocation(
      id: 'LOC003',
      name: 'Rack A',
      type: 'Rack',
      parentLocation: 'Main Warehouse',
      capacity: 80,
      status: 'Active',
      manager: 'Store Keeper',
      description: 'High-demand items',
    ),
    StorageLocation(
      id: 'LOC004',
      name: 'Shelf A1',
      type: 'Shelf',
      parentLocation: 'Rack A',
      capacity: 20,
      status: 'Active',
      manager: 'Store Keeper',
      description: 'Emergency stock',
    ),
    StorageLocation(
      id: 'LOC005',
      name: 'Bin 101',
      type: 'Bin',
      parentLocation: 'Shelf A1',
      capacity: 0,
      status: 'Empty',
      manager: 'Assistant',
      description: 'Reserved for consumables',
    ),
    StorageLocation(
      id: 'LOC006',
      name: 'Chemical Cabinet',
      type: 'Cabinet',
      parentLocation: 'Main Warehouse',
      capacity: 60,
      status: 'Active',
      manager: 'Safety Officer',
      description: 'Hazardous materials',
    ),
  ];

  final List<TraceabilityRecord> _traceabilityRecords = const [
    TraceabilityRecord(
      dateTime: '2023-11-01 10:30',
      type: 'GRN',
      reference: 'GRN-2023-001',
      itemDetails: 'Paracetamol 500mg',
      quantity: '+1000',
      user: 'Store Manager',
      location: 'Main Store',
    ),
    TraceabilityRecord(
      dateTime: '2023-11-02 14:15',
      type: 'Adjustment',
      reference: 'ADJ-2023-001',
      itemDetails: 'Insulin Glargine',
      quantity: '-2',
      user: 'Store Keeper',
      location: 'Pharmacy',
    ),
    TraceabilityRecord(
      dateTime: '2023-11-03 09:00',
      type: 'Issue',
      reference: 'ISS-2023-055',
      itemDetails: 'Surgical Gloves',
      quantity: '-50',
      user: 'Nurse Station A',
      location: 'Ward A',
    ),
  ];

  final List<ApprovalWorkflowItem> _approvalWorkflows = const [
    ApprovalWorkflowItem(
      priority: 'Routine',
      id: 'AP-001',
      date: '2023-10-25',
      title: 'Purchase Requisition',
      description: 'Surgical Gloves for IVF Lab',
      requestedBy: 'Dr. Sarah Smith',
      status: 'Pending',
    ),
    ApprovalWorkflowItem(
      priority: 'High',
      id: 'AP-002',
      date: '2023-10-29',
      title: 'Vendor Registration',
      description: 'New Vendor: SafeHands Inc',
      requestedBy: 'Procurement Officer',
      status: 'Pending',
    ),
    ApprovalWorkflowItem(
      priority: 'Urgent',
      id: 'AP-003',
      date: '2023-11-15',
      title: 'Stock Adjustment',
      description: 'Expiry Write-off: Insulin',
      requestedBy: 'Pharmacy Supervisor',
      status: 'Pending',
    ),
  ];

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
  List<ItemMaster> get itemMasterList => _itemMasterList;
  List<User> get usersList => _usersList;
  String get selectedNavItem => _selectedNavItem;
  bool get showAddUserForm => _showAddUserForm;
  NewUserForm get newUserForm => _newUserForm;
  List<String> get rolesList => _rolesList;
  List<Vendor> get vendors => List.unmodifiable(_vendors);
  FirebaseService get firebaseService => _firebaseService;
  List<PurchaseRequisition> get purchaseRequisitions =>
      List.unmodifiable(_purchaseRequisitions);
  List<PurchaseOrder> get purchaseOrders =>
      List.unmodifiable(_purchaseOrders);
  List<GoodsReceipt> get goodsReceipts => List.unmodifiable(_goodsReceipts);
  List<InventoryQuickAction> get inventoryActions =>
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
  String vendorFieldValue(String fieldId) =>
      _vendorFieldValues[fieldId] ?? '';

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
      throw Exception('Please fill all fields and use a password with at least 6 characters.');
    }

    try {
      final now = DateTime.now();
      final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
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
      _vendorSectionsExpanded[sectionId] =
          !_vendorSectionsExpanded[sectionId]!;
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

  void addStorageLocation({
    required String name,
    required String type,
    required String parentLocation,
    required int capacity,
    required String status,
    String manager = '',
    String description = '',
  }) {
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

  void addVendorFromFields() {
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

    final vendor = Vendor(
      name: vendorName,
      category: vendorFieldValue('vendor_category').isNotEmpty
          ? vendorFieldValue('vendor_category')
          : 'General',
      contactName: contactName,
      email: email,
      phone: phone,
      status: 'Pending',
    );
    _vendors = [..._vendors, vendor];
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
}

