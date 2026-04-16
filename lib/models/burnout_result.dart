import 'suggestion.dart';

class BurnoutResult {
  final double score;
  final String riskLevel;
  final Map<String, double> causes;
  final String topCause;
  final String topCauseInsight;
  final double predictedTomorrow;
  final List<double> threeDay;
  final List<Suggestion> suggestions;
  final double simulatedScore;
  final Map<String, double> simulatedChanges;

  const BurnoutResult({
    required this.score,
    required this.riskLevel,
    required this.causes,
    required this.topCause,
    required this.topCauseInsight,
    required this.predictedTomorrow,
    required this.threeDay,
    required this.suggestions,
    required this.simulatedScore,
    required this.simulatedChanges,
  });
}
