import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) => MaterialApp.router(
    title: 'Test Vocacional ITTUX',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.system,
    routerConfig: r.watch(appRouterProvider),
  );
}
