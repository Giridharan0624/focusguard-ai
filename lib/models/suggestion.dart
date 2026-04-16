class Suggestion {
  final String category;
  final String text;
  final double expectedReduction;
  final String priority;

  const Suggestion({
    required this.category,
    required this.text,
    required this.expectedReduction,
    required this.priority,
  });
}
