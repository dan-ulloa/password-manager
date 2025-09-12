import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../repositories/password_repository.dart';

class VaultProvider extends ChangeNotifier {
  PasswordRepository? _repo;

  // Estado público
  List<PasswordEntry> entries = [];
  Map<String, bool> visibleMap = {}; // id -> mostrar/ocultar contraseña
  bool loading = false;
  String? error;

  VaultProvider();

  // Método usado por ChangeNotifierProxyProvider para inyectar repo
  void setRepository(PasswordRepository repo) {
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
      // Inicializar mapa de visibilidad
      visibleMap = { for (var e in entries) e.id : false };
    } catch (e) {
      error = 'Error cargando entradas: $e';
      entries = [];
      visibleMap = {};
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

    final newEntry = PasswordEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      username: username,
      password: password,
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

  Future<void> deleteEntry(String id) async {
    if (_repo == null) return;
    loading = true;
    notifyListeners();
    try {
      await _repo!.deleteEntry(id);
      entries.removeWhere((e) => e.id == id);
      visibleMap.remove(id);
    } catch (e) {
      error = 'Error eliminando entrada: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void toggleVisibility(String id) {
    visibleMap[id] = !(isVisible(id));
    notifyListeners();
  }

  

  bool isVisible(String id) => visibleMap[id] ?? false;
}
