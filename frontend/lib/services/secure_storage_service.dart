import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants.dart';

class PkceData {
  final String state;
  final String codeVerifier;
  const PkceData(this.state, this.codeVerifier);
}

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ---------- Tokens ----------
  Future<void> saveTokens({required String accessToken, String? idToken}) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    if (idToken != null) {
      await _storage.write(key: AppConstants.keyIdToken, value: idToken);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> getIdToken() => _storage.read(key: AppConstants.keyIdToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyIdToken);
  }

  // ---------- PKCE (ต้องเก็บไว้ข้ามการ redirect ไปหน้า login) ----------
  Future<void> savePkce(PkceData data) async {
    await _storage.write(key: AppConstants.keyPkceState, value: data.state);
    await _storage.write(key: AppConstants.keyPkceVerifier, value: data.codeVerifier);
  }

  Future<PkceData?> readPkce() async {
    final state = await _storage.read(key: AppConstants.keyPkceState);
    final verifier = await _storage.read(key: AppConstants.keyPkceVerifier);
    if (state == null || verifier == null) return null;
    return PkceData(state, verifier);
  }

  Future<void> clearPkce() async {
    await _storage.delete(key: AppConstants.keyPkceState);
    await _storage.delete(key: AppConstants.keyPkceVerifier);
  }

  // ---------- Preferences ----------
  Future<void> saveThemeMode(String mode) =>
      _storage.write(key: AppConstants.keyThemeMode, value: mode);

  Future<String?> getThemeMode() => _storage.read(key: AppConstants.keyThemeMode);
}