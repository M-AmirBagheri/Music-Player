import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.purple,
    colorScheme: const ColorScheme.dark(
      primary: Colors.purple,
      secondary: Colors.purpleAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.purple,
    colorScheme: const ColorScheme.light(
      primary: Colors.purple,
      secondary: Colors.purpleAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );
}
