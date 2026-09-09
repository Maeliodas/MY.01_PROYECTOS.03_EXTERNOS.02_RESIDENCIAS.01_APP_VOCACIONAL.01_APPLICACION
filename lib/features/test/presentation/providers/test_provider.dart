import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/question_repository.dart';
import '../../data/test_local_datasource.dart';
import '../../domain/models/question.dart';

class TestState {
  final String? sessionId;
  final int currentIndex;
  final List<Question> questions;
  final Map<int, double> answers;
  final String openAnswer;
  final bool isCompleted;
  final bool restored;
  final bool isLoading;
  final String? error;

  const TestState({
    this.sessionId,
    required this.currentIndex,
    required this.questions,
    required this.answers,
    required this.openAnswer,
    required this.isCompleted,
    this.restored = false,
    this.isLoading = false,
    this.error,
  });

  TestState copyWith({
    String? sessionId,
    int? currentIndex,
    List<Question>? questions,
    Map<int, double>? answers,
    String? openAnswer,
    bool? isCompleted,
    bool? restored,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      TestState(
        sessionId: sessionId ?? this.sessionId,
        currentIndex: currentIndex ?? this.currentIndex,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        openAnswer: openAnswer ?? this.openAnswer,
        isCompleted: isCompleted ?? this.isCompleted,
        restored: restored ?? this.restored,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  double get progress => questions.isEmpty
      ? 0.0
      : ((currentIndex + 1) / questions.length).clamp(0.0, 1.0).toDouble();
}

class TestNotifier extends StateNotifier<TestState> {
  TestNotifier()
      : super(const TestState(
          currentIndex: 0,
          questions: [],
          answers: {},
          openAnswer: '',
          isCompleted: false,
          isLoading: true,
        )) {
    _initialize();
  }

  final QuestionRepository _questions = const QuestionRepository();
  final TestLocalDatasource _local = TestLocalDatasource();
  final Uuid _uuid = const Uuid();

  /// Aplica el orden guardado de ids sobre la lista canónica de preguntas.
  /// Si el orden está vacío o incompleto, devuelve la lista original.
  List<Question> _applyOrder(List<Question> canonical, List<int> order) {
    if (order.isEmpty) return List<Question>.from(canonical);
    final byId = {for (final q in canonical) q.id: q};
    final ordered = <Question>[];
    for (final id in order) {
      final q = byId[id];
      if (q != null) ordered.add(q);
    }
    // Si faltan preguntas (catálogo actualizado), se agregan al final.
    if (ordered.length < canonical.length) {
      final seen = ordered.map((q) => q.id).toSet();
      for (final q in canonical) {
        if (!seen.contains(q.id)) ordered.add(q);
      }
    }
    return ordered;
  }

  /// Baraja una copia de la lista (Fisher–Yates).
  List<Question> _shuffle(List<Question> source) {
    final list = List<Question>.from(source);
    list.shuffle();
    return list;
  }

  Future<void> _initialize() async {
    try {
      final canonical = await _questions.getActiveQuestions();
      final persisted = await _local.loadActiveSession();

      if (persisted == null) {
        // Sin sesión activa: lista canónica.
        // El orden aleatorio se genera al llamar startNewTestSession().
        state = TestState(
          currentIndex: 0,
          questions: canonical,
          answers: const {},
          openAnswer: '',
          isCompleted: false,
          restored: true,
          isLoading: false,
        );
        return;
      }

      // Restaurar sesión: respetar el orden guardado.
      final ordered = _applyOrder(canonical, persisted.questionOrder);
      final maxIndex = ordered.isEmpty ? 0 : ordered.length - 1;
      state = TestState(
        sessionId: persisted.id,
        currentIndex: persisted.currentIndex.clamp(0, maxIndex).toInt(),
        questions: ordered,
        answers: persisted.answers,
        openAnswer: persisted.openAnswer,
        isCompleted: persisted.completed,
        restored: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        restored: true,
        error: 'No se pudo cargar la prueba: $e',
      );
    }
  }

  /// Inicia (o reinicia) un test desde cero con orden aleatorio nuevo.
  Future<void> startNewTestSession() async {
    final canonical = await _questions.getActiveQuestions();
    final shuffled = _shuffle(canonical);
    await _local.clearCurrentProgress();
    final id = _uuid.v4();
    await _local.createSession(
      sessionId: id,
      questionOrder: shuffled.map((q) => q.id).toList(),
    );
    state = TestState(
      sessionId: id,
      currentIndex: 0,
      questions: shuffled,
      answers: const {},
      openAnswer: '',
      isCompleted: false,
      restored: true,
      isLoading: false,
    );
  }

  Future<void> _ensureSession() async {
    if (state.sessionId != null) return;
    await startNewTestSession();
  }

  Future<void> answerQuestion(double value) async {
    await _ensureSession();
    if (state.questions.isEmpty) return;
    final q = state.questions[state.currentIndex];
    final normalized = value.clamp(0.0, 10.0).toDouble();
    final updated = Map<int, double>.from(state.answers)..[q.id] = normalized;
    state = state.copyWith(answers: updated);
    await _local.saveAnswer(
      sessionId: state.sessionId!,
      questionId: q.id,
      value: normalized,
    );
  }

  Future<bool> nextQuestion() async {
    await _ensureSession();
    if (state.currentIndex < state.questions.length - 1) {
      final next = state.currentIndex + 1;
      state = state.copyWith(currentIndex: next);
      await _local.updateProgress(
        sessionId: state.sessionId!,
        currentIndex: next,
      );
      return false;
    }
    state = state.copyWith(isCompleted: true);
    await _local.updateProgress(
      sessionId: state.sessionId!,
      currentIndex: state.currentIndex,
      completed: true,
    );
    return true;
  }

  Future<void> completeTest(String openAnswer) async {
    await _ensureSession();
    state = state.copyWith(openAnswer: openAnswer, isCompleted: true);
    await _local.updateProgress(
      sessionId: state.sessionId!,
      currentIndex: state.currentIndex,
      openAnswer: openAnswer,
      completed: true,
    );
  }

  void setOpenAnswer(String answer) {
    state = state.copyWith(openAnswer: answer);
  }

  /// Reinicio explícito: nuevo orden aleatorio.
  Future<void> resetTest() => startNewTestSession();
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>(
  (ref) => TestNotifier(),
);
