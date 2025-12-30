import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette based on original Boldask branding.
class BoldaskColors {
  // Primary colors
  static const Color primary = Color(0xFF0F413C);
  static const Color primaryLight = Color(0xFF1A5C55);
  static const Color primaryDark = Color(0xFF082B28);

  // Secondary colors
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7EDDD6);
  static const Color secondaryDark = Color(0xFF3BA99F);

  // Background colors
  static const Color backgroundLight = Color(0xFFF1F4F8);
  static const Color backgroundDark = Color(0xFF14181B);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E2429);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF14181B);
  static const Color textPrimaryDark = Color(0xFFF1F4F8);
  static const Color textSecondaryLight = Color(0xFF57636C);
  static const Color textSecondaryDark = Color(0xFF95A1AC);

  // Status colors
  static const Color success = Color(0xFF249689);
  static const Color error = Color(0xFFFF5963);
  static const Color warning = Color(0xFFF9CF58);
  static const Color info = Color(0xFF4B39EF);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF0F413C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App theme configuration.
class BoldaskTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: BoldaskColors.primary,
      scaffoldBackgroundColor: BoldaskColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: BoldaskColors.primary,
        secondary: BoldaskColors.secondary,
        surface: BoldaskColors.surfaceLight,
        error: BoldaskColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: BoldaskColors.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: _textTheme(BoldaskColors.textPrimaryLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: BoldaskColors.backgroundLight,
        foregroundColor: BoldaskColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BoldaskColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BoldaskColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: BoldaskColors.primary, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BoldaskColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.backgroundLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.backgroundLight, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.readexPro(
          color: BoldaskColors.textSecondaryLight,
          fontSize: 16,
        ),
      ),
      cardTheme: CardTheme(
        color: BoldaskColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BoldaskColors.surfaceLight,
        selectedItemColor: BoldaskColors.primary,
        unselectedItemColor: BoldaskColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: BoldaskColors.primary,
        unselectedLabelColor: BoldaskColors.textSecondaryLight,
        indicatorColor: BoldaskColors.primary,
        labelStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BoldaskColors.backgroundLight,
        selectedColor: BoldaskColors.primary,
        labelStyle: GoogleFonts.readexPro(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: BoldaskColors.primary,
      scaffoldBackgroundColor: BoldaskColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: BoldaskColors.secondary,
        secondary: BoldaskColors.secondary,
        surface: BoldaskColors.surfaceDark,
        error: BoldaskColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: BoldaskColors.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: _textTheme(BoldaskColors.textPrimaryDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: BoldaskColors.backgroundDark,
        foregroundColor: BoldaskColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BoldaskColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BoldaskColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: BoldaskColors.secondary, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BoldaskColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.backgroundDark, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.backgroundDark, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BoldaskColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.readexPro(
          color: BoldaskColors.textSecondaryDark,
          fontSize: 16,
        ),
      ),
      cardTheme: CardTheme(
        color: BoldaskColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BoldaskColors.surfaceDark,
        selectedItemColor: BoldaskColors.secondary,
        unselectedItemColor: BoldaskColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: BoldaskColors.secondary,
        unselectedLabelColor: BoldaskColors.textSecondaryDark,
        indicatorColor: BoldaskColors.secondary,
        labelStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BoldaskColors.surfaceDark,
        selectedColor: BoldaskColors.secondary,
        labelStyle: GoogleFonts.readexPro(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: GoogleFonts.readexPro(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.readexPro(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.readexPro(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.readexPro(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: GoogleFonts.readexPro(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: GoogleFonts.readexPro(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.readexPro(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.readexPro(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
