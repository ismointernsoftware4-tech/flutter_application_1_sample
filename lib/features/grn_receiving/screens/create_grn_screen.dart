import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateGRNScreen extends StatefulWidget {
  const CreateGRNScreen({super.key});

  @override
  State<CreateGRNScreen> createState() => _CreateGRNScreenState();
}

class _CreateGRNScreenState extends State<CreateGRNScreen> {
  late final FormBuilderProvider _provider;
  String _generatedGRNId = '';

  @override
  void initState() {
    super.initState();
    _generatedGRNId = _generateGRNId();
    _provider = FormBuilderProvider(formId: 'grn_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  String _generateGRNId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'GRN-$year-$month$day-$random';
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
                title: 'Create Goods Receipt Note',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Goods Receipt Note',
                  description:
                      'Fill in the details to create a new goods receipt note.',
                  saveButtonLabel: 'Create GRN',
                  onSave: (data) async {
                    data['grnId'] = _generatedGRNId;
                    data['status'] = 'Pending';
                    if (data['dateReceived'] == null ||
                        data['dateReceived'].toString().isEmpty) {
                      final now = DateTime.now();
                      data['dateReceived'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    await context.read<DashboardProvider>().saveGRN(data);
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

