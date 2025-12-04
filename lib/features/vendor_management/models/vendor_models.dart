class Vendor {
  final String id;
  final String name;
  final String category;
  final String contactName;
  final String email;
  final String phone;
  final String status;
  final String address;
  final String paymentTerms;
  final String notes;

  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.status,
    this.address = '',
    this.paymentTerms = '',
    this.notes = '',
  });
}

class VendorFilter {
  static const _unset = Object();

  final String? status;
  final String? category;
  final String? searchQuery;

  const VendorFilter({this.status, this.category, this.searchQuery});

  VendorFilter copyWith({
    Object? status = _unset,
    Object? category = _unset,
    Object? searchQuery = _unset,
  }) {
    return VendorFilter(
      status: status == _unset ? this.status : status as String?,
      category: category == _unset ? this.category : category as String?,
      searchQuery:
          searchQuery == _unset ? this.searchQuery : searchQuery as String?,
    );
  }

  bool matches(Vendor vendor) {
    final statusOk = status == null || vendor.status == status;
    final categoryOk = category == null || vendor.category == category;
    final searchOk =
        searchQuery == null ||
        vendor.name.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        vendor.category.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        vendor.contactName.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && categoryOk && searchOk;
  }

  bool matchesMap(Map<String, dynamic> vendor) {
    final vendorStatus = (vendor['status'] ?? '').toString();
    final vendorCategory = (vendor['category'] ?? '').toString();
    final vendorName = (vendor['name'] ?? '').toString().toLowerCase();
    final vendorContactName = (vendor['contactName'] ?? '').toString().toLowerCase();
    
    final statusOk = status == null || vendorStatus == status;
    final categoryOk = category == null || vendorCategory == category;
    final searchOk =
        searchQuery == null ||
        searchQuery!.isEmpty ||
        vendorName.contains(searchQuery!.toLowerCase()) ||
        vendorCategory.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        vendorContactName.contains(searchQuery!.toLowerCase());
    return statusOk && categoryOk && searchOk;
  }
}

enum VendorFieldType { text, dropdown, textarea }

class VendorFormField {
  final String id;
  String label;
  VendorFieldType type;
  bool required;
  List<String> options;

  VendorFormField({
    required this.id,
    required this.label,
    this.type = VendorFieldType.text,
    this.required = false,
    List<String>? options,
  }) : options = options ?? const [];

  VendorFormField copyWith({
    String? id,
    String? label,
    VendorFieldType? type,
    bool? required,
    List<String>? options,
  }) {
    return VendorFormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      options: options ?? this.options,
    );
  }
}

class VendorFormSection {
  final String id;
  String title;
  List<VendorFormField> fields;

  VendorFormSection({
    required this.id,
    required this.title,
    required this.fields,
  });

  VendorFormSection copyWith({
    String? id,
    String? title,
    List<VendorFormField>? fields,
  }) {
    return VendorFormSection(
      id: id ?? this.id,
      title: title ?? this.title,
      fields: fields ?? this.fields.map((f) => f.copyWith()).toList(),
    );
  }
}

class NewVendorForm {
  String vendorName;
  String category;
  String taxId;
  String website;
  String phone;
  String contactName;
  String contactEmail;
  String address;
  String paymentTerms;
  String bankName;
  String accountNumber;
  String complianceDocs;

  NewVendorForm({
    this.vendorName = '',
    this.category = 'Medical Supplies',
    this.taxId = '',
    this.website = '',
    this.phone = '',
    this.contactName = '',
    this.contactEmail = '',
    this.address = '',
    this.paymentTerms = 'Net 30',
    this.bankName = '',
    this.accountNumber = '',
    this.complianceDocs = '',
  });
}

