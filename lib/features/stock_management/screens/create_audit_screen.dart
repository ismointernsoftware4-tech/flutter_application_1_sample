import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateAuditScreen extends StatefulWidget {
  const CreateAuditScreen({super.key});

  @override
  State<CreateAuditScreen> createState() => _CreateAuditScreenState();
}

class _CreateAuditScreenState extends State<CreateAuditScreen> {
  late final FormBuilderProvider _provider;
  String _generatedAuditId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'audit_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
      _generatedAuditId = _generateAuditId();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _generateAuditId() {
    final timestamp = DateTime.now();
    return 'AUD-${timestamp.millisecondsSinceEpoch}';
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

              if (_generatedAuditId.isEmpty) {
                _generatedAuditId = _generateAuditId();
              }

              return FormScreenLayout(
                title: 'Create Stock Audit',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Start Stock Audit',
                  description:
                      'Fill in the audit details and coverage information below.',
                  saveButtonLabel: 'Save Audit',
                  onSave: (data) async {
                    data['id'] = _generatedAuditId;
                    data['status'] =
                        (data['status'] as String?)?.trim().isEmpty ?? true
                            ? 'Scheduled'
                            : data['status'];
                    if (data['date'] == null ||
                        data['date'].toString().trim().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    try {
                      // Sync table columns from form
                      await TableSchemaService.syncTableColumnsFromForm('audit_form');
                      
                      // Save audit
                      await context.read<DashboardProvider>().saveAudit(data);
                      
                      if (!mounted) return;
                      
                      // Close loading dialog
                      Navigator.of(context).pop();
                      
                      // Navigate back - just pop the current route
                      Navigator.of(context).pop();
                      
                      // Show success message after a short delay
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stock audit created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating audit: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

