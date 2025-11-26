import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';

class StorageMapViewScreen extends StatelessWidget {
  const StorageMapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<DashboardProvider>().storageLocations;
    final padding = ResponsiveHelper.getScreenPadding(context);

    return Material(
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 24),
                    _titleSection(),
                    const SizedBox(height: 32),
                    ..._buildStorageSections(context, locations),
                    const SizedBox(height: 32),
                    _cryogenicStorageMap(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open menu',
                    ),
                    Expanded(
                      child: Text(
                        'Storage Locations',
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 700;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isTablet)
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            tooltip: 'Open menu',
                          ),
                        if (!isSmallScreen)
                          Text(
                            'Storage Locations',
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
                              borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            '← Back to Location List',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Locations',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hierarchical view of all storage locations and their contents.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStorageSections(BuildContext context, List<StorageLocation> locations) {
    // Filter out nested locations (Racks, Shelves, Bins) - only show top-level locations
    final topLevelLocations = locations.where((loc) {
      final type = loc.type.toLowerCase();
      return type != 'rack' && type != 'shelf' && type != 'bin';
    }).toList();
    
    // Group locations by category
    final Map<String, List<StorageLocation>> groupedLocations = {};
    
    for (var location in topLevelLocations) {
      String category = _getCategory(location.type, location.description);
      if (!groupedLocations.containsKey(category)) {
        groupedLocations[category] = [];
      }
      groupedLocations[category]!.add(location);
    }

    List<Widget> sections = [];

    // Refrigerators & Cold Storage
    if (groupedLocations.containsKey('Refrigerators & Cold Storage')) {
      sections.add(_buildCategorySection(
        title: 'Refrigerators & Cold Storage',
        icon: Icons.ac_unit,
        locations: groupedLocations['Refrigerators & Cold Storage']!,
      ));
      sections.add(const SizedBox(height: 32));
    }

    // Storage Cabinets
    if (groupedLocations.containsKey('Storage Cabinets')) {
      sections.add(_buildCategorySection(
        title: 'Storage Cabinets',
        icon: Icons.inventory_2,
        locations: groupedLocations['Storage Cabinets']!,
      ));
      sections.add(const SizedBox(height: 32));
    }

    // Warehouses
    if (groupedLocations.containsKey('Warehouses')) {
      sections.add(_buildCategorySection(
        title: 'Warehouses',
        icon: Icons.warehouse,
        locations: groupedLocations['Warehouses']!,
      ));
    }

    return sections;
  }

  String _getCategory(String type, String description) {
    final typeLower = type.toLowerCase();
    final descLower = description.toLowerCase();
    
    // Check if it's a cold storage based on description
    if (descLower.contains('2-8') || descLower.contains('cold') || 
        (typeLower == 'room' && descLower.contains('storage'))) {
      return 'Refrigerators & Cold Storage';
    }
    
    switch (typeLower) {
      case 'cabinet':
        return 'Storage Cabinets';
      case 'warehouse':
        return 'Warehouses';
      case 'room':
        // Default rooms go to cold storage if no specific category
        return 'Refrigerators & Cold Storage';
      default:
        return 'Other';
    }
  }

  Widget _buildCategorySection({
    required String title,
    required IconData icon,
    required List<StorageLocation> locations,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final useCompactCards = availableWidth >= 640;
        final cardWidth = useCompactCards ? 360.0 : availableWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.grey[800]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: locations
                  .map(
                    (location) => SizedBox(
                      width: cardWidth,
                      child: _buildLocationCard(
                        location,
                        compact: useCompactCards,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationCard(
    StorageLocation location, {
    bool compact = false,
  }) {
    final capacityColor = _getCapacityColor(location.capacity);
    final temperature = _getTemperature(location);
    final titleStyle = TextStyle(
      fontSize: compact ? 17 : 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    location.name,
                    style: titleStyle,
                  ),
                ],
              ),
              _typeBadge(location.type),
            ],
          ),
          SizedBox(height: compact ? 12 : 16),
          Row(
            children: [
              const Icon(Icons.thermostat, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Temperature: $temperature',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Capacity',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${location.capacity}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: capacityColor,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 12 : 16),
          _buildShelvesSection(location),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatType(type),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }

  String _formatType(String type) {
    switch (type.toLowerCase()) {
      case 'warehouse':
        return 'Warehouse';
      case 'room':
        return 'Refrigerator';
      case 'cabinet':
        return 'Storage Cabinet';
      default:
        return type;
    }
  }

  Color _getCapacityColor(int capacity) {
    if (capacity >= 80) {
      return Colors.red.shade600;
    } else if (capacity >= 50) {
      return Colors.blue.shade600;
    } else {
      return Colors.green.shade600;
    }
  }

  String _getTemperature(StorageLocation location) {
    final descLower = location.description.toLowerCase();
    if (descLower.contains('2-8') || descLower.contains('cold')) {
      return '2-8°C';
    }
    return 'Room Temp';
  }

  Widget _buildShelvesSection(StorageLocation location) {
    // Generate mock shelf data based on location
    final shelves = _generateShelves(location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shelves/Sections:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...shelves.map((shelf) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shelf['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${shelf['items']} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  List<Map<String, dynamic>> _generateShelves(StorageLocation location) {
    // Generate shelf data based on location name to match the design
    final locationName = location.name.toLowerCase();
    
    if (locationName.contains('cold storage room') || locationName.contains('cold storage')) {
      return [
        {'name': 'Shelf 1', 'items': 6},
        {'name': 'Shelf 2', 'items': 32},
        {'name': 'Shelf 3', 'items': 16},
      ];
    } else if (locationName.contains('chemical cabinet')) {
      return [
        {'name': 'Shelf 1', 'items': 33},
        {'name': 'Shelf 2', 'items': 27},
        {'name': 'Shelf 3', 'items': 17},
      ];
    } else {
      // Default shelf data for other locations
      final baseItems = (location.capacity * 0.6).round(); // 60% of capacity as total items
      return [
        {'name': 'Shelf 1', 'items': (baseItems * 0.35).round()},
        {'name': 'Shelf 2', 'items': (baseItems * 0.40).round()},
        {'name': 'Shelf 3', 'items': (baseItems * 0.25).round()},
      ];
    }
  }

  Widget _cryogenicStorageMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cryogenic Storage Map',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Visual map of cryogenic tank positions.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTankGrid(),
              const SizedBox(height: 20),
              _buildLegend(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTankGrid() {
    // Create a 4x8 grid of tank positions
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 32,
      itemBuilder: (context, index) {
        // First 16 tanks are canister 1, next 16 are canister 2
        final isCanister1 = index < 16;
        final isFilled = index < 16;

        return Container(
          decoration: BoxDecoration(
            color: isCanister1
                ? Colors.blue.shade200
                : isFilled
                    ? Colors.cyan.shade300
                    : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('Canister 1 (23 vials)', Colors.blue.shade200),
        const SizedBox(width: 24),
        _legendItem('Canister 2 (18 vials)', Colors.cyan.shade300),
        const SizedBox(width: 24),
        _legendItem('Empty', Colors.grey.shade200),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

