import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

import 'app.dart';
import 'core/db/database_helper.dart';
import 'providers.dart';
import 'repositories/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sur ordinateur (Windows / Linux), sqflite doit passer par le moteur FFI.
  // Sur Android / iOS ce bloc est ignoré : le comportement mobile ne change pas.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    // Mobile : verrouille l'orientation en portrait.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialise la base et le compte admin par défaut.
  await DatabaseHelper.instance.database;
  await UserRepository().ensureDefaultAdmin();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const HoryNexApp(),
    ),
  );
}
