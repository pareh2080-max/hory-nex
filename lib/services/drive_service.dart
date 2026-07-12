import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../core/db/database_helper.dart';

/// Client HTTP authentifié qui injecte les en-têtes OAuth de Google Sign-In.
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

/// Sauvegarde / restauration de la base HORY.NEX sur Google Drive.
///
/// PRÉREQUIS (voir INSTALLATION.md) :
///  1. Créer un projet Google Cloud + activer l'API Drive.
///  2. Configurer un identifiant OAuth Android (SHA-1 + applicationId).
///  3. La restauration remplace la base locale par la copie du cloud.
class DriveService {
  static const _backupFileName = 'hory_nex_backup.db';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<drive.DriveApi?> _api() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final headers = await account.authHeaders;
    return drive.DriveApi(_GoogleAuthClient(headers));
  }

  Future<String?> currentUserEmail() async {
    final acc = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    return acc?.email;
  }

  Future<void> signOut() => _googleSignIn.signOut();

  /// Sauvegarde la base SQLite sur Drive (crée ou met à jour le fichier).
  Future<String> backupDatabase() async {
    final api = await _api();
    if (api == null) throw Exception('Connexion Google annulée.');

    final dbPath = await DatabaseHelper.instance.databasePath();
    final dbFile = File(dbPath);
    if (!dbFile.existsSync()) throw Exception('Base de données introuvable.');

    final existingId = await _findBackupId(api);
    final media = drive.Media(dbFile.openRead(), dbFile.lengthSync());

    if (existingId != null) {
      await api.files.update(drive.File(), existingId, uploadMedia: media);
      return 'Sauvegarde mise à jour sur Google Drive.';
    } else {
      final meta = drive.File()
        ..name = _backupFileName
        ..description = 'Sauvegarde automatique HORY.NEX';
      await api.files.create(meta, uploadMedia: media);
      return 'Sauvegarde créée sur Google Drive.';
    }
  }

  /// Restaure la base depuis Drive (remplace la base locale).
  Future<String> restoreDatabase() async {
    final api = await _api();
    if (api == null) throw Exception('Connexion Google annulée.');

    final id = await _findBackupId(api);
    if (id == null) throw Exception('Aucune sauvegarde trouvée sur Drive.');

    final media = await api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }

    // Ferme la base, écrase le fichier, puis rouvre.
    await DatabaseHelper.instance.close();
    final dbPath = await DatabaseHelper.instance.databasePath();
    await File(dbPath).writeAsBytes(bytes, flush: true);
    await DatabaseHelper.instance.database; // réouverture
    return 'Restauration terminée avec succès.';
  }

  Future<String?> _findBackupId(drive.DriveApi api) async {
    final result = await api.files.list(
      q: "name = '$_backupFileName' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    final files = result.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }
}
