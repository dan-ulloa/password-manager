import 'dart:typed_data';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyService {
  Future<Uint8List> deriveMasterKey(
    String masterPassword,
    Uint8List salt,
  ) async {
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
    final masterKeyBytes = await secretKey.extractBytes();

    // Hash de la masterKey para comparar
    final algorithm = Sha256();
    final masterKeyHash = await algorithm.hash(masterKeyBytes);

    return Uint8List.fromList(masterKeyHash.bytes);
  }

  //return Uint8List.fromList(base64Decode(keyBase64));

  Future<Uint8List?> deriveSubkey({
    required int subkeyId,
    required int subkeyLength,
    required String context,
    required Uint8List masterKey,
  }) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: subkeyLength);
    final secretKey = await hkdf.deriveKey(
      secretKey: SecretKey(masterKey),
      nonce: Uint8List.fromList(context.codeUnits + [subkeyId]),
    );

    return Uint8List.fromList(await secretKey.extractBytes());
  }
}
