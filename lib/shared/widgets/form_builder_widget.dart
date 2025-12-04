import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/dynamic_form_models.dart';
import '../providers/form_builder_provider.dart';
import '../utils/responsive_helper.dart';

class FormBuilderWidget extends StatelessWidget {
  const FormBuilderWidget({
    super.key,
    required this.provider,
    this.title = 'Form Template',
    this.description = 'Arrange sections and fields that will appear on the form.',
    this.onSave,
    this.onSaveAndView,
  });

  final FormBuilderProvider provider;
  final String title;
  final String description;
  final Future<void> Function()? onSave;
  final Future<void> Function()? onSaveAndView;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return ShadCard(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 28,
          vertical: isMobile ? 20 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleBlock(title: title, description: description),
                  const SizedBox(height: 12),
                  const _InfoTag(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: provider.addSection,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 8),
                          Text('Add Section'),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _TitleBlock(title: title, description: description),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _InfoTag(),
                      const SizedBox(height: 12),
                      ShadButton.outline(
                        onPressed: provider.addSection,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Add Section'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 24),
            ...provider.sections
                .map(
                  (section) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        provider: provider,
                        section: section,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final columnWidth =
                              width > 700 ? (width - 24) / 2 : width;
                          return Wrap(
                            spacing: 24,
                            runSpacing: 16,
                            children: section.fields
                                .map(
                                  (field) => SizedBox(
                                    width: columnWidth,
                                    child: _FieldPreview(
                                      provider: provider,
                                      sectionId: section.id,
                                      field: field,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _AddFieldControls(
                        provider: provider,
                        sectionId: section.id,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                )
                .toList(),
            const SizedBox(height: 24),
            if (isMobile)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              try {
                                await provider.saveDefinition();
                                if (!context.mounted) return;
                                if (onSave != null) {
                                  await onSave!();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Form definition saved.'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            provider.isSaving ? 'Saving...' : 'Save Form',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              try {
                                await provider.saveDefinition();
                                if (!context.mounted) return;
                                if (onSaveAndView != null) {
                                  await onSaveAndView!();
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            provider.isSaving ? 'Please wait...' : 'Save & Open Form',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              try {
                                await provider.saveDefinition();
                                if (!context.mounted) return;
                                if (onSave != null) {
                                  await onSave!();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Form definition saved.'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            provider.isSaving ? 'Saving...' : 'Save Form',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadButton(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              try {
                                await provider.saveDefinition();
                                if (!context.mounted) return;
                                if (onSaveAndView != null) {
                                  await onSaveAndView!();
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            provider.isSaving ? 'Please wait...' : 'Save & Open Form',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 18),
          SizedBox(width: 6),
          Text(
            'Changes apply to all users',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatefulWidget {
  const _SectionHeader({required this.provider, required this.section});

  final FormBuilderProvider provider;
  final DynamicFormSection section;

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.section.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SectionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.id != widget.section.id ||
        oldWidget.section.title != widget.section.title) {
      _controller.text = widget.section.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: ShadInput(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
              ),
              onSubmitted: (_) => _save(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 18),
            tooltip: 'Save section name',
            onPressed: _save,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Cancel',
            onPressed: () {
              _controller.text = widget.section.title;
              setState(() => _isEditing = false);
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            widget.section.title,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E40AF),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Rename'),
            ),
            if (widget.provider.sections.length > 1)
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text('Delete section?'),
                          content: Text(
                            'Delete "${widget.section.title}" and all its fields? '
                            'This cannot be undone.',
                          ),
                          actions: [
                            ShadButton.outline(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ShadButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (confirm) {
                    widget.provider.removeSection(widget.section.id);
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
              ),
          ],
        ),
      ],
    );
  }

  void _save() {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.section.title) {
      widget.provider.updateSectionTitle(widget.section.id, newTitle);
    }
    setState(() => _isEditing = false);
  }
}

class _AddFieldControls extends StatefulWidget {
  const _AddFieldControls({
    required this.provider,
    required this.sectionId,
  });

  final FormBuilderProvider provider;
  final String sectionId;

  @override
  State<_AddFieldControls> createState() => _AddFieldControlsState();
}

class _AddFieldControlsState extends State<_AddFieldControls> {
  String? _selectedTemplateKey;

  @override
  Widget build(BuildContext context) {
    final templates = widget.provider.availableTemplates;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DropdownButtonFormField<String>(
            value: _selectedTemplateKey,
            decoration: InputDecoration(
              labelText: 'Add field from catalog',
              helperText:
                  templates.isEmpty ? 'All predefined fields added' : null,
            ),
            items: templates
                .map(
                  (template) => DropdownMenuItem(
                    value: template.key,
                    child: Text(template.label),
                  ),
                )
                .toList(),
            onChanged: templates.isEmpty
                ? null
                : (value) {
                    if (value == null) return;
                    final template = templates.firstWhere(
                      (element) => element.key == value,
                    );
                    widget.provider.addFieldToSection(
                      widget.sectionId,
                      template,
                    );
                    setState(() => _selectedTemplateKey = null);
                  },
          ),
        ),
        ShadButton.outline(
          onPressed: () => widget.provider.addCustomField(widget.sectionId),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('Add Custom Field'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldPreview extends StatelessWidget {
  const _FieldPreview({
    required this.provider,
    required this.sectionId,
    required this.field,
  });

  final FormBuilderProvider provider;
  final String sectionId;
  final DynamicFormField field;

  @override
  Widget build(BuildContext context) {
    final label = field.required ? '${field.label} *' : field.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: 'Edit field',
              onPressed: () => _openFieldDialog(context),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Remove field',
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text('Remove field?'),
                        content: Text(
                          'Are you sure you want to remove "${field.label}"?',
                        ),
                        actions: [
                          ShadButton.outline(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ShadButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (shouldDelete) {
                  provider.removeField(sectionId, field.id);
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _PreviewInput(field: field),
      ],
    );
  }

  void _openFieldDialog(BuildContext context) {
    final labelController = TextEditingController(text: field.label);
    final hintController = TextEditingController(text: field.hint);
    final optionsController =
        TextEditingController(text: field.options.join(', '));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Edit Field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Label', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ShadInput(
                  controller: labelController,
                  placeholder: const Text('Label'),
                ),
                const SizedBox(height: 12),
                const Text('Placeholder', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ShadInput(
                  controller: hintController,
                  placeholder: const Text('Placeholder'),
                ),
                const SizedBox(height: 12),
                const Text('Field Type', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DynamicFieldType>(
                      value: field.type,
                      isExpanded: true,
                      items: DynamicFieldType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(type.name.toUpperCase()),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (newType) {
                        if (newType != null) {
                          provider.updateFieldType(sectionId, field.id, newType);
                          Navigator.of(context).pop();
                          _openFieldDialog(context);
                        }
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: field.required,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Required'),
                  onChanged: (value) =>
                      provider.updateFieldRequired(sectionId, field.id, value),
                ),
                if (field.type == DynamicFieldType.dropdown ||
                    field.type == DynamicFieldType.checkboxList)
                  ShadInput(
                    controller: optionsController,
                    placeholder: const Text('Options (comma separated)'),
                  ),
              ],
            ),
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ShadButton(
              onPressed: () {
                provider.updateFieldLabel(
                  sectionId,
                  field.id,
                  labelController.text.trim(),
                );
                provider.updateFieldHint(
                  sectionId,
                  field.id,
                  hintController.text.trim(),
                );
                final options = optionsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((element) => element.isNotEmpty)
                    .toList();
                provider.updateFieldOptions(sectionId, field.id, options);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _PreviewInput extends StatelessWidget {
  const _PreviewInput({required this.field});

  final DynamicFormField field;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case DynamicFieldType.dropdown:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          height: 44,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(
                field.options.isNotEmpty ? field.options.first : 'Select',
                style: const TextStyle(color: Colors.black54),
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      case DynamicFieldType.textarea:
        return _fakeInput(hint: field.hint, maxLines: 3);
      case DynamicFieldType.checkboxList:
        return Wrap(
          spacing: 12,
          children: field.options
              .map(
                (option) => Chip(
                  label: Text(option),
                  backgroundColor: Colors.grey[100],
                ),
              )
              .toList(),
        );
      case DynamicFieldType.number:
        return _fakeInput(hint: field.hint, keyboard: TextInputType.number);
      case DynamicFieldType.text:
        return _fakeInput(hint: field.hint);
    }
  }

  Widget _fakeInput({String? hint, int maxLines = 1, TextInputType? keyboard}) {
    return ShadInput(
      enabled: false,
      placeholder: hint != null ? Text(hint) : null,
      keyboardType: keyboard,
    );
  }
}

