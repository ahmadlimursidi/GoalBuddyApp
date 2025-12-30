class Badge {
  final String id;
  final String title;
  final String ageGroup;
  final String iconAsset;
  final String colorHex;
  final String description;

  Badge({
    required this.id,
    required this.title,
    required this.ageGroup,
    required this.iconAsset,
    required this.colorHex,
    required this.description,
  });

  // Factory constructor to create from map data
  factory Badge.fromMap(Map<String, dynamic> data) {
    return Badge(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      iconAsset: data['iconAsset'] ?? '',
      colorHex: data['colorHex'] ?? '',
      description: data['description'] ?? '',
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ageGroup': ageGroup,
      'iconAsset': iconAsset,
      'colorHex': colorHex,
      'description': description,
    };
  }
}