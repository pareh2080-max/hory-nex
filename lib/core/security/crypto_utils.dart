import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Utilitaires de chiffrement local des données sensibles (mots de passe).
///
/// Les mots de passe ne sont jamais stockés en clair : on conserve un
/// hachage SHA-256 salé (sel aléatoire par utilisateur).
class CryptoUtils {
  CryptoUtils._();

  static final Random _rng = Random.secure();

  /// Génère un sel aléatoire en base64.
  static String generateSalt([int length = 16]) {
    final bytes = List<int>.generate(length, (_) => _rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hache un mot de passe avec un sel donné (SHA-256).
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  /// Vérifie qu'un mot de passe correspond au hachage stocké.
  static bool verify(String password, String salt, String expectedHash) {
    return hashPassword(password, salt) == expectedHash;
  }
}
