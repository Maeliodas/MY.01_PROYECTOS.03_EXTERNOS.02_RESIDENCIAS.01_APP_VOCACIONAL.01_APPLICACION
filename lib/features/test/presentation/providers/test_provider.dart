import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/sync_service.dart';
import '../../data/questions_data.dart';
import '../../data/test_local_datasource.dart';
import '../../domain/models/question.dart';
import '../../domain/models/test_session.dart';
import '../../domain/repositories/test_repository.dart';

class TestRepositoryImpl implements TestRepository {
  final TestLocalDataSource source;

  TestRepositoryImpl(this.source);

  @override
  Future<TestSession> startNewSession() =>
      source.create(questionsData.map((q) => q.id).toList());

  @override
  Future<TestSession?> active() => source.active();

  @override
  Future<List<Question>> questions() async => questionsData;

  @override
  Future<int?> answer(String s, String q) => source.answer(s, q);

  @override
  Future<void> saveAnswer(String s, String q, int v, int p) =>
      source.save(s, q, v, p);

  @override
  Future<void> position(String s, int p) => source.pos(s, p);

  @override
  Future<void> complete(String s) => source.complete(s);
}

final testRepositoryProvider = Provider<TestRepository>(
  (ref) => TestRepositoryImpl(TestLocalDataSource()),
);

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());
