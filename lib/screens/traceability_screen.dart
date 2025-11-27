import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/transaction_traceability_provider.dart';
import '../utils/responsive_helper.dart';

class TraceabilityScreen extends StatelessWidget {
  const TraceabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionTraceabilityProvider>();
    final records = provider.records;
    final columns = provider.columns;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                children: [
                  _filters(),
                  const SizedBox(height: 20),
                  _table(
                    columns: columns,
                    records: records,
                    isLoading: provider.isLoading,
                    error: provider.error,
                    onRetry: provider.reload,
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
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);
    
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
                  if (!isSmallScreen)
                    Text(
                      'Transaction Traceability',
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
                    maxWidth: isSmallScreen ? double.infinity : searchWidth,
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          
          if (isMobile) {
            // Stack vertically on mobile
            return Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by Item, Reference, or Batch...',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'All Types',
                      labelStyle: TextStyle(color: Colors.grey[800]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.swap_vert, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Filter'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Export Log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey[800],
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Original Row for desktop/tablet
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Item, Reference, or Batch...',
                      labelStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: SizedBox(
                    width: 200,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'All Types',
                        labelStyle: TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.swap_vert, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Filter'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Export Log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey[800],
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _table({
    required List<String> columns,
    required List<TraceabilityRecord> records,
    required bool isLoading,
    required String? error,
    required Future<void> Function() onRetry,
  }) {
    final displayColumns = _buildColumns(columns);

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
              children: displayColumns
                  .map(
                    (column) => Expanded(
                      child: Text(
                        column.label,
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
          if (isLoading)
            SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey[700],
                ),
              ),
            )
          else if (error != null)
            _tableMessage(
              message: error,
              actionLabel: 'Retry',
              onPressed: onRetry,
            )
          else if (records.isEmpty)
            _tableMessage(
              message: 'No traceability data available.',
              onPressed: onRetry,
              actionLabel: 'Reload',
            )
          else
            ...records.map(
              (record) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: displayColumns
                      .map(
                        (column) => Expanded(
                          child: _buildCell(column.key, record),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(String key, TraceabilityRecord record) {
    switch (key) {
      case 'dateTime':
        return Text(record.dateTime);
      case 'type':
        return Row(
          children: [
            Icon(
              _typeIcon(record.type),
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                record.type,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case 'reference':
        return _linkText(record.reference);
      case 'item':
        return Text(record.itemDetails);
      case 'quantity':
        return Text(
          record.quantity,
          style: TextStyle(
            color:
                record.quantity.startsWith('+') ? Colors.green : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'userLocation':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.user),
            Text(
              record.location,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        );
      case 'user':
        return Text(record.user);
      case 'location':
        return Text(record.location);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _tableMessage({
    required String message,
    required Future<void> Function() onPressed,
    required String actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onPressed();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  List<_TraceabilityColumn> _buildColumns(List<String> columns) {
    if (columns.isEmpty) {
      return const [
        _TraceabilityColumn('dateTime', 'Date & Time'),
        _TraceabilityColumn('type', 'Type'),
        _TraceabilityColumn('reference', 'Reference'),
        _TraceabilityColumn('item', 'Item Details'),
        _TraceabilityColumn('quantity', 'Quantity'),
        _TraceabilityColumn('userLocation', 'User / Location'),
      ];
    }

    final hasUser = columns.contains('user');
    final hasLocation = columns.contains('location');

    final configs = <_TraceabilityColumn>[];
    for (final column in columns) {
      if (column == 'location' && hasUser) {
        continue;
      }
      if (column == 'user' && hasLocation) {
        configs.add(const _TraceabilityColumn('userLocation', 'User / Location'));
      } else {
        configs.add(
          _TraceabilityColumn(
            column,
            _columnLabel(column),
          ),
        );
      }
    }
    return configs;
  }

  String _columnLabel(String key) {
    switch (key) {
      case 'dateTime':
        return 'Date & Time';
      case 'type':
        return 'Type';
      case 'reference':
        return 'Reference';
      case 'item':
        return 'Item Details';
      case 'quantity':
        return 'Quantity';
      case 'user':
        return 'User';
      case 'location':
        return 'Location';
      default:
        return key;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'grn':
        return Icons.south_west;
      case 'adjustment':
        return Icons.autorenew;
      case 'issue':
        return Icons.north_east;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.info_outline;
    }
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
}

class _TraceabilityColumn {
  const _TraceabilityColumn(this.key, this.label);

  final String key;
  final String label;
}

