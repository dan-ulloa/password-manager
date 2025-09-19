import 'dart:typed_data';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _saltId = 'pwhash_salt';

  Future<bool> saltExists() async {
    String? saltBase64 = await _storage.read(key: _saltId);
    return saltBase64 != null && saltBase64.isNotEmpty;
  }

  Future<Uint8List> deriveMasterKey(String masterPassword) async {
    String? saltBase64 = await _storage.read(key: _saltId);
    late Uint8List salt;

    if (saltBase64 == null) {
      // randomBytes está basado en SecureRandom.safe → Random.secure().
      salt = Uint8List.fromList(randomBytes(16));
      await _storage.write(key: _saltId, value: base64Encode(salt));
    } else {
      salt = Uint8List.fromList(base64Decode(saltBase64));
    }

    // minimum configuration
    final argon2id = Argon2id(
      parallelism: 1,
      memory: 19 * 1024,
      iterations: 2,
      hashLength: 32,
    );

    final secretKey = await argon2id.deriveKeyFromPassword(
      password: masterPassword,
      nonce: salt,
    );

    final masterKey = await secretKey.extractBytes();
    //await _storage.write(key: _masterKeyId, value: base64Encode(masterKey));
    return Uint8List.fromList(masterKey);
  }

  Future<Uint8List?> getMasterKey() async {
    return null;
    /*
    final keyBase64 = await _storage.read(key: _masterKeyId);
    if (keyBase64 == null) return null;
    return Uint8List.fromList(base64Decode(keyBase64));
    */
  }

  Future<Uint8List?> deriveSubkey({
    required int subkeyId,
    required int subkeyLength,
    required String context,
  }) async {
    final masterKey = await getMasterKey();
    if (masterKey == null) return null;

    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: subkeyLength);
    final secretKey = await hkdf.deriveKey(
      secretKey: SecretKey(masterKey),
      nonce: Uint8List.fromList(context.codeUnits + [subkeyId]),
    );

    return Uint8List.fromList(await secretKey.extractBytes());
  }

  Future<void> reset() async {
    await _storage.delete(key: _saltId);
  }
}
