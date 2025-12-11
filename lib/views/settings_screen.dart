import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager/theme_manager.dart';
import '../widgets/task_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: isLargeScreen ? null : const CustomAppDrawer(),
      body: Center(
        child: Container(
          // Adaptive UI: Card max width for desktop/tablet
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Theme',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 30),
                  _buildThemeOption(
                    context,
                    'System Default',
                    Icons.settings_brightness,
                    ThemeMode.system,
                    themeManager,
                  ),
                  _buildThemeOption(
                    context,
                    'Light Mode',
                    Icons.light_mode,
                    ThemeMode.light,
                    themeManager,
                  ),
                  _buildThemeOption(
                    context,
                    'Dark Mode',
                    Icons.dark_mode,
                    ThemeMode.dark,
                    themeManager,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context,
      String title,
      IconData icon,
      ThemeMode mode,
      ThemeManager themeManager,
      ) {
    final isSelected = themeManager.themeMode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
        title: Text(title),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : null,
        onTap: () => themeManager.setThemeMode(mode),
        tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}