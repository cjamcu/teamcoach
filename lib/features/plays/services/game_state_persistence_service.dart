import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/game.dart';
import '../../../shared/models/game_lineup.dart';
import '../models/play.dart';

class GameStatePersistenceService {
  static const String _gameStateKey = 'active_game_state';
  static const String _lineupKey = 'active_game_lineup';
  static const String _playsKey = 'active_game_plays';
  static const String _gameControllerStateKey = 'active_game_controller_state';

  // Save complete game state
  static Future<void> saveGameState({
    required Game? game,
    required List<GameLineup> lineup,
    required List<Play> plays,
    required Map<String, dynamic> controllerState,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save game
    if (game != null) {
      await prefs.setString(_gameStateKey, jsonEncode(game.toJson()));
    } else {
      await prefs.remove(_gameStateKey);
    }
    
    // Save lineup
    final lineupJson = lineup.map((l) => l.toJson()).toList();
    await prefs.setString(_lineupKey, jsonEncode(lineupJson));
    
    // Save plays
    final playsJson = plays.map((p) => p.toJson()).toList();
    await prefs.setString(_playsKey, jsonEncode(playsJson));
    
    // Save controller state
    await prefs.setString(_gameControllerStateKey, jsonEncode(controllerState));
  }

  // Load complete game state
  static Future<GameStateData?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Load game
      final gameJson = prefs.getString(_gameStateKey);
      if (gameJson == null) return null;
      
      final game = Game.fromJson(jsonDecode(gameJson));
      
      // Load lineup
      final lineupJson = prefs.getString(_lineupKey);
      final lineup = lineupJson != null
          ? (jsonDecode(lineupJson) as List)
              .map((l) => GameLineup.fromJson(l))
              .toList()
          : <GameLineup>[];
      
      // Load plays
      final playsJson = prefs.getString(_playsKey);
      final plays = playsJson != null
          ? (jsonDecode(playsJson) as List)
              .map((p) => Play.fromJson(p))
              .toList()
          : <Play>[];
      
      // Load controller state
      final controllerStateJson = prefs.getString(_gameControllerStateKey);
      final controllerState = controllerStateJson != null
          ? jsonDecode(controllerStateJson) as Map<String, dynamic>
          : <String, dynamic>{};
      
      return GameStateData(
        game: game,
        lineup: lineup,
        plays: plays,
        controllerState: controllerState,
      );
    } catch (e) {
      // If there's an error loading, clear corrupted data
      await clearGameState();
      return null;
    }
  }

  // Clear saved game state
  static Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
    await prefs.remove(_lineupKey);
    await prefs.remove(_playsKey);
    await prefs.remove(_gameControllerStateKey);
  }

  // Check if there's a saved game state
  static Future<bool> hasSavedGameState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gameStateKey) != null;
  }

  // Save controller signals state
  static Map<String, dynamic> extractControllerState({
    required int currentInning,
    required bool isTopOfInning,
    required int currentBatterIndex,
    required int teamScore,
    required int opponentScore,
    required int outs,
    required Map<String, String> runnersOnBase,
    required int strikes,
    required int balls,
    required Map<int, Map<String, int>> inningScores,
    required bool isGameActive,
  }) {
    return {
      'currentInning': currentInning,
      'isTopOfInning': isTopOfInning,
      'currentBatterIndex': currentBatterIndex,
      'teamScore': teamScore,
      'opponentScore': opponentScore,
      'outs': outs,
      'runnersOnBase': runnersOnBase,
      'strikes': strikes,
      'balls': balls,
      'inningScores': inningScores,
      'isGameActive': isGameActive,
    };
  }
}

class GameStateData {
  final Game game;
  final List<GameLineup> lineup;
  final List<Play> plays;
  final Map<String, dynamic> controllerState;

  GameStateData({
    required this.game,
    required this.lineup,
    required this.plays,
    required this.controllerState,
  });
} 