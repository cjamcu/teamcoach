import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../controllers/active_game_controller.dart';

class ScoreboardWidget extends StatelessWidget {
  final ActiveGameController controller;

  const ScoreboardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título del juego
            Watch((context) {
              final game = controller.gameSignal.value;
              return Text(
                'vs ${game?.opponent ?? "Oponente"}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            const SizedBox(height: 16),
            
            // Tabla de innings
            _buildInningsTable(context),
            
            const SizedBox(height: 16),
            
            // Indicadores de estado (Outs, Strikes, Balls)
            _buildGameStateIndicators(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInningsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ShadTheme.of(context).colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Watch((context) {
        final teamScores = controller.teamScoreByInningSignal.value;
        final opponentScores = controller.opponentScoreByInningSignal.value;
        final currentInning = controller.currentInningSignal.value;
        final isTop = controller.isTopOfInningSignal.value;
        final teamTotal = controller.teamScoreSignal.value;
        final opponentTotal = controller.opponentScoreSignal.value;
        final totalInnings = controller.totalInningsSignal.value;
        
        // Use responsive design for better visibility
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: Table(
              columnWidths: {
                0: const FixedColumnWidth(100), // Team name column
                for (int i = 1; i <= totalInnings; i++)
                  i: const FixedColumnWidth(45), // Inning columns
                totalInnings + 1: const FixedColumnWidth(50), // R
                totalInnings + 2: const FixedColumnWidth(50), // H
                totalInnings + 3: const FixedColumnWidth(50), // E
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: ShadTheme.of(context).colorScheme.border,
                  width: 1,
                ),
                verticalInside: BorderSide(
                  color: ShadTheme.of(context).colorScheme.border,
                  width: 1,
                ),
              ),
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: ShadTheme.of(context).colorScheme.muted,
                  ),
                  children: [
                    _buildTableHeader(context, 'Equipo'),
                    for (int i = 1; i <= totalInnings; i++)
                      _buildTableHeader(context, '$i'),
                    _buildTableHeader(context, 'R', isTotal: true),
                    _buildTableHeader(context, 'H', isTotal: true),
                    _buildTableHeader(context, 'E', isTotal: true),
                  ],
                ),
                
                // Team row
                TableRow(
                  decoration: BoxDecoration(
                    color: isTop && currentInning <= totalInnings
                        ? ShadTheme.of(context).colorScheme.primary.withOpacity(0.1)
                        : ShadTheme.of(context).colorScheme.background,
                  ),
                  children: [
                    _buildTeamNameCell(context, 'Nosotros', isTop),
                    for (int i = 1; i <= totalInnings; i++)
                      _buildScoreCell(
                        context,
                        teamScores[i]?.toString() ?? '-',
                        isActive: isTop && i == currentInning,
                      ),
                    _buildTotalCell(context, teamTotal.toString()),
                    _buildTotalCell(context, '-'), // Hits placeholder
                    _buildTotalCell(context, '-'), // Errors placeholder
                  ],
                ),
                
                // Opponent row
                TableRow(
                  decoration: BoxDecoration(
                    color: !isTop && currentInning <= totalInnings
                        ? ShadTheme.of(context).colorScheme.primary.withOpacity(0.1)
                        : ShadTheme.of(context).colorScheme.background,
                  ),
                  children: [
                    _buildTeamNameCell(context, controller.gameSignal.value?.opponent ?? 'Visitante', !isTop),
                    for (int i = 1; i <= totalInnings; i++)
                      _buildScoreCell(
                        context,
                        opponentScores[i]?.toString() ?? '-',
                        isActive: !isTop && i == currentInning,
                      ),
                    _buildTotalCell(context, opponentTotal.toString()),
                    _buildTotalCell(context, '-'), // Hits placeholder
                    _buildTotalCell(context, '-'), // Errors placeholder
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Center(
        child: Text(
          text,
          style: ShadTheme.of(context).textTheme.small.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamNameCell(BuildContext context, String name, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          if (isActive)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: ShadTheme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              name,
              style: ShadTheme.of(context).textTheme.p.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive 
                    ? ShadTheme.of(context).colorScheme.primary
                    : ShadTheme.of(context).colorScheme.foreground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCell(BuildContext context, String score, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? ShadTheme.of(context).colorScheme.primary.withOpacity(0.2)
            : null,
      ),
      child: Center(
        child: Text(
          score,
          style: ShadTheme.of(context).textTheme.p.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? ShadTheme.of(context).colorScheme.primary
                : ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCell(BuildContext context, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.muted.withOpacity(0.5),
      ),
      child: Center(
        child: Text(
          value,
          style: ShadTheme.of(context).textTheme.p.copyWith(
            fontWeight: FontWeight.bold,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildGameStateIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Outs indicator
        Watch((context) {
          final outs = controller.outsSignal.value;
          return _buildIndicator(
            context,
            label: 'OUTS',
            count: outs,
            maxCount: 3,
            activeColor: Colors.red,
          );
        }),
        
        // Strikes indicator
        Watch((context) {
          final strikes = controller.strikesSignal.value;
          return _buildIndicator(
            context,
            label: 'STRIKES',
            count: strikes,
            maxCount: 3,
            activeColor: Colors.orange,
          );
        }),
        
        // Balls indicator
        Watch((context) {
          final balls = controller.ballsSignal.value;
          return _buildIndicator(
            context,
            label: 'BALLS',
            count: balls,
            maxCount: 4,
            activeColor: Colors.green,
          );
        }),
      ],
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required String label,
    required int count,
    required int maxCount,
    required Color activeColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: ShadTheme.of(context).textTheme.small.copyWith(
            fontWeight: FontWeight.bold,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxCount, (index) {
            final isActive = index < count;
            return Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : ShadTheme.of(context).colorScheme.muted,
                border: Border.all(
                  color: isActive ? activeColor.withOpacity(0.8) : ShadTheme.of(context).colorScheme.border,
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: ShadTheme.of(context).textTheme.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: count > 0 ? activeColor : ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
} 