import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/add_location_provider.dart';
import '../providers/dashboard_provider.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.read<DashboardProvider>();
    final existingParents =
        dashboard.storageLocations.map((loc) => loc.name).toList();

    return ChangeNotifierProvider(
      create: (_) => AddLocationProvider(existingParents),
      child: const _AddLocationView(),
    );
  }
}

class _AddLocationView extends StatelessWidget {
  const _AddLocationView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddLocationProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _formCard(context, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add New Location',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(BuildContext context, AddLocationProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 24,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                    child: _textField(
                      controller: provider.nameController,
                      label: 'Location Name',
                      hint: 'e.g., Warehouse B',
                      onChanged: (_) => provider.onFieldChanged(),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                    child: _dropdown(
                      label: 'Type',
                      value: provider.selectedType,
                      items: provider.types,
                      onChanged: provider.setType,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                    child: _dropdown(
                      label: 'Parent Location',
                      value: provider.selectedParent,
                      items: provider.parentLocations,
                      onChanged: provider.setParent,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                    child: _dropdown(
                      label: 'Status',
                      value: provider.selectedStatus,
                      items: provider.statuses,
                      onChanged: provider.setStatus,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                    child: _textField(
                      controller: provider.managerController,
                      label: 'Manager / Person in Charge',
                      hint: 'e.g., John Doe',
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                    child: _textField(
                      controller: provider.capacityController,
                      label: 'Max Capacity (Units)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _textField(
                      controller: provider.descriptionController,
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
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: provider.canSubmit
                    ? () => _submit(context, provider)
                    : null,
                icon: const Icon(Icons.save),
                label: const Text('Create Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
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
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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

  Future<void> _submit(
    BuildContext context,
    AddLocationProvider provider,
  ) async {
    final dashboard = context.read<DashboardProvider>();
    dashboard.addStorageLocation(
      name: provider.nameController.text.trim(),
      type: provider.selectedType,
      parentLocation: provider.selectedParent == 'None (Top Level)'
          ? '-'
          : provider.selectedParent,
      capacity: provider.parsedCapacity(),
      status: provider.selectedStatus,
      manager: provider.managerController.text.trim(),
      description: provider.descriptionController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location created successfully')),
    );
    Navigator.of(context).pop();
  }
}

