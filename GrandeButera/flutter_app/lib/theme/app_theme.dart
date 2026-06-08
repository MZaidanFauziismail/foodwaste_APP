import 'package:flutter/material.dart';

class AppTheme {
  // Main blue identity inspired by the provided logo
  static const Color primary = Color(0xFF4F9BFF);
  static const Color primaryLight = Color(0xFF8EDFFF);
  static const Color primaryDark = Color(0xFF2F73F6);
  static const Color secondary = Color(0xFF61C9FF);
  static const Color accent = Color(0xFF6AE4D9);
  static const Color green = Color(0xFF26C281);
  static const Color teal = Color(0xFF36C5D8);

  static const Color bgLight = Color(0xFFF4FAFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF12304C);
  static const Color textSecondary = Color(0xFF6A85A0);
  static const Color divider = Color(0xFFE0ECF8);

  static const Map<String, Color> categoryColors = {
    'free_food': Color(0xFF31C7D7),
    'free_nonfood': Color(0xFF5D9DFF),
    'for_sale': Color(0xFF3D7BFF),
    'borrow': Color(0xFF5AD0FF),
    'wanted': Color(0xFF6F8DFF),
  };

  static const Map<String, String> categoryLabels = {
    'free_food': 'Free Food',
    'free_nonfood': 'Free Non-Food',
    'for_sale': 'For Sale',
    'borrow': 'Borrow',
    'wanted': 'Wanted',
  };

  static const Map<String, IconData> categoryIcons = {};

  static LinearGradient primaryGradient({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) => LinearGradient(
    begin: begin,
    end: end,
    colors: const [Color(0xFF97EEFF), Color(0xFF62B8FF), Color(0xFF3D7BFF)],
    stops: const [0.0, 0.55, 1.0],
  );

  static LinearGradient skyGradient({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) => LinearGradient(
    begin: begin,
    end: end,
    colors: const [Color(0xFFE8FBFF), Color(0xFFD6F3FF), Color(0xFFBFE7FF)],
  );

  static LinearGradient gradientFor(
    Color base, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    final light = Color.lerp(base, Colors.white, 0.26)!;
    final dark = Color.lerp(base, const Color(0xFF2E6FE8), 0.18)!;
    return LinearGradient(begin: begin, end: end, colors: [light, dark]);
  }

  static BoxDecoration gradientDecoration({
    BorderRadius? borderRadius,
    List<Color>? colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    gradient: LinearGradient(
      begin: begin,
      end: end,
      colors: colors ?? const [Color(0xFF97EEFF), Color(0xFF62B8FF), Color(0xFF3D7BFF)],
    ),
    borderRadius: borderRadius,
    boxShadow: boxShadow,
  );

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light).copyWith(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEAF6FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: 'Nunito',
          color: Color(0xFF9DB5CB),
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
