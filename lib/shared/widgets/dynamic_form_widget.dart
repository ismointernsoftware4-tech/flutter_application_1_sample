import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/dynamic_form_models.dart';
import '../utils/responsive_helper.dart';

class DynamicFormWidget extends StatefulWidget {
  const DynamicFormWidget({
    super.key,
    required this.definition,
    required this.onSave,
    this.title = 'Form Details',
    this.description = 'Fill in the form fields below.',
    this.showCancelButton = true,
    this.onCancel,
    this.saveButtonLabel = 'Save',
    this.initialData,
  });

  final DynamicFormDefinition definition;
  final Future<void> Function(Map<String, dynamic> data) onSave;
  final String title;
  final String description;
  final bool showCancelButton;
  final VoidCallback? onCancel;
  final String saveButtonLabel;
  final Map<String, dynamic>? initialData;

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  final Map<String, TextEditingController> _baseControllers = {};
  final Map<String, TextEditingController> _customControllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, Set<String>> _checkboxSelections = {};
  final Map<String, String> _fieldLabels = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _registerBaseControllers();
    _syncControllers(widget.definition);
    if (widget.initialData != null) {
      _populateInitialData(widget.initialData!);
    }
  }

  @override
  void didUpdateWidget(DynamicFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition != widget.definition) {
      _syncControllers(widget.definition);
    }
  }

  @override
  void dispose() {
    for (final controller in _baseControllers.values) {
      controller.dispose();
    }
    for (final controller in _customControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _registerBaseControllers() {
    final keys = [
      'itemName',
      'category',
      'hsCode',
      'shelfLife',
      'specifications',
      'strength',
      'composition',
      'inventoryNotes',
      'manufacturer',
      'leadTime',
      'unitPrice',
      'taxRate',
      'minReorderLevel',
      'maxReorderLevel',
      'barcode',
      'complianceNotes',
    ];
    for (final key in keys) {
      _baseControllers[key] = TextEditingController();
    }
  }

  void _populateInitialData(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (_baseControllers.containsKey(key)) {
        _baseControllers[key]?.text = value.toString();
      } else if (_customControllers.containsKey(key)) {
        _customControllers[key]?.text = value.toString();
      } else if (_dropdownValues.containsKey(key)) {
        _dropdownValues[key] = value.toString();
      } else if (value is List) {
        _checkboxSelections[key] = value.map((e) => e.toString()).toSet();
      }
    }
  }

  void _syncControllers(DynamicFormDefinition definition) {
    final activeDropdownKeys = <String>{};
    final activeCustomKeys = <String>{};

    for (final section in definition.sections) {
      for (final field in section.fields) {
        _fieldLabels[field.key] = field.label;
        if (field.type == DynamicFieldType.dropdown) {
          final options = field.options.isNotEmpty ? field.options : [''];
          _dropdownValues.putIfAbsent(field.key, () => options.first);
          activeDropdownKeys.add(field.key);
        } else {
          if (!_baseControllers.containsKey(field.key)) {
            activeCustomKeys.add(field.key);
            _customControllers.putIfAbsent(
              field.key,
              () => TextEditingController(),
            );
          }
        }
      }
    }

    final unusedDropdownKeys = _dropdownValues.keys
        .where((key) => !activeDropdownKeys.contains(key))
        .toList();
    for (final key in unusedDropdownKeys) {
      _dropdownValues.remove(key);
    }

    final unusedCustomKeys = _customControllers.keys
        .where((key) => !activeCustomKeys.contains(key))
        .toList();
    for (final key in unusedCustomKeys) {
      _customControllers[key]?.dispose();
      _customControllers.remove(key);
    }
  }

  TextEditingController _controllerForKey(String key) {
    if (_baseControllers.containsKey(key)) {
      return _baseControllers[key]!;
    }
    return _customControllers.putIfAbsent(
      key,
      () => TextEditingController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return ShadCard(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 28,
          vertical: isMobile ? 20 : 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntro(isMobile),
              const SizedBox(height: 24),
              ...widget.definition.sections.expand((section) {
                return [
                  _sectionTitle(section.title),
                  const SizedBox(height: 12),
                  _buildSectionFields(section.fields),
                  const SizedBox(height: 32),
                ];
              }),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                if (widget.showCancelButton)
                  SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: ShadButton.outline(
                      onPressed:
                          widget.onCancel ?? () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: ShadButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            // Validate form before saving
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            try {
                              setState(() => _isSubmitting = true);
                              final data = _collectFormData(widget.definition);
                              await widget.onSave(data);
                              if (!mounted) return;
                              // IMPORTANT: Do NOT pop or call onCancel here.
                              // Each screen's onSave is responsible for navigation.
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save, size: 18),
                        const SizedBox(width: 8),
                        Text(_isSubmitting ? 'Saving...' : widget.saveButtonLabel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(bool isMobile) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.description,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );

    final infoTag = _infoTag();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 12),
          infoTag,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        infoTag,
      ],
    );
  }

  Widget _infoTag() {
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
            'All fields marked * are mandatory',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E40AF),
      ),
    );
  }

  /// Builds section fields in a responsive grid:
  /// - 3 columns on wide screens
  /// - 2 columns on medium screens
  /// - 1 column on small screens
  Widget _buildSectionFields(List<DynamicFormField> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;
        if (width > 1100) {
          columns = 3;
        } else if (width > 700) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 24.0;
        final totalSpacing = spacing * (columns - 1);
        final columnWidth = columns > 0
            ? (width - totalSpacing) / columns
            : width;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: fields.map((field) {
            return SizedBox(
              width: columnWidth,
              child: _buildField(field),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildField(DynamicFormField field) {
    final label = field.required ? '${field.label} *' : field.label;
    switch (field.type) {
      case DynamicFieldType.dropdown:
        final options = field.options;
        final value = _dropdownValues[field.key];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildShadSelect(
              id: field.key,
              value: value,
              options: options,
              placeholder: field.hint.isNotEmpty ? field.hint : null,
              required: field.required,
            ),
          ],
        );
      case DynamicFieldType.textarea:
        return _buildTextField(field, label, maxLines: 3);
      case DynamicFieldType.number:
        return _buildNumberField(field, label);
      case DynamicFieldType.text:
        return _buildTextField(field, label);
      case DynamicFieldType.checkboxList:
        return _buildCheckboxList(field, label);
    }
  }

  Widget _buildTextField(
    DynamicFormField field,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final controller = _controllerForKey(field.key);
    final helpText = field.extra['helpText'] as String?;
    final displayPlaceholder = field.extra['displayPlaceholder'] as bool? ?? true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (helpText != null && helpText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: controller.text,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                maxLines > 1
                    ? _buildShadTextArea(
                        controller: controller,
                        maxLines: maxLines,
                        keyboardType: keyboardType,
                        placeholder: displayPlaceholder && field.hint.isNotEmpty
                            ? field.hint
                            : null,
                        onChanged: (value) {
                          state.didChange(value);
                        },
                      )
                    : ShadInput(
                        controller: controller,
                        keyboardType: keyboardType,
                        placeholder: displayPlaceholder && field.hint.isNotEmpty
                            ? Text(field.hint)
                            : null,
                        onChanged: (value) {
                          state.didChange(value);
                        },
                      ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
          validator: field.required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildNumberField(DynamicFormField field, String label) {
    final controller = _controllerForKey(field.key);
    final min = field.extra['min'] as num?;
    final max = field.extra['max'] as num?;
    final numberFormat = field.extra['numberFormat'] as String?;
    final helpText = field.extra['helpText'] as String?;
    final displayPlaceholder = field.extra['displayPlaceholder'] as bool? ?? true;
    
    // Determine keyboard type based on numberFormat
    TextInputType keyboardType = TextInputType.number;
    if (numberFormat == 'integer') {
      keyboardType = TextInputType.number;
    } else if (numberFormat == 'decimal' || numberFormat == 'float') {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (field.required)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        if (helpText != null && helpText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (min != null || max != null) ...[
          const SizedBox(height: 4),
          Text(
            min != null && max != null
                ? 'Range: $min - $max'
                : min != null
                    ? 'Minimum: $min'
                    : 'Maximum: $max',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: controller.text,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInput(
                  controller: controller,
                  keyboardType: keyboardType,
                  placeholder: displayPlaceholder && field.hint.isNotEmpty
                      ? Text(field.hint)
                      : null,
                  onChanged: (value) {
                    state.didChange(value);
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
          validator: (value) {
            if (field.required && (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            if (value != null && value.trim().isNotEmpty) {
              final numValue = numberFormat == 'integer'
                  ? int.tryParse(value)
                  : double.tryParse(value);
              if (numValue == null) {
                return 'Please enter a valid number';
              }
              if (min != null && numValue < min) {
                return 'Value must be at least $min';
              }
              if (max != null && numValue > max) {
                return 'Value must be at most $max';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _collectFormData(DynamicFormDefinition definition) {
    final data = <String, dynamic>{};

    for (final section in definition.sections) {
      for (final field in section.fields) {
        final key = field.key;
        dynamic value;
        if (field.type == DynamicFieldType.dropdown) {
          value = _dropdownValues[key] ??
              (field.options.isNotEmpty ? field.options.first : '');
        } else if (field.type == DynamicFieldType.number) {
          final controller = _controllerForKey(key);
          final textValue = controller.text.trim();
          if (textValue.isNotEmpty) {
            final numberFormat = field.extra['numberFormat'] as String?;
            if (numberFormat == 'integer') {
              value = int.tryParse(textValue);
            } else {
              value = double.tryParse(textValue);
            }
          }
        } else if (field.type == DynamicFieldType.checkboxList) {
          value = _checkboxSelections[key]?.toList() ?? <String>[];
        } else {
          value = _controllerForKey(key).text.trim();
        }

        final isEmptyValue = value is List
            ? value.isEmpty
            : (value is String ? value.isEmpty : false);

        if (field.required && isEmptyValue) {
          throw Exception('${field.label} is required');
        }

        // Save all fields directly to data using their key
        // This ensures all form fields (including requestedBy, department, etc.) are saved correctly
        if (!isEmptyValue) {
          data[key] = value;
        }
      }
    }

    return data;
  }

  Widget _buildCheckboxList(DynamicFormField field, String label) {
    final options = field.options;
    final selected = _checkboxSelections[field.key] ?? <String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: options.map((option) {
            final isChecked = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isChecked,
              onSelected: (value) {
                setState(() {
                  final selections = _checkboxSelections.putIfAbsent(
                    field.key,
                    () => <String>{},
                  );
                  if (value) {
                    selections.add(option);
                  } else {
                    selections.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildShadTextArea({
    required TextEditingController controller,
    required int maxLines,
    TextInputType? keyboardType,
    String? placeholder,
    required ValueChanged<String> onChanged,
  }) {
    return ShadInput(
      controller: controller,
      keyboardType: keyboardType,
      minLines: maxLines,
      maxLines: maxLines,
      placeholder: placeholder != null && placeholder.isNotEmpty
          ? Text(placeholder)
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildShadSelect({
    required String id,
    required String? value,
    required List<String> options,
    String? placeholder,
    bool required = false,
  }) {
    final effectivePlaceholder =
        placeholder == null || placeholder.isEmpty ? 'Select an option' : placeholder;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the available width from constraints to constrain the dropdown menu
        final fieldWidth = constraints.maxWidth;
        
        return SizedBox(
          width: fieldWidth > 0 ? fieldWidth : double.infinity,
          child: ShadSelectFormField<String>(
            id: id,
            minWidth: fieldWidth > 0 ? fieldWidth : double.infinity,
            initialValue: (value != null && value.isNotEmpty) ? value : null,
            options: options
                .map(
                  (opt) => ShadOption<String>(
                    value: opt,
                    child: Text(opt),
                  ),
                )
                .toList(),
            selectedOptionBuilder: (context, selected) {
              if (selected.isEmpty) {
                return Text(effectivePlaceholder);
              }
              return Text(selected);
            },
            placeholder: Text(effectivePlaceholder),
            validator: required
                ? (v) {
                    if (v == null || v.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null,
            onChanged: (v) {
              setState(() {
                _dropdownValues[id] = v ?? '';
              });
            },
          ),
        );
      },
    );
  }
}

