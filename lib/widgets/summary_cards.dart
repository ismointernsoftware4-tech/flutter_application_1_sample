import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = Provider.of<DashboardProvider>(context).summary;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      // Stack vertically on mobile
      return Column(
        children: [
          _SummaryCard(
            icon: Icons.inventory_2,
            iconColor: Colors.blue,
            title: 'Total Items',
            value: summary.totalItems.toString(),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.warning,
            iconColor: Colors.orange,
            title: 'Low Stock Alerts',
            value: summary.lowStockAlerts.toString(),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.description,
            iconColor: Colors.purple,
            title: 'Pending POs',
            value: summary.pendingPOs.toString(),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Pending Approvals',
            value: summary.pendingApprovals.toString(),
          ),
        ],
      );
    } else if (isTablet) {
      // 2x2 grid on tablet
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.inventory_2,
                  iconColor: Colors.blue,
                  title: 'Total Items',
                  value: summary.totalItems.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.warning,
                  iconColor: Colors.orange,
                  title: 'Low Stock Alerts',
                  value: summary.lowStockAlerts.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.description,
                  iconColor: Colors.purple,
                  title: 'Pending POs',
                  value: summary.pendingPOs.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: 'Pending Approvals',
                  value: summary.pendingApprovals.toString(),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Desktop: original Row layout
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.inventory_2,
              iconColor: Colors.blue,
              title: 'Total Items',
              value: summary.totalItems.toString(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title: 'Low Stock Alerts',
              value: summary.lowStockAlerts.toString(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              icon: Icons.description,
              iconColor: Colors.purple,
              title: 'Pending POs',
              value: summary.pendingPOs.toString(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Pending Approvals',
              value: summary.pendingApprovals.toString(),
            ),
          ),
        ],
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? 40 : 48,
            height: ResponsiveHelper.isMobile(context) ? 40 : 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: ResponsiveHelper.isMobile(context) ? 20 : 24,
            ),
          ),
          SizedBox(width: ResponsiveHelper.isMobile(context) ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 11 : 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




