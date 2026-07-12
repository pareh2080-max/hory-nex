/// Modes de paiement acceptés.
enum PaymentMode { especes, moncash, natcash, virement, cheque }

extension PaymentModeX on PaymentMode {
  String get label {
    switch (this) {
      case PaymentMode.especes:
        return 'Espèces';
      case PaymentMode.moncash:
        return 'MonCash';
      case PaymentMode.natcash:
        return 'NatCash';
      case PaymentMode.virement:
        return 'Virement';
      case PaymentMode.cheque:
        return 'Chèque';
    }
  }

  static PaymentMode fromLabel(String value) {
    return PaymentMode.values.firstWhere(
      (m) => m.label == value,
      orElse: () => PaymentMode.especes,
    );
  }
}

class Payment {
  final String id;
  final String studentId;
  final String recuNumero;
  final double montant;
  final PaymentMode mode;
  final String? reference;
  final String datePaiement;
  final String? caissier;
  final String? note;
  final String createdAt;

  const Payment({
    required this.id,
    required this.studentId,
    required this.recuNumero,
    required this.montant,
    required this.mode,
    this.reference,
    required this.datePaiement,
    this.caissier,
    this.note,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'student_id': studentId,
        'recu_numero': recuNumero,
        'montant': montant,
        'mode': mode.label,
        'reference': reference,
        'date_paiement': datePaiement,
        'caissier': caissier,
        'note': note,
        'created_at': createdAt,
      };

  factory Payment.fromMap(Map<String, Object?> m) => Payment(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        recuNumero: m['recu_numero'] as String,
        montant: (m['montant'] as num).toDouble(),
        mode: PaymentModeX.fromLabel(m['mode'] as String),
        reference: m['reference'] as String?,
        datePaiement: m['date_paiement'] as String,
        caissier: m['caissier'] as String?,
        note: m['note'] as String?,
        createdAt: m['created_at'] as String,
      );
}

/// Statut de paiement calculé d'un étudiant.
enum PaymentStatus { paye, partiel, impaye }

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paye:
        return 'Payé';
      case PaymentStatus.partiel:
        return 'Partiellement payé';
      case PaymentStatus.impaye:
        return 'Non payé';
    }
  }
}
