import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client_browser.dart' as oidc;
import '../core/constants.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storageService;

  AuthService(this._storageService);

  // เริ่มต้นกระบวนการ Login (Redirect ไปหน้า OIDC Server)
  Future<void> login() async {
    final issuer = await oidc.Issuer.discover(Uri.parse(AppConstants.oidcIssuerUri));
    final client = oidc.Client(issuer, AppConstants.oidcClientId);

    final authenticator = oidc.Authenticator(
      client,
      scopes: const ['openid', 'profile', 'email'],
    );

    authenticator.authorize();
  }

  // ตรวจสอบและดึง Access Token จาก Callback URL
  Future<String?> handleAuthCallback() async {
    try {
      final uri = Uri.base;
      debugPrint('👉 Checking Auth Callback URL: $uri');

      String? token;

      // 1. ดึง Access Token จาก URL Fragment (#access_token=... หรือ #/access_token=...)
      if (uri.hasFragment) {
        var fragment = uri.fragment;
        if (fragment.startsWith('/')) {
          fragment = fragment.substring(1);
        }
        if (fragment.contains('access_token=')) {
          final params = Uri.splitQueryString(fragment);
          token = params['access_token'];
        }
      }

      // 2. ดึง Access Token จาก Query Parameter (?access_token=...)
      if (token == null && uri.queryParameters.containsKey('access_token')) {
        token = uri.queryParameters['access_token'];
      }

      // 3. ถ้าได้ Token จาก URL ให้บันทึกลง Secure Storage ทันที
      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Found Access Token from URL callback!');
        await _storageService.saveToken(token);
        return token;
      }

      // 4. กรณีที่ Django ส่งกลับมาเป็น Code (Authorization Code Flow)
      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code']!;
        debugPrint('👉 Exchanging code for token: $code');
        final dio = Dio();
        final response = await dio.post(
          '${AppConstants.backendBaseUrl}/openid/token',
          data: {
            'grant_type': 'authorization_code',
            'client_id': AppConstants.oidcClientId,
            'code': code,
            'redirect_uri': AppConstants.oidcRedirectUri,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );

        final exchangedToken = response.data['access_token'] as String?;
        if (exchangedToken != null && exchangedToken.isNotEmpty) {
          debugPrint('✅ Exchanged code for Access Token successfully!');
          await _storageService.saveToken(exchangedToken);
          return exchangedToken;
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error in handleAuthCallback: $e');
      debugPrint('$stack');
    }
    return null;
  }

  // ตรวจสอบ Token ที่เคยบันทึกไว้ใน Local Storage
  Future<String?> getSavedToken() async {
    return await _storageService.getAccessToken();
  }

  // ล้าง Token ออกจาก Storage (Logout)
  Future<void> logout() async {
    await _storageService.clearTokens();
  }
}