import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardSummary _summary = DashboardSummary(
    totalItems: 3,
    lowStockAlerts: 1,
    pendingPOs: 2,
    pendingApprovals: 3,
  );

  List<CategoryInventory> _inventoryByCategory = [
    CategoryInventory(category: 'Analgesic', quantity: 5000, value: 400),
    CategoryInventory(category: 'Antidiabetic', quantity: 50, value: 1700),
    CategoryInventory(category: 'Surgical', quantity: 30, value: 400),
  ];

  StockStatus _stockStatus = StockStatus(active: 75, lowStock: 25);

  PurchaseOrderStatus _poStatus = PurchaseOrderStatus(draft: 65, issued: 35);

  List<Transaction> _transactions = [
    Transaction(
      date: '2023-11-01 10:30',
      type: 'GRN',
      item: 'Paracetamol 500mg',
      quantity: '1000',
      user: 'Store Manager',
    ),
    Transaction(
      date: '2023-11-02 14:15',
      type: 'Adjustment',
      item: 'Insulin Glargine',
      quantity: '-2',
      user: 'Store Keeper',
    ),
  ];

  List<ItemMaster> _itemMasterList = [
    ItemMaster(
      itemCode: 'ITM001',
      itemName: 'Paracetamol 500mg',
      manufacturer: 'PharmaCorp',
      type: 'Drug',
      category: 'Analgesic',
      unit: 'Tablet',
      storage: 'RT',
      stock: 5000,
      status: 'Active',
    ),
    ItemMaster(
      itemCode: 'ITM002',
      itemName: 'Insulin Glargine',
      manufacturer: 'BioMed',
      type: 'Drug',
      category: 'Antidiabetic',
      unit: 'Vial',
      storage: '2-8°C',
      stock: 120,
      status: 'Active',
    ),
    ItemMaster(
      itemCode: 'ITM003',
      itemName: 'Surgical Gloves',
      manufacturer: 'SafeHands',
      type: 'Consumable',
      category: 'Surgical',
      unit: 'Box',
      storage: 'RT',
      stock: 50,
      status: 'Low Stock',
    ),
  ];

  String _selectedNavItem = 'Dashboard';

  DashboardSummary get summary => _summary;
  List<CategoryInventory> get inventoryByCategory => _inventoryByCategory;
  StockStatus get stockStatus => _stockStatus;
  PurchaseOrderStatus get poStatus => _poStatus;
  List<Transaction> get transactions => _transactions;
  List<ItemMaster> get itemMasterList => _itemMasterList;
  String get selectedNavItem => _selectedNavItem;

  void setSelectedNavItem(String item) {
    _selectedNavItem = item;
    notifyListeners();
  }
}

