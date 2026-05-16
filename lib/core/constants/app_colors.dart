import 'package:flutter/material.dart';

/// Cyberpunk color palette for Axon Scout app
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0a0a0f);
  static const Color backgroundCard = Color(0xFF12121a);
  static const Color backgroundSurface = Color(0xFF1a1a25);

  // Primary neon colors
  static const Color primaryNeon = Color(0xFF00f0ff);
  static const Color secondaryNeon = Color(0xFFff00aa);
  static const Color accent = Color(0xFF00aaff);

  // Status colors
  static const Color warning = Color(0xFFff8800);
  static const Color success = Color(0xFF00ff88);
  static const Color error = Color(0xFFff0044);

  // Text colors
  static const Color textPrimary = Color(0xFFffffff);
  static const Color textSecondary = Color(0xFF8888aa);
  static const Color textMuted = Color(0xFF555566);

  // Glow effects
  static const Color glowCyan = Color(0x4000f0ff);
  static const Color glowPink = Color(0x40ff00aa);
  static const Color glowBlue = Color(0x4000aaff);

  // Radar rings
  static const Color radarRing1 = Color(0xFF00ff88);
  static const Color radarRing2 = Color(0xFF00aaff);
  static const Color radarRing3 = Color(0xFFff8800);

  // Signal strength zones
  static const Color signalStrong = Color(0xFF00ff88);
  static const Color signalMedium = Color(0xFF00aaff);
  static const Color signalWeak = Color(0xFFff8800);

  // Gradient presets
  static const LinearGradient neonGradient = LinearGradient(
    colors: [primaryNeon, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [backgroundCard, backgroundSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Dark theme variant
class DarkTheme {
  DarkTheme._();
  
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryNeon,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.backgroundCard,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryNeon,
      secondary: AppColors.secondaryNeon,
      surface: AppColors.backgroundCard,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundCard,
      selectedItemColor: AppColors.primaryNeon,
      unselectedItemColor: AppColors.textSecondary,
    ),
    cardTheme: CardTheme(
      color: AppColors.backgroundCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Orbitron',
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'RobotoMono',
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'RobotoMono',
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.primaryNeon,
    ),
  );
}