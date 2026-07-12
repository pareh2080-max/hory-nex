import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/utils/formatters.dart';
import '../models/payment.dart';
import '../models/student.dart';

/// Génère les reçus PDF officiels HORY.NEX (QR Code + code-barres inclus).
class PdfReceiptService {
  /// Construit le contenu QR encodé dans le reçu / la fiche étudiant.
  static String qrPayload({
    required Student student,
    Payment? payment,
    required double solde,
    required String statut,
  }) {
    final buf = StringBuffer()
      ..writeln('HORY.NEX')
      ..writeln('Nom: ${student.nomComplet}')
      ..writeln('Matricule: ${student.matricule}');
    if (payment != null) {
      buf.writeln('Recu: ${payment.recuNumero}');
      buf.writeln('Montant: ${payment.montant} HTG');
      buf.writeln('Date: ${Formatters.date(payment.datePaiement)}');
    }
    buf.writeln('Solde: $solde HTG');
    buf.writeln('Statut: $statut');
    return buf.toString();
  }

  static Future<File> generate({
    required Student student,
    required Payment payment,
    required double totalPaye,
    required String caissier,
  }) async {
    final doc = pw.Document();
    final solde =
        (student.montantPrepac - totalPaye).clamp(0, double.infinity).toDouble();
    final statut = solde <= 0 && student.montantPrepac > 0
        ? 'Payé'
        : (totalPaye > 0 ? 'Partiellement payé' : 'Non payé');

    final qr = qrPayload(
        student: student, payment: payment, solde: solde, statut: statut);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // En-tête / logo texte
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HORY.NEX',
                          style: pw.TextStyle(
                              fontSize: 26,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF0D2C54))),
                      pw.Text('Gestion PREPAC · Haïti',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF2E9E5B),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text('REÇU',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColor.fromInt(0xFF0D2C54)),
              pw.SizedBox(height: 8),
              _row('Numéro du reçu', payment.recuNumero),
              _row('Date', Formatters.dateTime(payment.datePaiement)),
              _row('Étudiant', student.nomComplet),
              _row('Matricule', student.matricule),
              _row('Filière', student.filiere ?? student.axe ?? '—'),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(children: [
                  _row('Mode de paiement', payment.mode.label),
                  if (payment.reference != null && payment.reference!.isNotEmpty)
                    _row('Référence', payment.reference!),
                  _bigRow('Montant payé', '${payment.montant.toStringAsFixed(2)} HTG'),
                  _row('Montant PREPAC',
                      '${student.montantPrepac.toStringAsFixed(2)} HTG'),
                  _bigRow('Solde restant', '${solde.toStringAsFixed(2)} HTG'),
                  _row('Statut', statut),
                ]),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qr,
                    width: 80,
                    height: 80,
                  ),
                  pw.Column(children: [
                    pw.Container(width: 130, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text('Caissier : $caissier',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Signature numérique',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey600)),
                  ]),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: payment.recuNumero,
                  width: 200,
                  height: 40,
                  drawText: true,
                ),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Merci de votre confiance — HORY.NEX',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey600)),
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final recusDir = Directory('${dir.path}/recus');
    if (!recusDir.existsSync()) recusDir.createSync(recursive: true);
    final file = File('${recusDir.path}/${payment.recuNumero}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(value,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  static pw.Widget _bigRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF0D2C54))),
          ],
        ),
      );
}
