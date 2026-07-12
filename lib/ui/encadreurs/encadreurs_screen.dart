import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/encadreur.dart';
import '../../providers.dart';
import 'encadreur_form_screen.dart';

class EncadreursScreen extends ConsumerStatefulWidget {
  const EncadreursScreen({super.key});

  @override
  ConsumerState<EncadreursScreen> createState() => _EncadreursScreenState();
}

class _EncadreursScreenState extends ConsumerState<EncadreursScreen> {
  List<Encadreur> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ref.read(encadreurRepoProvider).all();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _openForm([Encadreur? e]) async {
    final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => EncadreurFormScreen(encadreur: e)));
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encadreurs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Aucun encadreur.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final e = _items[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.bleuFonce.withOpacity(.12),
                          child: Text(
                              e.prenom.isNotEmpty ? e.prenom[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: AppColors.bleuFonce,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(e.nomComplet,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${e.specialite ?? e.matiere ?? "—"} · ${e.statut ?? ""}'),
                        trailing: Text(e.matricule,
                            style: const TextStyle(fontSize: 11)),
                        onTap: () => _openForm(e),
                      ),
                    );
                  },
                ),
    );
  }
}
