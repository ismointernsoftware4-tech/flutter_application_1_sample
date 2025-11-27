import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';
import 'branch_transfers_screen.dart';
import 'internal_consumption_screen.dart';
import 'internal_transfers_screen.dart';
import 'stock_adjustment_screen.dart';
import 'stock_audits_screen.dart';
import 'stock_returns_screen.dart';

class InventoryControlScreen extends StatelessWidget {
  const InventoryControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _quickActions(context, provider.inventoryActions),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isStacked = constraints.maxWidth < 900;
                      if (isStacked) {
                        return Column(
                          children: [
                            _auditsCard(provider.recentAudits),
                            const SizedBox(height: 20),
                            _adjustmentsCard(provider.recentAdjustments),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _auditsCard(provider.recentAudits)),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _adjustmentsCard(provider.recentAdjustments),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 700;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isMobile || isTablet)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open menu',
                    ),
                  Text(
                    'Inventory Control',
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
                    maxWidth: isSmallScreen ? double.infinity : 320,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _quickActions(
    BuildContext context,
    List<InventoryQuickAction> actions,
  ) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final cardWidth = isMobile ? double.infinity : 150.0;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => _handleQuickActionTap(action.navTarget, context),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        action.backgroundColor,
                        action.backgroundColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(action.icon, color: action.iconColor, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleQuickActionTap(String target, BuildContext context) {
    Widget? destination;
    switch (target) {
      case 'Stock Audits':
        destination = const StockAuditsScreen();
        break;
      case 'Stock Adjustment':
        destination = const StockAdjustmentScreen();
        break;
      case 'Internal Transfers':
        destination = const InternalTransfersScreen();
        break;
      case 'Branch Transfers':
        destination = const BranchTransfersScreen();
        break;
      case 'Stock Returns':
        destination = const StockReturnsScreen();
        break;
      case 'Internal Consumption':
        destination = const InternalConsumptionScreen();
        break;
    }
    if (destination != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => destination!));
    }
  }

  Widget _auditsCard(List<InventoryAudit> audits) {
    return _sectionCard(
      title: 'Recent Audits',
      trailing: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          'View All',
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          _tableHeader(const ['Date', 'Type', 'Status', 'Discrepancies']),
          const Divider(height: 1),
          ...audits.map(
            (audit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      audit.date,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      audit.type,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(flex: 3, child: _statusChip(audit.status)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${audit.discrepancies}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adjustmentsCard(List<InventoryAdjustment> adjustments) {
    return _sectionCard(
      title: 'Recent Adjustments',
      trailing: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          'View All',
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          _tableHeader(const ['Date', 'Reason', 'Status']),
          const Divider(height: 1),
          ...adjustments.map(
            (adjustment) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      adjustment.date,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      adjustment.reason,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(flex: 3, child: _statusChip(adjustment.status)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = ResponsiveHelper.isMobile(context);
              final hasBoundedWidth =
                  constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
              final shouldStack = isMobile || !hasBoundedWidth;

              if (shouldStack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 12),
                      trailing,
                    ],
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _tableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final flex = index == labels.length - 1 ? 2 : 3;
          return Expanded(
            flex: flex,
            child: Text(
              labels[index],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        color = Colors.green.shade600;
        break;
      case 'pending approval':
      case 'pending':
        color = Colors.orange.shade600;
        break;
      case 'in transit':
        color = Colors.blue.shade600;
        break;
      default:
        color = Colors.blueGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
