import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    _loadTheme();
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeString = prefs.getString(_themeKey);

    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  // Set and persist theme preference
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();

      String themeString;
      if (mode == ThemeMode.light) {
        themeString = 'light';
      } else if (mode == ThemeMode.dark) {
        themeString = 'dark';
      } else {
        themeString = 'system';
      }

      await prefs.setString(_themeKey, themeString);
      notifyListeners();
    }
  }

  // --- Theme Data Definition ---
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey.shade100,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.white,
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.tealAccent,
      surface: Colors.grey.shade900,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.grey.shade800,
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}