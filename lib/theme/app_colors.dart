import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5A4BB8);

  // Secondary Colors
  static const Color secondary = Color(0xFFA29BFE);
  static const Color secondaryLight = Color(0xFFC5B9FF);
  static const Color secondaryDark = Color(0xFF8F7EC9);

  // Accent Colors
  static const Color accent = Color(0xFF00B894);
  static const Color accentLight = Color(0xFF55D9B8);
  static const Color accentDark = Color(0xFF009668);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFF9CA3AF);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color darkGray = Color(0xFF4B5563);

  // Semantic Colors
  static const Color success = accent;
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = primary;

  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color background = Color(0xFFFFFFFF);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warningSurface = Color(0xFFFEF3C7);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7),
    Color(0xFFA29BFE),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF00B894),
    Color(0xFF55D9B8),
  ];

  static const List<Color> mixedGradient = [
    Color(0xFF6C5CE7),
    Color(0xFFA29BFE),
    Color(0xFF00B894),
  ];

  // Shadow Color
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Overlay Color
  static const Color overlay = Color(0x40000000);

  // Shimmer Colors (for loading)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Disabled Color
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color disabledText = Color(0xFF9CA3AF);
}

/// Material Color for ThemeData
class AppColorTheme {
  static MaterialColor createMaterialColor(Color color) {
    List<Color> colors = [
      color.withOpacity(0.05),
      color.withOpacity(0.1),
      color.withOpacity(0.2),
      color.withOpacity(0.3),
      color.withOpacity(0.4),
      color.withOpacity(0.5),
      color.withOpacity(0.6),
      color.withOpacity(0.7),
      color.withOpacity(0.8),
      color.withOpacity(0.9),
    ];

    return MaterialColor(color.value, <int, Color>{
      50: colors[0],
      100: colors[1],
      200: colors[2],
      300: colors[3],
      400: colors[4],
      500: color,
      600: colors[5],
      700: colors[6],
      800: colors[7],
      900: colors[8],
    });
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      background: AppColors.lightGray,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      background: const Color(0xFF1F1F1F),
      surface: const Color(0xFF2A2A2A),
      onPrimary: AppColors.white,
      onSurface: AppColors.white,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
