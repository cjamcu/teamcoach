import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get_it/get_it.dart';
import '../services/stats_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/player_stats_table.dart';
import '../widgets/batting_average_chart.dart';
import 'player_stats_screen.dart';

class TeamStatsScreen extends StatefulWidget {
  const TeamStatsScreen({super.key});

  @override
  State<TeamStatsScreen> createState() => _TeamStatsScreenState();
}

class _TeamStatsScreenState extends State<TeamStatsScreen>
    with TickerProviderStateMixin {
  final _statsService = GetIt.I<StatsService>();
  late final TabController _tabController;
  
  // Use signals instead of setState
  late final Signal<String> sortBy;
  late final Signal<bool> ascending;
  late final Signal<bool> isLoading;
  late final Signal<String?> error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize signals
    sortBy = signal('battingAverage');
    ascending = signal(false);
    isLoading = signal(false);
    error = signal(null);
    
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
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

  void _updateSort(String newSortBy) {
    if (sortBy.value == newSortBy) {
      ascending.value = !ascending.value;
    } else {
      sortBy.value = newSortBy;
      ascending.value = false;
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
        final currentSortBy = sortBy.value;
        final currentAscending = ascending.value;

        // Sort player stats based on current sort criteria
        final sortedPlayerStats = [...playerStats];
        sortedPlayerStats.sort((a, b) {
          dynamic aValue, bValue;
          
          switch (currentSortBy) {
            case 'name':
              aValue = a.playerName;
              bValue = b.playerName;
              break;
            case 'battingAverage':
              aValue = a.battingAverage;
              bValue = b.battingAverage;
              break;
            case 'hits':
              aValue = a.hits;
              bValue = b.hits;
              break;
            case 'runs':
              aValue = a.runs;
              bValue = b.runs;
              break;
            case 'rbis':
              aValue = a.rbis;
              bValue = b.rbis;
              break;
            case 'homeRuns':
              aValue = a.homeRuns;
              bValue = b.homeRuns;
              break;
            case 'ops':
              aValue = a.ops;
              bValue = b.ops;
              break;
            default:
              aValue = a.battingAverage;
              bValue = b.battingAverage;
          }
          
          final comparison = aValue.compareTo(bValue);
          return currentAscending ? comparison : -comparison;
        });

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Estadísticas del Equipo',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              ShadButton.ghost(
                onPressed: _loadStats,
                child: const Icon(LucideIcons.refreshCw, size: 20),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorState(errorMessage)
                  : _buildContent(sortedPlayerStats, teamStats, currentSortBy, currentAscending),
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
                onPressed: _loadStats,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<PlayerStats> sortedPlayerStats, TeamStats? teamStats, String currentSortBy, bool currentAscending) {
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
            onRefresh: _loadStats,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(sortedPlayerStats, teamStats),
                _buildPlayersTab(sortedPlayerStats, currentSortBy, currentAscending),
                _buildChartsTab(sortedPlayerStats),
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

  Widget _buildPlayersTab(List<PlayerStats> playerStats, String currentSortBy, bool currentAscending) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PlayerStatsTable(
        playerStats: playerStats,
        sortBy: currentSortBy,
        ascending: currentAscending,
        onSort: _updateSort,
        onPlayerTap: (stats) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlayerStatsScreen(
                playerId: stats.playerId,
              ),
            ),
          );
        },
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
            'Promedios de Bateo del Equipo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BattingAverageChart(
            playerStats: playerStats,
            showTopPlayersOnly: false,
          ),
          const SizedBox(height: 32),
          
          Text(
            'Distribución de Rendimiento',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPerformanceDistribution(playerStats),
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
                title: 'Total Hits',
                value: '${teamStats.totalHits}',
                subtitle: '${teamStats.totalAtBats} VB',
                icon: LucideIcons.circle,
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPerformersSection(List<PlayerStats> playerStats) {
    final theme = Theme.of(context);
    
    if (playerStats.isEmpty) {
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  LucideIcons.users,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay estadísticas disponibles',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Get top performers
    final topHitters = [...playerStats]
      ..sort((a, b) => b.battingAverage.compareTo(a.battingAverage))
      ..take(3);
    
    final topRBI = [...playerStats]
      ..sort((a, b) => b.rbis.compareTo(a.rbis))
      ..take(3);
    
    final topOPS = [...playerStats]
      ..sort((a, b) => b.ops.compareTo(a.ops))
      ..take(3);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Líderes del Equipo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildLeaderCard('Mejor Promedio', topHitters),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLeaderCard('Más CI', topRBI),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildLeaderCard('Mejor OPS', topOPS),
      ],
    );
  }

  Widget _buildLeaderCard(String title, List<PlayerStats> leaders) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ...leaders.map((stats) => _buildLeaderItem(stats, title)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderItem(PlayerStats stats, String category) {
    final theme = Theme.of(context);
    String value;
    
    if (category.contains('Promedio')) {
      value = stats.battingAverageDisplay;
    } else if (category.contains('CI')) {
      value = '${stats.rbis}';
    } else {
      value = stats.ops.toStringAsFixed(3);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDistribution(List<PlayerStats> playerStats) {
    if (playerStats.isEmpty) {
      return const ShadCard(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay datos para mostrar'),
          ),
        ),
      );
    }

    final excellentCount = playerStats.where((p) => p.battingAverage >= 0.300).length;
    final goodCount = playerStats.where((p) => p.battingAverage >= 0.250 && p.battingAverage < 0.300).length;
    final needsImprovementCount = playerStats.where((p) => p.battingAverage < 0.250).length;
    
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de Promedios de Bateo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDistributionRow(
              'Excelente (≥ .300)',
              excellentCount,
              playerStats.length,
              Colors.green,
            ),
            _buildDistributionRow(
              'Bueno (.250 - .299)',
              goodCount,
              playerStats.length,
              Colors.orange,
            ),
            _buildDistributionRow(
              'Necesita mejorar (< .250)',
              needsImprovementCount,
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