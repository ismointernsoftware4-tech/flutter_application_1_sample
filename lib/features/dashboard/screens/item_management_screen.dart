import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../shared/utils/responsive_helper.dart';

class ItemManagementScreen extends StatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    // Load roles when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Search
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getScreenPadding(context).horizontal / 2),
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveHelper.isMobile(context);
                    final isTablet = ResponsiveHelper.isTablet(context);
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 700;
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isMobile || isTablet)
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () => Scaffold.of(context).openDrawer(),
                                tooltip: 'Open menu',
                              ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isSmallScreen ? double.infinity : 300,
                            ),
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Header Section
              Container(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveHelper.getScreenPadding(context).horizontal,
                  ResponsiveHelper.getScreenPadding(context).vertical,
                  ResponsiveHelper.getScreenPadding(context).horizontal,
                  20,
                ),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Management',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getTitleFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'View roles from Inventory collection in Firebase.',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.isMobile(context) ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveHelper.getScreenPadding(context).horizontal,
                    0,
                    ResponsiveHelper.getScreenPadding(context).horizontal,
                    ResponsiveHelper.getScreenPadding(context).vertical,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Roles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Stream roles from Firebase
                          StreamBuilder<List<String>>(
                            stream: _firebaseService.getRolesStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Error loading roles: ${snapshot.error}',
                                      style: TextStyle(color: Colors.red[600]),
                                    ),
                                  ),
                                );
                              }

                              final roles = snapshot.data ?? [];

                              if (roles.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No roles found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Create users in the admin section to see roles here',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Expanded(
                                child: ListView.builder(
                                  itemCount: roles.length,
                                  itemBuilder: (context, index) {
                                    final role = roles[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.shield_outlined,
                                              color: Colors.blue[700],
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  role,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Role from Inventory collection',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

