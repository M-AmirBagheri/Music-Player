import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  void toggleTheme() async {
    final isDark = _themeData.brightness == Brightness.dark;
    _themeData = isDark ? AppThemes.lightTheme : AppThemes.darkTheme;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isDark);

    notifyListeners();
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeData = isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
    notifyListeners();
  }
}
