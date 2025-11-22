import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/summary_cards.dart';
import '../widgets/charts.dart';
import '../widgets/transactions_table.dart';
import '../providers/dashboard_provider.dart';
import 'item_master_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                final selectedNavItem = provider.selectedNavItem;
                
                if (selectedNavItem == 'Item Master') {
                  return const ItemMasterScreen();
                }
                
                // Default Dashboard view
                return Column(
                  children: [
                    // Header with search
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            width: 300,
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
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary cards
                            const SummaryCards(),
                            const SizedBox(height: 24),
                            // Charts row 1
                            Row(
                              children: [
                                const Expanded(child: InventoryByCategoryChart()),
                                const SizedBox(width: 16),
                                const Expanded(child: StockStatusChart()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Charts row 2
                            Row(
                              children: [
                                const Expanded(child: InventoryValueByCategoryChart()),
                                const SizedBox(width: 16),
                                const Expanded(child: PurchaseOrdersStatusChart()),
                              ],
                            ),
                            const SizedBox(height: 24),
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
  }
}

