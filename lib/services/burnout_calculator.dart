import 'dart:math';
import '../models/user_input.dart';
import '../utils/constants.dart';

class BurnoutCalculator {
  double calculate(UserInput input) {
    // Sleep score — penalise both deficit and oversleeping
    double sleepScore;
    if (input.sleepHours > kOversleepThreshold) {
      sleepScore =
          ((input.sleepHours - kOversleepThreshold) / kOversleepDivisor) *
              kOversleepMaxPenalty;
    } else {
      final deficit = max(0.0, kOptimalSleep - input.sleepHours);
      sleepScore = (deficit / kMaxSleepDeficit) * 100;
    }

    final workScore =
        (min(input.workHours, kMaxWorkHours) / kMaxWorkHours) * 100;
    final moodScore =
        ((kMaxMood - input.mood) / kMaxMoodDeficit) * 100;
    final meetingScore =
        (min(input.meetings.toDouble(), kMaxMeetings) / kMaxMeetings) * 100;
    final caffeineScore =
        (min(input.caffeine.toDouble(), kMaxCaffeine) / kMaxCaffeine) * 100;

    final raw = (sleepScore * kWeightSleep) +
        (workScore * kWeightWork) +
        (moodScore * kWeightMood) +
        (meetingScore * kWeightMeetings) +
        (caffeineScore * kWeightCaffeine);

    return raw.clamp(0, 100);
  }

  /// Returns the individual weighted component scores (for cause analysis).
  Map<String, double> componentScores(UserInput input) {
    double sleepRaw;
    if (input.sleepHours > kOversleepThreshold) {
      sleepRaw =
          ((input.sleepHours - kOversleepThreshold) / kOversleepDivisor) *
              kOversleepMaxPenalty;
    } else {
      final deficit = max(0.0, kOptimalSleep - input.sleepHours);
      sleepRaw = (deficit / kMaxSleepDeficit) * 100;
    }

    return {
      'Sleep': sleepRaw * kWeightSleep,
      'Work': (min(input.workHours, kMaxWorkHours) / kMaxWorkHours) *
          100 *
          kWeightWork,
      'Mood': ((kMaxMood - input.mood) / kMaxMoodDeficit) *
          100 *
          kWeightMood,
      'Meetings': (min(input.meetings.toDouble(), kMaxMeetings) / kMaxMeetings) *
          100 *
          kWeightMeetings,
      'Caffeine': (min(input.caffeine.toDouble(), kMaxCaffeine) / kMaxCaffeine) *
          100 *
          kWeightCaffeine,
    };
  }
}
