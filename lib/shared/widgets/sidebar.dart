import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../core/constants/navigation_items.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final navItems = NavigationItems.sidebarItems;

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
                  'assets/sample.png',
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
                )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                  .slideX(begin: -0.1, end: 0);
              },
            ),
          ),
          // User section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.sessionName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            authProvider.sessionEmail,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => authProvider.logout(),
                    icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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

