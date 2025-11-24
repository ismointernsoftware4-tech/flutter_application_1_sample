import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';

class AddVendorSidebar extends StatefulWidget {
  const AddVendorSidebar({super.key});

  @override
  State<AddVendorSidebar> createState() => _AddVendorSidebarState();
}

class _AddVendorSidebarState extends State<AddVendorSidebar> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(DashboardProvider provider) {
    final fields = provider.vendorSections
        .expand((section) => section.fields)
        .where((field) => field.type != VendorFieldType.dropdown)
        .toList();
    final fieldIds = fields.map((f) => f.id).toSet();

    for (final field in fields) {
      final controller = _controllers.putIfAbsent(
        field.id,
        () => TextEditingController(
          text: provider.vendorFieldValue(field.id),
        ),
      );
      final currentValue = provider.vendorFieldValue(field.id);
      if (controller.text != currentValue) {
        controller.text = currentValue;
      }
    }

    final toRemove =
        _controllers.keys.where((id) => !fieldIds.contains(id)).toList();
    for (final id in toRemove) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final sections = provider.vendorSections;
    final expanded = provider.vendorSectionsExpanded;

    _syncControllers(provider);

    return Container(
      width: 700,
      color: Colors.white,
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendor Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final section in sections) ...[
                      _buildSection(
                        context,
                        provider: provider,
                        section: section,
                        expanded: expanded[section.id] ?? true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            provider.closeAddVendorSidebar();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                await provider.addVendorFromFields();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vendor saved successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  provider.closeAddVendorSidebar();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceFirst('Exception: ', ''),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save Vendor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Add New Vendor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<DashboardProvider>().closeAddVendorSidebar();
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required DashboardProvider provider,
    required VendorFormSection section,
    required bool expanded,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => provider.toggleVendorSection(section.id),
                  child: Row(
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: section.fields
                    .map((field) => SizedBox(
                          width: 320,
                          child: _buildField(field, provider),
                        ))
                    .toList(),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    VendorFormField field,
    DashboardProvider provider,
  ) {
    final label = '${field.label}${field.required ? ' *' : ''}';
    switch (field.type) {
      case VendorFieldType.dropdown:
        var value = provider.vendorFieldValue(field.id);
        if (!field.options.contains(value) && field.options.isNotEmpty) {
          value = field.options.first;
          provider.updateVendorField(field.id, value);
        }
        return DropdownButtonFormField<String>(
          value: field.options.contains(value) ? value : null,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: field.required
              ? (val) => val == null || val.isEmpty ? 'Required' : null
              : null,
          items: field.options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              provider.updateVendorField(field.id, value);
            }
          },
        );
      case VendorFieldType.textarea:
        return TextFormField(
          controller: _controllers[field.id],
          maxLines: 3,
          validator: field.required
              ? (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null
              : null,
          onChanged: (value) => provider.updateVendorField(field.id, value),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      case VendorFieldType.text:
        if (field.id == 'compliance_docs') {
          return TextFormField(
            controller: _controllers[field.id],
            readOnly: true,
            validator: field.required
                ? (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null
                : null,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              helperText: 'Upload Tax Certs, Licenses, etc.',
              suffixIcon: IconButton(
                icon: const Icon(Icons.upload_file),
                onPressed: () {
                  _controllers[field.id]?.text = 'Attachment Added';
                  provider.updateVendorField(field.id, 'Attachment Added');
                  setState(() {});
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          );
        }

        return TextFormField(
          controller: _controllers[field.id],
          validator: field.required
              ? (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null
              : null,
          onChanged: (value) => provider.updateVendorField(field.id, value),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
    }
  }
}

