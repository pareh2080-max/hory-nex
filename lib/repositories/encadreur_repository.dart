import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/db/database_helper.dart';
import '../models/encadreur.dart';

class EncadreurRepository {
  final _uuid = const Uuid();
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<String> _nextMatricule() async {
    final db = await _db;
    final year = DateTime.now().year;
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM encadreurs WHERE matricule LIKE ?",
      ['ENC-$year-%'],
    );
    final count = (rows.first['c'] as int) + 1;
    return 'ENC-$year-${count.toString().padLeft(4, '0')}';
  }

  Future<Encadreur> create(Encadreur draft) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final e = Encadreur(
      id: _uuid.v4(),
      matricule: draft.matricule.isEmpty ? await _nextMatricule() : draft.matricule,
      photoPath: draft.photoPath,
      nom: draft.nom,
      prenom: draft.prenom,
      telephone: draft.telephone,
      whatsapp: draft.whatsapp,
      adresse: draft.adresse,
      email: draft.email,
      specialite: draft.specialite,
      matiere: draft.matiere,
      axe: draft.axe,
      dateEmbauche: draft.dateEmbauche,
      disponibilite: draft.disponibilite,
      statut: draft.statut ?? 'Actif',
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('encadreurs', e.toMap());
    return e;
  }

  Future<void> update(Encadreur e) async {
    final db = await _db;
    final map = e.toMap()..['updated_at'] = DateTime.now().toIso8601String();
    await db.update('encadreurs', map, where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('encadreurs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Encadreur>> all({String query = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'encadreurs',
      where: query.trim().isEmpty ? null : '(nom LIKE ? OR prenom LIKE ? OR specialite LIKE ?)',
      whereArgs: query.trim().isEmpty
          ? null
          : ['%$query%', '%$query%', '%$query%'],
      orderBy: 'nom ASC',
    );
    return rows.map(Encadreur.fromMap).toList();
  }

  Future<Encadreur?> byId(String id) async {
    final db = await _db;
    final rows = await db.query('encadreurs', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Encadreur.fromMap(rows.first);
  }

  Future<int> count() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM encadreurs');
    return rows.first['c'] as int;
  }
}
