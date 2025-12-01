import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../controllers/clinic_form_controller.dart';
import '../../../shared/widgets/dynamic_form/dynamic_form_widget.dart';
import '../../form_builder/models/dynamic_form_models.dart';
import '../providers/clinic_form_provider.dart';

class AddClinicScreen extends StatefulWidget {
  const AddClinicScreen({super.key});

  @override
  State<AddClinicScreen> createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final List<List<String>> _stepSectionTitles = const [
    ['Basic Information'],
    ['Location'],
    ['Contact Information', 'Operational Settings'],
    ['Inventory Rules'],
    ['Procurement Settings'],
    ['Compliance & Documents'],
    ['System Access'],
  ];

  final Map<String, dynamic> _formData = {};
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicFormProvider>().loadDefinition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinicFormProvider = context.watch<ClinicFormProvider>();
    final controller = context.watch<ClinicFormController>();
    final definition = clinicFormProvider.definition;
    final isLoading =
        clinicFormProvider.isLoading || definition == null || definition.sections.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clinic'),
        backgroundColor: ShadTheme.of(context).colorScheme.card,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepperHeader(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DynamicFormWidget(
                          definition: _stepDefinition(definition),
                          onSave: (data) async {
                            try {
                            _formData.addAll(data);
                            controller.updateData(data);
                            if (_isLastStep) {
                                // Ensure all accumulated data from all steps is included
                                controller.updateData(_formData);
                              await controller.submit();
                              if (!mounted) return;
                              controller.reset();
                              Navigator.of(context).pop();
                            } else {
                              setState(() => _currentStep++);
                              }
                            } catch (e) {
                              // Validation error or other error - don't proceed
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                              rethrow; // Re-throw to prevent navigation
                            }
                          },
                          showCancelButton: false,
                          showActionButtons: true,
                          closeOnSave: false,
                          saveButtonLabel: _isLastStep ? 'Submit Clinic' : 'Next Step',
                          initialData: _formData,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            child: const Text('Back'),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                    if (controller.isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepperHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of ${_stepSectionTitles.length}',
          style: TextStyle(
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _stepTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  DynamicFormDefinition _stepDefinition(DynamicFormDefinition fullDefinition) {
    final allowedTitles = _stepSectionTitles[_currentStep];
    final filteredSections = fullDefinition.sections
        .where((section) => allowedTitles.contains(section.title))
        .toList();
    return fullDefinition.copyWith(sections: filteredSections);
  }

  String get _stepTitle {
    return _stepSectionTitles[_currentStep].join(' & ');
  }

  bool get _isLastStep => _currentStep == _stepSectionTitles.length - 1;
}

