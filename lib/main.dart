// lib/main.dart
import 'package:flutter/material.dart';
import 'package:grocery_list/themes/dark.dart';
import 'package:grocery_list/themes/light.dart';
import 'package:grocery_list/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme(),
      theme: lightTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const GroceryList(),
    );
  }
}
