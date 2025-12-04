class ColumnConfig {
  final String key;
  final String label;
  final String description;
  final bool visible;

  const ColumnConfig({
    required this.key,
    required this.label,
    this.description = '',
    this.visible = true,
  });

  ColumnConfig copyWith({
    String? key,
    String? label,
    String? description,
    bool? visible,
  }) {
    return ColumnConfig(
      key: key ?? this.key,
      label: label ?? this.label,
      description: description ?? this.description,
      visible: visible ?? this.visible,
    );
  }

  factory ColumnConfig.fromMap(Map<String, dynamic> map) {
    return ColumnConfig(
      key: map['key'] as String? ?? '',
      label: map['label'] as String? ?? '',
      description: map['description'] as String? ?? '',
      visible: map['visible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'description': description,
      'visible': visible,
    };
  }
}

