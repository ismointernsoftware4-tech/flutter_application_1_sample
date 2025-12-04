import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateInternalConsumptionScreen extends StatefulWidget {
  const CreateInternalConsumptionScreen({super.key});

  @override
  State<CreateInternalConsumptionScreen> createState() =>
      _CreateInternalConsumptionScreenState();
}

class _CreateInternalConsumptionScreenState
    extends State<CreateInternalConsumptionScreen> {
  late final FormBuilderProvider _provider;
  String _generatedRecordId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'internal_consumption_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
      _generatedRecordId = _generateRecordId();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _generateRecordId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'CON-$timestamp';
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

              if (_generatedRecordId.isEmpty) {
                _generatedRecordId = _generateRecordId();
              }

              return FormScreenLayout(
                title: 'Department Consumption',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Record Internal Consumption',
                  description:
                      'Document how internal departments are using inventory.',
                  saveButtonLabel: 'Save Consumption',
                  onSave: (data) async {
                    // Sync table columns from form
                    await TableSchemaService.syncTableColumnsFromForm('internal_consumption_form');
                    
                    data['id'] = _generatedRecordId;
                    if (data['date'] == null ||
                        data['date'].toString().trim().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    await context
                        .read<DashboardProvider>()
                        .saveInternalConsumption(data);
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

