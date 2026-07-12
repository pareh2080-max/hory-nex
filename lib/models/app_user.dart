/// Rôles disponibles dans l'application.
enum UserRole { admin, caissier, encadreur, utilisateur }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.caissier:
        return 'Caissier';
      case UserRole.encadreur:
        return 'Encadreur';
      case UserRole.utilisateur:
        return 'Utilisateur';
    }
  }

  String get id => name;

  static UserRole fromId(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.utilisateur,
    );
  }
}

class AppUser {
  final String id;
  final String username;
  final String fullName;
  final UserRole role;
  final String passwordHash;
  final String salt;
  final bool active;
  final String createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.passwordHash,
    required this.salt,
    this.active = true,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        'role': role.name,
        'password_hash': passwordHash,
        'salt': salt,
        'active': active ? 1 : 0,
        'created_at': createdAt,
      };

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as String,
        username: m['username'] as String,
        fullName: m['full_name'] as String,
        role: UserRoleX.fromId(m['role'] as String),
        passwordHash: m['password_hash'] as String,
        salt: m['salt'] as String,
        active: (m['active'] as int? ?? 1) == 1,
        createdAt: m['created_at'] as String,
      );

  /// Permissions par rôle.
  bool get canManageStudents =>
      role == UserRole.admin || role == UserRole.encadreur || role == UserRole.caissier;
  bool get canManagePayments => role == UserRole.admin || role == UserRole.caissier;
  bool get canManageEncadreurs => role == UserRole.admin;
  bool get canBackup => role == UserRole.admin;
  bool get canManageUsers => role == UserRole.admin;
  bool get canManageAttendance =>
      role == UserRole.admin || role == UserRole.encadreur;
}
