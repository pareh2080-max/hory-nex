import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/payment.dart';
import '../../models/student.dart';
import '../../providers.dart';
import '../../repositories/payment_repository.dart';
import '../../services/pdf_receipt_service.dart';
import '../payments/add_payment_dialog.dart';
import '../receipts/receipt_actions.dart';
import 'student_form_screen.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  Student? _student;
  StudentBalance? _balance;
  List<Payment> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sRepo = ref.read(studentRepoProvider);
    final pRepo = ref.read(paymentRepoProvider);
    final student = await sRepo.byId(widget.studentId);
    if (student == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final balance = await pRepo.balance(student);
    final payments = await pRepo.byStudent(student.id);
    if (!mounted) return;
    setState(() {
      _student = student;
      _balance = balance;
      _payments = payments;
      _loading = false;
    });
  }

  Future<void> _addPayment() async {
    final user = ref.read(authProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AddPaymentDialog(
        student: _student!,
        soldeRestant: _balance!.solde,
        caissier: user?.fullName ?? 'Caissier',
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _generateReceipt(Payment payment) async {
    final user = ref.read(authProvider);
    final file = await PdfReceiptService.generate(
      student: _student!,
      payment: payment,
      totalPaye: _balance!.totalPaye,
      caissier: user?.fullName ?? 'Caissier',
    );
    if (!mounted) return;
    showReceiptActions(context, file, _student!, payment);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = _student!;
    final b = _balance!;
    final qrData = PdfReceiptService.qrPayload(
      student: s,
      solde: b.solde,
      statut: b.status.label,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(s.nomComplet),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => StudentFormScreen(student: s)),
              );
              if (saved == true) _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPayment,
        icon: const Icon(Icons.add_card),
        label: const Text('Paiement'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          _balanceCard(b),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _info('Matricule', s.matricule),
                _info('Sexe', s.sexe),
                _info('Naissance', s.dateNaissance),
                _info('Téléphone', s.telephone),
                _info('WhatsApp', s.whatsapp),
                _info('Email', s.email),
                _info('Adresse', s.adresse),
                _info('Département', s.departement),
                _info('Commune', s.commune),
                _info('Axe', s.axe),
                _info('Filière', s.filiere),
                _info('École précédente', s.ecolePrecedente),
                _info('Parent', s.nomParent),
                _info('Tél. parent', s.telParent),
                _info('Inscription', Formatters.date(s.dateInscription)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Text('QR Code étudiant',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Center(
                  child: QrImageView(
                    data: qrData,
                    size: 170,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Scanner pour voir nom, matricule, paiement & statut',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.grisMoyen)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Historique des paiements',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun paiement enregistré.'),
            )
          else
            ..._payments.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt, color: AppColors.vert),
                    title: Text(Formatters.money(p.montant)),
                    subtitle: Text(
                        '${p.recuNumero} · ${p.mode.label}\n${Formatters.dateTime(p.datePaiement)}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: AppColors.danger),
                      tooltip: 'Reçu PDF',
                      onPressed: () => _generateReceipt(p),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _balanceCard(StudentBalance b) {
    final color = b.status == PaymentStatus.paye
        ? AppColors.paye
        : b.status == PaymentStatus.partiel
            ? AppColors.partiel
            : AppColors.impaye;
    return Card(
      color: AppColors.bleuFonce,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Situation financière',
                    style: TextStyle(color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(20)),
                  child: Text(b.status.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _money('Montant PREPAC', b.montantPrepac, Colors.white),
                _money('Payé', b.totalPaye, AppColors.vertClair),
                _money('Solde', b.solde, AppColors.avertissement),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _money(String label, double value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 2),
          Text(Formatters.money(value),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      );

  Widget _info(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(color: AppColors.grisMoyen, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }
}
