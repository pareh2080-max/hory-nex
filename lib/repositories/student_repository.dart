import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/db/database_helper.dart';
import '../models/student.dart';

class StudentRepository {
  final _uuid = const Uuid();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  /// Génère un matricule automatique : PRE-AAAA-000123
  Future<String> _nextMatricule() async {
    final db = await _db;
    final year = DateTime.now().year;
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM students WHERE matricule LIKE ?",
      ['PRE-$year-%'],
    );
    final count = (rows.first['c'] as int) + 1;
    return 'PRE-$year-${count.toString().padLeft(6, '0')}';
  }

  Future<Student> create(Student draft) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final student = Student(
      id: _uuid.v4(),
      matricule: draft.matricule.isEmpty ? await _nextMatricule() : draft.matricule,
      photoPath: draft.photoPath,
      nom: draft.nom,
      prenom: draft.prenom,
      sexe: draft.sexe,
      dateNaissance: draft.dateNaissance,
      nif: draft.nif,
      cin: draft.cin,
      telephone: draft.telephone,
      whatsapp: draft.whatsapp,
      email: draft.email,
      adresse: draft.adresse,
      departement: draft.departement,
      commune: draft.commune,
      sectionCommunale: draft.sectionCommunale,
      ecolePrecedente: draft.ecolePrecedente,
      anneeScolaire: draft.anneeScolaire,
      dateInscription: draft.dateInscription ?? now,
      nomParent: draft.nomParent,
      telParent: draft.telParent,
      professionParent: draft.professionParent,
      axe: draft.axe,
      filiere: draft.filiere,
      montantPrepac: draft.montantPrepac,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('students', student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return student;
  }

  Future<void> update(Student student) async {
    final db = await _db;
    final updated = student.copyWith(updatedAt: DateTime.now().toIso8601String());
    await db.update('students', updated.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<Student?> byId(String id) async {
    final db = await _db;
    final rows = await db.query('students', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  Future<Student?> byMatricule(String matricule) async {
    final db = await _db;
    final rows = await db.query('students',
        where: 'matricule = ?', whereArgs: [matricule], limit: 1);
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  /// Recherche instantanée + pagination (performant sur des milliers de fiches).
  Future<List<Student>> search({
    String query = '',
    String? departement,
    String? commune,
    String? axe,
    String? filiere,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add('(nom LIKE ? OR prenom LIKE ? OR matricule LIKE ? OR telephone LIKE ?)');
      args.addAll([q, q, q, q]);
    }
    if (departement != null) { where.add('departement = ?'); args.add(departement); }
    if (commune != null) { where.add('commune = ?'); args.add(commune); }
    if (axe != null) { where.add('axe = ?'); args.add(axe); }
    if (filiere != null) { where.add('filiere = ?'); args.add(filiere); }

    final rows = await db.query(
      'students',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'nom ASC, prenom ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<int> count() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM students');
    return rows.first['c'] as int;
  }

  Future<int> countCommunes() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COUNT(DISTINCT commune) AS c FROM students WHERE commune IS NOT NULL AND commune <> ""',
    );
    return rows.first['c'] as int;
  }

  /// Répartition par département (pour les graphiques).
  Future<Map<String, int>> repartitionParDepartement() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT departement, COUNT(*) AS c FROM students '
      'WHERE departement IS NOT NULL GROUP BY departement ORDER BY c DESC',
    );
    return {for (final r in rows) (r['departement'] as String): r['c'] as int};
  }

  Future<Map<String, int>> repartitionParAxe() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT axe, COUNT(*) AS c FROM students '
      'WHERE axe IS NOT NULL GROUP BY axe ORDER BY c DESC',
    );
    return {for (final r in rows) (r['axe'] as String): r['c'] as int};
  }
}
