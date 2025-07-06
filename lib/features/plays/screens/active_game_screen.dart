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

class _ActiveGameScreenState extends State<ActiveGameScreen> with WidgetsBindingObserver {
  late final ActiveGameController _controller;
  final ValueNotifier<bool> _isFieldingMode = ValueNotifier(false);
  bool _showPlayHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ActiveGameController();
    _loadGameState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveGameState();
    _controller.resetGame();
    _isFieldingMode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveGameState();
    }
  }

  Future<void> _loadGameState() async {
    // Try to load saved game state first
    final hasLoadedState = await _controller.loadGameState();
    
    if (!hasLoadedState) {
      // If no saved state or loading failed, start new game
      _controller.startGame(widget.game, widget.lineup);
    } else {
      // Show a message that the game was restored
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text('Juego restaurado desde donde se quedó'),
          ),
        );
      }
    }
  }

  Future<void> _saveGameState() async {
    // Save current game state to local storage
    await _controller.saveGameState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: _showPlayHistory 
          ? PlayHistoryWidget(controller: _controller)
          : _buildScrollableGameInterface(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Watch((context) {
        final game = _controller.gameSignal.value;
        return Text(
          'vs ${game?.opponent ?? "Oponente"}',
          style: ShadTheme.of(context).textTheme.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
      }),
      actions: [
        // Toggle fielding mode
        ValueListenableBuilder(
          valueListenable: _isFieldingMode,
          builder: (context, isFielding, _) {
            return ShadButton.outline(
              onPressed: () => _isFieldingMode.value = !isFielding,
              size: ShadButtonSize.sm,
              backgroundColor: isFielding 
                  ? ShadTheme.of(context).colorScheme.primary 
                  : null,
              foregroundColor: isFielding 
                  ? Colors.white 
                  : ShadTheme.of(context).colorScheme.foreground,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFielding ? LucideIcons.shield : LucideIcons.target,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(isFielding ? 'Defendiendo' : 'Bateando'),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Watch((context) {
          final isActive = _controller.isGameActiveSignal.value;
          return ShadButton.outline(
            onPressed: isActive ? _showEndGameDialog : null,
            size: ShadButtonSize.sm,
            child: const Text('Finalizar'),
          );
        }),
        const SizedBox(width: 8),
        ShadButton.ghost(
          onPressed: () => setState(() => _showPlayHistory = !_showPlayHistory),
          size: ShadButtonSize.sm,
          child: Icon(_showPlayHistory ? LucideIcons.gamepad2 : LucideIcons.history),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildScrollableGameInterface() {
    return ValueListenableBuilder(
      valueListenable: _isFieldingMode,
      builder: (context, isFielding, _) {
        if (isFielding) {
          return _buildFieldingView();
        } else {
          return _buildBattingView();
        }
      },
    );
  }

  Widget _buildBattingView() {
    return CustomScrollView(
      slivers: [
        // Live game status header
        SliverToBoxAdapter(
          child: _buildLiveGameHeader(),
        ),
        
        // Current batter - Hero section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildEnhancedCurrentBatter(),
          ),
        ),
        
        // Count and game state
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildGameStateCard(),
          ),
        ),
        
        // Quick actions - Main focus
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PlayButtonsWidget(
              controller: _controller,
              onPlayRecorded: _onPlayRecorded,
            ),
          ),
        ),
        
        // Next batters preview
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildNextBattersPreview(),
          ),
        ),
        
        // Scoreboard - Moved to bottom
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marcador Detallado',
                  style: ShadTheme.of(context).textTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ScoreboardWidget(controller: _controller),
              ],
            ),
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildFieldingView() {
    return CustomScrollView(
      slivers: [
        // Live game status header
        SliverToBoxAdapter(
          child: _buildLiveGameHeader(),
        ),
        
        // Fielding mode header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: ShadTheme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ShadTheme.of(context).colorScheme.primary,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.shield,
                  size: 24,
                  color: ShadTheme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo Defensivo',
                        style: ShadTheme.of(context).textTheme.h4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ShadTheme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Tu equipo está en el campo',
                        style: ShadTheme.of(context).textTheme.small.copyWith(
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Game state summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFieldingGameState(),
          ),
        ),
        
        // Opponent scoring controls
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildOpponentControls(),
          ),
        ),
        
        // Quick defensive actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildDefensiveActions(),
          ),
        ),
        
        // Scoreboard
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marcador',
                  style: ShadTheme.of(context).textTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ScoreboardWidget(controller: _controller),
              ],
            ),
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildLiveGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ShadTheme.of(context).colorScheme.primary,
            ShadTheme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Live indicator
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'EN VIVO',
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Watch((context) {
              final teamScore = _controller.teamScoreSignal.value;
              final opponentScore = _controller.opponentScoreSignal.value;
              final inning = _controller.inningDisplaySignal.value;
              
              return Text(
                '$teamScore - $opponentScore • $inning',
                style: ShadTheme.of(context).textTheme.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCurrentBatter() {
    return Watch((context) {
      final currentBatter = _controller.currentBatterSignal.value;
      
      if (currentBatter == null) {
        return ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.userX,
                    size: 48,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay bateador asignado',
                    style: ShadTheme.of(context).textTheme.h4.copyWith(
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header with batting order
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ShadTheme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Al Bate #${currentBatter.battingOrder}',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.target,
                    color: ShadTheme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Main batter info
              Row(
                children: [
                  // Large player number
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ShadTheme.of(context).colorScheme.primary,
                          ShadTheme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: ShadTheme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${currentBatter.displayNumber}',
                        style: ShadTheme.of(context).textTheme.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Player info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentBatter.displayName,
                          style: ShadTheme.of(context).textTheme.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildEnhancedChip(
                              context,
                              currentBatter.startingPosition,
                              LucideIcons.mapPin,
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            if (currentBatter.player?.battingSide != null)
                              _buildEnhancedChip(
                                context,
                                _getBattingSideDisplay(currentBatter.player!.battingSide),
                                LucideIcons.zap,
                                Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEnhancedChip(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: ShadTheme.of(context).textTheme.small.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStateCard() {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Count display
            Expanded(
              child: Watch((context) {
                final balls = _controller.ballsSignal.value;
                final strikes = _controller.strikesSignal.value;
                
                return Column(
                  children: [
                    Text(
                      'Conteo',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: ShadTheme.of(context).textTheme.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '$balls',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                          TextSpan(
                            text: ' - ',
                            style: TextStyle(color: ShadTheme.of(context).colorScheme.foreground),
                          ),
                          TextSpan(
                            text: '$strikes',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            
            Container(
              width: 1,
              height: 40,
              color: ShadTheme.of(context).colorScheme.border,
            ),
            
            // Outs display
            Expanded(
              child: Watch((context) {
                final outs = _controller.outsSignal.value;
                
                return Column(
                  children: [
                    Text(
                      'Outs',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isOut = index < outs;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isOut ? Colors.red : ShadTheme.of(context).colorScheme.muted,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
            
            Container(
              width: 1,
              height: 40,
              color: ShadTheme.of(context).colorScheme.border,
            ),
            
            // Inning display
            Expanded(
              child: Watch((context) {
                final inning = _controller.inningDisplaySignal.value;
                
                return Column(
                  children: [
                    Text(
                      'Inning',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inning,
                      style: ShadTheme.of(context).textTheme.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextBattersPreview() {
    return Watch((context) {
      final lineup = _controller.lineupSignal.value;
      final currentAtBat = _controller.atBatCountSignal.value;
      
      // Prevent division by zero
      if (lineup.isEmpty) return const SizedBox.shrink();
      
      // Get next 3 batters
      final nextBatters = <GameLineup>[];
      for (int i = 1; i <= 3; i++) {
        final nextIndex = (currentAtBat + i - 1) % lineup.length;
        if (nextIndex < lineup.length) {
          nextBatters.add(lineup[nextIndex]);
        }
      }
      
      if (nextBatters.isEmpty) return const SizedBox.shrink();
      
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 20,
                    color: ShadTheme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Próximos al Bate',
                    style: ShadTheme.of(context).textTheme.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...nextBatters.asMap().entries.map((entry) {
                final index = entry.key;
                final batter = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < nextBatters.length - 1 ? 8 : 0),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ShadTheme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${batter.displayNumber}',
                            style: ShadTheme.of(context).textTheme.small.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          batter.displayName,
                          style: ShadTheme.of(context).textTheme.p,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ShadTheme.of(context).colorScheme.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          batter.startingPosition,
                          style: ShadTheme.of(context).textTheme.small,
                        ),
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

  Widget _buildFieldingGameState() {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Inning
                Expanded(
                  child: Watch((context) {
                    final inning = _controller.inningDisplaySignal.value;
                    
                    return Column(
                      children: [
                        Text(
                          'Inning',
                          style: ShadTheme.of(context).textTheme.small.copyWith(
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inning,
                          style: ShadTheme.of(context).textTheme.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                
                Container(
                  width: 1,
                  height: 40,
                  color: ShadTheme.of(context).colorScheme.border,
                ),
                
                // Outs
                Expanded(
                  child: Watch((context) {
                    final outs = _controller.outsSignal.value;
                    
                    return Column(
                      children: [
                        Text(
                          'Outs',
                          style: ShadTheme.of(context).textTheme.small.copyWith(
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isOut = index < outs;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isOut ? Colors.red : ShadTheme.of(context).colorScheme.muted,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  }),
                ),
                
                Container(
                  width: 1,
                  height: 40,
                  color: ShadTheme.of(context).colorScheme.border,
                ),
                
                // Score
                Expanded(
                  child: Watch((context) {
                    final teamScore = _controller.teamScoreSignal.value;
                    final opponentScore = _controller.opponentScoreSignal.value;
                    
                    return Column(
                      children: [
                        Text(
                          'Score',
                          style: ShadTheme.of(context).textTheme.small.copyWith(
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$teamScore - $opponentScore',
                          style: ShadTheme.of(context).textTheme.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentControls() {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control del Score Oponente',
              style: ShadTheme.of(context).textTheme.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () {
                      _controller.subtractOpponentRun();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.minus, size: 16),
                        const SizedBox(width: 4),
                        const Text('Quitar Carrera'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadButton(
                    onPressed: () {
                      _controller.addOpponentRun();
                    },
                    backgroundColor: Colors.red.shade600,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.plus, size: 16),
                        const SizedBox(width: 4),
                        const Text('Carrera Oponente'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefensiveActions() {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Defensivas',
              style: ShadTheme.of(context).textTheme.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: [
                _buildDefensiveButton(
                  context,
                  icon: LucideIcons.target,
                  label: 'Strikeout',
                  onPressed: () => _controller.addStrike(),
                  color: Colors.red.shade600,
                ),
                _buildDefensiveButton(
                  context,
                  icon: LucideIcons.circle,
                  label: 'Walk',
                  onPressed: () => _controller.addBall(),
                  color: Colors.green.shade600,
                ),
                _buildDefensiveButton(
                  context,
                  icon: LucideIcons.rotateCcw,
                  label: 'Cambio Inning',
                  onPressed: () => _endHalfInning(),
                  color: Colors.blue.shade600,
                ),
                _buildDefensiveButton(
                  context,
                  icon: LucideIcons.users,
                  label: 'Sustitución',
                  onPressed: () => _showSubstitutionDialog(),
                  color: Colors.purple.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefensiveButton(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _endHalfInning() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Cambio de Inning'),
        description: const Text('¿Confirmar cambio de inning? Se reiniciarán los outs.'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ShadButton(
            onPressed: () {
              _controller.outsSignal.value = 3; // This will trigger half-inning end
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return ValueListenableBuilder(
      valueListenable: _isFieldingMode,
      builder: (context, isFielding, _) {
        if (isFielding) {
          // Simplified FAB for fielding mode
          return FloatingActionButton(
            onPressed: _showSubstitutionDialog,
            backgroundColor: ShadTheme.of(context).colorScheme.primary,
            child: const Icon(LucideIcons.users),
          );
        } else {
          // Standard FABs for batting mode
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'substitution',
                onPressed: _showSubstitutionDialog,
                backgroundColor: ShadTheme.of(context).colorScheme.secondary,
                child: const Icon(LucideIcons.users),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'quick_action',
                onPressed: () {
                  // Quick access to most common actions
                  _isFieldingMode.value = !_isFieldingMode.value;
                },
                backgroundColor: ShadTheme.of(context).colorScheme.accent,
                child: const Icon(LucideIcons.zap),
              ),
            ],
          );
        }
      },
    );
  }

  void _onPlayRecorded(String playType, String result) {
    // Save state after each play
    _saveGameState();
    
    // Show success feedback
    if (mounted) {
      ShadToaster.of(context).show(
        ShadToast(
          description: Text('Jugada registrada: ${Play.quickPlays[result]?['display'] ?? result}'),
        ),
      );
    }
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
          ShadButton(
            onPressed: () async {
              // End the game by updating status
              final game = _controller.gameSignal.value;
              if (game != null) {
                _controller.gameSignal.value = game.copyWith(
                  status: 'completed',
                  finalScoreTeam: _controller.teamScoreSignal.value,
                  finalScoreOpponent: _controller.opponentScoreSignal.value,
                );
                _controller.isGameActiveSignal.value = false;
                
                // Clear saved game state since game is completed
                await _controller.clearSavedGameState();
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
} 