import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'key_service.dart';
import 'package:collection/collection.dart';

class AuthService {
  final KeyService _keyService = KeyService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> register(String masterPassword) async {
    try {
      final masterKey = await _keyService.deriveMasterKey(masterPassword);
      return masterKey.isNotEmpty;
    } catch (e) {
      print("Error register: $e");
      return false;
    }
  }

  Future<bool> login(String masterPassword) async {
    try {
      final storedKey = await _keyService.getMasterKey();
      final derivedKey = await _keyService.deriveMasterKey(masterPassword);
      if (storedKey == null) return false;
      
      return const ListEquality().equals(derivedKey, storedKey);
    } catch (e) {
      print("Error login: $e");
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Accede con tu biometría',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print("Biometric auth error: $e");
      return false;
    }
  }
  
  Future<void> logout() async {
    await _keyService.reset();
  }
}
