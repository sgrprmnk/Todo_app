import 'package:flutter/material.dart';

// Shared Text Styles
const String _fontFamily = 'Inter';

final _baseTextTheme = TextTheme(
  headlineLarge: const TextStyle(fontWeight: FontWeight.bold, fontFamily: _fontFamily),
  titleLarge: const TextStyle(fontWeight: FontWeight.w700, fontFamily: _fontFamily),
  bodyLarge: TextStyle(fontFamily: _fontFamily, color: Colors.grey[800]),
  bodyMedium: TextStyle(fontFamily: _fontFamily, color: Colors.grey[700]),
);

// --- LIGHT THEME ---

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    primary: Colors.teal,
    secondary: Colors.cyan,
    tertiary: Colors.blueGrey,
    background: Colors.grey[50],
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.grey[50],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.teal),
    titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: _fontFamily),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  textTheme: _baseTextTheme.apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  ),
  useMaterial3: true,
);

// --- DARK THEME ---

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    primary: Colors.tealAccent[400],
    secondary: Colors.cyanAccent[400],
    tertiary: Colors.blueGrey[400],
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.tealAccent),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: _fontFamily),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  textTheme: _baseTextTheme.apply(
    bodyColor: Colors.white70,
    displayColor: Colors.white,
  ),
  useMaterial3: true,
);