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
        
        // Quick action tabs
        _buildQuickActionTabs(context),
      ],
    );
  }

  Widget _buildCountControls(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Conteo del Bateador',
              style: ShadTheme.of(context).textTheme.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.x, size: 18),
                          const SizedBox(height: 2),
                          Text(
                            isMaxed ? 'Strike Out!' : 'Strike ($strikes)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.circle, size: 18),
                          const SizedBox(height: 2),
                          Text(
                            isMaxed ? 'Walk!' : 'Ball ($balls)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildQuickActionTabs(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: ShadTheme.of(context).colorScheme.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: ShadTheme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: ShadTheme.of(context).colorScheme.mutedForeground,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.zap, size: 16),
                      SizedBox(width: 4),
                      Text('Hits', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.x, size: 16),
                      SizedBox(width: 4),
                      Text('Outs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 16),
                      SizedBox(width: 4),
                      Text('Otros', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Tab content
          SizedBox(
            height: 140,
            child: TabBarView(
              children: [
                _buildHitsTab(context),
                _buildOutsTab(context),
                _buildOthersTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHitsTab(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [
        _buildQuickButton(
          context,
          icon: LucideIcons.zap,
          label: 'Sencillo',
          onPressed: () => _recordHit('single'),
          color: Colors.blue.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.zap,
          label: 'Doble',
          onPressed: () => _recordHit('double'),
          color: Colors.blue.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.zap,
          label: 'Triple',
          onPressed: () => _recordHit('triple'),
          color: Colors.blue.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.trophy,
          label: 'Jonrón',
          onPressed: () => _recordHit('home_run'),
          color: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildOutsTab(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [
        _buildQuickButton(
          context,
          icon: LucideIcons.arrowUp,
          label: 'Elevado',
          onPressed: () => _recordOut('fly_out'),
          color: Colors.red.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.arrowDown,
          label: 'Rolling',
          onPressed: () => _recordOut('ground_out'),
          color: Colors.red.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.arrowUpRight,
          label: 'Foul Out',
          onPressed: () => _recordOut('foul_out'),
          color: Colors.red.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.arrowRight,
          label: 'Línea Out',
          onPressed: () => _recordOut('line_out'),
          color: Colors.red.shade600,
        ),
      ],
    );
  }

  Widget _buildOthersTab(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [
        _buildQuickButton(
          context,
          icon: LucideIcons.triangleAlert,
          label: 'Error',
          onPressed: () => _showErrorDialog(context),
          color: Colors.orange.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.heart,
          label: 'Sacrificio',
          onPressed: () => _showSacrificeDialog(context),
          color: Colors.purple.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.shuffle,
          label: 'Base Robada',
          onPressed: () => _recordPlay('steal', 'stolen_base'),
          color: Colors.teal.shade600,
        ),
        _buildQuickButton(
          context,
          icon: LucideIcons.userX,
          label: 'Out Pick-off',
          onPressed: () => _recordOut('pickoff'),
          color: Colors.red.shade700,
        ),
      ],
    );
  }

  Widget _buildQuickButton(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _recordPlay(String playType, String result) {
    controller.recordPlay(
      playType: playType,
      result: result,
    );
    onPlayRecorded(playType, result);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ShadButton.outline(
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
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ShadButton.outline(
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
            ),
            const SizedBox(height: 16),
            ShadButton.ghost(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
} 