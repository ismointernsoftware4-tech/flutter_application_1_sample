import 'package:flutter/foundation.dart';

import '../models/dashboard_models.dart';
import '../models/item_master_schema.dart';

class ItemTableProvider extends ChangeNotifier {
  final List<ItemMaster> _items = [];
  bool _isLoading = true;
  final ItemMasterSchemaLoader _schemaLoader;

  List<ItemMaster> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  ItemTableProvider({ItemMasterSchemaLoader? schemaLoader})
      : _schemaLoader = schemaLoader ?? const ItemMasterSchemaLoader() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadFromSchema();
  }

  void seedBlankRows(int count) => _seedBlankRows(count);

  void resetTable() => _seedBlankRows(5);

  Future<void> loadFromSchema() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schema = await _schemaLoader.load();
      final sampleData = schema.sampleData;

      if (sampleData.isEmpty) {
        _seedBlankRows(5);
      } else {
        final parsedItems = sampleData
            .map(
              (entry) => _itemFromJson(entry),
            )
            .toList();

        _items
          ..clear()
          ..addAll(parsedItems);
      }
    } catch (error) {
      debugPrint('Failed to load item master schema: $error');
      _seedBlankRows(5);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reloads the schema from JSON file (for instant updates when JSON changes)
  Future<void> reloadSchema() async {
    await loadFromSchema();
  }

  void _seedBlankRows(int count, {bool notify = true}) {
    _items
      ..clear()
      ..addAll(List.generate(count, (_) => _blankItem()));
    if (notify) this.notifyListeners();
  }

  ItemMaster _blankItem() {
    return ItemMaster(
      itemCode: '',
      itemName: '',
      manufacturer: '',
      type: '',
      category: '',
      unit: '',
      storage: '',
      stock: 0,
      status: '',
      rawValues: const {},
    );
  }

  void addEmptyRow() {
    _items.add(_blankItem());
    notifyListeners();
  }

  void updateField(int index, String key, String value) {
    if (index < 0 || index >= _items.length) return;
    final current = _items[index];
    final updatedRaw = Map<String, dynamic>.from(current.rawValues);
    
    // Update rawValues with the new value (handles any field key dynamically)
    if (key == 'stock') {
      updatedRaw[key] = int.tryParse(value) ?? current.stock;
    } else {
      updatedRaw[key] = value;
    }
    
    // Update legacy fields for backward compatibility, but primary source is rawValues
    final updated = current.copyWith(
      itemCode: key == 'itemCode' ? value : null,
      itemName: key == 'itemName' ? value : null,
      type: (key == 'type' || key == 'itemType') ? value : null,
      category: key == 'category' ? value : null,
      manufacturer: key == 'manufacturer' ? value : null,
      unit: (key == 'unit' || key == 'unitOfMeasure') ? value : null,
      storage: (key == 'storage' || key == 'storageConditions') ? value : null,
      status: key == 'status' ? value : null,
      stock: key == 'stock' ? int.tryParse(value) ?? current.stock : null,
      rawValues: updatedRaw,
    );

    _items[index] = updated;
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  ItemMaster _itemFromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json);
    
    // Extract values dynamically from raw data, with fallbacks for legacy fields
    // All actual values come from rawValues, which contains the full JSON data
    return ItemMaster(
      itemCode: raw['itemCode'] as String? ?? '',
      itemName: raw['itemName'] as String? ?? '',
      manufacturer: raw['manufacturer'] as String? ?? '',
      type: raw['itemType'] as String? ?? raw['type'] as String? ?? '',
      category: raw['category'] as String? ?? '',
      unit: raw['unitOfMeasure'] as String? ?? raw['unit'] as String? ?? '',
      storage: raw['storageConditions'] as String? ?? raw['storage'] as String? ?? '',
      stock: (raw['stock'] as num?)?.toInt() ?? 0,
      status: raw['status'] as String? ?? 'Active',
      rawValues: raw,
    );
  }
}
