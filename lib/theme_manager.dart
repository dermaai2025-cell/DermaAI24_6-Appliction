// lib/theme_manager.dart
import 'package:flutter/material.dart';

// Global controller for the theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class AppThemes {
  // ---  LIGHT THEME (Clean & Clinical) ---
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0056D2),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate White
    cardColor: Colors.white,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0056D2),
      surface: Colors.white,
      onSurface: Color(0xFF1E293B), // textDark
    ),
  );

  // --- DARK THEME (Stunning & Deep) ---
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3B82F6), // Electric Blue
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Midnight
    cardColor: const Color(0xFF1E293B), // Charcoal Slate
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      surface: Color(0xFF1E293B),
      onSurface: Color(0xFFF1F5F9), // Cloud White
    ),
  );
}