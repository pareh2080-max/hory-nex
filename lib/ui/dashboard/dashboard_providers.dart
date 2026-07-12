import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class DashboardData {
  final int totalStudents;
  final int totalEncadreurs;
  final int presencesJour;
  final int paiementsJour;
  final double totalEncaisse;
  final double totalRestant;
  final double rapportHebdo;
  final double rapportMensuel;
  final int communes;
  final Map<String, double> encaisseParJour;

  const DashboardData({
    required this.totalStudents,
    required this.totalEncadreurs,
    required this.presencesJour,
    required this.paiementsJour,
    required this.totalEncaisse,
    required this.totalRestant,
    required this.rapportHebdo,
    required this.rapportMensuel,
    required this.communes,
    required this.encaisseParJour,
  });
}

/// Agrège toutes les statistiques du tableau de bord depuis SQLite.
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final students = ref.watch(studentRepoProvider);
  final encadreurs = ref.watch(encadreurRepoProvider);
  final payments = ref.watch(paymentRepoProvider);
  final attendance = ref.watch(attendanceRepoProvider);

  final now = DateTime.now();
  final debutSemaine = now.subtract(Duration(days: now.weekday - 1));
  final debutSemaineJour = DateTime(debutSemaine.year, debutSemaine.month, debutSemaine.day);
  final debutMois = DateTime(now.year, now.month, 1);

  return DashboardData(
    totalStudents: await students.count(),
    totalEncadreurs: await encadreurs.count(),
    presencesJour: await attendance.countPresentsJour(now),
    paiementsJour: await payments.countPaiementsJour(now),
    totalEncaisse: await payments.totalEncaisse(),
    totalRestant: await payments.totalRestant(),
    rapportHebdo: await payments.encaisseEntre(debutSemaineJour, now.add(const Duration(days: 1))),
    rapportMensuel: await payments.encaisseEntre(debutMois, now.add(const Duration(days: 1))),
    communes: await students.countCommunes(),
    encaisseParJour: await payments.encaisseParJour(7),
  );
});
