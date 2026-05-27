import 'package:flutter/material.dart';

class StackMoneyTheme {
  static final ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF09090B),

    // Customização das cores principais do app
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00F3FF),       // Cyan para focos principais
      secondary: Color(0xFFFF007F),     // Magenta para contrastes secundários
      surface: Color(0xFF141416),       // Cor dos Cards
      onSurface: Color(0xFFFFFFFF),     // Texto principal nos cards
      error: Color(0xFFFF007F),         // Magenta mapeado para estados de erro/negativos
    ),

    // Um bônus: deixando os inputs de texto com a cara do tema
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF141416),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00F3FF), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF71717A), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}