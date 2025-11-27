import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_traceability_provider.dart';

class TransactionsTable extends StatelessWidget {
  const TransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionTraceabilityProvider>();
    final records = provider.records.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
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
          if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (provider.error != null)
            _StatusMessage(
              message: provider.error!,
              onRetry: provider.reload,
            )
          else if (records.isEmpty)
            _StatusMessage(
              message: 'No transactions yet.',
              onRetry: provider.reload,
              actionLabel: 'Reload',
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  children: const [
                    _TableHeaderCell('DATE'),
                    _TableHeaderCell('TYPE'),
                    _TableHeaderCell('ITEM'),
                    _TableHeaderCell('QUANTITY'),
                    _TableHeaderCell('USER / LOCATION'),
                  ],
                ),
                ...records.map((record) {
                  return TableRow(
                    children: [
                      _TableCell(record.dateTime),
                      _TableCell(
                        record.type,
                        isType: true,
                        typeColor: _typeColor(record.type),
                      ),
                      _TableCell(record.itemDetails),
                      _QuantityCell(record.quantity),
                      _TableCell(
                        '${record.user}\n${record.location}',
                      ),
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
            color: typeColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
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

class _QuantityCell extends StatelessWidget {
  const _QuantityCell(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final isPositive = value.trim().startsWith('+');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isPositive ? Colors.green : Colors.redAccent,
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    required this.onRetry,
    this.actionLabel = 'Retry',
  });

  final String message;
  final Future<void> Function() onRetry;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

Color _typeColor(String type) {
  switch (type.toLowerCase()) {
    case 'grn':
      return Colors.green;
    case 'adjustment':
      return Colors.orange;
    case 'issue':
      return Colors.red;
    case 'transfer':
      return Colors.blueGrey;
    default:
      return Colors.grey;
  }
}