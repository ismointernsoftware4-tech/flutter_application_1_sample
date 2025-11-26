import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_column_visibility_provider.dart';

class ItemColumnPickerScreen extends StatelessWidget {
  const ItemColumnPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Columns'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ItemColumnVisibilityProvider>().resetToDefault();
            },
            child: const Text('Reset'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ItemColumnVisibilityProvider>(
        builder: (context, provider, _) {
          final columns = provider.columns;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose which columns appear in the Item Table.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: columns
                      .map(
                        (column) => FilterChip(
                          label: Text(column.label),
                          tooltip: column.description,
                          selected: column.visible,
                          onSelected: (value) =>
                              provider.toggleColumn(column.key, value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Expanded(
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
                        secondary: Icon(
                          column.visible ? Icons.check_circle : Icons.circle,
                          color: column.visible
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              provider.setAll(false),
                          icon: const Icon(Icons.visibility_off),
                          label: const Text('Hide All'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              provider.setAll(true),
                          icon: const Icon(Icons.visibility),
                          label: const Text('Show All'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


