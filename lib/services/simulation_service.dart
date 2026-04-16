import 'dart:math';
import '../models/simulation_result.dart';
import '../models/user_input.dart';
import '../utils/constants.dart';
import 'burnout_calculator.dart';

class SimulationService {
  final BurnoutCalculator _calculator;

  SimulationService(this._calculator);

  SimulationResult simulate(UserInput input) {
    final improved = input.copyWith(
      sleepHours: max(input.sleepHours, kSimTargetSleep),
      workHours: min(input.workHours, kSimTargetWork),
      mood: min(input.mood + kSimMoodBoost, kMaxMood),
      meetings: (input.meetings * kSimMeetingReduction).round(),
      caffeine: min(input.caffeine, kSimTargetCaffeine),
    );

    final originalScore = _calculator.calculate(input);
    final improvedScore = _calculator.calculate(improved);

    final changes = <String, double>{};
    if (improved.sleepHours != input.sleepHours) {
      changes['Sleep'] = improved.sleepHours - input.sleepHours;
    }
    if (improved.workHours != input.workHours) {
      changes['Work'] = improved.workHours - input.workHours;
    }
    if (improved.mood != input.mood) {
      changes['Mood'] = (improved.mood - input.mood).toDouble();
    }
    if (improved.meetings != input.meetings) {
      changes['Meetings'] = (improved.meetings - input.meetings).toDouble();
    }
    if (improved.caffeine != input.caffeine) {
      changes['Caffeine'] = (improved.caffeine - input.caffeine).toDouble();
    }

    return SimulationResult(
      originalScore: originalScore,
      improvedScore: improvedScore,
      changes: changes,
    );
  }
}
