import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/summary_cards.dart';
import '../widgets/charts.dart';
import '../widgets/transactions_table.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';
import 'item_master_screen.dart';
import 'users_roles_screen.dart';
import 'procurement_screen.dart';
import 'grn_receiving_screen.dart';
import 'inventory_control_screen.dart';
import 'storage_locations_screen.dart';
import 'traceability_screen.dart';
import 'approvals_screen.dart';
import 'reports_screen.dart';
import 'settings_admin_screen.dart';
import 'item_management_screen.dart';
import 'vendor_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final showDrawer = isMobile || isTablet;

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          drawer: showDrawer ? const Sidebar() : null,
          body: Row(
            children: [
              // Sidebar for desktop - can be toggled
              if (!showDrawer && (provider.sidebarVisible == true)) const Sidebar(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final selectedNavItem = provider.selectedNavItem;
                    
                    if (selectedNavItem == 'Item Master') {
                      return const ItemMasterScreen();
                    }
                    
                    if (selectedNavItem == 'Item Management') {
                      return const ItemManagementScreen();
                    }
                    
                    if (selectedNavItem == 'Vendor Management') {
                      return const VendorManagementScreen();
                    }
                    
                    if (selectedNavItem == 'Users & Roles') {
                      return const UsersRolesScreen();
                    }
                    
                    if (selectedNavItem == 'Procurement') {
                      return const ProcurementScreen();
                    }
                    
                    if (selectedNavItem == 'GRN & Receiving') {
                      return const GrnReceivingScreen();
                    }
                    
                    if (selectedNavItem == 'Inventory Control') {
                      return const InventoryControlScreen();
                    }
                    
                    if (selectedNavItem == 'Storage Locations') {
                      return const StorageLocationsScreen();
                    }
                    
                    if (selectedNavItem == 'Traceability') {
                      return const TraceabilityScreen();
                    }
                    
                    if (selectedNavItem == 'Approvals') {
                      return const ApprovalsScreen();
                    }
                    
                    if (selectedNavItem == 'Reports') {
                      return const ReportsScreen();
                    }
                    
                    if (selectedNavItem == 'Settings') {
                      return const SettingsAdminScreen();
                    }
                    
                    // Default Dashboard view
                    return Column(
                  children: [
                    // Header with search
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getScreenPadding(context).horizontal / 2),
                      color: Colors.white,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final isSmallScreen = screenWidth < 700;
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Menu icon - always visible
                                  IconButton(
                                    icon: const Icon(Icons.menu),
                                    onPressed: () {
                                      if (showDrawer) {
                                        Scaffold.of(context).openDrawer();
                                      } else {
                                        Provider.of<DashboardProvider>(context, listen: false).toggleSidebar();
                                      }
                                    },
                                    tooltip: 'Toggle menu',
                                  ),
                                  if (!isSmallScreen)
                                    Text(
                                      'Dashboard',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getTitleFontSize(context),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                ],
                              ),
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: isSmallScreen ? double.infinity : 300,
                                  ),
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: ResponsiveHelper.getScreenPadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary cards
                            const SummaryCards(),
                            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                            // Charts row 1 - responsive
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = ResponsiveHelper.isMobile(context);
                                final isTablet = ResponsiveHelper.isTablet(context);
                                
                                if (isMobile) {
                                  return Column(
                                    children: [
                                      const InventoryByCategoryChart(),
                                      const SizedBox(height: 16),
                                      const StockStatusChart(),
                                    ],
                                  );
                                } else if (isTablet) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(child: InventoryByCategoryChart()),
                                      const SizedBox(width: 16),
                                      const Expanded(child: StockStatusChart()),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      const Expanded(child: InventoryByCategoryChart()),
                                      const SizedBox(width: 16),
                                      const Expanded(child: StockStatusChart()),
                                    ],
                                  );
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                            // Charts row 2 - responsive
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = ResponsiveHelper.isMobile(context);
                                final isTablet = ResponsiveHelper.isTablet(context);
                                
                                if (isMobile) {
                                  return Column(
                                    children: [
                                      const InventoryValueByCategoryChart(),
                                      const SizedBox(height: 16),
                                      const PurchaseOrdersStatusChart(),
                                    ],
                                  );
                                } else if (isTablet) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(child: InventoryValueByCategoryChart()),
                                      const SizedBox(width: 16),
                                      const Expanded(child: PurchaseOrdersStatusChart()),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      const Expanded(child: InventoryValueByCategoryChart()),
                                      const SizedBox(width: 16),
                                      const Expanded(child: PurchaseOrdersStatusChart()),
                                    ],
                                  );
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                            // Transactions table
                            const TransactionsTable(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

