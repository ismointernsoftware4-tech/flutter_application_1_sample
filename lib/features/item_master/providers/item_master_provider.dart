import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../shared/services/firebase_service.dart';
import '../../../shared/utils/csv_file_helper.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/models/dynamic_form_models.dart';
import '../models/item_master_models.dart';

class ItemMasterProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Map<String, dynamic>> _itemMasterList = [];
  ItemMasterFilter _itemMasterFilter = const ItemMasterFilter();
  String _itemSearchQuery = '';

  List<Map<String, dynamic>> get itemMasterList => _itemMasterList;
  
  List<Map<String, dynamic>> get filteredItemMasterList =>
      _itemMasterList.where(_applyItemMasterFilters).toList();
  
  ItemMasterFilter get itemMasterFilter => _itemMasterFilter;
  String get itemSearchQuery => _itemSearchQuery;
  
  List<String> get itemMasterStatuses =>
      _itemMasterList
          .map((e) => (e['status'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  
  List<String> get itemMasterCategories =>
      _itemMasterList
          .map((e) => (e['category'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  
  List<String> get itemMasterTypes =>
      _itemMasterList
          .map((e) => (e['type'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  // Robust helper to extract item name from various possible field names.
  String _extractItemName(Map<String, dynamic> data) {
    // 1. Try known key variants first
    final direct = data['itemName'] ??
        data['item_name'] ??
        data['Item Name'] ??
        data['name'];

    if (direct != null && direct.toString().trim().isNotEmpty) {
      print('DEBUG _extractItemName: Found via direct key: "$direct"');
      return direct.toString().trim();
    }

    // 2. Fallback: scan for any string field whose key contains "name"
    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;

      if (value is String &&
          value.trim().isNotEmpty &&
          key.contains('name')) {
        print('DEBUG _extractItemName: Found via fallback scan - key: "${entry.key}", value: "$value"');
        return value.trim();
      }
    }

    print('DEBUG _extractItemName: No item name found in data keys: ${data.keys.toList()}');
    return '';
  }

  bool _applyItemMasterFilters(Map<String, dynamic> item) {
    final query = _itemSearchQuery.trim().toLowerCase();
    final itemCode = (item['itemCode'] ?? '').toString().toLowerCase();
    final itemName = (item['itemName'] ?? '').toString().toLowerCase();
    final manufacturer = (item['manufacturer'] ?? '').toString().toLowerCase();
    
    final matchesQuery =
        query.isEmpty ||
        itemCode.contains(query) ||
        itemName.contains(query) ||
        manufacturer.contains(query);

    final nameFilter = _itemMasterFilter.nameQuery?.trim().toLowerCase();
    final matchesName =
        nameFilter == null ||
        nameFilter.isEmpty ||
        itemName.contains(nameFilter);

    return matchesQuery && matchesName && _itemMasterFilter.matchesMap(item);
  }

  void updateItemMasterFilter(ItemMasterFilter filter) {
    _itemMasterFilter = filter;
    notifyListeners();
  }

  void resetItemMasterFilter() {
    _itemMasterFilter = const ItemMasterFilter();
    notifyListeners();
  }

  void updateItemSearchQuery(String query) {
    _itemSearchQuery = query;
    notifyListeners();
  }

  Future<void> loadItems() async {
    try {
    final itemsData = await _firebaseService.fetchItems();
    print('DEBUG Item Master: Total items from Firebase: ${itemsData.length}');
    
    // Load form definition to map field IDs to semantic keys
    DynamicFormDefinition? formDefinition;
    try {
      final formBuilderProvider = FormBuilderProvider(formId: 'item_master');
      await formBuilderProvider.loadDefinition();
      formDefinition = formBuilderProvider.definition;
    } catch (formError) {
      print('Error loading form definition: $formError');
      // Continue without form definition mapping - use raw data
      formDefinition = null;
    }
    
    print('DEBUG Item Master: Form definition loaded: ${formDefinition != null}');
    if (formDefinition != null) {
      print('DEBUG Item Master: Form definition sections: ${formDefinition.sections.length}');
      for (final section in formDefinition.sections) {
        print('DEBUG Item Master: Section "${section.title}" has ${section.fields.length} fields');
        for (final field in section.fields) {
          print(
            'DEBUG Item Master: Field - id: "${field.id}", key: "${field.key}", label: "${field.label}"',
          );
        }
      }
    }
    
    // Build mapping: field ID (e.g., "#d5d2c") -> field key (e.g., "itemName")
    final fieldIdToKeyMap = <String, String>{};
    if (formDefinition != null) {
      for (final section in formDefinition.sections) {
        for (final field in section.fields) {
          // Map both with and without # prefix
          if (field.id.isNotEmpty && field.key.isNotEmpty) {
            // Store the original ID
            fieldIdToKeyMap[field.id] = field.key;

            if (field.id.startsWith('#')) {
              // ID has #, map both with and without it
              fieldIdToKeyMap[field.id] = field.key; // "#d5d2c" -> "itemName"
              fieldIdToKeyMap[field.id.substring(1)] = field.key; // "d5d2c" -> "itemName"
            } else {
              // ID doesn't have #, map both with and without it
              fieldIdToKeyMap[field.id] = field.key; // "d5d2c" -> "itemName"
              fieldIdToKeyMap['#${field.id}'] = field.key; // "#d5d2c" -> "itemName"
            }
          }
        }
      }
      print('DEBUG Item Master: Field ID to Key mapping: $fieldIdToKeyMap');
      print('DEBUG Item Master: Mapping size: ${fieldIdToKeyMap.length}');
    } else {
      print('DEBUG Item Master: WARNING - Form definition is null!');
    }
    
    _itemMasterList = itemsData.map((data) {
      // Remap field_[#id] to semantic keys using form definition
      final remappedData = <String, dynamic>{...data};
      int remappedCount = 0;
      
      data.forEach((key, value) {
        if (key.startsWith('field_[') && key.endsWith(']')) {
          // Extract field ID from "field_[#d5d2c]"
          final fieldIdMatch = RegExp(r'field_\[#?([^\]]+)\]').firstMatch(key);
          if (fieldIdMatch != null) {
            final fieldId = fieldIdMatch.group(1)!;
            final fieldIdWithHash = '#$fieldId';
            
            // Try multiple variations
            final semanticKey = fieldIdToKeyMap[fieldId] ??
                fieldIdToKeyMap[fieldIdWithHash] ??
                fieldIdToKeyMap[fieldId.replaceFirst('#', '')];
            
            // DEBUG for first item
            final isFirstItem = itemsData.indexOf(data) == 0;
            if (isFirstItem) {
              print('DEBUG Item Master: Processing key "$key"');
              print('DEBUG Item Master: Extracted fieldId: "$fieldId"');
              print('DEBUG Item Master: Looking for: "$fieldId", "#$fieldId"');
              print('DEBUG Item Master: Found semanticKey: "$semanticKey"');
            }
            
            if (semanticKey != null && semanticKey.isNotEmpty) {
              // Map to semantic key, but don't overwrite if it already exists
              if (!remappedData.containsKey(semanticKey) ||
                  remappedData[semanticKey] == null ||
                  remappedData[semanticKey].toString().isEmpty) {
                remappedData[semanticKey] = value;
                remappedCount++;
                if (isFirstItem) {
                  print(
                    'DEBUG Item Master: Mapped "$key" -> "$semanticKey" = "$value"',
                  );
                }
              }
              // Remove the old field_[#id] key to avoid confusion
              remappedData.remove(key);
            } else if (isFirstItem) {
              print(
                'DEBUG Item Master: WARNING - No semantic key found for fieldId "$fieldId"',
              );
            }
          }
        }
      });
      
      // Hard-coded fallback for old schemas where name is stored in field_[#d5d2c]
      // Based on debug logs, field_[#d5d2c] appears to be the item name
      if ((remappedData['itemName'] == null ||
              remappedData['itemName'].toString().trim().isEmpty) &&
          remappedData['field_[#d5d2c]'] != null &&
          remappedData['field_[#d5d2c]'].toString().trim().isNotEmpty) {
        remappedData['itemName'] = remappedData['field_[#d5d2c]'].toString().trim();
        print('DEBUG Item Master: Applied fallback - mapped field_[#d5d2c] to itemName');
      }
      
      // DEBUG: Print remapped data for first item
      final isFirstItem = itemsData.indexOf(data) == 0;
      if (isFirstItem) {
        print('DEBUG Item Master: Remapped $remappedCount fields');
        print('DEBUG Item Master: After remapping - keys: ${remappedData.keys.toList()}');
        print('DEBUG Item Master: After remapping - itemName: ${remappedData['itemName']}');
        print('DEBUG Item Master: After remapping - type: ${remappedData['type']}');
        print('DEBUG Item Master: After remapping - category: ${remappedData['category']}');
      }
      
      // Now normalize using remapped data
      final normalized = {
        'id': remappedData['id'],
        'itemCode': remappedData['itemCode'] ?? remappedData['item_code'] ?? '',
        'itemName': _extractItemName(remappedData),
        'manufacturer': remappedData['manufacturer'] ?? '',
        'type': remappedData['itemType'] ?? remappedData['type'] ?? '',
        'category': remappedData['category'] ?? '',
        'unit': remappedData['unitOfMeasure'] ?? remappedData['unit'] ?? '',
        'storage': remappedData['storageConditions'] ?? remappedData['storage'] ?? '',
        'stock': (remappedData['stock'] ?? remappedData['quantity'] ?? 0) is int
            ? (remappedData['stock'] ?? remappedData['quantity'] ?? 0)
            : int.tryParse(
                    (remappedData['stock'] ?? remappedData['quantity'] ?? '0').toString(),
                  ) ??
              0,
        'status': remappedData['status'] ?? 'Active',
      };
      
      // Exclude keys that we've normalized
      final excludedKeys = {
        'id', 'itemCode', 'item_code', 'itemName', 'item_name',
        'Item Name', 'name',
        'manufacturer', 'itemType', 'type', 'category',
        'unitOfMeasure', 'unit', 'storageConditions', 'storage',
        'stock', 'quantity', 'status'
      };
      
      // Get additional fields that weren't normalized
      final additionalData = <String, dynamic>{};
      remappedData.forEach((key, value) {
        if (!excludedKeys.contains(key) && !key.startsWith('field_[')) {
          additionalData[key] = value;
        }
      });
      
      final result = {
        ...normalized,
        ...additionalData,
      };
      
      if (isFirstItem) {
        print('DEBUG Item Master: Normalized itemName: "${normalized['itemName']}"');
        print('DEBUG Item Master: Final result itemName: "${result['itemName']}"');
      }
      
      return result;
    }).toList();
    
    notifyListeners();
    print('Items loaded successfully: ${_itemMasterList.length} items');
    
    if (_itemMasterList.isNotEmpty) {
      print('DEBUG Item Master: First item in _itemMasterList:');
      print('  - itemCode: ${_itemMasterList[0]['itemCode']}');
      print('  - itemName: "${_itemMasterList[0]['itemName']}"');
    }
  } catch (e, stackTrace) {
    print('Error loading items: $e');
    print('Stack trace: $stackTrace');
    // Set empty list to prevent null/undefined errors in UI
    _itemMasterList = [];
    // CRITICAL: Always notify listeners even on error to unblock UI
    notifyListeners();
  }
}

  Future<void> saveItem(Map<String, dynamic> itemData) async {
    try {
      // Save to Firestore
      final docId = await _firebaseService.saveItem(itemData);

      // Reload items from Firestore to get the latest data
      await loadItems();

      print('Item saved successfully with ID: $docId');
    } catch (e) {
      print('Error saving item: $e');
      throw Exception('Error saving item: $e');
    }
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> itemData) async {
    try {
      await _firebaseService.updateItem(documentId, itemData);
      await loadItems(); // Reload to refresh UI
      print('Item updated successfully');
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String documentId) async {
    try {
      await _firebaseService.deleteItem(documentId);
      _itemMasterList.removeWhere((item) => item['id'] == documentId);
      notifyListeners();
      print('Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Error deleting item: $e');
    }
  }

  Future<String> exportItemMasterCsv() async {
    final rows = <List<String>>[
      [
        'Item Code',
        'Item Name',
        'Manufacturer',
        'Type',
        'Category',
        'Unit',
        'Stock',
        'Status',
      ],
      ...filteredItemMasterList.map(
        (item) => [
          (item['itemCode'] ?? '').toString(),
          (item['itemName'] ?? '').toString(),
          (item['manufacturer'] ?? '').toString(),
          (item['type'] ?? '').toString(),
          (item['category'] ?? '').toString(),
          (item['unit'] ?? '').toString(),
          (item['stock'] ?? 0).toString(),
          (item['status'] ?? '').toString(),
        ],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    final fileName = 'item_master_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  String _escapeCsv(String value) {
    final safe = value.replaceAll('"', '""');
    return '"$safe"';
  }
}

