import 'dart:convert';

class TestSession {
  final String id;
  final String userId;
  final String status; // 'in_progress', 'completed'
  final List<int> questionOrder;
  final int currentIndex;
  final String? openQuestionAnswer;
  final DateTime createdAt;

  TestSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.questionOrder,
    required this.currentIndex,
    this.openQuestionAnswer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'question_order': jsonEncode(questionOrder),
      'current_index': currentIndex,
      'open_question_answer': openQuestionAnswer,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TestSession.fromMap(Map<String, dynamic> map) {
    return TestSession(
      id: map['id'],
      userId: map['user_id'],
      status: map['status'],
      questionOrder: List<int>.from(jsonDecode(map['question_order'])),
      currentIndex: map['current_index'],
      openQuestionAnswer: map['open_question_answer'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
