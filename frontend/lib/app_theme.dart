import 'package:flutter/material.dart';

// Catppuccin Mocha (dark) & Latte (light) palettes
class Catppuccin {
  // ---- Latte (light) ----
  static const latteBase = Color(0xFFEFF1F5);
  static const latteMantle = Color(0xFFE6E9EF);
  static const latteCrust = Color(0xFFDCE0E8);
  static const latteSurface0 = Color(0xFFCCD0DA);
  static const latteSurface1 = Color(0xFFBCC0CC);
  static const latteSurface2 = Color(0xFFACB0BE);
  static const latteOverlay0 = Color(0xFF9CA0B0);
  static const latteOverlay1 = Color(0xFF8C8FA1);
  static const latteOverlay2 = Color(0xFF7C7F93);
  static const latteSubtext0 = Color(0xFF6C6F85);
  static const latteSubtext1 = Color(0xFF5C5F77);
  static const latteText = Color(0xFF4C4F69);
  static const latteLavender = Color(0xFF7287FD);
  static const latteBlue = Color(0xFF1E66F5);
  static const latteSapphire = Color(0xFF209FB5);
  static const latteSky = Color(0xFF04A5E5);
  static const latteTeal = Color(0xFF179299);
  static const latteGreen = Color(0xFF40A02B);
  static const latteYellow = Color(0xFFDF8E1D);
  static const lattePeach = Color(0xFFFE640B);
  static const latteMaroon = Color(0xFFE64553);
  static const latteRed = Color(0xFFD20F39);
  static const latteMauve = Color(0xFF8839EF);
  static const lattePink = Color(0xFFEA76CB);
  static const latteFlamingo = Color(0xFFDD7878);
  static const latteRosewater = Color(0xFFDC8A78);

  // ---- Mocha (dark) ----
  static const mochaBase = Color(0xFF1E1E2E);
  static const mochaMantle = Color(0xFF181825);
  static const mochaCrust = Color(0xFF11111B);
  static const mochaSurface0 = Color(0xFF313244);
  static const mochaSurface1 = Color(0xFF45475A);
  static const mochaSurface2 = Color(0xFF585B70);
  static const mochaOverlay0 = Color(0xFF6C7086);
  static const mochaOverlay1 = Color(0xFF7F849C);
  static const mochaOverlay2 = Color(0xFF9399B2);
  static const mochaSubtext0 = Color(0xFFA6ADC8);
  static const mochaSubtext1 = Color(0xFFBAC2DE);
  static const mochaText = Color(0xFFCDD6F4);
  static const mochaLavender = Color(0xFFB4BEFE);
  static const mochaBlue = Color(0xFF89B4FA);
  static const mochaSapphire = Color(0xFF74C7EC);
  static const mochaSky = Color(0xFF89DCEB);
  static const mochaTeal = Color(0xFF94E2D5);
  static const mochaGreen = Color(0xFFA6E3A1);
  static const mochaYellow = Color(0xFFF9E2AF);
  static const mochaPeach = Color(0xFFFAB387);
  static const mochaMaroon = Color(0xFFF38BA8);
  static const mochaRed = Color(0xFFF38BA8);
  static const mochaMauve = Color(0xFFCBA6F7);
  static const mochaPink = Color(0xFFF5C2E7);
  static const mochaFlamingo = Color(0xFFF2CDCD);
  static const mochaRosewater = Color(0xFFF5E0DC);
}

class AppTheme {
  static const pastelPrimary = Color(0xFF9B85A8);
  static const pastelPrimaryDark = Color(0xFFD7C8E0);
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppTheme.pastelPrimary,
      onPrimary: Catppuccin.latteBase,
      secondary: Catppuccin.latteLavender,
      onSecondary: Catppuccin.latteBase,
      tertiary: Catppuccin.latteTeal,
      onTertiary: Catppuccin.latteBase,
      surface: Catppuccin.latteBase,
      onSurface: Catppuccin.latteText,
      surfaceContainerHighest: Catppuccin.latteSurface0,
      error: Catppuccin.latteRed,
      onError: Catppuccin.latteBase,
      outline: Catppuccin.latteSurface1,
      outlineVariant: Catppuccin.latteSurface0,
    ),
    scaffoldBackgroundColor: Catppuccin.latteMantle,
    fontFamily: 'Poetsen',
    appBarTheme: const AppBarTheme(
      backgroundColor: Catppuccin.latteBase,
      foregroundColor: Catppuccin.latteText,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poetsen',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Catppuccin.latteText,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Catppuccin.latteBase,
      selectedItemColor: AppTheme.pastelPrimary,
      unselectedItemColor: Catppuccin.latteOverlay0,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Poetsen',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poetsen',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.pastelPrimary,
        foregroundColor: Catppuccin.latteBase,
        textStyle: const TextStyle(fontFamily: 'Poetsen', fontSize: 18),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.pastelPrimary,
        textStyle: const TextStyle(fontFamily: 'Poetsen', fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Catppuccin.latteSurface0,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.pastelPrimary, width: 2),
      ),
      hintStyle: TextStyle(
        color: Catppuccin.latteOverlay1.withValues(alpha: 0.7),
        fontSize: 16,
      ),
      labelStyle: const TextStyle(color: Catppuccin.latteOverlay1, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: Catppuccin.latteBase,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: Catppuccin.latteSurface0,
    dividerTheme: const DividerThemeData(
      color: Catppuccin.latteSurface0,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Catppuccin.latteSurface2,
      contentTextStyle: const TextStyle(
        color: Catppuccin.latteText,
        fontSize: 15,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Catppuccin.latteSurface0,
      selectedColor: AppTheme.pastelPrimary,
      labelStyle: const TextStyle(
        fontSize: 14,
        color: Catppuccin.latteText,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 14,
        color: Catppuccin.latteBase,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppTheme.pastelPrimary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppTheme.pastelPrimary,
      foregroundColor: Catppuccin.latteBase,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppTheme.pastelPrimary,
      thumbColor: AppTheme.pastelPrimary,
      inactiveTrackColor: Catppuccin.latteSurface0,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      fillColor: AppTheme.pastelPrimary.withValues(alpha: 0.15),
      selectedColor: AppTheme.pastelPrimary,
      disabledColor: Catppuccin.latteOverlay0,
      borderRadius: BorderRadius.circular(8),
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: Catppuccin.latteRed,
      textColor: Catppuccin.latteBase,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD7C8E0),
      onPrimary: Catppuccin.mochaBase,
      secondary: Catppuccin.mochaLavender,
      onSecondary: Catppuccin.mochaBase,
      tertiary: Catppuccin.mochaTeal,
      onTertiary: Catppuccin.mochaBase,
      surface: Catppuccin.mochaBase,
      onSurface: Catppuccin.mochaText,
      surfaceContainerHighest: Catppuccin.mochaSurface0,
      error: Catppuccin.mochaRed,
      onError: Catppuccin.mochaBase,
      outline: Catppuccin.mochaSurface1,
      outlineVariant: Catppuccin.mochaSurface0,
    ),
    scaffoldBackgroundColor: Catppuccin.mochaMantle,
    fontFamily: 'Poetsen',
    appBarTheme: const AppBarTheme(
      backgroundColor: Catppuccin.mochaBase,
      foregroundColor: Catppuccin.mochaText,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poetsen',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Catppuccin.mochaText,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Catppuccin.mochaBase,
      selectedItemColor: AppTheme.pastelPrimaryDark,
      unselectedItemColor: Catppuccin.mochaOverlay0,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Poetsen',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poetsen',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.pastelPrimaryDark,
        foregroundColor: Catppuccin.mochaBase,
        textStyle: const TextStyle(fontFamily: 'Poetsen', fontSize: 18),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.pastelPrimaryDark,
        textStyle: const TextStyle(fontFamily: 'Poetsen', fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Catppuccin.mochaSurface0,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.pastelPrimaryDark, width: 2),
      ),
      hintStyle: TextStyle(
        color: Catppuccin.mochaOverlay1.withValues(alpha: 0.7),
        fontSize: 16,
      ),
      labelStyle: const TextStyle(color: Catppuccin.mochaOverlay1, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: Catppuccin.mochaBase,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: Catppuccin.mochaSurface0,
    dividerTheme: const DividerThemeData(
      color: Catppuccin.mochaSurface0,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Catppuccin.mochaSurface2,
      contentTextStyle: const TextStyle(
        color: Catppuccin.mochaText,
        fontSize: 15,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Catppuccin.mochaSurface0,
      selectedColor: AppTheme.pastelPrimaryDark,
      labelStyle: const TextStyle(
        fontSize: 14,
        color: Catppuccin.mochaText,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 14,
        color: Catppuccin.mochaBase,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppTheme.pastelPrimaryDark,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppTheme.pastelPrimaryDark,
      foregroundColor: Catppuccin.mochaBase,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppTheme.pastelPrimaryDark,
      thumbColor: AppTheme.pastelPrimaryDark,
      inactiveTrackColor: Catppuccin.mochaSurface0,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      fillColor: AppTheme.pastelPrimaryDark.withValues(alpha: 0.15),
      selectedColor: AppTheme.pastelPrimaryDark,
      disabledColor: Catppuccin.mochaOverlay0,
      borderRadius: BorderRadius.circular(8),
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: Catppuccin.mochaRed,
      textColor: Catppuccin.mochaBase,
    ),
  );
}
