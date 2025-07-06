import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:teamcoach/shared/models/game.dart';
import 'package:teamcoach/core/utils/validators.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStart;
  final VoidCallback? onFinish;
  final VoidCallback? onConfigureLineup;
  final bool hasLineup;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStart,
    this.onFinish,
    this.onConfigureLineup,
    this.hasLineup = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ShadCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: game.isInProgress ? BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.orange,
              width: 2,
            ),
          ) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador especial para juegos en progreso
                if (game.isInProgress) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Toca para anotar jugadas',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Header con oponente y estado
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs ${game.opponent}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                game.isHome ? Icons.home : Icons.flight_takeoff,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                game.isHome ? 'Local' : 'Visitante',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Información del juego
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Formatters.formatDate(game.gameDate),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Formatters.formatTime(game.gameDate),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (game.location.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    game.location,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ubicación sin especificar',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Marcador si está finalizado
                    if (game.isCompleted) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getResultColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getResultColor(context).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              game.scoreDisplay,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getResultColor(context),
                              ),
                            ),
                            Text(
                              _getResultText(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getResultColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Acciones
                if (_hasActions()) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (game.isScheduled && !hasLineup && onConfigureLineup != null) ...[
                        ShadButton(
                          onPressed: onConfigureLineup,
                          size: ShadButtonSize.sm,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings, size: 16),
                              SizedBox(width: 4),
                              Text('Alineación'),
                            ],
                          ),
                        ),
                      ] else if (game.isScheduled && hasLineup && onStart != null) ...[
                        ShadButton.outline(
                          onPressed: onStart,
                          size: ShadButtonSize.sm,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow, size: 16),
                              SizedBox(width: 4),
                              Text('Iniciar'),
                            ],
                          ),
                        ),
                      ],
                      if (game.isInProgress && onFinish != null) ...[
                        ShadButton(
                          onPressed: onFinish,
                          size: ShadButtonSize.sm,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stop, size: 16),
                              SizedBox(width: 4),
                              Text('Finalizar'),
                            ],
                          ),
                        ),
                      ],
                      if (onEdit != null) ...[
                        ShadButton.outline(
                          onPressed: onEdit,
                          size: ShadButtonSize.sm,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 4),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      ],
                      if (onDelete != null) ...[
                        ShadButton.outline(
                          onPressed: onDelete,
                          size: ShadButtonSize.sm,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 4),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    Color badgeColor;
    IconData icon;
    
    switch (game.status) {
      case 'scheduled':
        badgeColor = theme.colorScheme.primary;
        icon = Icons.schedule;
        break;
      case 'in_progress':
        badgeColor = Colors.orange;
        icon = Icons.play_circle;
        break;
      case 'completed':
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        badgeColor = theme.colorScheme.outline;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            game.statusDisplay,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getResultColor(BuildContext context) {
    final theme = Theme.of(context);
    if (game.isWin) return Colors.green;
    if (game.isLoss) return Colors.red;
    return theme.colorScheme.outline; // Empate
  }

  String _getResultText() {
    if (game.isWin) return 'VICTORIA';
    if (game.isLoss) return 'DERROTA';
    return 'EMPATE';
  }

  bool _hasActions() {
    return (game.isScheduled && !hasLineup && onConfigureLineup != null) ||
           (game.isScheduled && hasLineup && onStart != null) ||
           (game.isInProgress && onFinish != null) ||
           onEdit != null ||
           onDelete != null;
  }
} 