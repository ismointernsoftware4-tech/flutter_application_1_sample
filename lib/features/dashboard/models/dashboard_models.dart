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

class InventoryQuickAction {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String navTarget;

  const InventoryQuickAction({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.navTarget = '',
  });
}


