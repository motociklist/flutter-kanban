import 'package:flutter/material.dart';

class AppStyles {
  // Core brand colors (used in light mode)
  static const Color primary = Color(0xFF6A1B9A); // deep violet
  static const Color secondary = Color(0xFF1976D2); // bright blue

  // Dark mode alternatives
  static const Color primaryDark = Color(0xFF9C47C1);
  static const Color secondaryDark = Color(0xFF42A5F5);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  );

  static InputDecoration inputDecoration({required String hint, IconData? prefixIcon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
      );

  static ButtonStyle elevatedButtonStyle({double verticalPadding = 14}) =>
      ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFFFA726),
        foregroundColor: Colors.white,
        elevation: 4,
      );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, secondary: secondary),
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFFF7FAFF),
    appBarTheme: const AppBarTheme(backgroundColor: primary),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle()),
    inputDecorationTheme: InputDecorationTheme(border: inputBorder, filled: true, fillColor: Colors.grey.shade100),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryDark, primary: primaryDark, secondary: secondaryDark, brightness: Brightness.dark),
    primaryColor: primaryDark,
    scaffoldBackgroundColor: const Color(0xFF0B1020),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1B2F)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle()),
    inputDecorationTheme: InputDecorationTheme(border: inputBorder, filled: true, fillColor: Colors.grey.shade800),
  );
}
