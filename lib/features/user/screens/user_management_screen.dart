import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../providers/user_form_provider.dart';
import '../../clinic/providers/selected_clinic_provider.dart';
import '../controllers/user_form_controller.dart';
import 'add_user_screen_new.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    // Get the globally selected clinic from SelectedClinicProvider
    final clinicProvider = context.watch<SelectedClinicProvider>();
    final clinicId = clinicProvider.selectedClinicId;

    // Show loading or message if no clinic is selected
    if (clinicId == null || clinicId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please select a clinic to view users',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clinicProvider.clinic?.clinicName ?? 'Clinic: $clinicId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddUserDialog(context, clinicId),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _selectedBranchId == null
                    ? _userService.getAllUsers(clinicId)
                    : _userService.getUsersByBranch(clinicId, _selectedBranchId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No users found. Add your first user!'),
                    );
                  }

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(user.role),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(user.email),
                              Text('${user.role}${user.branchId != null ? ' • ${user.branchId}' : ''}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  user.status,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: user.isActive
                                    ? Colors.green[50]
                                    : Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: user.isActive
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditUserDialog(context, user);
                                  } else if (value == 'delete') {
                                    _deleteUser(context, user, clinicId);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'SYSTEM_ADMIN':
        return Colors.purple;
      case 'BRANCH_ADMIN':
        return Colors.blue;
      case 'END_USER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showAddUserDialog(BuildContext context, String clinicId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => UserFormProvider(clinicId: clinicId),
            ),
            ChangeNotifierProvider(
              create: (_) => UserFormController(clinicId: clinicId),
            ),
          ],
          child: AddUserScreenNew(clinicId: clinicId),
        ),
      ),
    );
    
    if (result != null && context.mounted) {
      // User was created successfully, the stream will automatically update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user functionality coming soon')),
    );
  }

  Future<void> _deleteUser(BuildContext context, UserModel user, String clinicId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _userService.deleteUser(clinicId, user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

