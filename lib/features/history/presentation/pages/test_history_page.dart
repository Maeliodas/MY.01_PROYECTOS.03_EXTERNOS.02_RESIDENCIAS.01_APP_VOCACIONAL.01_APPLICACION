import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../result/presentation/providers/result_provider.dart';
import '../../../../core/widgets/app_back_button.dart';

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
                ? const [AppColors.backgroundDark, AppColors.blue900]
                : const [AppColors.white, AppColors.blue50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                child: Row(
                  children: [
                    AppBackButton(onPressed: () => Navigator.maybePop(context)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Historial',
                        style: AppTypography.headline.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.primaryOnDark : AppColors.secondary;
    final createdAt = DateTime.tryParse(item['created_at']?.toString() ?? '');
    final affinity = _toDouble(item['top_career_affinity']).round();
    final careerName = item['top_career_name']?.toString().trim();
    final holland = item['holland_code']?.toString().trim();

    return Material(
      color: dark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppMetrics.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppMetrics.radiusLg),
        onTap: () => _showDetails(context, item),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppMetrics.radiusLg),
            border: dark ? Border.all(color: AppColors.borderDark) : null,
            boxShadow: dark ? AppMetrics.shadowCardDark : AppMetrics.shadowCard,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: dark ? AppColors.surfaceVariantDark : AppColors.blue50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: dark ? AppColors.primaryOnDark : AppColors.primary,
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
                      style: AppTypography.badge.copyWith(color: accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      careerName == null || careerName.isEmpty
                          ? 'Carrera no disponible'
                          : careerName,
                      style: AppTypography.title.copyWith(
                        height: 1.15,
                        color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${createdAt == null ? 'Fecha no disponible' : AppDateUtils.formatFullDate(createdAt)} · Perfil ${holland == null || holland.isEmpty ? '—' : holland}',
                      style: AppTypography.caption.copyWith(
                        color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: dark ? AppColors.primaryOnDarkContainer : AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(AppMetrics.radiusChip),
                ),
                child: Text(
                  '$affinity%',
                  style: AppTypography.bodyStrong.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppMetrics.radiusLg)),
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
                    color: dark ? AppColors.borderDark : AppColors.gray300,
                    borderRadius: BorderRadius.circular(AppMetrics.sm),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Detalle de evaluación',
                style: AppTypography.headline.copyWith(color: textColor),
              ),
              const SizedBox(height: 5),
              Text(
                item['top_career_name']?.toString() ?? 'Resultado vocacional',
                style: AppTypography.body.copyWith(fontSize: 16, color: secondaryColor),
              ),
              const SizedBox(height: 22),
              Text(
                'DESGLOSE RIASEC',
                style: AppTypography.badge.copyWith(
                  letterSpacing: 1,
                  color: dark ? AppColors.primaryOnDark : AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in scores.entries)
                _ScoreBar(
                  code: entry.key,
                  value: entry.value,
                  dark: dark,
                ),
              if (ranking.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  'MEJORES OPCIONES',
                  style: AppTypography.badge.copyWith(
                    letterSpacing: 1,
                    color: dark ? AppColors.primaryOnDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                ...ranking.take(3).map(
                  (career) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            career.name,
                            style: AppTypography.bodyStrong.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        Text(
                          '${career.affinity.round()}%',
                          style: AppTypography.bodyStrong.copyWith(
                            fontWeight: FontWeight.w700,
                            color: dark ? AppColors.primaryOnDark : AppColors.primary,
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
  final bool dark;

  const _ScoreBar({required this.code, required this.value, required this.dark});

  @override
  Widget build(BuildContext context) {
    final normalized = (value / 50).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              code,
              style: AppTypography.bodyStrong.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppMetrics.sm),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 8,
                backgroundColor: dark ? AppColors.borderDark : AppColors.blue100,
                valueColor: AlwaysStoppedAnimation(
                  dark ? AppColors.primaryOnDark : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              '${(normalized * 100).round()}%',
              textAlign: TextAlign.end,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              'No fue posible cargar el historial.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
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
