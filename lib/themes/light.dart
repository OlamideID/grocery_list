// lib/theme/light_theme.dart
import 'package:flutter/material.dart';

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 147, 229, 250),
  brightness: Brightness.light,
  surface: const Color.fromARGB(255, 42, 51, 59),
);

ThemeData lightTheme() {
  return ThemeData.light().copyWith(
    colorScheme: lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primaryContainer,
      titleTextStyle: TextStyle(
        color: lightColorScheme.onSecondaryContainer,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Colors.grey[800],
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        splashColor: lightColorScheme.secondary,
        shape: const CircleBorder(),
        backgroundColor: lightColorScheme.surfaceContainerHigh,
        foregroundColor: Colors.black),
    cardTheme: CardTheme(
      color: lightColorScheme.secondaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme.onPrimary,
      ),
    ),
    textTheme: ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
  );
}
