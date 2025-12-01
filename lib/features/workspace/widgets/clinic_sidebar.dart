import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../clinic/providers/clinic_workspace_provider.dart';

class ClinicSidebar extends StatelessWidget {
  const ClinicSidebar({super.key, this.isDrawer = false});

  final bool isDrawer;

  static const List<_ClinicNavItem> _navItems = [
    _ClinicNavItem('Clinic Dashboard', Icons.dashboard_outlined),
    _ClinicNavItem('Clinic Details', Icons.description_outlined),
    _ClinicNavItem('Clinic Branches', Icons.account_tree_outlined),
    _ClinicNavItem('Clinic Users', Icons.people_outline),
    _ClinicNavItem('Clinic Roles', Icons.security_outlined),
    _ClinicNavItem('Clinic Settings', Icons.settings_outlined),
    _ClinicNavItem('Clinic Form Builder', Icons.edit_note_outlined),
  ];

  static const List<_ClinicFormNavItem> _formNavItems = [];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicWorkspaceProvider>();
    final selected = provider.selectedSection;

    return Container(
      width: 240,
      color: const Color(0xFF1E3A5F),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Clinic Workspace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              children: [
                ..._navItems.map((item) {
                  final isActive = item.title == selected;
                  return InkWell(
                    onTap: () {
                      provider.setSection(item.title);
                      if (isDrawer) Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      color: isActive
                          ? const Color(0xFF2A4A6F)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isActive ? Colors.white : Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (_formNavItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Clinic Forms',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ..._formNavItems.map((item) {
                    final isActive = item.navKey == selected;
                    return InkWell(
                      onTap: () {
                        provider.setSection(item.navKey);
                        if (isDrawer) Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        color: isActive
                            ? const Color(0xFF2A4A6F)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isActive ? Colors.white : Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicNavItem {
  final String title;
  final IconData icon;

  const _ClinicNavItem(this.title, this.icon);
}

class _ClinicFormNavItem {
  final String title;
  final IconData icon;
  final String navKey;

  const _ClinicFormNavItem(this.title, this.icon, this.navKey);
}

