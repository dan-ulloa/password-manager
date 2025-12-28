import 'dart:async';
import 'package:granatum/old/providers/database_provider.dart';
import '../models/password_entry.dart';

class PasswordRepository {
  final DatabaseProvider _dbProvider;

  PasswordRepository(this._dbProvider);

  Future<void> addEntry(PasswordEntry entry) async {
    final db = await _dbProvider.database;
    final id = await db.insert('passwords', entry.toMap());
    entry.id = id;
  }

  Future<List<PasswordEntry>> getEntries() async {
    final db = await _dbProvider.database;
    final result = await db.query('passwords');
    return result.map((e) => PasswordEntry.fromMap(e)).toList();
  }

  Future<PasswordEntry> getEntryById(int id) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('No se encontró la entrada con id $id');
    }

    return PasswordEntry.fromMap(result.first);
  }

  Future<void> deleteEntry(int id) async {
    final db = await _dbProvider.database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}
