import 'package:signals/signals.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/game.dart';
import '../../../shared/models/game_lineup.dart';
import '../../../shared/models/player.dart';
import '../models/play.dart';

class ActiveGameController {
  static final _uuid = Uuid();
  
  // Core game state
  final gameSignal = signal<Game?>(null);
  final lineupSignal = listSignal<GameLineup>([]);
  final playsSignal = listSignal<Play>([]);
  
  // Current game state
  final currentInningSignal = signal<int>(1);
  final isTopOfInningSignal = signal<bool>(true);
  final currentBatterIndexSignal = signal<int>(0);
  final teamScoreSignal = signal<int>(0);
  final opponentScoreSignal = signal<int>(0);
  final outsSignal = signal<int>(0);
  final runnersOnBaseSignal = mapSignal<String, String>({});  // position -> playerId
  
  // Count state (balls & strikes)
  final strikesSignal = signal<int>(0);
  final ballsSignal = signal<int>(0);
  
  // Innings tracking - Map<inning, Map<'team'|'opponent', runs>>
  final inningScoresSignal = mapSignal<int, Map<String, int>>({});
  
  // UI state
  final isGameActiveSignal = signal<bool>(false);
  final showSubstitutionDialogSignal = signal<bool>(false);
  
  // Constants
  static const int DEFAULT_INNINGS = 7;  // Default for softball tournaments
  static const int MAX_STRIKES = 3;
  static const int MAX_BALLS = 4;
  
  // Computed signals
  late final currentBatterSignal = computed(() {
    final lineup = lineupSignal.value;
    final index = currentBatterIndexSignal.value;
    if (lineup.isEmpty || index >= lineup.length) return null;
    return lineup[index];
  });
  
  late final inningDisplaySignal = computed(() {
    final inning = currentInningSignal.value;
    final isTop = isTopOfInningSignal.value;
    return '${isTop ? "↑" : "↓"} ${inning}°';
  });
  
  late final atBatCountSignal = computed(() {
    final gameId = gameSignal.value?.id;
    if (gameId == null) return 0;
    
    final currentInning = currentInningSignal.value;
    final isTop = isTopOfInningSignal.value;
    
    return playsSignal.value
        .where((play) => 
            play.gameId == gameId && 
            play.inning == currentInning &&
            ((isTop && play.atBatNumber <= 999) || (!isTop && play.atBatNumber > 999)))
        .length + 1;
  });
  
  late final hasRunnersSignal = computed(() {
    return runnersOnBaseSignal.value.isNotEmpty;
  });
  
  late final totalInningsSignal = computed(() {
    return gameSignal.value?.innings ?? DEFAULT_INNINGS;
  });
  
  late final teamScoreByInningSignal = computed(() {
    final scores = <int, int>{};
    final totalInnings = totalInningsSignal.value;
    for (int i = 1; i <= totalInnings; i++) {
      scores[i] = inningScoresSignal.value[i]?['team'] ?? 0;
    }
    return scores;
  });
  
  late final opponentScoreByInningSignal = computed(() {
    final scores = <int, int>{};
    final totalInnings = totalInningsSignal.value;
    for (int i = 1; i <= totalInnings; i++) {
      scores[i] = inningScoresSignal.value[i]?['opponent'] ?? 0;
    }
    return scores;
  });
  
  // Initialize game
  void startGame(Game game, List<GameLineup> lineup) {
    gameSignal.value = game.copyWith(status: 'in_progress');
    lineupSignal.value = List.from(lineup.where((l) => l.isStarter))
      ..sort((a, b) => a.battingOrder.compareTo(b.battingOrder));
    
    // Reset game state
    currentInningSignal.value = 1;
    isTopOfInningSignal.value = true;
    currentBatterIndexSignal.value = 0;
    teamScoreSignal.value = 0;
    opponentScoreSignal.value = 0;
    outsSignal.value = 0;
    strikesSignal.value = 0;
    ballsSignal.value = 0;
    runnersOnBaseSignal.value = {};
    playsSignal.value = [];
    isGameActiveSignal.value = true;
    
    // Initialize innings scores
    final inningScores = <int, Map<String, int>>{};
    final totalInnings = game.innings;
    for (int i = 1; i <= totalInnings; i++) {
      inningScores[i] = {'team': 0, 'opponent': 0};
    }
    inningScoresSignal.value = inningScores;
  }
  
  // Ball and Strike tracking
  void addStrike() {
    strikesSignal.value++;
    if (strikesSignal.value >= MAX_STRIKES) {
      recordPlay(
        playType: 'out',
        result: 'strikeout',
        notes: 'K',
      );
    }
  }
  
  void addBall() {
    ballsSignal.value++;
    if (ballsSignal.value >= MAX_BALLS) {
      recordPlay(
        playType: 'walk',
        result: 'walk',
        notes: 'BB',
      );
    }
  }
  
  void resetCount() {
    strikesSignal.value = 0;
    ballsSignal.value = 0;
  }
  
  // Record a play
  void recordPlay({
    required String playType,
    required String result,
    int rbi = 0,
    int runsScored = 0,
    String? notes,
  }) {
    final currentBatter = currentBatterSignal.value;
    final game = gameSignal.value;
    
    if (currentBatter == null || game == null) return;
    
    final play = Play(
      id: _uuid.v4(),
      gameId: game.id,
      playerId: currentBatter.playerId,
      inning: currentInningSignal.value,
      atBatNumber: _getAtBatNumber(),
      playType: playType,
      result: result,
      rbi: rbi,
      runsScored: runsScored,
      timestamp: DateTime.now(),
      notes: notes,
    );
    
    playsSignal.value = [...playsSignal.value, play];
    
    // Update game state based on play
    _updateGameStateAfterPlay(play);
  }
  
  int _getAtBatNumber() {
    final isTop = isTopOfInningSignal.value;
    final baseNumber = atBatCountSignal.value;
    
    // Top of inning: 1-999, bottom: 1000+
    return isTop ? baseNumber : (1000 + baseNumber);
  }
  
  void _updateGameStateAfterPlay(Play play) {
    // Update score
    if (play.runsScored > 0) {
      _addRunsToCurrentInning(play.runsScored);
    }
    
    // Reset count for new batter
    resetCount();
    
    // Handle outs
    if (play.isOut || play.isStrikeout) {
      outsSignal.value++;
      
      // End of half-inning?
      if (outsSignal.value >= 3) {
        _endHalfInning();
        return;
      }
    }
    
    // Handle hits and walks - advance to next batter
    if (play.isHit || play.isWalk || play.isError) {
      _advanceBatter();
      _updateRunners(play);
    } else if (play.isOut || play.isStrikeout) {
      _advanceBatter();
    }
  }
  
  void _addRunsToCurrentInning(int runs) {
    final inning = currentInningSignal.value;
    final isTop = isTopOfInningSignal.value;
    final team = isTop ? 'team' : 'opponent';
    
    // Update total score
    if (isTop) {
      teamScoreSignal.value += runs;
    } else {
      opponentScoreSignal.value += runs;
    }
    
    // Update inning score
    final currentScores = Map<int, Map<String, int>>.from(inningScoresSignal.value);
    if (!currentScores.containsKey(inning)) {
      currentScores[inning] = {'team': 0, 'opponent': 0};
    }
    currentScores[inning]![team] = (currentScores[inning]![team] ?? 0) + runs;
    inningScoresSignal.value = currentScores;
  }
  
  void _endHalfInning() {
    outsSignal.value = 0;
    runnersOnBaseSignal.value = {};
    resetCount();
    
    if (isTopOfInningSignal.value) {
      // Switch to bottom of inning
      isTopOfInningSignal.value = false;
    } else {
      // End of full inning
      isTopOfInningSignal.value = true;
      currentInningSignal.value++;
      
      // Check if game should end
      final game = gameSignal.value;
      if (game != null && currentInningSignal.value > game.innings) {
        _endGame();
      }
    }
  }
  
  void _advanceBatter() {
    final lineup = lineupSignal.value;
    if (lineup.isEmpty) return;
    
    currentBatterIndexSignal.value = (currentBatterIndexSignal.value + 1) % lineup.length;
  }
  
  void _updateRunners(Play play) {
    // Simplified runner advancement logic
    // In a real implementation, this would be more sophisticated
    final runners = Map<String, String>.from(runnersOnBaseSignal.value);
    
    if (play.isHit) {
      // Add current batter to first base
      runners['1B'] = play.playerId;
      
      // Advance existing runners based on hit type
      switch (play.result) {
        case 'single':
          _advanceRunners(runners, 1);
          break;
        case 'double':
          _advanceRunners(runners, 2);
          break;
        case 'triple':
          _advanceRunners(runners, 3);
          break;
        case 'home_run':
          runners.clear(); // Everyone scores
          break;
      }
    } else if (play.isWalk) {
      // Force advance if bases loaded, otherwise just add to first
      runners['1B'] = play.playerId;
    }
    
    runnersOnBaseSignal.value = runners;
  }
  
  void _advanceRunners(Map<String, String> runners, int bases) {
    // Simplified runner advancement
    final positions = ['3B', '2B', '1B'];
    final newRunners = <String, String>{};
    
    for (final pos in positions) {
      if (runners.containsKey(pos)) {
        final currentBase = positions.indexOf(pos);
        final newBase = currentBase - bases;
        
        if (newBase >= 0) {
          newRunners[positions[newBase]] = runners[pos]!;
        }
        // If newBase < 0, runner scores (handled in play recording)
      }
    }
    
    runners.clear();
    runners.addAll(newRunners);
  }
  
  void _endGame() {
    final game = gameSignal.value;
    if (game == null) return;
    
    gameSignal.value = game.copyWith(
      status: 'completed',
      finalScoreTeam: teamScoreSignal.value,
      finalScoreOpponent: opponentScoreSignal.value,
    );
    
    isGameActiveSignal.value = false;
  }
  
  // Add opponent score (for manual tracking)
  void addOpponentRun() {
    _addRunsToCurrentInning(1);
  }
  
  void subtractOpponentRun() {
    if (opponentScoreSignal.value > 0) {
      final inning = currentInningSignal.value;
      final isTop = isTopOfInningSignal.value;
      final team = isTop ? 'team' : 'opponent';
      
      opponentScoreSignal.value--;
      
      // Update inning score
      final currentScores = Map<int, Map<String, int>>.from(inningScoresSignal.value);
      if (currentScores.containsKey(inning) && (currentScores[inning]![team] ?? 0) > 0) {
        currentScores[inning]![team] = (currentScores[inning]![team] ?? 0) - 1;
        inningScoresSignal.value = currentScores;
      }
    }
  }
  
  // Substitution methods
  void substitutePlayer(String currentPlayerId, String newPlayerId, int inning) {
    final lineup = lineupSignal.value;
    final index = lineup.indexWhere((l) => l.playerId == currentPlayerId);
    
    if (index != -1) {
      final updatedLineup = [...lineup];
      updatedLineup[index] = lineup[index].copyWith(
        substitutedAtInning: inning,
        substitutedBy: newPlayerId,
      );
      
      lineupSignal.value = updatedLineup;
    }
  }
  
  // Manual scoring adjustment
  void adjustTeamScore(int newScore) {
    if (newScore >= 0) {
      teamScoreSignal.value = newScore;
    }
  }
  
  void adjustOpponentScore(int newScore) {
    if (newScore >= 0) {
      opponentScoreSignal.value = newScore;
    }
  }
  
  // Reset/cleanup
  void resetGame() {
    gameSignal.value = null;
    lineupSignal.value = [];
    playsSignal.value = [];
    currentInningSignal.value = 1;
    isTopOfInningSignal.value = true;
    currentBatterIndexSignal.value = 0;
    teamScoreSignal.value = 0;
    opponentScoreSignal.value = 0;
    outsSignal.value = 0;
    strikesSignal.value = 0;
    ballsSignal.value = 0;
    runnersOnBaseSignal.value = {};
    inningScoresSignal.value = {};
    isGameActiveSignal.value = false;
  }
} 