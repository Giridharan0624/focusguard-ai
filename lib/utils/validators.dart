import 'constants.dart';

class Validators {
  Validators._();

  static double clampSleep(double value) =>
      value.clamp(kMinSleep, kMaxSleep);

  static double clampWork(double value) =>
      value.clamp(kMinWork, kMaxWork);

  static int clampMood(int value) =>
      value.clamp(kMinMood, kMaxMood);

  static double clampScreenTime(double value) =>
      value.clamp(kMinScreenTime, kMaxScreenTimeInput);

  static int clampCaffeine(int value) =>
      value.clamp(kMinCaffeine, kMaxCaffeineInput);

  static String? validateSleep(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final v = double.tryParse(value);
    if (v == null) return 'Enter a valid number';
    if (v < kMinSleep || v > kMaxSleep) return '${kMinSleep.toInt()}-${kMaxSleep.toInt()} hours';
    return null;
  }

  static String? validateWork(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final v = double.tryParse(value);
    if (v == null) return 'Enter a valid number';
    if (v < kMinWork || v > kMaxWork) return '${kMinWork.toInt()}-${kMaxWork.toInt()} hours';
    return null;
  }

  static String? validateMood(int? value) {
    if (value == null) return 'Required';
    if (value < kMinMood || value > kMaxMood) return '$kMinMood-$kMaxMood';
    return null;
  }

  static String? validateScreenTime(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final v = double.tryParse(value);
    if (v == null) return 'Enter a valid number';
    if (v < kMinScreenTime || v > kMaxScreenTimeInput) return '${kMinScreenTime.toInt()}-${kMaxScreenTimeInput.toInt()} hours';
    return null;
  }

  static String? validateCaffeine(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final v = int.tryParse(value);
    if (v == null) return 'Enter a whole number';
    if (v < kMinCaffeine || v > kMaxCaffeineInput) return '$kMinCaffeine-$kMaxCaffeineInput';
    return null;
  }
}
