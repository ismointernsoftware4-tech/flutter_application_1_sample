import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateStockReturnScreen extends StatefulWidget {
  const CreateStockReturnScreen({super.key});

  @override
  State<CreateStockReturnScreen> createState() => _CreateStockReturnScreenState();
}

class _CreateStockReturnScreenState extends State<CreateStockReturnScreen> {
  late final FormBuilderProvider _provider;
  String _generatedReturnId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'stock_return_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
      _generatedReturnId = _generateReturnId();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _generateReturnId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'RET-$timestamp';
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

              if (_generatedReturnId.isEmpty) {
                _generatedReturnId = _generateReturnId();
              }

              return FormScreenLayout(
                title: 'Create Stock Return',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Stock Return',
                  description:
                      'Provide return details before dispatching items back to the vendor.',
                  saveButtonLabel: 'Save Return',
                  onSave: (data) async {
                    // Sync table columns from form
                    await TableSchemaService.syncTableColumnsFromForm('stock_return_form');
                    
                    data['id'] = _generatedReturnId;
                    if (data['date'] == null ||
                        data['date'].toString().trim().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    await context
                        .read<DashboardProvider>()
                        .saveStockReturn(data);
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

