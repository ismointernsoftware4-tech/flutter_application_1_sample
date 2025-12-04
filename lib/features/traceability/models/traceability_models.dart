class TraceabilityRecord {
  final String dateTime;
  final String type;
  final String reference;
  final String itemDetails;
  final String quantity;
  final String user;
  final String location;

  const TraceabilityRecord({
    required this.dateTime,
    required this.type,
    required this.reference,
    required this.itemDetails,
    required this.quantity,
    required this.user,
    required this.location,
  });
}

class TraceabilityFilter {
  final String? type;
  final String? user;
  final String? location;
  final String? searchQuery;

  const TraceabilityFilter({
    this.type,
    this.user,
    this.location,
    this.searchQuery,
  });

  TraceabilityFilter copyWith({
    String? type,
    String? user,
    String? location,
    String? searchQuery,
  }) {
    return TraceabilityFilter(
      type: type ?? this.type,
      user: user ?? this.user,
      location: location ?? this.location,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool matches(TraceabilityRecord record) {
    final typeOk = type == null || record.type == type;
    final userOk = user == null || record.user == user;
    final locationOk = location == null || record.location == location;
    final searchOk =
        searchQuery == null ||
        record.reference.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        record.itemDetails.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        record.type.toLowerCase().contains(searchQuery!.toLowerCase());
    return typeOk && userOk && locationOk && searchOk;
  }
}

