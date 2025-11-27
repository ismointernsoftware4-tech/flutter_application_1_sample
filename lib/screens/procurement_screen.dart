import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../providers/procurement_provider.dart';
import '../providers/purchase_requisition_list_provider.dart';
import '../widgets/vendor_card.dart';
import '../widgets/create_purchase_requisition_screen.dart';
import '../widgets/create_purchase_order_screen.dart';
import '../widgets/create_vendor_screen.dart';
import '../utils/responsive_helper.dart';

class ProcurementScreen extends StatelessWidget {
  const ProcurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProcurementProvider()),
        ChangeNotifierProvider(
          create: (_) => PurchaseRequisitionListProvider(),
        ),
      ],
      child: const _ProcurementView(),
    );
  }
}

class _ProcurementView extends StatelessWidget {
  const _ProcurementView();

  @override
  Widget build(BuildContext context) {
    final procurementProvider = context.watch<ProcurementProvider>();
    final showForm = procurementProvider.showCreateForm;
    final activeTab = procurementProvider.activeTab;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: showForm
                  ? _getFormWidget(activeTab)
                  : _mainContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFormWidget(int activeTab) {
    switch (activeTab) {
      case 0:
        return const CreatePurchaseRequisitionScreen(
          key: ValueKey('create-pr-form'),
        );
      case 1:
        return const CreatePurchaseOrderScreen(key: ValueKey('create-po-form'));
      case 2:
        return const CreateVendorScreen(key: ValueKey('create-vendor-form'));
      default:
        return const CreatePurchaseRequisitionScreen(
          key: ValueKey('create-pr-form'),
        );
    }
  }

  Widget _mainContent(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final contentWidth = _contentMaxWidth(context);

    return SingleChildScrollView(
      key: const ValueKey('procurement-main'),
      padding: EdgeInsets.only(
        left: screenPadding.left,
        right: screenPadding.right,
        top: 0,
        bottom: screenPadding.bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: contentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabs(context),
              _buildActionBar(context),
              _buildTabContent(context, dashboardProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);
    final contentWidth = _contentMaxWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.left,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Menu icon for mobile/tablet
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open menu',
                    ),
                    Expanded(
                      child: Text(
                        'Procurement',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
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
              ],
            )
          : Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: contentWidth,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 640;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isTablet)
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                                tooltip: 'Open menu',
                              ),
                            Text(
                              'Procurement',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getTitleFontSize(
                                  context,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isSmallScreen
                                  ? double.infinity
                                  : searchWidth,
                            ),
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
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  double _contentMaxWidth(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return double.infinity;
    } else if (ResponsiveHelper.isTablet(context)) {
      return 920;
    }
    return 1100;
  }

  Widget _buildTabs(BuildContext context) {
    final procurementProvider = context.watch<ProcurementProvider>();
    final activeTab = procurementProvider.activeTab;
    final tabs = ['Purchase Requisitions', 'Purchase Orders', 'Vendors'];
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isActive = activeTab == index;
                return GestureDetector(
                  onTap: () =>
                      context.read<ProcurementProvider>().setActiveTab(index),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isMobile && tabs[index].length > 15
                              ? tabs[index].split(' ').first
                              : tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.blue.shade700
                                : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isActive)
                          Container(
                            height: 3,
                            width: 40,
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
            ),
          )
        : Row(
            children: List.generate(tabs.length, (index) {
              final isActive = activeTab == index;
              return GestureDetector(
                onTap: () =>
                    context.read<ProcurementProvider>().setActiveTab(index),
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
                          color: isActive
                              ? Colors.blue.shade700
                              : Colors.grey[500],
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
    final buttonLabel = context.watch<ProcurementProvider>().primaryButtonLabel;
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _outlineButton(Icons.filter_list, 'Filter', () {}),
                  _outlineButton(Icons.download, 'Export', () {}),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProcurementProvider>().openCreateForm();
                },
                icon: const Icon(Icons.add),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          )
        : Row(
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
                onPressed: () {
                  context.read<ProcurementProvider>().openCreateForm();
                },
                icon: const Icon(Icons.add),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  elevation: 0,
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
        return _buildRequisitionTableFromJson(context);
      case 1:
        return _buildPurchaseOrderTable(dashboardProvider.purchaseOrders);
      default:
        return _buildVendorGrid(dashboardProvider.vendors);
    }
  }

  /// JSON-driven Purchase Requisition table (no static rows or headers).
  Widget _buildRequisitionTableFromJson(BuildContext context) {
    return Consumer<PurchaseRequisitionListProvider>(
      builder: (context, prProvider, _) {
        if (prProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final columns = prProvider.columns;
        final rows = prProvider.rows;

        if (columns.isEmpty || rows.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No purchase requisitions defined in schema.'),
            ),
          );
        }

        final headers = columns.map(_labelForKey).toList();

        final widgetRows = rows.map((row) {
          return columns.map((key) {
            if (key == 'prId') {
              return _linkText(row.valueFor(key));
            }

            if (key == 'priority' || key == 'status') {
              final raw = row.raw[key];
              String label = row.valueFor(key);
              Color color;

              if (raw is Map && raw['color'] != null) {
                color = _schemaColor(raw['color'].toString(), key);
              } else {
                color = key == 'priority'
                    ? _priorityColor(label)
                    : _statusColor(label);
              }

              return _statusChip(label, color);
            }

            if (key == 'actions') {
              return IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.center,
              );
            }

            return _cellText(row.valueFor(key));
          }).toList();
        }).toList();

        return _buildTableContainer(headers: headers, rows: widgetRows);
      },
    );
  }

  Widget _buildPurchaseOrderTable(List<PurchaseOrder> data) {
    return _buildTableContainer(
      headers: const [
        'PO ID',
        'Vendor',
        'Date',
        'Delivery Date',
        'Total Amount',
        'Status',
        'Actions',
      ],
      rows: data.map((item) {
        return [
          _linkText(item.id),
          _cellText(item.vendor),
          _cellText(item.date),
          _cellText(item.deliveryDate ?? ''),
          _cellText(item.amount),
          _statusChip(item.status, _statusColor(item.status)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.center,
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.description_outlined, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.center,
                tooltip: 'Edit',
              ),
            ],
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
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
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
            (vendor) => SizedBox(width: 320, child: VendorCard(vendor: vendor)),
          )
          .toList(),
    );
  }

  Widget _buildTableContainer({
    required List<String> headers,
    required List<List<Widget>> rows,
  }) {
    // Calculate flex values for each column
    final flexValues = headers.map((header) {
      if (header == 'PR ID' || header == 'PO ID') return 2;
      if (header == 'Date' || header == 'Delivery Date') return 2;
      if (header == 'Total Amount' || header == 'Amount') return 3;
      if (header == 'Status' || header == 'Priority') return 2;
      if (header == 'Actions') return 2;
      return 3;
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.02),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: List.generate(headers.length, (index) {
                return Expanded(
                  flex: flexValues[index],
                  child: Align(
                    alignment: headers[index] == 'Actions'
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: Text(
                      headers[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1),
          // Data rows
          ...rows.map(
            (cells) => Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                children: List.generate(cells.length, (index) {
                  return Expanded(
                    flex: flexValues[index],
                    child: Align(
                      alignment: headers[index] == 'Actions'
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: cells[index],
                    ),
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
        fontSize: 14,
        decoration: TextDecoration.underline,
        decorationColor: Colors.blue[700],
        decorationThickness: 1.5,
      ),
    );
  }

  Widget _cellText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.2,
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
        return Colors.grey.shade500;
      case 'issued':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  /// Convert simple color keywords from JSON into real [Color]s.
  Color _schemaColor(String code, String key) {
    final normalized = code.toLowerCase().trim();

    switch (normalized) {
      case 'red':
        return Colors.red.shade600;
      case 'green':
        return Colors.green.shade600;
      case 'yellow':
      case 'orange':
        return Colors.orange.shade600;
      case 'blue':
        return Colors.blue.shade600;
      default:
        // Fallback to existing helpers based on key type.
        return key == 'priority'
            ? _priorityColor(normalized)
            : _statusColor(normalized);
    }
  }

  /// Human-friendly label from a JSON key (e.g., prId -> PR ID).
  String _labelForKey(String key) {
    switch (key) {
      case 'prId':
        return 'PR ID';
      case 'requestedBy':
        return 'Requested By';
      case 'date':
        return 'Date';
      case 'department':
        return 'Department';
      case 'priority':
        return 'Priority';
      case 'status':
        return 'Status';
      case 'actions':
        return 'Actions';
      default:
        // Basic camelCase / snake_case to Title Case.
        final buffer = StringBuffer();
        for (var i = 0; i < key.length; i++) {
          final char = key[i];
          final isUpper =
              char.toUpperCase() == char && char.toLowerCase() != char;
          if (i == 0) {
            buffer.write(char.toUpperCase());
          } else if (isUpper || char == '_' || char == '-') {
            buffer.write(' ');
            if (char != '_' && char != '-') buffer.write(char);
          } else {
            buffer.write(char);
          }
        }
        return buffer.toString();
    }
  }

  Widget _outlineButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
