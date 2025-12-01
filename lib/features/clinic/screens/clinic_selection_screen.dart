import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../controllers/clinic_form_controller.dart';
import '../providers/clinic_branches_provider.dart';
import '../providers/clinic_form_provider.dart';
import '../providers/clinic_workspace_provider.dart';
import '../providers/selected_clinic_provider.dart';
import '../services/clinic_service.dart';
import 'add_clinic_screen.dart';
import '../../workspace/screens/clinic_workspace_screen.dart';

class ClinicSelectionScreen extends StatefulWidget {
  const ClinicSelectionScreen({super.key});

  @override
  State<ClinicSelectionScreen> createState() => _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
  String? _selectedClinicId;
  late final ClinicService _clinicService;

  @override
  void initState() {
    super.initState();
    _clinicService = ClinicService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Clinic')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _clinicService.listenClinics(),
        builder: (context, snapshot) {
          final clinics = snapshot.data ?? const [];
          
          if (_selectedClinicId == null && clinics.isNotEmpty) {
            _selectedClinicId = clinics.first['id'] as String;
          }

          if (_selectedClinicId != null &&
              !clinics.any((c) => c['id'] == _selectedClinicId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _selectedClinicId = clinics.isNotEmpty ? clinics.first['id'] as String : null;
              });
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Super Admin',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select an existing clinic or create a new one.',
                  style: TextStyle(
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  value: _selectedClinicId,
                  decoration: const InputDecoration(
                    labelText: 'Select Clinic',
                    border: OutlineInputBorder(),
                  ),
                  items: clinics.map((clinic) {
                    return DropdownMenuItem<String>(
                      value: clinic['id'] as String,
                      child: Text(clinic['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClinicId = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _selectedClinicId == null
                            ? null
                            : () async {
                                final selected = clinics.firstWhere(
                                  (c) => c['id'] == _selectedClinicId,
                                );
                                final clinicId = selected['id'] as String;
                                final clinicName = selected['name'] as String;
                                
                                // Load clinic from Firestore
                                final provider = context
                                    .read<SelectedClinicProvider>();
                                
                                // Load from Firestore (all data should be in Firestore now)
                                await provider.loadClinicFromFirestore(clinicId);
                                
                                if (!mounted) return;
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MultiProvider(
                                      providers: [
                                        ChangeNotifierProvider(
                                          create: (_) =>
                                              ClinicWorkspaceProvider(),
                                        ),
                                        ChangeNotifierProvider(
                                          create: (_) =>
                                              ClinicBranchesProvider(),
                                        ),
                                      ],
                                      child: ClinicWorkspaceScreen(
                                        clinicId: clinicId,
                                        clinicName: clinicName,
                                      ),
                                    ),
                                  ),
                                );
                              },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Continue'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                    create: (_) => ClinicFormProvider(),
                                  ),
                                  ChangeNotifierProvider(
                                    create: (_) => ClinicFormController(),
                                  ),
                                ],
                                child: const AddClinicScreen(),
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Add New Clinic'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

