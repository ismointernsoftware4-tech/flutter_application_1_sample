import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class AddItemSidebar extends StatefulWidget {
  const AddItemSidebar({super.key});

  @override
  State<AddItemSidebar> createState() => _AddItemSidebarState();
}

class _AddItemSidebarState extends State<AddItemSidebar> {
  final Map<String, bool> _expanded = {
    'basic': true,
    'specs': true,
    'inventory': true,
    'compliance': true,
  };

  // Form controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemTypeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _hsCodeController = TextEditingController();
  final TextEditingController _storageConditionsController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _specificationsController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();
  final TextEditingController _unitOfMeasureController = TextEditingController();
  final TextEditingController _compositionController = TextEditingController();
  final TextEditingController _inventoryNotesController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _leadTimeController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _minReorderLevelController = TextEditingController();
  final TextEditingController _maxReorderLevelController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _complianceNotesController = TextEditingController();
  final TextEditingController _hazardClassificationController = TextEditingController();

  String _selectedItemType = 'Drug';
  String _selectedStorageConditions = 'Room Temperature (RT)';
  String _selectedUnitOfMeasure = 'Tablet';
  String _selectedHazardClassification = 'None';

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemTypeController.dispose();
    _categoryController.dispose();
    _hsCodeController.dispose();
    _storageConditionsController.dispose();
    _shelfLifeController.dispose();
    _specificationsController.dispose();
    _strengthController.dispose();
    _unitOfMeasureController.dispose();
    _compositionController.dispose();
    _inventoryNotesController.dispose();
    _manufacturerController.dispose();
    _leadTimeController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _minReorderLevelController.dispose();
    _maxReorderLevelController.dispose();
    _barcodeController.dispose();
    _complianceNotesController.dispose();
    _hazardClassificationController.dispose();
    super.dispose();
  }

  void _toggle(String key) {
    setState(() {
      _expanded[key] = !(_expanded[key] ?? true);
    });
  }

  Map<String, dynamic> _collectFormData() {
    // Generate item code
    final itemCode = 'ITM${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    return {
      'itemCode': itemCode,
      'itemName': _itemNameController.text.trim(),
      'itemType': _selectedItemType,
      'category': _categoryController.text.trim(),
      'hsCode': _hsCodeController.text.trim(),
      'storageConditions': _selectedStorageConditions,
      'shelfLife': _shelfLifeController.text.trim(),
      'specifications': _specificationsController.text.trim(),
      'strength': _strengthController.text.trim(),
      'unitOfMeasure': _selectedUnitOfMeasure,
      'composition': _compositionController.text.trim(),
      'inventoryNotes': _inventoryNotesController.text.trim(),
      'manufacturer': _manufacturerController.text.trim(),
      'leadTime': _leadTimeController.text.trim(),
      'unitPrice': _unitPriceController.text.trim(),
      'taxRate': _taxRateController.text.trim(),
      'minReorderLevel': _minReorderLevelController.text.trim(),
      'maxReorderLevel': _maxReorderLevelController.text.trim(),
      'barcode': _barcodeController.text.trim(),
      'complianceNotes': _complianceNotesController.text.trim(),
      'hazardClassification': _selectedHazardClassification,
      'stock': 0,
      'status': 'Active',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      color: Colors.white,
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    title: 'BASIC INFORMATION',
                    keyName: 'basic',
                    children: [
                      _twoColumn([
                        _textField('Item Name *', controller: _itemNameController, hint: 'e.g. Paracetamol 500mg'),
                        _dropdownField('Item Type *', ['Drug', 'Consumable'], _selectedItemType, (value) {
                          setState(() => _selectedItemType = value!);
                        }),
                        _textField('Category', controller: _categoryController, hint: 'e.g. Analgesic'),
                        _textField('HS Code', controller: _hsCodeController, hint: 'Harmonized System Code'),
                        _dropdownField('Storage Conditions *', [
                          'Room Temperature (RT)',
                          'Cold Chain (2-8°C)'
                        ], _selectedStorageConditions, (value) {
                          setState(() => _selectedStorageConditions = value!);
                        }),
                        _textField('Shelf Life (Months)', controller: _shelfLifeController, hint: '24'),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: 'SPECIFICATIONS',
                    keyName: 'specs',
                    children: [
                      _twoColumn([
                        _textField('Specifications', controller: _specificationsController, hint: 'General specifications...'),
                        _textField('Strength / Concentration', controller: _strengthController, hint: 'e.g. 500mg or 100IU/ml'),
                        _dropdownField('Unit of Measure *', ['Tablet', 'Bottle'], _selectedUnitOfMeasure, (value) {
                          setState(() => _selectedUnitOfMeasure = value!);
                        }),
                        _textArea('Composition / Description', controller: _compositionController,
                            hint: 'Detailed composition or description...'),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: 'INVENTORY & SUPPLY',
                    keyName: 'inventory',
                    children: [
                      _twoColumn([
                        _textArea('Inventory & Supply', controller: _inventoryNotesController, hint: 'General inventory notes...'),
                        _textField('Manufacturer', controller: _manufacturerController, hint: 'Manufacturer Name'),
                        _textField('Lead Time (Days)', controller: _leadTimeController, hint: 'e.g. 7'),
                        _textField('Unit Price', controller: _unitPriceController, hint: '0.00'),
                        _textField('Tax Rate (%)', controller: _taxRateController, hint: '0'),
                        _textField('Min Reorder Level', controller: _minReorderLevelController, hint: '100'),
                        _textField('Max Reorder Level', controller: _maxReorderLevelController, hint: '1000'),
                        _textField('Barcode / QR', controller: _barcodeController, hint: 'Scan or enter code'),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: 'COMPLIANCE & DOCUMENTS',
                    keyName: 'compliance',
                    children: [
                      _twoColumn([
                        _textArea('Compliance & Documents', controller: _complianceNotesController, hint: 'General compliance notes...'),
                        _dropdownField('Hazard Classification', ['None', 'Chemical', 'Biohazard'], _selectedHazardClassification, (value) {
                          setState(() => _selectedHazardClassification = value!);
                        }),
                        _filePicker(),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          context.read<DashboardProvider>().closeAddItemSidebar();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          child: Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_itemNameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter Item Name')),
                            );
                            return;
                          }
                          
                          try {
                            final formData = _collectFormData();
                            await context.read<DashboardProvider>().saveItem(formData);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item saved successfully!')),
                              );
                              context.read<DashboardProvider>().closeAddItemSidebar();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error saving item: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
            'Add New Item',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<DashboardProvider>().closeAddItemSidebar();
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String keyName,
    required List<Widget> children,
  }) {
    final expanded = _expanded[keyName] ?? true;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
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
          GestureDetector(
            onTap: () => _toggle(keyName),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const Spacer(),
                Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),
          if (expanded) ...children,
        ],
      ),
    );
  }

  Widget _twoColumn(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnWidth = width > 500 ? (width - 24) / 2 : width;
        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: fields.map((field) {
            return SizedBox(width: columnWidth, child: field);
          }).toList(),
        );
      },
    );
  }

  Widget _textField(String label, {required TextEditingController controller, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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

  Widget _textArea(String label, {required TextEditingController controller, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
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

  Widget _dropdownField(String label, List<String> options, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: options
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
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
  }

  Widget _filePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documents (COA, SDS)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file),
          label: const Text('Choose Files'),
        ),
        const SizedBox(height: 4),
        const Text(
          'Supported formats: PDF, JPG, PNG',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

