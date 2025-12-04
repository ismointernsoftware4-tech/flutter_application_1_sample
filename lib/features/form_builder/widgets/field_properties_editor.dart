import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';

class FieldPropertiesEditor extends StatefulWidget {
  const FieldPropertiesEditor({
    super.key,
    required this.section,
    required this.field,
    required this.onSectionUpdate,
    required this.onDeleteSection,
    required this.onFieldUpdate,
    required this.onDeleteField,
  });

  final DynamicFormSection? section;
  final DynamicFormField? field;
  final void Function(DynamicFormSection section) onSectionUpdate;
  final void Function(String sectionId) onDeleteSection;
  final void Function(DynamicFormField field) onFieldUpdate;
  final void Function(String fieldId) onDeleteField;

  @override
  State<FieldPropertiesEditor> createState() => _FieldPropertiesEditorState();
}

class _FieldPropertiesEditorState extends State<FieldPropertiesEditor> {
  late TextEditingController _sectionTitleController;
  late TextEditingController _sectionDescriptionController;
  late TextEditingController _labelController;
  late TextEditingController _placeholderController;
  late TextEditingController _helpTextController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late TextEditingController _dateMinController;
  late TextEditingController _dateMaxController;
  late TextEditingController _maxFileSizeController;
  late TextEditingController _minFileSizeController;
  late TextEditingController _customFileTypeController;
  List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _initSectionControllers();
    _initFieldControllers();
  }

  @override
  void didUpdateWidget(FieldPropertiesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section?.id != oldWidget.section?.id) {
      _initSectionControllers();
    }
    if (widget.field?.id != oldWidget.field?.id) {
      _initFieldControllers();
    }
  }

  void _initSectionControllers() {
    _sectionTitleController = TextEditingController(
      text: widget.section?.title ?? '',
    );
    _sectionDescriptionController = TextEditingController(
      text: widget.section?.description ?? '',
    );
  }

  void _disposeOptionControllers() {
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers = [];
  }

  void _initFieldControllers() {
    _disposeOptionControllers();
    _labelController = TextEditingController(text: widget.field?.label ?? '');
    _placeholderController = TextEditingController(
      text: widget.field?.hint ?? '',
    );
    _helpTextController = TextEditingController(
      text: widget.field?.extra['helpText'] as String? ?? '',
    );
    _minController = TextEditingController(
      text: widget.field?.extra['min']?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: widget.field?.extra['max']?.toString() ?? '',
    );
    _dateMinController = TextEditingController(
      text: widget.field?.extra['minDate'] as String? ?? '',
    );
    _dateMaxController = TextEditingController(
      text: widget.field?.extra['maxDate'] as String? ?? '',
    );
    _maxFileSizeController = TextEditingController(
      text: _formatDouble(widget.field?.extra['maxSizeMb']),
    );
    _minFileSizeController = TextEditingController(
      text: _formatDouble(widget.field?.extra['minSizeMb']),
    );
    _customFileTypeController = TextEditingController();
    final options = widget.field?.options ?? const [];
    _optionControllers = options
        .map((option) => TextEditingController(text: option))
        .toList();
  }

  @override
  void dispose() {
    _sectionTitleController.dispose();
    _sectionDescriptionController.dispose();
    _labelController.dispose();
    _placeholderController.dispose();
    _helpTextController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _dateMinController.dispose();
    _dateMaxController.dispose();
    _maxFileSizeController.dispose();
    _minFileSizeController.dispose();
    _customFileTypeController.dispose();
    _disposeOptionControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final section = widget.section;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Properties',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (field != null) ...[
              _buildFieldHeader(field),
              const Divider(height: 24),
              _buildFieldForm(field),
            ] else if (section != null) ...[
              _buildSectionHeader(section),
              const Divider(height: 24),
              _buildSectionForm(section),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Select a section or field to edit its properties.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(DynamicFormSection section) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Section',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        IconButton(
          onPressed: () => widget.onDeleteSection(section.id),
          color: Colors.red,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  Widget _buildSectionForm(DynamicFormSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _input(
          label: 'Title',
          controller: _sectionTitleController,
          onChanged: (value) =>
              widget.onSectionUpdate(section.copyWith(title: value)),
        ),
        const SizedBox(height: 16),
        _input(
          label: 'Description',
          controller: _sectionDescriptionController,
          maxLines: 3,
          onChanged: (value) =>
              widget.onSectionUpdate(section.copyWith(description: value)),
        ),
      ],
    );
  }

  Widget _buildFieldHeader(DynamicFormField field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          field.type.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => widget.onDeleteField(field.id),
          color: Colors.red,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  Widget _buildFieldForm(DynamicFormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _input(
          label: 'Label',
          controller: _labelController,
          onChanged: (value) =>
              widget.onFieldUpdate(field.copyWith(label: value)),
        ),
        const SizedBox(height: 16),
        _input(
          label: 'Placeholder',
          controller: _placeholderController,
          onChanged: (value) =>
              widget.onFieldUpdate(field.copyWith(hint: value)),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: field.required,
          onChanged: (value) =>
              widget.onFieldUpdate(field.copyWith(required: value)),
          title: const Text('Required'),
        ),
        const SizedBox(height: 12),
        _input(
          label: 'Help text',
          controller: _helpTextController,
          maxLines: 2,
          onChanged: (value) =>
              widget.onFieldUpdate(_withExtra(field, 'helpText', value)),
        ),
        if (field.type == DynamicFieldType.number) ...[
          const SizedBox(height: 16),
          const Text(
            'Number type',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Integer'),
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(
                  color: (field.extra['numberFormat'] as String?) == 'integer'
                      ? Colors.white
                      : Colors.black87,
                ),
                selected: (field.extra['numberFormat'] as String?) != 'float',
                onSelected: (_) => widget.onFieldUpdate(
                  _withExtra(field, 'numberFormat', 'integer'),
                ),
              ),
              ChoiceChip(
                label: const Text('Decimal'),
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(
                  color: (field.extra['numberFormat'] as String?) == 'float'
                      ? Colors.white
                      : Colors.black87,
                ),
                selected: (field.extra['numberFormat'] as String?) == 'float',
                onSelected: (_) => widget.onFieldUpdate(
                  _withExtra(field, 'numberFormat', 'float'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _input(
                  label: 'Min',
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.onFieldUpdate(
                    _withExtra(field, 'min', double.tryParse(value)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _input(
                  label: 'Max',
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.onFieldUpdate(
                    _withExtra(field, 'max', double.tryParse(value)),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (field.type == DynamicFieldType.dropdown ||
            field.type == DynamicFieldType.radio ||
            field.type == DynamicFieldType.checkbox) ...[
          const SizedBox(height: 16),
          _optionsBuilder(field),
        ],
        if (field.type == DynamicFieldType.checkbox)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Default checked'),
            value: field.extra['defaultChecked'] == true,
            onChanged: (value) => widget.onFieldUpdate(
              _withExtra(field, 'defaultChecked', value),
            ),
          ),
        if (field.type == DynamicFieldType.file) ...[
          const SizedBox(height: 16),
          _fileRulesEditor(field),
        ],
        if (field.type == DynamicFieldType.date) ...[
          const SizedBox(height: 16),
          _input(
            label: 'Min date (YYYY-MM-DD)',
            controller: _dateMinController,
            onChanged: (value) =>
                widget.onFieldUpdate(_withExtra(field, 'minDate', value)),
          ),
          const SizedBox(height: 12),
          _input(
            label: 'Max date (YYYY-MM-DD)',
            controller: _dateMaxController,
            onChanged: (value) =>
                widget.onFieldUpdate(_withExtra(field, 'maxDate', value)),
          ),
        ],
      ],
    );
  }

  Widget _optionsBuilder(DynamicFormField field) {
    final options = field.options;
    if (_optionControllers.length != options.length) {
      _optionControllers = options
          .map((option) => TextEditingController(text: option))
          .toList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Options', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...List.generate(options.length, (index) {
          final controller = _optionControllers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final updated = [...field.options];
                      updated[index] = value;
                      widget.onFieldUpdate(field.copyWith(options: updated));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      onPressed: index == 0
                          ? null
                          : () {
                              // Reorder options
                              final updated = [...field.options];
                              final item = updated.removeAt(index);
                              updated.insert(index - 1, item);
                              
                              // Reorder controllers to match
                              final controllerItem = _optionControllers.removeAt(index);
                              _optionControllers.insert(index - 1, controllerItem);
                              
                              // Sync controller texts with updated options
                              for (var i = 0; i < updated.length; i++) {
                                if (_optionControllers[i].text != updated[i]) {
                                  _optionControllers[i].text = updated[i];
                                }
                              }
                              
                              widget.onFieldUpdate(
                                field.copyWith(options: updated),
                              );
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 18),
                      onPressed: index == options.length - 1
                          ? null
                          : () {
                              // Reorder options
                              final updated = [...field.options];
                              final item = updated.removeAt(index);
                              updated.insert(index + 1, item);
                              
                              // Reorder controllers to match
                              final controllerItem = _optionControllers.removeAt(index);
                              _optionControllers.insert(index + 1, controllerItem);
                              
                              // Sync controller texts with updated options
                              for (var i = 0; i < updated.length; i++) {
                                if (_optionControllers[i].text != updated[i]) {
                                  _optionControllers[i].text = updated[i];
                                }
                              }
                              
                              widget.onFieldUpdate(
                                field.copyWith(options: updated),
                              );
                            },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: options.length <= 1
                      ? null
                      : () {
                          final updated = [...field.options]..removeAt(index);
                          widget.onFieldUpdate(
                            field.copyWith(options: updated),
                          );
                        },
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            final updated = [
              ...field.options,
              'Option ${field.options.length + 1}',
            ];
            widget.onFieldUpdate(field.copyWith(options: updated));
          },
          icon: const Icon(Icons.add),
          label: const Text('Add option'),
        ),
      ],
    );
  }

  Widget _fileRulesEditor(DynamicFormField field) {
    final allowed =
        (field.extra['allowedTypes'] as List?)?.cast<String>() ?? <String>[];
    const presets = ['pdf', 'docx', 'xlsx', 'csv', 'jpg', 'png', 'gif'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allowed file types',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((type) {
            final isSelected = allowed.contains(type);
            return FilterChip(
              label: Text(type.toUpperCase()),
              selected: isSelected,
              onSelected: (value) {
                final updated = [...allowed];
                if (value) {
                  updated.add(type);
                } else {
                  updated.remove(type);
                }
                widget.onFieldUpdate(
                  _withExtra(field, 'allowedTypes', updated),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customFileTypeController,
                decoration: const InputDecoration(
                  labelText: 'Custom type (e.g. svg)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final value = _customFileTypeController.text.trim();
                if (value.isEmpty) return;
                final updated = {...allowed, value.toLowerCase()}.toList();
                widget.onFieldUpdate(
                  _withExtra(field, 'allowedTypes', updated),
                );
                _customFileTypeController.clear();
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _input(
                label: 'Max size (MB)',
                controller: _maxFileSizeController,
                keyboardType: TextInputType.number,
                onChanged: (value) => widget.onFieldUpdate(
                  _withExtra(field, 'maxSizeMb', double.tryParse(value)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _input(
                label: 'Min size (MB)',
                controller: _minFileSizeController,
                keyboardType: TextInputType.number,
                onChanged: (value) => widget.onFieldUpdate(
                  _withExtra(field, 'minSizeMb', double.tryParse(value)),
                ),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Allow multiple files'),
          value: field.extra['allowMultiple'] == true,
          onChanged: (value) =>
              widget.onFieldUpdate(_withExtra(field, 'allowMultiple', value)),
        ),
      ],
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  DynamicFormField _withExtra(
    DynamicFormField field,
    String key,
    dynamic value,
  ) {
    final extra = Map<String, dynamic>.from(field.extra);
    if (value == null || (value is String && value.isEmpty)) {
      extra.remove(key);
    } else {
      extra[key] = value;
    }
    return field.copyWith(extra: extra);
  }

  String _formatDouble(dynamic value) {
    if (value == null) return '';
    if (value is num) return value.toString();
    return value.toString();
  }
}

