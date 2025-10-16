import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../repositories/password_repository.dart';
import '../services/crypto_service.dart';

class VaultProvider extends ChangeNotifier {
  late PasswordRepository _repo;
  late CryptoService _cryptoService;

  // Lista de entradas
  List<PasswordEntry> _entries = [];
  List<PasswordEntry> get entries => _entries;

  // Estado de carga
  bool _loading = false;
  bool get loading => _loading;

  // Contraseña revelada actualmente
  String? _revealedPassword;
  String? get revealedPassword => _revealedPassword;

  int? _revealedId;
  int? get revealedId => _revealedId;

  String? error;

  // Inyección de dependencias
  void setDependencies(PasswordRepository repo, CryptoService crypto) {
    _repo = repo;
    _cryptoService = crypto;
  }

  Future<void> loadEntries() async {
    _loading = true;
    notifyListeners();

    try {
      _entries = await _repo.getEntries();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(String title, String username, String password) async {
    final encryptedPassword = await _cryptoService.encrypt(password);
    final entry = PasswordEntry(
      title: title,
      username: username,
      password: encryptedPassword,
    );

    await _repo.addEntry(entry);
    _entries.add(entry);
    notifyListeners();
  }

  Future<void> updateEntry(
    PasswordEntry entry, {
    String? title,
    String? username,
    String? password,
  }) async {
    final updatedEntry = PasswordEntry(
      id: entry.id,
      title: title ?? entry.title,
      username: username ?? entry.username,
      password: password != null
          ? await _cryptoService.encrypt(password)
          : entry.password,
    );

    //await _repo.updateEntry(updatedEntry);

    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) _entries[index] = updatedEntry;
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    await _repo.deleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> revealPassword(int id) async {
    // Ocultar cualquier contraseña revelada previamente
    _revealedPassword = null;
    _revealedId = null;
    notifyListeners();

    final entry = await _repo.getEntryById(id);
    final plain = await _cryptoService.decrypt(entry.password);

    _revealedPassword = plain;
    _revealedId = id;
    notifyListeners();
  }

  /// Revelar una contraseña (solo una a la vez)
  Future<void> revealPassword2(Uint8List masterKey, int id) async {
    // Si ya hay otra revelada, la ocultamos
    _revealedPassword = null;
    _revealedId = null;
    notifyListeners();

    try {
      // Buscamos la entrada
      final entry = await _repo!.getEntryById(id);
      final plain = await _cryptoService.decrypt(entry.password);

      _revealedPassword = plain;
      _revealedId = id;
      notifyListeners();

      // Auto-ocultar después de 10s
      Future.delayed(const Duration(seconds: 10), () {
        if (_revealedId == id) {
          _revealedPassword = null;
          _revealedId = null;
          notifyListeners();
        }
      });
    } catch (e) {
      _revealedPassword = null;
      _revealedId = null;
      notifyListeners();

      debugPrint('Error al revelar contraseña: $e');
    }
  }

  /// Ocultar manualmente
  void hidePassword() {
    _revealedPassword = null;
    _revealedId = null;
    notifyListeners();
  }
}
