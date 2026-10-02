import 'package:flutter/material.dart';

import '../repositories/theme_repository.dart';

class ThemeViewModel extends ChangeNotifier {
  final ThemeRepository _repository;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeViewModel(this._repository) {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _load() async {
    _themeMode = await _repository.loadThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _repository.saveThemeMode(_themeMode); // จำค่าไว้ รีเฟรชแล้วไม่หาย
  }
}