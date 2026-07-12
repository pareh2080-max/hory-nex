import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/db/database_helper.dart';
import '../core/security/crypto_utils.dart';
import '../models/app_user.dart';

class UserRepository {
  final _uuid = const Uuid();
  Future<Database> get _db async => DatabaseHelper.instance.database;

  /// Crée le compte administrateur par défaut au premier lancement.
  /// Identifiants initiaux : admin / admin123 (à changer immédiatement).
  Future<void> ensureDefaultAdmin() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM users');
    if ((rows.first['c'] as int) > 0) return;
    await createUser(
      username: 'admin',
      fullName: 'Administrateur',
      role: UserRole.admin,
      password: 'admin123',
    );
  }

  Future<AppUser> createUser({
    required String username,
    required String fullName,
    required UserRole role,
    required String password,
  }) async {
    final db = await _db;
    final salt = CryptoUtils.generateSalt();
    final user = AppUser(
      id: _uuid.v4(),
      username: username.trim().toLowerCase(),
      fullName: fullName,
      role: role,
      passwordHash: CryptoUtils.hashPassword(password, salt),
      salt: salt,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('users', user.toMap());
    return user;
  }

  Future<AppUser?> authenticate(String username, String password) async {
    final db = await _db;
    final rows = await db.query('users',
        where: 'username = ? AND active = 1',
        whereArgs: [username.trim().toLowerCase()],
        limit: 1);
    if (rows.isEmpty) return null;
    final user = AppUser.fromMap(rows.first);
    if (CryptoUtils.verify(password, user.salt, user.passwordHash)) {
      return user;
    }
    return null;
  }

  Future<void> changePassword(String userId, String newPassword) async {
    final db = await _db;
    final salt = CryptoUtils.generateSalt();
    await db.update(
      'users',
      {
        'salt': salt,
        'password_hash': CryptoUtils.hashPassword(newPassword, salt),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<AppUser>> all() async {
    final db = await _db;
    final rows = await db.query('users', orderBy: 'full_name ASC');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<void> setActive(String userId, bool active) async {
    final db = await _db;
    await db.update('users', {'active': active ? 1 : 0},
        where: 'id = ?', whereArgs: [userId]);
  }
}
