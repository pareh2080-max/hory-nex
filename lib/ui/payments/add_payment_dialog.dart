import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../models/payment.dart';
import '../../models/student.dart';
import '../../providers.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final Student student;
  final double soldeRestant;
  final String caissier;
  const AddPaymentDialog({
    super.key,
    required this.student,
    required this.soldeRestant,
    required this.caissier,
  });

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _montant = TextEditingController();
  final _reference = TextEditingController();
  PaymentMode _mode = PaymentMode.especes;
  bool _saving = false;

  @override
  void dispose() {
    _montant.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final montant = double.tryParse(_montant.text.replaceAll(',', '.'));
    if (montant == null || montant <= 0) return;
    setState(() => _saving = true);
    await ref.read(paymentRepoProvider).create(
          studentId: widget.student.id,
          montant: montant,
          mode: _mode,
          reference: _reference.text.trim(),
          caissier: widget.caissier,
        );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau paiement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solde restant : ${Formatters.money(widget.soldeRestant)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _montant,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Montant (HTG) *'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMode>(
              initialValue: _mode,
              decoration: const InputDecoration(labelText: 'Mode de paiement'),
              items: PaymentMode.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
              onChanged: (v) => setState(() => _mode = v ?? PaymentMode.especes),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reference,
              decoration: const InputDecoration(
                  labelText: 'Référence (MonCash/NatCash/Chèque...)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? '...' : 'Enregistrer'),
        ),
      ],
    );
  }
}
