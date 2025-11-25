import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/vendor_card.dart';
import '../widgets/add_vendor_sidebar.dart';
import '../utils/responsive_helper.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() =>
      _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {
  static const List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final vendors = provider.vendors.where((vendor) {
      if (_selectedFilter == 'All') return true;
      return vendor.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
    final showSidebar = provider.showAddVendorSidebar;
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Stack(
      children: [
        Container(
          color: Colors.grey[100],
          child: SingleChildScrollView(
            padding: screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: isMobile ? 16 : 24),
                _buildFilters(context),
                SizedBox(height: isMobile ? 16 : 24),
                _buildActionBar(context),
                SizedBox(height: isMobile ? 16 : 24),
                _buildVendorGrid(context, vendors),
              ],
            ),
          ),
        ),
        // Sidebar overlay
        if (showSidebar)
          Positioned.fill(
            child: Stack(
              children: [
                // Backdrop
                GestureDetector(
                  onTap: () => context.read<DashboardProvider>().closeAddVendorSidebar(),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                // Sidebar
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when clicking sidebar
                    child: const AddVendorSidebar(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);
    
    return Container(
      padding: screenPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Menu icon for mobile/tablet
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          tooltip: 'Open menu',
                        ),
                        Expanded(
                          child: Text(
                            'Vendor Management',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ],
                )
              :               LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isSmallScreen = screenWidth < 700;
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Menu icon for tablet
                          if (isTablet)
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                              tooltip: 'Open menu',
                            ),
                          if (!isSmallScreen)
                            Text(
                              'Vendor Management',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getTitleFontSize(context),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? double.infinity : searchWidth,
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          SizedBox(height: isMobile ? 16 : 24),
          isMobile
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab('Purchase Requisitions', false),
                      _buildTab('Purchase Orders', false),
                      _buildTab('Vendors', true),
                    ],
                  ),
                )
              : Row(
                  children: [
                    _buildTab('Purchase Requisitions', false),
                    _buildTab('Purchase Orders', false),
                    _buildTab('Vendors', true),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.indigo : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isActive,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.indigo.shade50,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.indigo : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          )
        : Row(
            children: _filters.map((filter) {
              final isActive = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isActive,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  selectedColor: Colors.indigo.shade50,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.indigo : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.white,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildActionBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _outlineButton(Icons.filter_list, 'Filter', () {}),
                  _outlineButton(Icons.download, 'Export', () {}),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DashboardProvider>().openAddVendorSidebar();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Vendor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _outlineButton(Icons.filter_list, 'Filter', () {}),
                  const SizedBox(width: 12),
                  _outlineButton(Icons.download, 'Export', () {}),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DashboardProvider>().openAddVendorSidebar();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Vendor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildVendorGrid(BuildContext context, List<Vendor> vendors) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    if (vendors.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text('No vendors found for this filter'),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: vendors.map((vendor) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: VendorCard(vendor: vendor),
          );
        }).toList(),
      );
    }

    final crossAxisCount = isTablet ? 2 : 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = ResponsiveHelper.getScreenPadding(context);
    final availableWidth = screenWidth - (padding.horizontal * 2);
    final cardWidth = (availableWidth - (crossAxisCount - 1) * 20) / crossAxisCount;

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: vendors.map((vendor) {
        return SizedBox(
          width: cardWidth,
          child: VendorCard(vendor: vendor),
        );
      }).toList(),
    );
  }

  Widget _outlineButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}


