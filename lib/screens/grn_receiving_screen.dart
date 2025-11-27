import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grn_schema.dart';
import '../providers/grn_table_provider.dart';
import '../utils/responsive_helper.dart';

class GrnReceivingScreen extends StatelessWidget {
  const GrnReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionBar(),
                  const SizedBox(height: 24),
                  _buildTable(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                      'GRN & Receiving',
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

  Widget _buildActionBar() {
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
          label: const Text('Create New GRN'),
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

  Widget _buildTable(BuildContext context) {
    final grnProvider = context.watch<GrnTableProvider>();
    final columns = grnProvider.columns;
    final rows = grnProvider.rows;
    final isLoading = grnProvider.isLoading;

    if (isLoading) {
      return _tableContainer(
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (columns.isEmpty) {
      return _tableContainer(
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No GRN schema columns found. Please check schemas/grn_schema.json.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _tableContainer(
      child: Column(
        children: [
          _buildTableHeader(columns),
          const Divider(height: 1),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No GRN records found in the schema sampleData.'),
              ),
            )
          else
            ...rows.map((row) => _buildTableRow(columns, row)),
        ],
      ),
    );
  }

  Widget _tableContainer({required Widget child}) {
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
      child: child,
    );
  }

  Widget _buildTableHeader(List<String> columns) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: columns
            .map(
              (key) => Expanded(
                flex: key == 'grnId'
                    ? 2
                    : key == 'actions'
                    ? 3
                    : 3,
                child: Text(
                  _columnLabel(key),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTableRow(List<String> columns, GrnTableRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: columns
            .map(
              (column) => Expanded(
                flex: column == 'grnId'
                    ? 2
                    : column == 'actions'
                    ? 3
                    : 3,
                child: _buildCell(column, row),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCell(String column, GrnTableRow row) {
    switch (column) {
      case 'grnId':
        return _linkText(row.valueFor(column));
      case 'status':
        return _statusChip(row.valueFor(column));
      case 'actions':
        return _buildActions(row);
      default:
        return Text(row.valueFor(column));
    }
  }

  Widget _buildActions(GrnTableRow row) {
    final viewEnabled = row.actionEnabled('view');
    final refreshEnabled = row.actionEnabled('refresh');

    if (!viewEnabled && !refreshEnabled) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (viewEnabled)
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'View',
          ),
        if (refreshEnabled)
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Refresh',
          ),
      ],
    );
  }

  Widget _outlineButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _statusChip(String status) {
    final color = status.toLowerCase() == 'completed'
        ? Colors.green.shade600
        : Colors.blueGrey;

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

  String _columnLabel(String key) {
    const overrides = {
      'grnId': 'GRN ID',
      'poReference': 'PO Reference',
      'vendorName': 'Vendor',
      'dateReceived': 'Date Received',
      'receivedBy': 'Received By',
      'status': 'Status',
      'actions': 'Actions',
    };

    if (overrides.containsKey(key)) {
      return overrides[key]!;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      final isUpper = char.toUpperCase() == char && char != char.toLowerCase();
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else if (isUpper) {
        buffer
          ..write(' ')
          ..write(char);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
