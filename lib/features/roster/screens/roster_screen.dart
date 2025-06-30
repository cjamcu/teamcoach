import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:teamcoach/features/roster/services/player_service.dart';
import 'package:teamcoach/shared/widgets/player_card.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final _playerService = GetIt.I<PlayerService>();
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _playerService.updateSearchQuery(_searchController.text);
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _showDeleteConfirmation(BuildContext context, String playerId, String playerName) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Confirmar Eliminación'),
        description: Text('¿Estás seguro de que deseas eliminar a $playerName? Esta acción no se puede deshacer.'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Eliminar'),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _playerService.deletePlayer(playerId);
                if (mounted) {
                  ShadToaster.of(context).show(
                    const ShadToast(
                      title: Text('Éxito'),
                      description: Text('Jugador eliminado exitosamente'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('Error'),
                      description: Text('Error al eliminar jugador: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  void _showBulkActions(BuildContext context) {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Acciones'),
        description: const Text('Selecciona una acción para los jugadores seleccionados'),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadButton.outline(
                width: double.infinity,
                onPressed: () async {
                  Navigator.pop(context);
                  await _playerService.toggleMultiplePlayersStatus(true);
                  if (mounted) {
                    ShadToaster.of(context).show(
                      const ShadToast(
                        title: Text('Éxito'),
                        description: Text('Jugadores activados'),
                      ),
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 18),
                    SizedBox(width: 8),
                    Text('Activar seleccionados'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShadButton.outline(
                width: double.infinity,
                onPressed: () async {
                  Navigator.pop(context);
                  await _playerService.toggleMultiplePlayersStatus(false);
                  if (mounted) {
                    ShadToaster.of(context).show(
                      const ShadToast(
                        title: Text('Éxito'),
                        description: Text('Jugadores desactivados'),
                      ),
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 18),
                    SizedBox(width: 8),
                    Text('Desactivar seleccionados'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShadButton.destructive(
                width: double.infinity,
                onPressed: () {
                  Navigator.pop(context);
                  _showBulkDeleteConfirmation(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Eliminar seleccionados'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkDeleteConfirmation(BuildContext context) {
    final selectedCount = _playerService.selectedPlayerIds.value.length;
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Confirmar Eliminación'),
        description: Text(
          '¿Estás seguro de que deseas eliminar $selectedCount jugadores? Esta acción no se puede deshacer.'
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ShadButton.destructive(
            child: const Text('Eliminar'),
            onPressed: () async {
              Navigator.pop(context);
              await _playerService.deleteMultiplePlayers();
              if (mounted) {
                ShadToaster.of(context).show(
                  const ShadToast(
                    title: Text('Éxito'),
                    description: Text('Jugadores eliminados exitosamente'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Watch(
      (context) {
        final isLoading = _playerService.isLoading.value;
        final error = _playerService.error.value;
        final players = _playerService.filteredPlayers.value;
        final hasSelection = _playerService.hasSelection.value;
        final selectedCount = _playerService.selectedPlayerIds.value.length;
        
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: hasSelection 
                ? Text(
                    '$selectedCount seleccionados',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Text(
                    'Roster',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            leading: hasSelection
                ? ShadButton.ghost(
                    onPressed: _playerService.clearSelection,
                    child: const Icon(Icons.close, size: 20),
                  )
                : null,
            actions: [
              if (hasSelection) ...[
                ShadButton.ghost(
                  onPressed: _playerService.selectAll,
                  child: const Icon(Icons.select_all, size: 20),
                ),
                const SizedBox(width: 8),
                ShadButton.ghost(
                  onPressed: () => _showBulkActions(context),
                  child: const Icon(Icons.more_vert, size: 20),
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ShadInput(
                  controller: _searchController,
                  placeholder: const Text('Buscar por nombre, número o posición...'),
                ),
              ),
              
              // Lista de jugadores
              Expanded(
                child: isLoading && players.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando jugadores...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : error != null
                        ? Center(
                            child: ShadCard(
                              width: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: theme.colorScheme.error,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error al cargar',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ShadButton(
                                      onPressed: _playerService.loadPlayers,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : players.isEmpty
                            ? Center(
                                child: ShadCard(
                                  width: 320,
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.people_outline,
                                            color: theme.colorScheme.onSurfaceVariant,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _searchController.text.isEmpty
                                              ? 'No hay jugadores'
                                              : 'Sin resultados',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _searchController.text.isEmpty
                                              ? 'Agrega jugadores para comenzar a formar tu equipo'
                                              : 'Intenta con otros términos de búsqueda',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                        if (_searchController.text.isEmpty) ...[
                                          const SizedBox(height: 20),
                                          ShadButton(
                                            onPressed: () => context.go('/roster/add'),
                                            child: const Text('Agregar Jugador'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _playerService.loadPlayers,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                  itemCount: players.length,
                                  itemBuilder: (context, index) {
                                    final player = players[index];
                                    final isSelected = _playerService.selectedPlayerIds.value
                                        .contains(player.id);
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Stack(
                                        children: [
                                          PlayerCard(
                                            player: player,
                                            onTap: hasSelection
                                                ? () => _playerService.togglePlayerSelection(player.id)
                                                : () => context.go(
                                                    '/roster/edit/${player.id}',
                                                    extra: player,
                                                  ),
                                            onEdit: hasSelection
                                                ? null
                                                : () => context.go(
                                                    '/roster/edit/${player.id}',
                                                    extra: player,
                                                  ),
                                            onDelete: hasSelection
                                                ? null
                                                : () => _showDeleteConfirmation(
                                                    context,
                                                    player.id,
                                                    player.name,
                                                  ),
                                          ),
                                          if (hasSelection)
                                            Positioned(
                                              left: 12,
                                              top: 12,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: isSelected 
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme.surface,
                                                  border: Border.all(
                                                    color: isSelected 
                                                        ? theme.colorScheme.primary
                                                        : theme.colorScheme.outline,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: isSelected
                                                    ? Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: theme.colorScheme.onPrimary,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
          floatingActionButton: ShadButton(
            onPressed: () => context.go('/roster/add'),
            size: ShadButtonSize.lg,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text('Nuevo Jugador'),
              ],
            ),
          ),
        );
      },
    );
  }
} 