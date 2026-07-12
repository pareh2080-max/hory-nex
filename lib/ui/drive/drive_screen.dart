import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../services/drive_service.dart';

class DriveScreen extends ConsumerStatefulWidget {
  const DriveScreen({super.key});

  @override
  ConsumerState<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends ConsumerState<DriveScreen> {
  final _drive = DriveService();
  bool _busy = false;
  String? _status;

  Future<void> _do(Future<String> Function() task) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final msg = await task();
      if (mounted) setState(() => _status = msg);
    } catch (e) {
      if (mounted) setState(() => _status = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde Google Drive')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.bleuFonce,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud, color: AppColors.vertClair, size: 40),
                  SizedBox(height: 12),
                  Text('Sauvegarde sécurisée',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'Sauvegardez toute la base (étudiants, paiements, présences, '
                    'horaires, encadreurs) sur votre Google Drive et restaurez-la '
                    'en cas de changement de téléphone.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : () => _do(_drive.backupDatabase),
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Synchroniser avec Google Drive'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _do(_drive.restoreDatabase),
            icon: const Icon(Icons.cloud_download),
            label: const Text('Restaurer depuis Google Drive'),
          ),
          const SizedBox(height: 24),
          if (_busy) const Center(child: CircularProgressIndicator()),
          if (_status != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _status!.startsWith('Erreur')
                    ? AppColors.danger.withOpacity(.1)
                    : AppColors.vert.withOpacity(.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_status!),
            ),
          const SizedBox(height: 24),
          const Text(
            'Note : la première utilisation nécessite la configuration OAuth '
            'Google (voir INSTALLATION.md). Sans cette configuration, la '
            'connexion Google échouera.',
            style: TextStyle(fontSize: 12, color: AppColors.grisMoyen),
          ),
        ],
      ),
    );
  }
}
