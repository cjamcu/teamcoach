import 'package:appwrite/appwrite.dart';
import 'package:signals/signals.dart';
import 'package:teamcoach/core/services/appwrite_service.dart';
import 'package:teamcoach/features/plays/models/play.dart';
import 'package:get_it/get_it.dart';

class PlayService {
  final AppwriteService _appwrite = GetIt.I<AppwriteService>();
  
  // Estado reactivo con signals
  final ListSignal<Play> plays = listSignal([]);
  final Signal<bool> isLoading = signal(false);
  final Signal<String?> error = signal(null);
  
  // Guardar jugada
  Future<void> savePlay(Play play) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playsCollection,
        documentId: play.id,
        data: play.toJson(),
      );
      
      // Agregar a la lista local
      plays.value = [...plays.value, play];
    } catch (e) {
      error.value = 'Error al guardar jugada: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Cargar jugadas de un juego
  Future<void> loadGamePlays(String gameId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playsCollection,
        queries: [
          Query.equal('game_id', gameId),
          Query.orderAsc('timestamp'),
        ],
      );
      
      plays.value = response.documents
          .map((doc) => Play.fromJson(doc.data))
          .toList();
    } catch (e) {
      error.value = 'Error al cargar jugadas: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Eliminar jugada
  Future<void> deletePlay(String playId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.playsCollection,
        documentId: playId,
      );
      
      // Eliminar de la lista local
      plays.value = plays.value.where((p) => p.id != playId).toList();
    } catch (e) {
      error.value = 'Error al eliminar jugada: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Estadísticas del juego
  int getPlayerHits(String playerId) {
    return plays.value.where((p) => p.playerId == playerId && p.isHit).length;
  }
  
  int getPlayerAtBats(String playerId) {
    return plays.value.where((p) => 
      p.playerId == playerId && 
      (p.isHit || p.isOut || p.isStrikeout)
    ).length;
  }
  
  int getPlayerRBIs(String playerId) {
    return plays.value
        .where((p) => p.playerId == playerId)
        .fold(0, (sum, play) => sum + play.rbi);
  }
  
  int getPlayerRuns(String playerId) {
    return plays.value
        .where((p) => p.playerId == playerId)
        .fold(0, (sum, play) => sum + play.runsScored);
  }
  
  // Limpiar datos al salir del juego
  void clearPlays() {
    plays.value = [];
    error.value = null;
  }
} 