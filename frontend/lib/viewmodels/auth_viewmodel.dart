import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<void>? _expiredSub;

  bool _isInitializing = true; // ตรวจ session ตอนเปิดแอป (router จะโชว์ splash)
  bool _isBusy = false; // กำลังกด login/logout (ใช้หมุนปุ่ม)
  bool _isAuthenticated = false;
  UserProfile? _user;
  String? _errorMessage;

  bool get isInitializing => _isInitializing;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _isAuthenticated;
  UserProfile? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthViewModel(this._repository) {
    _expiredSub = _repository.sessionExpired.listen((_) => _onSessionExpired());
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final result = await _repository.restoreSession();
    switch (result) {
      case Success(:final data):
        _user = data;
        _isAuthenticated = data != null;
      case Failure(:final message):
        _isAuthenticated = false;
        _errorMessage = message;
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> login() async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login();
    // ถ้าสำเร็จ browser จะ redirect ออกไปหน้า login ของ Django เอง
    if (result case Failure(:final message)) {
      _errorMessage = message;
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isBusy = true;
    notifyListeners();

    final result = await _repository.logout();
    if (result case Failure(:final message)) {
      _errorMessage = message;
    }
    _user = null;
    _isAuthenticated = false;
    _isBusy = false;
    notifyListeners();
  }

  Future<void> _onSessionExpired() async {
    if (!_isAuthenticated) return;
    await _repository.clearLocalSession();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่';
    notifyListeners();
  }

  @override
  void dispose() {
    _expiredSub?.cancel();
    super.dispose();
  }
}