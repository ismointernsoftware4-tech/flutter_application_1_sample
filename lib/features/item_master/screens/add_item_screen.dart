import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';
import '../providers/item_master_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  late final FormBuilderProvider _provider;
  String _generatedItemCode = '';

  @override
  void initState() {
    super.initState();
    _generatedItemCode = _generateItemCode();
    _provider = FormBuilderProvider(formId: 'item_master');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: SafeArea(
        child: Consumer<FormBuilderProvider>(
          builder: (context, formProvider, _) {
            if (formProvider.isLoading || formProvider.definition == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return FormScreenLayout(
              title: 'Add New Item',
              body: DynamicFormWidget(
                definition: formProvider.definition!,
                title: 'Item Details',
                description:
                    'Capture basic information, specifications, inventory and compliance data.',
                saveButtonLabel: 'Save Item',
                onSave: (data) async {
                  try {
                    data['itemCode'] = _generatedItemCode;
                    data['stock'] = 0;
                    data['status'] = 'Active';

                    // Show loading indicator on the root navigator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Save the item to Firebase
                    await context.read<ItemMasterProvider>().saveItem(data);

                    if (!mounted) return;

                    // Close loading dialog (root navigator)
                    final rootNav = Navigator.of(context, rootNavigator: true);
                    if (rootNav.canPop()) {
                      rootNav.pop();
                    }

                    // Pop the AddItemScreen using the content navigator
                    final dashboardProvider =
                        Provider.of<DashboardProvider>(context, listen: false);
                    final contentNav =
                        dashboardProvider.contentNavigatorKey.currentState;
                    contentNav?.maybePop();

                    // Show success message after navigation
                    // Use a small delay to ensure navigation completes
                    await Future.delayed(const Duration(milliseconds: 100));

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item saved successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    // Close loading dialog on root navigator if open
                    final rootNav = Navigator.of(context, rootNavigator: true);
                    if (rootNav.canPop()) {
                      rootNav.pop();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving item: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    // Don't navigate on error - let user fix and retry
                  }
                },
                onCancel: () {
                  final dashboardProvider =
                      Provider.of<DashboardProvider>(context, listen: false);
                  final contentNav =
                      dashboardProvider.contentNavigatorKey.currentState;
                  contentNav?.maybePop();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _generateItemCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ITM${timestamp.substring(timestamp.length - 5)}';
  }
}
