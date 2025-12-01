import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../controllers/user_form_controller.dart';
import '../../clinic/providers/selected_clinic_provider.dart';
import '../../role/services/role_service.dart';
import '../../role/models/role_model.dart';
import '../../branch/services/branch_service.dart';
import '../../branch/models/branch_model.dart';
import '../../clinic/models/clinic_summary_info.dart';

class AddUserScreenNew extends StatefulWidget {
  const AddUserScreenNew({super.key, required this.clinicId});

  final String clinicId;

  @override
  State<AddUserScreenNew> createState() => _AddUserScreenNewState();
}

class _AddUserScreenNewState extends State<AddUserScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final RoleService _roleService = RoleService();
  final BranchService _branchService = BranchService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  // State variables
  String? _selectedClinicId;
  String? _selectedBranchId;
  String? _selectedRoleName;
  String _selectedStatus = 'Active';
  File? _profilePhoto;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  
  // Dropdown data
  List<ClinicSummaryInfo> _availableClinics = [];
  List<BranchModel> _availableBranches = [];
  List<String> _availableRoles = [];
  Map<String, RoleModel> _roleDetails = {};
  bool _isLoadingClinics = false;
  bool _isLoadingBranches = false;
  bool _isLoadingRoles = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClinics();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    setState(() => _isLoadingClinics = true);
    try {
      final snapshot = await _firestore.collection('clinics').get();
      _availableClinics = snapshot.docs.map((doc) {
        final data = doc.data();
        return ClinicSummaryInfo(
          id: doc.id,
          name: data['clinicName'] as String? ?? doc.id,
        );
      }).toList();
      
      final clinicProvider = context.read<SelectedClinicProvider>();
      final globalClinicId = clinicProvider.selectedClinicId;
      _selectedClinicId = globalClinicId ?? widget.clinicId;
      
      if (_selectedClinicId != null && _selectedClinicId!.isNotEmpty) {
        _loadBranches(_selectedClinicId!);
        _loadRoles();
      }
    } catch (e) {
      debugPrint('Error loading clinics: $e');
    } finally {
      setState(() => _isLoadingClinics = false);
    }
  }

  Future<void> _loadBranches(String clinicId) async {
    if (clinicId.isEmpty) return;
    
    setState(() => _isLoadingBranches = true);
    try {
      final branchesStream = _branchService.getAllBranches(clinicId);
      await for (final branches in branchesStream) {
        if (mounted) {
          final activeBranches = branches.where((b) => b.status == 'Active').toList();
          setState(() {
            _availableBranches = activeBranches;
            _isLoadingBranches = false;
          });
          break;
        }
      }
    } catch (e) {
      debugPrint('Error loading branches: $e');
      setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _loadRoles() async {
    final clinicId = _selectedClinicId ?? widget.clinicId;
    if (clinicId.isEmpty) return;
    
    setState(() => _isLoadingRoles = true);
    try {
      final roles = await _roleService.getRoleNames(clinicId);
      final uniqueRoles = roles.toSet().toList()..sort();
      
      // Load role details for tooltips
      final roleDetailsMap = <String, RoleModel>{};
      for (final roleName in uniqueRoles) {
        try {
          final role = await _roleService.getRoleByName(
            clinicId: clinicId,
            roleName: roleName,
          );
          if (role != null) {
            roleDetailsMap[roleName] = role;
          }
        } catch (e) {
          debugPrint('Error loading role details for $roleName: $e');
        }
      }
      
      setState(() {
        _availableRoles = uniqueRoles;
        _roleDetails = roleDetailsMap;
        _isLoadingRoles = false;
      });
    } catch (e) {
      debugPrint('Error loading roles: $e');
      setState(() => _isLoadingRoles = false);
    }
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _profilePhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _generateUsername() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    
    if (name.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name or email first')),
      );
      return;
    }
    
    String username = '';
    if (name.isNotEmpty) {
      username = name.toLowerCase().replaceAll(' ', '.');
    } else if (email.isNotEmpty) {
      username = email.split('@').first;
    }
    
    // Add random suffix
    username = '${username}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    setState(() {
      _usernameController.text = username;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClinicId == null || _selectedClinicId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clinic')),
      );
      return;
    }

    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a branch')),
      );
      return;
    }

    if (_selectedRoleName == null || _selectedRoleName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = context.read<UserFormController>();
      
      // Upload profile photo if selected
      // TODO: Implement file upload to Firebase Storage
      // String? profilePhotoUrl;
      // if (_profilePhoto != null) {
      //   profilePhotoUrl = await _uploadProfilePhoto(_profilePhoto!);
      // }

      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'username': _usernameController.text.trim().isEmpty 
            ? null 
            : _usernameController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRoleName,
        'clinicId': _selectedClinicId,
        'branchId': _selectedBranchId,
        'status': _selectedStatus,
        // if (profilePhotoUrl != null) 'profilePhoto': profilePhotoUrl,
      };

      controller.updateData(userData);
      final uid = await controller.submit();
      
      if (!mounted) return;
      
      if (uid.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        controller.reset();
        Navigator.of(context).pop(uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getRoleTooltip(String roleName) {
      final role = _roleDetails[roleName];
      if (role != null) {
        if (role.description.isNotEmpty) {
          return role.description;
        }
      }
    
    // Default descriptions
    switch (roleName.toUpperCase()) {
      case 'SYSTEM_ADMIN':
        return 'Full system access with all permissions';
      case 'BRANCH_ADMIN':
        return 'Administrative access to assigned branch';
      case 'CLINIC_ADMIN':
        return 'Administrative access to assigned clinic';
      case 'END_USER':
        return 'Standard user with limited permissions';
      default:
        return 'User role with assigned permissions';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'User Registration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new user account for the inventory management system',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Section 1: Clinic & Branch
                _buildSectionCard(
                  title: 'Clinic & Branch',
                  subtitle: 'Select the clinic and branch for this user',
                  child: Column(
                    children: [
                      _buildDropdownField(
                        label: 'Clinic',
                        value: _selectedClinicId,
                        items: _availableClinics
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        isLoading: _isLoadingClinics,
                        onChanged: (value) {
                          setState(() {
                            _selectedClinicId = value;
                            _selectedBranchId = null;
                            _availableBranches = [];
                          });
                          if (value != null) {
                            _loadBranches(value);
                            _loadRoles();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        label: 'Branch',
                        value: _selectedBranchId,
                        items: _availableBranches
                            .map((b) => DropdownMenuItem(
                                  value: b.branchId,
                                  child: Text(
                                    b.branchName.isNotEmpty
                                        ? '${b.branchName} (${b.branchId})'
                                        : b.branchId,
                                  ),
                                ))
                            .toList(),
                        isLoading: _isLoadingBranches,
                        onChanged: (value) {
                          setState(() => _selectedBranchId = value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 2: Role
                _buildSectionCard(
                  title: 'Role',
                  subtitle: 'Assign a role to define user permissions',
                  child: _buildDropdownField(
                    label: 'Role',
                    value: _selectedRoleName,
                    items: _availableRoles
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Row(
                                children: [
                                  Expanded(child: Text(role)),
                                  Tooltip(
                                    message: _getRoleTooltip(role),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    isLoading: _isLoadingRoles,
                    onChanged: (value) {
                      setState(() => _selectedRoleName = value);
                    },
                    tooltip: _selectedRoleName != null
                        ? _getRoleTooltip(_selectedRoleName!)
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                // Section 2.5: Status
                _buildSectionCard(
                  title: 'Status',
                  subtitle: 'Set the user account status',
                  child: _buildDropdownField(
                    label: 'Status',
                    value: _selectedStatus,
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
                    isLoading: false,
                    onChanged: (value) {
                      setState(() => _selectedStatus = value ?? 'Active');
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Section 3: User Information
                _buildSectionCard(
                  title: 'User Information',
                  subtitle: 'Enter the user\'s personal and account details',
                  child: Column(
                    children: [
                      // Full Name
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        required: true,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Phone Number
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        required: true,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Username with Generate button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _usernameController,
                              label: 'Username',
                              required: false,
                              icon: Icons.alternate_email,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: OutlinedButton.icon(
                              onPressed: _generateUsername,
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('Generate'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'Password',
                        required: true,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Photo Upload
                      _buildProfilePhotoUpload(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(120, 48),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitForm,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.person_add),
                      label: Text(_isSubmitting ? 'Creating...' : 'Create User'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(160, 48),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool isLoading = false,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red),
            ),
            if (tooltip != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: tooltip,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: isLoading
              ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Loading...'),
                    enabled: false,
                  ),
                ]
              : items.isEmpty
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No options available'),
                        enabled: false,
                      ),
                    ]
                  : items,
          onChanged: isLoading ? null : onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required bool required,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Photo Preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _profilePhoto != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _profilePhoto!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.grey[400],
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickProfilePhoto,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        if (_profilePhoto != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() => _profilePhoto = null);
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Remove Photo'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
