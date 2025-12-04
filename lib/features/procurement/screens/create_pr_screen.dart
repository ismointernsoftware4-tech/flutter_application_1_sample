import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreatePRScreen extends StatefulWidget {
  const CreatePRScreen({super.key});

  @override
  State<CreatePRScreen> createState() => _CreatePRScreenState();
}

class _CreatePRScreenState extends State<CreatePRScreen> {
  late final FormBuilderProvider _provider;
  String _generatedPRId = '';

  @override
  void initState() {
    super.initState();
    _generatedPRId = _generatePRId();
    _provider = FormBuilderProvider(formId: 'pr_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  String _generatePRId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'PR-$year-$month$day-$random';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: SafeArea(
        child: Consumer<FormBuilderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.definition == null) {
                return Center(
                  child: CircularProgressIndicator()
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(0.8, 0.8),
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    ),
                );
              }

              return FormScreenLayout(
                title: 'Create Purchase Requisition',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Purchase Requisition',
                  description:
                      'Fill in the details to create a new purchase requisition.',
                  saveButtonLabel: 'Create PR',
                  onSave: (data) async {
                    data['id'] = _generatedPRId;
                    data['status'] = 'Pending Approval';
                    if (data['date'] == null || data['date'].toString().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    await context.read<DashboardProvider>().savePR(data);
                    
                    // Sync table columns with mandatory form fields
                    await TableSchemaService.syncTableColumnsFromForm('pr_form');
                    
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0);
            },
          ),
        ),
    );
  }

}

