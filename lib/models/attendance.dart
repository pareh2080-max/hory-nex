enum AttendanceStatus { present, absent, retard }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Présent';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.retard:
        return 'Retard';
    }
  }

  static AttendanceStatus fromId(String value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AttendanceStatus.present,
    );
  }
}

class Attendance {
  final String id;
  final String studentId;
  final String date;
  final String? heure;
  final AttendanceStatus statut;
  final bool justifie;
  final String? signature;
  final String? note;
  final String createdAt;

  const Attendance({
    required this.id,
    required this.studentId,
    required this.date,
    this.heure,
    required this.statut,
    this.justifie = false,
    this.signature,
    this.note,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'student_id': studentId,
        'date': date,
        'heure': heure,
        'statut': statut.name,
        'justifie': justifie ? 1 : 0,
        'signature': signature,
        'note': note,
        'created_at': createdAt,
      };

  factory Attendance.fromMap(Map<String, Object?> m) => Attendance(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        date: m['date'] as String,
        heure: m['heure'] as String?,
        statut: AttendanceStatusX.fromId(m['statut'] as String),
        justifie: (m['justifie'] as int? ?? 0) == 1,
        signature: m['signature'] as String?,
        note: m['note'] as String?,
        createdAt: m['created_at'] as String,
      );
}
