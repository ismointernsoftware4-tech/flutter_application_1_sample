import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/widgets/dynamic_form_widget.dart';
import '../../../shared/widgets/form_screen_layout.dart';

class CreateLocationScreen extends StatefulWidget {
  const CreateLocationScreen({super.key});

  @override
  State<CreateLocationScreen> createState() => _CreateLocationScreenState();
}

class _CreateLocationScreenState extends State<CreateLocationScreen> {
  late final FormBuilderProvider _provider;
  String _generatedLocationId = '';

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: 'storage_location_form');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  void _generateLocationId(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final nextNumber = dashboardProvider.storageLocations.length + 1;
    _generatedLocationId = 'LOC${nextNumber.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
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

              // Generate location ID when form is ready
              if (_generatedLocationId.isEmpty) {
                _generateLocationId(context);
              }

              return FormScreenLayout(
                title: 'Create Storage Location',
                body: DynamicFormWidget(
                  definition: provider.definition!,
                  title: 'Storage Location',
                  description:
                      'Fill in the details to create a new storage location.',
                  saveButtonLabel: 'Create Location',
                  onSave: (data) async {
                    if (_generatedLocationId.isEmpty) {
                      _generateLocationId(context);
                    }
                    data['id'] = _generatedLocationId;
                    if (data['capacity'] != null) {
                      final capacityStr = data['capacity'].toString();
                      data['capacity'] = int.tryParse(capacityStr) ?? 0;
                    } else {
                      data['capacity'] = 0;
                    }
                    data['manager'] = data['manager'] ?? '';
                    data['description'] = data['description'] ?? '';
                    
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
                      await TableSchemaService.syncTableColumnsFromForm('storage_location_form');
                      
                      // Save location
                      await context.read<DashboardProvider>().addStorageLocation(
                        name: data['name'] as String? ?? '',
                        type: data['type'] as String? ?? '',
                        parentLocation: data['parentLocation'] as String? ?? '',
                        capacity: data['capacity'] as int? ?? 0,
                        status: data['status'] as String? ?? 'Active',
                        manager: data['manager'] as String? ?? '',
                        description: data['description'] as String? ?? '',
                      );
                      
                      if (!mounted) return;
                      
                      // Close loading dialog
                      Navigator.of(context).pop();
                      
                      // Navigate back - just pop the current route (CreateLocationScreen)
                      Navigator.of(context).pop();
                      
                      // Show success message after a short delay
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Storage location created successfully'),
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
                          content: Text('Error creating location: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

