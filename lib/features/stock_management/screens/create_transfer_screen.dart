import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateTransferScreen extends StatefulWidget {
  const CreateTransferScreen({super.key});

  @override
  State<CreateTransferScreen> createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen> {
  late final FormBuilderProvider _provider;
  String _generatedTransferId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'transfer_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
      _generatedTransferId = _generateTransferId();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _generateTransferId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TRF-$timestamp';
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

              if (_generatedTransferId.isEmpty) {
                _generatedTransferId = _generateTransferId();
              }

              return FormScreenLayout(
                title: 'New Internal Transfer',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Create Internal Transfer',
                  description:
                      'Fill in the details to move stock between locations.',
                  saveButtonLabel: 'Save Transfer',
                  onSave: (data) async {
                    // Sync table columns from form
                    await TableSchemaService.syncTableColumnsFromForm('transfer_form');
                    
                    data['id'] = _generatedTransferId;
                    if (data['date'] == null ||
                        data['date'].toString().trim().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    await context
                        .read<DashboardProvider>()
                        .saveInternalTransfer(data);
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

