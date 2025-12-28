import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  Uint8List? _entrySubkey;

  void setEntrySubkey(Uint8List subkey) {
    _entrySubkey = subkey;
  }

  /// Cifra texto plano con AES-GCM usando una subkey
  Future<Uint8List> encrypt(String plainText) async {
    final subkey = _entrySubkey;
    if (subkey == null) throw Exception('Subkey no inicializada');

    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(subkey);
    final nonce = algorithm.newNonce();

    final encrypted = await algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );

    // Construimos el paquete: [nonce | ciphertext | mac]
    return Uint8List.fromList(
      nonce + encrypted.cipherText + encrypted.mac.bytes,
    );
  }

  /// Descifra texto cifrado en Base64
  Future<String> decrypt(Uint8List encryptedBlob) async {
    final subkey = _entrySubkey;
    if (subkey == null) throw Exception('Subkey no inicializada');

    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(subkey);

    // Separar nonce, ciphertext y mac
    final nonceLength = algorithm.nonceLength;
    final macLength = 16; // AES-GCM usa 16 bytes por defecto

    final nonce = encryptedBlob.sublist(0, nonceLength);
    final cipherText = encryptedBlob.sublist(
      nonceLength,
      encryptedBlob.length - macLength,
    );
    final mac = Mac(encryptedBlob.sublist(encryptedBlob.length - macLength));

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);

    final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(decrypted);
  }

  void clearKeys() {
    _entrySubkey = null;
  }
}
