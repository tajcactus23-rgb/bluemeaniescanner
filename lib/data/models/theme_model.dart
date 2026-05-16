import 'package:flutter/material.dart';

/// Theme model for dynamic theming
class ThemeModel {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final bool isDark;

  const ThemeModel({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    this.isDark = true,
  });

  ThemeData toThemeData() => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      error: const Color(0xFFff0044),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: textPrimaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'RobotoMono',
        color: textPrimaryColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'RobotoMono',
        color: textSecondaryColor,
        fontSize: 14,
      ),
    ),
    iconTheme: IconThemeData(color: primaryColor),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'primary_color': primaryColor.value,
    'secondary_color': secondaryColor.value,
    'accent_color': accentColor.value,
    'background_color': backgroundColor.value,
    'card_color': cardColor.value,
    'text_primary_color': textPrimaryColor.value,
    'text_secondary_color': textSecondaryColor.value,
  };

  factory ThemeModel.fromJson(Map<String, dynamic> json) => ThemeModel(
    id: json['id'],
    name: json['name'],
    primaryColor: Color(json['primary_color']),
    secondaryColor: Color(json['secondary_color']),
    accentColor: Color(json['accent_color']),
    backgroundColor: Color(json['background_color']),
    cardColor: Color(json['card_color']),
    textPrimaryColor: Color(json['text_primary_color']),
    textSecondaryColor: Color(json['text_secondary_color']),
  );
}

/// Predefined themes
class Themes {
  Themes._();

  static final ThemeModel cyberpunk = const ThemeModel(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    primaryColor: Color(0xFF00f0ff),
    secondaryColor: Color(0xFFff00aa),
    accentColor: Color(0xFF00aaff),
    backgroundColor: Color(0xFF0a0a0f),
    cardColor: Color(0xFF12121a),
    textPrimaryColor: Color(0xFFffffff),
    textSecondaryColor: Color(0xFF8888aa),
  );

  static final ThemeModel redAlert = const ThemeModel(
    id: 'red_alert',
    name: 'Red Alert',
    primaryColor: Color(0xFFff3333),
    secondaryColor: Color(0xFFff8800),
    accentColor: Color(0xFFffaa00),
    backgroundColor: Color(0xFF0f0505),
    cardColor: Color(0xFF1a0a0a),
    textPrimaryColor: Color(0xFFffffff),
    textSecondaryColor: Color(0xFFaa6666),
  );

  static final ThemeModel stealth = const ThemeModel(
    id: 'stealth',
    name: 'Stealth',
    primaryColor: Color(0xFF66ff66),
    secondaryColor: Color(0xFF44aa44),
    accentColor: Color(0xFF88ff88),
    backgroundColor: Color(0xFF050a05),
    cardColor: Color(0xFF0a150a),
    textPrimaryColor: Color(0xFFccffcc),
    textSecondaryColor: Color(0xFF88aa88),
  );

  static final ThemeModel neonPink = const ThemeModel(
    id: 'neon_pink',
    name: 'Neon Pink',
    primaryColor: Color(0xFFff00aa),
    secondaryColor: Color(0xFFaa00ff),
    accentColor: Color(0xFFff66aa),
    backgroundColor: Color(0xFF0f0510),
    cardColor: Color(0xFF1a0a1a),
    textPrimaryColor: Color(0xFFffffff),
    textSecondaryColor: Color(0xFFaa88aa),
  );

  static final ThemeModel matrix = const ThemeModel(
    id: 'matrix',
    name: 'Matrix',
    primaryColor: Color(0xFF00ff00),
    secondaryColor: Color(0xFF00aa00),
    accentColor: Color(0xFF88ff88),
    backgroundColor: Color(0xFF000800),
    cardColor: Color(0xFF001000),
    textPrimaryColor: Color(0xFF00ff00),
    textSecondaryColor: Color(0xFF008800),
  );

  static final ThemeModel goldenHour = const ThemeModel(
    id: 'golden_hour',
    name: 'Golden Hour',
    primaryColor: Color(0xFFffaa00),
    secondaryColor: Color(0xFFff6600),
    accentColor: Color(0xFFffcc00),
    backgroundColor: Color(0xFF0f0800),
    cardColor: Color(0xFF1a1000),
    textPrimaryColor: Color(0xFFffffff),
    textSecondaryColor: Color(0xFFaa9955),
  );

  static final ThemeModel arctic = const ThemeModel(
    id: 'arctic',
    name: 'Arctic',
    primaryColor: Color(0xFF00ddff),
    secondaryColor: Color(0xFF0088aa),
    accentColor: Color(0xFF66ffff),
    backgroundColor: Color(0xFF050810),
    cardColor: Color(0xFF0a1020),
    textPrimaryColor: Color(0xFFffffff),
    textSecondaryColor: Color(0xFF88aabb),
  );

  static final ThemeModel voidTheme = const ThemeModel(
    id: 'void',
    name: 'Void',
    primaryColor: Color(0xFF9966ff),
    secondaryColor: Color(0xFF6633ff),
    accentColor: Color(0xFFbb99ff),
    backgroundColor: Color(0xFF080510),
    cardColor: Color(0xFF100a15),
    textPrimaryColor: Color(0xFFffffff),
    textSecondaryColor: Color(0xFFaa88bb),
  );

  static final ThemeModel solarized = const ThemeModel(
    id: 'solarized',
    name: 'Solarized',
    primaryColor: Color(0xFF268bd2),
    secondaryColor: Color(0xFFcb4b16),
    accentColor: Color(0xFF2aa198),
    backgroundColor: Color(0xFF002b36),
    cardColor: Color(0xFF073642),
    textPrimaryColor: Color(0xFFfdf6e3),
    textSecondaryColor: Color(0xFF93a1a1),
  );

  static final List<ThemeModel> all = [
    cyberpunk,
    redAlert,
    stealth,
    neonPink,
    matrix,
    goldenHour,
    arctic,
    voidTheme,
    solarized,
  ];
}