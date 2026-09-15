import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'app/app.dart';
import 'core/sync/sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('AEVUM_API_URL: ${AppConstants.apiBaseUrl}');
  debugPrint(
  'AEVUM_API_KEY cargada: ${AppConstants.apiKey.isNotEmpty}',
);
  runApp(const ProviderScope(child: VocationalApp()));
  unawaited(SyncService().syncPendingQueue());
}
