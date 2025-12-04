import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreatePOScreen extends StatefulWidget {
  const CreatePOScreen({super.key});

  @override
  State<CreatePOScreen> createState() => _CreatePOScreenState();
}

class _CreatePOScreenState extends State<CreatePOScreen> {
  late final FormBuilderProvider _provider;
  String _generatedPOId = '';

  @override
  void initState() {
    super.initState();
    _generatedPOId = _generatePOId();
    _provider = FormBuilderProvider(formId: 'po_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  String _generatePOId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'PO-$year-$month$day-$random';
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
                title: 'Create Purchase Order',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Purchase Order',
                  description:
                      'Fill in the details to create a new purchase order.',
                  saveButtonLabel: 'Create PO',
                  onSave: (data) async {
                    data['id'] = _generatedPOId;
                    if (data['status'] == null || data['status'].toString().isEmpty) {
                      data['status'] = 'Draft';
                    }
                    if (data['date'] == null || data['date'].toString().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    // Format amount with currency symbol if it's a number
                    if (data['amount'] != null) {
                      final amountValue = data['amount'];
                      if (amountValue is num) {
                        final formatted = amountValue.toStringAsFixed(2).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        );
                        data['amount'] = '\$$formatted';
                      }
                    }
                    await context.read<DashboardProvider>().savePO(data);
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

