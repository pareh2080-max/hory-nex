import 'package:flutter_test/flutter_test.dart';
import 'package:hory_nex/core/security/crypto_utils.dart';

void main() {
  group('CryptoUtils', () {
    test('un mot de passe correct est vérifié', () {
      final salt = CryptoUtils.generateSalt();
      final hash = CryptoUtils.hashPassword('secret123', salt);
      expect(CryptoUtils.verify('secret123', salt, hash), isTrue);
    });

    test('un mauvais mot de passe est rejeté', () {
      final salt = CryptoUtils.generateSalt();
      final hash = CryptoUtils.hashPassword('secret123', salt);
      expect(CryptoUtils.verify('mauvais', salt, hash), isFalse);
    });

    test('deux sels différents produisent des hachages différents', () {
      final h1 = CryptoUtils.hashPassword('x', CryptoUtils.generateSalt());
      final h2 = CryptoUtils.hashPassword('x', CryptoUtils.generateSalt());
      expect(h1, isNot(equals(h2)));
    });
  });
}
