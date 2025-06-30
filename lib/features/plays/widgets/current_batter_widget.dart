import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../controllers/active_game_controller.dart';

class CurrentBatterWidget extends StatelessWidget {
  final ActiveGameController controller;

  const CurrentBatterWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final currentBatter = controller.currentBatterSignal.value;
      
      if (currentBatter == null) {
        return ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No hay bateador asignado',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ),
          ),
        );
      }

      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    LucideIcons.target,
                    size: 20,
                    color: ShadTheme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bateador Actual',
                    style: ShadTheme.of(context).textTheme.small.copyWith(
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ShadTheme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${currentBatter.battingOrder}',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: ShadTheme.of(context).colorScheme.primaryForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Batter info
              Row(
                children: [
                  // Player avatar/number
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: ShadTheme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: ShadTheme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${currentBatter.displayNumber}',
                        style: ShadTheme.of(context).textTheme.h3.copyWith(
                          color: ShadTheme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Player details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentBatter.displayName,
                          style: ShadTheme.of(context).textTheme.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildInfoChip(
                              context,
                              currentBatter.startingPosition,
                              LucideIcons.mapPin,
                            ),
                            const SizedBox(width: 8),
                            if (currentBatter.player?.battingSide != null)
                              _buildInfoChip(
                                context,
                                _getBattingSideDisplay(currentBatter.player!.battingSide),
                                LucideIcons.zap,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // At-bat info
              Watch((context) {
                final atBat = controller.atBatCountSignal.value;
                final inning = controller.inningDisplaySignal.value;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ShadTheme.of(context).colorScheme.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Turno al Bat',
                        '#$atBat',
                        LucideIcons.hash,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: ShadTheme.of(context).colorScheme.border,
                      ),
                      _buildStatItem(
                        context,
                        'Inning',
                        inning,
                        LucideIcons.clock,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: ShadTheme.of(context).colorScheme.secondaryForeground,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: ShadTheme.of(context).textTheme.small.copyWith(
              color: ShadTheme.of(context).colorScheme.secondaryForeground,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: ShadTheme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ShadTheme.of(context).textTheme.p.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: ShadTheme.of(context).textTheme.small.copyWith(
            color: ShadTheme.of(context).colorScheme.mutedForeground,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getBattingSideDisplay(String battingSide) {
    switch (battingSide) {
      case 'left':
        return 'Zurdo';
      case 'right':
        return 'Diestro';
      case 'switch':
        return 'Ambos';
      default:
        return battingSide;
    }
  }
} 