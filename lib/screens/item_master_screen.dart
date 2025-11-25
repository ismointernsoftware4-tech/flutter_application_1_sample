import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'form_builder_screen.dart';
import '../utils/responsive_helper.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({super.key});

  @override
  State<ItemMasterScreen> createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    await provider.loadItems();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final items = provider.itemMasterList;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Column(
          children: [
            // Top Header with Search and Add New Item button
            Container(
              padding: EdgeInsets.all(screenPadding.horizontal / 2),
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
                                      Provider.of<DashboardProvider>(
                                        context,
                                        listen: false,
                                      ).toggleSidebar();
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
                                    child: const TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const FormBuilderScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add New Item'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                      Provider.of<DashboardProvider>(
                                        context,
                                        listen: false,
                                      ).toggleSidebar();
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
                                    child: const TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isSmallScreen)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const FormBuilderScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: Text(
                                      isMobile ? 'Add' : 'Add New Item',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 16 : 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
                margin: screenPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header with Title and Buttons
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          isMobile
                              ? Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Filter functionality
                                        },
                                        icon: const Icon(
                                          Icons.filter_alt,
                                          size: 18,
                                        ),
                                        label: const Text('Filter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black87,
                                          elevation: 0,
                                          side: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Export functionality
                                        },
                                        icon: const Icon(
                                          Icons.download,
                                          size: 18,
                                        ),
                                        label: const Text('Export'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black87,
                                          elevation: 0,
                                          side: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Filter functionality
                                      },
                                      icon: const Icon(
                                        Icons.filter_alt,
                                        size: 18,
                                      ),
                                      label: const Text('Filter'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black87,
                                        elevation: 0,
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Export functionality
                                      },
                                      icon: const Icon(
                                        Icons.download,
                                        size: 18,
                                      ),
                                      label: const Text('Export'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black87,
                                        elevation: 0,
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    // Data Table or Card View based on screen size
                    Expanded(
                      child: isMobile
                          ? _buildMobileCardView(items)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.grey[50],
                                  ),
                                  columnSpacing: isTablet ? 20 : 40,
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        'Item Code',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Item Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (!isTablet) ...[
                                      DataColumn(
                                        label: Text(
                                          'Type',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Category',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                    DataColumn(
                                      label: Text(
                                        'Unit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Stock',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Status',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: items.map((item) {
                                    final index = items.indexOf(item);
                                    return DataRow(
                                      color: MaterialStateProperty.all(
                                        index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey[50],
                                      ),
                                      cells: [
                                        // Item Code
                                        DataCell(
                                          Text(
                                            item.itemCode,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        // Item Name with Manufacturer
                                        DataCell(
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.manufacturer,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Type (hidden on tablet)
                                        if (!isTablet) ...[
                                          DataCell(
                                            Text(
                                              item.type,
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: isMobile ? 12 : 14,
                                              ),
                                            ),
                                          ),
                                          // Category
                                          DataCell(
                                            Text(
                                              item.category,
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: isMobile ? 12 : 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                        // Unit
                                        DataCell(
                                          Text(
                                            item.unit,
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: isMobile ? 12 : 14,
                                            ),
                                          ),
                                        ),
                                        // Stock
                                        DataCell(
                                          Text(
                                            item.stock.toString(),
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: isMobile ? 12 : 14,
                                            ),
                                          ),
                                        ),
                                        // Status
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item.status == 'Active'
                                                  ? Colors.green
                                                  : Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Actions
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                ),
                                                color: Colors.blue,
                                                onPressed: () {
                                                  // Edit functionality
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                ),
                                                color: Colors.red,
                                                onPressed: () {
                                                  // Delete functionality
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
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

  // Mobile card view
  Widget _buildMobileCardView(List items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
                            item.itemCode,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.manufacturer,
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
                        color: item.status == 'Active'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
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
                    _buildMobileInfoRow('Type', item.type),
                    _buildMobileInfoRow('Category', item.category),
                    _buildMobileInfoRow('Unit', item.unit),
                    _buildMobileInfoRow('Stock', item.stock.toString()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: Colors.blue,
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
