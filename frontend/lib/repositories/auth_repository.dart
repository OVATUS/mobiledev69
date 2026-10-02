import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/error_mapper.dart';
import '../core/result.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final ApiClient _apiClient;

  AuthRepository(this._authService, this._apiClient);

  /// แจ้งเมื่อ API ตอบ 401 ระหว่างใช้งาน (token หมดอายุ)
  Stream<void> get sessionExpired => _apiClient.onUnauthorized;

  /// ตอนเปิดแอป: รับ callback จาก OIDC (ถ้ามี) → ตรวจ token ที่เก็บไว้กับ server
  /// Success(null) = ยังไม่ได้ล็อกอิน
  Future<Result<UserProfile?>> restoreSession() async {
    try {
      await _authService.handleCallbackIfPresent();

      if (!await _authService.hasSavedToken()) return const Success(null);

      final user = await _authService.fetchUserInfo();
      return Success(user);
    } on AuthException catch (e) {
      return Failure(e.message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.clearLocalSession(); // token หมดอายุ → ล็อกอินใหม่
        return const Success(null);
      }
      return Failure(mapErrorToMessage(e)); // เน็ตหลุด: เก็บ token ไว้ก่อน ไม่ลบ
    } catch (e) {
      return Failure('ตรวจสอบการเข้าสู่ระบบไม่สำเร็จ: $e');
    }
  }

  Future<Result<void>> login() async {
    try {
      await _authService.login();
      return const Success(null);
    } catch (e) {
      return const Failure('เปิดหน้าเข้าสู่ระบบไม่ได้ กรุณาตรวจสอบว่า backend เปิดอยู่');
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _authService.logout();
      return const Success(null);
    } catch (e) {
      return Failure('ออกจากระบบไม่สำเร็จ: $e');
    }
  }

  Future<void> clearLocalSession() => _authService.clearLocalSession();
}