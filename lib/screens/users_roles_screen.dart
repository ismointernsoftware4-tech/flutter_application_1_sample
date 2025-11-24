import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';
import 'roles_management_screen.dart';

class UsersRolesScreen extends StatefulWidget {
  const UsersRolesScreen({super.key});

  @override
  State<UsersRolesScreen> createState() => _UsersRolesScreenState();
}

class _UsersRolesScreenState extends State<UsersRolesScreen> {
  void _showRoleEditDialog(User user, DashboardProvider provider) {
    final roles = provider.rolesList;
    if (roles.isEmpty) {
      provider.loadRoles();
    }
    String selectedRole = roles.contains(user.role)
        ? user.role
        : (roles.isNotEmpty ? roles.first : user.role);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Role - ${user.name}'),
              content: roles.isEmpty
                  ? const Text('No roles available. Please add roles first.')
                  : DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Select Role',
                        border: OutlineInputBorder(),
                      ),
                      items: roles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: roles.isEmpty
                      ? null
                      : () async {
                          await provider.updateUserRole(user, selectedRole);
                          if (mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User role updated'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Load roles when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadRoles();
    });
  }

  String getInitial(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final firebaseService = provider.firebaseService;

    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Search
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 300,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Header Section with Title and Add New User Button
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User & Role Management',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage system users and access permissions.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.showAddUserFormDialog();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add New User Form Section
                        if (provider.showAddUserForm)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Add New User',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Form Fields in Two Columns
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Full Name',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              onChanged: (value) {
                                                provider.updateNewUserForm(fullName: value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter full name',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(color: Colors.blue),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Role',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey[300]!),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: DropdownButtonFormField<String>(
                                                value: provider.newUserForm.role.isEmpty || 
                                                       !provider.rolesList.contains(provider.newUserForm.role)
                                                    ? (provider.rolesList.isNotEmpty ? provider.rolesList.first : null)
                                                    : provider.newUserForm.role,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                ),
                                                items: provider.rolesList.map((role) {
                                                  return DropdownMenuItem(
                                                    value: role,
                                                    child: Text(role),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    provider.updateNewUserForm(role: value);
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Edit Roles Button
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.grey[200]!),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const RolesManagementScreen(),
                                                    ),
                                                  ).then((_) {
                                                    // Reload roles when coming back
                                                    provider.loadRoles();
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      size: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Right Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Email Address',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              onChanged: (value) {
                                                provider.updateNewUserForm(email: value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter email address',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(color: Colors.blue),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Password',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              obscureText: true,
                                              onChanged: (value) {
                                                provider.updateNewUserForm(password: value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter password',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(color: Colors.blue),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Status',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey[300]!),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: DropdownButtonFormField<String>(
                                                value: provider.newUserForm.status,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                ),
                                                items: const [
                                                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                                                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    provider.updateNewUserForm(status: value);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          provider.hideAddUserFormDialog();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          side: BorderSide(color: Colors.grey[300]!),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await provider.createUser();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('User created successfully'),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Create User',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // User List Table
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: StreamBuilder<List<User>>(
                              stream: firebaseService.getUsers(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        'Error loading users: ${snapshot.error}',
                                        style: TextStyle(color: Colors.red[600]),
                                      ),
                                    ),
                                  );
                                }

                                final users = snapshot.data ?? [];
                                
                                // Also show local users if Firebase is empty
                                final allUsers = users.isEmpty ? provider.usersList : users;

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                                      columnSpacing: 50,
                                      dataRowMinHeight: 56,
                                      dataRowMaxHeight: 56,
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'Name',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Email',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Role',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Status',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Last Login',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Actions',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: allUsers.map((user) {
                                    final index = allUsers.indexOf(user);
                                    return DataRow(
                                      color: MaterialStateProperty.all(
                                        index % 2 == 0 ? Colors.white : Colors.grey[50],
                                      ),
                                      cells: [
                                        // Name Column with Initial Badge
                                        DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                getInitial(user.name),
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            user.name,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                        // Email Column
                                        DataCell(
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                        // Role Column with Badge and Shield Icon
                                        DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.shield_outlined,
                                              size: 14,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              user.role,
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                        // Status Column
                                        DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          user.status,
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                        // Last Login Column
                                        DataCell(
                                      Text(
                                        user.lastLogin,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                        // Actions Column
                                        DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            color: Colors.grey[700],
                                            onPressed: () {
                                              _showRoleEditDialog(user, provider);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 18),
                                            color: Colors.red[600],
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (dialogContext) => AlertDialog(
                                                  title: const Text('Delete User'),
                                                  content: Text('Are you sure you want to delete ${user.name}?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(dialogContext),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await provider.deleteUser(user);
                                                        if (mounted) {
                                                          Navigator.pop(dialogContext);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('${user.name} deleted'),
                                                              duration: const Duration(seconds: 2),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        foregroundColor: Colors.white,
                                                      ),
                                                      child: const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                      ],
                                    );
                                  }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
