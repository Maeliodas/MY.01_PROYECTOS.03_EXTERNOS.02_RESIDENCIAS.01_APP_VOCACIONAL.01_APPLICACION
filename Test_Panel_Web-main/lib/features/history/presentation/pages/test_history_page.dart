import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../result/presentation/providers/result_provider.dart';

class TestHistoryPage extends ConsumerWidget {
  const TestHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(resultHistoryProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF0F160D), Color(0xFF121A10), Color(0xFF102019)]
                : const [Color(0xFFF7FFE9), Color(0xFFF5F9EC), Color(0xFFECFFF8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Historial',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar',
                      onPressed: () => ref.invalidate(resultHistoryProvider),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: history.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, stackTrace) => _HistoryError(
                    onRetry: () => ref.invalidate(resultHistoryProvider),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const EmptyState(
                        message: 'Aún no has completado ningún test vocacional.',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => ref.refresh(resultHistoryProvider.future),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _HistoryCard(
                            item: item,
                            index: items.length - index,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _HistoryCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(item['created_at']?.toString() ?? '');
    final affinity = _toDouble(item['top_career_affinity']).round();
    final careerName = item['top_career_name']?.toString().trim();
    final holland = item['holland_code']?.toString().trim();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _showDetails(context, item),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .055),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF8D9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFF287400),
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evaluación $index',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                        color: Color(0xFF18A9D3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      careerName == null || careerName.isEmpty
                          ? 'Carrera no disponible'
                          : careerName,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${createdAt == null ? 'Fecha no disponible' : AppDateUtils.formatFullDate(createdAt)} · Perfil ${holland == null || holland.isEmpty ? '—' : holland}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$affinity%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6A23C1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> item) {
    final ranking = _decodeRanking(item['full_ranking_json']);
    final scores = <String, double>{
      'R': _toDouble(item['score_r']),
      'I': _toDouble(item['score_i']),
      'A': _toDouble(item['score_a']),
      'S': _toDouble(item['score_s']),
      'E': _toDouble(item['score_e']),
      'C': _toDouble(item['score_c']),
    };

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: .72,
        minChildSize: .50,
        maxChildSize: .92,
        expand: false,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DDCE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Detalle de evaluación',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                item['top_career_name']?.toString() ?? 'Resultado vocacional',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'DESGLOSE RIASEC',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Color(0xFF287400),
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in scores.entries)
                _ScoreBar(code: entry.key, value: entry.value),
              if (ranking.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text(
                  'MEJORES OPCIONES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Color(0xFF287400),
                  ),
                ),
                const SizedBox(height: 10),
                ...ranking.take(3).map(
                  (career) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            career.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${career.affinity.round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF287400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String code;
  final double value;

  const _ScoreBar({required this.code, required this.value});

  @override
  Widget build(BuildContext context) {
    final normalized = (value / 50).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(code, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 8,
                backgroundColor: const Color(0xFFE0E8D8),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              '${(normalized * 100).round()}%',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  final VoidCallback onRetry;

  const _HistoryError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No fue posible cargar el historial.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _HistoryCareer {
  final String name;
  final double affinity;

  const _HistoryCareer({required this.name, required this.affinity});
}

List<_HistoryCareer> _decodeRanking(dynamic raw) {
  if (raw == null) return const [];
  try {
    final decoded = jsonDecode(raw.toString());
    if (decoded is! List) return const [];
    return decoded.whereType<Map>().map((item) {
      return _HistoryCareer(
        name: item['name']?.toString() ?? 'Carrera',
        affinity: _toDouble(item['affinity']),
      );
    }).toList();
  } catch (_) {
    return const [];
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
