import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../shared/widgets/sidebar.dart';
import '../../../shared/widgets/summary_cards.dart';
import '../../../shared/widgets/charts.dart';
import '../../../shared/widgets/transactions_table.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../item_master/screens/item_master_screen.dart';
import '../../procurement/screens/procurement_screen.dart';
import '../../grn_receiving/screens/grn_receiving_screen.dart';
import 'inventory_control_screen.dart';
import '../../storage_locations/screens/storage_locations_screen.dart';
import '../../traceability/screens/traceability_screen.dart';
import '../../approvals/screens/approvals_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../settings/screens/settings_admin_screen.dart';
import 'item_management_screen.dart';
import '../../vendor_management/screens/vendor_management_screen.dart';

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
                child: Navigator(
                  key: provider.contentNavigatorKey,
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(
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
                                  child: ShadInput(
                                    placeholder: const Text('Search...'),
                                  ),
                                ),
                              ),
                            ],
                          )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: -0.05, end: 0);
                        },
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        // Keep top/bottom/left padding, but remove right so content
                        // (including Item Master table) can reach the screen edge.
                        padding: ResponsiveHelper
                            .getScreenPadding(context)
                            .copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary cards
                            const SummaryCards()
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 100.ms),
                            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                            // Charts row 1 - responsive
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = ResponsiveHelper.isMobile(context);
                                final isTablet = ResponsiveHelper.isTablet(context);
                                
                                if (isMobile) {
                                  return Column(
                                    children: [
                                      const InventoryByCategoryChart()
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 200.ms)
                                        .slideY(begin: 0.1, end: 0),
                                      const SizedBox(height: 16),
                                      const StockStatusChart()
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 300.ms)
                                        .slideY(begin: 0.1, end: 0),
                                    ],
                                  );
                                } else if (isTablet) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: const InventoryByCategoryChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 200.ms)
                                          .slideX(begin: -0.1, end: 0),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: const StockStatusChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 300.ms)
                                          .slideX(begin: 0.1, end: 0),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: const InventoryByCategoryChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 200.ms)
                                          .slideX(begin: -0.1, end: 0),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: const StockStatusChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 300.ms)
                                          .slideX(begin: 0.1, end: 0),
                                      ),
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
                                      const InventoryValueByCategoryChart()
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 400.ms)
                                        .slideY(begin: 0.1, end: 0),
                                      const SizedBox(height: 16),
                                      const PurchaseOrdersStatusChart()
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 500.ms)
                                        .slideY(begin: 0.1, end: 0),
                                    ],
                                  );
                                } else if (isTablet) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: const InventoryValueByCategoryChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 400.ms)
                                          .slideX(begin: -0.1, end: 0),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: const PurchaseOrdersStatusChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 500.ms)
                                          .slideX(begin: 0.1, end: 0),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: const InventoryValueByCategoryChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 400.ms)
                                          .slideX(begin: -0.1, end: 0),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: const PurchaseOrdersStatusChart()
                                          .animate()
                                          .fadeIn(duration: 500.ms, delay: 500.ms)
                                          .slideX(begin: 0.1, end: 0),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                            // Transactions table
                            const TransactionsTable()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 600.ms)
                              .slideY(begin: 0.1, end: 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                          .animate()
                          .fadeIn(duration: 300.ms);
                      },
                      settings: settings,
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

