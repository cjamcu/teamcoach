class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    
    return null;
  }
  
  // Player number validation
  static String? validatePlayerNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número es requerido';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Ingrese un número válido';
    }
    
    if (number < 0 || number > 99) {
      return 'El número debe estar entre 0 y 99';
    }
    
    return null;
  }
  
  // Team name validation
  static String? validateTeamName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del equipo es requerido';
    }
    
    if (value.length < 3) {
      return 'El nombre del equipo debe tener al menos 3 caracteres';
    }
    
    if (value.length > 100) {
      return 'El nombre del equipo no puede exceder 100 caracteres';
    }
    
    return null;
  }
  
  // Position validation
  static String? validatePositions(List<String>? positions) {
    if (positions == null || positions.isEmpty) {
      return 'Debe seleccionar al menos una posición';
    }
    
    if (positions.length > 3) {
      return 'No puede seleccionar más de 3 posiciones';
    }
    
    return null;
  }
}

class Formatters {
  // Format player number with leading zero
  static String formatPlayerNumber(int number) {
    return number.toString().padLeft(2, '0');
  }
  
  // Format date for display
  static String formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }
  
  // Format time for display
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final displayHour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    
    return '$displayHour:$minute $period';
  }
  
  // Format game score
  static String formatScore(int homeScore, int awayScore) {
    return '$homeScore - $awayScore';
  }
  
  // Format batting average
  static String formatBattingAverage(double average) {
    return '.${(average * 1000).toStringAsFixed(0).padLeft(3, '0')}';
  }
  
  // Format percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
} 