import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF8DECB8);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        background: Colors.white,
        onSurface: const Color(0xFF0A0A0A),
        onBackground: const Color(0xFF0A0A0A),
        onPrimary: Colors.white,
        error: Colors.red[700]!,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: Colors.white,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black),
        actionsIconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        displayMedium: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        displaySmall: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        headlineLarge: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        headlineMedium: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        headlineSmall: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        titleLarge: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        titleMedium: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        titleSmall: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        bodyLarge: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        bodyMedium: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        bodySmall: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        labelLarge: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        labelMedium: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        labelSmall: TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[700]!, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Cairo'),
        labelStyle: const TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFF0A0A0A),
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFF0A0A0A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF0A0A0A),
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200]!,
        selectedColor: primaryColor,
        disabledColor: Colors.grey[300]!,
        labelStyle: const TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFF0A0A0A),
        iconColor: Color(0xFF0A0A0A),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey[300];
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: darkSurface,
        background: darkBackground,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onPrimary: Color(0xFF0A0A0A),
        error: Color(0xFFCF6679),
        onError: Colors.black,
      ),

      scaffoldBackgroundColor: darkBackground,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        displayMedium: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        displaySmall: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        headlineLarge: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        headlineMedium: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        headlineSmall: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        titleMedium: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        titleSmall: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        bodyMedium: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
        bodySmall: TextStyle(color: Colors.white60, fontFamily: 'Cairo'),
        labelLarge: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        labelMedium: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
        labelSmall: TextStyle(color: Colors.white60, fontFamily: 'Cairo'),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Cairo'),
        labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF0A0A0A),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[800],
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: primaryColor,
        disabledColor: Colors.grey[800]!,
        labelStyle: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF0A0A0A), fontFamily: 'Cairo'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey[700]!),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF0A0A0A);
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey[700];
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }
}