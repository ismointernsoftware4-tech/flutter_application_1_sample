import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/column_config.dart';
import '../utils/responsive_helper.dart';

class SchemaTable<T> extends StatelessWidget {
  const SchemaTable({
    super.key,
    required this.items,
    required this.columns,
    required this.valueBuilder,
    this.actionsBuilder,
    this.cellBuilder,
    this.columnWidth = 180,
    this.emptyLabel = 'No rows available.',
  });

  final List<T> items;
  final List<ColumnConfig> columns;
  final String Function(T item, ColumnConfig column) valueBuilder;
  final List<Widget> Function(T item)? actionsBuilder;
  final Widget? Function(T item, ColumnConfig column)? cellBuilder;
  final double columnWidth;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) {
      return Center(
        child: Text(
          'No columns selected. Configure visible columns to render the table.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    // Header cells from dynamic columns (+ optional Actions)
    final headerCells = <ShadTableCell>[
      ...columns.map(
        (c) => ShadTableCell.header(
          child: Text(
            c.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : 13,
            ),
          ),
        ),
      ),
      if (actionsBuilder != null)
        const ShadTableCell.header(
          alignment: Alignment.centerRight,
          child: Text('Actions'),
        ),
    ];

    // Build row cells using valueBuilder / cellBuilder + optional actions
    final rowChildren = items.map<List<ShadTableCell>>((item) {
      final cells = <ShadTableCell>[];

      for (final column in columns) {
        final custom = cellBuilder?.call(item, column);
        if (custom != null) {
          cells.add(ShadTableCell(child: custom));
        } else {
          final text = valueBuilder(item, column);
          cells.add(
            ShadTableCell(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }

      if (actionsBuilder != null) {
        cells.add(
          ShadTableCell(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actionsBuilder!(item),
              ),
            ),
          ),
        );
      }

      return cells;
    }).toList();

    // Simple footer showing row count
    final totalColumns = columns.length + (actionsBuilder != null ? 1 : 0);
    final footerCells = <ShadTableCell>[
      ShadTableCell.footer(
        child: Text(
          'Rows: ${items.length}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      for (int i = 1; i < totalColumns; i++)
        const ShadTableCell.footer(child: SizedBox.shrink()),
    ];

    // Return table wrapped to fill full width and height - extends to right edge
   return LayoutBuilder(
  builder: (context, constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
      ),
      child: ShadTable.list(
        header: headerCells,
        footer: footerCells,
        columnSpanExtent: (_) => null,
        children: rowChildren,
      ),
    );
  },
);

  }
}

