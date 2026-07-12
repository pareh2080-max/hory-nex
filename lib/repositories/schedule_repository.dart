import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/db/database_helper.dart';
import '../models/schedule_item.dart';

class ScheduleRepository {
  final _uuid = const Uuid();
  Future<Database> get _db async => DatabaseHelper.instance.database;

  static const jours = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  Future<ScheduleItem> create(ScheduleItem draft) async {
    final db = await _db;
    final item = ScheduleItem(
      id: _uuid.v4(),
      jour: draft.jour,
      heureDebut: draft.heureDebut,
      heureFin: draft.heureFin,
      salle: draft.salle,
      cours: draft.cours,
      encadreurId: draft.encadreurId,
      filiere: draft.filiere,
      niveau: draft.niveau,
      ordre: draft.ordre,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('schedule', item.toMap());
    return item;
  }

  Future<void> update(ScheduleItem item) async {
    final db = await _db;
    await db.update('schedule', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  /// Déplacement glisser-déposer : change le jour et l'ordre.
  Future<void> move(String id, String nouveauJour, int nouvelOrdre) async {
    final db = await _db;
    await db.update('schedule',
        {'jour': nouveauJour, 'ordre': nouvelOrdre},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('schedule', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ScheduleItem>> all() async {
    final db = await _db;
    final rows = await db.query('schedule', orderBy: 'ordre ASC, heure_debut ASC');
    return rows.map(ScheduleItem.fromMap).toList();
  }

  Future<Map<String, List<ScheduleItem>>> parJour() async {
    final items = await all();
    final map = {for (final j in jours) j: <ScheduleItem>[]};
    for (final item in items) {
      map.putIfAbsent(item.jour, () => []).add(item);
    }
    return map;
  }
}

class CalendarRepository {
  final _uuid = const Uuid();
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<CalendarEvent> create({
    required String titre,
    required String type,
    required DateTime date,
    String? note,
  }) async {
    final db = await _db;
    final e = CalendarEvent(
      id: _uuid.v4(),
      titre: titre,
      type: type,
      date: date.toIso8601String(),
      note: note,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('calendar_events', e.toMap());
    return e;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('calendar_events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CalendarEvent>> all() async {
    final db = await _db;
    final rows = await db.query('calendar_events', orderBy: 'date ASC');
    return rows.map(CalendarEvent.fromMap).toList();
  }
}
