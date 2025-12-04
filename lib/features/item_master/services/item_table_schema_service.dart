import 'package:flutter/foundation.dart' show debugPrint;

import '../../../shared/models/column_config.dart';
import '../../../shared/services/firebase_service.dart';

class ItemTableSchemaService {
  Future<List<ColumnConfig>> loadColumns() async {
    // Try to load from Firebase first
    try {
      final firebaseService = FirebaseService();
      final firebaseData = await firebaseService.fetchFormDefinition('item_table_schema');
      if (firebaseData != null && firebaseData['columns'] != null) {
        final columns = (firebaseData['columns'] as List<dynamic>)
            .map((e) => ColumnConfig.fromMap(e as Map<String, dynamic>))
            .toList();
        if (columns.isNotEmpty) {
          return columns;
        }
      }
    } catch (e) {
      debugPrint('Error loading item table columns from Firebase: $e');
    }
    
    // Fallback to default columns
    return defaultColumns;
  }

  Future<void> saveColumns(List<ColumnConfig> columns) async {
    // Save to Firebase instead of local file
    try {
      final firebaseService = FirebaseService();
      await firebaseService.saveFormDefinition(
        'item_table_schema',
        {
          'columns': columns.map((c) => c.toMap()).toList(),
        },
      );
    } catch (e) {
      debugPrint('Error saving item table columns to Firebase: $e');
    }
  }

  List<ColumnConfig> get defaultColumns => const [
        ColumnConfig(
          key: 'itemCode',
          label: 'Item Code',
          description: 'System generated code',
        ),
        ColumnConfig(
          key: 'itemName',
          label: 'Item Name',
          description: 'Display name of the item',
        ),
        ColumnConfig(
          key: 'manufacturer',
          label: 'Manufacturer',
          description: 'Supplier or brand',
        ),
        ColumnConfig(
          key: 'type',
          label: 'Type',
          description: 'Classification',
        ),
        ColumnConfig(
          key: 'category',
          label: 'Category',
          description: 'Category grouping',
        ),
        ColumnConfig(
          key: 'unit',
          label: 'Unit',
          description: 'Unit of measure',
        ),
        ColumnConfig(
          key: 'stock',
          label: 'Stock',
          description: 'Current quantity',
        ),
        ColumnConfig(
          key: 'status',
          label: 'Status',
          description: 'Lifecycle status',
        ),
      ];
}
