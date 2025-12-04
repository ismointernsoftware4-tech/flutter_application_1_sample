import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/table_column_visibility_provider.dart';
import '../../../shared/services/firebase_service.dart';
import '../models/procurement_models.dart';
import '../../vendor_management/models/vendor_models.dart';
import '../providers/procurement_provider.dart';
import '../../../shared/utils/animated_routes.dart';
import '../../../shared/widgets/vendor_card.dart';
import '../../../shared/widgets/filter_export_buttons.dart';
import '../../../shared/widgets/enhanced_filter_sheet.dart';
import '../../../shared/widgets/schema_table.dart';
import '../../../shared/utils/responsive_helper.dart';
import 'create_pr_screen.dart';
import 'create_po_screen.dart';

class ProcurementScreen extends StatelessWidget {
  const ProcurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProcurementProvider(),
      child: const _ProcurementView(),
    );
  }
}

class _ProcurementView extends StatefulWidget {
  const _ProcurementView();

  @override
  State<_ProcurementView> createState() => _ProcurementViewState();
}

class _ProcurementViewState extends State<_ProcurementView> {
  late final TextEditingController _searchController;
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _currentPRs = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = Provider.of<ProcurementProvider>(
        context,
        listen: false,
      ).searchQuery;
      _searchController.text = query;
      // StreamBuilder will handle loading PRs automatically
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final provider = context.read<ProcurementProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final activeTab = provider.activeTab;

    ProcurementFilterSheet filterSheet;
    final filterKey = GlobalKey<_ProcurementFilterSheetState>();
    String title;

    // Use current PRs from stream (cached) or fallback to dashboardProvider
    final currentPRs = _currentPRs.isNotEmpty 
        ? _currentPRs 
        : dashboardProvider.purchaseRequisitions;

    if (activeTab == 0) {
      // Purchase Requisitions
      title = 'Filter Purchase Requisitions';
      filterSheet = ProcurementFilterSheet(
        key: filterKey,
        initialFilter: provider.filter,
        type: 'PR',
        statuses:
            currentPRs
                .map((e) => (e['status'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
        priorities:
            currentPRs
                .map((e) => (e['priority'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
        departments:
            currentPRs
                .map((e) => (e['department'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
      );
    } else if (activeTab == 1) {
      // Purchase Orders - get PRs that have PO fields attached
      final prsWithPO = currentPRs
          .where((pr) => (pr['poStatus'] as String? ?? '').isNotEmpty)
          .toList();
      title = 'Filter Purchase Orders';
      filterSheet = ProcurementFilterSheet(
        key: filterKey,
        initialFilter: provider.filter,
        type: 'PO',
        statuses:
            prsWithPO
                .map((e) => (e['poStatus'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
        vendors:
            prsWithPO
                .map((e) => (e['poVendor'] ?? e['vendor'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
      );
    } else {
      // Vendors
      title = 'Filter Vendors';
      filterSheet = ProcurementFilterSheet(
        key: filterKey,
        initialFilter: provider.filter,
        type: 'Vendor',
        statuses:
            dashboardProvider.vendors
                .map((e) => (e['status'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
        categories:
            dashboardProvider.vendors
                .map((e) => (e['category'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
      );
    }

    final result = await EnhancedFilterSheet.show<ProcurementFilter>(
      context: context,
      title: title,
      child: filterSheet,
      onApply: () => filterKey.currentState?.getFilter() ?? const ProcurementFilter(),
      onClear: () => const ProcurementFilter(),
    );

    if (result != null) {
      provider.updateFilter(result);
    }
  }

  Future<String> _handleExport() async {
    final provider = context.read<ProcurementProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final activeTab = provider.activeTab;

    // Use current PRs from stream (cached) or fallback to dashboardProvider
    final currentPRs = _currentPRs.isNotEmpty 
        ? _currentPRs 
        : dashboardProvider.purchaseRequisitions;

    if (activeTab == 0) {
      final filtered = provider.filterPRs(currentPRs);
      return await provider.exportPRs(filtered);
    } else if (activeTab == 1) {
      // Export PRs that have PO fields attached
      final prsWithPO = currentPRs
          .where((pr) => (pr['poStatus'] as String? ?? '').isNotEmpty)
          .toList();
      final filtered = provider.filterPOs(prsWithPO);
      return await provider.exportPOs(filtered);
    } else {
      final filtered = provider.filterVendors(dashboardProvider.vendors);
      return await provider.exportVendors(filtered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final procurementProvider = context.watch<ProcurementProvider>();
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildHeader(context, procurementProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(context),
                  SizedBox(height: isMobile ? 16 : 20),
                  _buildActionBar(context, procurementProvider),
                  SizedBox(height: isMobile ? 16 : 24),
                  _buildTabContent(
                    context,
                    dashboardProvider,
                    procurementProvider,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProcurementProvider procurementProvider,
  ) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Menu icon for mobile/tablet
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open menu',
                    ),
                    Expanded(
                      child: Text(
                        'Procurement',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ShadInput(
                    controller: _searchController,
                    onChanged: (value) =>
                        procurementProvider.updateSearchQuery(value),
                    placeholder: const Text('Search...'),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 700;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Menu icon for tablet
                        if (isTablet)
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            tooltip: 'Open menu',
                          ),
                        if (!isSmallScreen)
                          Text(
                            'Procurement',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getTitleFontSize(
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen
                              ? double.infinity
                              : searchWidth,
                        ),
                        child: ShadInput(
                          controller: _searchController,
                          onChanged: (value) =>
                              procurementProvider.updateSearchQuery(value),
                          placeholder: const Text('Search...'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final procurementProvider = context.watch<ProcurementProvider>();
    final activeTab = procurementProvider.activeTab;
    final tabs = ['Purchase Requisitions', 'Purchase Orders', 'Vendors'];
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isActive = activeTab == index;
                return GestureDetector(
                  onTap: () {
                    if (index == 2) {
                      // Set selectedNavItem to 'Vendor Management' to show it in dashboard
                      context.read<DashboardProvider>().setSelectedNavItem('Vendor Management');
                    } else {
                      context.read<ProcurementProvider>().setActiveTab(index);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isMobile && tabs[index].length > 15
                              ? tabs[index].split(' ').first
                              : tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.blue.shade700
                                : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isActive)
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          )
        : Row(
            children: List.generate(tabs.length, (index) {
              final isActive = activeTab == index;
              return GestureDetector(
                onTap: () {
                  if (index == 2) {
                    // Set selectedNavItem to 'Vendor Management' to show it in dashboard
                    context.read<DashboardProvider>().setSelectedNavItem('Vendor Management');
                  } else {
                    context.read<ProcurementProvider>().setActiveTab(index);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.blue.shade700
                              : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isActive)
                        Container(
                          height: 3,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
  }

  Widget _buildActionBar(
    BuildContext context,
    ProcurementProvider procurementProvider,
  ) {
    final buttonLabel = procurementProvider.primaryButtonLabel;
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilterExportButtonRow(
                onFilterPressed: _openFilterSheet,
                onExportPressed: _handleExport,
                filterLabel: 'Filter',
                exportLabel: 'Export',
                isMobile: true,
                spacing: 8,
              ),
              const SizedBox(height: 12),
              ShadButton(
                onPressed: () {
                  if (procurementProvider.activeTab == 0) {
                    Navigator.of(context).push(
                      AnimatedRoutes.slideRight(
                        const CreatePRScreen(),
                      ),
                    );
                  } else if (procurementProvider.activeTab == 1) {
                    Navigator.of(context).push(
                      AnimatedRoutes.slideRight(
                        const CreatePOScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add Vendor functionality coming soon'),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(buttonLabel),
                  ],
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilterExportButtonRow(
                onFilterPressed: _openFilterSheet,
                onExportPressed: _handleExport,
                filterLabel: 'Filter',
                exportLabel: 'Export',
                isMobile: false,
              ),
              ShadButton(
                onPressed: () {
                  if (procurementProvider.activeTab == 0) {
                    Navigator.of(context).push(
                      AnimatedRoutes.slideRight(
                        const CreatePRScreen(),
                      ),
                    );
                  } else if (procurementProvider.activeTab == 1) {
                    Navigator.of(context).push(
                      AnimatedRoutes.slideRight(
                        const CreatePOScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add Vendor functionality coming soon'),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(buttonLabel),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildTabContent(
    BuildContext context,
    DashboardProvider dashboardProvider,
    ProcurementProvider procurementProvider,
  ) {
    final activeTab = procurementProvider.activeTab;
    switch (activeTab) {
      case 0:
        // Use StreamBuilder for Purchase Requisitions
        // Use a key to prevent ChangeNotifierProvider recreation
        return ChangeNotifierProvider(
          key: const ValueKey('pr_column_provider'),
          create: (_) => TableColumnVisibilityProvider('pr'),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firebaseService.getPRsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              
              final allPRs = snapshot.data ?? [];
              // Update cache without setState to prevent extra rebuild
              _currentPRs = allPRs;
              
              final filtered = procurementProvider.filterPRs(allPRs);
              return _buildRequisitionTable(filtered);
            },
          ),
        );
      case 1:
        // Use StreamBuilder for Purchase Orders (PRs with PO fields)
        // Use a key to prevent ChangeNotifierProvider recreation
        return ChangeNotifierProvider(
          key: const ValueKey('po_column_provider'),
          create: (_) => TableColumnVisibilityProvider('po'),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firebaseService.getPRsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              
              final allPRs = snapshot.data ?? [];
              // Update cache without setState to prevent extra rebuild
              _currentPRs = allPRs;
              
              final prsWithPO = allPRs
                  .where((pr) => (pr['poStatus'] as String? ?? '').isNotEmpty)
                  .toList();
              final filtered = procurementProvider.filterPOs(prsWithPO);
              return _buildPurchaseOrderTable(filtered);
            },
          ),
        );
      default:
        final filtered = procurementProvider.filterVendors(
          dashboardProvider.vendors,
        );
        return _buildVendorGrid(filtered);
    }
  }

  Widget _buildRequisitionTable(List<Map<String, dynamic>> data) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Show cards on mobile, table on desktop/tablet
    if (isMobile) {
      return _buildPRMobileCardView(data);
    }
    
    // ChangeNotifierProvider is now in _buildTabContent, use Consumer directly
    return Consumer<TableColumnVisibilityProvider>(
        builder: (context, columnProvider, _) {
          if (columnProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final visibleColumns = columnProvider.visibleColumns;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Manage Columns button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (dialogContext) {
                              final isDialogMobile = ResponsiveHelper.isMobile(dialogContext);
                              return AlertDialog(
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: isDialogMobile ? 12 : 80,
                                  vertical: isDialogMobile ? 12 : 40,
                                ),
                                contentPadding: const EdgeInsets.all(24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: SizedBox(
                                  width: isDialogMobile ? double.infinity : 640,
                                  child: _InlineColumnPicker(
                                    provider: columnProvider,
                                    title: 'Manage PR Columns',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.view_column),
                        label: const Text('Manage Columns'),
                      ),
                    ],
                  ),
                ),
                // Table
                SizedBox(
                  height: 400,
                  child: SchemaTable<Map<String, dynamic>>(
                    items: data,
                    columns: visibleColumns,
                    columnWidth: isTablet ? 160 : 200,
                    emptyLabel: 'No purchase requisitions found.',
                    valueBuilder: (item, column) => _resolvePRColumnValue(item, column.key),
                    actionsBuilder: (item) => [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
  }

  Widget _buildPurchaseOrderTable(List<Map<String, dynamic>> data) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Show cards on mobile, table on desktop/tablet
    if (isMobile) {
      return _buildPOMobileCardView(data);
    }
    
    // ChangeNotifierProvider is now in _buildTabContent, use Consumer directly
    return Consumer<TableColumnVisibilityProvider>(
        builder: (context, columnProvider, _) {
          if (columnProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final visibleColumns = columnProvider.visibleColumns;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Manage Columns button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (dialogContext) {
                              final isDialogMobile = ResponsiveHelper.isMobile(dialogContext);
                              return AlertDialog(
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: isDialogMobile ? 12 : 80,
                                  vertical: isDialogMobile ? 12 : 40,
                                ),
                                contentPadding: const EdgeInsets.all(24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: SizedBox(
                                  width: isDialogMobile ? double.infinity : 640,
                                  child: _InlineColumnPicker(
                                    provider: columnProvider,
                                    title: 'Manage PO Columns',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.view_column),
                        label: const Text('Manage Columns'),
                      ),
                    ],
                  ),
                ),
                // Table
                SizedBox(
                  height: 400,
                  child: SchemaTable<Map<String, dynamic>>(
                    items: data,
                    columns: visibleColumns,
                    columnWidth: isTablet ? 160 : 200,
                    emptyLabel: 'No purchase orders found.',
                    valueBuilder: (item, column) => _resolvePOColumnValue(item, column.key),
                    actionsBuilder: (item) => [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
  }

  String _resolvePRColumnValue(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return '';
    return value.toString();
  }

  String _resolvePOColumnValue(Map<String, dynamic> item, String key) {
    // For PO columns, check PO-specific fields first, then fall back to PR fields
    String? value;
    
    // Map common column keys to PO field names
    if (key.toLowerCase().contains('status')) {
      value = item['poStatus'] ?? item['status'];
    } else if (key.toLowerCase().contains('id') || key.toLowerCase().contains('number')) {
      value = item['poId'] ?? item['id'];
    } else if (key.toLowerCase().contains('vendor')) {
      value = item['poVendor'] ?? item['vendor'] ?? item['vendorName'];
    } else if (key.toLowerCase().contains('date')) {
      value = item['poDate'] ?? item['date'];
    } else if (key.toLowerCase().contains('amount') || key.toLowerCase().contains('total')) {
      value = item['poAmount'] ?? item['amount'] ?? item['totalAmount'] ?? item['grandTotal'];
    } else {
      // For other fields, check PO prefix first, then regular field
      value = item['po$key'] ?? item[key];
    }
    
    if (value == null) return '';
    return value.toString();
  }

  Widget _buildVendorGrid(List<Map<String, dynamic>> vendors) {
    if (vendors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text('No vendors available'),
            ],
          ),
        ),
      );
    }

    // For now, keep the grid view for vendors, but we could convert to table too
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: vendors
          .map(
            (vendor) => SizedBox(
              width: 320,
              child: VendorCard(
                vendor: Vendor(
                  id: (vendor['id'] ?? '').toString(),
                  name: (vendor['name'] ?? '').toString(),
                  category: (vendor['category'] ?? '').toString(),
                  contactName: (vendor['contactName'] ?? '').toString(),
                  email: (vendor['email'] ?? '').toString(),
                  phone: (vendor['phone'] ?? '').toString(),
                  status: (vendor['status'] ?? '').toString(),
                  address: (vendor['address'] ?? '').toString(),
                  paymentTerms: (vendor['paymentTerms'] ?? '').toString(),
                  notes: (vendor['notes'] ?? '').toString(),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // Mobile card view for Purchase Requisitions
  Widget _buildPRMobileCardView(List<Map<String, dynamic>> prs) {
    if (prs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No purchase requisitions found.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: prs.length,
      itemBuilder: (context, index) {
        final pr = prs[index];
        final prId = (pr['id'] ?? pr['prId'] ?? '').toString();
        final status = (pr['status'] ?? '').toString();
        final priority = (pr['priority'] ?? '').toString();
        final department = (pr['department'] ?? '').toString();
        final date = (pr['date'] ?? pr['createdAt'] ?? '').toString();
        final amount = (pr['amount'] ?? pr['totalAmount'] ?? pr['grandTotal'] ?? '0').toString();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prId,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            department.isNotEmpty ? department : 'No Department',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMobileInfoRow('Priority', priority),
                    _buildMobileInfoRow('Date', date),
                    _buildMobileInfoRow('Amount', amount),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Mobile card view for Purchase Orders
  Widget _buildPOMobileCardView(List<Map<String, dynamic>> pos) {
    if (pos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No purchase orders found.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: pos.length,
      itemBuilder: (context, index) {
        final po = pos[index];
        final poId = (po['poId'] ?? po['id'] ?? '').toString();
        final status = (po['poStatus'] ?? po['status'] ?? '').toString();
        final vendor = (po['poVendor'] ?? po['vendor'] ?? po['vendorName'] ?? '').toString();
        final date = (po['poDate'] ?? po['date'] ?? '').toString();
        final amount = (po['poAmount'] ?? po['amount'] ?? po['totalAmount'] ?? po['grandTotal'] ?? '0').toString();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poId,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vendor.isNotEmpty ? vendor : 'No Vendor',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMobileInfoRow('Date', date),
                    _buildMobileInfoRow('Amount', amount),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('approved') || lower.contains('completed')) {
      return Colors.green;
    } else if (lower.contains('pending') || lower.contains('draft')) {
      return Colors.orange;
    } else if (lower.contains('rejected') || lower.contains('cancelled')) {
      return Colors.red;
    }
    return Colors.blueGrey;
  }


}

class _InlineColumnPicker extends StatelessWidget {
  const _InlineColumnPicker({
    required this.provider,
    required this.title,
  });

  final TableColumnVisibilityProvider provider;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: provider,
          builder: (context, _) {
            if (provider.isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final columns = provider.columns;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: provider.resetToDefault,
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: columns
                      .map(
                        (column) => FilterChip(
                          label: Text(column.label),
                          selected: column.visible,
                          onSelected: (value) =>
                              provider.toggleColumn(column.key, value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: columns.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final column = columns[index];
                      return SwitchListTile(
                        title: Text(column.label),
                        subtitle: Text(column.description),
                        value: column.visible,
                        onChanged: (value) =>
                            provider.toggleColumn(column.key, value),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.setAll(false),
                        icon: const Icon(Icons.visibility_off),
                        label: const Text('Hide All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.setAll(true),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show All'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProcurementFilterSheet extends StatefulWidget {
  const ProcurementFilterSheet({
    super.key,
    required this.initialFilter,
    required this.type,
    this.statuses = const [],
    this.priorities = const [],
    this.departments = const [],
    this.vendors = const [],
    this.categories = const [],
  });

  final ProcurementFilter initialFilter;
  final String type; // 'PR', 'PO', or 'Vendor'
  final List<String> statuses;
  final List<String> priorities;
  final List<String> departments;
  final List<String> vendors;
  final List<String> categories;

  @override
  State<ProcurementFilterSheet> createState() => _ProcurementFilterSheetState();
}

class _ProcurementFilterSheetState extends State<ProcurementFilterSheet> {
  String? _status;
  String? _priority;
  String? _department;
  String? _vendor;
  String? _category;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialFilter.status;
    _priority = widget.initialFilter.priority;
    _department = widget.initialFilter.department;
    _vendor = widget.initialFilter.vendor;
    _category = widget.initialFilter.category;
    _searchController = TextEditingController(
      text: widget.initialFilter.searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ProcurementFilter getFilter() {
    return ProcurementFilter(
      status: _status,
      priority: _priority,
      department: _department,
      vendor: _vendor,
      category: _category,
      searchQuery: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadInput(
          controller: _searchController,
          placeholder: const Text('Search'),
        ),
        if (widget.statuses.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Status',
            value: _status,
            items: widget.statuses,
            onChanged: (value) => setState(() => _status = value),
          ),
        ],
        if (widget.type == 'PR' && widget.priorities.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Priority',
            value: _priority,
            items: widget.priorities,
            onChanged: (value) => setState(() => _priority = value),
          ),
        ],
        if (widget.type == 'PR' && widget.departments.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Department',
            value: _department,
            items: widget.departments,
            onChanged: (value) => setState(() => _department = value),
          ),
        ],
        if (widget.type == 'PO' && widget.vendors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Vendor',
            value: _vendor,
            items: widget.vendors,
            onChanged: (value) => setState(() => _vendor = value),
          ),
        ],
        if (widget.type == 'Vendor' && widget.categories.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Category',
            value: _category,
            items: widget.categories,
            onChanged: (value) => setState(() => _category = value),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final dropdownItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Any')),
      ...items.map((e) => DropdownMenuItem<String?>(value: e, child: Text(e))),
    ];

    return DropdownButtonFormField<String?>(
      value: value,
      items: dropdownItems,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }
}
