import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:teamcoach/features/games/services/game_service.dart';
import 'package:teamcoach/shared/models/game.dart';
import 'package:teamcoach/core/utils/validators.dart';

class CreateGameScreen extends StatefulWidget {
  final Game? game;
  
  const CreateGameScreen({
    super.key,
    this.game,
  });

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameService = GetIt.I<GameService>();
  
  late final TextEditingController _opponentController;
  late final TextEditingController _locationController;
  late final TextEditingController _inningsController;
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isHome;
  
  bool _isSubmitting = false;
  
  bool get isEditing => widget.game != null;
  
  @override
  void initState() {
    super.initState();
    
    _opponentController = TextEditingController(text: widget.game?.opponent ?? '');
    _locationController = TextEditingController(text: widget.game?.location ?? '');
    _inningsController = TextEditingController(
      text: widget.game?.innings.toString() ?? '7',
    );
    
    if (widget.game != null) {
      _selectedDate = widget.game!.gameDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.game!.gameDate);
      _isHome = widget.game!.isHome;
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 19, minute: 0);
      _isHome = true;
    }
  }
  
  @override
  void dispose() {
    _opponentController.dispose();
    _locationController.dispose();
    _inningsController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final gameDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      if (isEditing) {
        final updatedGame = widget.game!.copyWith(
          opponent: _opponentController.text.trim(),
          location: _locationController.text.trim(),
          gameDate: gameDateTime,
          isHome: _isHome,
          innings: int.parse(_inningsController.text),
        );
        
        await _gameService.updateGame(updatedGame);
      } else {
        await _gameService.createGame(
          opponent: _opponentController.text.trim(),
          location: _locationController.text.trim(),
          gameDate: gameDateTime,
          isHome: _isHome,
          innings: int.parse(_inningsController.text),
        );
      }
      
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Éxito'),
            description: Text(
              isEditing 
                  ? 'Juego actualizado exitosamente'
                  : 'Juego creado exitosamente',
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
              'Error al ${isEditing ? 'actualizar' : 'crear'} juego: $e',
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
          isEditing ? 'Editar Juego' : 'Nuevo Juego',
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
                    isEditing ? Icons.edit : Icons.sports_baseball,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Información del juego
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
                              Icons.info,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Información del Juego',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        controller: _opponentController,
                        placeholder: const Text('Ej: Águilas FC'),
                        label: const Text('Equipo Rival'),
                        validator: Validators.validateTeamName,
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        controller: _locationController,
                        placeholder: const Text('Ej: Estadio Municipal (opcional)'),
                        label: const Text('Ubicación'),
                        // Campo opcional - sin validador
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        controller: _inningsController,
                        placeholder: const Text('Ej: 7'),
                        label: const Text('Número de Innings'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El número de innings es requerido';
                          }
                          final innings = int.tryParse(value);
                          if (innings == null || innings < 1 || innings > 15) {
                            return 'Debe ser un número entre 1 y 15';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Fecha y hora
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
                              Icons.schedule,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Fecha y Hora',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        Formatters.formatDate(_selectedDate),
                                        style: theme.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedTime.format(context),
                                        style: theme.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Local/Visitante
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
                              Icons.home,
                              size: 18,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tipo de Juego',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isHome = true),
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _isHome 
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                    border: const Border(
                                      right: BorderSide(color: Colors.grey, width: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home,
                                        size: 16,
                                        color: _isHome 
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Local',
                                        style: TextStyle(
                                          color: _isHome
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurface,
                                          fontWeight: _isHome ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isHome = false),
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: !_isHome 
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.flight_takeoff,
                                        size: 16,
                                        color: !_isHome 
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Visitante',
                                        style: TextStyle(
                                          color: !_isHome
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurface,
                                          fontWeight: !_isHome ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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