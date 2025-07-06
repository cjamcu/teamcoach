import 'package:appwrite/appwrite.dart';
import 'package:signals/signals.dart';
import 'package:teamcoach/core/services/appwrite_service.dart';
import 'package:teamcoach/shared/models/game.dart';
import 'package:teamcoach/shared/models/game_lineup.dart';
import 'package:teamcoach/shared/models/player.dart';
import 'package:get_it/get_it.dart';

class GameService {
  final AppwriteService _appwrite = GetIt.I<AppwriteService>();
  
  // Estado reactivo con signals
  final ListSignal<Game> games = listSignal([]);
  final Signal<bool> isLoading = signal(false);
  final Signal<String?> error = signal(null);
  final Signal<String> searchQuery = signal('');
  final Signal<String> statusFilter = signal('all'); // all, scheduled, in_progress, completed
  
  // Computed signals
  late final Computed<List<Game>> filteredGames;
  
  // Team ID del equipo Panteras
  static const String temporaryTeamId = 'team_panteras';
  
  GameService() {
    // Configurar computed signals
    filteredGames = computed(() {
      final query = searchQuery.value.toLowerCase();
      var filtered = games.value;
      
      // Filtrar por estado
      if (statusFilter.value != 'all') {
        filtered = filtered.where((game) => game.status == statusFilter.value).toList();
      }
      
      // Filtrar por búsqueda
      if (query.isNotEmpty) {
        filtered = filtered.where((game) {
          return game.opponent.toLowerCase().contains(query) ||
                 game.location.toLowerCase().contains(query);
        }).toList();
      }
      
      // Ordenar por fecha (próximos primero)
      filtered.sort((a, b) => a.gameDate.compareTo(b.gameDate));
      
      return filtered;
    });
    
    // Cargar juegos al inicializar
    loadGames();
  }
  
  // Cargar todos los juegos
  Future<void> loadGames() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gamesCollection,
        queries: [
          Query.equal('team_id', temporaryTeamId),
          Query.orderDesc('game_date'),
        ],
      );
      
      games.value = response.documents
          .map((doc) => Game.fromJson(doc.data))
          .toList();
    } catch (e) {
      error.value = 'Error al cargar juegos: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Crear nuevo juego
  Future<void> createGame({
    required String opponent,
    String location = '',
    required DateTime gameDate,
    required bool isHome,
    int innings = 7,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final now = DateTime.now();
      final game = Game(
        id: ID.unique(),
        teamId: temporaryTeamId,
        opponent: opponent,
        location: location,
        gameDate: gameDate,
        isHome: isHome,
        status: 'scheduled',
        innings: innings,
        createdAt: now,
        updatedAt: now,
      );
      
      await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gamesCollection,
        documentId: game.id,
        data: game.toJson(),
      );
      
      // Agregar a la lista local
      games.value = [game, ...games.value];
    } catch (e) {
      error.value = 'Error al crear juego: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Actualizar juego
  Future<void> updateGame(Game game) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final updatedGame = game.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gamesCollection,
        documentId: game.id,
        data: updatedGame.toJson(),
      );
      
      // Actualizar en la lista local
      games.value = games.value.map((g) {
        return g.id == game.id ? updatedGame : g;
      }).toList();
    } catch (e) {
      error.value = 'Error al actualizar juego: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Eliminar juego
  Future<void> deleteGame(String gameId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gamesCollection,
        documentId: gameId,
      );
      
      // Eliminar de la lista local
      games.value = games.value.where((g) => g.id != gameId).toList();
    } catch (e) {
      error.value = 'Error al eliminar juego: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Iniciar juego
  Future<void> startGame(String gameId) async {
    final game = games.value.firstWhere((g) => g.id == gameId);
    await updateGame(game.copyWith(status: 'in_progress'));
  }
  
  // Finalizar juego
  Future<void> finishGame(String gameId, int teamScore, int opponentScore) async {
    final game = games.value.firstWhere((g) => g.id == gameId);
    await updateGame(game.copyWith(
      status: 'completed',
      finalScoreTeam: teamScore,
      finalScoreOpponent: opponentScore,
    ));
  }
  
  // Verificar si existe alineación para el juego
  Future<bool> hasGameLineup(String gameId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gameLineupsCollection,
        queries: [
          Query.equal('game_id', gameId),
          Query.limit(1),
        ],
      );
      
      return response.documents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtener alineación del juego con datos del jugador
  Future<List<GameLineup>> getGameLineup(String gameId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gameLineupsCollection,
        queries: [
          Query.equal('game_id', gameId),
          Query.orderAsc('batting_order'),
        ],
      );
      
      // Cargar datos de los jugadores
      final lineupList = <GameLineup>[];
      
      for (final doc in response.documents) {
        final lineup = GameLineup.fromJson(doc.data);
        
        try {
          // Cargar datos del jugador
          final playerResponse = await _appwrite.databases.getDocument(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.playersCollection,
            documentId: lineup.playerId,
          );
          
          final player = Player.fromJson(playerResponse.data);
          lineupList.add(lineup.copyWith(player: player));
        } catch (e) {
          // Si no se puede cargar el jugador, agregarlo sin datos de jugador
          print('Error al cargar jugador ${lineup.playerId}: $e');
          lineupList.add(lineup);
        }
      }
      
      return lineupList;
    } catch (e) {
      throw Exception('Error al cargar alineación: $e');
    }
  }
  
  // Crear alineación completa
  Future<void> createGameLineup(String gameId, List<GameLineup> lineup) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      // Eliminar alineación existente
      final existingLineup = await getGameLineup(gameId);
      for (final lineupEntry in existingLineup) {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.gameLineupsCollection,
          documentId: lineupEntry.id,
        );
      }
      
      // Crear nueva alineación
      for (final lineupEntry in lineup) {
        await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.gameLineupsCollection,
          documentId: lineupEntry.id,
          data: lineupEntry.toJson(),
        );
      }
    } catch (e) {
      error.value = 'Error al guardar alineación: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filtros y búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void updateStatusFilter(String status) {
    statusFilter.value = status;
  }
  
  // Helper methods para estadísticas rápidas
  int get totalGames => games.value.length;
  int get scheduledGames => games.value.where((g) => g.isScheduled).length;
  int get completedGames => games.value.where((g) => g.isCompleted).length;
  int get wins => games.value.where((g) => g.isWin).length;
  int get losses => games.value.where((g) => g.isLoss).length;
  double get winPercentage => completedGames > 0 ? wins / completedGames : 0.0;

  // Get game by ID
  Future<Game?> getGame(String gameId) async {
    try {
      // First try to find in local cache
      final localGame = games.value.where((g) => g.id == gameId).firstOrNull;
      if (localGame != null) {
        return localGame;
      }
      
      // If not found locally, fetch from database
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.gamesCollection,
        documentId: gameId,
      );
      
      return Game.fromJson(doc.data);
    } catch (e) {
      error.value = 'Error al obtener juego: $e';
      return null;
    }
  }
} 