import 'dart:async';

import 'package:dio/dio.dart';

import '../services/secure_storage_service.dart';
import 'constants.dart';

/// Dio ตัวกลางของทั้งแอป: แนบ Bearer token อัตโนมัติ และแจ้งเตือนเมื่อเจอ 401
class ApiClient {
  final SecureStorageService _storage;
  final StreamController<void> _unauthorized = StreamController<void>.broadcast();
  late final Dio dio;

  ApiClient(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.backendBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _unauthorized.add(null); // ให้ AuthViewModel พาผู้ใช้กลับหน้า Login
        }
        handler.next(error);
      },
    ));
  }

  /// ยิง event ทุกครั้งที่ server ตอบ 401 (token หมดอายุหรือถูกลบ)
  Stream<void> get onUnauthorized => _unauthorized.stream;
}