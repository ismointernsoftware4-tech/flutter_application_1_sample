import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/form_template_info.dart';
import '../providers/form_builder_workspace_provider.dart';
import '../widgets/field_properties_editor.dart';
import '../widgets/form_canvas.dart';
import '../widgets/toolbox_panel.dart';

class FormBuilderWorkspaceScreen extends StatefulWidget {
  const FormBuilderWorkspaceScreen({super.key, this.initialFormId, this.clinicId});

  final String? initialFormId;
  final String? clinicId;

  @override
  State<FormBuilderWorkspaceScreen> createState() =>
      _FormBuilderWorkspaceScreenState();
}

class _FormBuilderWorkspaceScreenState
    extends State<FormBuilderWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FormBuilderWorkspaceProvider>();
      provider.setClinicId(widget.clinicId);
      final defaultFormId =
          widget.initialFormId ??
          (kFormTemplates.isNotEmpty ? kFormTemplates.first.id : null);
      if (defaultFormId != null) {
        provider.loadForm(defaultFormId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FormBuilderWorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinicId != widget.clinicId) {
      final provider = context.read<FormBuilderWorkspaceProvider>();
      // Set the new clinicId (this will clear cached data)
      provider.setClinicId(widget.clinicId);
      // Reload the form for the new clinic
      final formIdToLoad = provider.selectedFormId ?? 
                          widget.initialFormId ??
                          (kFormTemplates.isNotEmpty ? kFormTemplates.first.id : null);
      if (formIdToLoad != null) {
        provider.loadForm(formIdToLoad);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<FormBuilderWorkspaceProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _FormBuilderHeader(
              workspaceProvider: workspaceProvider,
              selectedFormId:
                  workspaceProvider.selectedFormId ??
                  widget.initialFormId,
              onFormChanged: (formId) {
                workspaceProvider.loadForm(formId);
              },
              onAddSection: workspaceProvider.selectedFormId == null
                  ? null
                  : workspaceProvider.addSection,
              onSave: workspaceProvider.isSaving
                  ? null
                  : () => workspaceProvider.save(),
              isSaving: workspaceProvider.isSaving,
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 280,
                    child: ToolboxPanel(
                      onAddField: workspaceProvider.addFieldToSection,
                      hasSections: workspaceProvider.sections.isNotEmpty,
                      activeSectionTitle:
                          workspaceProvider.selectedSection?.title,
                    ),
                  ),
                  Expanded(
                    child: workspaceProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FormCanvas(
                            sections: workspaceProvider.sections,
                            selectedSectionId:
                                workspaceProvider.selectedSection?.id,
                            selectedFieldId:
                                workspaceProvider.selectedField?.id,
                            onReorderSections:
                                workspaceProvider.reorderSections,
                            onMoveField: workspaceProvider.moveField,
                            onSelectSection: workspaceProvider.selectSection,
                            onSelectField: workspaceProvider.selectField,
                            onAddField: (type, sectionId) {
                              workspaceProvider.addFieldToSection(
                                type,
                                sectionId: sectionId,
                              );
                            },
                          ),
                  ),
                  SizedBox(
                    width: 340,
                    child: FieldPropertiesEditor(
                      section: workspaceProvider.selectedSection,
                      field: workspaceProvider.selectedField,
                      onSectionUpdate: workspaceProvider.updateSection,
                      onDeleteSection: workspaceProvider.removeSection,
                      onFieldUpdate: workspaceProvider.updateField,
                      onDeleteField: workspaceProvider.removeField,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormBuilderHeader extends StatefulWidget {
  const _FormBuilderHeader({
    required this.workspaceProvider,
    required this.selectedFormId,
    required this.onFormChanged,
    required this.onAddSection,
    required this.onSave,
    required this.isSaving,
  });

  final FormBuilderWorkspaceProvider workspaceProvider;
  final String? selectedFormId;
  final void Function(String formId) onFormChanged;
  final VoidCallback? onAddSection;
  final VoidCallback? onSave;
  final bool isSaving;

  @override
  State<_FormBuilderHeader> createState() => _FormBuilderHeaderState();
}

class _FormBuilderHeaderState extends State<_FormBuilderHeader> {
  List<Map<String, String>> _availableForms = [];
  bool _isLoadingForms = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableForms();
  }

  Future<void> _loadAvailableForms() async {
    setState(() => _isLoadingForms = true);
    try {
      final forms = await widget.workspaceProvider.getAvailableForms();
      setState(() {
        _availableForms = forms;
      });
      
      // If no forms found and we have a selected form ID, try to load it anyway
      if (_availableForms.isEmpty && widget.selectedFormId != null) {
        // Form might exist but not have a name field, add it to the list
        _availableForms.add({
          'id': widget.selectedFormId!,
          'name': widget.selectedFormId!.replaceAll('_', ' ').split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1);
          }).join(' '),
        });
      }
    } catch (e) {
      debugPrint('Error loading forms: $e');
    } finally {
      setState(() => _isLoadingForms = false);
    }
  }

  Future<void> _showCreateFormDialog() async {
    final formNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Form'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: formNameController,
                decoration: const InputDecoration(
                  labelText: 'Form Name',
                  hintText: 'e.g., Inventory Form, Sales Form',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Form name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Form name must be at least 3 characters';
                  }
                  return null;
                },
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(formNameController.text.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final formId = await widget.workspaceProvider.createNewForm(result);
        await _loadAvailableForms(); // Refresh the list
        widget.onFormChanged(formId);
        
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text('Form "$result" created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text('Error creating form: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Text(
            'Dynamic Form Builder',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _availableForms.any((form) => form['id'] == widget.selectedFormId)
                        ? widget.selectedFormId
                        : _availableForms.isNotEmpty
                        ? _availableForms.first['id']
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Select Form',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    hint: _availableForms.isEmpty
                        ? const Text('No forms available')
                        : null,
                    items: _availableForms.isEmpty
                        ? null
                        : _availableForms
                            .map(
                              (form) => DropdownMenuItem(
                                value: form['id'],
                                child: Text(form['name'] ?? form['id']!),
                              ),
                            )
                            .toList(),
                    onChanged: _availableForms.isEmpty
                        ? null
                        : (value) {
                            if (value != null) widget.onFormChanged(value);
                          },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoadingForms ? null : _loadAvailableForms,
                  icon: _isLoadingForms
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Refresh Forms',
                ),
                IconButton(
                  onPressed: _showCreateFormDialog,
                  icon: const Icon(Icons.add),
                  tooltip: 'Create New Form',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: widget.onAddSection,
            icon: const Icon(Icons.view_column_outlined),
            label: const Text('Add Section'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: widget.onSave,
            icon: widget.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(widget.isSaving ? 'Saving...' : 'Save Form'),
          ),
        ],
      ),
    );
  }
}

