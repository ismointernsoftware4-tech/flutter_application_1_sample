import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';
import 'sidebar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final showDrawer = isMobile || isTablet;

    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: backgroundColor ?? Colors.grey[100],
          drawer: showDrawer ? const Sidebar() : null,
          body: Row(
            children: [
              if (!showDrawer && provider.sidebarVisible) const Sidebar(),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
