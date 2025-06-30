import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  static ShadThemeData lightTheme() {
    return ShadThemeData(
      cardTheme: ShadCardTheme(
       padding: const EdgeInsets.all(4),
      ),
      brightness: Brightness.light,
      colorScheme: ShadColorScheme.fromName(
        'blue',
        brightness: Brightness.light,
      ),
    );
  }

  static ShadThemeData darkTheme() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: ShadColorScheme.fromName(
        'slate',
        brightness: Brightness.dark,
      ),
    );
  }

  // App-specific colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  
  // Position colors
  static const Map<String, Color> positionColors = {
    'P': Color(0xFF4CAF50),
    'C': Color(0xFF2196F3),
    '1B': Color(0xFFF44336),
    '2B': Color(0xFFFF9800),
    '3B': Color(0xFF9C27B0),
    'SS': Color(0xFF3F51B5),
    'LF': Color(0xFF009688),
    'CF': Color(0xFF607D8B),
    'RF': Color(0xFF795548),
    'DH': Color(0xFFFF5722),
  };
} 