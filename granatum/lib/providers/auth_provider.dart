import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  bool _authenticated = false;
  bool get authenticated => _authenticated;

  AuthProvider(this._authService);

  Future<void> login(String password) async {
    try {
      await _authService.login(password);
      _authenticated = true;
    } on Exception catch (e) {
      _authenticated = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signup(String password) async {
    try {
      await _authService.signup(password);
      _authenticated = true;
    } on Exception catch (e) {
      _authenticated = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    //await _authService.logout();
    _authenticated = false;
    notifyListeners();
  }

  Future<void> loginBiometric() async {
    final ok = await _authService.authenticateWithBiometrics();
    _authenticated = ok;
    notifyListeners();
  }
}
