import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF79926);
  static const Color accentColor = Color(0xFFFFA12E);

  static const Color primaryColorDark = Color(0xFFF79926);
  static const Color accentColorDark = Color(0xFFBDBDBD);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: accentColor,
    ),
    fontFamily: 'Poetsen',
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Poetsen', fontSize: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: accentColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: accentColor, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 16.0,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.dark,
      primary: primaryColorDark,
      secondary: accentColorDark,
      surface: const Color(0xFF121212),
      onPrimary: Colors.white,
    ),
    fontFamily: 'Poetsen',
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: primaryColorDark,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Poetsen', fontSize: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: primaryColorDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: primaryColorDark, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 16.0,
      ),
    ),
  );
}
