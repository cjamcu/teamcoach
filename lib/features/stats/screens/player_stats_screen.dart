import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get_it/get_it.dart';
import '../services/stats_service.dart';
import '../widgets/stat_card.dart';
import '../../roster/services/player_service.dart';
import '../../../shared/models/player.dart';

class PlayerStatsScreen extends StatefulWidget {
  final String playerId;

  const PlayerStatsScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  final _statsService = GetIt.I<StatsService>();
  final _playerService = GetIt.I<PlayerService>();
  
  // Use signals instead of setState
  late final Signal<Player?> player;
  late final Signal<PlayerStats?> playerStats;
  late final Signal<List<GameStats>> gameStats;
  late final Signal<bool> isLoading;
  late final Signal<String?> error;

  @override
  void initState() {
    super.initState();
    
    // Initialize signals
    player = signal(null);
    playerStats = signal(null);
    gameStats = signal([]);
    isLoading = signal(true);
    error = signal(null);
    
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    isLoading.value = true;
    error.value = null;

    try {
      // Load player information
      final loadedPlayer = await _playerService.getPlayer(widget.playerId);
      player.value = loadedPlayer;
      
      // Load all plays to calculate stats
      await _statsService.loadAllPlays();
      
      // Get player specific stats
      final allPlayerStats = _statsService.playerStats.value;
      final foundPlayerStats = allPlayerStats.where(
        (stats) => stats.playerId == widget.playerId
      ).firstOrNull;
      
      if (foundPlayerStats != null) {
        playerStats.value = foundPlayerStats;
      } else {
        // Create empty stats if player has no plays
        playerStats.value = PlayerStats(
          playerId: widget.playerId,
          playerName: loadedPlayer?.name ?? 'Unknown',
          playerNumber: loadedPlayer?.number ?? 0,
          gamesPlayed: 0,
          atBats: 0,
          hits: 0,
          runs: 0,
          rbis: 0,
          singles: 0,
          doubles: 0,
          triples: 0,
          homeRuns: 0,
          walks: 0,
          strikeouts: 0,
          stolenBases: 0,
          battingAverage: 0.0,
          onBasePercentage: 0.0,
          sluggingPercentage: 0.0,
          ops: 0.0,
        );
      }

      // Get game-by-game stats
      final loadedGameStats = await _statsService.getPlayerGameStats(widget.playerId);
      gameStats.value = loadedGameStats;

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
        final currentPlayer = player.value;
        final currentPlayerStats = playerStats.value;
        final currentGameStats = gameStats.value;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              currentPlayer?.name ?? 'Jugador',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              ShadButton.ghost(
                onPressed: _loadPlayerData,
                child: const Icon(LucideIcons.refreshCw, size: 20),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorState(errorMessage)
                  : _buildContent(currentPlayer, currentPlayerStats, currentGameStats),
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
                onPressed: _loadPlayerData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Player? currentPlayer, PlayerStats? currentPlayerStats, List<GameStats> currentGameStats) {
    return RefreshIndicator(
      onRefresh: _loadPlayerData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Info Card
            _buildPlayerInfoCard(currentPlayer),
            const SizedBox(height: 24),

            // Stats Overview
            if (currentPlayerStats != null) _buildStatsOverview(currentPlayerStats),
            const SizedBox(height: 24),

            // Detailed Stats
            if (currentPlayerStats != null) _buildDetailedStats(currentPlayerStats),
            const SizedBox(height: 24),

            // Game by Game
            _buildGameByGameStats(currentGameStats),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfoCard(Player? currentPlayer) {
    final theme = Theme.of(context);
    
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  '${currentPlayer?.number ?? 0}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPlayer?.name ?? 'Jugador',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Posiciones: ${currentPlayer?.positions.join(", ") ?? "N/A"}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Bateo: ${currentPlayer?.battingSide ?? "N/A"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Lanza: ${currentPlayer?.throwingSide ?? "N/A"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(PlayerStats stats) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Temporada',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Promedio',
                value: stats.battingAverageDisplay,
                icon: LucideIcons.target,
                iconColor: _getBattingAverageColor(stats.battingAverage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'OPS',
                value: stats.ops.toStringAsFixed(3),
                icon: LucideIcons.zap,
                iconColor: _getOPSColor(stats.ops),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Hits',
                value: '${stats.hits}',
                subtitle: '${stats.atBats} VB',
                icon: LucideIcons.circle,
                iconColor: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Carreras',
                value: '${stats.runs}',
                icon: LucideIcons.flag,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'CI',
                value: '${stats.rbis}',
                icon: LucideIcons.users,
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedStats(PlayerStats stats) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Detalladas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Juegos Jugados', '${stats.gamesPlayed}'),
                _buildStatRow('Turnos al Bate', '${stats.atBats}'),
                _buildStatRow('Hits', '${stats.hits}'),
                _buildStatRow('Dobles', '${stats.doubles}'),
                _buildStatRow('Triples', '${stats.triples}'),
                _buildStatRow('Jonrones', '${stats.homeRuns}'),
                _buildStatRow('Carreras', '${stats.runs}'),
                _buildStatRow('Carreras Impulsadas', '${stats.rbis}'),
                _buildStatRow('Bases por Bolas', '${stats.walks}'),
                _buildStatRow('Ponches', '${stats.strikeouts}'),
                const Divider(),
                _buildStatRow('% En Base', _formatPercentage(stats.onBasePercentage)),
                _buildStatRow('% de Slugging', _formatPercentage(stats.sluggingPercentage)),
                _buildStatRow('OPS', stats.ops.toStringAsFixed(3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameByGameStats(List<GameStats> currentGameStats) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Juego',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: currentGameStats.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No hay juegos registrados'),
                    ),
                  )
                : Column(
                    children: currentGameStats
                        .map((gameStats) => _buildGameStatsRow(gameStats))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatsRow(GameStats gameStats) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              gameStats.opponent,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '${gameStats.atBats}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              '${gameStats.hits}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              '${gameStats.runs}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              '${gameStats.rbis}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBattingAverageColor(double avg) {
    if (avg >= 0.300) return Colors.green.shade600;
    if (avg >= 0.250) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getOPSColor(double ops) {
    if (ops >= 0.800) return Colors.green.shade600;
    if (ops >= 0.700) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _formatPercentage(double value) {
    return value > 0 
        ? '.${(value * 1000).toStringAsFixed(0).padLeft(3, '0')}'
        : '.000';
  }
} 