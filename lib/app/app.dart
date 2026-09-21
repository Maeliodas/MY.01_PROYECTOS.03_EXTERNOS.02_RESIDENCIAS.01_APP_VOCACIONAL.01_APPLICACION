import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/sync/catalog_live_sync.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class VocationalApp extends ConsumerWidget {
  const VocationalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) =>
          CatalogLiveSync(child: child ?? const SizedBox.shrink()),
    );
  }
}
