import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/grn_models.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/table_column_visibility_provider.dart';
import '../../../shared/widgets/filter_export_buttons.dart';
import '../../../shared/widgets/enhanced_filter_sheet.dart';
import '../../../shared/widgets/schema_table.dart';
import '../../../shared/utils/responsive_helper.dart';
import 'create_grn_screen.dart';

class GrnReceivingScreen extends StatefulWidget {
  const GrnReceivingScreen({super.key});

  @override
  State<GrnReceivingScreen> createState() => _GrnReceivingScreenState();
}

class _GrnReceivingScreenState extends State<GrnReceivingScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).grnSearchQuery;
      _searchController.text = query;
      // Load GRNs from Firebase
      final provider = Provider.of<DashboardProvider>(
        context,
        listen: false,
      );
      provider.loadGRNsFromFirebase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final provider = context.read<DashboardProvider>();
    final filterKey = GlobalKey<_GRNFilterSheetState>();
    final filterSheet = GRNFilterSheet(
      key: filterKey,
      initialFilter: provider.grnFilter,
      statuses: provider.grnStatuses,
      vendors: provider.grnVendors,
      poReferences: provider.grnPOReferences,
    );
    
    final result = await EnhancedFilterSheet.show<GRNFilter>(
      context: context,
      title: 'Filter GRN',
      child: filterSheet,
      onApply: () => filterKey.currentState?.getFilter() ?? const GRNFilter(),
      onClear: () => const GRNFilter(),
    );
    
    if (result != null) {
      provider.updateGRNFilter(result);
    }
  }

  Future<String> _handleExport() async {
    return await context.read<DashboardProvider>().exportGRNCsv();
  }

  @override
  Widget build(BuildContext context) {
    final goodsReceipts = context.watch<DashboardProvider>().filteredGRNList;

    return Container(
      color: Colors.grey[100],
      child: ChangeNotifierProvider(
        create: (_) => TableColumnVisibilityProvider('grn'),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActionBar(),
                    const SizedBox(height: 24),
                    _buildTable(goodsReceipts),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                      'GRN & Receiving',
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
                        .updateGRNSearchQuery(value),
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

  Widget _buildActionBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilterExportButtonRow(
            onFilterPressed: _openFilterSheet,
            onExportPressed: _handleExport,
            filterLabel: 'Filter',
            exportLabel: 'Export',
            isMobile: false,
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateGRNScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New GRN'),
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
      ),
    );
  }

  Widget _buildTable(List<GoodsReceipt> data) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Show cards on mobile, table on desktop/tablet
    if (isMobile) {
      return _buildGRNMobileCardView(data);
    }

    // Map GoodsReceipt → Map<String, dynamic> for dynamic SchemaTable
    final mappedData = data
        .map<Map<String, dynamic>>(
          (g) => {
            'grnId': g.grnId,
            'poReference': g.poReference,
            'vendor': g.vendor,
            'dateReceived': g.dateReceived,
            'receivedBy': g.receivedBy,
            'status': g.status,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Manage Columns
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
                                  title: 'Manage GRN Columns',
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
                height: 400,
                child: SchemaTable<Map<String, dynamic>>(
                  items: mappedData,
                  columns: visibleColumns,
                  columnWidth: isTablet ? 160 : 200,
                  emptyLabel: 'No GRN records found for the current filters.',
                  valueBuilder: (item, column) =>
                      _resolveColumnValue(item, column.key),
                  actionsBuilder: (item) => _buildTableActions(context, item),
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
    final grnId = (item['grnId'] ?? '').toString();
    return [
      IconButton(
        icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
        color: Colors.blue,
        tooltip: 'View $grnId',
        onPressed: () {
          // TODO: open GRN details
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.check_circle_outline, size: 18),
        color: Colors.green,
        tooltip: 'Approve $grnId',
        onPressed: () {
          // TODO: approve GRN
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ];
  }

  Widget _statusChip(String status) {
    final color = status.toLowerCase() == 'completed'
        ? Colors.green.shade600
        : Colors.blueGrey;

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

  // Mobile card view for GRN
  Widget _buildGRNMobileCardView(List<GoodsReceipt> grns) {
    if (grns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No GRN records found.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: grns.length,
      itemBuilder: (context, index) {
        final grn = grns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                          Text(
                            grn.grnId,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            grn.poReference,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusChip(grn.status),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMobileInfoRow('Vendor', grn.vendor),
                    _buildMobileInfoRow('Date', grn.dateReceived),
                    _buildMobileInfoRow('Received By', grn.receivedBy),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                      color: Colors.blue,
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      color: Colors.green,
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileInfoRow(String label, String value) {
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class GRNFilterSheet extends StatefulWidget {
  const GRNFilterSheet({
    super.key,
    required this.initialFilter,
    required this.statuses,
    required this.vendors,
    required this.poReferences,
  });

  final GRNFilter initialFilter;
  final List<String> statuses;
  final List<String> vendors;
  final List<String> poReferences;

  @override
  State<GRNFilterSheet> createState() => _GRNFilterSheetState();
}

class _GRNFilterSheetState extends State<GRNFilterSheet> {
  String? _status;
  String? _vendor;
  String? _poReference;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialFilter.status;
    _vendor = widget.initialFilter.vendor;
    _poReference = widget.initialFilter.poReference;
    _searchController = TextEditingController(
      text: widget.initialFilter.searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  GRNFilter getFilter() {
    return GRNFilter(
      status: _status,
      vendor: _vendor,
      poReference: _poReference,
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
        if (widget.vendors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Vendor',
            value: _vendor,
            items: widget.vendors,
            onChanged: (value) => setState(() => _vendor = value),
          ),
        ],
        if (widget.poReferences.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'PO Reference',
            value: _poReference,
            items: widget.poReferences,
            onChanged: (value) => setState(() => _poReference = value),
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

