import 'package:flutter/material.dart';

class PurchaseRequisitionItem {
  String? itemId;
  String itemName;
  int quantity;
  String unit;

  PurchaseRequisitionItem({
    this.itemId,
    required this.itemName,
    this.quantity = 1,
    this.unit = '',
  });
}

class PurchaseRequisitionProvider extends ChangeNotifier {
  final TextEditingController requestedByController = TextEditingController(text: 'Current User');
  final TextEditingController requiredDateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> departments = const [
    'IVF Lab',
    'Pharmacy',
    'Laboratory',
    'Administration',
    'Maintenance',
  ];

  final List<String> priorities = const [
    'Routine',
    'Urgent',
    'Critical',
  ];

  final List<PurchaseRequisitionItem> _items = [
    PurchaseRequisitionItem(itemName: '', quantity: 1, unit: ''),
  ];

  String _selectedDepartment = 'IVF Lab';
  String _selectedPriority = 'Routine';

  String get selectedDepartment => _selectedDepartment;
  String get selectedPriority => _selectedPriority;
  List<PurchaseRequisitionItem> get items => List.unmodifiable(_items);

  bool get canSubmit {
    return requestedByController.text.trim().isNotEmpty &&
        _selectedDepartment.isNotEmpty &&
        _items.any((item) => item.itemName.isNotEmpty);
  }

  void setDepartment(String value) {
    if (value == _selectedDepartment) return;
    _selectedDepartment = value;
    notifyListeners();
  }

  void setPriority(String value) {
    if (value == _selectedPriority) return;
    _selectedPriority = value;
    notifyListeners();
  }

  void addItem() {
    _items.add(PurchaseRequisitionItem(itemName: '', quantity: 1, unit: ''));
    notifyListeners();
  }

  void removeItem(int index) {
    if (_items.length > 1 && index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateItem(int index, {
    String? itemName,
    int? quantity,
    String? unit,
  }) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      _items[index] = PurchaseRequisitionItem(
        itemId: item.itemId,
        itemName: itemName ?? item.itemName,
        quantity: quantity ?? item.quantity,
        unit: unit ?? item.unit,
      );
      notifyListeners();
    }
  }

  void onFieldChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    requestedByController.dispose();
    requiredDateController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

