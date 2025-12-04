import 'package:flutter/material.dart';

class DashboardSummary {
  final int totalItems;
  final int lowStockAlerts;
  final int pendingPOs;
  final int pendingApprovals;

  DashboardSummary({
    required this.totalItems,
    required this.lowStockAlerts,
    required this.pendingPOs,
    required this.pendingApprovals,
  });
}

class CategoryInventory {
  final String category;
  final int quantity;
  final double value;

  CategoryInventory({
    required this.category,
    required this.quantity,
    required this.value,
  });
}

class StockStatus {
  final int active;
  final int lowStock;

  StockStatus({required this.active, required this.lowStock});
}

class PurchaseOrderStatus {
  final int draft;
  final int issued;

  PurchaseOrderStatus({required this.draft, required this.issued});
}

class Transaction {
  final String date;
  final String type;
  final String item;
  final String quantity;
  final String user;

  Transaction({
    required this.date,
    required this.type,
    required this.item,
    required this.quantity,
    required this.user,
  });
}

class NavigationItem {
  final String title;
  final IconData icon;
  final bool isActive;

  NavigationItem({
    required this.title,
    required this.icon,
    this.isActive = false,
  });
}

class ItemMaster {
  final String? id; // Firestore document ID
  final String itemCode;
  final String itemName;
  final String manufacturer;
  final String type;
  final String category;
  final String unit;
  final String storage;
  final int stock;
  final String status;

  ItemMaster({
    this.id,
    required this.itemCode,
    required this.itemName,
    required this.manufacturer,
    required this.type,
    required this.category,
    required this.unit,
    required this.storage,
    required this.stock,
    required this.status,
  });
}

class ItemMasterFilter {
  final String? status;
  final String? category;
  final String? type;
  final String? nameQuery;

  const ItemMasterFilter({
    this.status,
    this.category,
    this.type,
    this.nameQuery,
  });

  ItemMasterFilter copyWith({
    String? status,
    String? category,
    String? type,
    String? nameQuery,
  }) {
    return ItemMasterFilter(
      status: status ?? this.status,
      category: category ?? this.category,
      type: type ?? this.type,
      nameQuery: nameQuery ?? this.nameQuery,
    );
  }

  bool get isActive =>
      status != null || category != null || type != null || nameQuery != null;

  bool matches(ItemMaster item) {
    final statusOk = status == null || item.status == status;
    final categoryOk = category == null || item.category == category;
    final typeOk = type == null || item.type == type;
    final nameOk =
        nameQuery == null ||
        item.itemName.toLowerCase().contains(nameQuery!.toLowerCase());
    return statusOk && categoryOk && typeOk && nameOk;
  }

  bool matchesMap(Map<String, dynamic> item) {
    final itemStatus = (item['status'] ?? '').toString();
    final itemCategory = (item['category'] ?? '').toString();
    final itemType = (item['type'] ?? '').toString();
    final itemName = (item['itemName'] ?? '').toString().toLowerCase();
    
    final statusOk = status == null || itemStatus == status;
    final categoryOk = category == null || itemCategory == category;
    final typeOk = type == null || itemType == type;
    final nameOk =
        nameQuery == null ||
        nameQuery!.isEmpty ||
        itemName.contains(nameQuery!.toLowerCase());
    return statusOk && categoryOk && typeOk && nameOk;
  }
}
