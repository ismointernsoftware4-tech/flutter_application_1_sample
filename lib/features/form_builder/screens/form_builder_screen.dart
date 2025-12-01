import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dynamic_form_models.dart';
import '../providers/form_builder_provider.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key, this.formTitle = 'Configure Item Form'});

  final String formTitle;

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormBuilderProvider>().loadDefinition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF4F6FB);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Consumer<FormBuilderProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading || provider.definition == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                _BuilderHeader(
                  title: widget.formTitle,
                  onViewForm: () async {
                    await provider.saveDefinition();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form definition saved. Use Form Entry to view the form.'),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              if (index == 0) {
                                return _BuilderCard(provider: provider);
                              }
                              return const SizedBox.shrink();
                            }, childCount: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BuilderHeader extends StatelessWidget {
  const _BuilderHeader({required this.onViewForm, required this.title});

  final String title;
  final VoidCallback onViewForm;

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
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onViewForm,
            icon: const Icon(Icons.visibility),
            label: const Text('View Form'),
          ),
        ],
      ),
    );
  }
}

class _BuilderCard extends StatelessWidget {
  const _BuilderCard({required this.provider});

  final FormBuilderProvider provider;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [_IntroText(), _InfoTag()],
            ),
            const SizedBox(height: 24),
            ...provider.sections
                .map(
                  (section) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final columnWidth = width > 700
                              ? (width - 24) / 2
                              : width;
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
            const SizedBox(height: 8),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isSaving
                        ? null
                        : () async {
                            try {
                              await provider.saveDefinition();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Form definition saved.'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                    icon: const Icon(Icons.save_outlined),
                    label: Text(provider.isSaving ? 'Saving...' : 'Save Form'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: provider.isSaving
                        ? null
                        : () async {
                            try {
                              await provider.saveDefinition();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Form definition saved. Use Form Entry to view the form.'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      provider.isSaving ? 'Please wait...' : 'Save & Open Form',
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

class _IntroText extends StatelessWidget {
  const _IntroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Item Form Template',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Arrange sections and fields that will appear on the Add Item screen.',
          style: TextStyle(color: Colors.black54, fontSize: 14),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.info_outline, color: Colors.blue, size: 18),
          SizedBox(width: 6),
          Text(
            'Changes apply to all users',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AddFieldControls extends StatefulWidget {
  const _AddFieldControls({required this.provider, required this.sectionId});

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
              helperText: templates.isEmpty
                  ? 'All predefined fields added'
                  : null,
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
        OutlinedButton.icon(
          onPressed: () => widget.provider.addCustomField(widget.sectionId),
          icon: const Icon(Icons.add),
          label: const Text('Add Custom Field'),
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
                final shouldDelete =
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove field?'),
                        content: Text(
                          'Are you sure you want to remove "${field.label}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
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
    final optionsController = TextEditingController(
      text: field.options.join(', '),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hintController,
                  decoration: const InputDecoration(labelText: 'Placeholder'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DynamicFieldType>(
                  value: field.type,
                  decoration: const InputDecoration(labelText: 'Field Type'),
                  items: DynamicFieldType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
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
                    field.type == DynamicFieldType.checkbox)
                  TextField(
                    controller: optionsController,
                    decoration: const InputDecoration(
                      labelText: 'Options (comma separated)',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
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
      case DynamicFieldType.radio:
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
      case DynamicFieldType.checkbox:
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
      case DynamicFieldType.email:
      case DynamicFieldType.date:
        return _fakeInput(hint: field.hint);
      case DynamicFieldType.file:
        return _fakeInput(hint: 'Upload file');
      case DynamicFieldType.section:
        return Text(
          field.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        );
      case DynamicFieldType.divider:
        return const Divider();
    }
  }

  Widget _fakeInput({String? hint, int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      enabled: false,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      keyboardType: keyboard,
    );
  }
}

