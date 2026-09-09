import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(AppConstants.keyThemeMode);

    state = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConstants.keyThemeMode, isDark ? 'dark' : 'light');
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ReduceAnimationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadPreference();
    return false;
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();

    state = prefs.getBool(AppConstants.keyReduceAnimations) ?? false;
  }

  Future<void> toggleReduce(bool value) async {
    state = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(AppConstants.keyReduceAnimations, value);
  }
}

final reduceAnimationsProvider =
    NotifierProvider<ReduceAnimationsNotifier, bool>(
      ReduceAnimationsNotifier.new,
    );
