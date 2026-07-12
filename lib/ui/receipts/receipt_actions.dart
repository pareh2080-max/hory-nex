import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/payment.dart';
import '../../models/student.dart';

/// Affiche la feuille d'actions pour un reçu PDF déjà généré.
void showReceiptActions(
    BuildContext context, File pdf, Student student, Payment payment) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.bleuFonce),
            title: Text('Reçu ${payment.recuNumero}'),
            subtitle: Text('${student.nomComplet} · ${Formatters.money(payment.montant)}'),
          ),
          const Divider(height: 1),
          _action(context, Icons.print, 'Imprimer', () async {
            final bytes = await pdf.readAsBytes();
            await Printing.layoutPdf(onLayout: (_) async => bytes);
          }),
          _action(context, Icons.picture_as_pdf, 'Aperçu / Télécharger PDF', () async {
            final bytes = await pdf.readAsBytes();
            await Printing.sharePdf(bytes: bytes, filename: '${payment.recuNumero}.pdf');
          }),
          _action(context, Icons.share, 'Partager (Bluetooth, Fichiers...)', () async {
            await Share.shareXFiles([XFile(pdf.path)],
                text: 'Reçu HORY.NEX ${payment.recuNumero}');
          }),
          _action(context, Icons.chat, 'Partager par WhatsApp', () async {
            final tel = (student.whatsapp?.isNotEmpty ?? false)
                ? student.whatsapp!
                : student.telephone ?? '';
            final msg = Uri.encodeComponent(
                'Bonjour ${student.prenom}, voici votre reçu HORY.NEX ${payment.recuNumero} '
                'd\'un montant de ${Formatters.money(payment.montant)}.');
            // Ouvre WhatsApp avec le message ; le PDF est aussi partageable via "Partager".
            final uri = Uri.parse('https://wa.me/${_cleanPhone(tel)}?text=$msg');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              await Share.shareXFiles([XFile(pdf.path)]);
            }
          }),
          _action(context, Icons.email, 'Envoyer par Email', () async {
            final uri = Uri(
              scheme: 'mailto',
              path: student.email ?? '',
              query: 'subject=${Uri.encodeComponent("Reçu HORY.NEX ${payment.recuNumero}")}'
                  '&body=${Uri.encodeComponent("Veuillez trouver votre reçu en pièce jointe (à joindre depuis Partager).")}',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
            await Share.shareXFiles([XFile(pdf.path)]);
          }),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

String _cleanPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  // Préfixe Haïti (509) si numéro local à 8 chiffres.
  if (digits.length == 8) return '509$digits';
  return digits;
}

Widget _action(BuildContext context, IconData icon, String label, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon),
    title: Text(label),
    onTap: () {
      Navigator.of(context).pop();
      onTap();
    },
  );
}
