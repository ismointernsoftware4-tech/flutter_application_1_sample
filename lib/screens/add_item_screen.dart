import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final Map<String, bool> _expanded = {
    'basic': true,
    'specs': true,
    'inventory': true,
    'compliance': true,
  };

  void _toggle(String key) {
    setState(() {
      _expanded[key] = !(_expanded[key] ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
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
                          _textField('Item Name *', hint: 'e.g. Paracetamol 500mg'),
                          _dropdownField('Item Type *', ['Drug', 'Consumable']),
                          _textField('Category', hint: 'e.g. Analgesic'),
                          _textField('HS Code', hint: 'Harmonized System Code'),
                          _dropdownField('Storage Conditions *', [
                            'Room Temperature (RT)',
                            'Cold Chain (2-8°C)'
                          ]),
                          _textField('Shelf Life (Months)', hint: '24'),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'SPECIFICATIONS',
                      keyName: 'specs',
                      children: [
                        _twoColumn([
                          _textField('Specifications', hint: 'General specifications...'),
                          _textField('Strength / Concentration', hint: 'e.g. 500mg or 100IU/ml'),
                          _dropdownField('Unit of Measure *', ['Tablet', 'Bottle']),
                          _textArea('Composition / Description',
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
                          _textArea('Inventory & Supply', hint: 'General inventory notes...'),
                          _textField('Manufacturer', hint: 'Manufacturer Name'),
                          _textField('Lead Time (Days)', hint: 'e.g. 7'),
                          _textField('Unit Price', hint: '0.00'),
                          _textField('Tax Rate (%)', hint: '0'),
                          _textField('Min Reorder Level', hint: '100'),
                          _textField('Max Reorder Level', hint: '1000'),
                          _textField('Barcode / QR', hint: 'Scan or enter code'),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'COMPLIANCE & DOCUMENTS',
                      keyName: 'compliance',
                      children: [
                        _twoColumn([
                          _textArea('Compliance & Documents', hint: 'General compliance notes...'),
                          _dropdownField('Hazard Classification', ['None', 'Chemical', 'Biohazard']),
                          _filePicker(),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
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
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 260,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
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
        final columnWidth = width > 900 ? (width - 24) / 2 : width;
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

  Widget _textField(String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
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

  Widget _textArea(String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
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

  Widget _dropdownField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: options.first,
          items: options
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (_) {},
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

