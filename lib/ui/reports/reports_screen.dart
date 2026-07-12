import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../providers.dart';
import '../../services/report_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _busy = false;

  Future<void> _run(Future<File> Function() task) async {
    setState(() => _busy = true);
    try {
      final file = await task();
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: 'Rapport HORY.NEX');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Généré : ${file.path.split(Platform.pathSeparator).last}')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapports')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Étudiants',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _tile('Rapport étudiants (PDF)', Icons.picture_as_pdf,
                  AppColors.danger, () async {
                final students = await ref.read(studentRepoProvider).search(limit: 5000);
                return ReportService.studentsPdf(students, periode: 'Complet');
              }),
              _tile('Export étudiants (Excel)', Icons.table_chart,
                  AppColors.vert, () async {
                final students = await ref.read(studentRepoProvider).search(limit: 5000);
                return ReportService.studentsExcel(students);
              }),
              _tile('Export étudiants (CSV)', Icons.description,
                  AppColors.info, () async {
                final students = await ref.read(studentRepoProvider).search(limit: 5000);
                return ReportService.studentsCsv(students);
              }),
              const SizedBox(height: 20),
              const Text('Paiements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _tile('Rapport paiements (PDF)', Icons.picture_as_pdf,
                  AppColors.danger, () async {
                final repo = ref.read(paymentRepoProvider);
                final payments = await repo.recent(limit: 5000);
                final total = await repo.totalEncaisse();
                return ReportService.paymentsPdf(payments,
                    periode: 'Complet', total: total);
              }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grisClair,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chaque rapport est enregistré dans le dossier de l\'application '
                  'puis proposé au partage (WhatsApp, Email, Fichiers...).',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          if (_busy)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _tile(String label, IconData icon, Color color, Future<File> Function() task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: const Icon(Icons.download),
        onTap: _busy ? null : () => _run(task),
      ),
    );
  }
}
