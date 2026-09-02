class TestSession {
  final String id;
  final DateTime startedAt;
  final List<String> questionOrder;
  final int currentIndex;
  final String status;
  const TestSession({
    required this.id,
    required this.startedAt,
    required this.questionOrder,
    required this.currentIndex,
    required this.status,
  });
}
