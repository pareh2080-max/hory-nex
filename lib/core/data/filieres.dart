/// Filières PREPAC organisées en trois grands axes.
class Filieres {
  Filieres._();

  static const String axeScientifique = 'AXE SCIENTIFIQUE (SC)';
  static const String axeAgroMedical = 'AXE AGRO-MÉDICAL';
  static const String axeSciencesHumaines = 'AXE SCIENCES HUMAINES ET SOCIALES (SH)';

  static const List<String> axes = [
    axeScientifique,
    axeAgroMedical,
    axeSciencesHumaines,
  ];

  static const Map<String, List<String>> parAxe = {
    axeScientifique: [
      'Génie civil',
      'Génie mécanique',
      'Génie électrique',
      'Génie industriel',
      'Génie informatique',
      'Informatique',
      'Mathématiques',
      'Statistiques',
      'Physique',
      'Chimie',
      'Architecture',
      'Télécommunication',
      'Robotique',
      'Intelligence Artificielle',
      'Data Science',
    ],
    axeAgroMedical: [
      'Médecine',
      'Médecine vétérinaire',
      'Agronomie',
      'Sciences environnementales',
      'Biologie',
      'Infirmière',
      'Sage-femme',
      'Nutrition',
      'Laboratoire médical',
      'Santé publique',
      'Pharmacie',
      'Odontologie',
      'Épidémiologie',
      'Foresterie',
      'Gestion environnementale',
    ],
    axeSciencesHumaines: [
      'Droit',
      'Économie',
      'Gestion',
      'Administration',
      'Comptabilité',
      'Marketing',
      'Psychologie',
      'Sociologie',
      'Anthropologie',
      'Science politique',
      'Communication',
      'Journalisme',
      'Relations internationales',
      'Tourisme',
      'Langues modernes',
      'Histoire',
      'Géographie',
      'Éducation',
      'Travail social',
    ],
  };

  static List<String> filieresDe(String? axe) {
    if (axe == null) return const [];
    return parAxe[axe] ?? const [];
  }
}
