import 'package:teamcoach/shared/models/player.dart';

class GameLineup {
  final String id;
  final String gameId;
  final String playerId;
  final int battingOrder;
  final String startingPosition;
  final bool isStarter;
  final List<String> positionsPlayed;
  final int? substitutedAtInning;
  final String? substitutedBy;

  // Transient properties for UI
  final Player? player;

  GameLineup({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.battingOrder,
    required this.startingPosition,
    required this.isStarter,
    this.positionsPlayed = const [],
    this.substitutedAtInning,
    this.substitutedBy,
    this.player,
  });

  factory GameLineup.fromJson(Map<String, dynamic> json) {
    return GameLineup(
      id: json['id'] ?? json['\$id'] ?? '',
      gameId: json['game_id'] ?? '',
      playerId: json['player_id'] ?? '',
      battingOrder: json['batting_order'] ?? 0,
      startingPosition: json['starting_position'] ?? '',
      isStarter: json['is_starter'] ?? true,
      positionsPlayed: List<String>.from(json['positions_played'] ?? []),
      substitutedAtInning: json['substituted_at_inning'],
      substitutedBy: json['substituted_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'player_id': playerId,
      'batting_order': battingOrder,
      'starting_position': startingPosition,
      'is_starter': isStarter,
      'positions_played': positionsPlayed,
      'substituted_at_inning': substitutedAtInning,
      'substituted_by': substitutedBy,
    };
  }

  GameLineup copyWith({
    String? id,
    String? gameId,
    String? playerId,
    int? battingOrder,
    String? startingPosition,
    bool? isStarter,
    List<String>? positionsPlayed,
    int? substitutedAtInning,
    String? substitutedBy,
    Player? player,
  }) {
    return GameLineup(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      battingOrder: battingOrder ?? this.battingOrder,
      startingPosition: startingPosition ?? this.startingPosition,
      isStarter: isStarter ?? this.isStarter,
      positionsPlayed: positionsPlayed ?? this.positionsPlayed,
      substitutedAtInning: substitutedAtInning ?? this.substitutedAtInning,
      substitutedBy: substitutedBy ?? this.substitutedBy,
      player: player ?? this.player,
    );
  }

  // Helper getters
  bool get isSubstituted => substitutedAtInning != null;
  String get displayName => player?.name ?? 'Jugador Desconocido';
  int get displayNumber => player?.number ?? 0;
  
  String get positionsPlayedDisplay => positionsPlayed.isEmpty 
      ? startingPosition 
      : positionsPlayed.join(', ');
} 