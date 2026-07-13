import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  List<AppUser> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ref.read(userRepoProvider).all();
    if (!mounted) return;
    setState(() {
      _users = list;
      _loading = false;
    });
  }

  Future<void> _addUser() async {
    final username = TextEditingController();
    final fullName = TextEditingController();
    final password = TextEditingController();
    UserRole role = UserRole.caissier;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Nouvel utilisateur'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nom complet *')),
              const SizedBox(height: 8),
              TextField(controller: username, decoration: const InputDecoration(labelText: 'Identifiant *')),
              const SizedBox(height: 8),
              TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe *')),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setLocal(() => role = v ?? UserRole.caissier),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Créer')),
          ],
        ),
      ),
    );

    if (ok == true &&
        username.text.trim().isNotEmpty &&
        password.text.isNotEmpty &&
        fullName.text.trim().isNotEmpty) {
      await ref.read(userRepoProvider).createUser(
            username: username.text.trim(),
            fullName: fullName.text.trim(),
            role: role,
            password: password.text,
          );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs & rôles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: _users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final u = _users[i];
                return Card(
                  margin: EdgeInsets.zero,
                  child: SwitchListTile(
                    value: u.active,
                    onChanged: (v) async {
                      await ref.read(userRepoProvider).setActive(u.id, v);
                      _load();
                    },
                    title: Text(u.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${u.username} · ${u.role.label}'),
                    secondary: const Icon(Icons.person),
                  ),
                );
              },
            ),
    );
  }
}
