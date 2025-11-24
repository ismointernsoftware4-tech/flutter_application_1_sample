import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import 'stock_audits_screen.dart';
import 'stock_adjustment_screen.dart';
import 'internal_transfers_screen.dart';
import 'branch_transfers_screen.dart';
import 'stock_returns_screen.dart';
import 'internal_consumption_screen.dart';
import '../providers/dashboard_provider.dart';

class InventoryControlScreen extends StatelessWidget {
  const InventoryControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(),
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
                        child: _auditsCard(provider.recentAudits),
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

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inventory Control',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            width: 280,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
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
                  color: Colors.black.withOpacity(0.03),
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
        MaterialPageRoute(builder: (_) => destination!),
      );
    }
  }

  Widget _auditsCard(List<InventoryAudit> audits) {
    return _sectionCard(
      title: 'Recent Audits',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('View All'),
      ),
      child: Column(
        children: audits
            .map(
              (audit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        audit.date,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        audit.type,
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
      child: Column(
        children: adjustments
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green.shade600;
        break;
      case 'approved':
        color = Colors.green.shade600;
        break;
      case 'pending approval':
        color = Colors.orange.shade600;
        break;
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

