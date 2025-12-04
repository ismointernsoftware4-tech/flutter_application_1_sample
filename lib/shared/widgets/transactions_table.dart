import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class TransactionsTable extends StatelessWidget {
  const TransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<DashboardProvider>(context).transactions;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(2),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                children: const [
                  _TableHeaderCell('DATE'),
                  _TableHeaderCell('TYPE'),
                  _TableHeaderCell('ITEM'),
                  _TableHeaderCell('QUANTITY'),
                  _TableHeaderCell('USER'),
                ],
              ),
              // Data rows
              ...transactions.map((transaction) {
                return TableRow(
                  children: [
                    _TableCell(transaction.date),
                    _TableCell(
                      transaction.type,
                      isType: true,
                      typeColor: transaction.type == 'GRN' ? Colors.green : Colors.grey,
                    ),
                    _TableCell(transaction.item),
                    _TableCell(transaction.quantity),
                    _TableCell(transaction.user),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isType;
  final Color? typeColor;

  const _TableCell(
    this.text, {
    this.isType = false,
    this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isType) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: typeColor?.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: typeColor ?? Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }
}




