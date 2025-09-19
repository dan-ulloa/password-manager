import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../services/key_service.dart';

class DatabaseProvider {
  Database? _db;
  final KeyService _keyService;
  final String dbName = "vault.db";

  DatabaseProvider(this._keyService);

  Future<Database> get database async {
    if (_db != null) return _db!;
    return await initDB();
  }

  Future<Database> initDB() async {
    // Limpia el secure storage si la DB no existe
    validateStorage();

    final dbPath = join(await getDatabasesPath(), dbName);

    // Generar subkey para la DB a partir de la Master Key
    final dbKey = await _keyService.deriveSubkey(
      subkeyId: 99,
      subkeyLength: 32,
      context: "DB_ENCRYPTION",
    );

    if (dbKey == null) {
      throw Exception("Master key no inicializada. Autorización requerida");
    }

    return await openDatabase(
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

  Future<void> validateStorage() async {
    final databaseExists = await dbExists();
    final saltExists = await _keyService.saltExists();

    if (databaseExists && !saltExists || !databaseExists && saltExists) {
      // “No se detectó la bóveda, se requiere registro inicial”.
      // “Bóveda corrupta o sin inicializar, se requiere registro de nuevo”.
      // la DB ya no existe pero la llave sí.
      // "Inconsistencia detectada: eliminando master key..."
      await _keyService.reset();
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de metadatos
    await db.execute('''
      CREATE TABLE vault_metadata (
        id INTEGER PRIMARY KEY,
        salt BLOB NOT NULL,
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
}
