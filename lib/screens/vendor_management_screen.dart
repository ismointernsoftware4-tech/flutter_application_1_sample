import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/vendor_card.dart';
import 'add_vendor_screen.dart';

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

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildActionBar(),
            const SizedBox(height: 24),
            _buildVendorGrid(vendors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Procurement',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                width: 280,
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
          ),
          const SizedBox(height: 24),
          Row(
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

  Widget _buildFilters() {
    return Row(
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

  Widget _buildActionBar() {
    return Row(
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
            final provider =
                Provider.of<DashboardProvider>(context, listen: false);
            provider.resetVendorFormFields();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddVendorScreen(),
              ),
            );
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

  Widget _buildVendorGrid(List<Vendor> vendors) {
    if (vendors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
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

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: vendors.map((vendor) {
        return SizedBox(
          width: 320,
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


