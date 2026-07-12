import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../models/schedule_item.dart';
import '../../providers.dart';

const _types = {
  'cours': ('Cours', AppColors.bleuFonce),
  'examen': ('Examen', AppColors.danger),
  'reunion': ('Réunion', AppColors.info),
  'paiement': ('Paiement', AppColors.vert),
  'vacances': ('Vacances', AppColors.avertissement),
  'rappel': ('Rappel', AppColors.grisFonce),
};

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
    _load();
  }

  Future<void> _load() async {
    final events = await ref.read(calendarRepoProvider).all();
    if (!mounted) return;
    setState(() => _events = events);
  }

  List<CalendarEvent> _forDay(DateTime day) {
    return _events.where((e) {
      final d = DateTime.tryParse(e.date);
      return d != null && isSameDay(d, day);
    }).toList();
  }

  Future<void> _addEvent() async {
    final titre = TextEditingController();
    String type = 'cours';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text('Événement · ${_selected!.day}/${_selected!.month}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titre, decoration: const InputDecoration(labelText: 'Titre *')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _types.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value.$1)))
                  .toList(),
              onChanged: (v) => setLocal(() => type = v ?? 'cours'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajouter')),
          ],
        ),
      ),
    );
    if (ok == true && titre.text.trim().isNotEmpty) {
      await ref.read(calendarRepoProvider).create(
          titre: titre.text.trim(), type: type, date: _selected!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _forDay(_selected ?? _focused);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.event),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar<CalendarEvent>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2035),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(_selected, d),
              eventLoader: _forDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (sel, foc) => setState(() {
                _selected = sel;
                _focused = foc;
              }),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: AppColors.vertClair, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: AppColors.bleuFonce, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(
                    color: AppColors.vert, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
          ),
          Expanded(
            child: dayEvents.isEmpty
                ? const Center(child: Text('Aucun événement ce jour.'))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: dayEvents.map((e) {
                      final meta = _types[e.type] ?? ('Autre', AppColors.grisFonce);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: meta.$2, radius: 8),
                          title: Text(e.titre),
                          subtitle: Text(meta.$1),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref.read(calendarRepoProvider).delete(e.id);
                              _load();
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
