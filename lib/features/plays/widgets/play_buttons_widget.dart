import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../controllers/active_game_controller.dart';
import '../models/play.dart';

class PlayButtonsWidget extends StatelessWidget {
  final ActiveGameController controller;
  final Function(String, String) onPlayRecorded;

  const PlayButtonsWidget({
    super.key,
    required this.controller,
    required this.onPlayRecorded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Count controls (Balls & Strikes)
        _buildCountControls(context),
        
        const SizedBox(height: 16),
        
        // Quick play buttons grid
        _buildQuickPlayButtons(context),
        
        const SizedBox(height: 16),
        
        // Additional play options
        _buildAdditionalOptions(context),
      ],
    );
  }

  Widget _buildCountControls(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Conteo del Bateador',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Strike button
                Expanded(
                  child: Watch((context) {
                    final strikes = controller.strikesSignal.value;
                    final isMaxed = strikes >= ActiveGameController.MAX_STRIKES - 1;
                    
                    return ShadButton(
                      onPressed: controller.addStrike,
                      backgroundColor: isMaxed 
                          ? Colors.red.shade600 
                          : Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      size: ShadButtonSize.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.x, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isMaxed ? 'Strike Out!' : 'Strike ($strikes)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                // Ball button
                Expanded(
                  child: Watch((context) {
                    final balls = controller.ballsSignal.value;
                    final isMaxed = balls >= ActiveGameController.MAX_BALLS - 1;
                    
                    return ShadButton(
                      onPressed: controller.addBall,
                      backgroundColor: isMaxed 
                          ? Colors.green.shade700 
                          : Colors.green.shade600,
                      foregroundColor: Colors.white,
                      size: ShadButtonSize.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.circle, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isMaxed ? 'Walk!' : 'Ball ($balls)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reset count button
            Center(
              child: ShadButton.outline(
                onPressed: controller.resetCount,
                size: ShadButtonSize.sm,
                child: const Text('Reiniciar Conteo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPlayButtons(BuildContext context) {
    final hitPlays = [
      {'key': 'single', 'icon': LucideIcons.zap},
      {'key': 'double', 'icon': LucideIcons.zap},
      {'key': 'triple', 'icon': LucideIcons.zap},
      {'key': 'home_run', 'icon': LucideIcons.trophy},
    ];

    final outPlays = [
      {'key': 'fly_out', 'icon': LucideIcons.arrowUp},
      {'key': 'ground_out', 'icon': LucideIcons.arrowDown},
      {'key': 'foul_out', 'icon': LucideIcons.arrowUpRight},
      {'key': 'line_out', 'icon': LucideIcons.arrowRight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hit buttons
        Text(
          'Hits',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: hitPlays.length,
          itemBuilder: (context, index) {
            final play = hitPlays[index];
            final playKey = play['key'] as String;
            final playData = Play.quickPlays[playKey] ?? {};
            
            return _buildPlayButton(
              context,
              icon: play['icon'] as IconData,
              label: playData['display'] ?? playKey,
              onPressed: () => _recordHit(playKey),
              color: Colors.blue.shade600,
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Out buttons
        Text(
          'Outs',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: outPlays.length,
          itemBuilder: (context, index) {
            final play = outPlays[index];
            final playKey = play['key'] as String;
            final playData = Play.quickPlays[playKey] ?? {};
            
            return _buildPlayButton(
              context,
              icon: play['icon'] as IconData,
              label: playData['display'] ?? playKey,
              onPressed: () => _recordOut(playKey),
              color: Colors.red.shade600,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    return Row(
      children: [
        // Error button
        Expanded(
          child: _buildPlayButton(
            context,
            icon: LucideIcons.triangleAlert,
            label: 'Error',
            onPressed: () => _showErrorDialog(context),
            color: Colors.orange.shade600,
          ),
        ),
        const SizedBox(width: 8),
        // Sacrifice button
        Expanded(
          child: _buildPlayButton(
            context,
            icon: LucideIcons.heart,
            label: 'Sacrificio',
            onPressed: () => _showSacrificeDialog(context),
            color: Colors.purple.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ShadButton(
      onPressed: onPressed,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _recordHit(String result) {
    // Calculate RBIs and runs based on hit type and runners
    final runners = controller.runnersOnBaseSignal.value;
    int estimatedRBIs = 0;
    int estimatedRuns = 0;

    switch (result) {
      case 'single':
        estimatedRBIs = runners.containsKey('3B') ? 1 : 0;
        estimatedRuns = estimatedRBIs;
        break;
      case 'double':
        estimatedRBIs = (runners.containsKey('3B') ? 1 : 0) + 
                        (runners.containsKey('2B') ? 1 : 0);
        estimatedRuns = estimatedRBIs;
        break;
      case 'triple':
        estimatedRBIs = runners.length;
        estimatedRuns = estimatedRBIs;
        break;
      case 'home_run':
        estimatedRBIs = runners.length + 1;
        estimatedRuns = estimatedRBIs;
        break;
    }

    controller.recordPlay(
      playType: 'hit',
      result: result,
      rbi: estimatedRBIs,
      runsScored: estimatedRuns,
    );
    
    onPlayRecorded('hit', result);
  }

  void _recordOut(String result) {
    controller.recordPlay(
      playType: 'out',
      result: result,
    );
    
    onPlayRecorded('out', result);
  }

  void _showErrorDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Registrar Error'),
        description: const Text('¿El bateador llegó a base por error?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ShadButton(
            onPressed: () {
              controller.recordPlay(
                playType: 'error',
                result: 'error',
                notes: 'E',
              );
              onPlayRecorded('error', 'error');
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSacrificeDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Registrar Sacrificio'),
        description: const Text('Selecciona el tipo de sacrificio:'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          ShadButton.outline(
            onPressed: () {
              controller.recordPlay(
                playType: 'sacrifice',
                result: 'sacrifice_fly',
                rbi: 1,
                runsScored: 1,
              );
              onPlayRecorded('sacrifice', 'sacrifice_fly');
              Navigator.pop(context);
            },
            child: const Text('Elevado de Sacrificio'),
          ),
          const SizedBox(width: 8),
          ShadButton.outline(
            onPressed: () {
              controller.recordPlay(
                playType: 'sacrifice',
                result: 'sacrifice_bunt',
              );
              onPlayRecorded('sacrifice', 'sacrifice_bunt');
              Navigator.pop(context);
            },
            child: const Text('Toque de Sacrificio'),
          ),
        ],
      ),
    );
  }
} 