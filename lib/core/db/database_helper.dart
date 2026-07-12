import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Point d'accès unique à la base SQLite locale de HORY.NEX.
///
/// La base fonctionne 100 % hors ligne. Le fichier `.db` est aussi
/// l'artefact principal sauvegardé/restauré via Google Drive.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String dbName = 'hory_nex.db';
  static const int dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  /// Chemin absolu du fichier de base (utile pour la sauvegarde Drive).
  Future<String> databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, dbName);
  }

  Future<Database> _open() async {
    final path = await databasePath();
    return openDatabase(
      path,
      version: dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // --- Utilisateurs / rôles ---
    await db.execute('''
      CREATE TABLE users (
        id            TEXT PRIMARY KEY,
        username      TEXT NOT NULL UNIQUE,
        full_name     TEXT NOT NULL,
        role          TEXT NOT NULL,          -- admin | caissier | encadreur | utilisateur
        password_hash TEXT NOT NULL,
        salt          TEXT NOT NULL,
        active        INTEGER NOT NULL DEFAULT 1,
        created_at    TEXT NOT NULL
      )
    ''');

    // --- Étudiants ---
    await db.execute('''
      CREATE TABLE students (
        id                  TEXT PRIMARY KEY,
        matricule           TEXT NOT NULL UNIQUE,   -- numéro d'inscription automatique
        photo_path          TEXT,
        nom                 TEXT NOT NULL,
        prenom              TEXT NOT NULL,
        sexe                TEXT,
        date_naissance      TEXT,
        nif                 TEXT,
        cin                 TEXT,
        telephone           TEXT,
        whatsapp            TEXT,
        email               TEXT,
        adresse             TEXT,
        departement         TEXT,
        commune             TEXT,
        section_communale   TEXT,
        ecole_precedente    TEXT,
        annee_scolaire      TEXT,
        date_inscription    TEXT,
        nom_parent          TEXT,
        tel_parent          TEXT,
        profession_parent   TEXT,
        axe                 TEXT,
        filiere             TEXT,
        montant_prepac      REAL NOT NULL DEFAULT 0,
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_students_nom ON students(nom, prenom)');
    await db.execute('CREATE INDEX idx_students_matricule ON students(matricule)');
    await db.execute('CREATE INDEX idx_students_dept ON students(departement, commune)');
    await db.execute('CREATE INDEX idx_students_filiere ON students(axe, filiere)');
    await db.execute('CREATE INDEX idx_students_tel ON students(telephone)');

    // --- Encadreurs ---
    await db.execute('''
      CREATE TABLE encadreurs (
        id              TEXT PRIMARY KEY,
        matricule       TEXT NOT NULL UNIQUE,
        photo_path      TEXT,
        nom             TEXT NOT NULL,
        prenom          TEXT NOT NULL,
        telephone       TEXT,
        whatsapp        TEXT,
        adresse         TEXT,
        email           TEXT,
        specialite      TEXT,
        matiere         TEXT,
        axe             TEXT,
        date_embauche   TEXT,
        disponibilite   TEXT,
        statut          TEXT,
        created_at      TEXT NOT NULL,
        updated_at      TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_encadreurs_nom ON encadreurs(nom, prenom)');

    // --- Paiements ---
    await db.execute('''
      CREATE TABLE payments (
        id              TEXT PRIMARY KEY,
        student_id      TEXT NOT NULL,
        recu_numero     TEXT NOT NULL UNIQUE,
        montant         REAL NOT NULL,
        mode            TEXT NOT NULL,          -- Espèces | MonCash | NatCash | Virement | Chèque
        reference       TEXT,
        date_paiement   TEXT NOT NULL,
        caissier        TEXT,
        note            TEXT,
        created_at      TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_payments_student ON payments(student_id)');
    await db.execute('CREATE INDEX idx_payments_date ON payments(date_paiement)');

    // --- Présences ---
    await db.execute('''
      CREATE TABLE attendance (
        id            TEXT PRIMARY KEY,
        student_id    TEXT NOT NULL,
        date          TEXT NOT NULL,
        heure         TEXT,
        statut        TEXT NOT NULL,           -- present | absent | retard
        justifie      INTEGER NOT NULL DEFAULT 0,
        signature     TEXT,
        note          TEXT,
        created_at    TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');
    await db.execute('CREATE INDEX idx_attendance_student ON attendance(student_id, date)');

    // --- Horaire / planning ---
    await db.execute('''
      CREATE TABLE schedule (
        id            TEXT PRIMARY KEY,
        jour          TEXT NOT NULL,           -- Lundi..Dimanche
        heure_debut   TEXT NOT NULL,
        heure_fin     TEXT NOT NULL,
        salle         TEXT,
        cours         TEXT NOT NULL,
        encadreur_id  TEXT,
        filiere       TEXT,
        niveau        TEXT,
        ordre         INTEGER NOT NULL DEFAULT 0,
        created_at    TEXT NOT NULL,
        FOREIGN KEY (encadreur_id) REFERENCES encadreurs(id) ON DELETE SET NULL
      )
    ''');

    // --- Événements calendrier ---
    await db.execute('''
      CREATE TABLE calendar_events (
        id            TEXT PRIMARY KEY,
        titre         TEXT NOT NULL,
        type          TEXT NOT NULL,           -- cours | examen | reunion | paiement | vacances | rappel
        date          TEXT NOT NULL,
        note          TEXT,
        created_at    TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_events_date ON calendar_events(date)');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // Migrations futures : à compléter au fil des versions.
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
