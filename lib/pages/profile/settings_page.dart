import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    final theme = Provider.of<ThemeProvider>(context, listen: false).themeData;
    _isDarkMode = theme.brightness == Brightness.dark;
  }

  void _toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value ? 'Dark mode enabled' : 'Light mode enabled')),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: _toggleTheme,
            secondary: const Icon(Icons.brightness_6),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
