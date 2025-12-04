import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/column_config.dart';
import '../../../shared/widgets/filter_export_buttons.dart';
import '../../../shared/widgets/enhanced_filter_sheet.dart';
import '../../../shared/widgets/schema_table.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/utils/animated_routes.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../models/item_master_models.dart';
import '../providers/item_master_provider.dart';
import '../providers/item_column_visibility_provider.dart';
import 'add_item_screen.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({super.key});

  @override
  State<ItemMasterScreen> createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
  bool _isLoading = true;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = Provider.of<ItemMasterProvider>(
        context,
        listen: false,
      ).itemSearchQuery;
      _searchController.text = query;
    });
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final provider = Provider.of<ItemMasterProvider>(context, listen: false);
      await provider.loadItems();
    } catch (e) {
      // Handle error - show snackbar to inform user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading items: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Always reset loading state to unblock UI
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openFilterSheet() async {
    final provider = context.read<ItemMasterProvider>();
    final filterKey = GlobalKey<_ItemMasterFilterSheetState>();
    final filterSheet = ItemMasterFilterSheet(
      key: filterKey,
      initialFilter: provider.itemMasterFilter,
      statuses: provider.itemMasterStatuses,
      categories: provider.itemMasterCategories,
      types: provider.itemMasterTypes,
    );
    
    final result = await EnhancedFilterSheet.show<ItemMasterFilter>(
      context: context,
      title: 'Filter Items',
      child: filterSheet,
      onApply: () => filterKey.currentState?.getFilter() ?? const ItemMasterFilter(),
      onClear: () => const ItemMasterFilter(),
    );
    
    if (result == null) return;
    provider.updateItemMasterFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemMasterProvider>(context);
    final items = provider.filteredItemMasterList;
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator()
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(0.8, 0.8),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Top Header with Search and Add New Item button
            Container(
              // Remove extra right padding so the content aligns with the
              // dashboard body; keep left/top/bottom spacing.
              padding: EdgeInsets.only(
                left: screenPadding.horizontal / 2,
                right: 0,
                top: screenPadding.horizontal / 2,
                bottom: screenPadding.horizontal / 2,
              ),
              color: Colors.white,
              child: Column(
                children: [
                  // Search bar and Add button row
                  isMobile
                      ? Column(
                          children: [
                            Row(
                              children: [
                                // Menu icon - always visible
                                IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () {
                                    if (isMobile || isTablet) {
                                      Scaffold.of(context).openDrawer();
                                    } else {
                                      dashboardProvider.toggleSidebar();
                                    }
                                  },
                                  tooltip: 'Toggle menu',
                                ),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ShadInput(
                                      controller: _searchController,
                                      onChanged: context
                                          .read<ItemMasterProvider>()
                                          .updateItemSearchQuery,
                                      placeholder: const Text(
                                        'Search code, name, manufacturer...',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                onPressed: () {
                                  final dashboardProvider =
                                      Provider.of<DashboardProvider>(
                                    context,
                                    listen: false,
                                  );

                                  dashboardProvider
                                      .contentNavigatorKey.currentState
                                      ?.push(
                                    AnimatedRoutes.slideRight(
                                      const AddItemScreen(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, size: 18),
                                    SizedBox(width: 8),
                                    Text('Add New Item'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final isSmallScreen = screenWidth < 700;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Menu icon - always visible
                                IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () {
                                    if (isMobile || isTablet) {
                                      Scaffold.of(context).openDrawer();
                                    } else {
                                      dashboardProvider.toggleSidebar();
                                    }
                                  },
                                  tooltip: 'Toggle menu',
                                ),
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: isSmallScreen
                                          ? double.infinity
                                          : 400,
                                    ),
                                    height: 40,
                                    margin: EdgeInsets.only(
                                      right: isMobile ? 0 : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ShadInput(
                                      controller: _searchController,
                                      onChanged: context
                                          .read<ItemMasterProvider>()
                                          .updateItemSearchQuery,
                                      placeholder: const Text(
                                        'Search code, name, manufacturer...',
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isSmallScreen)
                                  ShadButton(
                                    onPressed: () {
                                      final dashboardProvider =
                                          Provider.of<DashboardProvider>(
                                        context,
                                        listen: false,
                                      );

                                      dashboardProvider
                                          .contentNavigatorKey.currentState
                                          ?.push(
                                        AnimatedRoutes.slideRight(
                                          const AddItemScreen(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          isMobile ? 'Add' : 'Add New Item',
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ],
              ),
            ),
            // Main Content Card
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Header with Title and Buttons
                    Padding(
                      padding: EdgeInsets.only(
                        left: isMobile ? 12 : 20,
                        top: isMobile ? 12 : 20,
                        bottom: isMobile ? 12 : 20,
                        right: 0, // Remove right padding - let table extend to edge
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Item Master',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getTitleFontSize(
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              FilterExportButtonRow(
                                onFilterPressed: _openFilterSheet,
                                onExportPressed: () => context
                                    .read<ItemMasterProvider>()
                                    .exportItemMasterCsv(),
                                filterLabel: 'Filter',
                                exportLabel: 'Export',
                                isMobile: isMobile,
                                spacing: 8,
                              ),
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
                                          child: const _InlineColumnPicker(),
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
                        ],
                      ),
                    ),
                    
                    // Data Table / Mobile Cards - This Expanded should fill remaining space
                    Expanded(
                      child: isMobile
                          // MOBILE (Android/iOS or narrow web): show cards
                          ? _buildMobileCardView(items)
                          // TABLET / DESKTOP: show full table
                          : Consumer<ItemColumnVisibilityProvider>(
                              builder: (context, columnProvider, _) {
                                final visibleColumns = columnProvider.visibleColumns;
                                return ClipRect(
                                  clipBehavior: Clip.hardEdge,
                                  child: SchemaTable<Map<String, dynamic>>(
                                    items: items,
                                    columns: visibleColumns,
                                    columnWidth: isTablet ? 160 : 200,
                                    emptyLabel:
                                        'No items found for the current filters.',
                                    valueBuilder: (item, column) =>
                                        _resolveColumnValue(item, column.key),
                                    cellBuilder: (item, column) =>
                                        _buildCustomCell(item, column),
                                    actionsBuilder: (item) =>
                                        _buildTableActions(context, item),
                                  )
                                      .animate()
                                      .fadeIn(duration: 500.ms)
                                      .slideY(begin: 0.05, end: 0, duration: 500.ms),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ], // Close Column children
        ), // Close Column
      ], // Close Stack children
    ); // Close Stack
  }

  String _resolveColumnValue(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return '';
    return value.toString();
  }

  /// Custom web-table cell rendering to match the design screenshot.
  Widget? _buildCustomCell(Map<String, dynamic> item, ColumnConfig column) {
    final key = column.key;

    // Item Code - blue text
    if (key == 'itemCode') {
      final value = _resolveColumnValue(item, key);
      return Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF2563EB), // blue
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    // Item Name - bold with manufacturer below
    if (key == 'itemName') {
      final itemName = (item['itemName'] ?? '').toString();
      final manufacturer = (item['manufacturer'] ?? '').toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            itemName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (manufacturer.isNotEmpty)
            Text(
              manufacturer,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      );
    }

    // Storage - muted pill
    if (key == 'storage' || key == 'storageLocation') {
      final value = _resolveColumnValue(item, key);
      if (value.isEmpty) return null;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Status - colored pill
    if (key == 'status') {
      final value = _resolveColumnValue(item, key);
      if (value.isEmpty) return null;

      Color bg;
      Color fg;

      final lower = value.toLowerCase();
      if (lower == 'active') {
        bg = const Color(0xFFD1FAE5); // green tint
        fg = const Color(0xFF065F46);
      } else if (lower.contains('low')) {
        bg = const Color(0xFFFEF3C7); // amber tint
        fg = const Color(0xFF92400E);
      } else {
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF111827);
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: fg,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Fallback: let SchemaTable render normal text
    return null;
  }

  List<Widget> _buildTableActions(BuildContext context, Map<String, dynamic> item) {
    final itemCode = (item['itemCode'] ?? '').toString();
    return [
      IconButton(
        icon: const Icon(Icons.edit, size: 18),
        color: Colors.blue,
        tooltip: 'Edit $itemCode',
        onPressed: () => _editItem(context, item),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.delete, size: 18),
        color: Colors.red,
        tooltip: 'Delete $itemCode',
        onPressed: () => _deleteItem(context, item),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ];
  }

  void _editItem(BuildContext context, Map<String, dynamic> item) {
    if (item['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to edit this item because it does not have a valid identifier.'),
        ),
      );
      return;
    }
    // TODO: Update EditItemScreen to accept Map<String, dynamic>
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality will be updated to work with dynamic columns.'),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, Map<String, dynamic> item) async {
    if (item['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete this item because it does not have a valid identifier.'),
        ),
      );
      return;
    }
    final itemName = (item['itemName'] ?? '').toString();
    final itemCode = (item['itemCode'] ?? '').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "$itemName" ($itemCode)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && item['id'] != null) {
      try {
        await context.read<ItemMasterProvider>().deleteItem(item['id']!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$itemName" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting item: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Mobile card view
  Widget _buildMobileCardView(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemCode = (item['itemCode'] ?? '').toString();
        final itemName = (item['itemName'] ?? '').toString();
        final manufacturer = (item['manufacturer'] ?? '').toString();
        final status = (item['status'] ?? '').toString();
        final type = (item['type'] ?? '').toString();
        final category = (item['category'] ?? '').toString();
        final unit = (item['unit'] ?? '').toString();
        final stock = (item['stock'] ?? 0).toString();
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
                            itemCode,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            manufacturer,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'Active'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMobileInfoRow('Type', type),
                    _buildMobileInfoRow('Category', category),
                    _buildMobileInfoRow('Unit', unit),
                    _buildMobileInfoRow('Stock', stock),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: Colors.blue,
                      onPressed: () => _editItem(context, item),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      onPressed: () => _deleteItem(context, item),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
          .animate()
          .fadeIn(duration: 300.ms, delay: (index * 50).ms)
          .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: (index * 50).ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms, delay: (index * 50).ms);
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InlineColumnPicker extends StatelessWidget {
  const _InlineColumnPicker();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ItemColumnVisibilityProvider>(
          builder: (context, provider, _) {
            // No loading check needed - provider initializes with default columns
            final columns = provider.columns;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Manage Columns',
                        style: TextStyle(
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

class ItemMasterFilterSheet extends StatefulWidget {
  const ItemMasterFilterSheet({
    super.key,
    required this.initialFilter,
    required this.statuses,
    required this.categories,
    required this.types,
  });

  final ItemMasterFilter initialFilter;
  final List<String> statuses;
  final List<String> categories;
  final List<String> types;

  @override
  State<ItemMasterFilterSheet> createState() => _ItemMasterFilterSheetState();
}

class _ItemMasterFilterSheetState extends State<ItemMasterFilterSheet> {
  String? _status;
  String? _category;
  String? _type;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialFilter.status;
    _category = widget.initialFilter.category;
    _type = widget.initialFilter.type;
    _nameController = TextEditingController(
      text: widget.initialFilter.nameQuery ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ItemMasterFilter getFilter() {
    return ItemMasterFilter(
      status: _status,
      category: _category,
      type: _type,
      nameQuery: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadInput(
          controller: _nameController,
          placeholder: const Text('Item Name Contains'),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Status',
          value: _status,
          items: widget.statuses,
          onChanged: (value) => setState(() => _status = value),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Category',
          value: _category,
          items: widget.categories,
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Type',
          value: _type,
          items: widget.types,
          onChanged: (value) => setState(() => _type = value),
        ),
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
