import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../controllers/active_game_controller.dart';
import '../models/play.dart';

class PlayHistoryWidget extends StatelessWidget {
  final ActiveGameController controller;

  const PlayHistoryWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  LucideIcons.history,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Historial de Jugadas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Watch((context) {
                  final playCount = controller.playsSignal.value.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$playCount',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Plays list
        Expanded(
          child: Watch((context) {
            final plays = controller.playsSignal.value;
            
            if (plays.isEmpty) {
              return Card(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clipboardList,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay jugadas registradas',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Las jugadas aparecerán aquí a medida que se registren',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            
            // Sort plays by timestamp (most recent first)
            final sortedPlays = [...plays]
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            
            return ListView.builder(
              itemCount: sortedPlays.length,
              itemBuilder: (context, index) {
                final play = sortedPlays[index];
                final isLast = index == sortedPlays.length - 1;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  child: _buildPlayCard(context, play, index + 1),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPlayCard(BuildContext context, Play play, int sequenceNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Sequence number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getPlayTypeColor(play.playType),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$sequenceNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Play info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            play.displayResult,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          _buildPlayTypeChip(context, play),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Inning ${play.inning} • Turno ${play.atBatNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Stats row (if applicable)
            if (play.rbi > 0 || play.runsScored > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (play.rbi > 0) ...[
                    _buildStatChip(context, 'RBI', '${play.rbi}', Colors.blue),
                    const SizedBox(width: 8),
                  ],
                  if (play.runsScored > 0)
                    _buildStatChip(context, 'Carreras', '${play.runsScored}', Colors.green),
                ],
              ),
            ],
            
            // Notes (if any)
            if (play.notes != null && play.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        play.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Timestamp
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm:ss').format(play.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayTypeChip(BuildContext context, Play play) {
    final color = _getPlayTypeColor(play.playType);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getPlayTypeDisplay(play.playType),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlayTypeColor(String playType) {
    switch (playType) {
      case 'hit':
        return Colors.green;
      case 'out':
        return Colors.red;
      case 'walk':
        return Colors.blue;
      case 'strikeout':
        return Colors.orange;
      case 'error':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getPlayTypeDisplay(String playType) {
    switch (playType) {
      case 'hit':
        return 'HIT';
      case 'out':
        return 'OUT';
      case 'walk':
        return 'BB';
      case 'strikeout':
        return 'K';
      case 'error':
        return 'E';
      default:
        return playType.toUpperCase();
    }
  }
} 