import 'package:flutter/material.dart';

/// Palette officielle HORY.NEX
/// Bleu foncé, Vert, Blanc, Gris clair.
class AppColors {
  AppColors._();

  // Couleurs de marque
  static const Color bleuFonce = Color(0xFF0D2C54); // Bleu foncé principal
  static const Color bleuFonceClair = Color(0xFF1B4079);
  static const Color vert = Color(0xFF2E9E5B); // Vert principal
  static const Color vertClair = Color(0xFF4CC97D);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color grisClair = Color(0xFFF2F4F7);
  static const Color grisMoyen = Color(0xFF98A2B3);
  static const Color grisFonce = Color(0xFF344054);

  // Sémantique
  static const Color succes = Color(0xFF2E9E5B);
  static const Color avertissement = Color(0xFFF79009);
  static const Color danger = Color(0xFFD92D20);
  static const Color info = Color(0xFF1B4079);

  // Statuts de paiement
  static const Color paye = vert;
  static const Color partiel = avertissement;
  static const Color impaye = danger;
}
