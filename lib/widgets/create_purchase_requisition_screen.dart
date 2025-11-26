import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_requisition_provider.dart';
import '../providers/procurement_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';
import '../utils/responsive_helper.dart';

class CreatePurchaseRequisitionScreen extends StatefulWidget {
  const CreatePurchaseRequisitionScreen({super.key});

  @override
  State<CreatePurchaseRequisitionScreen> createState() => _CreatePurchaseRequisitionScreenState();
}

class _CreatePurchaseRequisitionScreenState extends State<CreatePurchaseRequisitionScreen> {
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
      create: (_) => PurchaseRequisitionProvider(),
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open menu',
                    ),
                    Expanded(
                      child: Text(
                        'Create Purchase Requisition',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 700;
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isTablet)
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            tooltip: 'Open menu',
                          ),
                        if (!isSmallScreen)
                          Text(
                            'Create Purchase Requisition',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? double.infinity : searchWidth,
                        ),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
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
    final prProvider = context.watch<PurchaseRequisitionProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final items = dashboardProvider.itemMasterList;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Purchase Requisition',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          _requisitionDetailsSection(context, prProvider),
          const SizedBox(height: 32),
          _itemsRequiredSection(context, prProvider, items),
          const SizedBox(height: 32),
          _notesSection(context, prProvider),
          const SizedBox(height: 32),
          _actionButtons(context, prProvider),
        ],
      ),
    );
  }

  Widget _requisitionDetailsSection(
    BuildContext context,
    PurchaseRequisitionProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requisition Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: provider.requestedByController,
                    label: 'Requested By',
                    hint: 'Current User',
                    enabled: false,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dropdown(
                    label: 'Department *',
                    value: provider.selectedDepartment,
                    items: provider.departments,
                    onChanged: provider.setDepartment,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dropdown(
                    label: 'Priority *',
                    value: provider.selectedPriority,
                    items: provider.priorities,
                    onChanged: provider.setPriority,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dateField(
                    controller: provider.requiredDateController,
                    label: 'Required Date',
                    hint: 'mm/dd/yyyy',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _itemsRequiredSection(
    BuildContext context,
    PurchaseRequisitionProvider provider,
    List items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => provider.addItem(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('Action', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              ...provider.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _itemRow(context, provider, items, index, item);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemRow(
    BuildContext context,
    PurchaseRequisitionProvider provider,
    List items,
    int index,
    PurchaseRequisitionItem item,
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
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
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
    PurchaseRequisitionProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes / Justification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: provider.notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Reason for request...',
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

  Widget _actionButtons(
    BuildContext context,
    PurchaseRequisitionProvider provider,
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
          icon: const Icon(Icons.save),
          label: const Text('Submit Requisition'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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

  Future<void> _submit(BuildContext context, PurchaseRequisitionProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // TODO: Implement actual submission logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Requisition submitted successfully')),
        );
        context.read<ProcurementProvider>().closeCreateForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting requisition: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

