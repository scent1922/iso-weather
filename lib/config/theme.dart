import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      secondary: Color(0xFF64B5F6),
      surface: Color(0xFF1A1A2E),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x80000000)),
        ],
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000)),
        ],
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xB3FFFFFF),
        height: 1.5,
      ),
    ),
  );
}
