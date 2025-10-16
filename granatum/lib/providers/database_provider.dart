import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseProvider {
  Database? _db;
  final String dbName = "vault.db";

  Database get database {
    if (_db == null) throw Exception('DB no inicializada. Login requerido.');
    return _db!;
  }

  Future<void> initDB(Uint8List dbKey) async {
    final dbPath = join(await getDatabasesPath(), dbName);

    _db = await openDatabase(
      dbPath,
      password: base64Encode(dbKey), // clave en base64 como passphrase
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<bool> dbExists() async {
    final dbPath = join(await getDatabasesPath(), dbName);
    final dbFile = File(dbPath);

    return await dbFile.exists();
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de metadatos
    await db.execute('''
      CREATE TABLE vault_metadata (
        id INTEGER PRIMARY KEY,
        salt BLOB NOT NULL,
        masterKeyHash BLOB NOT NULL, 
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Crear tabla de contraseñas
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password BLOB NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ejecutar migraciones si agregas nuevas tablas o columnas
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
