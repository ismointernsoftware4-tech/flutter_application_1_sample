import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_column_visibility_provider.dart';

class ItemColumnPickerScreen extends StatelessWidget {
  const ItemColumnPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Item Columns',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade700),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () {
                context.read<ItemColumnVisibilityProvider>().resetToDefault();
              },
              icon: Icon(Icons.refresh, size: 18, color: Colors.blue.shade600),
              label: Text(
                'Reset',
                style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ItemColumnVisibilityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final columns = provider.columns;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Column Visibility',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose which columns appear in the Item Table. Toggle visibility to customize your view.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: columns
                          .map(
                            (column) => FilterChip(
                              label: Text(
                                column.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: column.visible ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              tooltip: column.description,
                              selected: column.visible,
                              onSelected: (value) =>
                                  provider.toggleColumn(column.key, value),
                              selectedColor: Colors.blue.shade50,
                              checkmarkColor: Colors.blue.shade700,
                              labelStyle: TextStyle(
                                color: column.visible ? Colors.blue.shade700 : Colors.grey.shade700,
                              ),
                              side: BorderSide(
                                color: column.visible ? Colors.blue.shade300 : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: columns.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final column = columns[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: column.visible ? Colors.blue.shade50.withOpacity(0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            column.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            column.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          value: column.visible,
                          onChanged: (value) =>
                              provider.toggleColumn(column.key, value),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: column.visible
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              column.visible ? Icons.visibility : Icons.visibility_off,
                              color: column.visible
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          activeColor: Colors.blue.shade600,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => provider.setAll(false),
                          icon: const Icon(Icons.visibility_off, size: 18),
                          label: const Text(
                            'Hide All',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => provider.setAll(true),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text(
                            'Show All',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



