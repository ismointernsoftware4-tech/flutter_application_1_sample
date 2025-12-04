import 'package:flutter/foundation.dart' show debugPrint;

import '../models/column_config.dart';
import '../models/dynamic_form_models.dart';
import 'firebase_service.dart';
import 'schema_service.dart';

class TableSchemaService {
  final String tableType; // 'pr', 'po', 'vendor', etc.
  
  TableSchemaService(this.tableType);

  Future<List<ColumnConfig>> loadColumns() async {
    // Try to load from Firebase first
    try {
      final firebaseService = FirebaseService();
      final tableSchemaId = '${tableType}_table_schema';
      final firebaseData = await firebaseService.fetchFormDefinition(tableSchemaId);
      if (firebaseData != null && firebaseData['columns'] != null) {
        final columns = (firebaseData['columns'] as List<dynamic>)
            .map((e) => ColumnConfig.fromMap(e as Map<String, dynamic>))
            .toList();
        if (columns.isNotEmpty) {
          return columns;
        }
      }
    } catch (e) {
      debugPrint('Error loading table columns from Firebase: $e');
    }
    
    // Fallback to default columns if Firebase doesn't have it
    return defaultColumns;
  }

  Future<void> saveColumns(List<ColumnConfig> columns) async {
    // Save to Firebase instead of local file
    try {
      final firebaseService = FirebaseService();
      final tableSchemaId = '${tableType}_table_schema';
      await firebaseService.saveFormDefinition(
        tableSchemaId,
        {
          'columns': columns.map((c) => c.toMap()).toList(),
        },
      );
    } catch (e) {
      debugPrint('Error saving table columns to Firebase: $e');
    }
  }

  List<ColumnConfig> get defaultColumns {
    switch (tableType) {
      case 'pr':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'PR ID',
            description: 'Purchase Requisition ID',
          ),
          ColumnConfig(
            key: 'requestedBy',
            label: 'Requested By',
            description: 'Person who requested',
          ),
          ColumnConfig(
            key: 'department',
            label: 'Department',
            description: 'Requesting department',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Request date',
          ),
          ColumnConfig(
            key: 'priority',
            label: 'Priority',
            description: 'Request priority',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current status',
          ),
        ];
      case 'po':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'PO ID',
            description: 'Purchase Order ID',
          ),
          ColumnConfig(
            key: 'vendor',
            label: 'Vendor',
            description: 'Vendor name',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Order date',
          ),
          ColumnConfig(
            key: 'amount',
            label: 'Amount',
            description: 'Order amount',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current status',
          ),
        ];
      case 'vendor':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'Vendor ID',
            description: 'Vendor identifier',
          ),
          ColumnConfig(
            key: 'name',
            label: 'Name',
            description: 'Vendor name',
          ),
          ColumnConfig(
            key: 'category',
            label: 'Category',
            description: 'Vendor category',
          ),
          ColumnConfig(
            key: 'contactName',
            label: 'Contact Name',
            description: 'Primary contact',
          ),
          ColumnConfig(
            key: 'email',
            label: 'Email',
            description: 'Contact email',
          ),
          ColumnConfig(
            key: 'phone',
            label: 'Phone',
            description: 'Contact phone',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Vendor status',
          ),
        ];
      case 'grn':
        return const [
          ColumnConfig(
            key: 'grnId',
            label: 'GRN ID',
            description: 'Goods Receipt ID',
          ),
          ColumnConfig(
            key: 'poReference',
            label: 'PO Reference',
            description: 'Related purchase order',
          ),
          ColumnConfig(
            key: 'vendor',
            label: 'Vendor',
            description: 'Vendor name',
          ),
          ColumnConfig(
            key: 'dateReceived',
            label: 'Date Received',
            description: 'When goods were received',
          ),
          ColumnConfig(
            key: 'receivedBy',
            label: 'Received By',
            description: 'Person who received the goods',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current GRN status',
          ),
        ];
      case 'storage_location':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'ID',
            description: 'Location identifier',
          ),
          ColumnConfig(
            key: 'name',
            label: 'Name',
            description: 'Location name',
          ),
          ColumnConfig(
            key: 'type',
            label: 'Type',
            description: 'Location type',
          ),
          ColumnConfig(
            key: 'parentLocation',
            label: 'Parent Location',
            description: 'Parent location',
          ),
          ColumnConfig(
            key: 'capacity',
            label: 'Capacity',
            description: 'Storage capacity',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current status',
          ),
          ColumnConfig(
            key: 'manager',
            label: 'Manager',
            description: 'Location manager',
          ),
        ];
      case 'stock_audit':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'Audit ID',
            description: 'Stock audit identifier',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Audit date',
          ),
          ColumnConfig(
            key: 'type',
            label: 'Type',
            description: 'Audit type',
          ),
          ColumnConfig(
            key: 'auditor',
            label: 'Auditor',
            description: 'Person conducting audit',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current status',
          ),
          ColumnConfig(
            key: 'discrepancies',
            label: 'Discrepancies',
            description: 'Number of discrepancies found',
          ),
        ];
      case 'internal_transfer':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'Transfer ID',
            description: 'Internal transfer identifier',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Transfer date',
          ),
          ColumnConfig(
            key: 'fromLocation',
            label: 'From',
            description: 'Source location',
          ),
          ColumnConfig(
            key: 'toLocation',
            label: 'To',
            description: 'Destination location',
          ),
          ColumnConfig(
            key: 'quantity',
            label: 'Items Qty',
            description: 'Total quantity transferred',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current transfer status',
          ),
        ];
      case 'branch_transfer':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'Transfer ID',
            description: 'Branch transfer identifier',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Transfer date',
          ),
          ColumnConfig(
            key: 'sourceBranch',
            label: 'Source Branch',
            description: 'Source branch name',
          ),
          ColumnConfig(
            key: 'destinationBranch',
            label: 'Dest Branch',
            description: 'Destination branch name',
          ),
          ColumnConfig(
            key: 'quantity',
            label: 'Items Qty',
            description: 'Total quantity transferred',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current transfer status',
          ),
        ];
      case 'stock_return':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'Return ID',
            description: 'Stock return identifier',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Return date',
          ),
          ColumnConfig(
            key: 'vendor',
            label: 'Vendor',
            description: 'Vendor name',
          ),
          ColumnConfig(
            key: 'item',
            label: 'Item',
            description: 'Item name',
          ),
          ColumnConfig(
            key: 'quantity',
            label: 'Qty',
            description: 'Return quantity',
          ),
          ColumnConfig(
            key: 'reason',
            label: 'Reason',
            description: 'Return reason',
          ),
          ColumnConfig(
            key: 'status',
            label: 'Status',
            description: 'Current return status',
          ),
        ];
      case 'internal_consumption':
        return const [
          ColumnConfig(
            key: 'id',
            label: 'ID',
            description: 'Consumption record identifier',
          ),
          ColumnConfig(
            key: 'date',
            label: 'Date',
            description: 'Consumption date',
          ),
          ColumnConfig(
            key: 'department',
            label: 'Department',
            description: 'Department name',
          ),
          ColumnConfig(
            key: 'item',
            label: 'Item',
            description: 'Item name',
          ),
          ColumnConfig(
            key: 'quantity',
            label: 'Qty',
            description: 'Consumption quantity',
          ),
          ColumnConfig(
            key: 'purpose',
            label: 'Purpose',
            description: 'Consumption purpose',
          ),
          ColumnConfig(
            key: 'user',
            label: 'User',
            description: 'User who recorded consumption',
          ),
        ];
      default:
        return [];
    }
  }


  /// Syncs table columns with mandatory fields from the form schema
  /// This ensures table columns automatically match required form fields
  static Future<void> syncTableColumnsFromForm(String formType) async {
    try {
      // Map form type to table type
      String tableType = formType.replaceAll('_form', '');
      // Special mapping for transfer_form -> internal_transfer
      if (formType == 'transfer_form') {
        tableType = 'internal_transfer';
      }
      // Special mapping for branch_transfer_form -> branch_transfer
      if (formType == 'branch_transfer_form') {
        tableType = 'branch_transfer';
      }
      // Special mapping for stock_return_form -> stock_return
      if (formType == 'stock_return_form') {
        tableType = 'stock_return';
      }
      // Special mapping for internal_consumption_form -> internal_consumption
      if (formType == 'internal_consumption_form') {
        tableType = 'internal_consumption';
      }
      
      // Load form definition
      final formDefinition = await SchemaService.loadSchema(formType);
      if (formDefinition == null) {
        debugPrint('No form definition found for $formType');
        return;
      }

      // Extract mandatory fields from form
      final mandatoryFields = <DynamicFormField>[];
      for (final section in formDefinition.sections) {
        for (final field in section.fields) {
          if (field.required) {
            mandatoryFields.add(field);
          }
        }
      }

      // Convert mandatory fields to column configs
      final columns = mandatoryFields.map((field) {
        return ColumnConfig(
          key: field.key,
          label: field.label,
          description: field.hint.isNotEmpty ? field.hint : field.label,
          visible: true,
        );
      }).toList();

      // Add system fields (id, status) if they don't exist
      final existingKeys = columns.map((c) => c.key).toSet();
      if (!existingKeys.contains('id')) {
        String idLabel = 'ID';
        if (formType == 'pr_form') idLabel = 'PR ID';
        else if (formType == 'po_form') idLabel = 'PO ID';
        else if (formType == 'grn_form') idLabel = 'GRN ID';
        else if (formType == 'storage_location_form') idLabel = 'ID';
        else if (formType == 'audit_form') idLabel = 'Audit ID';
        else if (formType == 'transfer_form') idLabel = 'Transfer ID';
        else if (formType == 'branch_transfer_form') idLabel = 'Transfer ID';
        else if (formType == 'stock_return_form') idLabel = 'Return ID';
        else if (formType == 'internal_consumption_form') idLabel = 'ID';
        
        columns.insert(0, ColumnConfig(
          key: 'id',
          label: idLabel,
          description: 'System generated identifier',
          visible: true,
        ));
      }
      if (!existingKeys.contains('status')) {
        columns.add(ColumnConfig(
          key: 'status',
          label: 'Status',
          description: 'Current status',
          visible: true,
        ));
      }

      // Save to table schema
      final tableService = TableSchemaService(tableType);
      await tableService.saveColumns(columns);

      debugPrint('Table columns synced with form mandatory fields for $formType');
    } catch (e) {
      debugPrint('Error syncing table columns: $e');
    }
  }
}

