class Team {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? logoUrl;
  final String primaryColor;
  final String secondaryColor;

  Team({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? json['\$id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['\$createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['\$updatedAt'] ?? DateTime.now().toIso8601String()),
      logoUrl: json['logo_url'],
      primaryColor: json['primary_color'] ?? '#1976D2',
      secondaryColor: json['secondary_color'] ?? '#FFC107',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'logo_url': logoUrl,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
    };
  }

  Team copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }
} 