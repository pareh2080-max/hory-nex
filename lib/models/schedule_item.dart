class ScheduleItem {
  final String id;
  final String jour;
  final String heureDebut;
  final String heureFin;
  final String? salle;
  final String cours;
  final String? encadreurId;
  final String? filiere;
  final String? niveau;
  final int ordre;
  final String createdAt;

  const ScheduleItem({
    required this.id,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    this.salle,
    required this.cours,
    this.encadreurId,
    this.filiere,
    this.niveau,
    this.ordre = 0,
    required this.createdAt,
  });

  ScheduleItem copyWith({String? jour, int? ordre}) => ScheduleItem(
        id: id,
        jour: jour ?? this.jour,
        heureDebut: heureDebut,
        heureFin: heureFin,
        salle: salle,
        cours: cours,
        encadreurId: encadreurId,
        filiere: filiere,
        niveau: niveau,
        ordre: ordre ?? this.ordre,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'jour': jour,
        'heure_debut': heureDebut,
        'heure_fin': heureFin,
        'salle': salle,
        'cours': cours,
        'encadreur_id': encadreurId,
        'filiere': filiere,
        'niveau': niveau,
        'ordre': ordre,
        'created_at': createdAt,
      };

  factory ScheduleItem.fromMap(Map<String, Object?> m) => ScheduleItem(
        id: m['id'] as String,
        jour: m['jour'] as String,
        heureDebut: m['heure_debut'] as String,
        heureFin: m['heure_fin'] as String,
        salle: m['salle'] as String?,
        cours: m['cours'] as String,
        encadreurId: m['encadreur_id'] as String?,
        filiere: m['filiere'] as String?,
        niveau: m['niveau'] as String?,
        ordre: (m['ordre'] as int?) ?? 0,
        createdAt: m['created_at'] as String,
      );
}

class CalendarEvent {
  final String id;
  final String titre;
  final String type; // cours | examen | reunion | paiement | vacances | rappel
  final String date;
  final String? note;
  final String createdAt;

  const CalendarEvent({
    required this.id,
    required this.titre,
    required this.type,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'titre': titre,
        'type': type,
        'date': date,
        'note': note,
        'created_at': createdAt,
      };

  factory CalendarEvent.fromMap(Map<String, Object?> m) => CalendarEvent(
        id: m['id'] as String,
        titre: m['titre'] as String,
        type: m['type'] as String,
        date: m['date'] as String,
        note: m['note'] as String?,
        createdAt: m['created_at'] as String,
      );
}
