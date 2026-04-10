import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF1A56DB);
  static const accent = Color(0xFFFF6B35);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const surface = Color(0xFFF0F4FF);

  static Color statusColor(String status) {
    switch (status) {
      case 'open': return danger;
      case 'inProgress': return warning;
      case 'resolved': return success;
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'low': return success;
      case 'medium': return warning;
      case 'high': return accent;
      case 'critical': return danger;
      default: return Colors.grey;
    }
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}