import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../shared/constants/permissions.dart';
import '../models/role_model.dart';
import '../services/role_service.dart';

enum RoleTemplate { clinicAdmin, branchAdmin, endUser, custom }

class CreateRoleScreen extends StatefulWidget {
  const CreateRoleScreen({
    super.key,
    required this.clinicId,
  });

  final String clinicId;

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roleNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final RoleService _roleService = RoleService();

  RoleTemplate _selectedTemplate = RoleTemplate.clinicAdmin;
  String _status = 'Active';
  final Set<String> _selectedPermissions = {...kClinicAdminRecommended};

  bool _isSaving = false;

  @override
  void dispose() {
    _roleNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyTemplate(RoleTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _selectedPermissions.clear();

      switch (template) {
        case RoleTemplate.clinicAdmin:
          _selectedPermissions.addAll(kClinicAdminRecommended);
          _roleNameController.text = 'Clinic Admin';
          break;
        case RoleTemplate.branchAdmin:
          _selectedPermissions.addAll(kBranchAdminRecommended);
          _roleNameController.text = 'Branch Admin';
          break;
        case RoleTemplate.endUser:
          _selectedPermissions.addAll(kEndUserRecommended);
          _roleNameController.text = 'End User';
          break;
        case RoleTemplate.custom:
          // Custom: clear role name and permissions, let user enter custom name
          _roleNameController.text = '';
          _selectedPermissions.clear();
          break;
      }
    });
  }

  Future<void> _showSummaryAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPermissions.isEmpty) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Please select at least one permission.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final roleName = _roleNameController.text.trim();
    final description = _descriptionController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Role'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role Name: $roleName'),
                const SizedBox(height: 4),
                Text('Status: $_status'),
                const SizedBox(height: 8),
                const Text(
                  'Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedPermissions
                      .map(
                        (p) => Chip(
                          label: Text(p),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm & Save'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _saveRole(roleName: roleName, description: description);
  }

  Future<void> _saveRole({
    required String roleName,
    required String description,
  }) async {
    if (!mounted) return;
    setState(() => _isSaving = true);
    
    try {
      final role = RoleModel(
        roleName: roleName,
        description: description,
        status: _status,
        permissions: _selectedPermissions.toList()..sort(),
      );

      await _roleService.createRole(
        clinicId: widget.clinicId,
        role: role,
      );

      if (!mounted) return;
      
      // Reset saving state before navigation
      setState(() => _isSaving = false);
      
      // Show success message
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Role "$roleName" created successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Small delay to ensure SnackBar is shown before navigation
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Failed to create role: ${e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Failed to create role: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      debugPrint('CreateRoleScreen build() called for clinicId: ${widget.clinicId}');
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Role'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                try {
                  final isWide = constraints.maxWidth > 900;
                  final sidePadding = isWide ? constraints.maxWidth * 0.1 : 16.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRoleHeader(),
                        const SizedBox(height: 16),
                        _buildRoleBasicsCard(),
                        const SizedBox(height: 16),
                        _buildPermissionsCard(isWide),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _showSummaryAndSave,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Save Role',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } catch (e, stackTrace) {
                  debugPrint('Error in LayoutBuilder: $e');
                  debugPrint('Stack trace: $stackTrace');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error building form: $e'),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error in CreateRoleScreen build(): $e');
      debugPrint('Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(title: const Text('Create Role')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading form: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildRoleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create New Role',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Define permissions for Clinic Admin, Branch Admin, End Users, or custom roles.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildRoleBasicsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<RoleTemplate>(
                value: _selectedTemplate,
                decoration: const InputDecoration(
                  labelText: 'Role Template',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: RoleTemplate.clinicAdmin,
                    child: Text('Clinic Admin'),
                  ),
                  DropdownMenuItem(
                    value: RoleTemplate.branchAdmin,
                    child: Text('Branch Admin'),
                  ),
                  DropdownMenuItem(
                    value: RoleTemplate.endUser,
                    child: Text('End User'),
                  ),
                  DropdownMenuItem(
                    value: RoleTemplate.custom,
                    child: Text('Custom Role'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _applyTemplate(value);
                  }
                },
              ),
            ),
            SizedBox(
              width: 260,
              child: TextFormField(
                controller: _roleNameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Role name is required';
                  }
                  final lower = value.trim().toLowerCase();
                  if (lower == 'super admin' || lower == 'superadmin') {
                    return 'Super Admin cannot be created here';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Inactive',
                    child: Text('Inactive'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
            ),
            SizedBox(
              width: 600,
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Role Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(bool isWide) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Select all actions this role is allowed to perform. '
              'Templates pre-select recommended permissions, but you can override.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: kPermissionGroups.entries.map((entry) {
                final groupName = entry.key;
                final perms = entry.value;

                final allSelected =
                    perms.every((p) => _selectedPermissions.contains(p));
                final anySelected =
                    perms.any((p) => _selectedPermissions.contains(p));

                return SizedBox(
                  width: isWide ? 280 : double.infinity,
                  child: _buildPermissionGroupCard(
                    groupName: groupName,
                    permissions: perms,
                    allSelected: allSelected,
                    anySelected: anySelected,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionGroupCard({
    required String groupName,
    required List<String> permissions,
    required bool allSelected,
    required bool anySelected,
  }) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: Checkbox(
          value: allSelected,
          tristate: anySelected && !allSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedPermissions.addAll(permissions);
              } else {
                _selectedPermissions.removeAll(permissions);
              }
            });
          },
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: permissions.map((perm) {
          final isChecked = _selectedPermissions.contains(perm);
          return CheckboxListTile(
            value: isChecked,
            title: Text(perm),
            dense: true,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedPermissions.add(perm);
                } else {
                  _selectedPermissions.remove(perm);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}

