import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/procurement_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  State<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboard = context.read<DashboardProvider>();
      // Load items for dropdown
      if (dashboard.itemMasterList.isEmpty) {
        dashboard.loadItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseOrderProvider(),
      child: Builder(
        builder: (context) {
          return Container(
            color: Colors.grey[100],
            child: Column(
              children: [
                _pageHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _backButton(context),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: _formCard(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pageHeader(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ProcurementProvider>().closeCreateForm();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            '← Back to List',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    final poProvider = context.watch<PurchaseOrderProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final items = dashboardProvider.itemMasterList;
    final vendors = dashboardProvider.vendors;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.02),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Purchase Order',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a new purchase order',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _orderDetailsSection(context, poProvider, vendors),
          const SizedBox(height: 32),
          _itemsSection(context, poProvider, items),
          const SizedBox(height: 32),
          _notesSection(context, poProvider),
          const SizedBox(height: 32),
          _actionButtons(context, poProvider),
        ],
      ),
    );
  }

  Widget _orderDetailsSection(
    BuildContext context,
    PurchaseOrderProvider provider,
    List<Vendor> vendors,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _vendorDropdown(
                    label: 'Vendor *',
                    value: provider.selectedVendor,
                    vendors: vendors,
                    onChanged: provider.setVendor,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dateField(
                    controller: provider.expectedDeliveryDateController,
                    label: 'Expected Delivery Date',
                    hint: 'mm/dd/yyyy',
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dropdown(
                    label: 'Payment Terms',
                    value: provider.selectedPaymentTerms,
                    items: provider.paymentTerms,
                    onChanged: provider.setPaymentTerms,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: provider.referencePRController,
                    label: 'Reference PR (Optional)',
                    hint: 'Enter PR Number',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _itemsSection(
    BuildContext context,
    PurchaseOrderProvider provider,
    List items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => provider.addItem(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('Unit Price (\$)', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('Total (\$)', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('Action', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              ...provider.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _itemRow(context, provider, items, index, item);
              }),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${provider.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemRow(
    BuildContext context,
    PurchaseOrderProvider provider,
    List items,
    int index,
    PurchaseOrderItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _itemDropdown(
              value: item.itemName.isEmpty ? 'Select Item' : item.itemName,
              items: items,
              onChanged: (value) {
                if (value != null) {
                  provider.updateItem(index, itemName: value);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              controller: TextEditingController(text: item.quantity.toString()),
              onChanged: (value) {
                final qty = int.tryParse(value) ?? 1;
                provider.updateItem(index, quantity: qty);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Units',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              controller: TextEditingController(text: item.unit),
              onChanged: (value) {
                provider.updateItem(index, unit: value);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              controller: TextEditingController(text: item.unitPrice.toStringAsFixed(2)),
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0.0;
                provider.updateItem(index, unitPrice: price);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => provider.removeItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemDropdown({
    required String value,
    required List items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? 'Select Item' : value,
          isExpanded: true,
          items: [
            const DropdownMenuItem(
              value: 'Select Item',
              child: Text('Select Item'),
            ),
            ...items.map((item) {
              final itemName = item is ItemMaster ? item.itemName : item.toString();
              return DropdownMenuItem(
                value: itemName,
                child: Text(itemName),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _notesSection(
    BuildContext context,
    PurchaseOrderProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notes / Terms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
        const SizedBox(height: 12),
        TextField(
          controller: provider.notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Additional terms or notes...',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(
    BuildContext context,
    PurchaseOrderProvider provider,
  ) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            context.read<ProcurementProvider>().closeCreateForm();
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: provider.canSubmit ? () => _submit(context, provider) : null,
          icon: const Icon(Icons.description),
          label: const Text('Create PO'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _vendorDropdown({
    required String label,
    required String? value,
    required List<Vendor> vendors,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text('Select Vendor'),
              items: vendors
                  .map(
                    (vendor) => DropdownMenuItem(
                      value: vendor.name,
                      child: Text(vendor.name),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
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
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              controller.text = '${date.month}/${date.day}/${date.year}';
            }
          },
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, PurchaseOrderProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // TODO: Implement actual submission logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Order created successfully')),
        );
        context.read<ProcurementProvider>().closeCreateForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating purchase order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

