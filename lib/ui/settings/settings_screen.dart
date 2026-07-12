import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers.dart';
import '../widgets/hory_logo.dart';
import 'users_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final mode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.bleuFonce,
                child: Text(
                  (user?.fullName.isNotEmpty ?? false)
                      ? user!.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user?.fullName ?? ''),
              subtitle: Text(user?.role.label ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Apparence',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: mode,
                  title: const Text('Mode clair'),
                  secondary: const Icon(Icons.light_mode),
                  onChanged: (m) => ref.read(themeProvider.notifier).set(m!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: mode,
                  title: const Text('Mode sombre'),
                  secondary: const Icon(Icons.dark_mode),
                  onChanged: (m) => ref.read(themeProvider.notifier).set(m!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: mode,
                  title: const Text('Système'),
                  secondary: const Icon(Icons.settings_suggest),
                  onChanged: (m) => ref.read(themeProvider.notifier).set(m!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Sécurité', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Changer mon mot de passe'),
                  onTap: () => _changePassword(context, ref, user),
                ),
                if (user?.canManageUsers ?? false)
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Gérer les utilisateurs & rôles'),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UsersScreen())),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(child: HoryLogo(size: 64, showTagline: false)),
          const SizedBox(height: 8),
          const Center(
            child: Text('Version 1.0.0',
                style: TextStyle(color: AppColors.grisMoyen)),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(
      BuildContext context, WidgetRef ref, AppUser? user) async {
    if (user == null) return;
    final pass = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau mot de passe'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe')),
          const SizedBox(height: 8),
          TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Valider')),
        ],
      ),
    );
    if (ok == true &&
        pass.text.isNotEmpty &&
        pass.text == confirm.text) {
      await ref.read(userRepoProvider).changePassword(user.id, pass.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe modifié.')));
      }
    } else if (context.mounted && ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas.')));
    }
  }
}
