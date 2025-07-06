import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get_it/get_it.dart';
import '../services/stats_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/player_stats_table.dart';
import '../widgets/batting_average_chart.dart';

class SeasonStatsScreen extends StatefulWidget {
  const SeasonStatsScreen({super.key});

  @override
  State<SeasonStatsScreen> createState() => _SeasonStatsScreenState();
}

class _SeasonStatsScreenState extends State<SeasonStatsScreen>
    with TickerProviderStateMixin {
  final _statsService = GetIt.I<StatsService>();
  late final TabController _tabController;

  // Use signals instead of setState
  late final Signal<bool> isLoading;
  late final Signal<String?> error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize signals
    isLoading = signal(false);
    error = signal(null);
    
    _loadSeasonStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSeasonStats() async {
    isLoading.value = true;
    error.value = null;

    try {
      await _statsService.loadAllPlays();
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
        final playerStats = _statsService.playerStats.value;
        final teamStats = _statsService.teamStats.value;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Estadísticas de Temporada',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              ShadButton.ghost(
                onPressed: _loadSeasonStats,
                child: const Icon(LucideIcons.refreshCw, size: 20),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorState(errorMessage)
                  : _buildContent(playerStats, teamStats),
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
                onPressed: _loadSeasonStats,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<PlayerStats> playerStats, TeamStats? teamStats) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Jugadores'),
              Tab(text: 'Gráficas'),
            ],
          ),
        ),
        // Tab Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadSeasonStats,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(playerStats, teamStats),
                _buildPlayersTab(playerStats),
                _buildChartsTab(playerStats),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(List<PlayerStats> playerStats, TeamStats? teamStats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Stats
          if (teamStats != null) _buildTeamStatsSection(teamStats),
          const SizedBox(height: 24),

          // Top Performers
          _buildTopPerformersSection(playerStats),
        ],
      ),
    );
  }

  Widget _buildPlayersTab(List<PlayerStats> playerStats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PlayerStatsTable(
        playerStats: playerStats,
        onPlayerTap: null, // Could navigate to individual player stats
      ),
    );
  }

  Widget _buildChartsTab(List<PlayerStats> playerStats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promedios de Bateo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BattingAverageChart(
            playerStats: playerStats,
            showTopPlayersOnly: true,
          ),
          const SizedBox(height: 32),
          
          Text(
            'Distribución de Estadísticas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsDistribution(playerStats),
        ],
      ),
    );
  }

  Widget _buildTeamStatsSection(TeamStats teamStats) {
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
                title: 'Récord',
                value: '${teamStats.wins}-${teamStats.losses}',
                subtitle: '${(teamStats.winPercentage * 100).toStringAsFixed(1)}%',
                icon: LucideIcons.trophy,
                iconColor: teamStats.winPercentage > 0.5 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Promedio',
                value: teamStats.teamBattingAverage > 0
                    ? '.${(teamStats.teamBattingAverage * 1000).toStringAsFixed(0).padLeft(3, '0')}'
                    : '.000',
                icon: LucideIcons.target,
                iconColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Carreras x Juego',
                value: teamStats.averageRunsPerGame.toStringAsFixed(1),
                icon: LucideIcons.zap,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Juegos',
                value: '${teamStats.totalGames}',
                subtitle: 'Completados',
                icon: LucideIcons.calendar,
                iconColor: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPerformersSection(List<PlayerStats> playerStats) {
    final theme = Theme.of(context);
    
    // Get top performers
    final topHitters = [...playerStats]
      ..sort((a, b) => b.battingAverage.compareTo(a.battingAverage))
      ..take(3);
    
    final topRBI = [...playerStats]
      ..sort((a, b) => b.rbis.compareTo(a.rbis))
      ..take(3);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mejores Rendimientos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Top Hitters
        Text(
          'Mejor Promedio',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: topHitters
                  .map((stats) => _buildLeaderRow(
                      stats.playerName,
                      stats.battingAverageDisplay,
                      stats.playerNumber))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Top RBI
        Text(
          'Más Carreras Impulsadas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: topRBI
                  .map((stats) => _buildLeaderRow(
                      stats.playerName,
                      '${stats.rbis}',
                      stats.playerNumber))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderRow(String playerName, String value, int playerNumber) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '$playerNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              playerName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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

  Widget _buildStatsDistribution(List<PlayerStats> playerStats) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Distribución de Rendimiento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDistributionRow(
              'Promedio > .300',
              playerStats.where((p) => p.battingAverage > 0.300).length,
              playerStats.length,
              Colors.green,
            ),
            _buildDistributionRow(
              'Promedio .250-.300',
              playerStats.where((p) => p.battingAverage >= 0.250 && p.battingAverage <= 0.300).length,
              playerStats.length,
              Colors.orange,
            ),
            _buildDistributionRow(
              'Promedio < .250',
              playerStats.where((p) => p.battingAverage < 0.250).length,
              playerStats.length,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 