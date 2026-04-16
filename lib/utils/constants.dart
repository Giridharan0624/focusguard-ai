// ── Burnout Formula Weights ──
const double kWeightSleep = 0.30;
const double kWeightWork = 0.25;
const double kWeightMood = 0.25;
const double kWeightMeetings = 0.12;
const double kWeightCaffeine = 0.08;

// ── Normalization Caps ──
const double kMaxSleepDeficit = 8.0;
const double kMaxWorkHours = 16.0;
const double kMaxMoodDeficit = 9.0;
const double kMaxMeetings = 10.0;
const double kMaxCaffeine = 10.0;

// ── Optimal Sleep Range ──
const double kOptimalSleep = 8.0;
const double kOversleepThreshold = 9.0;
const double kOversleepMaxPenalty = 30.0;
const double kOversleepDivisor = 7.0;

// ── Input Defaults ──
const double kDefaultSleep = 7.0;
const double kDefaultWorkHours = 8.0;
const int kDefaultMood = 5;
const int kDefaultMeetings = 2;
const int kDefaultCaffeine = 2;

// ── Input Ranges ──
const double kMinSleep = 0;
const double kMaxSleep = 16;
const double kMinWork = 0;
const double kMaxWork = 24;
const int kMinMood = 1;
const int kMaxMood = 10;
const int kMinMeetings = 0;
const int kMaxMeetingsInput = 20;
const int kMinCaffeine = 0;
const int kMaxCaffeineInput = 15;

// ── Risk Level Thresholds ──
const double kRiskLowMax = 25;
const double kRiskModerateMax = 50;
const double kRiskHighMax = 75;

// ── Prediction Constants ──
const double kDecayFactor = 0.85;
const double kTrendUp = 8.0;
const double kTrendDown = -5.0;
const double kTrendStable = 3.0;
const int kTrendWindowSize = 3;
const int kPredictionDays = 3;
const int kHistoryLookback = 7;

// ── Simulation Targets ──
const double kSimTargetSleep = 7.5;
const double kSimTargetWork = 8.0;
const int kSimMoodBoost = 2;
const double kSimMeetingReduction = 0.5;
const int kSimTargetCaffeine = 2;

// ── Nutrition Goals ──
const double kDefaultProteinGoal = 60;
const double kDefaultCalorieGoal = 2000;
const double kDefaultCarbGoal = 250;
const double kDefaultFatGoal = 65;

// ── Nutrition Penalty ──
const double kProteinDeficitThreshold = 50;
const double kCalorieDeficitThreshold = 50;
const double kProteinPenalty = 5;
const double kCaloriePenalty = 4;

// ── Demo Data ──
const double kDemoSleep = 4;
const double kDemoWork = 12;
const int kDemoMood = 3;
const int kDemoMeetings = 7;
const int kDemoCaffeine = 6;

// ── Risk Level Labels ──
const String kRiskLow = 'low';
const String kRiskModerate = 'moderate';
const String kRiskHigh = 'high';
const String kRiskCritical = 'critical';

// ── Firestore Collections ──
const String kCollectionCheckins = 'check_ins';
const String kCollectionNutritionLogs = 'nutrition_logs';
const String kCollectionFoodItems = 'food_items';
