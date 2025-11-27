import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/storage_location_schema.dart';
import '../providers/storage_location_table_provider.dart';
import '../utils/responsive_helper.dart';

class StorageLocationTable extends StatelessWidget {
  const StorageLocationTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final tableProvider = context.watch<StorageLocationTableProvider>();

    if (tableProvider.isLoading) {
      return _tableContainer(
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final columns = tableProvider.columns;
    final rows = tableProvider.rows;

    if (columns.isEmpty) {
      return _tableContainer(
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No storage location columns found. Please check schemas/storage_location_schema.json.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return _buildMobileCardViewRows(rows);
    }

    return _tableContainer(
      Column(
        children: [
          _buildTableHeader(columns),
          const Divider(height: 1),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No storage locations found in sampleData.'),
              ),
            )
          else
            ...rows.map(
              (row) => _buildTableRow(columns, row),
            ),
        ],
      ),
    );
  }
}

Widget _tableContainer(Widget child) {
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
        ),
        BoxShadow(
          color: Colors.blue.withOpacity(0.02),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

Widget _buildTableHeader(List<String> columns) {
  return Container(
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
      children: columns
          .map(
            (column) => Expanded(
              child: Text(
                _columnLabel(column),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

Widget _buildTableRow(List<String> columns, StorageLocationRow row) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
    ),
    child: Row(
      children: columns
          .map(
            (column) => Expanded(
              child: _buildCell(column, row),
            ),
          )
          .toList(),
    ),
  );
}

Widget _buildCell(String column, StorageLocationRow row) {
  switch (column) {
    case 'id':
      return _linkText(row.valueFor(column));
    case 'name':
      return Text(row.valueFor(column));
    case 'type':
      return _badge(row.valueFor(column));
    case 'parentLocation':
      final value = row.valueFor(column).isEmpty ? '-' : row.valueFor(column);
      return Row(
        children: [
          const Icon(Icons.warehouse_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Flexible(child: Text(value)),
        ],
      );
    case 'capacity':
      final capacity = row.numericValue(column);
      final text =
          capacity != null ? '${capacity.toString()}%' : row.valueFor(column);
      return Text(text);
    case 'status':
      return _statusChip(row.valueFor(column));
    case 'actions':
      return _buildActions(row);
    default:
      return Text(row.valueFor(column));
  }
}

Widget _buildActions(StorageLocationRow row) {
  final canView = row.actionEnabled('view');
  final canEdit = row.actionEnabled('edit');
  final canDelete = row.actionEnabled('delete');

  if (!canView && !canEdit && !canDelete) {
    return const SizedBox.shrink();
  }

  return Row(
    children: [
      if (canView)
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.remove_red_eye_outlined),
        ),
      if (canEdit)
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined),
        ),
      if (canDelete)
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.delete_outline),
        ),
    ],
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

Widget _badge(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFF1F5F9),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF635BFF),
      ),
    ),
  );
}

Widget _statusChip(String status) {
  final isActive = status.toLowerCase() == 'active';
  final color = isActive ? Colors.green.shade600 : Colors.grey;
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

Widget _buildMobileCardViewRows(List<StorageLocationRow> rows) {
  return Column(
    children: rows.map((row) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        _linkText(row.valueFor('id')),
                        const SizedBox(height: 4),
                        Text(
                          row.valueFor('name'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(row.valueFor('status')),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildMobileInfo('Type', _badge(row.valueFor('type'))),
                  _buildMobileInfo(
                    'Parent',
                    Text(
                      row.valueFor('parentLocation').isEmpty
                          ? '-'
                          : row.valueFor('parentLocation'),
                    ),
                  ),
                  _buildMobileInfo(
                    'Capacity',
                    Text('${row.valueFor('capacity')}%'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: _buildActions(row),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

Widget _buildMobileInfo(String label, Widget value) {
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
      DefaultTextStyle(
        style: const TextStyle(fontSize: 12),
        child: value,
      ),
    ],
  );
}

String _columnLabel(String key) {
  const overrides = {
    'id': 'ID',
    'name': 'Name',
    'type': 'Type',
    'parentLocation': 'Parent Location',
    'capacity': 'Capacity',
    'status': 'Status',
    'actions': 'Actions',
  };
  if (overrides.containsKey(key)) return overrides[key]!;

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


