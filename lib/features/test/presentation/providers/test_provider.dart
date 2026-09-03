import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/riasec_constants.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../result/data/result_local_datasource.dart';
import '../../../result/domain/services/result_calculator.dart';
import '../../data/questions_data.dart';
import '../../data/test_local_datasource.dart';
//import '../../domain/models/question.dart';
import '../../domain/models/test_session.dart';
import '../../domain/repositories/test_repository.dart';

final testRepositoryProvider = Provider((ref) => TestRepository());
final testDatasourceProvider = Provider((ref) => TestLocalDatasource());
final resultDatasourceProvider = Provider((ref) => ResultLocalDatasource());

class TestState {
  final TestSession? session;
  final int currentIndex;
  final Map<int, int> answers;
  final bool isCompleted;

  TestState({
    this.session,
    this.currentIndex = 0,
    this.answers = const {},
    this.isCompleted = false,
  });

  TestState copyWith({
    TestSession? session,
    int? currentIndex,
    Map<int, int>? answers,
    bool? isCompleted,
  }) {
    return TestState(
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  final Ref ref;

  TestNotifier(this.ref) : super(TestState());

  Future<void> startNewTestSession() async {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    final List<int> randomOrder = List.generate(30, (i) => i + 1)..shuffle();
    final newSession = TestSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: profile.id,
      status: 'in_progress',
      questionOrder: randomOrder,
      currentIndex: 0,
      createdAt: DateTime.now(),
    );

    await ref.read(testRepositoryProvider).saveSession(newSession);
    state = TestState(session: newSession, currentIndex: 0, answers: {});
  }

  Future<void> answerQuestion(int questionId, int value) async {
    if (state.session == null) return;

    final updatedAnswers = Map<int, int>.from(state.answers)
      ..[questionId] = value;
    state = state.copyWith(answers: updatedAnswers);

    final question =
        QuestionsData.questions.firstWhere((q) => q.id == questionId);
    await ref.read(testDatasourceProvider).saveAnswer(
          sessionId: state.session!.id,
          questionId: questionId,
          dimension: question.dimension.code,
          value: value,
        );
  }

  void nextQuestion() {
    if (state.currentIndex < 29) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  Future<void> completeTest(String openAnswer) async {
    if (state.session == null) return;

    final profile = ref.read(profileProvider);
    final riasec = ResultCalculator.calculate(state.answers);
    final matches = ResultCalculator.calculateCareerMatches(riasec);
    final topCareer = matches.first;

    // Guardar resultado localmente
    await ref.read(resultDatasourceProvider).saveResult(
          sessionId: state.session!.id,
          scoreR: riasec.scoreR,
          scoreI: riasec.scoreI,
          scoreA: riasec.scoreA,
          scoreS: riasec.scoreS,
          scoreE: riasec.scoreE,
          scoreC: riasec.scoreC,
          hollandCode: riasec.hollandCode,
          topCareerId: topCareer.careerId,
          topCareerName: topCareer.name,
          topCareerAffinity: topCareer.affinityPercentage,
          fullRanking: matches
              .map((m) => {
                    'id': m.careerId,
                    'name': m.name,
                    'affinity': m.affinityPercentage,
                  })
              .toList(),
        );

    // Payload de envío anónimo
    final anonymousPayload = {
      'school': profile?.school ?? 'Desconocida',
      'gender': profile?.gender ?? 'Otro',
      'speaks_languages': profile?.speaksLanguages ?? false,
      'languages': profile?.languagesList ?? [],
      'riasec_scores': {
        'R': riasec.scoreR,
        'I': riasec.scoreI,
        'A': riasec.scoreA,
        'S': riasec.scoreS,
        'E': riasec.scoreE,
        'C': riasec.scoreC,
      },
      'holland_code': riasec.hollandCode,
      'top_career': topCareer.name,
    };

    // Intentar sincronizar
    SyncService().processSessionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: state.session!.id,
      anonymousPayload: anonymousPayload,
    );

    state = state.copyWith(isCompleted: true);
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier(ref);
});
