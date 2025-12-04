import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/storage_location_models.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/table_column_visibility_provider.dart';
import '../../../shared/widgets/filter_export_buttons.dart';
import '../../../shared/widgets/enhanced_filter_sheet.dart';
import '../../../shared/widgets/schema_table.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/utils/animated_routes.dart';
import 'create_location_screen.dart';

class StorageLocationsScreen extends StatefulWidget {
  const StorageLocationsScreen({super.key});

  @override
  State<StorageLocationsScreen> createState() => _StorageLocationsScreenState();
}

class _StorageLocationsScreenState extends State<StorageLocationsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).storageLocationSearchQuery;
      _searchController.text = query;
      // Load storage locations from Firebase
      final provider = Provider.of<DashboardProvider>(
        context,
        listen: false,
      );
      provider.loadStorageLocationsFromFirebase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final provider = context.read<DashboardProvider>();
    final filterKey = GlobalKey<_StorageLocationFilterSheetState>();
    final filterSheet = StorageLocationFilterSheet(
      key: filterKey,
      initialFilter: provider.storageLocationFilter,
      statuses: provider.storageLocationStatuses,
      types: provider.storageLocationTypes,
      parentLocations: provider.storageLocationParents,
    );
    
    final result = await EnhancedFilterSheet.show<StorageLocationFilter>(
      context: context,
      title: 'Filter Storage Locations',
      child: filterSheet,
      onApply: () => filterKey.currentState?.getFilter() ?? const StorageLocationFilter(),
      onClear: () => const StorageLocationFilter(),
    );
    
    if (result != null) {
      provider.updateStorageLocationFilter(result);
    }
  }

  Future<String> _handleExport() async {
    return await context.read<DashboardProvider>().exportStorageLocationsCsv();
  }

  @override
  Widget build(BuildContext context) {
    final locations = context
        .watch<DashboardProvider>()
        .filteredStorageLocationList;

    return ChangeNotifierProvider(
      create: (_) => TableColumnVisibilityProvider('storage_location'),
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getScreenPadding(context).copyWith(right: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _titleBar(context),
                    SizedBox(
                      height: ResponsiveHelper.isMobile(context) ? 16 : 24,
                    ),
                    _buildTable(context, locations),
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
                    controller: _searchController,
                    onChanged: (value) => context
                        .read<DashboardProvider>()
                        .updateStorageLocationSearchQuery(value),
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
                              fontSize: ResponsiveHelper.getTitleFontSize(
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen
                              ? double.infinity
                              : searchWidth,
                        ),
                        child: ShadInput(
                          controller: _searchController,
                          onChanged: (value) => context
                              .read<DashboardProvider>()
                              .updateStorageLocationSearchQuery(value),
                          placeholder: const Text('Search...'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _titleBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

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
                  FilterExportButtonRow(
                    onFilterPressed: _openFilterSheet,
                    onExportPressed: _handleExport,
                    filterLabel: 'Filter',
                    exportLabel: 'Export',
                    isMobile: true,
                    spacing: 8,
                  ),
                  ShadButton.outline(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Map'),
                      ],
                    ),
                  ),
                  ShadButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        AnimatedRoutes.slideRight(
                          const CreateLocationScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 8),
                        Text('Add'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              // Use Wrap layout for tablets or when screen width is less than 1000px
              // Lower threshold to catch more edge cases
              final useWrap = isTablet || constraints.maxWidth < 1000;
              
              if (useWrap) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilterExportButtonRow(
                          onFilterPressed: _openFilterSheet,
                          onExportPressed: _handleExport,
                          filterLabel: 'Filter',
                          exportLabel: 'Export',
                          isMobile: false,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('View Map'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueGrey[800],
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              AnimatedRoutes.slideRight(
                                const CreateLocationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
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
              
              // Desktop layout - use Expanded instead of Flexible and wrap buttons in Flexible
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
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
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FilterExportButtonRow(
                            onFilterPressed: _openFilterSheet,
                            onExportPressed: _handleExport,
                            filterLabel: 'Filter',
                            exportLabel: 'Export',
                            isMobile: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('View Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueGrey[800],
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                AnimatedRoutes.slideRight(
                                  const CreateLocationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }

  Widget _buildTable(BuildContext context, List<StorageLocation> locations) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      return _buildMobileCardView(locations);
    }

    // Convert StorageLocation objects to Map<String, dynamic>
    final mappedData = locations
        .map<Map<String, dynamic>>(
          (loc) => {
            'id': loc.id,
            'name': loc.name,
            'type': loc.type,
            'parentLocation': loc.parentLocation,
            'capacity': loc.capacity.toString(),
            'status': loc.status,
            'manager': loc.manager,
          },
        )
        .toList();

    return Consumer<TableColumnVisibilityProvider>(
      builder: (context, columnProvider, _) {
        if (columnProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final visibleColumns = columnProvider.visibleColumns;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.zero, // No radius on right to extend to edge
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Manage Columns button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) {
                            final isDialogMobile =
                                ResponsiveHelper.isMobile(dialogContext);
                            return AlertDialog(
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: isDialogMobile ? 12 : 80,
                                vertical: isDialogMobile ? 12 : 40,
                              ),
                              contentPadding: const EdgeInsets.all(24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: SizedBox(
                                width: isDialogMobile ? double.infinity : 640,
                                child: _InlineColumnPicker(
                                  provider: columnProvider,
                                  title: 'Manage Storage Location Columns',
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.view_column),
                      label: const Text('Manage Columns'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Constrain table height to avoid unbounded viewport errors
              SizedBox(
                width: double.infinity,
                height: 400,
                child: SchemaTable<Map<String, dynamic>>(
                  items: mappedData,
                  columns: visibleColumns,
                  columnWidth: isTablet ? 160 : 200,
                  emptyLabel:
                      'No storage locations found for the current filters.',
                  valueBuilder: (item, column) =>
                      _resolveColumnValue(item, column.key),
                  actionsBuilder: (item) =>
                      _buildTableActions(context, item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _resolveColumnValue(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return '';
    return value.toString();
  }

  List<Widget> _buildTableActions(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final locationId = (item['id'] ?? '').toString();
    return [
      IconButton(
        icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
        color: Colors.blue,
        tooltip: 'View $locationId',
        onPressed: () {},
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.edit_outlined, size: 18),
        color: Colors.orange,
        tooltip: 'Edit $locationId',
        onPressed: () {},
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: Colors.red,
        tooltip: 'Delete $locationId',
        onPressed: () {},
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ];
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
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMobileCardView(List<StorageLocation> locations) {
    return Column(
      children: locations.asMap().entries.map((entry) {
        final location = entry.value;
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
        )
          .animate()
          .fadeIn(duration: 400.ms, delay: (entry.key * 100).ms)
          .slideX(begin: -0.1, end: 0)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
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
        DefaultTextStyle(style: const TextStyle(fontSize: 12), child: value),
      ],
    );
  }
}

class StorageLocationFilterSheet extends StatefulWidget {
  const StorageLocationFilterSheet({
    super.key,
    required this.initialFilter,
    required this.statuses,
    required this.types,
    required this.parentLocations,
  });

  final StorageLocationFilter initialFilter;
  final List<String> statuses;
  final List<String> types;
  final List<String> parentLocations;

  @override
  State<StorageLocationFilterSheet> createState() =>
      _StorageLocationFilterSheetState();
}

class _StorageLocationFilterSheetState
    extends State<StorageLocationFilterSheet> {
  String? _status;
  String? _type;
  String? _parentLocation;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialFilter.status;
    _type = widget.initialFilter.type;
    _parentLocation = widget.initialFilter.parentLocation;
    _searchController = TextEditingController(
      text: widget.initialFilter.searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  StorageLocationFilter getFilter() {
    return StorageLocationFilter(
      status: _status,
      type: _type,
      parentLocation: _parentLocation,
      searchQuery: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadInput(
          controller: _searchController,
          placeholder: const Text('Search'),
        ),
        if (widget.statuses.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Status',
            value: _status,
            items: widget.statuses,
            onChanged: (value) => setState(() => _status = value),
          ),
        ],
        if (widget.types.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Type',
            value: _type,
            items: widget.types,
            onChanged: (value) => setState(() => _type = value),
          ),
        ],
        if (widget.parentLocations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Parent Location',
            value: _parentLocation,
            items: widget.parentLocations,
            onChanged: (value) => setState(() => _parentLocation = value),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final dropdownItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Any')),
      ...items.map((e) => DropdownMenuItem<String?>(value: e, child: Text(e))),
    ];

    return DropdownButtonFormField<String?>(
      value: value,
      items: dropdownItems,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }
}

class _InlineColumnPicker extends StatelessWidget {
  const _InlineColumnPicker({
    required this.provider,
    required this.title,
  });

  final TableColumnVisibilityProvider provider;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: provider,
          builder: (context, _) {
            if (provider.isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final columns = provider.columns;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: provider.resetToDefault,
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: columns
                      .map(
                        (column) => FilterChip(
                          label: Text(column.label),
                          selected: column.visible,
                          onSelected: (value) =>
                              provider.toggleColumn(column.key, value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: columns.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final column = columns[index];
                      return SwitchListTile(
                        title: Text(column.label),
                        subtitle: Text(column.description),
                        value: column.visible,
                        onChanged: (value) =>
                            provider.toggleColumn(column.key, value),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.setAll(false),
                        icon: const Icon(Icons.visibility_off),
                        label: const Text('Hide All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.setAll(true),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show All'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
