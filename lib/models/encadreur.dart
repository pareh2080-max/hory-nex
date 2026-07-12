class Encadreur {
  final String id;
  final String matricule;
  final String? photoPath;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? whatsapp;
  final String? adresse;
  final String? email;
  final String? specialite;
  final String? matiere;
  final String? axe;
  final String? dateEmbauche;
  final String? disponibilite;
  final String? statut;
  final String createdAt;
  final String updatedAt;

  const Encadreur({
    required this.id,
    required this.matricule,
    this.photoPath,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.whatsapp,
    this.adresse,
    this.email,
    this.specialite,
    this.matiere,
    this.axe,
    this.dateEmbauche,
    this.disponibilite,
    this.statut,
    required this.createdAt,
    required this.updatedAt,
  });

  String get nomComplet => '$prenom $nom';

  Map<String, Object?> toMap() => {
        'id': id,
        'matricule': matricule,
        'photo_path': photoPath,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'whatsapp': whatsapp,
        'adresse': adresse,
        'email': email,
        'specialite': specialite,
        'matiere': matiere,
        'axe': axe,
        'date_embauche': dateEmbauche,
        'disponibilite': disponibilite,
        'statut': statut,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Encadreur.fromMap(Map<String, Object?> m) => Encadreur(
        id: m['id'] as String,
        matricule: m['matricule'] as String,
        photoPath: m['photo_path'] as String?,
        nom: m['nom'] as String,
        prenom: m['prenom'] as String,
        telephone: m['telephone'] as String?,
        whatsapp: m['whatsapp'] as String?,
        adresse: m['adresse'] as String?,
        email: m['email'] as String?,
        specialite: m['specialite'] as String?,
        matiere: m['matiere'] as String?,
        axe: m['axe'] as String?,
        dateEmbauche: m['date_embauche'] as String?,
        disponibilite: m['disponibilite'] as String?,
        statut: m['statut'] as String?,
        createdAt: m['created_at'] as String,
        updatedAt: m['updated_at'] as String,
      );
}
