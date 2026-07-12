import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_user.dart';
import 'repositories/attendance_repository.dart';
import 'repositories/encadreur_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/schedule_repository.dart';
import 'repositories/student_repository.dart';
import 'repositories/user_repository.dart';

// ------------------- Repositories -------------------
final studentRepoProvider = Provider((_) => StudentRepository());
final paymentRepoProvider = Provider((_) => PaymentRepository());
final encadreurRepoProvider = Provider((_) => EncadreurRepository());
final attendanceRepoProvider = Provider((_) => AttendanceRepository());
final userRepoProvider = Provider((_) => UserRepository());
final scheduleRepoProvider = Provider((_) => ScheduleRepository());
final calendarRepoProvider = Provider((_) => CalendarRepository());

// ------------------- Préférences (thème) -------------------
final prefsProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError('SharedPreferences doit être initialisé dans main()');
});

class ThemeController extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;
  static const _key = 'theme_mode';

  ThemeController(this.prefs) : super(_read(prefs));

  static ThemeMode _read(SharedPreferences p) {
    switch (p.getString(_key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await prefs.setString(_key, mode.name);
  }

  void toggle() {
    set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController(ref.watch(prefsProvider));
});

// ------------------- Authentification -------------------
class AuthController extends StateNotifier<AppUser?> {
  final UserRepository repo;
  AuthController(this.repo) : super(null);

  Future<bool> login(String username, String password) async {
    final user = await repo.authenticate(username, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  void logout() => state = null;
}

final authProvider = StateNotifierProvider<AuthController, AppUser?>((ref) {
  return AuthController(ref.watch(userRepoProvider));
});
