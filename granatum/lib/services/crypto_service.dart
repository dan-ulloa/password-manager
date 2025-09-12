import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import '../services/key_service.dart';

class CryptoService {
  final KeyService _keyService;

  CryptoService(this._keyService);

  /// Cifra texto plano con AES-GCM usando una subkey
  Future<String> encrypt(String plainText) async {
    final subkey = await _keyService.deriveSubkey(
      subkeyId: 1,
      subkeyLength: 32,
      context: "ENTRY_ENCRYPTION",
    );

    if (subkey == null) {
      throw Exception("No hay master key inicializada");
    }

    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(subkey);
    final nonce = algorithm.newNonce();

    final encrypted = await algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );

    // Guardamos ciphertext + nonce en Base64
    return base64Encode(nonce + encrypted.cipherText + encrypted.mac.bytes);
  }

  /// Descifra texto cifrado en Base64
  Future<String> decrypt(String encryptedBase64) async {
    final subkey = await _keyService.deriveSubkey(
      subkeyId: 1,
      subkeyLength: 32,
      context: "ENTRY_ENCRYPTION",
    );

    if (subkey == null) {
      throw Exception("No hay master key inicializada");
    }

    final raw = base64Decode(encryptedBase64);
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(subkey);

    final nonce = raw.sublist(0, 12);
    final cipherText = raw.sublist(12, raw.length - 16);
    final macBytes = raw.sublist(raw.length - 16);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(decrypted);
  }
}
