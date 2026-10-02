import 'package:flutter/material.dart';

import '../services/secure_storage_service.dart';

class ThemeRepository {
  final SecureStorageService _storage;

  ThemeRepository(this._storage);

  Future<ThemeMode> loadThemeMode() async {
    final saved = await _storage.getThemeMode();
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _storage.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
}