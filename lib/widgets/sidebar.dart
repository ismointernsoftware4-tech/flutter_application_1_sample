import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard},
      {'title': 'Item Master', 'icon': Icons.inventory_2},
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

    return Container(
      width: 250,
      color: const Color(0xFF1E3A5F),
      child: Column(
        children: [
          // Logo and title
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Image.asset(
                  'lib/assets/sample.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Embryo One',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final title = item['title'] as String;
                final icon = item['icon'] as IconData;
                final isActive = provider.selectedNavItem == title;
                return InkWell(
                  onTap: () => provider.setSelectedNavItem(title),
                  child: Container(
                    color: isActive ? const Color(0xFF2A4A6F) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: isActive ? Colors.white : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          title,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white70,
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // User section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'admin@inv.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

