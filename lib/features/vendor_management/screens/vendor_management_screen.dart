import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../models/vendor_models.dart';
import 'create_vendor_screen.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/utils/animated_routes.dart';
import '../../../shared/widgets/filter_export_buttons.dart';
import '../../../shared/widgets/vendor_card.dart';
import '../../../shared/widgets/enhanced_filter_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_input.dart';
import '../../../shared/widgets/sidebar.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<DashboardProvider>();
    _searchController = TextEditingController(text: provider.vendorSearchQuery);

    // Load vendor data from Firebase on screen open so vendors persist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadVendorsFromFirebase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _dismissKeyboardAndPreventScroll() {
    // Store current scroll position immediately
    double? currentOffset;
    if (_scrollController.hasClients) {
      currentOffset = _scrollController.offset;
    }
    
    // Unfocus any text fields to dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Prevent scroll view from auto-scrolling by restoring position
    // Use SchedulerBinding to ensure it runs after the current frame
    if (currentOffset != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && mounted) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final clampedOffset = currentOffset!.clamp(0.0, maxScroll);
          // Only restore if position has changed significantly
          if ((_scrollController.offset - clampedOffset).abs() > 1.0) {
            _scrollController.jumpTo(clampedOffset);
          }
        }
      });
    }
  }

  Future<void> _openFilterSheet() async {
    final provider = context.read<DashboardProvider>();
    final filterKey = GlobalKey<_VendorFilterSheetState>();
    final filterSheet = VendorFilterSheet(
      key: filterKey,
      initialFilter: provider.vendorFilter,
      statuses: provider.vendorStatuses,
      categories: provider.vendorCategories,
    );
    
    final result = await EnhancedFilterSheet.show<VendorFilter>(
      context: context,
      title: 'Filter Vendors',
      child: filterSheet,
      onApply: () => filterKey.currentState?.getFilter() ?? const VendorFilter(),
      onClear: () => const VendorFilter(),
    );

    if (result != null) {
      provider.updateVendorFilter(result);
    }
  }

  Future<String> _handleExport() {
    return context.read<DashboardProvider>().exportVendorsCsv();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final vendors = provider.filteredVendorList;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    return Scaffold(
      // Provide a drawer on mobile/tablet so the menu icon appears and screens can be switched
      drawer: (isMobile || isTablet) ? const Sidebar() : null,
      appBar: AppBar(
        title: const Text('Vendor Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontSize: ResponsiveHelper.getTitleFontSize(context),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: screenPadding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final isMobile = ResponsiveHelper.isMobile(context);
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
              ? SizedBox(
                  width: double.infinity,
                  child: AppInput(
                    controller: _searchController,
                    onChanged: provider.updateVendorSearchQuery,
                    placeholder: 'Search...',
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 700;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  isSmallScreen ? double.infinity : searchWidth,
                            ),
                            child: AppInput(
                              controller: _searchController,
                              onChanged: provider.updateVendorSearchQuery,
                              placeholder: 'Search...',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          SizedBox(height: isMobile ? 16 : 24),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final statuses = provider.vendorStatuses;
    final allFilters = ['All', ...statuses];
    final isMobile = ResponsiveHelper.isMobile(context);

    Iterable<Widget> buildChips() {
      return allFilters.map((filter) {
        final isActive = filter == 'All'
            ? provider.vendorFilter.status == null
            : provider.vendorFilter.status == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(filter),
            selected: isActive,
            onSelected: (_) {
              provider.updateVendorFilter(
                provider.vendorFilter.copyWith(
                  status: filter == 'All' ? null : filter,
                ),
              );
            },
            selectedColor: Colors.indigo.shade50,
            labelStyle: TextStyle(
              color: isActive ? Colors.indigo : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
          ),
        );
      });
    }

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: buildChips().toList()),
      );
    }

    return Row(children: buildChips().toList());
  }

  Widget _buildActionBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilterExportButtonRow(
                onFilterPressed: () {
                  _dismissKeyboardAndPreventScroll();
                  _openFilterSheet();
                },
                onExportPressed: () {
                  _dismissKeyboardAndPreventScroll();
                  return _handleExport();
                },
                filterLabel: 'Filter',
                exportLabel: 'Export',
                isMobile: true,
                spacing: 8,
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () {
                  _dismissKeyboardAndPreventScroll();
                  Navigator.of(context).push(
                    AnimatedRoutes.slideRight(
                      const CreateVendorScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add New Vendor'),
                  ],
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilterExportButtonRow(
                onFilterPressed: () {
                  _dismissKeyboardAndPreventScroll();
                  _openFilterSheet();
                },
                onExportPressed: () {
                  _dismissKeyboardAndPreventScroll();
                  return _handleExport();
                },
                filterLabel: 'Filter',
                exportLabel: 'Export',
                isMobile: false,
              ),
              AppButton(
                onPressed: () {
                  _dismissKeyboardAndPreventScroll();
                  Navigator.of(context).push(
                    AnimatedRoutes.slideRight(
                      const CreateVendorScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add New Vendor'),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildVendorGrid(BuildContext context, List<Map<String, dynamic>> vendors) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text('No vendors found for this filter'),
            ],
          ),
        ),
      );
    }

    Vendor _mapToVendor(Map<String, dynamic> vendor) {
      return Vendor(
        id: (vendor['id'] ?? '').toString(),
        name: (vendor['name'] ?? '').toString(),
        category: (vendor['category'] ?? '').toString(),
        contactName: (vendor['contactName'] ?? '').toString(),
        email: (vendor['email'] ?? '').toString(),
        phone: (vendor['phone'] ?? '').toString(),
        status: (vendor['status'] ?? '').toString(),
        address: (vendor['address'] ?? '').toString(),
        paymentTerms: (vendor['paymentTerms'] ?? '').toString(),
        notes: (vendor['notes'] ?? '').toString(),
      );
    }

    if (isMobile) {
      return Column(
        children: vendors
            .map(
              (vendor) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: VendorCard(vendor: _mapToVendor(vendor)),
              ),
            )
            .toList(),
      );
    }

    final crossAxisCount = isTablet ? 2 : 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = ResponsiveHelper.getScreenPadding(context);
    final availableWidth = screenWidth - (padding.horizontal * 2);
    final cardWidth =
        (availableWidth - (crossAxisCount - 1) * 20) / crossAxisCount;

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.end,       // Align cards to the right
      runAlignment: WrapAlignment.start,  // Keep rows at the top
      children: vendors
          .map(
            (vendor) => SizedBox(
              width: cardWidth,
              child: VendorCard(vendor: _mapToVendor(vendor)),
            ),
          )
          .toList(),
    );
  }
}

class VendorFilterSheet extends StatefulWidget {
  const VendorFilterSheet({
    super.key,
    required this.initialFilter,
    required this.statuses,
    required this.categories,
  });

  final VendorFilter initialFilter;
  final List<String> statuses;
  final List<String> categories;

  @override
  State<VendorFilterSheet> createState() => _VendorFilterSheetState();
}

class _VendorFilterSheetState extends State<VendorFilterSheet> {
  String? _status;
  String? _category;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialFilter.status;
    _category = widget.initialFilter.category;
    _searchController = TextEditingController(
      text: widget.initialFilter.searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  VendorFilter getFilter() {
    return VendorFilter(
      status: _status,
      category: _category,
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
        if (widget.categories.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Category',
            value: _category,
            items: widget.categories,
            onChanged: (value) => setState(() => _category = value),
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
      ...items.map(
        (e) => DropdownMenuItem<String?>(value: e, child: Text(e)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String?>(
        initialValue: value,
        items: dropdownItems,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
