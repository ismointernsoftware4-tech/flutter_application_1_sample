import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';
import '../services/firebase_service.dart';
import '../services/table_schema_service.dart';

class FormBuilderProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  DynamicFormDefinition? _definition;
  bool _isLoading = false;
  bool _isSaving = false;
  int _version = 0;
  final String _formId;

  FormBuilderProvider({String formId = 'item_master'}) : _formId = formId;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  int get version => _version;
  DynamicFormDefinition? get definition => _definition;
  List<DynamicFormSection> get sections => _definition?.sections ?? [];

  List<FormFieldTemplate> get availableTemplates {
    final assignedKeys = <String>{
      for (final section in sections)
        for (final field in section.fields)
          if (!field.isCustom) field.key,
    };
    return kFormFieldCatalog
        .where((template) => !assignedKeys.contains(template.key))
        .toList();
  }

  Future<void> loadDefinition() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      // Try Firebase first for all forms (using /clinics/CLN-0004/forms/{formId})
      final firebaseData = await _firebaseService.fetchFormDefinition(_formId);
      if (firebaseData != null) {
        _definition = DynamicFormDefinition.fromMap(firebaseData);
        _version++;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // If Firebase doesn't have the form, use default
      _definition = _getDefaultDefinition();
      // Optionally save default to Firebase for future use
      // await _firebaseService.saveFormDefinition(_formId, _definition!.toMap());
      _version++;
    } catch (e) {
      debugPrint('Error loading form definition: $e');
      _definition = _getDefaultDefinition();
      // No longer saving to local JSON - Firebase only
      _version++;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DynamicFormDefinition _getDefaultDefinition() {
    if (_formId == 'pr_form') {
      // Return default PR schema
      return DynamicFormDefinition(
        id: 'pr_form',
        name: 'Purchase Requisition Form',
        sections: [
          DynamicFormSection(
            id: 'basic',
            title: 'BASIC INFORMATION',
            fields: [
              DynamicFormField(
                id: 'basic_requestedBy',
                key: 'requestedBy',
                label: 'Requested By',
                hint: 'Enter requester name',
                type: DynamicFieldType.text,
                options: [],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_department',
                key: 'department',
                label: 'Department',
                hint: 'Select department',
                type: DynamicFieldType.dropdown,
                options: ['IVF Lab', 'Pharmacy', 'Administration', 'Finance', 'Operations'],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_priority',
                key: 'priority',
                label: 'Priority',
                hint: 'Select priority level',
                type: DynamicFieldType.dropdown,
                options: ['Routine', 'Urgent', 'High', 'Low'],
                required: true,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'grn_form') {
      // Return default GRN schema
      return DynamicFormDefinition(
        id: 'grn_form',
        name: 'Goods Receipt Note Form',
        sections: [
          DynamicFormSection(
            id: 'basic',
            title: 'BASIC INFORMATION',
            fields: [
              DynamicFormField(
                id: 'basic_poReference',
                key: 'poReference',
                label: 'PO Reference',
                hint: 'Select Purchase Order',
                type: DynamicFieldType.dropdown,
                options: [],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_vendor',
                key: 'vendor',
                label: 'Vendor',
                hint: 'Enter vendor name',
                type: DynamicFieldType.text,
                options: [],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_dateReceived',
                key: 'dateReceived',
                label: 'Date Received',
                hint: 'Select date',
                type: DynamicFieldType.text,
                options: [],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_receivedBy',
                key: 'receivedBy',
                label: 'Received By',
                hint: 'Enter name of person who received',
                type: DynamicFieldType.text,
                options: [],
                required: true,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'storage_location_form') {
      // Return default Storage Location schema
      return DynamicFormDefinition(
        id: 'storage_location_form',
        name: 'Storage Location Form',
        sections: [
          DynamicFormSection(
            id: 'basic',
            title: 'BASIC INFORMATION',
            fields: [
              DynamicFormField(
                id: 'basic_name',
                key: 'name',
                label: 'Location Name',
                hint: 'e.g. Main Warehouse',
                type: DynamicFieldType.text,
                options: [],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_type',
                key: 'type',
                label: 'Location Type',
                hint: 'Select location type',
                type: DynamicFieldType.dropdown,
                options: ['Warehouse', 'Room', 'Rack', 'Shelf', 'Bin', 'Cabinet'],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_parentLocation',
                key: 'parentLocation',
                label: 'Parent Location',
                hint: 'Select parent location (optional)',
                type: DynamicFieldType.dropdown,
                options: [],
                required: false,
              ),
              DynamicFormField(
                id: 'basic_status',
                key: 'status',
                label: 'Status',
                hint: 'Select status',
                type: DynamicFieldType.dropdown,
                options: ['Active', 'Inactive', 'Empty'],
                required: true,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'audit_form') {
      // Return default Audit schema
      return DynamicFormDefinition(
        id: 'audit_form',
        name: 'Stock Audit Form',
        sections: [
          DynamicFormSection(
            id: 'overview',
            title: 'AUDIT OVERVIEW',
            fields: [
              DynamicFormField(
                id: 'overview_type',
                key: 'type',
                label: 'Audit Type',
                hint: 'Select audit methodology',
                type: DynamicFieldType.dropdown,
                options: ['Systemic', 'Random', 'Cycle Count', 'Spot Check'],
                required: true,
              ),
              DynamicFormField(
                id: 'overview_date',
                key: 'date',
                label: 'Audit Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'overview_auditor',
                key: 'auditor',
                label: 'Lead Auditor',
                hint: 'Enter lead auditor name',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'overview_status',
                key: 'status',
                label: 'Audit Status',
                hint: 'Select current status',
                type: DynamicFieldType.dropdown,
                options: ['Scheduled', 'In Progress', 'Pending Approval', 'Completed'],
                required: true,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'coverage',
            title: 'SCOPE & COVERAGE',
            fields: [
              DynamicFormField(
                id: 'coverage_locations',
                key: 'locationsCovered',
                label: 'Locations Covered',
                hint: 'E.g. Main Store, Pharmacy',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'coverage_items',
                key: 'itemsReviewed',
                label: 'Key Items Reviewed',
                hint: 'List critical SKUs',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'coverage_discrepancies',
                key: 'discrepancies',
                label: 'Discrepancies Found',
                hint: 'Numeric value',
                type: DynamicFieldType.number,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'notes',
            title: 'NOTES & ACTIONS',
            fields: [
              DynamicFormField(
                id: 'notes_findings',
                key: 'findingsSummary',
                label: 'Findings Summary',
                hint: 'Summarize observations',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'notes_actions',
                key: 'actionsRequired',
                label: 'Actions Required',
                hint: 'List corrective actions',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'transfer_form') {
      return DynamicFormDefinition(
        id: 'transfer_form',
        name: 'Internal Transfer Form',
        sections: [
          DynamicFormSection(
            id: 'details',
            title: 'TRANSFER DETAILS',
            fields: [
              DynamicFormField(
                id: 'details_type',
                key: 'transferType',
                label: 'Transfer Type',
                hint: 'Select transfer type',
                type: DynamicFieldType.dropdown,
                options: ['Internal', 'Branch', 'Emergency'],
                required: true,
              ),
              DynamicFormField(
                id: 'details_date',
                key: 'date',
                label: 'Transfer Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_requestedBy',
                key: 'requestedBy',
                label: 'Requested By',
                hint: 'Enter requester name',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_priority',
                key: 'priority',
                label: 'Priority',
                hint: 'Select priority',
                type: DynamicFieldType.dropdown,
                options: ['Routine', 'High', 'Urgent'],
              ),
            ],
          ),
          DynamicFormSection(
            id: 'locations',
            title: 'SOURCE & DESTINATION',
            fields: [
              DynamicFormField(
                id: 'locations_from',
                key: 'fromLocation',
                label: 'From Location',
                hint: 'Origin store/room',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'locations_to',
                key: 'toLocation',
                label: 'To Location',
                hint: 'Destination store/room',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'locations_items',
                key: 'itemsDescription',
                label: 'Items Description',
                hint: 'List items being transferred',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'locations_qty',
                key: 'quantity',
                label: 'Total Quantity',
                hint: 'Enter total units',
                type: DynamicFieldType.number,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'notes',
            title: 'NOTES & APPROVAL',
            fields: [
              DynamicFormField(
                id: 'notes_reason',
                key: 'reason',
                label: 'Reason',
                hint: 'Provide transfer justification',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'notes_approver',
                key: 'approver',
                label: 'Approver',
                hint: 'Enter approving manager',
                type: DynamicFieldType.text,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'branch_transfer_form') {
      return DynamicFormDefinition(
        id: 'branch_transfer_form',
        name: 'Branch Transfer Form',
        sections: [
          DynamicFormSection(
            id: 'details',
            title: 'TRANSFER DETAILS',
            fields: [
              DynamicFormField(
                id: 'details_type',
                key: 'transferType',
                label: 'Transfer Type',
                hint: 'Select transfer type',
                type: DynamicFieldType.dropdown,
                options: ['Inter-Branch', 'Emergency Fulfillment', 'Backorder'],
                required: true,
              ),
              DynamicFormField(
                id: 'details_date',
                key: 'date',
                label: 'Transfer Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_requestedBy',
                key: 'requestedBy',
                label: 'Requested By',
                hint: 'Enter requester name',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_priority',
                key: 'priority',
                label: 'Priority',
                hint: 'Select priority',
                type: DynamicFieldType.dropdown,
                options: ['Routine', 'High', 'Urgent'],
              ),
            ],
          ),
          DynamicFormSection(
            id: 'branches',
            title: 'BRANCHES & ITEMS',
            fields: [
              DynamicFormField(
                id: 'branches_source',
                key: 'sourceBranch',
                label: 'Source Branch',
                hint: 'From which branch?',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'branches_destination',
                key: 'destinationBranch',
                label: 'Destination Branch',
                hint: 'To which branch?',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'branches_items',
                key: 'itemsDescription',
                label: 'Items Description',
                hint: 'List key items being transferred',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'branches_quantity',
                key: 'quantity',
                label: 'Total Quantity',
                hint: 'Enter total units',
                type: DynamicFieldType.number,
                required: true,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'logistics',
            title: 'LOGISTICS & NOTES',
            fields: [
              DynamicFormField(
                id: 'logistics_courier',
                key: 'courierDetails',
                label: 'Courier / Transport Details',
                hint: 'Provide vehicle or courier info',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'logistics_eta',
                key: 'eta',
                label: 'Estimated Arrival',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'logistics_notes',
                key: 'notes',
                label: 'Notes',
                hint: 'Additional remarks',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'stock_return_form') {
      return DynamicFormDefinition(
        id: 'stock_return_form',
        name: 'Stock Return Form',
        sections: [
          DynamicFormSection(
            id: 'details',
            title: 'RETURN DETAILS',
            fields: [
              DynamicFormField(
                id: 'details_returnType',
                key: 'returnType',
                label: 'Return Type',
                hint: 'Select reason',
                type: DynamicFieldType.dropdown,
                options: ['Damaged', 'Expired', 'Incorrect Delivery', 'Recall'],
                required: true,
              ),
              DynamicFormField(
                id: 'details_date',
                key: 'date',
                label: 'Return Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_vendor',
                key: 'vendor',
                label: 'Vendor',
                hint: 'Enter vendor name',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_reference',
                key: 'reference',
                label: 'Reference #',
                hint: 'PO or invoice reference',
                type: DynamicFieldType.text,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'items',
            title: 'ITEMS & QUANTITIES',
            fields: [
              DynamicFormField(
                id: 'items_name',
                key: 'item',
                label: 'Item Name',
                hint: 'Enter the item being returned',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'items_batch',
                key: 'batchNo',
                label: 'Batch / Lot Number',
                hint: 'Enter batch or lot',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'items_quantity',
                key: 'quantity',
                label: 'Quantity',
                hint: 'Enter units to return',
                type: DynamicFieldType.number,
                required: true,
              ),
              DynamicFormField(
                id: 'items_reason',
                key: 'reason',
                label: 'Reason Details',
                hint: 'Provide explanation',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'logistics',
            title: 'LOGISTICS & NOTES',
            fields: [
              DynamicFormField(
                id: 'logistics_pickup',
                key: 'pickupMethod',
                label: 'Pickup / Courier Method',
                hint: 'E.g. Vendor pickup, Courier',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'logistics_eta',
                key: 'eta',
                label: 'Expected Pickup Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'logistics_notes',
                key: 'notes',
                label: 'Additional Notes',
                hint: 'Any extra remarks',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'internal_consumption_form') {
      return DynamicFormDefinition(
        id: 'internal_consumption_form',
        name: 'Internal Consumption Form',
        sections: [
          DynamicFormSection(
            id: 'details',
            title: 'CONSUMPTION DETAILS',
            fields: [
              DynamicFormField(
                id: 'details_department',
                key: 'department',
                label: 'Department',
                hint: 'Select consuming department',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_date',
                key: 'date',
                label: 'Consumption Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'details_requestedBy',
                key: 'requestedBy',
                label: 'Requested By',
                hint: 'Enter requester name',
                type: DynamicFieldType.text,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'items',
            title: 'ITEM INFORMATION',
            fields: [
              DynamicFormField(
                id: 'items_item',
                key: 'item',
                label: 'Item Name',
                hint: 'Enter consumed item',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'items_batch',
                key: 'batchNo',
                label: 'Batch Number',
                hint: 'Optional batch number',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'items_quantity',
                key: 'quantity',
                label: 'Quantity',
                hint: 'Units consumed',
                type: DynamicFieldType.number,
                required: true,
              ),
              DynamicFormField(
                id: 'items_unit',
                key: 'unit',
                label: 'Unit',
                hint: 'e.g. Boxes, Units',
                type: DynamicFieldType.text,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'purpose',
            title: 'PURPOSE & NOTES',
            fields: [
              DynamicFormField(
                id: 'purpose_usage',
                key: 'purpose',
                label: 'Purpose',
                hint: 'Why was the item consumed?',
                type: DynamicFieldType.textarea,
                required: true,
              ),
              DynamicFormField(
                id: 'purpose_user',
                key: 'user',
                label: 'User',
                hint: 'Person responsible',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'purpose_notes',
                key: 'notes',
                label: 'Additional Notes',
                hint: 'Any other context',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'stock_adjustment_form') {
      return DynamicFormDefinition(
        id: 'stock_adjustment_form',
        name: 'Stock Adjustment Form',
        sections: [
          DynamicFormSection(
            id: 'overview',
            title: 'ADJUSTMENT OVERVIEW',
            fields: [
              DynamicFormField(
                id: 'overview_type',
                key: 'adjustmentType',
                label: 'Adjustment Type',
                hint: 'Select adjustment reason',
                type: DynamicFieldType.dropdown,
                options: [
                  'Damage / Breakage',
                  'Expiry Write-off',
                  'Inventory Gain',
                  'Cycle Count Correction',
                ],
                required: true,
              ),
              DynamicFormField(
                id: 'overview_date',
                key: 'date',
                label: 'Date',
                hint: 'YYYY-MM-DD',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'overview_requestedBy',
                key: 'requestedBy',
                label: 'Requested By',
                hint: 'Enter requester name',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'overview_status',
                key: 'status',
                label: 'Status',
                hint: 'Select status',
                type: DynamicFieldType.dropdown,
                options: ['Draft', 'Pending Approval', 'Approved', 'Rejected'],
              ),
            ],
          ),
          DynamicFormSection(
            id: 'items',
            title: 'ITEMS TO ADJUST',
            fields: [
              DynamicFormField(
                id: 'items_item',
                key: 'item',
                label: 'Item',
                hint: 'Select item to adjust',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'items_currentStock',
                key: 'currentStock',
                label: 'Current Stock',
                hint: 'Current on-hand stock',
                type: DynamicFieldType.number,
              ),
              DynamicFormField(
                id: 'items_adjustQty',
                key: 'adjustQty',
                label: 'Adjust Qty (+/-)',
                hint: 'Enter quantity adjustment',
                type: DynamicFieldType.number,
                required: true,
              ),
              DynamicFormField(
                id: 'items_unit',
                key: 'unit',
                label: 'Unit',
                hint: 'Units (e.g. boxes)',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'items_specificReason',
                key: 'specificReason',
                label: 'Specific Reason',
                hint: 'Detailed note for this item',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'remarks',
            title: 'REMARKS & APPROVAL',
            fields: [
              DynamicFormField(
                id: 'remarks_general',
                key: 'remarks',
                label: 'General Remarks',
                hint: 'Explanation for adjustment...',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'remarks_approver',
                key: 'approver',
                label: 'Approver',
                hint: 'Manager approving adjustment',
                type: DynamicFieldType.text,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'vendor_form') {
      return DynamicFormDefinition(
        id: 'vendor_form',
        name: 'Vendor Registration Form',
        sections: [
          DynamicFormSection(
            id: 'company',
            title: 'COMPANY DETAILS',
            fields: [
              DynamicFormField(
                id: 'company_name',
                key: 'vendorName',
                label: 'Vendor Name',
                hint: 'Enter legal company name',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'company_category',
                key: 'category',
                label: 'Category',
                hint: 'e.g. Medical Supplies',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'company_taxId',
                key: 'taxId',
                label: 'Tax ID',
                hint: 'Enter GST/PAN/VAT number',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'company_website',
                key: 'website',
                label: 'Website',
                hint: 'https://example.com',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'company_phone',
                key: 'phone',
                label: 'Phone',
                hint: '+91 98765 43210',
                type: DynamicFieldType.text,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'contact',
            title: 'PRIMARY CONTACT',
            fields: [
              DynamicFormField(
                id: 'contact_name',
                key: 'contactName',
                label: 'Contact Name',
                hint: 'Primary contact person',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'contact_email',
                key: 'contactEmail',
                label: 'Contact Email',
                hint: 'contact@example.com',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'contact_phone',
                key: 'contactPhone',
                label: 'Contact Phone',
                hint: 'Contact mobile number',
                type: DynamicFieldType.text,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'address',
            title: 'ADDRESS & PAYMENT',
            fields: [
              DynamicFormField(
                id: 'address_full',
                key: 'address',
                label: 'Address',
                hint: 'Full address with city/state',
                type: DynamicFieldType.textarea,
                required: true,
              ),
              DynamicFormField(
                id: 'address_terms',
                key: 'paymentTerms',
                label: 'Payment Terms',
                hint: 'e.g. Net 30',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'address_bankName',
                key: 'bankName',
                label: 'Bank Name',
                hint: 'Bank for payouts',
                type: DynamicFieldType.text,
              ),
              DynamicFormField(
                id: 'address_accountNumber',
                key: 'accountNumber',
                label: 'Account Number',
                hint: '*********1234',
                type: DynamicFieldType.text,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'compliance',
            title: 'COMPLIANCE & NOTES',
            fields: [
              DynamicFormField(
                id: 'compliance_docs',
                key: 'complianceDocs',
                label: 'Compliance Documents',
                hint: 'License / Certifications',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'compliance_notes',
                key: 'notes',
                label: 'Notes',
                hint: 'Any additional remarks',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
        ],
      );
    }
    if (_formId == 'po_form') {
      // Return default PO schema
      return DynamicFormDefinition(
        id: 'po_form',
        name: 'Purchase Order Form',
        sections: [
          DynamicFormSection(
            id: 'basic',
            title: 'BASIC INFORMATION',
            fields: [
              DynamicFormField(
                id: 'basic_vendor',
                key: 'vendor',
                label: 'Vendor',
                hint: 'Select vendor',
                type: DynamicFieldType.dropdown,
                options: [],
                required: true,
              ),
              DynamicFormField(
                id: 'basic_date',
                key: 'date',
                label: 'Order Date',
                hint: 'Select date',
                type: DynamicFieldType.text,
                required: true,
              ),
              DynamicFormField(
                id: 'basic_amount',
                key: 'amount',
                label: 'Total Amount',
                hint: 'Enter total amount',
                type: DynamicFieldType.number,
                required: true,
              ),
              DynamicFormField(
                id: 'basic_status',
                key: 'status',
                label: 'Status',
                hint: 'Select status',
                type: DynamicFieldType.dropdown,
                options: ['Draft', 'Issued', 'Pending', 'Approved', 'Cancelled'],
                required: true,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'items',
            title: 'ORDER ITEMS',
            fields: [
              DynamicFormField(
                id: 'items_description',
                key: 'itemsDescription',
                label: 'Items Description',
                hint: 'Describe the items ordered',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'items_quantity',
                key: 'quantity',
                label: 'Quantity',
                hint: 'Enter quantity',
                type: DynamicFieldType.number,
              ),
            ],
          ),
          DynamicFormSection(
            id: 'notes',
            title: 'NOTES & TERMS',
            fields: [
              DynamicFormField(
                id: 'notes_terms',
                key: 'terms',
                label: 'Terms & Conditions',
                hint: 'Enter terms and conditions',
                type: DynamicFieldType.textarea,
              ),
              DynamicFormField(
                id: 'notes_additional',
                key: 'additionalNotes',
                label: 'Additional Notes',
                hint: 'Any additional information',
                type: DynamicFieldType.textarea,
              ),
            ],
          ),
        ],
      );
    }
    // Default item master schema
    return defaultDynamicFormDefinition();
  }

  void _updateDefinition(List<DynamicFormSection> updatedSections) {
    if (_definition == null) return;
    _definition = _definition!.copyWith(sections: updatedSections);
    _version++;
    notifyListeners();
  }

  void addSection() {
    if (_definition == null) return;
    final newSection = DynamicFormSection(
      id: UniqueKey().toString(),
      title: 'New Section',
      fields: const [],
    );
    final updated = [...sections, newSection];
    _updateDefinition(updated);
  }

  void removeSection(String sectionId) {
    if (_definition == null) return;
    final updated = sections.where((section) => section.id != sectionId).toList();
    if (updated.isEmpty) return;
    _updateDefinition(updated);
  }

  void updateSectionTitle(String sectionId, String title) {
    if (_definition == null) return;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        return section.copyWith(title: title);
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  void addFieldToSection(String sectionId, FormFieldTemplate template) {
    if (_definition == null) return;
    final fieldKey = template.key.isEmpty
        ? 'custom_${DateTime.now().microsecondsSinceEpoch}'
        : template.key;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        final newField = DynamicFormField(
          id: UniqueKey().toString(),
          key: fieldKey,
          label: template.label.isEmpty ? 'Custom Field' : template.label,
          hint: template.hint,
          type: template.type,
          options: template.options,
          required: template.required,
          isCustom: !template.isSystemField,
          extra: template.extra,
        );
        return section.copyWith(fields: [...section.fields, newField]);
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  void addCustomField(String sectionId) {
    addFieldToSection(
      sectionId,
      const FormFieldTemplate(
        key: '',
        label: 'Custom Field',
        isSystemField: false,
      ),
    );
  }

  void removeField(String sectionId, String fieldId) {
    if (_definition == null) return;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        return section.copyWith(
          fields: section.fields.where((field) => field.id != fieldId).toList(),
        );
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  void updateFieldLabel(String sectionId, String fieldId, String label) {
    _mutateField(sectionId, fieldId, (field) => field.copyWith(label: label));
  }

  void updateFieldHint(String sectionId, String fieldId, String hint) {
    _mutateField(sectionId, fieldId, (field) => field.copyWith(hint: hint));
  }

  void updateFieldRequired(String sectionId, String fieldId, bool value) {
    _mutateField(sectionId, fieldId, (field) => field.copyWith(required: value));
  }

  void updateFieldType(String sectionId, String fieldId, DynamicFieldType type) {
    _mutateField(
      sectionId,
      fieldId,
      (field) => field.copyWith(
        type: type,
        options: type == DynamicFieldType.dropdown ||
                type == DynamicFieldType.checkboxList
            ? (field.options.isEmpty ? ['Option 1', 'Option 2'] : field.options)
            : const [],
      ),
    );
  }

  void updateFieldOptions(
    String sectionId,
    String fieldId,
    List<String> options,
  ) {
    _mutateField(sectionId, fieldId, (field) => field.copyWith(options: options));
  }

  void _mutateField(
    String sectionId,
    String fieldId,
    DynamicFormField Function(DynamicFormField field) transformer,
  ) {
    if (_definition == null) return;
    final updated = sections.map((section) {
      if (section.id == sectionId) {
        final newFields = section.fields.map((field) {
          if (field.id == fieldId) {
            return transformer(field);
          }
          return field;
        }).toList();
        return section.copyWith(fields: newFields);
      }
      return section;
    }).toList();
    _updateDefinition(updated);
  }

  Future<bool> saveDefinition() async {
    if (_definition == null || _isSaving) return false;
    // Skip mandatory field validation for Firebase-loaded forms
    // Firebase forms are the source of truth and may have different field structures
    // Only validate manually built forms (not loaded from Firebase)
    if (_formId == 'item_master' && _definition!.id != 'form_add_item') {
      // Only validate if it's not a Firebase form
      final allKeys = <String>{
        for (final section in sections) for (final field in section.fields) field.key,
      };
      final missingRequired = kMandatoryFieldKeys.difference(allKeys);
      if (missingRequired.isNotEmpty) {
        throw Exception(
          'Please include required fields: ${missingRequired.join(', ')}',
        );
      }
    }
    _isSaving = true;
    notifyListeners();
    try {
      await _firebaseService.saveFormDefinition(_formId, _definition!.toMap());
      
      // Sync table columns with mandatory form fields for forms that have tables
      final formsWithTables = ['pr_form', 'po_form', 'grn_form', 'vendor_form'];
      if (formsWithTables.contains(_formId)) {
        await TableSchemaService.syncTableColumnsFromForm(_formId);
      }
      
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

