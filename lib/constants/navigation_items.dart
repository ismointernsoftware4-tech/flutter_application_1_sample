import 'package:flutter/material.dart';

class NavigationItems {
  static const List<Map<String, dynamic>> sidebarItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Item Master', 'icon': Icons.inventory_2},
    {'title': 'Item Management', 'icon': Icons.inventory},
    {'title': 'Procurement', 'icon': Icons.shopping_cart},
    {'title': 'Vendor Management', 'icon': Icons.business},
    {'title': 'GRN & Receiving', 'icon': Icons.local_shipping},
    {'title': 'Inventory Control', 'icon': Icons.assignment},
    {'title': 'Storage Locations', 'icon': Icons.location_on},
    {'title': 'Traceability', 'icon': Icons.timeline},
    {'title': 'Approvals', 'icon': Icons.check_circle},
    {'title': 'Reports', 'icon': Icons.bar_chart},
    {'title': 'Users & Roles', 'icon': Icons.people},
    {'title': 'Settings', 'icon': Icons.settings},
  ];

  static List<String> get titles =>
      sidebarItems.map((item) => item['title'] as String).toList();
}


