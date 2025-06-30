import 'package:signals/signals.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/player.dart';
import '../../../shared/models/game_lineup.dart';

class LineupController {
  final String gameId;
  final _uuid = Uuid();

  // Una sola lista - los primeros 9 son titulares, el resto reservas
  final lineupListSignal = listSignal<GameLineup>([]);
  final isLoadingSignal = signal<bool>(false);

  // Posiciones disponibles
  final List<String> positions = ['P', 'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF'];

  // Computed signals
  late final Computed<List<GameLineup>> startersSignal;
  late final Computed<List<GameLineup>> reservesSignal;
  late final Computed<bool> isLineupCompleteSignal;

  LineupController(this.gameId) {
    // Computed signals
    startersSignal = computed(() {
      final list = lineupListSignal.value;
      return list.take(9).toList();
    });

    reservesSignal = computed(() {
      final list = lineupListSignal.value;
      return list.skip(9).toList();
    });

    isLineupCompleteSignal = computed(() {
      final starters = startersSignal.value;
      if (starters.length < 9) return false;
      
      // Verificar que todos tienen posiciones
      for (final starter in starters) {
        if (starter.startingPosition.isEmpty) {
          return false;
        }
      }
      return true;
    });
  }

  // Cargar lineup existente o crear uno nuevo con jugadores disponibles
  void loadLineup(List<Player> availablePlayers, List<GameLineup>? existingLineup) {
    if (existingLineup != null && existingLineup.isNotEmpty) {
      // Cargar lineup existente
      final sortedLineup = List<GameLineup>.from(existingLineup);
      
      // Ordenar: primero titulares por batting order, luego reservas
      sortedLineup.sort((a, b) {
        if (a.isStarter && b.isStarter) {
          return a.battingOrder.compareTo(b.battingOrder);
        } else if (a.isStarter && !b.isStarter) {
          return -1;
        } else if (!a.isStarter && b.isStarter) {
          return 1;
        } else {
          return 0; // Ambos son reservas
        }
      });
      
      lineupListSignal.value = sortedLineup;
    } else {
      // Crear lineup nuevo con jugadores disponibles
      final newLineup = availablePlayers.map((player) {
        return GameLineup(
          id: _uuid.v4(),
          gameId: gameId,
          playerId: player.id,
          battingOrder: 0, // Se actualizará al guardar
          startingPosition: player.positions.isNotEmpty ? player.positions.first : 'P',
          isStarter: false, // Se determinará por posición en la lista
          player: player,
        );
      }).toList();
      
      lineupListSignal.value = newLineup;
    }
  }

  // Reordenar la lista
  void reorderLineup(int oldIndex, int newIndex) {
    final currentList = List<GameLineup>.from(lineupListSignal.value);
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);
    
    lineupListSignal.value = currentList;
  }

  // Cambiar posición de un jugador
  void updatePlayerPosition(int index, String position) {
    final currentList = List<GameLineup>.from(lineupListSignal.value);
    
    if (index >= 0 && index < currentList.length) {
      currentList[index] = currentList[index].copyWith(startingPosition: position);
      lineupListSignal.value = currentList;
    }
  }

  // Remover jugador de la lista (solo reservas)
  void removePlayer(int index) {
    if (index < 9) return; // No se pueden remover titulares
    
    final currentList = List<GameLineup>.from(lineupListSignal.value);
    currentList.removeAt(index);
    lineupListSignal.value = currentList;
  }

  // Preparar lista final para guardar
  List<GameLineup> getFinalLineup() {
    final currentList = lineupListSignal.value;
    final result = <GameLineup>[];
    
    for (int i = 0; i < currentList.length; i++) {
      final lineup = currentList[i];
      final isStarter = i < 9;
      
      if (isStarter) {
        // Titulares: batting order 1-9
        result.add(lineup.copyWith(
          isStarter: true,
          battingOrder: i + 1,
        ));
      } else {
        // Reservas: batting order 10+ (máximo 15 según restricción)
        final reserveOrder = 10 + (i - 9);
        if (reserveOrder <= 15) {
          result.add(lineup.copyWith(
            isStarter: false,
            battingOrder: reserveOrder,
          ));
        }
      }
    }
    
    return result;
  }

  // Validar lineup
  String? validateLineup() {
    final list = lineupListSignal.value;
    
    if (list.length < 9) {
      return 'Necesitas al menos 9 jugadores';
    }

    // Verificar que los primeros 9 tienen posiciones
    for (int i = 0; i < 9; i++) {
      if (i >= list.length || list[i].startingPosition.isEmpty) {
        return 'El jugador #${i + 1} necesita una posición asignada';
      }
    }

    // Verificar límite de reservas (máximo 6 para no exceder batting_order = 15)
    if (list.length > 15) {
      return 'Máximo 15 jugadores permitidos (9 titulares + 6 reservas)';
    }

    return null; // Sin errores
  }

  void dispose() {
    lineupListSignal.dispose();
    isLoadingSignal.dispose();
  }
} 