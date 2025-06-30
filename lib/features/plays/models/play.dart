class Play {
  final String id;
  final String gameId;
  final String playerId;
  final int inning;
  final int atBatNumber;
  final String playType; // "hit", "out", "walk", "strikeout", "error", "sacrifice"
  final String result; // "single", "double", "triple", "home_run", "fly_out", "ground_out", etc.
  final int rbi;
  final int runsScored;
  final DateTime timestamp;
  final String? notes;

  Play({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.inning,
    required this.atBatNumber,
    required this.playType,
    required this.result,
    this.rbi = 0,
    this.runsScored = 0,
    required this.timestamp,
    this.notes,
  });

  factory Play.fromJson(Map<String, dynamic> json) {
    return Play(
      id: json['id'] ?? json['\$id'] ?? '',
      gameId: json['game_id'] ?? '',
      playerId: json['player_id'] ?? '',
      inning: json['inning'] ?? 1,
      atBatNumber: json['at_bat_number'] ?? 1,
      playType: json['play_type'] ?? '',
      result: json['result'] ?? '',
      rbi: json['rbi'] ?? 0,
      runsScored: json['runs_scored'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'player_id': playerId,
      'inning': inning,
      'at_bat_number': atBatNumber,
      'play_type': playType,
      'result': result,
      'rbi': rbi,
      'runs_scored': runsScored,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  Play copyWith({
    String? id,
    String? gameId,
    String? playerId,
    int? inning,
    int? atBatNumber,
    String? playType,
    String? result,
    int? rbi,
    int? runsScored,
    DateTime? timestamp,
    String? notes,
  }) {
    return Play(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      inning: inning ?? this.inning,
      atBatNumber: atBatNumber ?? this.atBatNumber,
      playType: playType ?? this.playType,
      result: result ?? this.result,
      rbi: rbi ?? this.rbi,
      runsScored: runsScored ?? this.runsScored,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  // Helper getters
  bool get isHit => ['single', 'double', 'triple', 'home_run'].contains(result);
  bool get isOut => playType == 'out';
  bool get isWalk => playType == 'walk';
  bool get isStrikeout => playType == 'strikeout';
  bool get isError => playType == 'error';
  
  String get displayResult {
    switch (result) {
      case 'single':
        return 'Sencillo';
      case 'double':
        return 'Doble';
      case 'triple':
        return 'Triple';
      case 'home_run':
        return 'Home Run';
      case 'fly_out':
        return 'Elevado Out';
      case 'ground_out':
        return 'Rolata Out';
      case 'strikeout':
        return 'Ponche';
      case 'walk':
        return 'Base por Bolas';
      case 'error':
        return 'Error';
      default:
        return result;
    }
  }
  
  // Common play types for quick buttons
  static const Map<String, Map<String, String>> quickPlays = {
    'single': {'type': 'hit', 'result': 'single', 'display': 'Sencillo'},
    'double': {'type': 'hit', 'result': 'double', 'display': 'Doble'},
    'triple': {'type': 'hit', 'result': 'triple', 'display': 'Triple'},
    'home_run': {'type': 'hit', 'result': 'home_run', 'display': 'HR'},
    'walk': {'type': 'walk', 'result': 'walk', 'display': 'BB'},
    'strikeout': {'type': 'strikeout', 'result': 'strikeout', 'display': 'K'},
    'fly_out': {'type': 'out', 'result': 'fly_out', 'display': 'Elevado'},
    'ground_out': {'type': 'out', 'result': 'ground_out', 'display': 'Rolata'},
    'error': {'type': 'error', 'result': 'error', 'display': 'Error'},
  };
} 