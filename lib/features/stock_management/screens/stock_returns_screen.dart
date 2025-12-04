import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../models/stock_models.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/table_column_visibility_provider.dart';
import '../../../shared/widgets/schema_table.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/utils/animated_routes.dart';
import 'create_stock_return_screen.dart';

class StockReturnsScreen extends StatelessWidget {
  const StockReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final returns = context.watch<DashboardProvider>().stockReturns;
    return ChangeNotifierProvider(
      create: (_) => TableColumnVisibilityProvider('stock_return'),
        child: SafeArea(
          child: Column(
            children: [
              _header(context, 'Stock Returns to Vendors'),
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: _returnsTable(context, returns),
                ),
              ),
            ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _returnsTable(BuildContext context, List<StockReturnRecord> returns) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Show cards on mobile, table on desktop/tablet
    if (isMobile) {
      return _buildMobileCardView(returns);
    }
    
    // Convert StockReturnRecord objects to Map<String, dynamic>
    final mappedData = returns
        .map<Map<String, dynamic>>(
          (ret) => {
            'id': ret.id,
            'date': ret.date,
            'vendor': ret.vendor,
            'item': ret.item,
            'quantity': ret.quantity.toString(),
            'reason': ret.reason,
            'status': ret.status,
          },
        )
        .toList();

    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
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
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Process returns for damaged or expired goods.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 16),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          AnimatedRoutes.slideRight(
                            const CreateStockReturnScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        isMobile ? 'Create' : 'Create Return',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Consumer<TableColumnVisibilityProvider>(
            builder: (context, columnProvider, _) {
              if (columnProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final visibleColumns = columnProvider.visibleColumns;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Manage Columns button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (dialogContext) {
                                  final isDialogMobile =
                                      ResponsiveHelper.isMobile(dialogContext);
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.symmetric(
                                      horizontal: isDialogMobile ? 12 : 80,
                                      vertical: isDialogMobile ? 12 : 40,
                                    ),
                                    contentPadding: const EdgeInsets.all(24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    content: SizedBox(
                                      width: isDialogMobile ? double.infinity : 640,
                                      child: _InlineColumnPicker(
                                        provider: columnProvider,
                                        title: 'Manage Stock Return Columns',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.view_column),
                            label: const Text('Manage Columns'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Constrain table height to avoid unbounded viewport errors
                    SizedBox(
                      height: 400,
                      child: SchemaTable<Map<String, dynamic>>(
                        items: mappedData,
                        columns: visibleColumns,
                        columnWidth: isTablet ? 160 : 200,
                        emptyLabel: 'No stock returns found.',
                        valueBuilder: (item, column) =>
                            _resolveColumnValue(item, column.key),
                        actionsBuilder: (item) =>
                            _buildTableActions(context, item),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _resolveColumnValue(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return '';
    return value.toString();
  }

  List<Widget> _buildTableActions(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return [
      TextButton(
        onPressed: () {},
        child: const Text('View'),
      ),
    ];
  }

  // Mobile card view for Stock Returns
  Widget _buildMobileCardView(List<StockReturnRecord> returns) {
    if (returns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No stock returns found.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final ret = returns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ret.id,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ret.item,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ret.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ret.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMobileInfoRow('Date', ret.date),
                    _buildMobileInfoRow('Vendor', ret.vendor),
                    _buildMobileInfoRow('Quantity', ret.quantity.toString()),
                    _buildMobileInfoRow('Reason', ret.reason),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('completed') || lower.contains('approved')) {
      return Colors.green;
    } else if (lower.contains('pending')) {
      return Colors.orange;
    }
    return Colors.blueGrey;
  }
}

class _InlineColumnPicker extends StatelessWidget {
  const _InlineColumnPicker({
    required this.provider,
    required this.title,
  });

  final TableColumnVisibilityProvider provider;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: provider,
          builder: (context, _) {
            if (provider.isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final columns = provider.columns;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: provider.resetToDefault,
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: columns
                      .map(
                        (column) => FilterChip(
                          label: Text(column.label),
                          selected: column.visible,
                          onSelected: (value) =>
                              provider.toggleColumn(column.key, value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: columns.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final column = columns[index];
                      return SwitchListTile(
                        title: Text(column.label),
                        subtitle: Text(column.description),
                        value: column.visible,
                        onChanged: (value) =>
                            provider.toggleColumn(column.key, value),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.setAll(false),
                        icon: const Icon(Icons.visibility_off),
                        label: const Text('Hide All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.setAll(true),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show All'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
