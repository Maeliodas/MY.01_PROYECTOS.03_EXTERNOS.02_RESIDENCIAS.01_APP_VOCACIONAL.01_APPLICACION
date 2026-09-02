import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/app_database.dart';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await AppDatabase.instance.database; runApp(const ProviderScope(child: App())); }
