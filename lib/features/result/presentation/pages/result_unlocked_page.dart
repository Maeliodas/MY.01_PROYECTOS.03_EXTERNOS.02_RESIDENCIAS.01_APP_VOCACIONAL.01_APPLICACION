import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/result_local_datasource.dart';
import '../../domain/services/result_calculator.dart';
import '../../../../core/constants/riasec_constants.dart';

class ResultUnlockedPage extends ConsumerStatefulWidget {
  const ResultUnlockedPage({super.key});
  @override
  ConsumerState<ResultUnlockedPage> createState() => _S();
}

class _S extends ConsumerState<ResultUnlockedPage> {
  bool loading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading) _buildResult();
  }

  Future<void> _buildResult() async {
    final sid = GoRouterState.of(context).uri.queryParameters['session'];
    if (sid == null) return;
    final d = await AppDatabase.instance.database;
    final a = await d.query(
      Tables.answers,
      where: 'sessionId=?',
      whereArgs: [sid],
    );
    final answers = {
      for (final x in a)
        if (x['value'] != null) x['questionId'] as String: (x['value'] as int),
    };
    final calc = ResultCalculator();
    final result = calc.calculate(answers);
    final careers = calc.rank(result);
    final sr = await d.query(
      Tables.testSessions,
      where: 'id=?',
      whereArgs: [sid],
      limit: 1,
    );
    final open = sr.isEmpty ? null : sr.first['openResponse'] as String?;
    final pr = await d.query(Tables.profile, limit: 1);
    final snap = pr.isEmpty
        ? <String, dynamic>{}
        : {
            'schoolId': pr.first['schoolId'],
            'schoolName': pr.first['schoolNameSnapshot'],
            'gender': pr.first['gender'],
            'languageIds': jsonDecode(
              pr.first['languageIds'] as String? ?? '[]',
            ),
            'languageNames': jsonDecode(
              pr.first['languageNamesSnapshot'] as String? ?? '[]',
            ),
          };
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await ResultLocalDataSource().save(
      id: id,
      sessionId: sid,
      result: result,
      careers: careers,
      openResponse: open,
      profile: snap,
    );
    final payload = {
      'recordId': id,
      'createdAt': AppDateUtils.now(),
      'schoolId': snap['schoolId'],
      'gender': snap['gender'],
      'languageIds': snap['languageIds'],
      'riasecScores': result.scores.map((k, v) => MapEntry(k.code, v)),
      'hollandCode': result.hollandCode,
      'recommendedCareer': careers.first.careerId,
      'recommendedCareers': careers.take(3).map((x) => x.careerId).toList(),
    };
    await SyncQueue().add('anonymous_result', id, payload);
    Future.microtask(() => SyncService().syncInBackground());
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: SafeArea(
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      '¡Gracias por completar el test!',
                      style: Theme.of(c).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tus respuestas quedaron guardadas localmente y la información estadística se sincroniza en segundo plano',
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () => c.go('/result/detail'),
                      child: const Text('Ver mis resultados'),
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}
