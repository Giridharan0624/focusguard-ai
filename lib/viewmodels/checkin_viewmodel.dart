import 'package:flutter/foundation.dart';
import '../data/checkin_repository.dart';
import '../models/burnout_result.dart';
import '../models/user_input.dart';
import '../services/auth_service.dart';
import '../services/burnout_calculator.dart';
import '../services/cause_analyzer.dart';
import '../services/prediction_service.dart';
import '../services/recommendation_service.dart';
import '../services/simulation_service.dart';
import '../utils/constants.dart';

class CheckInViewModel extends ChangeNotifier {
  // ── Input state ──
  double _sleepHours = kDefaultSleep;
  double _workHours = kDefaultWorkHours;
  int _mood = kDefaultMood;
  double _screenTime = kDefaultScreenTime;
  int _caffeine = kDefaultCaffeine;
  bool _exercised = false;

  double get sleepHours => _sleepHours;
  set sleepHours(double v) { _sleepHours = v; notifyListeners(); }

  double get workHours => _workHours;
  set workHours(double v) { _workHours = v; notifyListeners(); }

  int get mood => _mood;
  set mood(int v) { _mood = v; notifyListeners(); }

  double get screenTime => _screenTime;
  set screenTime(double v) { _screenTime = v; notifyListeners(); }

  int get caffeine => _caffeine;
  set caffeine(int v) { _caffeine = v; notifyListeners(); }

  bool get exercised => _exercised;
  set exercised(bool v) { _exercised = v; notifyListeners(); }

  // ── Result state ──
  BurnoutResult? result;
  bool isLoading = false;
  String? errorMessage;

  // ── Dependencies ──
  final AuthService _authService;
  final BurnoutCalculator _calculator;
  final CauseAnalyzer _causeAnalyzer;
  final PredictionService _predictionService;
  final RecommendationService _recommendationService;
  final SimulationService _simulationService;
  final CheckInRepository _repository;

  CheckInViewModel({
    required AuthService authService,
    required BurnoutCalculator calculator,
    required CauseAnalyzer causeAnalyzer,
    required PredictionService predictionService,
    required RecommendationService recommendationService,
    required SimulationService simulationService,
    required CheckInRepository repository,
  })  : _authService = authService,
        _calculator = calculator,
        _causeAnalyzer = causeAnalyzer,
        _predictionService = predictionService,
        _recommendationService = recommendationService,
        _simulationService = simulationService,
        _repository = repository;

  // ── Live score preview (pure computation, no side effects) ──
  double get liveScore {
    final input = UserInput(
      date: DateTime.now(),
      sleepHours: _sleepHours,
      workHours: _workHours,
      mood: _mood,
      screenTime: _screenTime,
      caffeine: _caffeine,
    );
    var score = _calculator.calculate(input);
    if (_exercised) score = (score - 5).clamp(0, 100);
    return score;
  }

  // ── Presets ──
  void loadPreset(String preset) {
    switch (preset) {
      case 'student':
        _sleepHours = 6; _workHours = 10; _mood = 5;
        _screenTime = 10; _caffeine = 3;
        break;
      case 'work':
        _sleepHours = 7; _workHours = 9; _mood = 6;
        _screenTime = 7; _caffeine = 3;
        break;
      case 'rest':
        _sleepHours = 9; _workHours = 1; _mood = 8;
        _screenTime = 3; _caffeine = 1; _exercised = true;
        break;
    }
    notifyListeners();
  }

  // ── Demo ──
  void loadDemoData() {
    _sleepHours = kDemoSleep;
    _workHours = kDemoWork;
    _mood = kDemoMood;
    _screenTime = kDemoScreenTime;
    _caffeine = kDemoCaffeine;
    notifyListeners();
  }

  void resetToDefaults() {
    _sleepHours = kDefaultSleep;
    _workHours = kDefaultWorkHours;
    _mood = kDefaultMood;
    _screenTime = kDefaultScreenTime;
    _caffeine = kDefaultCaffeine;
    _exercised = false;
    result = null;
    errorMessage = null;
    notifyListeners();
  }

  // ── Submit ──
  Future<void> submit() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uid = _authService.uid;
      final input = _buildInput();

      var score = _calculator.calculate(input);
      if (_exercised) score = (score - 5).clamp(0, 100);

      final causes = _causeAnalyzer.analyze(input, score);
      final history =
          await _repository.getRecentScores(uid, kHistoryLookback);
      final tomorrow = _predictionService.predictTomorrow(score, history);
      final threeDay = _predictionService.predictThreeDays(score, history);
      final suggestions = _recommendationService.generate(input, causes);
      final simulation = _simulationService.simulate(input);

      await _repository.save(uid, input, score);

      final topCause = _topCause(causes);

      result = BurnoutResult(
        score: score,
        riskLevel: riskLevel(score),
        causes: causes,
        topCause: topCause,
        topCauseInsight: _insightFor(topCause),
        predictedTomorrow: tomorrow,
        threeDay: threeDay,
        suggestions: suggestions,
        simulatedScore: simulation.improvedScore,
        simulatedChanges: simulation.changes,
      );
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  // ── Helpers ──
  UserInput _buildInput() => UserInput(
        date: DateTime.now(),
        sleepHours: _sleepHours,
        workHours: _workHours,
        mood: _mood,
        screenTime: _screenTime,
        caffeine: _caffeine,
      );

  static String riskLevel(double score) {
    if (score <= kRiskLowMax) return kRiskLow;
    if (score <= kRiskModerateMax) return kRiskModerate;
    if (score <= kRiskHighMax) return kRiskHigh;
    return kRiskCritical;
  }

  static String riskLabel(String level) {
    switch (level) {
      case kRiskLow:
        return "You're doing great";
      case kRiskModerate:
        return 'Watch out';
      case kRiskHigh:
        return 'Take action';
      case kRiskCritical:
        return 'Burnout alert';
      default:
        return '';
    }
  }

  String _topCause(Map<String, double> causes) =>
      causes.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  String _insightFor(String cause) {
    const insights = {
      'Sleep': 'Sleep deficit is your biggest burnout driver today.',
      'Work': 'Long work hours are pushing your burnout risk up.',
      'Mood': 'Low mood is a major factor in your burnout score.',
      'Screen Time': 'Too much screen time is straining your energy.',
      'Caffeine':
          "High caffeine intake suggests you're compensating for fatigue.",
    };
    return insights[cause] ??
        'Multiple factors are contributing to your burnout.';
  }
}
