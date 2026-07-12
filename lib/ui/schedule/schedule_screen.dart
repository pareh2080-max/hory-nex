import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/schedule_item.dart';
import '../../providers.dart';
import '../../repositories/schedule_repository.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  Map<String, List<ScheduleItem>> _byDay = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final byDay = await ref.read(scheduleRepoProvider).parJour();
    if (!mounted) return;
    setState(() {
      _byDay = byDay;
      _loading = false;
    });
  }

  Future<void> _moveTo(ScheduleItem item, String jour) async {
    if (item.jour == jour) return;
    await ref.read(scheduleRepoProvider).move(item.id, jour, item.ordre);
    _load();
  }

  Future<void> _addDialog() async {
    final cours = TextEditingController();
    final salle = TextEditingController();
    final debut = TextEditingController(text: '08:00');
    final fin = TextEditingController(text: '10:00');
    final niveau = TextEditingController();
    String jour = ScheduleRepository.jours.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Nouveau cours'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: cours, decoration: const InputDecoration(labelText: 'Cours *')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: jour,
                decoration: const InputDecoration(labelText: 'Jour'),
                items: ScheduleRepository.jours
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (v) => setLocal(() => jour = v ?? jour),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: debut, decoration: const InputDecoration(labelText: 'Début'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: fin, decoration: const InputDecoration(labelText: 'Fin'))),
              ]),
              const SizedBox(height: 8),
              TextField(controller: salle, decoration: const InputDecoration(labelText: 'Salle')),
              const SizedBox(height: 8),
              TextField(controller: niveau, decoration: const InputDecoration(labelText: 'Niveau / Filière')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajouter')),
          ],
        ),
      ),
    );

    if (ok == true && cours.text.trim().isNotEmpty) {
      await ref.read(scheduleRepoProvider).create(ScheduleItem(
            id: '',
            jour: jour,
            heureDebut: debut.text.trim(),
            heureFin: fin.text.trim(),
            salle: salle.text.trim(),
            cours: cours.text.trim(),
            filiere: niveau.text.trim(),
            createdAt: '',
          ));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horaire')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              children: ScheduleRepository.jours.map((jour) {
                final items = _byDay[jour] ?? [];
                return DragTarget<ScheduleItem>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (d) => _moveTo(d.data, jour),
                  builder: (context, candidate, __) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: candidate.isNotEmpty
                            ? AppColors.vert.withOpacity(.12)
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.grisMoyen.withOpacity(.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                            child: Text(jour,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.bleuFonce)),
                          ),
                          if (items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
                              child: Text('Glissez un cours ici',
                                  style: TextStyle(
                                      color: AppColors.grisMoyen, fontSize: 12)),
                            )
                          else
                            ...items.map((item) => LongPressDraggable<ScheduleItem>(
                                  data: item,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: _courseCard(item, dragging: true),
                                  ),
                                  childWhenDragging: Opacity(
                                      opacity: .4, child: _courseCard(item)),
                                  child: _courseCard(item),
                                )),
                          const SizedBox(height: 6),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget _courseCard(ScheduleItem item, {bool dragging = false}) {
    return Container(
      width: dragging ? 260 : null,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bleuFonce,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.book, color: AppColors.vertClair, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.cours,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(
                    '${item.heureDebut} - ${item.heureFin}${item.salle != null && item.salle!.isNotEmpty ? " · ${item.salle}" : ""}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
            onPressed: () async {
              await ref.read(scheduleRepoProvider).delete(item.id);
              _load();
            },
          ),
        ],
      ),
    );
  }
}
