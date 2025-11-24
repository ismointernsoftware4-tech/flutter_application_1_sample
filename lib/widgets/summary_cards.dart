import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = Provider.of<DashboardProvider>(context).summary;

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
      padding: const EdgeInsets.all(20),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
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




