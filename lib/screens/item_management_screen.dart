import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/item_column_keys.dart';
import '../models/dashboard_models.dart';
import '../providers/item_column_visibility_provider.dart';
import '../providers/item_table_provider.dart';
import '../utils/responsive_helper.dart';

class ItemManagementScreen extends StatelessWidget {
  const ItemManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getScreenPadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 700;

    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(padding.horizontal / 2),
                color: Colors.white,
                child: Row(
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
                            'Item Master Table',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? double.infinity : 320,
                        ),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search items',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding.horizontal,
                    0,
                    padding.horizontal,
                    padding.vertical,
                  ),
                  child: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Consumer2<ItemTableProvider, ItemColumnVisibilityProvider>(
                        builder: (context, tableProvider, columnProvider, _) {
                          final visibleColumns = columnProvider.visibleColumns;
                          final items = tableProvider.items;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _ItemTable(
                                  items: items,
                                  visibleColumns: visibleColumns,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 220,
                                child: _ColumnSelectorPanel(
                                  columns: columnProvider.columns,
                                  onToggle: columnProvider.toggleColumn,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTable extends StatelessWidget {
  final List<ItemMaster> items;
  final List<ColumnConfig> visibleColumns;

  const _ItemTable({
    required this.items,
    required this.visibleColumns,
  });

  @override
  Widget build(BuildContext context) {
    if (visibleColumns.isEmpty) {
      return const Center(
        child: Text(
          'No columns selected. Enable at least one heading from Column Picker.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No rows defined.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: visibleColumns.length * 160,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: const Color(0xFFE0E0E0),
            dataTableTheme: DataTableThemeData(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F4F5)),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          child: DataTable(
            border: TableBorder(
              top: const BorderSide(color: Color(0xFFE0E0E0)),
              bottom: const BorderSide(color: Color(0xFFE0E0E0)),
              left: const BorderSide(color: Color(0xFFE0E0E0)),
              right: const BorderSide(color: Color(0xFFE0E0E0)),
              horizontalInside: const BorderSide(color: Color(0xFFE0E0E0)),
              verticalInside: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            columnSpacing: 0,
            headingRowHeight: 48,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 48,
          columns: visibleColumns
              .map(
                (column) => DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(column.label),
                  ),
                ),
              )
              .toList(),
          rows: List.generate(items.length, (index) {
            final item = items[index];
            return DataRow(
              cells: visibleColumns
                  .map(
                    (column) => DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          _resolveValue(item, column.key),
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
          ),
        ),
      ),
    );
  }

  String _resolveValue(ItemMaster item, String key) {
    switch (key) {
      case ItemColumnKeys.itemCode:
        return item.itemCode;
      case ItemColumnKeys.itemName:
        return item.itemName;
      case ItemColumnKeys.type:
        return item.type;
      case ItemColumnKeys.category:
        return item.category;
      case ItemColumnKeys.manufacturer:
        return item.manufacturer;
      case ItemColumnKeys.unit:
        return item.unit;
      case ItemColumnKeys.storage:
        return item.storage;
      case ItemColumnKeys.stock:
        return item.stock.toString();
      case ItemColumnKeys.status:
        return item.status;
      default:
        return '';
    }
  }
}

class _ColumnSelectorPanel extends StatelessWidget {
  final List<ColumnConfig> columns;
  final void Function(String key, bool value) onToggle;

  const _ColumnSelectorPanel({
    required this.columns,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_column, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                'Columns',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: columns.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final column = columns[index];
                return InkWell(
                  onTap: () => onToggle(column.key, !column.visible),
                  child: Row(
                    children: [
                      Checkbox(
                        value: column.visible,
                        onChanged: (value) =>
                            onToggle(column.key, value ?? column.visible),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          column.label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


