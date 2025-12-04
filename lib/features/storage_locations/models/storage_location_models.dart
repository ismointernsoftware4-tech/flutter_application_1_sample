class StorageLocation {
  final String id;
  final String name;
  final String type;
  final String parentLocation;
  final int capacity;
  final String status;
  final String manager;
  final String description;

  const StorageLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.parentLocation,
    required this.capacity,
    required this.status,
    this.manager = '',
    this.description = '',
  });
}

class StorageLocationFilter {
  final String? status;
  final String? type;
  final String? parentLocation;
  final String? searchQuery;

  const StorageLocationFilter({
    this.status,
    this.type,
    this.parentLocation,
    this.searchQuery,
  });

  StorageLocationFilter copyWith({
    String? status,
    String? type,
    String? parentLocation,
    String? searchQuery,
  }) {
    return StorageLocationFilter(
      status: status ?? this.status,
      type: type ?? this.type,
      parentLocation: parentLocation ?? this.parentLocation,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool matches(StorageLocation location) {
    final statusOk = status == null || location.status == status;
    final typeOk = type == null || location.type == type;
    final parentOk =
        parentLocation == null || location.parentLocation == parentLocation;
    final searchOk =
        searchQuery == null ||
        location.id.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        location.name.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        location.type.toLowerCase().contains(searchQuery!.toLowerCase());
    return statusOk && typeOk && parentOk && searchOk;
  }
}

