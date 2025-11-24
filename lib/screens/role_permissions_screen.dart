import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../constants/navigation_items.dart';

class RolePermissionsScreen extends StatefulWidget {
  final String roleName;

  const RolePermissionsScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<RolePermissionsScreen> createState() => _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, bool> _permissions = {};
  Map<String, String> _permissionLabels = {};
  bool _isLoading = true;

  // All sidebar navigation items
  final List<Map<String, dynamic>> _sidebarItems =
      NavigationItems.sidebarItems;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await _firebaseService.getRolePermissions(widget.roleName);
      setState(() {
        _permissions = Map.from(data.permissions);
        _permissionLabels = Map.from(data.labels);
        // Initialize all items to defaults if not found
        for (var item in _sidebarItems) {
          final title = item['title'] as String;
          _permissions.putIfAbsent(title, () => false);
          _permissionLabels.putIfAbsent(title, () => title);
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading permissions: $e');
      // Initialize all to false
      for (var item in _sidebarItems) {
        final title = item['title'] as String;
        _permissions[title] = false;
        _permissionLabels[title] = title;
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePermissions() async {
    try {
      await _firebaseService.saveRolePermissions(
        widget.roleName,
        _permissions,
        _permissionLabels,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editLabel(String key) {
    final controller =
        TextEditingController(text: _permissionLabels[key] ?? key);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename "$key"'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              setState(() {
                _permissionLabels[key] =
                    text.isEmpty ? key : text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissions for ${widget.roleName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Manage access permissions for this role',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _savePermissions,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save Permissions'),
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
              // Permissions List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
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
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _sidebarItems.length,
                            itemBuilder: (context, index) {
                              final item = _sidebarItems[index];
                              final title = item['title'] as String;
                              final icon = item['icon'] as IconData;
                              final hasPermission =
                                  _permissions[title] ?? false;
                              final displayName =
                                  _permissionLabels[title] ?? title;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      color: Colors.grey[700],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Checkbox(
                                      value: hasPermission,
                                      onChanged: (value) {
                                        setState(() {
                                          _permissions[title] = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _editLabel(title),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

