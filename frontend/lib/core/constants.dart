class AppConstants {
  static const String backendBaseUrl = 'http://localhost:8000';
  static const String oidcIssuerUri = 'http://localhost:8000/openid';
  static const String oidcClientId = 'flutter-task-app';
  static const String oidcRedirectUri = 'http://localhost:50000/';
  static const String apiTasksUrl = '$backendBaseUrl/api/tasks/';
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyIdToken = 'id_token';
}