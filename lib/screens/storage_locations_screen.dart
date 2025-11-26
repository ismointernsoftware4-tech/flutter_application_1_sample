import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/add_location_sidebar.dart';
import '../utils/responsive_helper.dart';

class StorageLocationsScreen extends StatefulWidget {
  const StorageLocationsScreen({super.key});

  @override
  State<StorageLocationsScreen> createState() => _StorageLocationsScreenState();
}

class _StorageLocationsScreenState extends State<StorageLocationsScreen> {
  bool _showMapView = false;

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<DashboardProvider>().storageLocations;
    final showForm = context.watch<DashboardProvider>().showAddLocationSidebar;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: showForm
                  ? const AddLocationSidebar(key: ValueKey('add-location-form'))
                  : _mainContent(context, locations),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainContent(BuildContext context, List<StorageLocation> locations) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showMapView) _backButton(context),
          if (_showMapView) const SizedBox(height: 24),
          _titleBar(context),
          SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
          _showMapView
              ? _mapViewContent(context, locations)
              : _table(context, locations),
        ],
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
                    // Menu icon for mobile/tablet
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
      onTap: () {
        setState(() {
          _showMapView = false;
        });
      },
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

  Widget _titleBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Show different title for map view
    if (_showMapView) {
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
    
    // Regular table view title bar
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage Locations',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage warehouses, rooms, racks, and bins.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _outlineButton(Icons.filter_list, 'Filter'),
                  _outlineButton(Icons.download, 'Export'),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMapView = true;
                      });
                    },
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey[800],
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardProvider>().openAddLocationSidebar();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage Locations',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage warehouses, rooms, racks, and bins.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  _outlineButton(Icons.filter_list, 'Filter'),
                  const SizedBox(width: 12),
                  _outlineButton(Icons.download, 'Export'),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMapView = true;
                      });
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('View Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey[800],
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardProvider>().openAddLocationSidebar();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _table(BuildContext context, List<StorageLocation> locations) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isMobile) {
      return _buildMobileCardView(locations);
    }
    
    final headers = [
      'ID',
      'Name',
      'Type',
      'Parent Location',
      'Capacity',
      'Status',
      'Actions',
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: headers
                  .map(
                    (header) => Expanded(
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          ...locations.map(
            (location) => Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _linkText(location.id),
                  ),
                  Expanded(
                    child: Text(location.name),
                  ),
                  Expanded(
                    child: _badge(location.type),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.warehouse_outlined,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Flexible(child: Text(location.parentLocation)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text('${location.capacity}%'),
                  ),
                  Expanded(
                    child: _statusChip(location.status),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.remove_red_eye_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
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

  Widget _linkText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.blue[700],
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF1F5F9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF635BFF),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.green.shade600 : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMobileCardView(List<StorageLocation> locations) {
    return Column(
      children: locations.map((location) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _linkText(location.id),
                          const SizedBox(height: 4),
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusChip(location.status),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMobileInfo('Type', _badge(location.type)),
                    _buildMobileInfo('Parent', Text(location.parentLocation)),
                    _buildMobileInfo('Capacity', Text('${location.capacity}%')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileInfo(String label, Widget value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: value,
        ),
      ],
    );
  }

  Widget _mapViewContent(BuildContext context, List<StorageLocation> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        ..._buildStorageSections(context, locations),
        const SizedBox(height: 32),
        _cryogenicStorageMap(),
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
              _mapTypeBadge(location.type),
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

  Widget _mapTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatMapType(type),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }

  String _formatMapType(String type) {
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

