import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/traceability_models.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/widgets/filter_export_buttons.dart';
import '../../../shared/widgets/enhanced_filter_sheet.dart';

class TraceabilityScreen extends StatefulWidget {
  const TraceabilityScreen({super.key});

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context) {
    final provider = context.read<DashboardProvider>();
    final filterKey = GlobalKey<_TraceabilityFilterSheetState>();
    final filterSheet = TraceabilityFilterSheet(
      key: filterKey,
      initialFilter: provider.traceabilityFilter,
      types: provider.traceabilityTypes,
      users: provider.traceabilityUsers,
      locations: provider.traceabilityLocations,
    );
    
    EnhancedFilterSheet.show<TraceabilityFilter>(
      context: context,
      title: 'Filter Traceability',
      child: filterSheet,
      onApply: () => filterKey.currentState?.getFilter() ?? const TraceabilityFilter(),
      onClear: () => const TraceabilityFilter(),
    ).then((filter) {
      if (filter != null) {
        provider.updateTraceabilityFilter(filter);
      }
    });
  }

  Future<String> _handleExport() {
    return context.read<DashboardProvider>().exportTraceabilityCsv();
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<DashboardProvider>().filteredTraceabilityList;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                children: [
                  _titleBar(context),
                  const SizedBox(height: 20),
                  _table(records),
                ],
              ),
            ),
          ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                  if (!isSmallScreen)
                    Text(
                      'Transaction Traceability',
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
                    controller: _searchController,
                    onChanged: (value) => context
                        .read<DashboardProvider>()
                        .updateTraceabilitySearchQuery(value),
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

  Widget _titleBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                FilterExportButtonRow(
                  onFilterPressed: () => _openFilterSheet(context),
                  onExportPressed: _handleExport,
                  filterLabel: 'Filter',
                  exportLabel: 'Export Log',
                  isMobile: true,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilterExportButtonRow(
                  onFilterPressed: () => _openFilterSheet(context),
                  onExportPressed: _handleExport,
                  filterLabel: 'Filter',
                  exportLabel: 'Export Log',
                ),
              ],
            ),
    );
  }

  Widget _table(List<TraceabilityRecord> records) {
    final headers = [
      'Date & Time',
      'Type',
      'Reference',
      'Item Details',
      'Quantity',
      'User / Location',
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
          ...records.asMap().entries.map(
            (entry) {
              final record = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(record.dateTime)),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _typeIcon(record.type),
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            record.type,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _linkText(record.reference)),
                  Expanded(child: Text(record.itemDetails)),
                  Expanded(
                    child: Text(
                      record.quantity,
                      style: TextStyle(
                        color: record.quantity.startsWith('+')
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.user),
                        Text(
                          record.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
              .animate()
              .fadeIn(duration: 300.ms, delay: (entry.key * 50).ms)
              .slideX(begin: 0.05, end: 0);
            }
          ),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.05, end: 0);
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'grn':
        return Icons.south_west;
      case 'adjustment':
        return Icons.autorenew;
      case 'issue':
        return Icons.north_east;
      default:
        return Icons.info_outline;
    }
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
}

class TraceabilityFilterSheet extends StatefulWidget {
  const TraceabilityFilterSheet({
    super.key,
    required this.initialFilter,
    required this.types,
    required this.users,
    required this.locations,
  });

  final TraceabilityFilter initialFilter;
  final List<String> types;
  final List<String> users;
  final List<String> locations;

  @override
  State<TraceabilityFilterSheet> createState() =>
      _TraceabilityFilterSheetState();
}

class _TraceabilityFilterSheetState extends State<TraceabilityFilterSheet> {
  String? _type;
  String? _user;
  String? _location;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _type = widget.initialFilter.type;
    _user = widget.initialFilter.user;
    _location = widget.initialFilter.location;
    _searchController = TextEditingController(
      text: widget.initialFilter.searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TraceabilityFilter getFilter() {
    return TraceabilityFilter(
      type: _type,
      user: _user,
      location: _location,
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
          placeholder: const Text('Search by Item, Reference, or Batch'),
        ),
        if (widget.types.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Type',
            value: _type,
            items: widget.types,
            onChanged: (value) => setState(() => _type = value),
          ),
        ],
        if (widget.users.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'User',
            value: _user,
            items: widget.users,
            onChanged: (value) => setState(() => _user = value),
          ),
        ],
        if (widget.locations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Location',
            value: _location,
            items: widget.locations,
            onChanged: (value) => setState(() => _location = value),
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
