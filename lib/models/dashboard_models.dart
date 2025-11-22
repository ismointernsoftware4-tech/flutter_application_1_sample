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

  StockStatus({
    required this.active,
    required this.lowStock,
  });
}

class PurchaseOrderStatus {
  final int draft;
  final int issued;

  PurchaseOrderStatus({
    required this.draft,
    required this.issued,
  });
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

