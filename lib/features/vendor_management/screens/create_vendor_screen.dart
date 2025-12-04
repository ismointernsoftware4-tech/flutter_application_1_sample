import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateVendorScreen extends StatefulWidget {
  const CreateVendorScreen({super.key});

  @override
  State<CreateVendorScreen> createState() => _CreateVendorScreenState();
}

class _CreateVendorScreenState extends State<CreateVendorScreen> {
  late final FormBuilderProvider _provider;
  String _generatedVendorId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'vendor_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
      _generatedVendorId = _generateVendorId();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _generateVendorId() {
    return 'VND-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: SafeArea(
        child: Consumer<FormBuilderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.definition == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_generatedVendorId.isEmpty) {
                _generatedVendorId = _generateVendorId();
              }

              return FormScreenLayout(
                title: 'Add New Vendor',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Register New Vendor',
                  description:
                      'Fill in the company, contact, and compliance details.',
                  saveButtonLabel: 'Save Vendor',
                  onSave: (data) async {
                    data['id'] = _generatedVendorId;
                    await context.read<DashboardProvider>().saveVendor(data);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  onCancel: () {
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

