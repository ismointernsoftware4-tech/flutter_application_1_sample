import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/models/dashboard_models.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key, required this.item});

  final ItemMaster item;

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late final FormBuilderProvider _provider;

  Map<String, dynamic> get _initialData {
    final item = widget.item;
    return {
      'id': item.id,
      'itemCode': item.itemCode,
      'itemName': item.itemName,
      'manufacturer': item.manufacturer,
      'itemType': item.type,
      'type': item.type,
      'category': item.category,
      'unit': item.unit,
      'unitOfMeasure': item.unit,
      'storage': item.storage,
      'storageConditions': item.storage,
      'stock': item.stock,
      'quantity': item.stock,
      'status': item.status,
    };
  }

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'item_master');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.id == null) {
      return const Scaffold(
        body: Center(
          child: Text('Unable to edit item without a valid identifier.'),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _provider,
      child: SafeArea(
        child: Consumer<FormBuilderProvider>(
            builder: (context, formProvider, _) {
              if (formProvider.isLoading || formProvider.definition == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return FormScreenLayout(
                title: 'Edit Item',
                body: DynamicFormWidget(
                  definition: formProvider.definition!,
                  title: 'Item Details',
                  description:
                      'Update basic information, specifications, inventory and compliance data.',
                  saveButtonLabel: 'Update Item',
                  initialData: _initialData,
                  onSave: (data) async {
                    final item = widget.item;
                    data['itemCode'] = data['itemCode'] ?? item.itemCode;
                    data['status'] = data['status'] ?? item.status;
                    await context
                        .read<DashboardProvider>()
                        .updateItem(item.id!, data);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          ),
        ),
    );
  }
}


