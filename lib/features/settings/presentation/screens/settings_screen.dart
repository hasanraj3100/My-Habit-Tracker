import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/app_theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void sendFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send feedback clicked')),
    );
  }

  void rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate the app clicked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: colors.primary,
      ),
      backgroundColor: colors.background,
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView(
            children: [
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Dark Mode"),
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: colors.primary,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              Divider(color: colors.border),
              ListTile(
                leading: Icon(Icons.feedback, color: colors.secondary),
                title: Text(
                  "Send Feedback",
                  style: TextStyle(color: colors.textPrimary),
                ),
                onTap: () => sendFeedback(context),
              ),
              Divider(color: colors.border),
              ListTile(
                leading: Icon(Icons.star_rate, color: colors.warning),
                title: Text(
                  "Rate the App",
                  style: TextStyle(color: colors.textPrimary),
                ),
                onTap: () => rateApp(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
