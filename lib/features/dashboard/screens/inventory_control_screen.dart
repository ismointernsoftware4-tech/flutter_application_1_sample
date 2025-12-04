import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../stock_management/models/stock_models.dart';
import '../models/dashboard_models.dart';
import '../../../shared/utils/animated_routes.dart';
import '../../stock_management/screens/stock_audits_screen.dart';
import '../../stock_management/screens/stock_adjustment_screen.dart';
import '../../stock_management/screens/internal_transfers_screen.dart';
import '../../stock_management/screens/branch_transfers_screen.dart';
import '../../stock_management/screens/stock_returns_screen.dart';
import '../../stock_management/screens/internal_consumption_screen.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/utils/responsive_helper.dart';

class InventoryControlScreen extends StatelessWidget {
  const InventoryControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    // Ensure all related inventory data (audits, transfers, returns,
    // consumptions, adjustments) is loaded so that the detail screens
    // show existing dynamically created rows in their tables.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().ensureInventoryControlDataLoaded();
    });

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _auditsCard(context),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _adjustmentsCard(provider.recentAdjustments),
              ),
            ],
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
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMobile || isTablet)
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: 'Open menu',
                      ),
                    if (!isSmallScreen)
                      Expanded(
                        child: Text(
                          'Inventory Control',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getTitleFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
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
    );
  }

  Widget _quickActions(
    BuildContext context,
    List<InventoryQuickAction> actions,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => _handleQuickActionTap(action.navTarget, context),
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
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
                    color: action.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.iconColor,
                    size: 28,
                  ),
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
      Navigator.of(context).push(
        AnimatedRoutes.slideRight(destination),
      );
    }
  }

  Widget _auditsCard(BuildContext context) {
    final firebase = context.read<DashboardProvider>().firebaseService;

    return _sectionCard(
      title: 'Recent Audits',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('View All'),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firebase.getStockAuditsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Error loading audits',
                style: TextStyle(color: Colors.red[400], fontSize: 12),
              ),
            );
          }

          final docs = snapshot.data ?? const [];

          // Map Firestore docs → InventoryAudit model
          final audits = docs.map((data) {
            final date =
                (data['date'] ?? data['auditDate'] ?? '').toString();
            final type = (data['type'] ?? '').toString();
            final status = (data['status'] ?? 'Pending').toString();
            final rawDiscrepancies = data['discrepancies'];
            final discrepancies = rawDiscrepancies is int
                ? rawDiscrepancies
                : int.tryParse(rawDiscrepancies?.toString() ?? '0') ?? 0;

            return InventoryAudit(
              date: date,
              type: type,
              status: status,
              discrepancies: discrepancies,
            );
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = ResponsiveHelper.isMobile(context);
              final visibleAudits =
                  audits.take(isMobile ? 3 : audits.length).toList();

              if (visibleAudits.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No recent audits',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // MOBILE: stacked card-style items
              if (isMobile) {
                return Column(
                  children: visibleAudits
                      .map((audit) => _buildMobileAuditItem(context, audit))
                      .toList(),
                );
              }

              // DESKTOP/TABLET: keep row layout
              return Column(
                children: visibleAudits
                    .map(
                      (audit) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                audit.date,
                                style: const TextStyle(
                                    color: Colors.black87),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                audit.type,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _statusChip(audit.status),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${audit.discrepancies}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _adjustmentsCard(List<InventoryAdjustment> adjustments) {
    return _sectionCard(
      title: 'Recent Adjustments',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('View All'),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          final visibleAdjustments =
              adjustments.take(isMobile ? 3 : adjustments.length).toList();

          if (visibleAdjustments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No recent adjustments',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (isMobile) {
            return Column(
              children: visibleAdjustments
                  .map((adj) => _buildMobileAdjustmentItem(context, adj))
                  .toList(),
            );
          }

          return Column(
            children: visibleAdjustments
                .map(
                  (adjustment) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            adjustment.date,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            adjustment.reason,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _statusChip(adjustment.status),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        },
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
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
              
              if (isMobile) {
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
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Mobile card for a single recent audit
  Widget _buildMobileAuditItem(BuildContext context, InventoryAudit audit) {
    final color = _statusColor(audit.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On very narrow cards, hide the vertical status pill to avoid overflow
          final isVeryNarrow = constraints.maxWidth < 120;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audit.date,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${audit.discrepancies}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  audit.type,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isVeryNarrow) ...[
                const SizedBox(width: 8),
                RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      audit.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Mobile card for a single recent adjustment
  Widget _buildMobileAdjustmentItem(
    BuildContext context,
    InventoryAdjustment adjustment,
  ) {
    final color = _statusColor(adjustment.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On very narrow cards, hide the vertical status pill to avoid overflow
          final isVeryNarrow = constraints.maxWidth < 120;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adjustment.date,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adjustment.quantity,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  adjustment.reason,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isVeryNarrow) ...[
                const SizedBox(width: 8),
                RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      adjustment.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'approved':
        return Colors.green.shade600;
      case 'pending approval':
        return Colors.orange.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'in transit':
        return Colors.blue.shade600;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

