import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:teamcoach/features/games/services/game_service.dart';
import 'package:teamcoach/shared/widgets/game_card.dart';
import 'package:teamcoach/features/plays/screens/active_game_screen.dart';
import 'package:teamcoach/features/games/screens/lineup_builder_screen.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  final _gameService = GetIt.I<GameService>();
  final _searchController = TextEditingController();
  final Map<String, bool> _gameLineupCache = {};
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _gameService.updateSearchQuery(_searchController.text);
    });
  }

  Future<bool> _checkGameLineup(String gameId) async {
    if (_gameLineupCache.containsKey(gameId)) {
      return _gameLineupCache[gameId]!;
    }
    
    final hasLineup = await _gameService.hasGameLineup(gameId);
    _gameLineupCache[gameId] = hasLineup;
    return hasLineup;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _showDeleteConfirmation(BuildContext context, String gameId, String opponent) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Confirmar Eliminación'),
        description: Text('¿Estás seguro de que deseas eliminar el juego vs $opponent? Esta acción no se puede deshacer.'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Eliminar'),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _gameService.deleteGame(gameId);
                if (mounted) {
                  ShadToaster.of(context).show(
                    const ShadToast(
                      title: Text('Éxito'),
                      description: Text('Juego eliminado exitosamente'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('Error'),
                      description: Text('Error al eliminar juego: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showFinishGameDialog(BuildContext context, String gameId) {
    final teamScoreController = TextEditingController();
    final opponentScoreController = TextEditingController();
    
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Finalizar Juego'),
        description: const Text('Ingresa el marcador final del juego'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ShadInputFormField(
                    controller: teamScoreController,
                    placeholder: const Text('0'),
                    label: const Text('Nuestro marcador'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ShadInputFormField(
                    controller: opponentScoreController,
                    placeholder: const Text('0'),
                    label: const Text('Marcador rival'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ShadButton(
            child: const Text('Finalizar'),
            onPressed: () async {
              final teamScore = int.tryParse(teamScoreController.text) ?? 0;
              final opponentScore = int.tryParse(opponentScoreController.text) ?? 0;
              
              Navigator.of(context).pop();
              try {
                await _gameService.finishGame(gameId, teamScore, opponentScore);
                if (mounted) {
                  ShadToaster.of(context).show(
                    const ShadToast(
                      title: Text('Éxito'),
                      description: Text('Juego finalizado exitosamente'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('Error'),
                      description: Text('Error al finalizar juego: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Navegar al ActiveGameScreen con alineación
  Future<void> _navigateToActiveGame(String gameId) async {
    try {
      // Obtener el juego y la alineación
      final game = _gameService.games.value.firstWhere((g) => g.id == gameId);
      final lineup = await _gameService.getGameLineup(gameId);

      if (lineup.isEmpty) {
        // Si no hay alineación, ir a crear alineación
        if (mounted) {
          _navigateToLineupBuilder(gameId);
        }
        return;
      }

      // Navegar al ActiveGameScreen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActiveGameScreen(
              game: game,
              lineup: lineup,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Error al abrir juego: $e'),
          ),
        );
      }
    }
  }

  // Navegar a crear alineación
  void _navigateToLineupBuilder(String gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LineupBuilderScreen(
          gameId: gameId,
          onLineupCreated: () {
            // Actualizar caché
            _gameLineupCache[gameId] = true;
            // Una vez creada la alineación, ir al ActiveGameScreen
            Navigator.of(context).pop(); // Cerrar LineupBuilder
            _navigateToActiveGame(gameId); // Ir a ActiveGameScreen
          },
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Watch(
      (context) {
        final isLoading = _gameService.isLoading.value;
        final error = _gameService.error.value;
        final games = _gameService.filteredGames.value;
        final statusFilter = _gameService.statusFilter.value;
        
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Juegos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Barra de búsqueda y filtros
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    ShadInput(
                      controller: _searchController,
                      placeholder: const Text('Buscar por oponente o ubicación...'),
                    ),
                    const SizedBox(height: 12),
                    // Filtros de estado
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, 'all', 'Todos', statusFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, 'scheduled', 'Programados', statusFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, 'in_progress', 'En Curso', statusFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, 'completed', 'Finalizados', statusFilter),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de juegos
              Expanded(
                child: isLoading && games.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando juegos...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : error != null
                        ? Center(
                            child: ShadCard(
                              width: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: theme.colorScheme.error,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error al cargar',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ShadButton(
                                      onPressed: _gameService.loadGames,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : games.isEmpty
                            ? Center(
                                child: ShadCard(
                                  width: 320,
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.sports_baseball,
                                            color: theme.colorScheme.onSurfaceVariant,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _searchController.text.isEmpty
                                              ? 'No hay juegos'
                                              : 'Sin resultados',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _searchController.text.isEmpty
                                              ? 'Programa el primer juego de la temporada'
                                              : 'Intenta con otros términos de búsqueda',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                        if (_searchController.text.isEmpty) ...[
                                          const SizedBox(height: 20),
                                          ShadButton(
                                            onPressed: () => context.go('/games/create'),
                                            child: const Text('Crear Juego'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _gameService.loadGames,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                  itemCount: games.length,
                                  itemBuilder: (context, index) {
                                    final game = games[index];
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: FutureBuilder<bool>(
                                        future: _checkGameLineup(game.id),
                                        builder: (context, snapshot) {
                                          final hasLineup = snapshot.data ?? false;
                                          
                                          return GameCard(
                                            game: game,
                                            hasLineup: hasLineup,
                                            onTap: () {
                                              // Si el juego está en progreso, ir al ActiveGameScreen
                                              if (game.isInProgress) {
                                                _navigateToActiveGame(game.id);
                                              } else {
                                                // Para otros estados, ir a los detalles del juego
                                                context.go('/games/${game.id}');
                                              }
                                            },
                                            onEdit: () => context.go('/games/${game.id}/edit'),
                                            onDelete: () => _showDeleteConfirmation(
                                              context,
                                              game.id,
                                              game.opponent,
                                            ),
                                            onConfigureLineup: () => _navigateToLineupBuilder(game.id),
                                            onStart: () async {
                                              try {
                                                await _gameService.startGame(game.id);
                                                if (mounted) {
                                                  ShadToaster.of(context).show(
                                                    const ShadToast(
                                                      title: Text('Éxito'),
                                                      description: Text('Juego iniciado'),
                                                    ),
                                                  );
                                                  // Navegar automáticamente al ActiveGameScreen
                                                  _navigateToActiveGame(game.id);
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ShadToaster.of(context).show(
                                                    ShadToast.destructive(
                                                      title: const Text('Error'),
                                                      description: Text('Error al iniciar juego: $e'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            onFinish: () => _showFinishGameDialog(context, game.id),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
          floatingActionButton: ShadButton(
            onPressed: () => context.go('/games/create'),
            size: ShadButtonSize.lg,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text('Nuevo Juego'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label, String currentFilter) {
    final theme = Theme.of(context);
    final isSelected = currentFilter == value;
    
    return InkWell(
      onTap: () => _gameService.updateStatusFilter(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 