class GoodsReceipt {
  final String grnId;
  final String poReference;
  final String vendor;
  final String dateReceived;
  final String receivedBy;
  final String status;

  GoodsReceipt({
    required this.grnId,
    required this.poReference,
    required this.vendor,
    required this.dateReceived,
    required this.receivedBy,
    required this.status,
  });
}

class GRNFilter {
  final String? status;
  final String? vendor;
  final String? poReference;
  final String? searchQuery;

  const GRNFilter({
    this.status,
    this.vendor,
    this.poReference,
    this.searchQuery,
  });

  GRNFilter copyWith({
    String? status,
    String? vendor,
    String? poReference,
    String? searchQuery,
  }) {
    return GRNFilter(
      status: status ?? this.status,
      vendor: vendor ?? this.vendor,
      poReference: poReference ?? this.poReference,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool matches(GoodsReceipt grn) {
    final statusOk = status == null || grn.status == status;
    final vendorOk = vendor == null || grn.vendor == vendor;
    final poOk = poReference == null || grn.poReference == poReference;
    final searchOk =
        searchQuery == null ||
        grn.grnId.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        grn.poReference.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        grn.vendor.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && vendorOk && poOk && searchOk;
  }
}

