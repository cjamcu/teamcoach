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
        border: Border.all(color: Theme.of(context).dividerColor),
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
        
        // Calculate column widths based on innings
        final Map<int, TableColumnWidth> columnWidths = {
          0: const FixedColumnWidth(80), // Team name column
        };
        
        // Add innings columns
        for (int i = 1; i <= totalInnings; i++) {
          columnWidths[i] = const FixedColumnWidth(40);
        }
        
        // Add total columns
        columnWidths[totalInnings + 1] = const FixedColumnWidth(60); // R
        columnWidths[totalInnings + 2] = const FixedColumnWidth(60); // H
        columnWidths[totalInnings + 3] = const FixedColumnWidth(60); // E
        
        return Table(
          columnWidths: columnWidths,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
            verticalInside: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
              ),
              children: [
                _buildTeamNameCell(context, 'Nosotros', isTop),
                for (int i = 1; i <= totalInnings; i++)
                  _buildScoreCell(
                    context,
                    teamScores[i]?.toString() ?? '',
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
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
              ),
              children: [
                _buildTeamNameCell(context, controller.gameSignal.value?.opponent ?? 'Visitante', !isTop),
                for (int i = 1; i <= totalInnings; i++)
                  _buildScoreCell(
                    context,
                    opponentScores[i]?.toString() ?? '',
                    isActive: !isTop && i == currentInning,
                  ),
                _buildTotalCell(context, opponentTotal.toString()),
                _buildTotalCell(context, '-'), // Hits placeholder
                _buildTotalCell(context, '-'), // Errors placeholder
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamNameCell(BuildContext context, String name, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          if (isActive)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : null,
      ),
      child: Center(
        child: Text(
          score,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCell(BuildContext context, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Center(
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxCount, (index) {
            final isActive = index < count;
            return Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : Colors.grey.shade300,
                border: Border.all(
                  color: isActive ? activeColor.withOpacity(0.8) : Colors.grey.shade400,
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
} 