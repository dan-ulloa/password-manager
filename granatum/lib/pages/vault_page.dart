import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../models/password_entry.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _titleCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Se ejecuta después de que el widget se haya renderizado
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VaultProvider>();
      if (provider.entries.isEmpty && !provider.loading) {
        provider.loadEntries();
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddDialog(VaultProvider provider) async {
    _titleCtrl.clear();
    _userCtrl.clear();
    _passCtrl.clear();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva entrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleCtrl.text.trim();
              final user = _userCtrl.text.trim();
              final pass = _passCtrl.text;
              if (title.isEmpty || user.isEmpty || pass.isEmpty) return;
              Navigator.pop(context);
              await provider.addEntry(title, user, pass);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bóveda'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.loadEntries,
                tooltip: 'Refrescar',
              ),
            ],
          ),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.entries.isEmpty
              ? const Center(child: Text('No hay entradas aún.'))
              : ListView.builder(
                  itemCount: provider.entries.length,
                  itemBuilder: (_, i) {
                    final PasswordEntry entry = provider.entries[i];
                    final isRevealed = provider.revealedId == entry.id;

                    return ListTile(
                      title: Text(entry.title),
                      subtitle: Text(
                        isRevealed ? provider.revealedPassword! : "********",
                        style: const TextStyle(fontSize: 16),
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isRevealed
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              if (isRevealed) {
                                provider.hidePassword();
                              } else {
                                provider.revealPassword(entry.id!);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _confirmDelete(context, provider, entry.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(provider),
            child: const Icon(Icons.add),
            tooltip: 'Agregar entrada',
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, VaultProvider provider, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Eliminar esta entrada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteEntry(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
