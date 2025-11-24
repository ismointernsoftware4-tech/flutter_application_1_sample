import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../providers/procurement_provider.dart';
import '../widgets/vendor_card.dart';

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

class _ProcurementView extends StatelessWidget {
  const _ProcurementView();

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(context),
                  const SizedBox(height: 20),
                  _buildActionBar(context),
                  const SizedBox(height: 24),
                  _buildTabContent(context, dashboardProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Procurement',
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

  Widget _buildTabs(BuildContext context) {
    final procurementProvider = context.watch<ProcurementProvider>();
    final activeTab = procurementProvider.activeTab;
    final tabs = ['Purchase Requisitions', 'Purchase Orders', 'Vendors'];
    return Row(
      children: List.generate(tabs.length, (index) {
        final isActive = activeTab == index;
        return GestureDetector(
          onTap: () => context.read<ProcurementProvider>().setActiveTab(index),
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
                    color: isActive ? Colors.blue.shade700 : Colors.grey[500],
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

  Widget _buildActionBar(BuildContext context) {
    final buttonLabel =
        context.watch<ProcurementProvider>().primaryButtonLabel;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _outlineButton(Icons.filter_list, 'Filter', () {}),
            const SizedBox(width: 12),
            _outlineButton(Icons.download, 'Export', () {}),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: Text(buttonLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    DashboardProvider dashboardProvider,
  ) {
    final activeTab = context.watch<ProcurementProvider>().activeTab;
    switch (activeTab) {
      case 0:
        return _buildRequisitionTable(dashboardProvider.purchaseRequisitions);
      case 1:
        return _buildPurchaseOrderTable(dashboardProvider.purchaseOrders);
      default:
        return _buildVendorGrid(dashboardProvider.vendors);
    }
  }

  Widget _buildRequisitionTable(List<PurchaseRequisition> data) {
    return _buildTableContainer(
      headers: const [
        'PR ID',
        'Requested By',
        'Department',
        'Date',
        'Priority',
        'Status',
        'Actions'
      ],
      rows: data.map((item) {
        return [
          _linkText(item.id),
          Text(item.requestedBy),
          Text(item.department),
          Text(item.date),
          _statusChip(item.priority, _priorityColor(item.priority)),
          _statusChip(item.status, _statusColor(item.status)),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () {},
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildPurchaseOrderTable(List<PurchaseOrder> data) {
    return _buildTableContainer(
      headers: const ['PO ID', 'Vendor', 'Date', 'Amount', 'Status', 'Actions'],
      rows: data.map((item) {
        return [
          _linkText(item.id),
          Text(item.vendor),
          Text(item.date),
          Text(item.amount),
          _statusChip(item.status, _statusColor(item.status)),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () {},
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildVendorGrid(List<Vendor> vendors) {
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
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text('No vendors available'),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: vendors
          .map(
            (vendor) => SizedBox(
              width: 320,
              child: VendorCard(vendor: vendor),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTableContainer({
    required List<String> headers,
    required List<List<Widget>> rows,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: headers
                  .map(
                    (header) => Expanded(
                      flex: header == 'PR ID' || header == 'PO ID' ? 2 : 3,
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          ...rows.map(
            (cells) => Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: List.generate(cells.length, (index) {
                  return Expanded(
                    flex: headers[index] == 'PR ID' ||
                            headers[index] == 'PO ID'
                        ? 2
                        : 3,
                    child: cells[index],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.blue[700],
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red.shade400;
      case 'routine':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending approval':
        return Colors.orange.shade600;
      case 'approved':
        return Colors.green.shade600;
      case 'draft':
        return Colors.blueGrey.shade400;
      case 'issued':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _outlineButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

