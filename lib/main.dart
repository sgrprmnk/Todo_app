import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_ai/views/home_screen.dart';
import 'package:todo_ai/views/settings_screen.dart';
import 'package:todo_ai/views/stats_screen.dart';
import 'manager/task_manager.dart';
import 'manager/theme_manager.dart';


void main() async {
  // Ensure Flutter engine is initialized before running Hive or SharedPrefs
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and load persistent data and settings managers
  final taskManager = TaskManager();
  final themeManager = ThemeManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeManager),
        ChangeNotifierProvider(create: (_) => taskManager),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch ThemeManager to react to theme changes
    final themeManager = context.watch<ThemeManager>();

    return MaterialApp(
      title: 'Task Manager Pro',
      debugShowCheckedModeBanner: false,

      // Theme Support (Light/Dark/System)
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: themeManager.themeMode, // Controlled by user setting

      // Routing
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/stats': (context) => const StatsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}