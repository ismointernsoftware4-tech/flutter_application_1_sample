import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/item_column_keys.dart';
import '../models/dashboard_models.dart';
import '../providers/item_column_visibility_provider.dart';
import '../providers/item_table_provider.dart';
import '../utils/responsive_helper.dart';

class ItemMasterScreen extends StatelessWidget {
  const ItemMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getScreenPadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

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
                  children: [
                    if (isMobile || isTablet)
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: 'Open menu',
                      ),
                    Text(
                      'Item Master',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getTitleFontSize(context),
                        fontWeight: FontWeight.bold,
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

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final panelExpanded = columnProvider.panelExpanded;
                              const collapsedWidth = 56.0;

                              if (isMobile) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: _ItemTable(
                                        items: items,
                                        visibleColumns: visibleColumns,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: _ColumnSelectorPanel(
                                        columns: columnProvider.columns,
                                        onToggle: columnProvider.toggleColumn,
                                        onToggleHighlight:
                                            columnProvider.toggleHighlight,
                                        isHighlighted: columnProvider.isHighlighted,
                                        expanded: panelExpanded,
                                        onTogglePanel: columnProvider.togglePanelExpanded,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              final panelWidth = isTablet ? 240.0 : 260.0;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _ItemTable(
                                      items: items,
                                      visibleColumns: visibleColumns,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  AnimatedContainer(
                                    width: panelExpanded ? panelWidth : collapsedWidth,
                                    height: constraints.maxHeight,
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeInOut,
                                    child: _ColumnSelectorPanel(
                                      columns: columnProvider.columns,
                                      onToggle: columnProvider.toggleColumn,
                                      onToggleHighlight: columnProvider.toggleHighlight,
                                      isHighlighted: columnProvider.isHighlighted,
                                      expanded: panelExpanded,
                                      onTogglePanel: columnProvider.togglePanelExpanded,
                                    ),
                                  ),
                                ],
                              );
                            },
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
          'No columns available. Add at least one heading to render the table.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No rows defined.'),
      );
    }

    final headers = [...visibleColumns.map((c) => c.label), 'Actions'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: (visibleColumns.length + 1) * 150,
        ),
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
                      (header) => SizedBox(
                        width: 150,
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
            ...items.map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    ...visibleColumns.map(
                      (column) => SizedBox(
                        width: 150,
                        child: _buildCell(item, column),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_red_eye_outlined),
                            tooltip: 'View',
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(ItemMaster item, ColumnConfig column) {
    final value = _resolveValue(item, column.key);
    
    return Text(
      value.isEmpty ? '-' : value,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
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
  final void Function(String key)? onToggleHighlight;
  final bool Function(String key)? isHighlighted;
  final bool expanded;
  final VoidCallback? onTogglePanel;

  static const Map<String, IconData> _columnIcons = {
    ItemColumnKeys.itemCode: Icons.qr_code_2,
    ItemColumnKeys.itemName: Icons.label_important,
    ItemColumnKeys.type: Icons.category,
    ItemColumnKeys.category: Icons.widgets_outlined,
    ItemColumnKeys.manufacturer: Icons.precision_manufacturing,
    ItemColumnKeys.unit: Icons.straighten,
    ItemColumnKeys.storage: Icons.inventory_2,
    ItemColumnKeys.stock: Icons.storage,
    ItemColumnKeys.status: Icons.verified_outlined,
  };

  const _ColumnSelectorPanel({
    required this.columns,
    required this.onToggle,
    this.onToggleHighlight,
    this.isHighlighted,
    this.expanded = true,
    this.onTogglePanel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14213D),
              Color(0xFF1F3B68),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: expanded ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !expanded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.view_week, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Item Master',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Toggle table columns',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: columns.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white10, height: 1),
                          itemBuilder: (context, index) {
                            final column = columns[index];
                            final highlighted = isHighlighted?.call(column.key) ?? false;
                            final icon = _columnIcons[column.key] ?? Icons.view_list_rounded;
                            return InkWell(
                              onTap: () => onToggleHighlight?.call(column.key),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: highlighted
                                      ? Colors.white.withOpacity(0.12)
                                      : (column.visible
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.transparent),
                                  border: highlighted
                                      ? Border.all(color: const Color(0xFF38BDF8), width: 1)
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: highlighted
                                            ? Colors.white.withOpacity(0.3)
                                            : (column.visible
                                                ? Colors.white.withOpacity(0.2)
                                                : Colors.white.withOpacity(0.08)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(icon, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        column.label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight:
                                              highlighted ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        checkboxTheme: CheckboxThemeData(
                                          side: const BorderSide(color: Colors.white54, width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          fillColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return const Color(0xFF38BDF8);
                                            }
                                            return Colors.transparent;
                                          }),
                                          checkColor: WidgetStateProperty.all(Colors.white),
                                        ),
                                      ),
                                      child: Checkbox(
                                        value: column.visible,
                                        onChanged: (value) =>
                                            onToggle(column.key, value ?? column.visible),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PanelToggleButton(
                  expanded: expanded,
                  onPressed: onTogglePanel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelToggleButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback? onPressed;

  const _PanelToggleButton({
    required this.expanded,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(
            expanded ? Icons.chevron_right : Icons.chevron_left,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

