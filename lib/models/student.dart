class Student {
  final String id;
  final String matricule;
  final String? photoPath;
  final String nom;
  final String prenom;
  final String? sexe;
  final String? dateNaissance;
  final String? nif;
  final String? cin;
  final String? telephone;
  final String? whatsapp;
  final String? email;
  final String? adresse;
  final String? departement;
  final String? commune;
  final String? sectionCommunale;
  final String? ecolePrecedente;
  final String? anneeScolaire;
  final String? dateInscription;
  final String? nomParent;
  final String? telParent;
  final String? professionParent;
  final String? axe;
  final String? filiere;
  final double montantPrepac;
  final String createdAt;
  final String updatedAt;

  const Student({
    required this.id,
    required this.matricule,
    this.photoPath,
    required this.nom,
    required this.prenom,
    this.sexe,
    this.dateNaissance,
    this.nif,
    this.cin,
    this.telephone,
    this.whatsapp,
    this.email,
    this.adresse,
    this.departement,
    this.commune,
    this.sectionCommunale,
    this.ecolePrecedente,
    this.anneeScolaire,
    this.dateInscription,
    this.nomParent,
    this.telParent,
    this.professionParent,
    this.axe,
    this.filiere,
    this.montantPrepac = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get nomComplet => '$prenom $nom';

  Student copyWith({
    String? photoPath,
    String? nom,
    String? prenom,
    String? sexe,
    String? dateNaissance,
    String? nif,
    String? cin,
    String? telephone,
    String? whatsapp,
    String? email,
    String? adresse,
    String? departement,
    String? commune,
    String? sectionCommunale,
    String? ecolePrecedente,
    String? anneeScolaire,
    String? dateInscription,
    String? nomParent,
    String? telParent,
    String? professionParent,
    String? axe,
    String? filiere,
    double? montantPrepac,
    String? updatedAt,
  }) {
    return Student(
      id: id,
      matricule: matricule,
      photoPath: photoPath ?? this.photoPath,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      nif: nif ?? this.nif,
      cin: cin ?? this.cin,
      telephone: telephone ?? this.telephone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      departement: departement ?? this.departement,
      commune: commune ?? this.commune,
      sectionCommunale: sectionCommunale ?? this.sectionCommunale,
      ecolePrecedente: ecolePrecedente ?? this.ecolePrecedente,
      anneeScolaire: anneeScolaire ?? this.anneeScolaire,
      dateInscription: dateInscription ?? this.dateInscription,
      nomParent: nomParent ?? this.nomParent,
      telParent: telParent ?? this.telParent,
      professionParent: professionParent ?? this.professionParent,
      axe: axe ?? this.axe,
      filiere: filiere ?? this.filiere,
      montantPrepac: montantPrepac ?? this.montantPrepac,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'matricule': matricule,
        'photo_path': photoPath,
        'nom': nom,
        'prenom': prenom,
        'sexe': sexe,
        'date_naissance': dateNaissance,
        'nif': nif,
        'cin': cin,
        'telephone': telephone,
        'whatsapp': whatsapp,
        'email': email,
        'adresse': adresse,
        'departement': departement,
        'commune': commune,
        'section_communale': sectionCommunale,
        'ecole_precedente': ecolePrecedente,
        'annee_scolaire': anneeScolaire,
        'date_inscription': dateInscription,
        'nom_parent': nomParent,
        'tel_parent': telParent,
        'profession_parent': professionParent,
        'axe': axe,
        'filiere': filiere,
        'montant_prepac': montantPrepac,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Student.fromMap(Map<String, Object?> m) => Student(
        id: m['id'] as String,
        matricule: m['matricule'] as String,
        photoPath: m['photo_path'] as String?,
        nom: m['nom'] as String,
        prenom: m['prenom'] as String,
        sexe: m['sexe'] as String?,
        dateNaissance: m['date_naissance'] as String?,
        nif: m['nif'] as String?,
        cin: m['cin'] as String?,
        telephone: m['telephone'] as String?,
        whatsapp: m['whatsapp'] as String?,
        email: m['email'] as String?,
        adresse: m['adresse'] as String?,
        departement: m['departement'] as String?,
        commune: m['commune'] as String?,
        sectionCommunale: m['section_communale'] as String?,
        ecolePrecedente: m['ecole_precedente'] as String?,
        anneeScolaire: m['annee_scolaire'] as String?,
        dateInscription: m['date_inscription'] as String?,
        nomParent: m['nom_parent'] as String?,
        telParent: m['tel_parent'] as String?,
        professionParent: m['profession_parent'] as String?,
        axe: m['axe'] as String?,
        filiere: m['filiere'] as String?,
        montantPrepac: (m['montant_prepac'] as num?)?.toDouble() ?? 0,
        createdAt: m['created_at'] as String,
        updatedAt: m['updated_at'] as String,
      );
}
