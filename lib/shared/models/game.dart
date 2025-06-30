class Game {
  final String id;
  final String teamId;
  final String opponent;
  final String location;
  final DateTime gameDate;
  final bool isHome;
  final String status; // "scheduled", "in_progress", "completed"
  final int innings;
  final int? finalScoreTeam;
  final int? finalScoreOpponent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Game({
    required this.id,
    required this.teamId,
    required this.opponent,
    required this.location,
    required this.gameDate,
    required this.isHome,
    required this.status,
    this.innings = 7,
    this.finalScoreTeam,
    this.finalScoreOpponent,
    this.createdAt,
    this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? json['\$id'] ?? '',
      teamId: json['team_id'] ?? '',
      opponent: json['opponent'] ?? '',
      location: json['location'] ?? '',
      gameDate: DateTime.parse(json['game_date']),
      isHome: json['is_home'] ?? true,
      status: json['status'] ?? 'scheduled',
      innings: json['innings'] ?? 7,
      finalScoreTeam: json['final_score_team'],
      finalScoreOpponent: json['final_score_opponent'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'opponent': opponent,
      'location': location,
      'game_date': gameDate.toIso8601String(),
      'is_home': isHome,
      'status': status,
      'innings': innings,
      'final_score_team': finalScoreTeam,
      'final_score_opponent': finalScoreOpponent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Game copyWith({
    String? id,
    String? teamId,
    String? opponent,
    String? location,
    DateTime? gameDate,
    bool? isHome,
    String? status,
    int? innings,
    int? finalScoreTeam,
    int? finalScoreOpponent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      opponent: opponent ?? this.opponent,
      location: location ?? this.location,
      gameDate: gameDate ?? this.gameDate,
      isHome: isHome ?? this.isHome,
      status: status ?? this.status,
      innings: innings ?? this.innings,
      finalScoreTeam: finalScoreTeam ?? this.finalScoreTeam,
      finalScoreOpponent: finalScoreOpponent ?? this.finalScoreOpponent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isScheduled => status == 'scheduled';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  
  String get scoreDisplay => '$finalScoreTeam - $finalScoreOpponent';
  
  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Programado';
      case 'in_progress':
        return 'En Curso';
      case 'completed':
        return 'Finalizado';
      default:
        return 'Desconocido';
    }
  }
  
  bool get hasResult => finalScoreTeam != null || finalScoreOpponent != null;
  
  bool get isWin => isCompleted && finalScoreTeam != null && finalScoreTeam! > (finalScoreOpponent ?? 0);
  bool get isLoss => isCompleted && finalScoreTeam != null && finalScoreTeam! < (finalScoreOpponent ?? 0);
  bool get isTie => isCompleted && finalScoreTeam != null && finalScoreTeam! == (finalScoreOpponent ?? 0);
} 