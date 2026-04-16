import '../models/suggestion.dart';
import '../models/user_input.dart';
import '../utils/constants.dart';

class RecommendationService {
  List<Suggestion> generate(UserInput input, Map<String, double> causes) {
    final suggestions = <Suggestion>[];

    // ── Sleep ──
    if (input.sleepHours < 4) {
      suggestions.add(const Suggestion(
        category: 'sleep',
        text: 'Critical sleep deficit. Prioritize a 20-min nap today.',
        expectedReduction: 15,
        priority: 'high',
      ));
    } else if (input.sleepHours < 6) {
      suggestions.add(const Suggestion(
        category: 'sleep',
        text: 'Aim for 7-8 hours tonight. Set a bedtime alarm.',
        expectedReduction: 10,
        priority: 'high',
      ));
    } else if (input.sleepHours > kOversleepThreshold) {
      suggestions.add(const Suggestion(
        category: 'sleep',
        text: 'Oversleeping can signal fatigue. Try a consistent sleep schedule.',
        expectedReduction: 5,
        priority: 'medium',
      ));
    }

    // ── Work ──
    if (input.workHours > 12) {
      suggestions.add(const Suggestion(
        category: 'work',
        text: 'Overwork detected. Block tomorrow for recovery.',
        expectedReduction: 12,
        priority: 'high',
      ));
    } else if (input.workHours > 10) {
      suggestions.add(const Suggestion(
        category: 'work',
        text: 'Cap your workday at 8 hours. Delegate or defer tasks.',
        expectedReduction: 8,
        priority: 'medium',
      ));
    }

    // ── Mood ──
    if (input.mood < 2) {
      suggestions.add(const Suggestion(
        category: 'mood',
        text: 'Consider talking to someone you trust about how you feel.',
        expectedReduction: 8,
        priority: 'high',
      ));
    } else if (input.mood < 4) {
      suggestions.add(const Suggestion(
        category: 'mood',
        text: 'Take a 15-minute walk or call a friend.',
        expectedReduction: 6,
        priority: 'medium',
      ));
    }

    // ── Meetings ──
    if (input.meetings > 8) {
      suggestions.add(const Suggestion(
        category: 'meetings',
        text: 'Meeting overload. Block focus time on your calendar.',
        expectedReduction: 5,
        priority: 'medium',
      ));
    } else if (input.meetings > 5) {
      suggestions.add(const Suggestion(
        category: 'meetings',
        text: 'Decline or reschedule non-essential meetings.',
        expectedReduction: 4,
        priority: 'low',
      ));
    }

    // ── Caffeine ──
    if (input.caffeine > 8) {
      suggestions.add(const Suggestion(
        category: 'caffeine',
        text: 'Excessive caffeine. This may be masking fatigue.',
        expectedReduction: 4,
        priority: 'medium',
      ));
    } else if (input.caffeine > 5) {
      suggestions.add(const Suggestion(
        category: 'caffeine',
        text: 'Reduce caffeine gradually. Switch to water after 2 PM.',
        expectedReduction: 3,
        priority: 'low',
      ));
    }

    suggestions.sort((a, b) {
      final pc = _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority));
      if (pc != 0) return pc;
      return b.expectedReduction.compareTo(a.expectedReduction);
    });

    return suggestions;
  }

  int _priorityOrder(String p) =>
      const {'high': 0, 'medium': 1, 'low': 2}[p] ?? 3;
}
