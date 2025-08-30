import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';

    if (theme == 'dark') {
      emit(ThemeMode.dark);
    } else if (theme == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
      await prefs.setString('theme', 'dark');
    } else if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
      await prefs.setString('theme', 'light');
    } else {
      emit(ThemeMode.dark);
      await prefs.setString('theme', 'dark');
    }
  }
}
