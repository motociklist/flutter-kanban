import 'package:flutter/material.dart';
import '../models/kanban_task.dart';

class AppStyles {
  // Core brand colors (used in light mode)
  static const Color primary = Color(0xFF6A1B9A); // deep violet
  static const Color secondary = Color(0xFF1976D2); // bright blue

  // Dark mode alternatives - более современные и яркие цвета
  static const Color primaryDark = Color(0xFFBB86FC); // яркий фиолетовый
  static const Color secondaryDark = Color(0xFF64B5F6); // яркий голубой

  // Темная тема цвета
  static const Color darkBackground = Color(0xFF121212); // Material Dark фон
  static const Color darkSurface = Color(0xFF1E1E1E); // Surface для карточек
  static const Color darkSurfaceVariant = Color(0xFF252525); // Вариант surface
  static const Color darkAppBar = Color(0xFF1E1B2E); // AppBar фон

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Градиент для темной темы
  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF1E1B2E), Color(0xFF121212)],
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

  // Стиль кнопки для темной темы
  static ButtonStyle elevatedButtonStyleDark({double verticalPadding = 14}) =>
      ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: primaryDark, // Яркий фиолетовый для темной темы
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

  // Dark theme - современная и гармоничная цветовая схема
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: darkSurface,
      surfaceContainerHighest: darkSurfaceVariant,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      error: Color(0xFFCF6679), // Мягкий красный для ошибок
    ),
    primaryColor: primaryDark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkAppBar,
      elevation: 0,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyleDark()),
    inputDecorationTheme: InputDecorationTheme(
      border: inputBorder,
      filled: true,
      fillColor: darkSurfaceVariant,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      labelStyle: TextStyle(color: Colors.grey.shade300),
      enabledBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: Colors.grey.shade800,
    listTileTheme: ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.grey.shade300,
    ),
  );

  // Цвета для статусов задач (светлая тема)
  static Color statusColorLight(KanbanStatus status) {
    switch (status) {
      case KanbanStatus.todo:
        return const Color(0xFFE3F2FD); // Светло-голубой
      case KanbanStatus.inProgress:
        return const Color(0xFFFFF3E0); // Светло-оранжевый
      case KanbanStatus.done:
        return const Color(0xFFE8F5E9); // Светло-зеленый
    }
  }

  // Цвета для статусов задач (темная тема) - более насыщенные и контрастные
  static Color statusColorDark(KanbanStatus status) {
    switch (status) {
      case KanbanStatus.todo:
        return const Color(0xFF2C3E6B); // Темно-синий с фиолетовым оттенком
      case KanbanStatus.inProgress:
        return const Color(0xFF6B4C3A); // Темно-оранжевый/коричневый
      case KanbanStatus.done:
        return const Color(0xFF3A5C3A); // Темно-зеленый
    }
  }

  // Получить цвет статуса в зависимости от темы
  static Color statusColor(KanbanStatus status, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? statusColorDark(status)
        : statusColorLight(status);
  }
}
