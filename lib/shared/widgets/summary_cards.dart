import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
          )
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.warning,
            iconColor: Colors.orange,
            title: 'Low Stock Alerts',
            value: summary.lowStockAlerts.toString(),
          )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.description,
            iconColor: Colors.purple,
            title: 'Pending POs',
            value: summary.pendingPOs.toString(),
          )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Pending Approvals',
            value: summary.pendingApprovals.toString(),
          )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0),
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
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 0.ms)
                  .slideY(begin: -0.1, end: 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.warning,
                  iconColor: Colors.orange,
                  title: 'Low Stock Alerts',
                  value: summary.lowStockAlerts.toString(),
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: -0.1, end: 0),
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
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: -0.1, end: 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: 'Pending Approvals',
                  value: summary.pendingApprovals.toString(),
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: -0.1, end: 0),
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
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: 0.ms)
              .slideY(begin: -0.1, end: 0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title: 'Low Stock Alerts',
              value: summary.lowStockAlerts.toString(),
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.1, end: 0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              icon: Icons.description,
              iconColor: Colors.purple,
              title: 'Pending POs',
              value: summary.pendingPOs.toString(),
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: -0.1, end: 0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Pending Approvals',
              value: summary.pendingApprovals.toString(),
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: -0.1, end: 0),
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
    return ShadCard(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
        child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? 40 : 48,
            height: ResponsiveHelper.isMobile(context) ? 40 : 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
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
      ),
    );
  }
}




