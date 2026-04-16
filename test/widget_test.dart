import 'package:flutter_test/flutter_test.dart';

import 'package:focusguard_ai/services/burnout_calculator.dart';
import 'package:focusguard_ai/models/user_input.dart';

void main() {
  final calculator = BurnoutCalculator();

  test('Perfect health produces score 0', () {
    final input = UserInput(
      date: DateTime.now(),
      sleepHours: 8,
      workHours: 0,
      mood: 10,
      screenTime: 0,
      caffeine: 0,
    );
    expect(calculator.calculate(input), 0);
  });

  test('Worst case produces score 100', () {
    final input = UserInput(
      date: DateTime.now(),
      sleepHours: 0,
      workHours: 16,
      mood: 1,
      screenTime: 16,
      caffeine: 10,
    );
    expect(calculator.calculate(input), 100);
  });

  test('Typical day produces moderate score', () {
    final input = UserInput(
      date: DateTime.now(),
      sleepHours: 7,
      workHours: 8,
      mood: 5,
      screenTime: 4,
      caffeine: 2,
    );
    final score = calculator.calculate(input);
    expect(score, greaterThan(15));
    expect(score, lessThan(45));
  });
}
