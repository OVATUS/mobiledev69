import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel(this._repository) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.checkLoginStatus();
    switch (result) {
      case Success(:final data):
        _isAuthenticated = data;
        _errorMessage = null;
      case Failure(:final message):
        _isAuthenticated = false;
        _errorMessage = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoading = true;
    notifyListeners();
    final result = await _repository.login();
    if (result is Failure) {
      _errorMessage = (result as Failure).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _repository.logout();
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }
}