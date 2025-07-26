import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode currentTheme = ThemeMode.dark;

  ThemeData get dark => AppThemes.darkTheme;
  ThemeData get light => AppThemes.lightTheme;

  ThemeProvider([ThemeData? defaultTheme]) {
    if (defaultTheme != null) {
      currentTheme = defaultTheme.brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }
  }

  void toggleTheme() {
    currentTheme =
    currentTheme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    saveTheme();
    notifyListeners();
  }

  bool get isDarkMode => currentTheme == ThemeMode.dark;

  ThemeData get activeTheme =>
      currentTheme == ThemeMode.dark ? dark : light;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    currentTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', currentTheme == ThemeMode.dark);
  }
}
