import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación vertical para coincidir con la interfaz móvil de Figma
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicialización de SQLite previo al renderizado
  await AppDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: AevumIterApp(),
    ),
  );
}
