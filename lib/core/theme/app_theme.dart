import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Цветовая палитра из макета
  static const Color lightBg = Color(0xFFE8E4F0);
  static const Color lightSurface = Color(0xFFF5F3FA);
  static const Color lightInput = Color(0xFFD9D4E8);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF252542);
  static const Color darkInput = Color(0xFF343452);
  static const Color primaryLight = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF8B7EC8);
  static const Color textLight = Color(0xFF2D2D44);
  static const Color textDark = Color(0xFFE8E4F0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      secondary: primaryLight.withOpacity(0.8),
      tertiary: primaryLight.withOpacity(0.6),
      surface: lightSurface,
      background: lightBg,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
      onBackground: textLight,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBg,
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      headlineLarge: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        color: textLight,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        color: textLight.withOpacity(0.7),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      foregroundColor: textLight,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      iconTheme: const IconThemeData(color: textLight),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: lightSurface,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: TextStyle(color: textLight.withOpacity(0.6)),
      hintStyle: TextStyle(color: textLight.withOpacity(0.4)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightSurface,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: textLight,
        fontSize: 16,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightInput,
      selectedColor: primaryLight,
      labelStyle: const TextStyle(color: textLight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryLight),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightSurface,
      indicatorColor: primaryLight.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: primaryLight, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: textLight.withOpacity(0.5));
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: primaryLight);
        }
        return IconThemeData(color: textLight.withOpacity(0.5));
      }),
    ),
    dividerColor: textLight.withOpacity(0.1),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      secondary: primaryDark.withOpacity(0.8),
      tertiary: primaryDark.withOpacity(0.6),
      surface: darkSurface,
      background: darkBg,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onBackground: textDark,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      headlineLarge: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        color: textDark.withOpacity(0.7),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      foregroundColor: textDark,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      iconTheme: const IconThemeData(color: textDark),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: darkSurface,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: TextStyle(color: textDark.withOpacity(0.6)),
      hintStyle: TextStyle(color: textDark.withOpacity(0.4)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: textDark,
        fontSize: 16,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkInput,
      selectedColor: primaryDark,
      labelStyle: const TextStyle(color: textDark),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryDark),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: primaryDark.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: primaryDark, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: textDark.withOpacity(0.5));
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: primaryDark);
        }
        return IconThemeData(color: textDark.withOpacity(0.5));
      }),
    ),
    dividerColor: textDark.withOpacity(0.1),
  );
}