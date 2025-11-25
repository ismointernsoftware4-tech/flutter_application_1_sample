import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dynamic_form_models.dart';
import '../providers/dashboard_provider.dart';
import '../providers/form_builder_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final Map<String, TextEditingController> _baseControllers = {};
  final Map<String, TextEditingController> _customControllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, Set<String>> _checkboxSelections = {};
  final Map<String, String> _fieldLabels = {};

  bool _isSubmitting = false;
  int _lastDefinitionVersion = -1;
  String _generatedItemCode = '';

  @override
  void initState() {
    super.initState();
    _registerBaseControllers();
    _generatedItemCode = _generateItemCode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormBuilderProvider>().loadDefinition();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.watch<FormBuilderProvider>();
    if (!provider.isLoading &&
        provider.definition != null &&
        provider.version != _lastDefinitionVersion) {
      _syncControllers(provider.definition!);
      _lastDefinitionVersion = provider.version;
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
            _customControllers.putIfAbsent(field.key, () => TextEditingController());
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
    final formProvider = context.watch<FormBuilderProvider>();
    final currentDefinition = formProvider.definition;
    final shouldShowLoader =
        formProvider.isLoading || currentDefinition == null;

    final Widget bodyContent;
    if (shouldShowLoader) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else {
      bodyContent = Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _buildFormBody(currentDefinition),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(child: bodyContent),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          const Text(
            'Add New Item',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 260,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBody(DynamicFormDefinition definition) {
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
            _buildIntro(),
            const SizedBox(height: 24),
            ...definition.sections.expand((section) {
              return [
                _sectionTitle(section.title),
                const SizedBox(height: 12),
                _twoColumn(
                  section.fields.map(_buildField).toList(),
                ),
                const SizedBox(height: 32),
              ];
            }),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final formProvider =
                              context.read<FormBuilderProvider>();
                          final definition = formProvider.definition;
                          if (definition == null) return;
                          try {
                            setState(() => _isSubmitting = true);
                            final navigator = Navigator.of(context);
                            final data = _collectFormData(definition);
                            await context
                                .read<DashboardProvider>()
                                .saveItem(data);
                            if (!mounted) return;
                            navigator.pop();
                            if (navigator.canPop()) {
                                navigator.pop();
                            }
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
                  icon: const Icon(Icons.save),
                  label: Text(_isSubmitting ? 'Saving...' : 'Save Item'),
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
          children: const [
            Text(
              'Item Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Capture basic information, specifications, inventory and compliance data.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E40AF),
      ),
    );
  }

  Widget _twoColumn(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnWidth = width > 700 ? (width - 24) / 2 : width;
        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: children.map((child) {
            return SizedBox(width: columnWidth, child: child);
          }).toList(),
        );
      },
    );
  }

  Widget _buildField(DynamicFormField field) {
    final label = field.required ? '${field.label} *' : field.label;
    switch (field.type) {
      case DynamicFieldType.dropdown:
        final options = field.options.isNotEmpty ? field.options : [''];
        final value = _dropdownValues[field.key] ?? options.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              items: options
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected == null) return;
                setState(() {
                  _dropdownValues[field.key] = selected;
                });
              },
              decoration: InputDecoration(
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
      case DynamicFieldType.textarea:
        return _buildTextField(field, label, maxLines: 3);
      case DynamicFieldType.number:
        return _buildTextField(
          field,
          label,
          keyboardType: TextInputType.number,
        );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: field.hint,
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

  Map<String, dynamic> _collectFormData(DynamicFormDefinition definition) {
    final data = <String, dynamic>{
      'itemCode': _generatedItemCode,
      'stock': 0,
      'status': 'Active',
    };
    final customFields = <String, dynamic>{};

    for (final section in definition.sections) {
      for (final field in section.fields) {
        final key = field.key;
        dynamic value;
        if (field.type == DynamicFieldType.dropdown) {
          value = _dropdownValues[key] ??
              (field.options.isNotEmpty ? field.options.first : '');
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

        if (isEmptyValue) continue;

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
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _generateItemCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ITM${timestamp.substring(timestamp.length - 5)}';
  }
}
