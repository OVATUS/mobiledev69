import '../core/result.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<Result<bool>> checkLoginStatus() async {
    try {
      // 1. ตรวจสอบว่ามี Token ที่ส่งกลับมาจาก OIDC Redirect หรือไม่
      final callbackToken = await _authService.handleAuthCallback();
      if (callbackToken != null) {
        return const Success(true);
      }

      // 2. ถ้าไม่มี callback ให้เช็ก Token ใน Secure Storage เดิม
      final savedToken = await _authService.getSavedToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        return const Success(true);
      }

      return const Success(false);
    } catch (e) {
      return Failure('Authentication check failed: ${e.toString()}');
    }
  }

  Future<Result<void>> login() async {
    try {
      await _authService.login();
      return const Success(null);
    } catch (e) {
      return Failure('Cannot initiate OIDC login: ${e.toString()}');
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _authService.logout();
      return const Success(null);
    } catch (e) {
      return Failure('Logout failed: ${e.toString()}');
    }
  }
}