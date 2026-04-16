import '../models/user_input.dart';
import 'burnout_calculator.dart';

class CauseAnalyzer {
  final BurnoutCalculator _calculator;

  CauseAnalyzer(this._calculator);

  /// Returns each factor's percentage contribution to the total score.
  /// All values sum to 100.
  Map<String, double> analyze(UserInput input, double totalScore) {
    if (totalScore == 0) return _defaultCauses();

    final components = _calculator.componentScores(input);
    final sum = components.values.fold<double>(0, (a, b) => a + b);
    if (sum == 0) return _defaultCauses();

    return components.map((key, value) =>
        MapEntry(key, (value / sum) * 100));
  }

  Map<String, double> _defaultCauses() => {
        'Sleep': 20.0,
        'Work': 20.0,
        'Mood': 20.0,
        'Meetings': 20.0,
        'Caffeine': 20.0,
      };
}
