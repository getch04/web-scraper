// Update AppTheme with additional styles
import 'package:flutter/material.dart';

class AppTheme {
  // Primary gradient colors
  static const primaryBlue = Color(0xFF00E1FF);
  static const primaryPink = Color(0xFFFF3D71);
  static const primaryYellow = Color(0xFFFFD93D);

  // Background and accent colors
  static const backgroundColor = Color(0xFF051B2C);  // Dark blue background
  static const surfaceColor = Color(0xFF0A2A44);    // Slightly lighter blue for cards
  static const accentColor = Color(0xFF00E1FF);     // Cyan for accents

  // Text colors
  static const textLight = Colors.white;
  static const textDark = Color(0xFF051B2C);

  static ThemeData theme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundColor,

    // Update AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textLight,
        letterSpacing: -0.5,
      ),
    ),

    // Update button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Add card theme
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Helper method for creating gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryBlue, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [primaryBlue, primaryYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
