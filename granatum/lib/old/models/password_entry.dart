import 'dart:typed_data';

class PasswordEntry {
  int? id;
  final String title;
  final String username;
  final Uint8List password;

  PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.password
  });

  // Factory para convertir de Map (BD) a objeto
  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as Uint8List,
    );
  }

  // Convertir de objeto a Map para insertar en BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password
    };
  }
}
