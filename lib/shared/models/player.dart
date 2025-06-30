class Player {
  final String id;
  final String teamId;
  final String name;
  final int number;
  final List<String> positions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final String battingSide;
  final String throwingSide;

  static const List<String> availablePositions = [
    'P', 'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH'
  ];

  Player({
    required this.id,
    required this.teamId,
    required this.name,
    required this.number,
    required this.positions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    required this.battingSide,
    required this.throwingSide,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? json['\$id'] ?? '',
      teamId: json['team_id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? 0,
      positions: List<String>.from(json['positions'] ?? []),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? json['\$createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['\$updatedAt'] ?? DateTime.now().toIso8601String()),
      avatarUrl: json['avatar_url'],
      battingSide: json['batting_side'] ?? 'right',
      throwingSide: json['throwing_side'] ?? 'right',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'name': name,
      'number': number,
      'positions': positions,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_url': avatarUrl,
      'batting_side': battingSide,
      'throwing_side': throwingSide,
    };
  }

  Player copyWith({
    String? id,
    String? teamId,
    String? name,
    int? number,
    List<String>? positions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    String? battingSide,
    String? throwingSide,
  }) {
    return Player(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      number: number ?? this.number,
      positions: positions ?? this.positions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      battingSide: battingSide ?? this.battingSide,
      throwingSide: throwingSide ?? this.throwingSide,
    );
  }

  String get positionsDisplay => positions.join(', ');
} 