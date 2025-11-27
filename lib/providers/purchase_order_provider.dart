import 'package:flutter/material.dart';

class PurchaseOrderItem {
  String? itemId;
  String itemName;
  int quantity;
  String unit;
  double unitPrice;

  PurchaseOrderItem({
    this.itemId,
    required this.itemName,
    this.quantity = 1,
    this.unit = '',
    this.unitPrice = 0.0,
  });

  double get total => quantity * unitPrice;
}

class PurchaseOrderProvider extends ChangeNotifier {
  final TextEditingController expectedDeliveryDateController = TextEditingController();
  final TextEditingController referencePRController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> paymentTerms = const [
    'Net 30',
    'Net 15',
    'Net 45',
    'Net 60',
    'Due on Receipt',
    'Cash on Delivery',
  ];

  final List<PurchaseOrderItem> _items = [
    PurchaseOrderItem(itemName: '', quantity: 1, unit: '', unitPrice: 0.0),
  ];

  String? _selectedVendor;
  String _selectedPaymentTerms = 'Net 30';

  String? get selectedVendor => _selectedVendor;
  String get selectedPaymentTerms => _selectedPaymentTerms;
  List<PurchaseOrderItem> get items => List.unmodifiable(_items);

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  bool get canSubmit {
    return _selectedVendor != null &&
        _selectedVendor!.isNotEmpty &&
        _items.any((item) => item.itemName.isNotEmpty);
  }

  void setVendor(String? value) {
    if (value == _selectedVendor) return;
    _selectedVendor = value;
    notifyListeners();
  }

  void setPaymentTerms(String value) {
    if (value == _selectedPaymentTerms) return;
    _selectedPaymentTerms = value;
    notifyListeners();
  }

  void addItem() {
    _items.add(PurchaseOrderItem(itemName: '', quantity: 1, unit: '', unitPrice: 0.0));
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
    double? unitPrice,
  }) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      _items[index] = PurchaseOrderItem(
        itemId: item.itemId,
        itemName: itemName ?? item.itemName,
        quantity: quantity ?? item.quantity,
        unit: unit ?? item.unit,
        unitPrice: unitPrice ?? item.unitPrice,
      );
      notifyListeners();
    }
  }

  void onFieldChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    expectedDeliveryDateController.dispose();
    referencePRController.dispose();
    notesController.dispose();
    super.dispose();
  }
}



