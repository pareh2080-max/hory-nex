import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/db/database_helper.dart';
import '../models/payment.dart';
import '../models/student.dart';

class StudentBalance {
  final double montantPrepac;
  final double totalPaye;
  double get solde => (montantPrepac - totalPaye).clamp(0, double.infinity);
  PaymentStatus get status {
    if (totalPaye <= 0) return PaymentStatus.impaye;
    if (totalPaye >= montantPrepac && montantPrepac > 0) return PaymentStatus.paye;
    return PaymentStatus.partiel;
  }

  const StudentBalance({required this.montantPrepac, required this.totalPaye});
}

class PaymentWithStudent {
  final Payment payment;
  final String studentNom;
  final String matricule;
  const PaymentWithStudent({
    required this.payment,
    required this.studentNom,
    required this.matricule,
  });
}

class PaymentRepository {
  final _uuid = const Uuid();
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<String> _nextRecuNumero() async {
    final db = await _db;
    final year = DateTime.now().year;
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM payments WHERE recu_numero LIKE ?",
      ['RC-$year-%'],
    );
    final count = (rows.first['c'] as int) + 1;
    return 'RC-$year-${count.toString().padLeft(6, '0')}';
  }

  Future<Payment> create({
    required String studentId,
    required double montant,
    required PaymentMode mode,
    String? reference,
    String? caissier,
    String? note,
    DateTime? date,
  }) async {
    final db = await _db;
    final now = DateTime.now();
    final payment = Payment(
      id: _uuid.v4(),
      studentId: studentId,
      recuNumero: await _nextRecuNumero(),
      montant: montant,
      mode: mode,
      reference: reference,
      datePaiement: (date ?? now).toIso8601String(),
      caissier: caissier,
      note: note,
      createdAt: now.toIso8601String(),
    );
    await db.insert('payments', payment.toMap());
    return payment;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Payment>> byStudent(String studentId) async {
    final db = await _db;
    final rows = await db.query('payments',
        where: 'student_id = ?', whereArgs: [studentId], orderBy: 'date_paiement DESC');
    return rows.map(Payment.fromMap).toList();
  }

  Future<Payment?> byId(String id) async {
    final db = await _db;
    final rows = await db.query('payments', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Payment.fromMap(rows.first);
  }

  Future<double> totalPayeStudent(String studentId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(montant),0) AS s FROM payments WHERE student_id = ?',
      [studentId],
    );
    return (rows.first['s'] as num).toDouble();
  }

  Future<StudentBalance> balance(Student student) async {
    final paye = await totalPayeStudent(student.id);
    return StudentBalance(montantPrepac: student.montantPrepac, totalPaye: paye);
  }

  /// Total encaissé (toute la période).
  Future<double> totalEncaisse() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COALESCE(SUM(montant),0) AS s FROM payments');
    return (rows.first['s'] as num).toDouble();
  }

  /// Total restant à payer = somme des montants PREPAC - total encaissé.
  Future<double> totalRestant() async {
    final db = await _db;
    final prepac = await db.rawQuery(
        'SELECT COALESCE(SUM(montant_prepac),0) AS s FROM students');
    final total = (prepac.first['s'] as num).toDouble();
    final encaisse = await totalEncaisse();
    return (total - encaisse).clamp(0, double.infinity);
  }

  Future<double> encaisseEntre(DateTime debut, DateTime fin) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(montant),0) AS s FROM payments '
      'WHERE date_paiement >= ? AND date_paiement < ?',
      [debut.toIso8601String(), fin.toIso8601String()],
    );
    return (rows.first['s'] as num).toDouble();
  }

  Future<double> encaisseJour(DateTime jour) {
    final debut = DateTime(jour.year, jour.month, jour.day);
    final fin = debut.add(const Duration(days: 1));
    return encaisseEntre(debut, fin);
  }

  Future<int> countPaiementsJour(DateTime jour) async {
    final db = await _db;
    final debut = DateTime(jour.year, jour.month, jour.day);
    final fin = debut.add(const Duration(days: 1));
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM payments WHERE date_paiement >= ? AND date_paiement < ?',
      [debut.toIso8601String(), fin.toIso8601String()],
    );
    return rows.first['c'] as int;
  }

  /// Paiements récents avec le nom de l'étudiant (pour la liste des paiements/reçus).
  Future<List<PaymentWithStudent>> recent({int limit = 100, String query = ''}) async {
    final db = await _db;
    final where = query.trim().isEmpty
        ? ''
        : "WHERE s.nom LIKE ? OR s.prenom LIKE ? OR p.recu_numero LIKE ?";
    final args = query.trim().isEmpty
        ? <Object?>[]
        : ['%$query%', '%$query%', '%$query%'];
    final rows = await db.rawQuery('''
      SELECT p.*, s.nom AS s_nom, s.prenom AS s_prenom, s.matricule AS s_matricule
      FROM payments p
      JOIN students s ON s.id = p.student_id
      $where
      ORDER BY p.date_paiement DESC
      LIMIT $limit
    ''', args);
    return rows
        .map((r) => PaymentWithStudent(
              payment: Payment.fromMap(r),
              studentNom: '${r['s_prenom']} ${r['s_nom']}',
              matricule: r['s_matricule'] as String,
            ))
        .toList();
  }

  /// Encaissements par jour sur N derniers jours (graphique).
  Future<Map<String, double>> encaisseParJour(int nbJours) async {
    final result = <String, double>{};
    final now = DateTime.now();
    for (int i = nbJours - 1; i >= 0; i--) {
      final jour = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = '${jour.day}/${jour.month}';
      result[key] = await encaisseJour(jour);
    }
    return result;
  }
}
