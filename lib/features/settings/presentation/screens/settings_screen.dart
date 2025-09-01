import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    // You can add your dark mode handling logic here
  }

  void sendFeedback() {
    // Implement feedback functionality (e.g., open email or feedback form)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send feedback clicked')),
    );
  }

  void rateApp() {
    // Implement rate app functionality (e.g., redirect to app store)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate the app clicked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: toggleDarkMode,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.orangeAccent),
            title: const Text("Send Feedback"),
            onTap: sendFeedback,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.amber),
            title: const Text("Rate the App"),
            onTap: rateApp,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
