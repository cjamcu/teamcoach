import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get_it/get_it.dart';
import '../services/stats_service.dart';
import '../widgets/stat_card.dart';
import '../../games/services/game_service.dart';
import '../../../shared/models/game.dart';

class GameStatsScreen extends StatefulWidget {
  final String gameId;

  const GameStatsScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<GameStatsScreen> createState() => _GameStatsScreenState();
}

class _GameStatsScreenState extends State<GameStatsScreen> {
  final _statsService = GetIt.I<StatsService>();
  final _gameService = GetIt.I<GameService>();
  
  // Use signals instead of setState
  late final Signal<Game?> game;
  late final Signal<List<PlayerStats>> gamePlayerStats;
  late final Signal<TeamStats?> gameTeamStats;
  late final Signal<bool> isLoading;
  late final Signal<String?> error;

  @override
  void initState() {
    super.initState();
    
    // Initialize signals
    game = signal(null);
    gamePlayerStats = signal([]);
    gameTeamStats = signal(null);
    isLoading = signal(true);
    error = signal(null);
    
    _loadGameStats();
  }

  Future<void> _loadGameStats() async {
    isLoading.value = true;
    error.value = null;

    try {
      // Load game information
      final loadedGame = await _gameService.getGame(widget.gameId);
      game.value = loadedGame;
      
      // Calculate game specific stats
      final loadedGamePlayerStats = await _statsService.getGamePlayerStats(widget.gameId);
      gamePlayerStats.value = loadedGamePlayerStats;
      
      final loadedGameTeamStats = await _statsService.getGameTeamStats(widget.gameId);
      gameTeamStats.value = loadedGameTeamStats;

    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch(
      (context) {
        final loading = isLoading.value;
        final errorMessage = error.value;
        final currentGame = game.value;
        final currentGamePlayerStats = gamePlayerStats.value;
        final currentGameTeamStats = gameTeamStats.value;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              currentGame != null ? 'vs ${currentGame.opponent}' : 'Estadísticas del Juego',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              ShadButton.ghost(
                onPressed: _loadGameStats,
                child: const Icon(LucideIcons.refreshCw, size: 20),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorState(errorMessage)
                  : _buildContent(currentGame, currentGameTeamStats, currentGamePlayerStats),
        );
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: ShadCard(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.x,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ShadButton(
                onPressed: _loadGameStats,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Game? currentGame, TeamStats? currentGameTeamStats, List<PlayerStats> currentGamePlayerStats) {
    return RefreshIndicator(
      onRefresh: _loadGameStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Info Card
            if (currentGame != null) _buildGameInfoCard(currentGame),
            const SizedBox(height: 24),

            // Team Stats
            if (currentGameTeamStats != null) _buildTeamStatsSection(currentGameTeamStats),
            const SizedBox(height: 24),

            // Player Stats
            _buildPlayerStatsSection(currentGamePlayerStats),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfoCard(Game currentGame) {
    final theme = Theme.of(context);
    
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  currentGame.isHome ? LucideIcons.house : LucideIcons.plane,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${currentGame.isHome ? "vs" : "@"} ${currentGame.opponent}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentGame.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(currentGame.status),
                    style: TextStyle(
                      color: _getStatusColor(currentGame.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Fecha',
                    _formatDate(currentGame.gameDate),
                    LucideIcons.calendar,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Lugar',
                    currentGame.location,
                    LucideIcons.mapPin,
                  ),
                ),
              ],
            ),
            if (currentGame.status == 'completed') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Nosotros',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${currentGame.finalScoreTeam ?? 0}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (currentGame.finalScoreTeam ?? 0) > (currentGame.finalScoreOpponent ?? 0)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '-',
                    style: theme.textTheme.headlineMedium,
                  ),
                  Column(
                    children: [
                      Text(
                        currentGame.opponent,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${currentGame.finalScoreOpponent ?? 0}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (currentGame.finalScoreOpponent ?? 0) > (currentGame.finalScoreTeam ?? 0)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamStatsSection(TeamStats stats) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas del Equipo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Carreras',
                value: '${stats.totalRuns}',
                icon: LucideIcons.target,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Hits',
                value: '${stats.totalHits}',
                subtitle: '${stats.totalAtBats} VB',
                icon: LucideIcons.circle,
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Promedio',
                value: stats.teamBattingAverage > 0
                    ? '.${(stats.teamBattingAverage * 1000).toStringAsFixed(0).padLeft(3, '0')}'
                    : '.000',
                icon: LucideIcons.zap,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'CI Total',
                value: '${stats.totalHits}', // Aproximación
                icon: LucideIcons.users,
                iconColor: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerStatsSection(List<PlayerStats> currentGamePlayerStats) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas por Jugador',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: currentGamePlayerStats.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No hay estadísticas de jugadores disponibles'),
                    ),
                  )
                : Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Jugador',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'VB',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'H',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'C',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'CI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'AVG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Player rows
                      ...currentGamePlayerStats.map((stats) => _buildPlayerStatsRow(stats)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerStatsRow(PlayerStats stats) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${stats.playerNumber}',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stats.playerName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${stats.atBats}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              '${stats.hits}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              '${stats.runs}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              '${stats.rbis}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              stats.battingAverageDisplay,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programado';
      case 'in_progress':
        return 'En Progreso';
      case 'completed':
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 