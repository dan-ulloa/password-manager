import 'dart:typed_data';

import 'package:granatum/providers/database_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';
import '../services/key_service.dart';
import '../services/crypto_service.dart';
import 'dart:convert';

class PasswordRepository {
  final DatabaseProvider _dbProvider;
  final CryptoService _cryptoService;

  PasswordRepository(this._dbProvider, this._cryptoService);
  
  Future<void> addEntry(PasswordEntry entry) async {
    final db = await _dbProvider.database;
    await db.insert('passwords', {
      'id': entry.id,
      'title': entry.title,
      'username': entry.username,
      'password': await _cryptoService.encrypt(entry.password),
    });
  }

  Future<List<PasswordEntry>> getEntries() async {
    final db = await _dbProvider.database;
    final result = await db.query('passwords');
    return result.map((e) => PasswordEntry(
      id: e['id'] as String,
      title: e['title'] as String,
      username: e['username'] as String,
      password: e['password'] as String,
      iv: e['iv'] as Uint8List,
    )).toList();
  }

  Future<void> deleteEntry(String id) async {
    final db = await _dbProvider.database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}
