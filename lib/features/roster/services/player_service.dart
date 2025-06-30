import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:signals/signals.dart';
import 'package:teamcoach/core/services/appwrite_service.dart';
import 'package:teamcoach/shared/models/player.dart';
import 'package:get_it/get_it.dart';

class PlayerService {
  final AppwriteService _appwrite = GetIt.I<AppwriteService>();
  
  // Estado reactivo con signals
  final ListSignal<Player> players = listSignal([]);
  final Signal<bool> isLoading = signal(false);
  final Signal<String?> error = signal(null);
  final Signal<String> searchQuery = signal('');
  final ListSignal<String> selectedPlayerIds = listSignal([]);
  
  // Computed signals
  late final Computed<List<Player>> filteredPlayers;
  late final Computed<List<Player>> selectedPlayers;
  late final Computed<bool> hasSelection;
  
  // Team ID del equipo Panteras
  static const String temporaryTeamId = 'team_panteras';
  
  PlayerService() {
    // Configurar computed signals
    filteredPlayers = computed(() {
      final query = searchQuery.value.toLowerCase();
      if (query.isEmpty) return players.value;
      
      return players.value.where((player) {
        return player.name.toLowerCase().contains(query) ||
               player.number.toString().contains(query) ||
               player.positions.any((pos) => pos.toLowerCase().contains(query));
      }).toList();
    });
    
    selectedPlayers = computed(() {
      return players.value
          .where((player) => selectedPlayerIds.value.contains(player.id))
          .toList();
    });
    
    hasSelection = computed(() => selectedPlayerIds.value.isNotEmpty);
    
    // Cargar jugadores al inicializar
    loadPlayers();
  }
  
  // Cargar todos los jugadores
  Future<void> loadPlayers() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playersCollection,
        queries: [
          Query.equal('team_id', temporaryTeamId),
          Query.orderDesc('created_at'),
        ],
      );
      
      players.value = response.documents
          .map((doc) => Player.fromJson(doc.data))
          .toList();
    } catch (e) {
      error.value = 'Error al cargar jugadores: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Crear nuevo jugador
  Future<void> createPlayer({
    required String name,
    required int number,
    required List<String> positions,
    required String battingSide,
    required String throwingSide,
    String? avatarUrl,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final now = DateTime.now();
      final player = Player(
        id: ID.unique(),
        teamId: temporaryTeamId,
        name: name,
        number: number,
        positions: positions,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        avatarUrl: avatarUrl,
        battingSide: battingSide,
        throwingSide: throwingSide,
      );
      
      await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playersCollection,
        documentId: player.id,
        data: player.toJson(),
      );
      
      // Agregar a la lista local
      players.value = [player, ...players.value];
    } catch (e) {
      error.value = 'Error al crear jugador: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Actualizar jugador
  Future<void> updatePlayer(Player player) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final updatedPlayer = player.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playersCollection,
        documentId: player.id,
        data: updatedPlayer.toJson(),
      );
      
      // Actualizar en la lista local
      players.value = players.value.map((p) {
        return p.id == player.id ? updatedPlayer : p;
      }).toList();
    } catch (e) {
      error.value = 'Error al actualizar jugador: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Eliminar jugador
  Future<void> deletePlayer(String playerId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playersCollection,
        documentId: playerId,
      );
      
      // Eliminar de la lista local
      players.value = players.value.where((p) => p.id != playerId).toList();
      selectedPlayerIds.value = selectedPlayerIds.value.where((id) => id != playerId).toList();
    } catch (e) {
      error.value = 'Error al eliminar jugador: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Eliminar múltiples jugadores
  Future<void> deleteMultiplePlayers() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      // Eliminar cada jugador seleccionado
      for (final playerId in selectedPlayerIds.value) {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.playersCollection,
          documentId: playerId,
        );
      }
      
      // Actualizar lista local
      players.value = players.value
          .where((p) => !selectedPlayerIds.value.contains(p.id))
          .toList();
      
      // Limpiar selección
      selectedPlayerIds.value = [];
    } catch (e) {
      error.value = 'Error al eliminar jugadores: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Activar/Desactivar múltiples jugadores
  Future<void> toggleMultiplePlayersStatus(bool activate) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      for (final playerId in selectedPlayerIds.value) {
        final player = players.value.firstWhere((p) => p.id == playerId);
        final updatedPlayer = player.copyWith(
          isActive: activate,
          updatedAt: DateTime.now(),
        );
        
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.playersCollection,
          documentId: playerId,
          data: updatedPlayer.toJson(),
        );
        
        // Actualizar en la lista local
        players.value = players.value.map((p) {
          return p.id == playerId ? updatedPlayer : p;
        }).toList();
      }
      
      // Limpiar selección
      selectedPlayerIds.value = [];
    } catch (e) {
      error.value = 'Error al actualizar estado de jugadores: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Métodos de selección
  void togglePlayerSelection(String playerId) {
    if (selectedPlayerIds.value.contains(playerId)) {
      selectedPlayerIds.value = selectedPlayerIds.value
          .where((id) => id != playerId)
          .toList();
    } else {
      selectedPlayerIds.value = [...selectedPlayerIds.value, playerId];
    }
  }
  
  void selectAll() {
    selectedPlayerIds.value = filteredPlayers.value.map((p) => p.id).toList();
  }
  
  void clearSelection() {
    selectedPlayerIds.value = [];
  }
  
  // Búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  // Singleton
  static void registerService() {
    GetIt.I.registerLazySingleton<PlayerService>(() => PlayerService());
  }
  
  static PlayerService get instance => GetIt.I<PlayerService>();
} 