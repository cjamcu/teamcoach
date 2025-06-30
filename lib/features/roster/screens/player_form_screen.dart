import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:teamcoach/features/roster/services/player_service.dart';
import 'package:teamcoach/features/roster/widgets/position_selector.dart';
import 'package:teamcoach/features/roster/widgets/side_selector.dart';
import 'package:teamcoach/shared/models/player.dart';
import 'package:teamcoach/core/utils/validators.dart';

class PlayerFormScreen extends StatefulWidget {
  final Player? player;
  
  const PlayerFormScreen({
    super.key,
    this.player,
  });

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerService = GetIt.I<PlayerService>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  
  late String _battingSide;
  late String _throwingSide;
  late List<String> _selectedPositions;
  
  bool _isSubmitting = false;
  
  bool get isEditing => widget.player != null;
  
  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.player?.name ?? '');
    _numberController = TextEditingController(
      text: widget.player?.number.toString() ?? '',
    );
    
    _battingSide = widget.player?.battingSide ?? 'right';
    _throwingSide = widget.player?.throwingSide ?? 'right';
    _selectedPositions = widget.player?.positions ?? [];
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPositions.isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Error de validación'),
          description: Text('Por favor selecciona al menos una posición'),
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      if (isEditing) {
        final updatedPlayer = widget.player!.copyWith(
          name: _nameController.text.trim(),
          number: int.parse(_numberController.text),
          positions: _selectedPositions,
          battingSide: _battingSide,
          throwingSide: _throwingSide,
        );
        
        await _playerService.updatePlayer(updatedPlayer);
      } else {
        await _playerService.createPlayer(
          name: _nameController.text.trim(),
          number: int.parse(_numberController.text),
          positions: _selectedPositions,
          battingSide: _battingSide,
          throwingSide: _throwingSide,
        );
      }
      
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Éxito'),
            description: Text(
              isEditing 
                  ? 'Jugador actualizado exitosamente'
                  : 'Jugador creado exitosamente',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text(
              'Error al ${isEditing ? 'actualizar' : 'crear'} jugador: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isEditing ? 'Editar Jugador' : 'Nuevo Jugador',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: ShadButton.ghost(
          onPressed: () => context.pop(),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con icono
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit : Icons.person_add,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Información básica
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Información Básica',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Jugador',
                          hintText: 'Ej: Juan Pérez',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        style: theme.textTheme.bodyLarge,
                        textCapitalization: TextCapitalization.words,
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numberController,
                        decoration: InputDecoration(
                          labelText: 'Número de Camiseta',
                          hintText: 'Ej: 23',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        style: theme.textTheme.bodyLarge,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: Validators.validatePlayerNumber,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Posiciones
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sports_baseball,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Posiciones',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PositionSelector(
                        selectedPositions: _selectedPositions,
                        onChanged: (positions) {
                          setState(() {
                            _selectedPositions = positions;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Características del jugador
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sports,
                              size: 18,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Características',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SideSelector(
                        label: 'Lado de Bateo',
                        value: _battingSide,
                        options: SideOptions.batting,
                        onChanged: (value) {
                          setState(() {
                            _battingSide = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SideSelector(
                        label: 'Lado de Lanzamiento',
                        value: _throwingSide,
                        options: SideOptions.throwing,
                        onChanged: (value) {
                          setState(() {
                            _throwingSide = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(isEditing ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 