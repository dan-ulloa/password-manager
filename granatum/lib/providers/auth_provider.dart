import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _authenticated = false;
  
  bool get authenticated => _authenticated;

  Future<void> login(String password) async {
    final ok = await _authService.login(password);
    _authenticated = ok;
    notifyListeners();
  }

  Future<void> loginBiometric() async {
    final ok = await _authService.authenticateWithBiometrics();
    _authenticated = ok;
    notifyListeners();
  }

  Future<void> register(String password) async {
    await _authService.register(password);
    _authenticated = true;
    notifyListeners();
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _authenticated = false;
    notifyListeners();
  }
}