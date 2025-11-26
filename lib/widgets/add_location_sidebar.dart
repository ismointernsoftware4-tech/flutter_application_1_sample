import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/add_location_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';

class AddLocationSidebar extends StatefulWidget {
  const AddLocationSidebar({super.key});

  @override
  State<AddLocationSidebar> createState() => _AddLocationSidebarState();
}

class _AddLocationSidebarState extends State<AddLocationSidebar> {
  late AddLocationProvider _locationProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final dashboard = context.read<DashboardProvider>();
    final existingParents =
        dashboard.storageLocations.map((loc) => loc.name).toList();
    _locationProvider = AddLocationProvider(existingParents);
  }

  @override
  void dispose() {
    _locationProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _pageHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(context),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: _formCard(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Text(
            'Add New Location',
            style: TextStyle(
              fontSize: ResponsiveHelper.getTitleFontSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<DashboardProvider>().closeAddLocationSidebar(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            'Back',
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

  Widget _formCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Storage Location',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              final columnWidth =
                  isWide ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 32,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: columnWidth,
                    child: _textField(
                      controller: _locationProvider.nameController,
                      label: 'Location Name',
                      hint: 'e.g., Warehouse B',
                      onChanged: (_) => _locationProvider.onFieldChanged(),
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _dropdown(
                      label: 'Type',
                      value: _locationProvider.selectedType,
                      items: _locationProvider.types,
                      onChanged: _locationProvider.setType,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _dropdown(
                      label: 'Parent Location',
                      value: _locationProvider.selectedParent,
                      items: _locationProvider.parentLocations,
                      onChanged: _locationProvider.setParent,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _dropdown(
                      label: 'Status',
                      value: _locationProvider.selectedStatus,
                      items: _locationProvider.statuses,
                      onChanged: _locationProvider.setStatus,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _textField(
                      controller: _locationProvider.managerController,
                      label: 'Manager / Person in Charge',
                      hint: 'e.g., John Doe',
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _textField(
                      controller: _locationProvider.capacityController,
                      label: 'Max Capacity (Units)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _textField(
                      controller: _locationProvider.descriptionController,
                      label: 'Description / Notes',
                      hint: 'Additional details about this location...',
                      maxLines: 3,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  context.read<DashboardProvider>().closeAddLocationSidebar();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _locationProvider.canSubmit
                    ? () => _submit(context)
                    : null,
                icon: const Icon(Icons.save),
                label: const Text('Create Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final dashboard = context.read<DashboardProvider>();
      await dashboard.addStorageLocation(
        name: _locationProvider.nameController.text.trim(),
        type: _locationProvider.selectedType,
        parentLocation: _locationProvider.selectedParent == 'None (Top Level)'
            ? '-'
            : _locationProvider.selectedParent,
        capacity: _locationProvider.parsedCapacity(),
        status: _locationProvider.selectedStatus,
        manager: _locationProvider.managerController.text.trim(),
        description: _locationProvider.descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location created successfully')),
        );
        context.read<DashboardProvider>().closeAddLocationSidebar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

