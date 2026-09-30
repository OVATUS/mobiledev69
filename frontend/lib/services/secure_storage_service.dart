import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String accessToken, {String? idToken}) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    if (idToken != null) {
      await _storage.write(key: AppConstants.keyIdToken, value: idToken);
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyIdToken);
  }
}