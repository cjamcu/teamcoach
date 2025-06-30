import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/models/game.dart';
import '../../../shared/models/game_lineup.dart';
import '../controllers/active_game_controller.dart';
import '../models/play.dart';
import '../widgets/scoreboard_widget.dart';
import '../widgets/current_batter_widget.dart';
import '../widgets/play_buttons_widget.dart';
import '../widgets/baserunners_widget.dart';
import '../widgets/play_history_widget.dart';

class ActiveGameScreen extends StatefulWidget {
  final Game game;
  final List<GameLineup> lineup;

  const ActiveGameScreen({
    super.key,
    required this.game,
    required this.lineup,
  });

  @override
  State<ActiveGameScreen> createState() => _ActiveGameScreenState();
}

class _ActiveGameScreenState extends State<ActiveGameScreen> {
  late final ActiveGameController _controller;
  bool _showPlayHistory = false;

  @override
  void initState() {
    super.initState();
    _controller = ActiveGameController();
    _controller.startGame(widget.game, widget.lineup);
  }

  @override
  void dispose() {
    _controller.resetGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Scoreboard section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ScoreboardWidget(controller: _controller),
          ),
          
          // Current game state
          Expanded(
            child: _showPlayHistory 
                ? PlayHistoryWidget(controller: _controller)
                : _buildGameInterface(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Watch((context) {
        final game = _controller.gameSignal.value;
        return Text(
          'vs ${game?.opponent ?? "Oponente"}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
      }),
      actions: [
        Watch((context) {
          final isActive = _controller.isGameActiveSignal.value;
          return OutlinedButton(
            onPressed: isActive ? _showEndGameDialog : null,
            child: const Text('Finalizar'),
          );
        }),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() => _showPlayHistory = !_showPlayHistory),
          icon: Icon(_showPlayHistory ? LucideIcons.gamepad2 : LucideIcons.history),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGameInterface() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current batter info
          CurrentBatterWidget(controller: _controller),
          
          const SizedBox(height: 16),
          
          // Baserunners visualization
          BaseRunnersWidget(controller: _controller),
          
          const SizedBox(height: 24),
          
          // Game state info
          _buildGameStateInfo(),
          
          const SizedBox(height: 24),
          
          // Play buttons
          PlayButtonsWidget(
            controller: _controller,
            onPlayRecorded: _onPlayRecorded,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGameStateInfo() {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Watch((context) {
              final inning = _controller.inningDisplaySignal.value;
              return _buildStatItem('Inning', inning, LucideIcons.clock);
            }),
            Watch((context) {
              final outs = _controller.outsSignal.value;
              return _buildStatItem('Outs', '$outs', LucideIcons.x);
            }),
            Watch((context) {
              final atBat = _controller.atBatCountSignal.value;
              return _buildStatItem('Turno', '#$atBat', LucideIcons.hash);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: ShadTheme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ShadTheme.of(context).textTheme.h4,
        ),
        Text(
          label,
          style: ShadTheme.of(context).textTheme.small.copyWith(
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick substitution button
        FloatingActionButton.small(
          heroTag: 'substitution',
          onPressed: _showSubstitutionDialog,
          backgroundColor: ShadTheme.of(context).colorScheme.secondary,
          child: const Icon(LucideIcons.users),
        ),
        const SizedBox(height: 8),
        
        // Opponent score adjustment
        FloatingActionButton.small(
          heroTag: 'opponent_score',
          onPressed: _showOpponentScoreDialog,
          backgroundColor: ShadTheme.of(context).colorScheme.accent,
          child: const Icon(LucideIcons.plus),
        ),
      ],
    );
  }

  void _onPlayRecorded(String playType, String result) {
    // Show success feedback
    if (mounted) {
      ShadToaster.of(context).show(
        ShadToast(
          description: Text('Jugada registrada: ${Play.quickPlays[result]?['display'] ?? result}'),
        ),
      );
    }
  }

  void _showEndGameDialog() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Finalizar Juego'),
        description: const Text('¿Estás seguro de que quieres finalizar el juego? Esta acción no se puede deshacer.'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // End the game by updating status
              final game = _controller.gameSignal.value;
              if (game != null) {
                _controller.gameSignal.value = game.copyWith(
                  status: 'completed',
                  finalScoreTeam: _controller.teamScoreSignal.value,
                  finalScoreOpponent: _controller.opponentScoreSignal.value,
                );
                _controller.isGameActiveSignal.value = false;
              }
              Navigator.pop(context);
              Navigator.pop(context); // Return to games list
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _showSubstitutionDialog() {
    // TODO: Implement substitution dialog
    ShadToaster.of(context).show(
      const ShadToast(
        description: Text('Función de sustitución próximamente'),
      ),
    );
  }

  void _showOpponentScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Score Visitante'),
        content: Watch((context) {
          final currentScore = _controller.opponentScoreSignal.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score actual: $currentScore',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _controller.subtractOpponentRun();
                    },
                    child: const Icon(LucideIcons.minus),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _controller.addOpponentRun();
                    },
                    child: const Icon(LucideIcons.plus),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
} 