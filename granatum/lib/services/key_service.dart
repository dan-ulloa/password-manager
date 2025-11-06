import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import "package:unorm_dart/unorm_dart.dart" as unorm;

class KeyService {
  /// Deriva la master key a partir de la contraseña del usuario y un salt único.
  /// - password: contraseña en texto plano ingresada por el usuario.
  /// - salt: valor aleatorio (16-32 bytes) guardado en SecureStorage.
  /// Devuelve una clave binaria de 32 bytes (Uint8List).
  Future<Uint8List> deriveMasterKey(
    String masterPassword,
    Uint8List salt,
  ) async {
    // minimum configuration
    final argon2id = Argon2id(
      parallelism: 1, // hilos de procesamiento
      memory: 19 * 1024, // 64 MB de RAM
      iterations: 2, // número de pasadas — más alto = más lento y más seguro
      hashLength: 32,
    );

    // Normalizar la clave
    final normalized = normalizePassword(masterPassword);

    // Derivar la clave desde la contraseña y el salt
    final secretKey = await argon2id.deriveKeyFromPassword(
      password: normalized,
      nonce: salt,
    );

    return Uint8List.fromList(await secretKey.extractBytes());
  }

  /// Deriva subclaves independientes (por ejemplo, para cifrar la BD o entradas).
  Future<Uint8List> deriveSubkey({
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

  /// Calcula un hash SHA-256 de la master key.
  /// Esto se usa como "verifier" para validar login sin guardar la master key.
  Future<Uint8List> hashMasterKey(Uint8List masterKey) async {
    // Hash de la masterKey para comparar
    final algorithm = Sha256();
    final hash = await algorithm.hash(masterKey);

    return Uint8List.fromList(hash.bytes);
  }

  String normalizePassword(String password) {
    final normalized = unorm.nfc(password);
    return normalized;
  }
}
