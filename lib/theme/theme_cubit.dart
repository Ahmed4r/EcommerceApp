import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// States
abstract class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

class ThemeLight extends ThemeState {
  const ThemeLight() : super(ThemeMode.light);
}

class ThemeDark extends ThemeState {
  const ThemeDark() : super(ThemeMode.dark);
}

// Cubit
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeLight()) {
    _loadTheme();
  }

  void toggleTheme() {
    if (state is ThemeLight) {
      _saveTheme(ThemeMode.dark);
      emit(const ThemeDark());
    } else {
      _saveTheme(ThemeMode.light);
      emit(const ThemeLight());
    }
  }

  void setTheme(ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      _saveTheme(ThemeMode.dark);
      emit(const ThemeDark());
    } else {
      _saveTheme(ThemeMode.light);
      emit(const ThemeLight());
    }
  }

  bool get isDarkMode => state is ThemeDark;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;

      if (isDark) {
        emit(const ThemeDark());
      } else {
        emit(const ThemeLight());
      }
    } catch (e) {
      // If there's an error loading preferences, default to light theme
      emit(const ThemeLight());
    }
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, themeMode == ThemeMode.dark);
    } catch (e) {
      // Handle error silently - theme will still work for current session
    }
  }
}
