import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/questions_data.dart';
import '../../domain/models/question.dart';

class TestState {
  final int currentIndex;
  final List<Question> questions;
  final Map<int, double> answers;
  final String openAnswer;
  final bool isCompleted;
  final bool restored;

  const TestState({required this.currentIndex, required this.questions, required this.answers, required this.openAnswer, required this.isCompleted, this.restored = false});

  TestState copyWith({int? currentIndex, List<Question>? questions, Map<int, double>? answers, String? openAnswer, bool? isCompleted, bool? restored}) => TestState(
    currentIndex: currentIndex ?? this.currentIndex,
    questions: questions ?? this.questions,
    answers: answers ?? this.answers,
    openAnswer: openAnswer ?? this.openAnswer,
    isCompleted: isCompleted ?? this.isCompleted,
    restored: restored ?? this.restored,
  );

  double get progress => questions.isEmpty
      ? 0.0
      : ((currentIndex + 1) / questions.length).clamp(0.0, 1.0).toDouble();
}

class TestNotifier extends StateNotifier<TestState> {
  static const _indexKey = 'aevum_test_index';
  static const _answersKey = 'aevum_test_answers';
  static const _completedKey = 'aevum_test_completed';
  static const _openAnswerKey = 'aevum_test_open_answer';

  TestNotifier() : super(const TestState(currentIndex: 0, questions: QuestionsData.questions, answers: {}, openAnswer: '', isCompleted: false)) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_answersKey);
    final restoredAnswers = <int, double>{};
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final id = int.tryParse(entry.key);
        final value = (entry.value as num?)?.toDouble();
        if (id != null && value != null) restoredAnswers[id] = value;
      }
    }
    final index = (prefs.getInt(_indexKey) ?? 0)
        .clamp(0, QuestionsData.questions.length - 1)
        .toInt();
    state = TestState(
      currentIndex: index,
      questions: QuestionsData.questions,
      answers: restoredAnswers,
      openAnswer: prefs.getString(_openAnswerKey) ?? '',
      isCompleted: prefs.getBool(_completedKey) ?? false,
      restored: true,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_indexKey, state.currentIndex);
    await prefs.setString(_answersKey, jsonEncode(state.answers.map((k, v) => MapEntry(k.toString(), v))));
    await prefs.setBool(_completedKey, state.isCompleted);
    await prefs.setString(_openAnswerKey, state.openAnswer);
  }

  Future<void> startNewTestSession() async {
    state = const TestState(currentIndex: 0, questions: QuestionsData.questions, answers: {}, openAnswer: '', isCompleted: false, restored: true);
    await _persist();
  }

  Future<void> answerQuestion(double value) async {
    final q = state.questions[state.currentIndex];
    final updated = Map<int, double>.from(state.answers)
      ..[q.id] = value.clamp(0.0, 10.0).toDouble();
    state = state.copyWith(answers: updated);
    await _persist();
  }

  Future<bool> nextQuestion() async {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      await _persist();
      return false;
    }
    state = state.copyWith(isCompleted: true);
    await _persist();
    return true;
  }

  Future<void> completeTest(String openAnswer) async {
    state = state.copyWith(openAnswer: openAnswer, isCompleted: true);
    await _persist();
  }

  void setOpenAnswer(String answer) => state = state.copyWith(openAnswer: answer);

  Future<void> resetTest() => startNewTestSession();
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) => TestNotifier());
