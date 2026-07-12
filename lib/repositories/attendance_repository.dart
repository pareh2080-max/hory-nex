import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/db/database_helper.dart';
import '../models/attendance.dart';

class AttendanceStats {
  final int present;
  final int absent;
  final int retard;
  int get total => present + absent + retard;
  const AttendanceStats(this.present, this.absent, this.retard);
}

class AttendanceRepository {
  final _uuid = const Uuid();
  Future<Database> get _db async => DatabaseHelper.instance.database;

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Enregistre ou met à jour la présence d'un étudiant pour une date.
  Future<void> mark({
    required String studentId,
    required DateTime date,
    required AttendanceStatus statut,
    bool justifie = false,
    String? heure,
    String? signature,
    String? note,
  }) async {
    final db = await _db;
    final key = dateKey(date);
    final existing = await db.query('attendance',
        where: 'student_id = ? AND date = ?', whereArgs: [studentId, key], limit: 1);
    final record = Attendance(
      id: existing.isEmpty ? _uuid.v4() : existing.first['id'] as String,
      studentId: studentId,
      date: key,
      heure: heure,
      statut: statut,
      justifie: justifie,
      signature: signature,
      note: note,
      createdAt: DateTime.now().toIso8601String(),
    );
    if (existing.isEmpty) {
      await db.insert('attendance', record.toMap());
    } else {
      await db.update('attendance', record.toMap(),
          where: 'id = ?', whereArgs: [record.id]);
    }
  }

  Future<List<Attendance>> forDate(DateTime date) async {
    final db = await _db;
    final rows = await db.query('attendance',
        where: 'date = ?', whereArgs: [dateKey(date)]);
    return rows.map(Attendance.fromMap).toList();
  }

  Future<AttendanceStats> statsForDate(DateTime date) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT statut, COUNT(*) AS c FROM attendance WHERE date = ? GROUP BY statut',
      [dateKey(date)],
    );
    int p = 0, a = 0, r = 0;
    for (final row in rows) {
      final s = row['statut'] as String;
      final c = row['c'] as int;
      if (s == AttendanceStatus.present.name) p = c;
      if (s == AttendanceStatus.absent.name) a = c;
      if (s == AttendanceStatus.retard.name) r = c;
    }
    return AttendanceStats(p, a, r);
  }

  Future<int> countPresentsJour(DateTime date) async {
    final stats = await statsForDate(date);
    return stats.present;
  }
}
