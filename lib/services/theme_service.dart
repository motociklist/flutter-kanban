import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static const String _themeModeSystem = 'system';
  static const String _themeModeLight = 'light';
  static const String _themeModeDark = 'dark';

  // Получить сохраненный режим темы
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? _themeModeSystem;
  }

  // Сохранить режим темы
  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  // Получить ThemeMode на основе сохраненных настроек и системной темы
  // ВАЖНО: не использовать BuildContext здесь, так как это может быть вызвано через async gap
  // Вместо этого используйте ThemeMode.system в MaterialApp, он автоматически следует системной теме
  static Future<ThemeMode> getThemeModeForApp(Brightness? systemBrightness) async {
    final savedMode = await getThemeMode();

    if (savedMode == _themeModeSystem) {
      // Следовать системной теме
      if (systemBrightness != null) {
        return systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
      // Если системная тема неизвестна, используем светлую тему по умолчанию
      return ThemeMode.light;
    } else if (savedMode == _themeModeDark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  // Установить режим темы
  static Future<void> setThemeModeEnum(ThemeMode mode) async {
    String modeString;
    if (mode == ThemeMode.dark) {
      modeString = _themeModeDark;
    } else if (mode == ThemeMode.light) {
      modeString = _themeModeLight;
    } else {
      modeString = _themeModeSystem;
    }
    await setThemeMode(modeString);
  }

  // Получить bool значение (для обратной совместимости)
  // true = dark, false = light, null = system
  static Future<bool?> getDarkMode() async {
    final mode = await getThemeMode();
    if (mode == _themeModeDark) return true;
    if (mode == _themeModeLight) return false;
    return null; // system
  }

  // Установить bool значение (для обратной совместимости)
  static Future<void> setDarkMode(bool? isDark) async {
    if (isDark == null) {
      await setThemeMode(_themeModeSystem);
    } else if (isDark) {
      await setThemeMode(_themeModeDark);
    } else {
      await setThemeMode(_themeModeLight);
    }
  }
}

