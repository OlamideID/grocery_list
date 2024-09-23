// lib/theme/dark_theme.dart
import 'package:flutter/material.dart';

final darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 147, 229, 250),
  brightness: Brightness.dark,
  surface: const Color.fromARGB(255, 42, 51, 59),
);

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    colorScheme: darkColorScheme,
    // scaffoldBackgroundColor: darkColorScheme.onSecondaryContainer,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        splashColor: darkColorScheme.secondary,
        shape: const CircleBorder(),
        backgroundColor: darkColorScheme.surfaceContainerHigh,
        foregroundColor: Colors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      titleTextStyle: TextStyle(
        color: darkColorScheme.onSecondaryContainer,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: darkColorScheme.secondaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkColorScheme.onPrimary,
      ),
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
  );
}
