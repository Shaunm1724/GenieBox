import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // To access sharedPreferencesProvider

const String _themeModeKey = 'app_theme_mode';

// Provider for the Notifier
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

// State Notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final themeString = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
          (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system, // Default
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state != themeMode) {
      state = themeMode;
      await _prefs.setString(_themeModeKey, themeMode.toString());
    }
  }

  void toggleTheme() {
    setThemeMode(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}