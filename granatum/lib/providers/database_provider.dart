import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../services/key_service.dart';

class DatabaseProvider {
  Database? _db;
  final KeyService _keyService;

  DatabaseProvider(this._keyService);

  Future<Database> get database async {
    if (_db != null) return _db!;
    return await initDB();
  }


  Future<Database> initDB() async {
    // Generar subkey para la DB a partir de la Master Key
    final dbKey = await _keyService.deriveSubkey(
      subkeyId: 99,
      subkeyLength: 32,
      context: "DB_ENCRYPTION",
    );

    if (dbKey == null) {
      throw Exception("Master key no inicializada. Autorización requerida");
    }

    final path = join(await getDatabasesPath(), 'vault.db');
    
    return await openDatabase(
      path,
      password: base64Encode(dbKey), // clave en base64 como passphrase
      version: 1,
      onCreate: _onCreate,  
      onUpgrade: _onUpgrade
    );
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
        service TEXT NOT NULL,
        username TEXT NOT NULL,
        password BLOB NOT NULL,
        iv BLOB NOT NULL
      )
    ''');
  }

   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ejecutar migraciones si agregas nuevas tablas o columnas
  }
}