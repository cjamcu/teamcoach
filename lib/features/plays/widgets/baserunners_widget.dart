import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../controllers/active_game_controller.dart';
import '../../../shared/models/game_lineup.dart';

class BaseRunnersWidget extends StatelessWidget {
  final ActiveGameController controller;

  const BaseRunnersWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Corredores en Base',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Baseball diamond
            SizedBox(
              height: 200,
              width: 200,
              child: Watch((context) {
                final runners = controller.runnersOnBaseSignal.value;
                final lineup = controller.lineupSignal.value;
                
                return CustomPaint(
                  painter: _DiamondPainter(
                    context: context,
                    runners: runners,
                    lineup: lineup,
                  ),
                  child: Stack(
                    children: [
                      // Home plate
                      Positioned(
                        bottom: 10,
                        left: 85,
                        child: _buildBase(
                          context,
                          label: 'H',
                          isOccupied: false,
                          isHome: true,
                        ),
                      ),
                      
                      // First base
                      Positioned(
                        right: 10,
                        top: 85,
                        child: _buildBase(
                          context,
                          label: '1B',
                          isOccupied: runners.containsKey('1B'),
                          playerName: _getPlayerName(runners['1B'], lineup),
                        ),
                      ),
                      
                      // Second base
                      Positioned(
                        top: 10,
                        left: 85,
                        child: _buildBase(
                          context,
                          label: '2B',
                          isOccupied: runners.containsKey('2B'),
                          playerName: _getPlayerName(runners['2B'], lineup),
                        ),
                      ),
                      
                      // Third base
                      Positioned(
                        left: 10,
                        top: 85,
                        child: _buildBase(
                          context,
                          label: '3B',
                          isOccupied: runners.containsKey('3B'),
                          playerName: _getPlayerName(runners['3B'], lineup),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 16),
            
            // Current batter info
            Watch((context) {
              final currentBatter = controller.currentBatterSignal.value;
              if (currentBatter == null) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Al bate: ${currentBatter.player?.name ?? "Jugador"}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String? _getPlayerName(String? playerId, List<GameLineup> lineup) {
    if (playerId == null) return null;
    
    final lineupEntry = lineup.firstWhere(
      (l) => l.playerId == playerId,
      orElse: () => GameLineup(
        id: '',
        gameId: '',
        playerId: '',
        battingOrder: 0,
        startingPosition: '',
        isStarter: false,
      ),
    );
    
    return lineupEntry.player?.name;
  }

  Widget _buildBase(
    BuildContext context, {
    required String label,
    required bool isOccupied,
    String? playerName,
    bool isHome = false,
  }) {
    final size = isHome ? 35.0 : 30.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playerName != null && isOccupied)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              playerName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOccupied
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            shape: isHome ? BoxShape.rectangle : BoxShape.circle,
            border: Border.all(
              color: isOccupied
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: 2,
            ),
            boxShadow: isOccupied
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isOccupied
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: isHome ? 14 : 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final BuildContext context;
  final Map<String, String> runners;
  final List<GameLineup> lineup;

  _DiamondPainter({
    required this.context,
    required this.runners,
    required this.lineup,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).dividerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw diamond
    final path = Path();
    path.moveTo(center.dx, center.dy + radius); // Home
    path.lineTo(center.dx + radius, center.dy); // First
    path.lineTo(center.dx, center.dy - radius); // Second
    path.lineTo(center.dx - radius, center.dy); // Third
    path.close();

    canvas.drawPath(path, paint);

    // Draw grass effect
    paint.color = Theme.of(context).colorScheme.primary.withOpacity(0.05);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiamondPainter oldDelegate) {
    return runners != oldDelegate.runners;
  }
} 