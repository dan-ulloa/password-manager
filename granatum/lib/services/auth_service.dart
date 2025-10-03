import 'dart:convert';

import 'package:cryptography/helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'key_service.dart';
import 'package:collection/collection.dart';

class AuthService {
  final KeyService _keyService = KeyService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _saltId = 'vault_salt';
  static const _masterKeyHashId = 'vault_masterkey_hash';

  Future<bool> register(String masterPassword) async {
    try {
      Uint8List salt = Uint8List.fromList(randomBytes(16));

      final masterKey = await _keyService.deriveMasterKey(masterPassword, salt);
      await _storage.write(key: _saltId, value: base64Encode(salt));

      return masterKey.isNotEmpty;
    } catch (e) {
      print("Error register: $e");
      return false;
    }
  }

  Future<bool> login(String masterPassword) async {
    try {
      String? saltBase64 = await _storage.read(key: _saltId);
      String? masterKeyBase64 = await _storage.read(key: _masterKeyHashId);

      if ((saltBase64?.isEmpty ?? false) || (masterKeyBase64?.isEmpty ?? false))
        throw Exception("No existe registro de la llave maestra");

      Uint8List salt = Uint8List.fromList(base64Decode(saltBase64!));
      Uint8List masterKeyHash = Uint8List.fromList(
        base64Decode(masterKeyBase64!),
      );

      final masterKeyResult = await _keyService.deriveMasterKey(
        masterPassword,
        salt,
      );
      return const ListEquality().equals(masterKeyResult, masterKeyHash);
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

  /*
  Future<void> logout() async {
    await _keyService.reset();
  }
  */
}
