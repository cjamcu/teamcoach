import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../shared/models/game.dart';
import '../../../shared/models/game_lineup.dart';
import '../../../features/roster/services/player_service.dart';
import '../services/game_service.dart';
import '../controllers/lineup_controller.dart';

class LineupBuilderScreen extends StatefulWidget {
  final String gameId;
  final VoidCallback onLineupCreated;

  const LineupBuilderScreen({
    super.key,
    required this.gameId,
    required this.onLineupCreated,
  });

  @override
  State<LineupBuilderScreen> createState() => _LineupBuilderScreenState();
}

class _LineupBuilderScreenState extends State<LineupBuilderScreen> {
  final _playerService = GetIt.I<PlayerService>();
  final _gameService = GetIt.I<GameService>();
  
  late final LineupController _controller;
  Game? game;

  @override
  void initState() {
    super.initState();
    _controller = LineupController(widget.gameId);
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _controller.isLoadingSignal.value = true;
    
    try {
      // Cargar jugadores activos
      await _playerService.loadPlayers();
      final players = _playerService.filteredPlayers.value
          .where((p) => p.isActive)
          .toList();
      
      // Cargar información del juego
      game = _gameService.games.value.firstWhere((g) => g.id == widget.gameId);

      // Intentar cargar lineup existente
      List<GameLineup>? existingLineup;
      try {
        existingLineup = await _gameService.getGameLineup(widget.gameId);
      } catch (e) {
        // No hay lineup existente, usaremos jugadores disponibles
        existingLineup = null;
      }

      // Cargar lineup en el controller
      _controller.loadLineup(players, existingLineup);
      
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Error al cargar datos: $e'),
          ),
        );
      }
    } finally {
      _controller.isLoadingSignal.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) {
        final isLoading = _controller.isLoadingSignal.value;
        final isComplete = _controller.isLineupCompleteSignal.value;
        final lineup = _controller.lineupListSignal.value;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Alineación vs ${game?.opponent ?? ""}'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              ShadButton(
                onPressed: isComplete ? _saveLineup : null,
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : lineup.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay jugadores disponibles',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        // Header con información
                        _buildHeader(),
                        
                        // Lista principal
                        Expanded(
                          child: _buildLineupList(),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Watch(
      (context) {
        final starters = _controller.startersSignal.value;
        final reserves = _controller.reservesSignal.value;
        
        return ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alineación de Bateo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arrastra para cambiar el orden de bateo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: starters.length >= 9 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Titulares: ${starters.length}/9',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (reserves.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reservas: ${reserves.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineupList() {
    return Watch(
      (context) {
        final lineup = _controller.lineupListSignal.value;
        
        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lineup.length,
          onReorder: _controller.reorderLineup,
          itemBuilder: (context, index) {
            final lineupEntry = lineup[index];
            final isStarter = index < 9;
            
            return _buildLineupItem(
              key: ValueKey(lineupEntry.id),
              lineupEntry: lineupEntry,
              index: index,
              isStarter: isStarter,
            );
          },
        );
      },
    );
  }

  Widget _buildLineupItem({
    required Key key,
    required GameLineup lineupEntry,
    required int index,
    required bool isStarter,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Indicador de posición/orden
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isStarter 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isStarter
                      ? Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.grey.shade200,
                          size: 20,
                        ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Avatar del jugador
              CircleAvatar(
                radius: 20,
                backgroundColor: isStarter 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                child: Text(
                  '${lineupEntry.player?.number ?? ""}',
                  style: TextStyle(
                    color: isStarter 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Información del jugador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lineupEntry.player?.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (isStarter) ...[
                          // Posición clickeable
                          GestureDetector(
                            onTap: () => _showPositionSelector(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    lineupEntry.startingPosition.isNotEmpty 
                                        ? lineupEntry.startingPosition 
                                        : 'Tocar para elegir',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'RESERVA',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          lineupEntry.player?.positionsDisplay ?? "",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Acciones
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de drag
                  Icon(
                    Icons.drag_handle,
                    color: Colors.grey.shade400,
                  ),
                  
                  // Botón de eliminar (solo para reservas)
                  if (!isStarter) ...[
                    const SizedBox(width: 8),
                    ShadButton.outline(
                      onPressed: () => _controller.removePlayer(index),
                      size: ShadButtonSize.sm,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPositionSelector(int index) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Seleccionar Posición'),
        description: const Text('Elige la posición que jugará este jugador'),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _controller.positions.map((position) {
            return ShadButton.outline(
              onPressed: () {
                _controller.updatePlayerPosition(index, position);
                Navigator.of(context).pop();
              },
              child: Text(position),
            );
          }).toList(),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLineup() async {
    final validationError = _controller.validateLineup();
    if (validationError != null) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text(validationError),
        ),
      );
      return;
    }

    _controller.isLoadingSignal.value = true;

    try {
      final finalLineup = _controller.getFinalLineup();
      await _gameService.createGameLineup(widget.gameId, finalLineup);
      
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Éxito'),
            description: Text('Alineación guardada exitosamente'),
          ),
        );
        widget.onLineupCreated();
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Error al guardar: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        _controller.isLoadingSignal.value = false;
      }
    }
  }
} 