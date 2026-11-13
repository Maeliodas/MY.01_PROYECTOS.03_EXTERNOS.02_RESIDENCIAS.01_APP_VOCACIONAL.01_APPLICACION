import 'dart:math';

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

  Future<void> _initialize() async {
    try {
      final questions = await _questions.getActiveQuestions();
      final persisted = await _local.loadActiveSession();
      if (persisted == null) {
        final randomized = List<Question>.from(questions)
          ..shuffle(Random.secure());
        state = TestState(
          currentIndex: 0,
          questions: randomized,
          answers: const {},
          openAnswer: '',
          isCompleted: false,
          restored: true,
        );
        return;
      }
      final byId = {for (final question in questions) question.id: question};
      final restoredQuestions = persisted.questionOrder
          .map((id) => byId[id])
          .whereType<Question>()
          .toList();
      // Se conserva el orden conocido salvo que esté vacío (p. ej. sesión sin
      // orden); en caso contrario se usa tal cual en vez de barajar, así el
      // usuario continúa donde lo dejó.
      List<Question> orderedQuestions;
      if (restoredQuestions.isEmpty) {
        orderedQuestions = List<Question>.from(questions)
          ..shuffle(Random.secure());
      } else {
        orderedQuestions = restoredQuestions;
      }
      // Un currentIndex igual a la cantidad de preguntas significa "ya se
      // avanzó más allá de las preguntas regulares" y debe conservarse; con
      // clamp solo se recorta el valor cuando queda fuera de rango.
      final maxIndex = orderedQuestions.length;
      state = TestState(
        sessionId: persisted.id,
        currentIndex: persisted.currentIndex.clamp(0, maxIndex).toInt(),
        questions: orderedQuestions,
        answers: persisted.answers,
        openAnswer: persisted.openAnswer,
        isCompleted: persisted.completed,
        restored: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        restored: true,
        error: 'No se pudo cargar la prueba: $e',
      );
    }
  }

  Future<void> startNewTestSession() async {
    final sourceQuestions = await _questions.getActiveQuestions();
    final questions = List<Question>.from(sourceQuestions)
      ..shuffle(Random.secure());
    await _local.clearCurrentProgress();
    final id = _uuid.v4();
    await _local.createSession(
      sessionId: id,
      questionOrder: questions.map((q) => q.id).toList(),
    );
    state = TestState(
      sessionId: id,
      currentIndex: 0,
      questions: questions,
      answers: const {},
      openAnswer: '',
      isCompleted: false,
      restored: true,
    );
  }

  Future<void> _ensureSession() async {
    if (state.sessionId != null) return;
    await startNewTestSession();
  }

  Future<void> answerQuestion(double value) async {
    await _ensureSession();
    if (state.questions.isEmpty) return;
    final q = state.questions[state.currentIndex.clamp(0, state.questions.length - 1).toInt()];
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
    // El usuario ya contestó la última pregunta regular: se marca la
    // posición final (una posición más allá de la lista) para que, al
    // reanudar, se continúe con la pregunta abierta en lugar de volver
    // al último reactivo. `isCompleted` solo se define cuando el usuario
    // responde la pregunta abierta (`completeTest`).
    state = state.copyWith(currentIndex: state.questions.length);
    await _local.updateProgress(
      sessionId: state.sessionId!,
      currentIndex: state.questions.length,
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

  Future<void> saveCareerOpenAnswer(String careerId, String questionText, String answer) async {
    await _ensureSession();
    await _local.saveCareerOpenAnswer(sessionId: state.sessionId!, careerId: careerId, questionText: questionText, answer: answer);
  }

  Future<void> resetTest() => startNewTestSession();
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>(
  (ref) => TestNotifier(),
);
