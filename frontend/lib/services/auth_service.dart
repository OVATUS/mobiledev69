import 'dart:math';

import 'package:openid_client/openid_client.dart';
import 'package:web/web.dart' as web;

import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user_profile.dart';
import 'secure_storage_service.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// คุยกับ OIDC Server (django-oidc-provider) ด้วย Authorization Code Flow + PKCE
class AuthService {
  final SecureStorageService _storage;
  final ApiClient _api;

  AuthService(this._storage, this._api);

  Future<Client> _createClient() async {
    final issuer = await Issuer.discover(Uri.parse(AppConstants.oidcIssuerUri));
    return Client(issuer, AppConstants.oidcClientId);
  }

  Flow _createFlow(Client client, {String? state, required String codeVerifier}) {
    final flow = Flow.authorizationCodeWithPKCE(
      client,
      state: state,
      codeVerifier: codeVerifier,
    )..redirectUri = Uri.parse(AppConstants.oidcRedirectUri);

    // django-oidc-provider ไม่ประกาศ scopes_supported ทำให้ library ตัด scope ทิ้งหมด
    // จึงต้องใส่ scope เองหลังสร้าง flow ไม่งั้นจะไม่ได้ id_token
    flow.scopes
      ..clear()
      ..addAll(AppConstants.oidcScopes);
    return flow;
  }

  /// ขั้นที่ 1: สร้าง code_verifier → เก็บไว้ → redirect ไปหน้า login ของ Django
  Future<void> login() async {
    final client = await _createClient();
    final verifier = _randomString(64);
    final flow = _createFlow(client, codeVerifier: verifier);

    await _storage.savePkce(PkceData(flow.state, verifier));
    web.window.location.href = flow.authenticationUri.toString();
  }

  /// ขั้นที่ 2: Django redirect กลับมาพร้อม ?code=...&state=...
  /// แลก code + code_verifier เป็น token  (คืนค่า true ถ้าเป็นการกลับมาจากหน้า login)
  Future<bool> handleCallbackIfPresent() async {
    final params = Map<String, String>.from(Uri.base.queryParameters);
    if (!params.containsKey('code') && !params.containsKey('error')) return false;

    _removeQueryFromUrl(); // กันไม่ให้รีเฟรชแล้วใช้ code เดิมซ้ำ

    if (params.containsKey('error')) {
      throw AuthException('การเข้าสู่ระบบถูกยกเลิก (${params['error']})');
    }

    final pkce = await _storage.readPkce();
    await _storage.clearPkce();
    if (pkce == null) {
      throw const AuthException('ไม่พบข้อมูลการล็อกอินเดิม กรุณากดเข้าสู่ระบบใหม่');
    }

    final client = await _createClient();
    final flow = _createFlow(client, state: pkce.state, codeVerifier: pkce.codeVerifier);
    final credential = await flow.callback(params); // ตรวจ state + ส่ง code_verifier

    final tokens = credential.response ?? const {};
    final accessToken = tokens['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('เซิร์ฟเวอร์ไม่ได้ส่ง access token กลับมา');
    }
    await _storage.saveTokens(
      accessToken: accessToken,
      idToken: tokens['id_token'] as String?,
    );
    return true;
  }

  Future<bool> hasSavedToken() async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// เรียก /openid/userinfo — ใช้ทั้งดึงชื่อผู้ใช้ และตรวจว่า token ยังใช้ได้
  Future<UserProfile> fetchUserInfo() async {
    final response = await _api.dio.get('/openid/userinfo');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> clearLocalSession() => _storage.clearTokens();

  /// Logout ครบ 3 ชั้น: ลบ token ที่ server → ลบ token ในเครื่อง → ปิด session ของ Django
  Future<void> logout() async {
    final idToken = await _storage.getIdToken();
    try {
      await _api.dio.post('/api/logout/');
    } catch (_) {
      // server ปิดอยู่ก็ยังล้างในเครื่องต่อได้
    }
    await _storage.clearTokens();

    if (idToken != null) {
      final endSession = Uri.parse('${AppConstants.oidcIssuerUri}/end-session').replace(
        queryParameters: {
          'id_token_hint': idToken,
          'post_logout_redirect_uri': AppConstants.oidcRedirectUri,
        },
      );
      web.window.location.href = endSession.toString();
    }
  }

  void _removeQueryFromUrl() {
    final location = web.window.location;
    web.window.history.replaceState(null, '', '${location.pathname}${location.hash}');
  }

  String _randomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}