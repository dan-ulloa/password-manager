import 'dart:typed_data';

class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password; // cifrado con subkey
  final Uint8List iv;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.iv,
  });
}
