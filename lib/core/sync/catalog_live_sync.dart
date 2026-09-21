import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/catalog/presentation/providers/catalog_providers.dart';

/// Actualización en vivo de catálogos mientras la app está abierta y hay red.
///
/// Revisa la versión ligera del panel al reanudar la app y cada cierto
/// intervalo; si hay novedades, descarga, aplica y refresca las pantallas.
/// Sin red no hace nada: lo pendiente se aplica en el siguiente arranque
/// con red (sync acotado del splash). No toca el test en curso.
class CatalogLiveSync extends ConsumerStatefulWidget {
  final Widget child;

  const CatalogLiveSync({super.key, required this.child});

  @override
  ConsumerState<CatalogLiveSync> createState() => _CatalogLiveSyncState();
}

class _CatalogLiveSyncState extends ConsumerState<CatalogLiveSync>
    with WidgetsBindingObserver {
  static const _interval = Duration(minutes: 5);

  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // El arranque ya lo cubre el splash; aquí solo reanudaciones e intervalo.
    _timer = Timer.periodic(_interval, (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_checking || !mounted) return;
    _checking = true;
    try {
      final changed =
          await ref.read(catalogSyncServiceProvider).checkAndSync();
      if (!mounted || !changed) return;
      ref.invalidate(statesProvider);
      ref.invalidate(schoolsProvider);
      ref.invalidate(allLanguagesProvider);
      ref.invalidate(careersCatalogProvider);
      ref.invalidate(departmentQuestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catálogos actualizados con novedades del panel.'),
        ),
      );
    } catch (_) {
      // Silencioso: el siguiente ciclo o arranque reintentará.
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
