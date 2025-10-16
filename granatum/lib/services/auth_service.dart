import 'dart:convert';

import 'package:cryptography/helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:granatum/providers/database_provider.dart';
import 'package:granatum/services/crypto_service.dart';
import 'package:local_auth/local_auth.dart';
import 'key_service.dart';
import 'package:collection/collection.dart';

enum AuthInitState {
  firstRun, // No existe BD ni masterKey → mostrar Signup
  needsLogin, // Ya existe BD + masterKey → mostrar Login
  inconsistent, // BD o masterKey faltan → error / pedir reset
}

class AuthService {
  final KeyService _keyService;
  final DatabaseProvider _dbProvider;
  final CryptoService _cryptoService;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const _saltId = 'vault_salt';
  static const _verifierId = 'vault_verifier';

  AuthService(
    this._keyService,
    this._dbProvider,
    this._cryptoService,
    this._secureStorage,
  );

  Future<void> signup(String masterPassword) async {
    final salt = Uint8List.fromList(randomBytes(16));
    final masterKey = await _keyService.deriveMasterKey(masterPassword, salt);
    final verifier = await _keyService.hashMasterKey(masterKey);

    // Se guardan salt y el verifier
    await _secureStorage.write(key: _saltId, value: base64Encode(salt));
    await _secureStorage.write(key: _verifierId, value: base64Encode(verifier));

    // Generar subkey para la DB a partir de la Master Key
    final dbKey = await _keyService.deriveSubkey(
      subkeyId: 99,
      subkeyLength: 32,
      context: "DB_ENCRYPTION",
      masterKey: masterKey,
    );

    // crea la base de datos cifrada
    await _dbProvider.initDB(dbKey);
  }

  Future<void> login(String masterPassword) async {
    final saltB64 = await _secureStorage.read(key: _saltId);
    final verifierB64 = await _secureStorage.read(key: _verifierId);

    if (saltB64 == null || verifierB64 == null)
      throw Exception('Registro requerido');

    final salt = Uint8List.fromList(base64Decode(saltB64));
    final storedVerifier = Uint8List.fromList(base64Decode(verifierB64));

    final masterKey = await _keyService.deriveMasterKey(masterPassword, salt);
    final derivedVerifier = await _keyService.hashMasterKey(masterKey);

    if (!const ListEquality().equals(derivedVerifier, storedVerifier)) {
      throw Exception('Contraseña incorrecta');
    }

    // Generar subkey para la DB a partir de la Master Key
    final dbKey = await _keyService.deriveSubkey(
      subkeyId: 99,
      subkeyLength: 32,
      context: "DB_ENCRYPTION",
      masterKey: masterKey,
    );

    // abrir la base de datos cifrada
    await _dbProvider.initDB(dbKey);

    final entrySubkey = await _keyService.deriveSubkey(
      subkeyId: 1,
      subkeyLength: 32,
      context: "ENTRY_ENCRYPTION",
      masterKey: masterKey,
    );

    _cryptoService.setEntrySubkey(entrySubkey);
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
    await _dbProvider.close();
  }

  Future<AuthInitState> checkInitialState() async {
    final dbExists = await _dbProvider.dbExists();
    final storedSalt = await _secureStorage.read(key: _saltId);
    final storedVerifier = await _secureStorage.read(key: _verifierId);

    if (!dbExists && storedSalt == null && storedVerifier == null) {
      return AuthInitState.firstRun;
    }

    if (dbExists && storedSalt != null && storedVerifier != null) {
      return AuthInitState.needsLogin;
    }

    // Caso inconsistente: uno existe y el otro no.
    return AuthInitState.inconsistent;
  }
}
