import 'package:signals/signals.dart';
import 'package:get_it/get_it.dart';
import 'package:teamcoach/features/plays/models/play.dart';
import 'package:teamcoach/features/plays/services/play_service.dart';
import 'package:teamcoach/features/games/services/game_service.dart';
import 'package:teamcoach/features/roster/services/player_service.dart';
import 'package:teamcoach/shared/models/player.dart';
import 'package:teamcoach/shared/models/game.dart';
import 'package:appwrite/appwrite.dart';
import 'package:teamcoach/core/services/appwrite_service.dart';
import 'package:teamcoach/core/constants/app_constants.dart';

// Player statistics model
class PlayerStats {
  final String playerId;
  final String playerName;
  final int playerNumber;
  final int gamesPlayed;
  final int atBats;
  final int hits;
  final int runs;
  final int rbis;
  final int singles;
  final int doubles;
  final int triples;
  final int homeRuns;
  final int walks;
  final int strikeouts;
  final int stolenBases;
  final double battingAverage;
  final double onBasePercentage;
  final double sluggingPercentage;
  final double ops;
  
  PlayerStats({
    required this.playerId,
    required this.playerName,
    required this.playerNumber,
    required this.gamesPlayed,
    required this.atBats,
    required this.hits,
    required this.runs,
    required this.rbis,
    required this.singles,
    required this.doubles,
    required this.triples,
    required this.homeRuns,
    required this.walks,
    required this.strikeouts,
    required this.stolenBases,
    required this.battingAverage,
    required this.onBasePercentage,
    required this.sluggingPercentage,
    required this.ops,
  });
  
  // Calculate total bases for slugging percentage
  int get totalBases => singles + (doubles * 2) + (triples * 3) + (homeRuns * 4);
  
  // Calculate plate appearances
  int get plateAppearances => atBats + walks;
  
  // Format batting average for display
  String get battingAverageDisplay => battingAverage > 0 
      ? '.${(battingAverage * 1000).toStringAsFixed(0).padLeft(3, '0')}'
      : '.000';
}

// Team statistics model
class TeamStats {
  final int totalGames;
  final int wins;
  final int losses;
  final int ties;
  final double winPercentage;
  final int totalRuns;
  final int totalRunsAgainst;
  final double averageRunsPerGame;
  final double teamBattingAverage;
  final int totalHits;
  final int totalAtBats;
  final int totalErrors;
  
  TeamStats({
    required this.totalGames,
    required this.wins,
    required this.losses,
    this.ties = 0,
    required this.winPercentage,
    required this.totalRuns,
    required this.totalRunsAgainst,
    required this.averageRunsPerGame,
    required this.teamBattingAverage,
    required this.totalHits,
    required this.totalAtBats,
    this.totalErrors = 0,
  });
}

// Game statistics model
class GameStats {
  final String gameId;
  final String opponent;
  final DateTime gameDate;
  final int atBats;
  final int hits;
  final int runs;
  final int rbis;
  
  GameStats({
    required this.gameId,
    required this.opponent,
    required this.gameDate,
    required this.atBats,
    required this.hits,
    required this.runs,
    required this.rbis,
  });
}

class StatsService {
  final AppwriteService _appwriteService = GetIt.I<AppwriteService>();
  final GameService _gameService = GetIt.I<GameService>();
  final PlayerService _playerService = GetIt.I<PlayerService>();
  
  // Reactive state
  final Signal<bool> isLoading = signal(false);
  final Signal<String?> error = signal(null);
  final ListSignal<Play> allPlays = listSignal([]);
  final ListSignal<PlayerStats> playerStats = listSignal([]);
  final Signal<TeamStats?> teamStats = signal(null);
  final Signal<String> selectedPlayerId = signal('');
  final Signal<String> selectedGameId = signal('');
  
  // Computed signals
  late final Computed<PlayerStats?> selectedPlayerStats;
  late final Computed<List<PlayerStats>> topHitters;
  late final Computed<List<PlayerStats>> topRBILeaders;
  
  StatsService() {
    selectedPlayerStats = computed(() {
      final playerId = selectedPlayerId.value;
      if (playerId.isEmpty || playerStats.value.isEmpty) return null;
      
      try {
        return playerStats.value.firstWhere(
          (stats) => stats.playerId == playerId,
        );
      } catch (e) {
        return playerStats.value.first;
      }
    });
    
    topHitters = computed(() {
      final sorted = [...playerStats.value];
      sorted.sort((a, b) => b.battingAverage.compareTo(a.battingAverage));
      return sorted.take(5).toList();
    });
    
    topRBILeaders = computed(() {
      final sorted = [...playerStats.value];
      sorted.sort((a, b) => b.rbis.compareTo(a.rbis));
      return sorted.take(5).toList();
    });
  }
  
  // Load all plays for statistics calculation
  Future<void> loadAllPlays() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.playsCollection,
        queries: [
          Query.limit(5000), // Get all plays
          Query.orderAsc('timestamp'),
        ],
      );
      
      allPlays.value = response.documents
          .map((doc) => Play.fromJson(doc.data))
          .toList();
      
      // Calculate stats after loading plays
      await calculateAllStats();
    } catch (e) {
      error.value = 'Error al cargar jugadas: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Calculate all statistics
  Future<void> calculateAllStats() async {
    await calculatePlayerStats();
    await calculateTeamStats();
  }
  
  // Calculate player statistics
  Future<void> calculatePlayerStats() async {
    final players = _playerService.players.value;
    final plays = allPlays.value;
    final games = _gameService.games.value.where((g) => g.status == 'completed').toList();
    
    final stats = <PlayerStats>[];
    
    for (final player in players) {
      // Get all plays for this player
      final playerPlays = plays.where((p) => p.playerId == player.id).toList();
      
      // Count games played (games where player has at least one play)
      final gamesPlayedSet = playerPlays.map((p) => p.gameId).toSet();
      final gamesPlayed = gamesPlayedSet.length;
      
      // Calculate batting stats
      int atBats = 0;
      int hits = 0;
      int singles = 0;
      int doubles = 0;
      int triples = 0;
      int homeRuns = 0;
      int runs = 0;
      int rbis = 0;
      int walks = 0;
      int strikeouts = 0;
      int stolenBases = 0;
      
      for (final play in playerPlays) {
        // At bats (hits, outs, strikeouts, but not walks)
        if (_isAtBat(play.playType)) {
          atBats++;
        }
        
        // Hits
        if (_isHit(play.result)) {
          hits++;
          switch (play.result) {
            case 'single':
              singles++;
              break;
            case 'double':
              doubles++;
              break;
            case 'triple':
              triples++;
              break;
            case 'home_run':
              homeRuns++;
              break;
          }
        }
        
        // Other stats
        if (play.playType == 'walk') walks++;
        if (play.playType == 'strikeout') strikeouts++;
        if (play.result == 'stolen_base') stolenBases++;
        
        runs += play.runsScored;
        rbis += play.rbi;
      }
      
      // Calculate percentages
      final battingAverage = atBats > 0 ? hits / atBats : 0.0;
      final onBasePercentage = (atBats + walks) > 0 
          ? (hits + walks) / (atBats + walks) 
          : 0.0;
      final sluggingPercentage = atBats > 0
          ? (singles + (doubles * 2) + (triples * 3) + (homeRuns * 4)) / atBats
          : 0.0;
      final ops = onBasePercentage + sluggingPercentage;
      
      stats.add(PlayerStats(
        playerId: player.id,
        playerName: player.name,
        playerNumber: player.number,
        gamesPlayed: gamesPlayed,
        atBats: atBats,
        hits: hits,
        runs: runs,
        rbis: rbis,
        singles: singles,
        doubles: doubles,
        triples: triples,
        homeRuns: homeRuns,
        walks: walks,
        strikeouts: strikeouts,
        stolenBases: stolenBases,
        battingAverage: battingAverage,
        onBasePercentage: onBasePercentage,
        sluggingPercentage: sluggingPercentage,
        ops: ops,
      ));
    }
    
    // Sort by batting average by default
    stats.sort((a, b) => b.battingAverage.compareTo(a.battingAverage));
    playerStats.value = stats;
  }
  
  // Calculate team statistics
  Future<void> calculateTeamStats() async {
    final games = _gameService.games.value;
    final completedGames = games.where((g) => g.status == 'completed').toList();
    final plays = allPlays.value;
    
    int wins = 0;
    int losses = 0;
    int ties = 0;
    int totalRuns = 0;
    int totalRunsAgainst = 0;
    int totalHits = 0;
    int totalAtBats = 0;
    
    // Calculate game results
    for (final game in completedGames) {
      final teamScore = game.finalScoreTeam ?? 0;
      final opponentScore = game.finalScoreOpponent ?? 0;
      
      if (teamScore > opponentScore) {
        wins++;
      } else if (teamScore < opponentScore) {
        losses++;
      } else {
        ties++;
      }
      
      totalRuns += teamScore;
      totalRunsAgainst += opponentScore;
    }
    
    // Calculate batting stats from plays
    for (final play in plays) {
      if (_isAtBat(play.playType)) {
        totalAtBats++;
      }
      if (_isHit(play.result)) {
        totalHits++;
      }
    }
    
    final totalGames = completedGames.length;
    final winPercentage = totalGames > 0 ? wins / totalGames : 0.0;
    final averageRunsPerGame = totalGames > 0 ? totalRuns / totalGames : 0.0;
    final teamBattingAverage = totalAtBats > 0 ? totalHits / totalAtBats : 0.0;
    
    teamStats.value = TeamStats(
      totalGames: totalGames,
      wins: wins,
      losses: losses,
      ties: ties,
      winPercentage: winPercentage,
      totalRuns: totalRuns,
      totalRunsAgainst: totalRunsAgainst,
      averageRunsPerGame: averageRunsPerGame,
      teamBattingAverage: teamBattingAverage,
      totalHits: totalHits,
      totalAtBats: totalAtBats,
    );
  }

  // Get player game statistics for a specific player
  Future<List<GameStats>> getPlayerGameStats(String playerId) async {
    try {
      final plays = allPlays.value.where((p) => p.playerId == playerId).toList();
      final games = _gameService.games.value;
      
      // Group plays by game
      final Map<String, List<Play>> playsByGame = {};
      for (final play in plays) {
        if (!playsByGame.containsKey(play.gameId)) {
          playsByGame[play.gameId] = [];
        }
        playsByGame[play.gameId]!.add(play);
      }

      // Calculate stats for each game
      final List<GameStats> gameStatsList = [];
      for (final entry in playsByGame.entries) {
        final gameId = entry.key;
        final gamePlays = entry.value;
        
        // Find game info
        final game = games.firstWhere(
          (g) => g.id == gameId,
          orElse: () => Game(
            id: gameId,
            teamId: '',
            opponent: 'Unknown',
            location: '',
            gameDate: DateTime.now(),
            isHome: true,
            status: 'completed',
            innings: 7,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        // Calculate stats for this game
        int atBats = 0;
        int hits = 0;
        int runs = 0;
        int rbis = 0;
        
        for (final play in gamePlays) {
          if (_isAtBat(play.playType)) {
            atBats++;
            if (_isHit(play.result)) {
              hits++;
            }
          }
          runs += play.runsScored;
          rbis += play.rbi;
        }
        
        gameStatsList.add(GameStats(
          gameId: gameId,
          opponent: game.opponent,
          gameDate: game.gameDate,
          atBats: atBats,
          hits: hits,
          runs: runs,
          rbis: rbis,
        ));
      }
      
      return gameStatsList..sort((a, b) => b.gameDate.compareTo(a.gameDate));
    } catch (e) {
      throw Exception('Error loading player game stats: $e');
    }
  }

  // Get game-specific player statistics
  Future<List<PlayerStats>> getGamePlayerStats(String gameId) async {
    try {
      final plays = allPlays.value.where((p) => p.gameId == gameId).toList();
      final players = _playerService.players.value;

      // Group plays by player
      final Map<String, List<Play>> playsByPlayer = {};
      for (final play in plays) {
        if (!playsByPlayer.containsKey(play.playerId)) {
          playsByPlayer[play.playerId] = [];
        }
        playsByPlayer[play.playerId]!.add(play);
      }

      // Calculate stats for each player in this game
      final List<PlayerStats> playerStatsList = [];
      for (final entry in playsByPlayer.entries) {
        final playerId = entry.key;
        final playerPlays = entry.value;
        
        // Find player info
        final player = players.firstWhere(
          (p) => p.id == playerId,
          orElse: () => Player(
            id: playerId,
            teamId: '',
            name: 'Unknown',
            number: 0,
            positions: [],
            isActive: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            battingSide: 'right',
            throwingSide: 'right',
          ),
        );
        
        // Calculate stats
        final stats = _calculatePlayerStatsFromPlays(playerId, player.name, player.number, playerPlays);
        playerStatsList.add(stats);
      }
      
      return playerStatsList;
    } catch (e) {
      throw Exception('Error loading game player stats: $e');
    }
  }

  // Get team statistics for a specific game
  Future<TeamStats> getGameTeamStats(String gameId) async {
    try {
      final plays = allPlays.value.where((p) => p.gameId == gameId).toList();
      final games = _gameService.games.value;
      
      final game = games.firstWhere((g) => g.id == gameId);

      // Calculate team stats for this game
      int totalRuns = 0;
      int totalHits = 0;
      int totalAtBats = 0;
      int totalRunsAgainst = game.finalScoreOpponent ?? 0;

      for (final play in plays) {
        if (_isAtBat(play.playType)) {
          totalAtBats++;
          if (_isHit(play.result)) {
            totalHits++;
          }
        }
        totalRuns += play.runsScored;
      }

      final teamBattingAverage = totalAtBats > 0 ? totalHits / totalAtBats : 0.0;
      final teamScore = game.finalScoreTeam ?? 0;
      final opponentScore = game.finalScoreOpponent ?? 0;
      
      final wins = teamScore > opponentScore ? 1 : 0;
      final losses = teamScore < opponentScore ? 1 : 0;

      return TeamStats(
        totalGames: 1,
        wins: wins,
        losses: losses,
        totalRuns: totalRuns,
        totalHits: totalHits,
        totalAtBats: totalAtBats,
        totalRunsAgainst: totalRunsAgainst,
        teamBattingAverage: teamBattingAverage,
        averageRunsPerGame: totalRuns.toDouble(),
        winPercentage: wins.toDouble(),
      );
    } catch (e) {
      throw Exception('Error loading game team stats: $e');
    }
  }

  // Helper method to determine if a play type counts as an at-bat
  bool _isAtBat(String playType) {
    return ['hit', 'out', 'strikeout'].contains(playType);
  }

  // Helper method to determine if a result is a hit
  bool _isHit(String result) {
    return ['single', 'double', 'triple', 'home_run'].contains(result);
  }

  // Helper method to calculate player stats from a list of plays
  PlayerStats _calculatePlayerStatsFromPlays(String playerId, String playerName, int playerNumber, List<Play> plays) {
    int atBats = 0;
    int hits = 0;
    int singles = 0;
    int doubles = 0;
    int triples = 0;
    int homeRuns = 0;
    int runs = 0;
    int rbis = 0;
    int walks = 0;
    int strikeouts = 0;
    int stolenBases = 0;
    
    for (final play in plays) {
      if (_isAtBat(play.playType)) {
        atBats++;
      }
      
      if (_isHit(play.result)) {
        hits++;
        switch (play.result) {
          case 'single':
            singles++;
            break;
          case 'double':
            doubles++;
            break;
          case 'triple':
            triples++;
            break;
          case 'home_run':
            homeRuns++;
            break;
        }
      }
      
      if (play.playType == 'walk') walks++;
      if (play.playType == 'strikeout') strikeouts++;
      if (play.result == 'stolen_base') stolenBases++;
      
      runs += play.runsScored;
      rbis += play.rbi;
    }
    
    final battingAverage = atBats > 0 ? hits / atBats : 0.0;
    final onBasePercentage = (atBats + walks) > 0 
        ? (hits + walks) / (atBats + walks) 
        : 0.0;
    final sluggingPercentage = atBats > 0
        ? (singles + (doubles * 2) + (triples * 3) + (homeRuns * 4)) / atBats
        : 0.0;
    final ops = onBasePercentage + sluggingPercentage;
    
    return PlayerStats(
      playerId: playerId,
      playerName: playerName,
      playerNumber: playerNumber,
      gamesPlayed: 1, // This is for a single game
      atBats: atBats,
      hits: hits,
      runs: runs,
      rbis: rbis,
      singles: singles,
      doubles: doubles,
      triples: triples,
      homeRuns: homeRuns,
      walks: walks,
      strikeouts: strikeouts,
      stolenBases: stolenBases,
      battingAverage: battingAverage,
      onBasePercentage: onBasePercentage,
      sluggingPercentage: sluggingPercentage,
      ops: ops,
    );
  }
} 