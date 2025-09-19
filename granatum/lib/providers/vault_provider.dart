import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../repositories/password_repository.dart';
import '../services/crypto_service.dart';

class VaultProvider extends ChangeNotifier {
  late PasswordRepository? _repo;
  late CryptoService _cryptoService;

  // Estado público
  List<PasswordEntry> entries = [];
  bool loading = false;
  String? error;
  
  String? _revealedPassword;
  int? _revealedId;

  String? get revealedPassword => _revealedPassword;
  int? get revealedId => _revealedId;

  VaultProvider();

  void setDependencies(PasswordRepository repo, CryptoService cryptoService) {
    _cryptoService = cryptoService;
    
    // Solo inicializar una vez para evitar recargas innecesarias
    final firstSet = _repo == null;
    _repo = repo;
    if (firstSet) {
      loadEntries();
    }
  }

  Future<void> loadEntries() async {
    if (_repo == null) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      entries = await _repo!.getEntries();
    } catch (e) {
      error = 'Error cargando entradas: $e';
      entries = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry({
    required String title,
    required String username,
    required String password,
  }) async {
    if (_repo == null) throw Exception('Repositorio no inicializado');

    final encrypted = await _cryptoService.encrypt(password);

    final newEntry = PasswordEntry(
      title: title,
      username: username,
      password: encrypted,
    );

    loading = true;
    notifyListeners();

    try {
      await _repo!.addEntry(newEntry);
      await loadEntries();
    } catch (e) {
      error = 'Error guardando entrada: $e';
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(int id) async {
    if (_repo == null) return;
    loading = true;
    notifyListeners();
    try {
      await _repo!.deleteEntry(id);
      entries.removeWhere((e) => e.id == id);
    } catch (e) {
      error = 'Error eliminando entrada: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Revelar una contraseña (solo una a la vez)
  Future<void> revealPassword(int id) async {
    // Si ya hay otra revelada, la ocultamos
    _revealedPassword = null;
    _revealedId = null;
    notifyListeners();
    
    try{
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

      error = 'Error al revelar contraseña: $e';
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
