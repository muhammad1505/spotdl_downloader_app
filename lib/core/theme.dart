import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Spotify Colors
  static const Color spotifyGreen = Color(0xFF1DB954);
  static const Color spotifyGreenDark = Color(0xFF1AA34A);
  static const Color spotifyGreenLight = Color(0xFF1ED760);
  static const Color spotifyBlack = Color(0xFF121212);
  static const Color spotifyDarkGrey = Color(0xFF181818);
  static const Color spotifyGrey = Color(0xFF282828);
  static const Color spotifyLightGrey = Color(0xFF404040);
  static const Color spotifyWhite = Color(0xFFFFFFFF);
  static const Color spotifySubtle = Color(0xFFB3B3B3);

  // Log Colors
  static const Color logInfo = Color(0xFFE0E0E0);
  static const Color logWarning = Color(0xFFFFC107);
  static const Color logError = Color(0xFFFF5252);
  static const Color logSuccess = Color(0xFF1DB954);

  // Card & Surface
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF161616);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spotifyBlack,
      primaryColor: spotifyGreen,
      colorScheme: const ColorScheme.dark(
        primary: spotifyGreen,
        secondary: spotifyGreenDark,
        surface: spotifyDarkGrey,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        error: logError,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: spotifyWhite,
        displayColor: spotifyWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: spotifyBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: spotifyWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: spotifyWhite),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: spotifyGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: spotifyGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: spotifyGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: logError, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: spotifySubtle,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: spotifyDarkGrey,
        selectedItemColor: spotifyGreen,
        unselectedItemColor: spotifySubtle,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: spotifyGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: GoogleFonts.inter(
          color: spotifyWhite,
          fontSize: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return spotifyGreen;
          return spotifyLightGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return spotifyGreen.withAlpha(80);
          return spotifyGrey;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: spotifyLightGrey,
        thickness: 0.5,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: spotifyGreen,
        linearTrackColor: spotifyGrey,
      ),
    );
  }
}
