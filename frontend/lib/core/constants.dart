class AppConstants {
  static const String backendBaseUrl = 'http://localhost:8000';
  static const String oidcIssuerUri = '$backendBaseUrl/openid';
  static const String oidcClientId = 'flutter-task-app';

  // ⚠️ ต้องตรงกัน 3 จุด: ค่านี้ / REDIRECT_URI ใน backend/setup_demo.py / --web-port ใน README
  static const String oidcRedirectUri = 'http://localhost:50000/';
  static const List<String> oidcScopes = ['openid', 'profile', 'email'];

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyIdToken = 'id_token';
  static const String keyPkceState = 'pkce_state';
  static const String keyPkceVerifier = 'pkce_verifier';
  static const String keyThemeMode = 'theme_mode';
}