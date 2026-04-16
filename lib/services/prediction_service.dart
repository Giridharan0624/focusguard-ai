import '../utils/constants.dart';

class PredictionService {
  double predictTomorrow(double currentScore, List<double> history) {
    final trend = _calculateTrend(history);
    return (currentScore * kDecayFactor + trend).clamp(0, 100);
  }

  List<double> predictThreeDays(double currentScore, List<double> history) {
    final predictions = <double>[];
    var score = currentScore;
    var h = List<double>.from(history);

    for (var i = 0; i < kPredictionDays; i++) {
      score = (score * kDecayFactor + _calculateTrend(h)).clamp(0, 100);
      predictions.add(score);
      h = [...h, score];
    }
    return predictions;
  }

  double _calculateTrend(List<double> history) {
    if (history.length < kTrendWindowSize) return kTrendStable;

    final recent = history.sublist(history.length - kTrendWindowSize);
    if (recent[2] > recent[1] && recent[1] > recent[0]) return kTrendUp;
    if (recent[2] < recent[1] && recent[1] < recent[0]) return kTrendDown;
    return kTrendStable;
  }
}
