import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/stats_service.dart';

class PlayerStatsTable extends StatelessWidget {
  final List<PlayerStats> playerStats;
  final Function(PlayerStats)? onPlayerTap;
  final String sortBy;
  final bool ascending;
  final Function(String)? onSort;

  const PlayerStatsTable({
    super.key,
    required this.playerStats,
    this.onPlayerTap,
    this.sortBy = 'battingAverage',
    this.ascending = false,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (playerStats.isEmpty) {
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay estadísticas disponibles',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Las estadísticas se mostrarán cuando haya jugadas registradas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ShadCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          dataRowMinHeight: 56,
          headingRowHeight: 64,
          columns: [
            _buildDataColumn('Jugador', 'playerName'),
            _buildDataColumn('#', 'playerNumber'),
            _buildDataColumn('J', 'gamesPlayed'),
            _buildDataColumn('VB', 'atBats'),
            _buildDataColumn('H', 'hits'),
            _buildDataColumn('C', 'runs'),
            _buildDataColumn('CI', 'rbis'),
            _buildDataColumn('2B', 'doubles'),
            _buildDataColumn('3B', 'triples'),
            _buildDataColumn('HR', 'homeRuns'),
            _buildDataColumn('BB', 'walks'),
            _buildDataColumn('K', 'strikeouts'),
            _buildDataColumn('AVG', 'battingAverage'),
            _buildDataColumn('OBP', 'onBasePercentage'),
            _buildDataColumn('SLG', 'sluggingPercentage'),
            _buildDataColumn('OPS', 'ops'),
          ],
          rows: playerStats.map((stats) => _buildDataRow(context, stats)).toList(),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, String field) {
    return DataColumn(
      label: InkWell(
        onTap: onSort != null ? () => onSort!(field) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (onSort != null) ...[
              const SizedBox(width: 4),
              Icon(
                sortBy == field
                    ? (ascending ? LucideIcons.chevronUp : LucideIcons.chevronDown)
                    : LucideIcons.chevronsUpDown,
                size: 12,
                color: sortBy == field ? Colors.blue : Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, PlayerStats stats) {
    final theme = Theme.of(context);
    
    return DataRow(
      onSelectChanged: onPlayerTap != null ? (_) => onPlayerTap!(stats) : null,
      cells: [
        // Player name
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
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
                    '${stats.playerNumber}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  stats.playerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text('${stats.playerNumber}')),
        DataCell(Text('${stats.gamesPlayed}')),
        DataCell(Text('${stats.atBats}')),
        DataCell(Text('${stats.hits}')),
        DataCell(Text('${stats.runs}')),
        DataCell(Text('${stats.rbis}')),
        DataCell(Text('${stats.doubles}')),
        DataCell(Text('${stats.triples}')),
        DataCell(Text('${stats.homeRuns}')),
        DataCell(Text('${stats.walks}')),
        DataCell(Text('${stats.strikeouts}')),
        DataCell(
          Text(
            stats.battingAverageDisplay,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getBattingAverageColor(stats.battingAverage),
            ),
          ),
        ),
        DataCell(
          Text(
            _formatPercentage(stats.onBasePercentage),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            _formatPercentage(stats.sluggingPercentage),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            _formatOPS(stats.ops),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getOPSColor(stats.ops),
            ),
          ),
        ),
      ],
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

  String _formatOPS(double ops) {
    return ops.toStringAsFixed(3);
  }
} 