import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';

class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                provider.resetVendorFormFields();
                                Navigator.pop(context);
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
                                          content:
                                              Text('Vendor saved successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e
                                                .toString()
                                                .replaceFirst('Exception: ', ''),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
                context.read<DashboardProvider>().resetVendorFormFields();
                Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to List'),
          ),
          const Spacer(),
          SizedBox(
            width: 240,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
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
                          fontSize: 13,
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
              IconButton(
                onPressed: () => _openSectionEditor(section, provider),
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit Section',
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 20,
                runSpacing: 16,
                children: section.fields
                    .map((field) => _buildField(field, provider))
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
    final label =
        '${field.label}${field.required ? ' *' : ''}';
    switch (field.type) {
      case VendorFieldType.dropdown:
        var value = provider.vendorFieldValue(field.id);
        if (!field.options.contains(value) && field.options.isNotEmpty) {
          value = field.options.first;
          provider.updateVendorField(field.id, value);
        }
        return SizedBox(
          width: 320,
          child: DropdownButtonFormField<String>(
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
          ),
        );
      case VendorFieldType.textarea:
        return SizedBox(
          width: 320,
          child: TextFormField(
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
          ),
        );
      case VendorFieldType.text:
        if (field.id == 'compliance_docs') {
          return SizedBox(
            width: 320,
            child: TextFormField(
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
            ),
          );
        }

        return SizedBox(
          width: 320,
          child: TextFormField(
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
          ),
        );
    }
  }

  Future<void> _openSectionEditor(
    VendorFormSection section,
    DashboardProvider provider,
  ) async {
    final result = await showDialog<_SectionEditResult>(
      context: context,
      builder: (context) => _SectionEditorDialog(
        section: section,
        canDelete: provider.vendorSections.length > 1,
      ),
    );
    if (result == null) return;
    if (result.delete) {
      provider.deleteVendorSection(section.id);
    } else {
      provider.updateVendorSection(
        section.id,
        title: result.title,
        fields: result.fields,
      );
    }
  }
}

class _SectionEditResult {
  final bool delete;
  final String title;
  final List<VendorFormField> fields;
  _SectionEditResult({
    required this.delete,
    required this.title,
    required this.fields,
  });
}

class _SectionEditorDialog extends StatefulWidget {
  final VendorFormSection section;
  final bool canDelete;
  const _SectionEditorDialog({
    required this.section,
    required this.canDelete,
  });

  @override
  State<_SectionEditorDialog> createState() => _SectionEditorDialogState();
}

class _SectionEditorDialogState extends State<_SectionEditorDialog> {
  late TextEditingController _titleController;
  final List<_EditableField> _fields = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
    for (final field in widget.section.fields) {
      _fields.add(
        _EditableField(
          id: field.id,
          controller: TextEditingController(text: field.label),
          required: field.required,
          type: field.type,
          options: List<String>.from(field.options),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final field in _fields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Section'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Section Title',
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: _fields
                    .map(
                      (field) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: field.controller,
                                decoration: InputDecoration(
                                  labelText: 'Field label',
                                  helperText: field.type ==
                                          VendorFieldType.dropdown
                                      ? 'Dropdown options fixed'
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                const Text('Required'),
                                Switch(
                                  value: field.required,
                                  onChanged: (value) {
                                    setState(() {
                                      field.required = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  field.controller.dispose();
                                  _fields.remove(field);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      final newId =
                          'field_${DateTime.now().millisecondsSinceEpoch}';
                      _fields.add(
                        _EditableField(
                          id: newId,
                          controller: TextEditingController(),
                          required: false,
                          type: VendorFieldType.text,
                          options: const [],
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.canDelete)
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                _SectionEditResult(
                  delete: true,
                  title: _titleController.text.trim(),
                  fields: widget.section.fields,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete Section'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedFields = _fields
                .map(
                  (field) => VendorFormField(
                    id: field.id,
                    label: field.controller.text.trim().isEmpty
                        ? 'Untitled Field'
                        : field.controller.text.trim(),
                    type: field.type,
                    required: field.required,
                    options: field.options,
                  ),
                )
                .toList();
            Navigator.pop(
              context,
              _SectionEditResult(
                delete: false,
                title: _titleController.text.trim().isEmpty
                    ? widget.section.title
                    : _titleController.text.trim(),
                fields: updatedFields,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditableField {
  final String id;
  final TextEditingController controller;
  bool required;
  VendorFieldType type;
  List<String> options;
  _EditableField({
    required this.id,
    required this.controller,
    required this.required,
    required this.type,
    required this.options,
  });
}

