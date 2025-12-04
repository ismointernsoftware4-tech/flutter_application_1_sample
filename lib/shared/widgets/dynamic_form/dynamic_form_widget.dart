import 'package:flutter/material.dart';

import '../../../features/form_builder/models/dynamic_form_models.dart';

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
    this.showActionButtons = true,
    this.closeOnSave = true,
  });

  final DynamicFormDefinition definition;
  final Future<void> Function(Map<String, dynamic> data) onSave;
  final String title;
  final String description;
  final bool showCancelButton;
  final VoidCallback? onCancel;
  final String saveButtonLabel;
  final Map<String, dynamic>? initialData;
  final bool showActionButtons;
  final bool closeOnSave;

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();

  // Static method to access state and submit form
  static Future<void>? submitFormFromKey(GlobalKey key) {
    final state = key.currentState;
    if (state is _DynamicFormWidgetState) {
      return state.submitForm();
    }
    return null;
  }
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  final Map<String, TextEditingController> _baseControllers = {};
  final Map<String, TextEditingController> _customControllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, Set<String>> _checkboxSelections = {};
  final Map<String, String> _fieldLabels = {};
  final Set<String> _invalidFields = {};

  bool _isSubmitting = false;

  // Public method to submit the form programmatically
  Future<void> submitForm() async {
    if (_isSubmitting) return;
    
    try {
      setState(() => _isSubmitting = true);
      
      // Validate required fields before proceeding
      final validationErrors = _validateForm(widget.definition);
      if (validationErrors.isNotEmpty) {
        if (!mounted) {
          setState(() => _isSubmitting = false);
          return;
        }
        
        // Mark invalid fields for visual feedback
        final invalidFieldsSet = <String>{};
        for (final section in widget.definition.sections) {
          for (final field in section.fields) {
            if (field.required) {
              final key = field.key;
              dynamic value;
              if (field.type == DynamicFieldType.dropdown || field.type == DynamicFieldType.radio) {
                value = _dropdownValues[key];
                if (value == null || (value is String && value.isEmpty)) {
                  invalidFieldsSet.add(key);
                }
              } else if (field.type == DynamicFieldType.checkbox) {
                value = _checkboxSelections[key]?.toList() ?? <String>[];
                if (value.isEmpty) {
                  invalidFieldsSet.add(key);
                }
              } else {
                value = _controllerForKey(key).text.trim();
                if (value.isEmpty) {
                  invalidFieldsSet.add(key);
                }
              }
            }
          }
        }
        
        setState(() {
          _isSubmitting = false;
          _invalidFields.clear();
          _invalidFields.addAll(invalidFieldsSet);
        });
        
        // Show error message
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(validationErrors.first),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else {
          debugPrint('Validation error: ${validationErrors.first}');
        }
        return;
      }
      
      // Clear invalid fields if validation passes
      setState(() {
        _invalidFields.clear();
      });
      
      final data = _collectFormData(widget.definition);
      await widget.onSave(data);
      if (!mounted) {
        setState(() => _isSubmitting = false);
        return;
      }
      if (widget.closeOnSave) {
        if (widget.onCancel != null) {
          widget.onCancel!();
        } else {
          Navigator.of(context).pop();
        }
      }
      // Reset submitting state after successful save
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        debugPrint('Error: ${e.toString()}');
      }
    }
  }

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
    return _customControllers.putIfAbsent(key, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntro(),
            const SizedBox(height: 24),
            Column(
              children: widget.definition.sections
                  .map((section) => _buildSection(section))
                  .toList(),
            ),
            if (widget.showActionButtons)
              Row(
                children: [
                  if (widget.showCancelButton)
                    OutlinedButton(
                      onPressed:
                          widget.onCancel ?? () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  if (widget.showCancelButton) const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            try {
                              setState(() => _isSubmitting = true);
                              
                              // Validate required fields before proceeding
                              final validationErrors = _validateForm(widget.definition);
                              if (validationErrors.isNotEmpty) {
                                if (!mounted) {
                                  setState(() => _isSubmitting = false);
                                  return;
                                }
                                
                                // Mark invalid fields for visual feedback
                                final invalidFieldsSet = <String>{};
                                for (final section in widget.definition.sections) {
                                  for (final field in section.fields) {
                                    if (field.required) {
                                      final key = field.key;
                                      dynamic value;
                                      if (field.type == DynamicFieldType.dropdown || field.type == DynamicFieldType.radio) {
                                        value = _dropdownValues[key];
                                        if (value == null || (value is String && value.isEmpty)) {
                                          invalidFieldsSet.add(key);
                                        }
                                      } else if (field.type == DynamicFieldType.checkbox) {
                                        value = _checkboxSelections[key]?.toList() ?? <String>[];
                                        if (value.isEmpty) {
                                          invalidFieldsSet.add(key);
                                        }
                                      } else {
                                        value = _controllerForKey(key).text.trim();
                                        if (value.isEmpty) {
                                          invalidFieldsSet.add(key);
                                        }
                                      }
                                    }
                                  }
                                }
                                
                                setState(() {
                                  _isSubmitting = false;
                                  _invalidFields.clear();
                                  _invalidFields.addAll(invalidFieldsSet);
                                });
                                
                                // Show error message
                                final messenger = ScaffoldMessenger.maybeOf(context);
                                if (messenger != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(validationErrors.first),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        textColor: Colors.white,
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                } else {
                                  debugPrint('Validation error: ${validationErrors.first}');
                                }
                                return;
                              }
                              
                              // Clear invalid fields if validation passes
                              setState(() {
                                _invalidFields.clear();
                              });
                              
                              final data = _collectFormData(widget.definition);
                              await widget.onSave(data);
                              if (!mounted) {
                                setState(() => _isSubmitting = false);
                                return;
                              }
                              if (widget.closeOnSave) {
                                if (widget.onCancel != null) {
                                  widget.onCancel!();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              }
                              // Reset submitting state after successful save
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _isSubmitting = false);
                              final messenger = ScaffoldMessenger.maybeOf(context);
                              if (messenger != null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                debugPrint('Error: ${e.toString()}');
                              }
                            }
                          },
                    icon: const Icon(Icons.save),
                    label: Text(
                      _isSubmitting ? 'Saving...' : widget.saveButtonLabel,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildIntro() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        Container(
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
        ),
      ],
    );
  }

  Widget _buildSection(DynamicFormSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title.toUpperCase(),
            style: const TextStyle(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
            ),
          ),
          if (section.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                section.description,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
          const SizedBox(height: 18),
          _gridLayout(section.fields.map(_buildField).toList()),
        ],
      ),
    );
  }

  Widget _gridLayout(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 24.0;
        final width = constraints.maxWidth;
        final columns = width > 640
            ? 3
            : width > 420
            ? 2
            : 1;
        final columnWidth = ((width - (gap * (columns - 1))) / columns).clamp(
          220.0,
          width,
        );
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((child) => SizedBox(width: columnWidth, child: child))
              .toList(),
        );
      },
    );
  }

  Widget _buildField(DynamicFormField field) {
    final label = field.required ? '${field.label} *' : field.label;
    Widget control;
    switch (field.type) {
      case DynamicFieldType.dropdown:
      case DynamicFieldType.radio:
        final options = field.options.isNotEmpty ? field.options : [''];
        // Don't default to first option for required fields - let user select
        final currentValue = _dropdownValues[field.key];
        final value = currentValue ?? (field.required ? null : options.first);
        control = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value != null && options.contains(value) ? value : null,
              items: options
                  .toSet() // Remove duplicates
                  .toList()
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected == null) return;
                setState(() {
                  _dropdownValues[field.key] = selected;
                  // Clear invalid state when user selects a value
                  _invalidFields.remove(field.key);
                });
              },
              validator: field.required
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '${field.label} is required';
                      }
                      return null;
                    }
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: _invalidFields.contains(field.key) 
                    ? Colors.red[50] 
                    : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: _invalidFields.contains(field.key)
                      ? const BorderSide(color: Colors.red, width: 2)
                      : BorderSide.none,
                ),
                errorText: _invalidFields.contains(field.key) && field.required
                    ? '${field.label} is required'
                    : null,
              ),
            ),
          ],
        );
        break;
      case DynamicFieldType.textarea:
        control = _buildTextField(field, label, maxLines: 3);
        break;
      case DynamicFieldType.number:
        control = _buildTextField(
          field,
          label,
          keyboardType: TextInputType.number,
        );
        break;
      case DynamicFieldType.text:
      case DynamicFieldType.email:
      case DynamicFieldType.date:
        control = _buildTextField(field, label);
        break;
      case DynamicFieldType.file:
        control = _buildFileUpload(field, label);
        break;
      case DynamicFieldType.checkbox:
        control = _buildCheckboxList(field, label);
        break;
      case DynamicFieldType.section:
        control = Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            field.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        );
        break;
      case DynamicFieldType.divider:
        control = const Divider();
        break;
    }
    final help = field.extra['helpText'] as String?;
    if (help != null && help.isNotEmpty) {
      control = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          control,
          const SizedBox(height: 6),
          Text(
            help,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      );
    }
    return control;
  }

  Widget _buildTextField(
    DynamicFormField field,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final controller = _controllerForKey(field.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (value) {
            // Clear invalid state when user starts typing
            if (_invalidFields.contains(field.key)) {
              setState(() {
                _invalidFields.remove(field.key);
              });
            }
          },
          decoration: InputDecoration(
            hintText: field.hint,
            filled: true,
            fillColor: _invalidFields.contains(field.key) 
                ? Colors.red[50] 
                : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: _invalidFields.contains(field.key)
                  ? const BorderSide(color: Colors.red, width: 2)
                  : BorderSide.none,
            ),
            errorText: _invalidFields.contains(field.key) && field.required
                ? '${field.label} is required'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(DynamicFormField field, String label) {
    final allowed =
        (field.extra['allowedTypes'] as List?)?.cast<String>() ??
        const ['pdf', 'jpg', 'png'];
    final description = allowed.isNotEmpty
        ? allowed.join(', ')
        : 'pdf, jpg, png';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            final messenger = ScaffoldMessenger.maybeOf(context);
            if (messenger != null) {
              messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'File upload will be supported in a future update.',
                ),
              ),
            );
            } else {
              debugPrint('File upload will be supported in a future update.');
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
        ),
        const SizedBox(height: 6),
        Text(
          'Allowed: $description',
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }

  /// Validate all required fields in the form
  List<String> _validateForm(DynamicFormDefinition definition) {
    final errors = <String>[];
    
    for (final section in definition.sections) {
      for (final field in section.fields) {
        if (!field.required) continue;
        
        if (field.type == DynamicFieldType.file) {
          // File fields are handled separately, skip for now
          continue;
        }
        
        final key = field.key;
        dynamic value;
        
        if (field.type == DynamicFieldType.dropdown || field.type == DynamicFieldType.radio) {
          value = _dropdownValues[key];
          // For required dropdowns, null or empty means not selected
          if (value == null || (value is String && value.isEmpty)) {
            errors.add('${field.label} is required');
            continue;
          }
        } else if (field.type == DynamicFieldType.checkbox) {
          value = _checkboxSelections[key]?.toList() ?? <String>[];
          if (value.isEmpty) {
            errors.add('${field.label} is required');
            continue;
          }
        } else {
          value = _controllerForKey(key).text.trim();
          if (value.isEmpty) {
            errors.add('${field.label} is required');
            continue;
          }
        }
      }
    }
    
    return errors;
  }

  Map<String, dynamic> _collectFormData(DynamicFormDefinition definition) {
    // Start with initial data to preserve previous steps' data
    final data = <String, dynamic>{};
    final customFields = <String, dynamic>{};

    if (widget.initialData != null) {
      // Preserve all data from previous steps
      data.addAll(widget.initialData!);
      // Extract and preserve existing customFields
      if (data.containsKey('customFields') && data['customFields'] is Map) {
        final existingCustomFields = data.remove('customFields') as Map<String, dynamic>;
        customFields.addAll(existingCustomFields);
      }
    }

    // Now collect data from current step's fields
    for (final section in definition.sections) {
      for (final field in section.fields) {
        if (field.type == DynamicFieldType.file) {
          // File uploads are not captured in this demo implementation.
          continue;
        }
        final key = field.key;
        dynamic value;
        if (field.type == DynamicFieldType.dropdown) {
          value =
              _dropdownValues[key] ??
              (field.options.isNotEmpty ? field.options.first : '');
        } else if (field.type == DynamicFieldType.checkbox) {
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

        // Only skip empty values if they're not required
        // This ensures we preserve previous step data even if field is empty in current step
        if (isEmptyValue && !field.required) continue;

        // Update the value (this will overwrite previous step's value if field exists in current step)
        if (_baseControllers.containsKey(key) ||
            kFormFieldCatalog.any((template) => template.key == key)) {
          data[key] = value;
        } else {
          customFields[_fieldLabels[key] ?? key] = value;
        }
      }
    }

    if (customFields.isNotEmpty) {
      data['customFields'] = customFields;
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
                  // Clear invalid state when user selects a checkbox
                  if (selections.isNotEmpty) {
                    _invalidFields.remove(field.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

