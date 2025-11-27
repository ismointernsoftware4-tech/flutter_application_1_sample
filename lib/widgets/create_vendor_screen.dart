import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/procurement_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';
import '../utils/responsive_helper.dart';

class CreateVendorScreen extends StatefulWidget {
  const CreateVendorScreen({super.key});

  @override
  State<CreateVendorScreen> createState() => _CreateVendorScreenState();
}

class _CreateVendorScreenState extends State<CreateVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _complianceDocsController = TextEditingController();

  String? _selectedCategory = 'Pharmaceuticals';
  String? _selectedPaymentTerms = 'Net 30';

  final List<String> _categories = [
    'Medical Supplies',
    'Pharmaceuticals',
    'Consumables',
    'Equipment',
  ];

  final List<String> _paymentTerms = [
    'Net 30',
    'Net 15',
    'Net 45',
    'Net 60',
    'Due on Receipt',
    'Cash on Delivery',
  ];

  @override
  void dispose() {
    _vendorNameController.dispose();
    _taxIdController.dispose();
    _websiteController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _complianceDocsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(context),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: _formCard(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          if (isMobile || isTablet)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open menu',
            ),
          Expanded(
            child: Text(
              'Add New Vendor',
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ProcurementProvider>().closeCreateForm();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            '← Back to List',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.02),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a new vendor to the system',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _companyInformationSection(context),
          const SizedBox(height: 32),
          _contactPersonSection(context),
          const SizedBox(height: 32),
          _financialComplianceSection(context),
          const SizedBox(height: 32),
          _actionButtons(context),
        ],
      ),
    );
  }

  Widget _companyInformationSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Company Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _vendorNameController,
                    label: 'Vendor Name *',
                    hint: 'Company Name',
                    required: true,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dropdown(
                    label: 'Vendor Category *',
                    value: _selectedCategory,
                    items: _categories,
                    hint: 'Select Category',
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    required: true,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _taxIdController,
                    label: 'Tax ID / GSTIN',
                    hint: 'Tax Identification Number',
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _websiteController,
                    label: 'Website',
                    hint: 'https://...',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _contactPersonSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Contact Person',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _contactNameController,
                    label: 'Contact Name *',
                    hint: 'Full Name',
                    required: true,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _emailController,
                    label: 'Email Address *',
                    hint: 'email@company.com',
                    keyboardType: TextInputType.emailAddress,
                    required: true,
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _phoneController,
                    label: 'Phone Number *',
                    hint: '+1 (555) 000-0000',
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                ),
                SizedBox(
                  width: isWide ? constraints.maxWidth : constraints.maxWidth,
                  child: _textArea(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'Full Address',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _financialComplianceSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Financial & Compliance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    hint: 'Bank Name',
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _textField(
                    controller: _accountNumberController,
                    label: 'Account Number',
                    hint: 'Account Number',
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _dropdown(
                    label: 'Payment Terms',
                    value: _selectedPaymentTerms,
                    items: _paymentTerms,
                    hint: 'Select Payment Terms',
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentTerms = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                  child: _fileUploadField(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: required
              ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _textArea({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String? hint,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: required
              ? (value) => value == null || value.isEmpty ? 'Required' : null
              : null,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _fileUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compliance Documents',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // TODO: Implement file picker
            setState(() {
              _complianceDocsController.text = 'Files Selected';
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 32,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  _complianceDocsController.text.isEmpty
                      ? 'Upload Tax Certs, Licenses, etc.'
                      : _complianceDocsController.text,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            context.read<ProcurementProvider>().closeCreateForm();
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _submit(context),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Vendor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final dashboardProvider = context.read<DashboardProvider>();
      
      // Create vendor using dashboard provider
      final vendor = Vendor(
        name: _vendorNameController.text.trim(),
        category: _selectedCategory ?? 'Medical Supplies',
        contactName: _contactNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        status: 'Pending',
      );

      // Add vendor through provider
      dashboardProvider.addVendor(vendor);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.read<ProcurementProvider>().closeCreateForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving vendor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

