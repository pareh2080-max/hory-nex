import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/utils/formatters.dart';
import '../models/payment.dart';
import '../models/student.dart';
import '../repositories/payment_repository.dart';

/// Génère les rapports exportables (PDF / Excel / CSV).
class ReportService {
  static Future<Directory> _reportsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/rapports');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  static String _ts() =>
      DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');

  // -------------------- CSV --------------------
  static Future<File> studentsCsv(List<Student> students) async {
    final rows = <List<dynamic>>[
      ['Matricule', 'Prénom', 'Nom', 'Sexe', 'Téléphone', 'Département',
       'Commune', 'Axe', 'Filière', 'Montant PREPAC'],
      ...students.map((s) => [
            s.matricule, s.prenom, s.nom, s.sexe ?? '', s.telephone ?? '',
            s.departement ?? '', s.commune ?? '', s.axe ?? '', s.filiere ?? '',
            s.montantPrepac,
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await _reportsDir();
    final file = File('${dir.path}/etudiants_${_ts()}.csv');
    await file.writeAsString(csv);
    return file;
  }

  // -------------------- Excel --------------------
  static Future<File> studentsExcel(List<Student> students) async {
    final excel = xls.Excel.createExcel();
    final sheet = excel['Étudiants'];
    sheet.appendRow([
      'Matricule', 'Prénom', 'Nom', 'Sexe', 'Téléphone', 'Département',
      'Commune', 'Axe', 'Filière', 'Montant PREPAC'
    ].map((e) => xls.TextCellValue(e)).toList());
    for (final s in students) {
      sheet.appendRow([
        xls.TextCellValue(s.matricule),
        xls.TextCellValue(s.prenom),
        xls.TextCellValue(s.nom),
        xls.TextCellValue(s.sexe ?? ''),
        xls.TextCellValue(s.telephone ?? ''),
        xls.TextCellValue(s.departement ?? ''),
        xls.TextCellValue(s.commune ?? ''),
        xls.TextCellValue(s.axe ?? ''),
        xls.TextCellValue(s.filiere ?? ''),
        xls.DoubleCellValue(s.montantPrepac),
      ]);
    }
    final dir = await _reportsDir();
    final file = File('${dir.path}/etudiants_${_ts()}.xlsx');
    final bytes = excel.encode();
    if (bytes != null) await file.writeAsBytes(bytes);
    return file;
  }

  // -------------------- PDF --------------------
  static Future<File> studentsPdf(
      List<Student> students, {required String periode}) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => _pdfHeader('Rapport des étudiants', periode),
        build: (_) => [
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromInt(0xFF0D2C54)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Matricule', 'Nom complet', 'Commune', 'Filière', 'PREPAC'],
            data: students
                .map((s) => [
                      s.matricule,
                      s.nomComplet,
                      s.commune ?? '',
                      s.filiere ?? s.axe ?? '',
                      Formatters.money(s.montantPrepac),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total étudiants : ${students.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
    final dir = await _reportsDir();
    final file = File('${dir.path}/rapport_etudiants_${_ts()}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Future<File> paymentsPdf(
      List<PaymentWithStudent> payments,
      {required String periode, required double total}) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => _pdfHeader('Rapport des paiements', periode),
        build: (_) => [
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromInt(0xFF0D2C54)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Reçu', 'Étudiant', 'Mode', 'Date', 'Montant'],
            data: payments
                .map((p) => [
                      p.payment.recuNumero,
                      p.studentNom,
                      p.payment.mode.label,
                      Formatters.date(p.payment.datePaiement),
                      Formatters.money(p.payment.montant),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total encaissé : ${Formatters.money(total)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
    final dir = await _reportsDir();
    final file = File('${dir.path}/rapport_paiements_${_ts()}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _pdfHeader(String titre, String periode) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('HORY.NEX',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF0D2C54))),
                pw.Text(DateTime.now().toString().split('.').first,
                    style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.Text(titre,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Période : $periode',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.Divider(),
          ],
        ),
      );
}
