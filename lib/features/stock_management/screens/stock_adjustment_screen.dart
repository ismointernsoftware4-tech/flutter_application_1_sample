import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  late final FormBuilderProvider _provider;
  String _generatedAdjustmentId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'stock_adjustment_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
      _generatedAdjustmentId = _generateAdjustmentId();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _generateAdjustmentId() {
    return 'ADJ-${DateTime.now().millisecondsSinceEpoch}';
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

              if (_generatedAdjustmentId.isEmpty) {
                _generatedAdjustmentId = _generateAdjustmentId();
              }

              return FormScreenLayout(
                title: 'Stock Adjustment',
                showDefaultSearch: false,
                trailing: _configureButton(context),
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Stock Adjustment',
                  description:
                      'Submit adjustment requests for damaged, expired, or gained inventory.',
                  saveButtonLabel: 'Submit Adjustment',
                  onSave: (data) async {
                    data['id'] = _generatedAdjustmentId;
                    if (data['date'] == null ||
                        data['date'].toString().trim().isEmpty) {
                      final now = DateTime.now();
                      data['date'] =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    }
                    data['status'] =
                        data['status'] as String? ?? 'Pending Approval';

                    try {
                      await context
                          .read<DashboardProvider>()
                          .saveStockAdjustment(data);

                      if (!mounted) return;
                      final navigator = Navigator.of(context);
                      if (navigator.canPop()) {
                        navigator.pop(); // Go back to previous screen only
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Stock adjustment saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Error saving stock adjustment: $e'),
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

  Widget _configureButton(BuildContext context) {
    // Form builder UI removed; stock adjustment form is now fixed/dynamic only
    return const SizedBox.shrink();
  }
}

