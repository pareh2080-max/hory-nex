import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_user.dart';
import '../../providers.dart';
import '../attendance/attendance_screen.dart';
import '../calendar/calendar_screen.dart';
import '../drive/drive_screen.dart';
import '../encadreurs/encadreurs_screen.dart';
import '../filieres/filieres_screen.dart';
import '../receipts/receipts_screen.dart';
import '../reports/reports_screen.dart';
import '../schedule/schedule_screen.dart';
import '../settings/settings_screen.dart';
import '../students/students_screen.dart';
import '../payments/payments_screen.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HORY.NEX'),
        actions: [
          IconButton(
            tooltip: 'Basculer thème',
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (d) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text('Bonjour, ${user?.fullName ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(user?.role.label ?? '',
                  style: TextStyle(color: AppColors.grisMoyen)),
              const SizedBox(height: 16),
              _statsGrid(context, d),
              const SizedBox(height: 20),
              _rapportsRow(context, d),
              const SizedBox(height: 20),
              _chartCard(context, d),
              const SizedBox(height: 24),
              Text('Menu principal',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _moduleGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsGrid(BuildContext context, DashboardData d) {
    final items = [
      _Stat('Étudiants', '${d.totalStudents}', Icons.school, AppColors.bleuFonce),
      _Stat('Encadreurs', '${d.totalEncadreurs}', Icons.badge, AppColors.bleuFonceClair),
      _Stat('Présences du jour', '${d.presencesJour}', Icons.how_to_reg, AppColors.vert),
      _Stat('Paiements du jour', '${d.paiementsJour}', Icons.receipt_long, AppColors.vertClair),
      _Stat('Total encaissé', Formatters.money(d.totalEncaisse), Icons.savings, AppColors.vert),
      _Stat('Reste à payer', Formatters.money(d.totalRestant), Icons.account_balance_wallet, AppColors.avertissement),
      _Stat('Communes', '${d.communes}', Icons.location_city, AppColors.info),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: items.map((s) => _statCard(context, s)).toList(),
    );
  }

  Widget _statCard(BuildContext context, _Stat s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: s.color.withOpacity(.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(s.icon, color: s.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(s.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(s.label,
                style: TextStyle(color: AppColors.grisMoyen, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _rapportsRow(BuildContext context, DashboardData d) {
    return Row(
      children: [
        Expanded(
          child: _miniReport(context, 'Rapport hebdomadaire',
              Formatters.money(d.rapportHebdo), Icons.calendar_view_week),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniReport(context, 'Rapport mensuel',
              Formatters.money(d.rapportMensuel), Icons.calendar_month),
        ),
      ],
    );
  }

  Widget _miniReport(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: AppColors.bleuFonce,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.vertClair),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(BuildContext context, DashboardData d) {
    final entries = d.encaisseParJour.entries.toList();
    final maxY = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encaissements (7 derniers jours)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: (maxY == 0 ? 100 : maxY) * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= entries.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(entries[i].key,
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (int i = 0; i < entries.length; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: entries[i].value,
                          width: 16,
                          color: AppColors.vert,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleGrid(BuildContext context) {
    final modules = <_Module>[
      _Module('Étudiants', Icons.school, const StudentsScreen()),
      _Module('Encadreurs', Icons.badge, const EncadreursScreen()),
      _Module('Filières', Icons.menu_book, const FilieresScreen()),
      _Module('Paiements', Icons.payments, const PaymentsScreen()),
      _Module('Présences', Icons.event_available, const AttendanceScreen()),
      _Module('Horaire', Icons.schedule, const ScheduleScreen()),
      _Module('Reçus', Icons.receipt_long, const ReceiptsScreen()),
      _Module('Rapports', Icons.picture_as_pdf, const ReportsScreen()),
      _Module('Calendrier', Icons.calendar_today, const CalendarScreen()),
      _Module('Sauvegarde Drive', Icons.cloud_upload, const DriveScreen()),
      _Module('Paramètres', Icons.settings, const SettingsScreen()),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: modules
          .map((m) => InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => m.screen)),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m.icon, size: 30, color: AppColors.bleuFonce),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(m.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _Stat(this.label, this.value, this.icon, this.color);
}

class _Module {
  final String label;
  final IconData icon;
  final Widget screen;
  _Module(this.label, this.icon, this.screen);
}
