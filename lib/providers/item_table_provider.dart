import 'package:flutter/foundation.dart';

import '../constants/item_column_keys.dart';
import '../models/dashboard_models.dart';

class ItemTableProvider extends ChangeNotifier {
  final List<ItemMaster> _items = [];

  List<ItemMaster> get items => List.unmodifiable(_items);

  ItemTableProvider() {
    _seedBlankRows(5, notify: false);
  }

  void seedBlankRows(int count) => _seedBlankRows(count);

  void resetTable() => _seedBlankRows(5);

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
    );
  }

  void addEmptyRow() {
    _items.add(_blankItem());
    notifyListeners();
  }

  void updateField(int index, String key, String value) {
    if (index < 0 || index >= _items.length) return;
    final current = _items[index];
    final updated = current.copyWith(
      itemCode: key == ItemColumnKeys.itemCode ? value : null,
      itemName: key == ItemColumnKeys.itemName ? value : null,
      type: key == ItemColumnKeys.type ? value : null,
      category: key == ItemColumnKeys.category ? value : null,
      manufacturer: key == ItemColumnKeys.manufacturer ? value : null,
      unit: key == ItemColumnKeys.unit ? value : null,
      storage: key == ItemColumnKeys.storage ? value : null,
      status: key == ItemColumnKeys.status ? value : null,
      stock: key == ItemColumnKeys.stock ? int.tryParse(value) ?? current.stock : null,
    );

    _items[index] = updated;
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }
}
