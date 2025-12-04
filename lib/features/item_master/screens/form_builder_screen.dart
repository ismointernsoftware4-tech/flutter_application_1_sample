import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/form_builder_provider.dart';
import '../../../shared/services/table_schema_service.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/utils/animated_routes.dart';
import '../../../shared/widgets/form_builder_widget.dart';
import 'add_item_screen.dart';
import '../../procurement/screens/create_pr_screen.dart';
import '../../grn_receiving/screens/create_grn_screen.dart';
import '../../storage_locations/screens/create_location_screen.dart';
import '../../stock_management/screens/create_audit_screen.dart';
import '../../stock_management/screens/create_transfer_screen.dart';
import '../../stock_management/screens/create_branch_transfer_screen.dart';
import '../../stock_management/screens/create_stock_return_screen.dart';
import '../../stock_management/screens/create_internal_consumption_screen.dart';
import '../../stock_management/screens/stock_adjustment_screen.dart';
import '../../vendor_management/screens/create_vendor_screen.dart';
import '../../procurement/screens/create_po_screen.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({
    super.key,
    this.formType = 'item_master',
  });

  final String formType; // 'item_master' or 'pr_form'

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  late final FormBuilderProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FormBuilderProvider(formId: widget.formType);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadDefinition();
    });
  }

  String get _formId => widget.formType;
  String get _title {
    switch (_formId) {
      case 'pr_form':
        return 'PR Form Template';
      case 'grn_form':
        return 'GRN Form Template';
      case 'storage_location_form':
        return 'Storage Location Form Template';
      case 'audit_form':
        return 'Audit Form Template';
      case 'transfer_form':
        return 'Transfer Form Template';
      case 'branch_transfer_form':
        return 'Branch Transfer Form Template';
      case 'stock_return_form':
        return 'Stock Return Form Template';
      case 'stock_adjustment_form':
        return 'Stock Adjustment Form Template';
      case 'internal_consumption_form':
        return 'Internal Consumption Form Template';
      case 'vendor_form':
        return 'Vendor Form Template';
      case 'po_form':
        return 'PO Form Template';
      case 'item_master':
      default:
        return 'Item Form Template';
    }
  }

  String get _description {
    switch (_formId) {
      case 'pr_form':
        return 'Arrange sections and fields that will appear on the Create PR screen.';
      case 'grn_form':
        return 'Arrange sections and fields that will appear on the Create GRN screen.';
      case 'storage_location_form':
        return 'Arrange sections and fields that will appear on the Create Location screen.';
      case 'audit_form':
        return 'Arrange sections and fields that will appear on the Create Audit screen.';
      case 'transfer_form':
        return 'Arrange sections and fields that will appear on the Create Transfer screen.';
      case 'branch_transfer_form':
        return 'Arrange sections and fields that will appear on the Create Branch Transfer screen.';
      case 'stock_return_form':
        return 'Arrange sections and fields that will appear on the Create Stock Return screen.';
      case 'stock_adjustment_form':
        return 'Arrange sections and fields that will appear on the Stock Adjustment screen.';
      case 'internal_consumption_form':
        return 'Arrange sections and fields that will appear on the Record Consumption screen.';
      case 'vendor_form':
        return 'Arrange sections and fields that will appear on the Add Vendor screen.';
      case 'po_form':
        return 'Arrange sections and fields that will appear on the Create PO screen.';
      case 'item_master':
      default:
        return 'Arrange sections and fields that will appear on the Add Item screen.';
    }
  }

  String get _headerTitle {
    switch (_formId) {
      case 'pr_form':
        return 'Add New PR Template';
      case 'grn_form':
        return 'Add New GRN Template';
      case 'storage_location_form':
        return 'Add New Location Template';
      case 'audit_form':
        return 'Add New Audit Template';
      case 'transfer_form':
        return 'Add New Transfer Template';
      case 'branch_transfer_form':
        return 'Add New Branch Transfer Template';
      case 'stock_return_form':
        return 'Add New Stock Return Template';
      case 'stock_adjustment_form':
        return 'Add New Stock Adjustment Template';
      case 'internal_consumption_form':
        return 'Record Internal Consumption Template';
      case 'vendor_form':
        return 'Add New Vendor Template';
      case 'po_form':
        return 'Add New PO Template';
      case 'item_master':
      default:
        return 'Add New Item Template';
    }
  }

  Widget _getFormScreen() {
    switch (_formId) {
      case 'pr_form':
        return const CreatePRScreen();
      case 'grn_form':
        return const CreateGRNScreen();
      case 'storage_location_form':
        return const CreateLocationScreen();
      case 'audit_form':
        return const CreateAuditScreen();
      case 'transfer_form':
        return const CreateTransferScreen();
      case 'branch_transfer_form':
        return const CreateBranchTransferScreen();
      case 'stock_return_form':
        return const CreateStockReturnScreen();
      case 'stock_adjustment_form':
        return const StockAdjustmentScreen();
      case 'internal_consumption_form':
        return const CreateInternalConsumptionScreen();
      case 'vendor_form':
        return const CreateVendorScreen();
      case 'po_form':
        return const CreatePOScreen();
      case 'item_master':
      default:
        return const AddItemScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF4F6FB);
    return ChangeNotifierProvider.value(
      value: _provider,
      child: SafeArea(
        child: Consumer<FormBuilderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.definition == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final isMobile = ResponsiveHelper.isMobile(context);
              final horizontalPadding = isMobile ? 16.0 : 32.0;
              final verticalPadding = isMobile ? 16.0 : 32.0;

              return Column(
                children: [
                  _BuilderHeader(
                    title: _headerTitle,
                    isMobile: isMobile,
                    horizontalPadding: horizontalPadding,
                    onViewForm: () async {
                      await provider.saveDefinition();
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        AnimatedRoutes.slideRight(_getFormScreen()),
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: FormBuilderWidget(
                        provider: provider,
                        title: _title,
                        description: _description,
                        onSaveAndView: () async {
                          await provider.saveDefinition();
                          if (!context.mounted) return;
                          await Navigator.of(context).push(
                            AnimatedRoutes.slideRight(_getFormScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    );
  }
}

class _BuilderHeader extends StatelessWidget {
  const _BuilderHeader({
    required this.title,
    required this.onViewForm,
    required this.isMobile,
    required this.horizontalPadding,
  });

  final String title;
  final VoidCallback onViewForm;
  final bool isMobile;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: isMobile ? 12 : 16,
    );
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);

    final searchField = SizedBox(
      width: isMobile ? double.infinity : searchWidth,
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, size: 18),
          filled: true,
          fillColor: Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );

    final viewButton = TextButton.icon(
      onPressed: onViewForm,
      icon: const Icon(Icons.visibility),
      label: const Text('View Form'),
    );

    final backButton = TextButton.icon(
      onPressed: () => Navigator.of(context).maybePop(),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Back to List'),
    );

    if (isMobile) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backButton,
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            searchField,
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: viewButton,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          backButton,
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          searchField,
          const SizedBox(width: 16),
          viewButton,
        ],
      ),
    );
  }
}


