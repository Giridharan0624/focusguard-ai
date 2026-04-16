# FocusGuard AI — Technical Design Document

## 1. Overview

This document defines the system architecture, data models, algorithms, and implementation design for FocusGuard AI — a Flutter mobile application for burnout prediction with nutrition tracking.

**Architecture:** MVVM (Model-View-ViewModel) + Service Layer

**Platform:** Android (primary), iOS (secondary)

**Language:** Dart / Flutter

---

## 2. Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.x | Cross-platform UI |
| State Management | Provider | ViewModel binding and reactive updates |
| Authentication | firebase_auth + google_sign_in | User login (email/password + Google) |
| Cloud Database | cloud_firestore | Persistent per-user data storage |
| Firebase Core | firebase_core | Firebase initialization |
| Charts | fl_chart | Pie charts, line charts, gauges |
| Voice (Phase 2) | speech_to_text | Speech-to-text input |
| AI (Phase 2) | OpenAI API | NLP parsing and AI recommendations |
| Analytics (Phase 2) | firebase_analytics | Usage tracking |
| Notifications (Phase 3) | firebase_messaging | Push notifications |

---

## 3. Architecture

### Layer Diagram

```
┌─────────────────────────────────┐
│       Presentation Layer        │
│   (Screens, Widgets, Themes)    │
├─────────────────────────────────┤
│        ViewModel Layer          │
│  (ChangeNotifier + Provider)    │
├─────────────────────────────────┤
│         Service Layer           │
│  (Business Logic, Algorithms)   │
├─────────────────────────────────┤
│          Data Layer             │
│  (Models, Firestore, Repository)│
├─────────────────────────────────┤
│        Firebase Layer           │
│  (Auth, Firestore, Config)      │
└─────────────────────────────────┘
```

### Responsibility Boundaries

- **Presentation:** Renders UI, captures user input, observes ViewModel state. No business logic.
- **ViewModel:** Holds screen state, orchestrates service calls, exposes data to UI via ChangeNotifier.
- **Service:** Pure business logic — scoring, prediction, recommendations, simulation. No UI or storage awareness.
- **Data:** Models, Firestore access, data mapping. Services receive models, not raw Firestore documents.
- **Firebase:** Authentication state management, Firestore instance, security rules enforcement.

---

## 4. Folder Structure

```
lib/
├── main.dart                     # App entry point, Firebase init, Provider setup
├── app.dart                      # MaterialApp, routing, theme, auth gate
│
├── models/
│   ├── user_input.dart           # CheckIn input model
│   ├── user_profile.dart         # User profile model (name, age, occupation)
│   ├── burnout_result.dart       # Score + causes + prediction
│   ├── food_item.dart            # Food database model
│   ├── nutrition_log.dart        # Logged food entry
│   └── nutrition_summary.dart    # Daily nutrition totals + deficits
│
├── services/
│   ├── auth_service.dart         # Firebase Auth wrapper (login, register, Google, logout)
│   ├── burnout_calculator.dart   # Score calculation (normalized formula)
│   ├── cause_analyzer.dart       # Factor contribution breakdown
│   ├── prediction_service.dart   # Tomorrow + 3-day prediction
│   ├── recommendation_service.dart # Recovery plan generation
│   ├── simulation_service.dart   # Outcome simulation
│   ├── nutrition_service.dart    # Nutrition calculation + deficit detection
│   └── food_recommendation_service.dart # Food suggestions
│
├── viewmodels/
│   ├── auth_viewmodel.dart       # Auth state, login/register/logout
│   ├── checkin_viewmodel.dart    # Check-in flow state
│   ├── result_viewmodel.dart     # Results + cause + prediction state
│   └── nutrition_viewmodel.dart  # Nutrition tracking state
│
├── views/
│   ├── auth/
│   │   ├── auth_gate.dart        # StreamBuilder on auth state → login or home
│   │   ├── login_screen.dart     # Email/password login + Google Sign-In
│   │   ├── register_screen.dart  # Email/password registration
│   │   └── profile_setup_screen.dart # First-login profile form
│   ├── home_screen.dart          # Dashboard with bottom nav
│   ├── checkin_screen.dart       # Input form
│   ├── result_screen.dart        # Score display
│   ├── cause_screen.dart         # Cause breakdown charts
│   ├── prediction_screen.dart    # Future risk view
│   ├── recovery_screen.dart      # Suggestions list
│   ├── simulation_screen.dart    # Before/after comparison
│   ├── nutrition_screen.dart     # Food input + summary
│   └── settings_screen.dart      # Profile view, logout, delete account
│
├── widgets/
│   ├── burnout_gauge.dart        # Circular score meter
│   ├── cause_chart.dart          # Pie/bar chart for causes
│   ├── trend_chart.dart          # Line chart for predictions
│   ├── score_card.dart           # Score display card
│   ├── suggestion_tile.dart      # Recovery suggestion item
│   ├── food_grid_item.dart       # Quick-select food tile
│   └── nutrition_progress_bar.dart # Nutrient progress indicator
│
├── data/
│   ├── firestore_service.dart    # Firestore instance + collection refs
│   ├── checkin_repository.dart   # CRUD for check-ins (Firestore)
│   ├── nutrition_repository.dart # CRUD for nutrition logs (Firestore)
│   ├── user_repository.dart      # CRUD for user profiles (Firestore)
│   └── food_data.dart            # Preset food items (seed data / Firestore)
│
├── theme/
│   └── app_theme.dart            # Colors, typography, card styles
│
└── utils/
    ├── constants.dart            # Weights, thresholds, defaults
    └── validators.dart           # Input validation helpers
```

---

## 5. Data Models

### 5.1 UserProfile

```dart
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final String? occupation;    // Student, Developer, Designer, Manager, Freelancer, Other
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.occupation,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Firestore serialization
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'age': age,
    'occupation': occupation,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) => UserProfile(
    uid: uid,
    name: map['name'] as String,
    email: map['email'] as String,
    age: map['age'] as int?,
    occupation: map['occupation'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
```

### 5.2 UserInput (CheckIn)

```dart
class UserInput {
  final String? id;              // Firestore document ID (date string)
  final DateTime date;
  final double sleepHours;       // 0-16
  final double workHours;        // 0-24
  final int mood;                // 1-10
  final int meetings;            // 0-20
  final int caffeine;            // 0-15
  final double? burnoutScore;    // stored alongside input
  final DateTime createdAt;

  UserInput({
    this.id,
    required this.date,
    required this.sleepHours,
    required this.workHours,
    required this.mood,
    required this.meetings,
    required this.caffeine,
    this.burnoutScore,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Firestore serialization
  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String().substring(0, 10),
    'sleep_hours': sleepHours,
    'work_hours': workHours,
    'mood': mood,
    'meetings': meetings,
    'caffeine': caffeine,
    'burnout_score': burnoutScore,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserInput.fromMap(String id, Map<String, dynamic> map) => UserInput(
    id: id,
    date: DateTime.parse(map['date'] as String),
    sleepHours: (map['sleep_hours'] as num).toDouble(),
    workHours: (map['work_hours'] as num).toDouble(),
    mood: map['mood'] as int,
    meetings: map['meetings'] as int,
    caffeine: map['caffeine'] as int,
    burnoutScore: (map['burnout_score'] as num?)?.toDouble(),
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
```

### 5.3 BurnoutResult

```dart
class BurnoutResult {
  final double score;                    // 0-100
  final String riskLevel;                // low, moderate, high, critical
  final Map<String, double> causes;      // factor -> contribution %
  final String topCause;                 // highest contributing factor
  final String topCauseInsight;          // human-readable insight
  final double predictedTomorrow;        // predicted score for tomorrow
  final List<double> threeDay;           // 3-day projection [day1, day2, day3]
  final List<Suggestion> suggestions;    // recovery plan
  final double simulatedScore;           // score after applying fixes
  final Map<String, double> simulatedChanges; // what was adjusted
}
```

### 5.4 SimulationResult

```dart
class SimulationResult {
  final double originalScore;
  final double improvedScore;
  final Map<String, double> changes; // factor -> delta value
}
```

### 5.5 Suggestion

```dart
class Suggestion {
  final String category;          // sleep, work, mood, meetings, caffeine
  final String text;              // actionable suggestion text
  final double expectedReduction; // how many points this would reduce
  final String priority;          // high, medium, low
}
```

### 5.6 FoodItem

```dart
class FoodItem {
  final String id;              // Firestore document ID
  final String name;
  final double servingSize;     // grams per serving
  final double protein;         // grams per serving
  final double calories;        // kcal per serving
  final double carbs;           // grams per serving
  final double fat;             // grams per serving
  final String category;        // protein-rich, energy, balanced, light
  final String icon;            // emoji or asset reference

  FoodItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.protein,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.category,
    required this.icon,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'serving_size': servingSize,
    'protein': protein,
    'calories': calories,
    'carbs': carbs,
    'fat': fat,
    'category': category,
    'icon': icon,
  };

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) => FoodItem(
    id: id,
    name: map['name'] as String,
    servingSize: (map['serving_size'] as num).toDouble(),
    protein: (map['protein'] as num).toDouble(),
    calories: (map['calories'] as num).toDouble(),
    carbs: (map['carbs'] as num).toDouble(),
    fat: (map['fat'] as num).toDouble(),
    category: map['category'] as String,
    icon: map['icon'] as String,
  );
}
```

### 5.7 NutritionLog

```dart
class NutritionLog {
  final String? id;             // Firestore document ID
  final DateTime date;
  final String foodItemId;      // Firestore document ID of food item
  final String foodName;        // denormalized for display
  final double quantity;        // number of servings
  final DateTime createdAt;

  NutritionLog({
    this.id,
    required this.date,
    required this.foodItemId,
    required this.foodName,
    required this.quantity,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String().substring(0, 10),
    'food_item_id': foodItemId,
    'food_name': foodName,
    'quantity': quantity,
    'created_at': createdAt.toIso8601String(),
  };

  factory NutritionLog.fromMap(String id, Map<String, dynamic> map) => NutritionLog(
    id: id,
    date: DateTime.parse(map['date'] as String),
    foodItemId: map['food_item_id'] as String,
    foodName: map['food_name'] as String,
    quantity: (map['quantity'] as num).toDouble(),
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
```

### 5.8 NutritionSummary

```dart
class NutritionSummary {
  final double totalProtein;
  final double totalCalories;
  final double totalCarbs;
  final double totalFat;
  final double proteinGoal;
  final double calorieGoal;
  final double carbGoal;
  final double fatGoal;
  final Map<String, double> deficits;     // nutrient -> deficit amount
  final Map<String, double> deficitPercents; // nutrient -> deficit %
  final double burnoutPenalty;            // penalty applied to burnout score
}
```

---

## 6. Core Algorithms

### 6.1 Burnout Score Calculation

```dart
class BurnoutCalculator {
  // Weights
  static const double wSleep = 0.30;
  static const double wWork = 0.25;
  static const double wMood = 0.25;
  static const double wMeetings = 0.12;
  static const double wCaffeine = 0.08;

  // Max values for normalization
  static const double maxSleepDeficit = 8.0;
  static const double maxWorkHours = 16.0;
  static const double maxMoodDeficit = 9.0;
  static const double maxMeetings = 10.0;
  static const double maxCaffeine = 10.0;

  double calculate(UserInput input) {
    double sleepScore;
    if (input.sleepHours > 9) {
      // Oversleeping penalty: mild fatigue signal (caps at ~30)
      sleepScore = ((input.sleepHours - 9) / 7) * 30;
    } else {
      double sleepDeficit = max(0, 8 - input.sleepHours);
      sleepScore = (sleepDeficit / maxSleepDeficit) * 100;
    }
    double workScore = (min(input.workHours, maxWorkHours) / maxWorkHours) * 100;
    double moodScore = ((10 - input.mood) / maxMoodDeficit) * 100;
    double meetingScore = (min(input.meetings, maxMeetings) / maxMeetings) * 100;
    double caffeineScore = (min(input.caffeine, maxCaffeine) / maxCaffeine) * 100;

    double raw = (sleepScore * wSleep)
               + (workScore * wWork)
               + (moodScore * wMood)
               + (meetingScore * wMeetings)
               + (caffeineScore * wCaffeine);

    return raw.clamp(0, 100);
  }
}
```

### 6.2 Cause Analysis

```dart
class CauseAnalyzer {
  Map<String, double> analyze(UserInput input, double totalScore) {
    if (totalScore == 0) return _defaultCauses();

    double sleepContrib;
    if (input.sleepHours > 9) {
      sleepContrib = ((input.sleepHours - 9) / 7) * 30 * 0.30;
    } else {
      sleepContrib = ((max(0, 8 - input.sleepHours) / 8) * 100 * 0.30);
    }
    double workContrib = ((min(input.workHours, 16) / 16) * 100 * 0.25);
    double moodContrib = (((10 - input.mood) / 9) * 100 * 0.25);
    double meetingContrib = ((min(input.meetings, 10) / 10) * 100 * 0.12);
    double caffeineContrib = ((min(input.caffeine, 10) / 10) * 100 * 0.08);

    double sum = sleepContrib + workContrib + moodContrib
               + meetingContrib + caffeineContrib;

    if (sum == 0) return _defaultCauses(); // safety: avoid division by zero

    return {
      'Sleep': (sleepContrib / sum) * 100,
      'Work': (workContrib / sum) * 100,
      'Mood': (moodContrib / sum) * 100,
      'Meetings': (meetingContrib / sum) * 100,
      'Caffeine': (caffeineContrib / sum) * 100,
    };
  }

  /// Fallback when score is 0 — equal distribution
  Map<String, double> _defaultCauses() => {
    'Sleep': 20.0,
    'Work': 20.0,
    'Mood': 20.0,
    'Meetings': 20.0,
    'Caffeine': 20.0,
  };
}
```

### 6.3 Prediction

```dart
class PredictionService {
  static const double decayFactor = 0.85;

  double predictTomorrow(double currentScore, List<double> history) {
    double trend = _calculateTrend(history);
    return (currentScore * decayFactor + trend).clamp(0, 100);
  }

  List<double> predictThreeDays(double currentScore, List<double> history) {
    List<double> predictions = [];
    double score = currentScore;
    for (int i = 0; i < 3; i++) {
      score = (score * decayFactor + _calculateTrend(history)).clamp(0, 100);
      predictions.add(score);
      history = [...history, score]; // feed predictions back
    }
    return predictions;
  }

  double _calculateTrend(List<double> history) {
    if (history.length < 3) return 3.0; // slight pessimistic bias

    var recent = history.sublist(history.length - 3);
    if (recent[2] > recent[1] && recent[1] > recent[0]) return 8.0;  // trending up
    if (recent[2] < recent[1] && recent[1] < recent[0]) return -5.0; // trending down
    return 3.0; // stable
  }
}
```

### 6.4 Recommendation Engine

```dart
class RecommendationService {
  List<Suggestion> generate(UserInput input, Map<String, double> causes) {
    List<Suggestion> suggestions = [];

    if (input.sleepHours < 4) {
      suggestions.add(Suggestion(
        category: 'sleep',
        text: 'Critical sleep deficit. Prioritize a 20-min nap today.',
        expectedReduction: 15,
        priority: 'high',
      ));
    } else if (input.sleepHours < 6) {
      suggestions.add(Suggestion(
        category: 'sleep',
        text: 'Aim for 7-8 hours tonight. Set a bedtime alarm.',
        expectedReduction: 10,
        priority: 'high',
      ));
    } else if (input.sleepHours > 9) {
      suggestions.add(Suggestion(
        category: 'sleep',
        text: 'Oversleeping can signal fatigue. Try a consistent sleep schedule.',
        expectedReduction: 5,
        priority: 'medium',
      ));
    }

    if (input.workHours > 12) {
      suggestions.add(Suggestion(
        category: 'work',
        text: 'Overwork detected. Block tomorrow for recovery.',
        expectedReduction: 12,
        priority: 'high',
      ));
    } else if (input.workHours > 10) {
      suggestions.add(Suggestion(
        category: 'work',
        text: 'Cap your workday at 8 hours. Delegate or defer tasks.',
        expectedReduction: 8,
        priority: 'medium',
      ));
    }

    if (input.mood < 2) {
      suggestions.add(Suggestion(
        category: 'mood',
        text: 'Consider talking to someone you trust about how you feel.',
        expectedReduction: 8,
        priority: 'high',
      ));
    } else if (input.mood < 4) {
      suggestions.add(Suggestion(
        category: 'mood',
        text: 'Take a 15-minute walk or call a friend.',
        expectedReduction: 6,
        priority: 'medium',
      ));
    }

    if (input.meetings > 8) {
      suggestions.add(Suggestion(
        category: 'meetings',
        text: 'Meeting overload. Block focus time on your calendar.',
        expectedReduction: 5,
        priority: 'medium',
      ));
    } else if (input.meetings > 5) {
      suggestions.add(Suggestion(
        category: 'meetings',
        text: 'Decline or reschedule non-essential meetings.',
        expectedReduction: 4,
        priority: 'low',
      ));
    }

    if (input.caffeine > 8) {
      suggestions.add(Suggestion(
        category: 'caffeine',
        text: 'Excessive caffeine. This may be masking fatigue.',
        expectedReduction: 4,
        priority: 'medium',
      ));
    } else if (input.caffeine > 5) {
      suggestions.add(Suggestion(
        category: 'caffeine',
        text: 'Reduce caffeine gradually. Switch to water after 2 PM.',
        expectedReduction: 3,
        priority: 'low',
      ));
    }

    // Sort by priority (high first) then by expected reduction
    suggestions.sort((a, b) {
      int priorityCompare = _priorityOrder(a.priority)
          .compareTo(_priorityOrder(b.priority));
      if (priorityCompare != 0) return priorityCompare;
      return b.expectedReduction.compareTo(a.expectedReduction);
    });

    return suggestions;
  }

  int _priorityOrder(String p) =>
      {'high': 0, 'medium': 1, 'low': 2}[p] ?? 3;
}
```

### 6.5 Simulation Engine

```dart
class SimulationService {
  // Target "improved" values
  static const double targetSleep = 7.5;
  static const double targetWork = 8.0;
  static const int targetMoodBoost = 2;   // add 2 to current mood
  static const double meetingReduction = 0.5; // reduce by half
  static const int targetCaffeine = 2;

  SimulationResult simulate(UserInput input, BurnoutCalculator calculator) {
    UserInput improved = UserInput(
      date: input.date,
      sleepHours: max(input.sleepHours, targetSleep),
      workHours: min(input.workHours, targetWork),
      mood: min(input.mood + targetMoodBoost, 10),
      meetings: (input.meetings * meetingReduction).round(),
      caffeine: min(input.caffeine, targetCaffeine),
    );

    double originalScore = calculator.calculate(input);
    double improvedScore = calculator.calculate(improved);

    Map<String, double> changes = {};
    if (improved.sleepHours != input.sleepHours)
      changes['Sleep'] = improved.sleepHours - input.sleepHours;
    if (improved.workHours != input.workHours)
      changes['Work'] = improved.workHours - input.workHours;
    if (improved.mood != input.mood)
      changes['Mood'] = (improved.mood - input.mood).toDouble();
    if (improved.meetings != input.meetings)
      changes['Meetings'] = (improved.meetings - input.meetings).toDouble();
    if (improved.caffeine != input.caffeine)
      changes['Caffeine'] = (improved.caffeine - input.caffeine).toDouble();

    return SimulationResult(
      originalScore: originalScore,
      improvedScore: improvedScore,
      changes: changes,
    );
  }
}
```

### 6.6 Nutrition Service

```dart
class NutritionService {
  static const double defaultProteinGoal = 60;
  static const double defaultCalorieGoal = 2000;
  static const double defaultCarbGoal = 250;
  static const double defaultFatGoal = 65;

  NutritionSummary summarize(List<NutritionLog> logs, List<FoodItem> foods) {
    double totalProtein = 0, totalCalories = 0, totalCarbs = 0, totalFat = 0;

    for (var log in logs) {
      var food = foods.firstWhere((f) => f.id == log.foodItemId);
      totalProtein += food.protein * log.quantity;
      totalCalories += food.calories * log.quantity;
      totalCarbs += food.carbs * log.quantity;
      totalFat += food.fat * log.quantity;
    }

    Map<String, double> deficits = {
      'protein': max(0, defaultProteinGoal - totalProtein),
      'calories': max(0, defaultCalorieGoal - totalCalories),
      'carbs': max(0, defaultCarbGoal - totalCarbs),
      'fat': max(0, defaultFatGoal - totalFat),
    };

    Map<String, double> deficitPercents = {
      'protein': (deficits['protein']! / defaultProteinGoal) * 100,
      'calories': (deficits['calories']! / defaultCalorieGoal) * 100,
      'carbs': (deficits['carbs']! / defaultCarbGoal) * 100,
      'fat': (deficits['fat']! / defaultFatGoal) * 100,
    };

    double penalty = 0;
    if (deficitPercents['protein']! > 50) penalty += 5;
    if (deficitPercents['calories']! > 50) penalty += 4;

    return NutritionSummary(
      totalProtein: totalProtein,
      totalCalories: totalCalories,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      proteinGoal: defaultProteinGoal,
      calorieGoal: defaultCalorieGoal,
      carbGoal: defaultCarbGoal,
      fatGoal: defaultFatGoal,
      deficits: deficits,
      deficitPercents: deficitPercents,
      burnoutPenalty: penalty,
    );
  }
}
```

### 6.7 Auth Service

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of auth state changes (used by AuthGate)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Register with email and password
  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Delete account (requires recent authentication)
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
```

### 6.8 Food Recommendation Service

```dart
class FoodRecommendationService {
  List<FoodItem> recommend(NutritionSummary summary, List<FoodItem> allFoods) {
    // Find the nutrient with the largest deficit percentage
    String worstNutrient = summary.deficitPercents.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;

    // Map nutrient to food category
    String targetCategory = {
      'protein': 'protein-rich',
      'calories': 'energy',
      'carbs': 'energy',
      'fat': 'balanced',
    }[worstNutrient] ?? 'balanced';

    // Filter and sort by nutrient density
    var filtered = allFoods.where((f) => f.category == targetCategory).toList();

    filtered.sort((a, b) {
      double aDensity = _nutrientDensity(a, worstNutrient);
      double bDensity = _nutrientDensity(b, worstNutrient);
      return bDensity.compareTo(aDensity);
    });

    return filtered.take(5).toList();
  }

  double _nutrientDensity(FoodItem food, String nutrient) {
    switch (nutrient) {
      case 'protein': return food.protein / food.servingSize * 100;
      case 'calories': return food.calories / food.servingSize * 100;
      case 'carbs': return food.carbs / food.servingSize * 100;
      case 'fat': return food.fat / food.servingSize * 100;
      default: return 0;
    }
  }
}
```

---

## 7. Firestore Schema

### Collection Structure

```
firestore-root/
├── users/
│   └── {uid}/                          # Document: user profile
│       ├── name: string
│       ├── email: string
│       ├── age: number | null
│       ├── occupation: string | null
│       ├── created_at: string (ISO 8601)
│       ├── updated_at: string (ISO 8601)
│       │
│       ├── check_ins/                  # Subcollection
│       │   └── {date}/                 # Document ID = "2026-04-16"
│       │       ├── date: string
│       │       ├── sleep_hours: number
│       │       ├── work_hours: number
│       │       ├── mood: number
│       │       ├── meetings: number
│       │       ├── caffeine: number
│       │       ├── burnout_score: number
│       │       └── created_at: string
│       │
│       └── nutrition_logs/             # Subcollection
│           └── {autoId}/              # Auto-generated document ID
│               ├── date: string
│               ├── food_item_id: string
│               ├── food_name: string
│               ├── quantity: number
│               └── created_at: string
│
└── food_items/                         # Top-level shared collection
    └── {id}/
        ├── name: string
        ├── serving_size: number
        ├── protein: number
        ├── calories: number
        ├── carbs: number
        ├── fat: number
        ├── category: string
        └── icon: string
```

### Firestore Service

```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reference to the current user's document
  DocumentReference userDoc(String uid) => _db.collection('users').doc(uid);

  /// Reference to a user's check-ins subcollection
  CollectionReference checkIns(String uid) =>
      userDoc(uid).collection('check_ins');

  /// Reference to a user's nutrition logs subcollection
  CollectionReference nutritionLogs(String uid) =>
      userDoc(uid).collection('nutrition_logs');

  /// Reference to the shared food items collection
  CollectionReference get foodItems => _db.collection('food_items');
}
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User profiles: only the owner can read/write
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      // Check-ins subcollection
      match /check_ins/{date} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }

      // Nutrition logs subcollection
      match /nutrition_logs/{logId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    // Food items: read-only for authenticated users
    match /food_items/{itemId} {
      allow read: if request.auth != null;
      allow write: if false; // admin-only via Firebase console or script
    }
  }
}
```

### Firestore Indexes

Composite indexes needed (create in Firebase console or `firestore.indexes.json`):

| Collection | Fields | Purpose |
|------------|--------|---------|
| `users/{uid}/check_ins` | `date DESC` | History screen sorted by date |
| `users/{uid}/nutrition_logs` | `date ASC, created_at ASC` | Today's logs query |

### Date Format Convention

All dates stored as ISO 8601 strings:
- **date field:** `"2026-04-16"` (date-only, for grouping by day)
- **created_at field:** `"2026-04-16T14:30:00.000"` (full timestamp)
- **Check-in document ID** uses the date string as its ID for natural upsert behavior
- Day comparison: compare `date` field string equality (no time component)

---

## 8. Repository Layer

### UserRepository

```dart
class UserRepository {
  final FirestoreService _firestore;

  UserRepository(this._firestore);

  /// Get user profile
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.userDoc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(uid, doc.data() as Map<String, dynamic>);
  }

  /// Create or update user profile
  Future<void> saveProfile(UserProfile profile) async {
    await _firestore.userDoc(profile.uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  /// Delete user profile and all subcollections
  Future<void> deleteAccount(String uid) async {
    // Delete check-ins subcollection
    final checkIns = await _firestore.checkIns(uid).get();
    for (var doc in checkIns.docs) {
      await doc.reference.delete();
    }
    // Delete nutrition logs subcollection
    final logs = await _firestore.nutritionLogs(uid).get();
    for (var doc in logs.docs) {
      await doc.reference.delete();
    }
    // Delete user document
    await _firestore.userDoc(uid).delete();
  }
}
```

### CheckInRepository

```dart
class CheckInRepository {
  final FirestoreService _firestore;

  CheckInRepository(this._firestore);

  /// Save or update today's check-in (upsert by date as document ID)
  Future<void> save(String uid, UserInput input, double burnoutScore) async {
    final dateStr = input.date.toIso8601String().substring(0, 10);

    await _firestore.checkIns(uid).doc(dateStr).set({
      ...input.toMap(),
      'burnout_score': burnoutScore,
    });
  }

  /// Get the most recent N scores for trend/prediction
  Future<List<double>> getRecentScores(String uid, int count) async {
    final snapshot = await _firestore.checkIns(uid)
        .orderBy('date', descending: true)
        .limit(count)
        .get();

    return snapshot.docs
        .map((doc) => ((doc.data() as Map)['burnout_score'] as num).toDouble())
        .toList()
        .reversed
        .toList(); // oldest first
  }

  /// Get today's check-in (if any)
  Future<UserInput?> getToday(String uid) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final doc = await _firestore.checkIns(uid).doc(today).get();
    if (!doc.exists) return null;
    return UserInput.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// Get all check-ins for history screen (newest first)
  Future<List<UserInput>> getAll(String uid) async {
    final snapshot = await _firestore.checkIns(uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UserInput.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Delete all check-ins for a user
  Future<void> clearAll(String uid) async {
    final snapshot = await _firestore.checkIns(uid).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
```

### NutritionRepository

```dart
class NutritionRepository {
  final FirestoreService _firestore;

  NutritionRepository(this._firestore);

  /// Get all food items from shared collection
  Future<List<FoodItem>> getAllFoodItems() async {
    final snapshot = await _firestore.foodItems.get();
    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get today's nutrition logs for a user
  Future<List<NutritionLog>> getTodayLogs(String uid) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final snapshot = await _firestore.nutritionLogs(uid)
        .where('date', isEqualTo: today)
        .orderBy('created_at')
        .get();

    return snapshot.docs
        .map((doc) => NutritionLog.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Save a nutrition log entry
  Future<void> saveLog(String uid, NutritionLog log) async {
    await _firestore.nutritionLogs(uid).add(log.toMap());
  }

  /// Delete a nutrition log entry
  Future<void> deleteLog(String uid, String logId) async {
    await _firestore.nutritionLogs(uid).doc(logId).delete();
  }
}
```

---

## 9. Preset Food Data

25 curated food items for MVP:

| Name | Serving (g) | Protein | Calories | Carbs | Fat | Category |
|------|-------------|---------|----------|-------|-----|----------|
| Boiled Egg | 50 | 6 | 78 | 1 | 5 | protein-rich |
| Grilled Chicken Breast | 150 | 31 | 165 | 0 | 4 | protein-rich |
| Paneer (Cottage Cheese) | 100 | 18 | 265 | 1 | 21 | protein-rich |
| Dal (Lentils) | 200 | 13 | 180 | 30 | 1 | protein-rich |
| Greek Yogurt | 150 | 15 | 100 | 6 | 1 | protein-rich |
| White Rice | 200 | 4 | 260 | 58 | 0 | energy |
| Chapati/Roti | 40 | 3 | 104 | 18 | 3 | energy |
| Banana | 120 | 1 | 105 | 27 | 0 | energy |
| Oats (cooked) | 200 | 5 | 150 | 27 | 3 | energy |
| Peanut Butter (2 tbsp) | 32 | 8 | 190 | 6 | 16 | energy |
| Mixed Vegetable Curry | 200 | 4 | 120 | 15 | 5 | balanced |
| Chicken Curry | 200 | 20 | 240 | 8 | 14 | balanced |
| Egg Fried Rice | 250 | 10 | 320 | 45 | 10 | balanced |
| Idli (2 pieces) | 100 | 4 | 130 | 26 | 1 | balanced |
| Dosa | 80 | 3 | 120 | 20 | 3 | balanced |
| Sprouts Salad | 150 | 9 | 80 | 12 | 1 | light |
| Green Salad | 200 | 2 | 35 | 7 | 0 | light |
| Clear Soup | 250 | 3 | 50 | 5 | 2 | light |
| Grilled Fish | 150 | 26 | 140 | 0 | 3 | protein-rich |
| Steamed Vegetables | 200 | 3 | 60 | 10 | 1 | light |
| Milk (1 glass) | 250 | 8 | 150 | 12 | 8 | balanced |
| Apple | 150 | 0 | 78 | 21 | 0 | light |
| Almonds (handful) | 30 | 6 | 170 | 6 | 15 | protein-rich |
| Curd/Yogurt | 200 | 6 | 120 | 8 | 6 | balanced |
| Poha (Flattened Rice) | 200 | 5 | 250 | 45 | 5 | energy |

---

## 10. Data Flow

### Auth Flow

```
App launches
  → Firebase.initializeApp()
  → AuthGate listens to AuthService.authStateChanges
  → If not authenticated → LoginScreen
      → User enters email/password or taps Google Sign-In
      → AuthService.signInWithEmail() or signInWithGoogle()
      → On success → AuthGate detects auth state change
  → If authenticated → Check UserRepository.getProfile(uid)
      → If no profile → ProfileSetupScreen
          → User fills name, age, occupation
          → UserRepository.saveProfile(profile)
      → If profile exists → HomeScreen (Dashboard)
```

### Check-In Flow

```
User taps "Start Check-In"
  → CheckInScreen renders input form
  → User fills sliders/fields, taps Submit
  → CheckInViewModel.submit(input)
      → Get uid from AuthService.currentUser
      → BurnoutCalculator.calculate(input) → score
      → CauseAnalyzer.analyze(input, score) → causes
      → PredictionService.predictTomorrow(score, history) → prediction
      → PredictionService.predictThreeDays(score, history) → threeDay
      → RecommendationService.generate(input, causes) → suggestions
      → SimulationService.simulate(input, calculator) → simulation
      → NutritionService.getBurnoutPenalty() → penalty
      → adjustedScore = clamp(score + penalty, 0, 100)
      → CheckInRepository.save(uid, input, adjustedScore) → Firestore
      → Build BurnoutResult, notify listeners
  → Navigate to ResultScreen
  → UI renders gauge, causes, predictions, suggestions
```

### Nutrition Flow

```
User opens Nutrition Screen
  → NutritionViewModel loads today's logs + food items
      → NutritionRepository.getTodayLogs(uid) → from Firestore
      → NutritionRepository.getAllFoodItems() → from Firestore
  → User selects food items, sets quantities
  → NutritionViewModel.addFood(foodId, quantity)
      → NutritionRepository.saveLog(uid, log) → to Firestore
      → NutritionService.summarize(logs, foods) → summary
      → If deficits detected:
          → FoodRecommendationService.recommend(summary, foods)
      → Notify listeners
  → UI updates daily totals, progress bars, deficit alerts
```

---

## 11. ViewModel Design

### AuthViewModel

```dart
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  bool isLoading = false;
  String? errorMessage;
  UserProfile? userProfile;

  AuthViewModel({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository;

  /// Current authenticated user's UID
  String? get uid => _authService.currentUser?.uid;

  /// Stream of auth state for AuthGate
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Register with email/password
  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmail(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e.code);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email/password
  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e.code);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Google sign-in failed. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Save user profile after first login
  Future<void> saveProfile(String name, int? age, String? occupation) async {
    final user = _authService.currentUser!;
    userProfile = UserProfile(
      uid: user.uid,
      name: name,
      email: user.email!,
      age: age,
      occupation: occupation,
    );
    await _userRepository.saveProfile(userProfile!);
    notifyListeners();
  }

  /// Load existing profile
  Future<bool> loadProfile() async {
    if (uid == null) return false;
    userProfile = await _userRepository.getProfile(uid!);
    notifyListeners();
    return userProfile != null;
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    userProfile = null;
    notifyListeners();
  }

  /// Delete account and all data
  Future<void> deleteAccount() async {
    if (uid != null) {
      await _userRepository.deleteAccount(uid!);
      await _authService.deleteAccount();
      userProfile = null;
      notifyListeners();
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      default: return 'Authentication failed. Please try again.';
    }
  }
}
```

### CheckInViewModel

```dart
class CheckInViewModel extends ChangeNotifier {
  // Input state
  double sleepHours = 7;
  double workHours = 8;
  int mood = 5;
  int meetings = 2;
  int caffeine = 2;

  // Result state
  BurnoutResult? result;
  bool isLoading = false;
  String? errorMessage;

  // Services (injected via constructor)
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

  /// Fill demo data for hackathon presentation
  void loadDemoData() {
    sleepHours = 4;
    workHours = 12;
    mood = 3;
    meetings = 7;
    caffeine = 6;
    notifyListeners();
  }

  Future<void> submit() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uid = _authService.currentUser!.uid;

      var input = UserInput(
        date: DateTime.now(),
        sleepHours: sleepHours,
        workHours: workHours,
        mood: mood,
        meetings: meetings,
        caffeine: caffeine,
      );

      double score = _calculator.calculate(input);
      var causes = _causeAnalyzer.analyze(input, score);
      var history = await _repository.getRecentScores(uid, 7);
      double tomorrow = _predictionService.predictTomorrow(score, history);
      var threeDay = _predictionService.predictThreeDays(score, history);
      var suggestions = _recommendationService.generate(input, causes);
      var simulation = _simulationService.simulate(input, _calculator);

      await _repository.save(uid, input, score);

      result = BurnoutResult(
        score: score,
        riskLevel: _riskLevel(score),
        causes: causes,
        topCause: _topCause(causes),
        topCauseInsight: _insightFor(_topCause(causes)),
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

  String _riskLevel(double score) {
    if (score <= 25) return 'low';
    if (score <= 50) return 'moderate';
    if (score <= 75) return 'high';
    return 'critical';
  }

  /// Returns the factor with the highest contribution percentage
  String _topCause(Map<String, double> causes) {
    return causes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Returns a human-readable insight for the top contributing factor
  String _insightFor(String cause) {
    const insights = {
      'Sleep': 'Sleep deficit is your biggest burnout driver today.',
      'Work': 'Long work hours are pushing your burnout risk up.',
      'Mood': 'Low mood is a major factor in your burnout score.',
      'Meetings': 'Too many meetings are draining your energy.',
      'Caffeine': 'High caffeine intake suggests you\'re compensating for fatigue.',
    };
    return insights[cause] ?? 'Multiple factors are contributing to your burnout.';
  }
}
```

### NutritionViewModel

```dart
class NutritionViewModel extends ChangeNotifier {
  List<FoodItem> foodItems = [];
  List<NutritionLog> todayLogs = [];
  NutritionSummary? summary;
  List<FoodItem> recommendations = [];

  final AuthService _authService;
  final NutritionService _nutritionService;
  final FoodRecommendationService _foodRecommendationService;
  final NutritionRepository _repository;

  NutritionViewModel({
    required AuthService authService,
    required NutritionService nutritionService,
    required FoodRecommendationService foodRecommendationService,
    required NutritionRepository repository,
  })  : _authService = authService,
        _nutritionService = nutritionService,
        _foodRecommendationService = foodRecommendationService,
        _repository = repository;

  String get _uid => _authService.currentUser!.uid;

  Future<void> loadToday() async {
    foodItems = await _repository.getAllFoodItems();
    todayLogs = await _repository.getTodayLogs(_uid);
    _recalculate();
  }

  Future<void> addFood(String foodItemId, String foodName, double quantity) async {
    var log = NutritionLog(
      date: DateTime.now(),
      foodItemId: foodItemId,
      foodName: foodName,
      quantity: quantity,
    );
    await _repository.saveLog(_uid, log);
    todayLogs = await _repository.getTodayLogs(_uid);
    _recalculate();
  }

  Future<void> deleteFood(String logId) async {
    await _repository.deleteLog(_uid, logId);
    todayLogs = await _repository.getTodayLogs(_uid);
    _recalculate();
  }

  void _recalculate() {
    summary = _nutritionService.summarize(todayLogs, foodItems);
    recommendations = _foodRecommendationService.recommend(summary!, foodItems);
    notifyListeners();
  }
}
```

---

## 12. Dependency Injection & Provider Setup

### Service Instantiation

Firebase is initialized before any other setup. All services are created once at app startup and injected into ViewModels via constructor parameters.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create core services
  final authService = AuthService();
  final firestoreService = FirestoreService();

  // Create repositories (Firestore-backed)
  final userRepo = UserRepository(firestoreService);
  final checkinRepo = CheckInRepository(firestoreService);
  final nutritionRepo = NutritionRepository(firestoreService);

  // Create business logic services (stateless, no dependencies on each other)
  final calculator = BurnoutCalculator();
  final causeAnalyzer = CauseAnalyzer();
  final predictionService = PredictionService();
  final recommendationService = RecommendationService();
  final simulationService = SimulationService();
  final nutritionService = NutritionService();
  final foodRecommendationService = FoodRecommendationService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authService: authService,
            userRepository: userRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckInViewModel(
            authService: authService,
            calculator: calculator,
            causeAnalyzer: causeAnalyzer,
            predictionService: predictionService,
            recommendationService: recommendationService,
            simulationService: simulationService,
            repository: checkinRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionViewModel(
            authService: authService,
            nutritionService: nutritionService,
            foodRecommendationService: foodRecommendationService,
            repository: nutritionRepo,
          ),
        ),
      ],
      child: const FocusGuardApp(),
    ),
  );
}
```

### Firebase Configuration

Firebase is configured using the FlutterFire CLI (`flutterfire configure`), which generates:
- `lib/firebase_options.dart` — platform-specific Firebase config
- `google-services.json` (Android) — placed in `android/app/`
- `GoogleService-Info.plist` (iOS) — placed in `ios/Runner/`

These files are auto-generated and should be added to `.gitignore` if the project is open-source.

---

## 13. Navigation

### Strategy: Auth Gate + Named Routes

The app root uses an `AuthGate` widget that listens to Firebase Auth state and routes to either the login flow or the main app.

```dart
class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusGuard AI',
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}
```

### Auth Gate

```dart
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: authVm.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not authenticated → show login
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        // Authenticated → check if profile exists
        return FutureBuilder<bool>(
          future: authVm.loadProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // No profile yet → show profile setup
            if (authVm.userProfile == null) {
              return const ProfileSetupScreen();
            }

            // Fully authenticated with profile → main app
            return const HomeScreen();
          },
        );
      },
    );
  }
}
```

### Bottom Navigation

HomeScreen uses a `Scaffold` with `BottomNavigationBar` and an `IndexedStack` to switch between 4 tabs: Dashboard, Check-In, Nutrition, History. The `IndexedStack` preserves state across tab switches.

```dart
class HomeScreen extends StatefulWidget { ... }

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardView(),    // Tab 0: Home/Dashboard
    CheckInScreen(),    // Tab 1: Check-In
    NutritionScreen(),  // Tab 2: Nutrition
    HistoryScreen(),    // Tab 3: History
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Check-In'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
```

---

## 14. UI Rendering Specifications

### Burnout Gauge
- Custom painter: circular arc from 0-270 degrees
- Color gradient: green → yellow → orange → red
- Center text: score number (large, bold) + risk label (small, below)
- Animated: score animates from 0 to final value over 800ms

### Cause Chart
- Pie chart (fl_chart PieChart) with 5 segments
- Each segment: factor color + percentage label
- Legend below chart with factor names
- Tap segment to highlight and show insight text

### Trend Chart
- Line chart (fl_chart LineChart) for 3-day prediction
- X-axis: today, +1, +2, +3
- Y-axis: 0-100
- Today's point uses actual score; future points use predictions
- Color-coded line segments by risk level

### Nutrition Progress Bars
- Horizontal progress bars for each nutrient
- Fill color: green (>70% of goal), yellow (40-70%), red (<40%)
- Label: "45g / 60g protein" format

---

## 15. Theme & Color System

### Dark Theme Definition

```dart
class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF6C63FF);       // Purple accent
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color background = Color(0xFF121212);     // Dark background
  static const Color surface = Color(0xFF1E1E2C);        // Card background
  static const Color surfaceLight = Color(0xFF2A2A3C);   // Elevated surface

  // Risk Level Colors
  static const Color riskLow = Color(0xFF4CAF50);        // Green
  static const Color riskModerate = Color(0xFFFFC107);   // Yellow/Amber
  static const Color riskHigh = Color(0xFFFF9800);       // Orange
  static const Color riskCritical = Color(0xFFF44336);   // Red

  // Cause Chart Colors (one per factor)
  static const Color colorSleep = Color(0xFF42A5F5);     // Blue
  static const Color colorWork = Color(0xFFEF5350);      // Red
  static const Color colorMood = Color(0xFFAB47BC);      // Purple
  static const Color colorMeetings = Color(0xFFFFA726);  // Orange
  static const Color colorCaffeine = Color(0xFF66BB6A);  // Green

  // Nutrition Progress Colors
  static const Color nutrientGood = Color(0xFF4CAF50);   // >70% of goal
  static const Color nutrientWarning = Color(0xFFFFC107); // 40-70%
  static const Color nutrientLow = Color(0xFFF44336);    // <40%

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    cardColor: surface,
    fontFamily: 'Poppins', // or system default
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textHint,
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  /// Returns the color for a given risk level
  static Color riskColor(String level) {
    switch (level) {
      case 'low': return riskLow;
      case 'moderate': return riskModerate;
      case 'high': return riskHigh;
      case 'critical': return riskCritical;
      default: return riskModerate;
    }
  }
}
```

---

## 16. Error Handling

| Scenario | Handling |
|----------|----------|
| Invalid input values | Clamp to valid range, show inline validation error |
| No check-in history | Use fallback prediction (+3 flat adjustment) |
| Empty nutrition logs | Show "No meals logged yet" state |
| Firestore read failure | Show error snackbar, retry with offline cache |
| Division by zero (causes) | Return equal 20% distribution |
| Score out of range | Clamp to 0-100 |
| Auth: invalid email | Show inline validation "Please enter a valid email" |
| Auth: wrong password | Show "Incorrect password" error |
| Auth: email already in use | Show "Account already exists" error |
| Auth: weak password | Show "Password must be at least 6 characters" |
| Auth: network error | Show "No internet connection. Please try again." |
| Auth: Google sign-in cancelled | Silent dismiss, no error shown |
| Auth: token expired | Firebase Auth handles refresh automatically |
| No internet (offline) | Firestore offline persistence serves cached data |

---

## 17. Testing Strategy

### Unit Tests (Priority)

| Test | What It Validates |
|------|-------------------|
| BurnoutCalculator with ideal inputs (sleep=8, work=0, mood=10, meetings=0, caffeine=0) | Score = 0 |
| BurnoutCalculator with worst inputs (sleep=0, work=16, mood=1, meetings=10, caffeine=10) | Score = 100 |
| BurnoutCalculator with typical inputs (sleep=7, work=8, mood=5, meetings=2, caffeine=2) | Score in 20-40 range |
| BurnoutCalculator with oversleeping (sleep=12) | Score > 0 on sleep component |
| CauseAnalyzer percentages | Sum to 100% |
| CauseAnalyzer with score = 0 | Returns equal 20% distribution |
| PredictionService with no history | Falls back to +3 adjustment |
| PredictionService with trending up [40, 50, 60] | Returns +8 trend |
| PredictionService with trending down [60, 50, 40] | Returns -5 trend |
| SimulationService | Improved score < original score |
| SimulationService with already-good values | No unnecessary changes |
| NutritionService deficit detection | Correct deficit calculation |
| NutritionService burnout penalty | +5 for protein deficit >50%, +4 for calorie deficit >50% |
| FoodRecommendationService | Returns foods matching deficit category |
| UserInput.toMap / fromMap | Round-trip Firestore serialization preserves all fields |
| UserProfile.toMap / fromMap | Round-trip Firestore serialization preserves all fields |
| NutritionLog.toMap / fromMap | Round-trip Firestore serialization preserves all fields |
| AuthViewModel.register | Creates account, returns true |
| AuthViewModel.signIn | Signs in, returns true |
| AuthViewModel._mapAuthError | Maps all Firebase error codes to user-friendly messages |
| AuthViewModel.signOut | Clears profile, signs out |

### Manual Testing (Demo)

- **Auth flow:** Register → profile setup → dashboard
- **Auth flow:** Login with existing account → dashboard
- **Auth flow:** Google Sign-In → profile setup (first time) → dashboard
- **Auth flow:** Logout → returns to login screen
- Complete check-in flow end-to-end (data saved to Firestore)
- Verify gauge animation and colors
- Test with extreme values (0 sleep, 24 work)
- Test nutrition flow: add foods, see deficit, get recommendations
- Navigate all screens without crashes
- **Offline mode:** Turn off network, verify app still works with cached data
- **Multi-device:** Login on second device, verify data syncs

---

## 18. Performance Considerations

- All calculations are O(1) — pure arithmetic, no network calls
- Firestore queries use indexed fields (`date`) for fast history lookups
- Firestore offline persistence caches data locally for instant reads
- Provider rebuilds scoped to specific widgets using Consumer/Selector
- Food item list is small (25 items) — no pagination needed
- Chart rendering uses fl_chart's built-in optimization
- Auth state is streamed via `authStateChanges` — no polling

---

## 19. Deployment

- **Build target:** Android APK (debug + release)
- **Min SDK:** Android API 21 (Android 5.0)
- **Firebase setup:**
  - Create Firebase project via Firebase Console
  - Run `flutterfire configure` to generate platform config files
  - Enable Email/Password and Google Sign-In in Firebase Console → Authentication → Sign-in method
  - Create Firestore database in production mode with security rules from Section 7
  - Seed `food_items` collection with 25 preset entries (one-time script or manual via Firebase Console)
- **Demo mode:** App ships with pre-seeded food data in Firestore; demo account can be pre-created for hackathon
- **Test data:** Include a "Demo" button on home screen that fills check-in with sample values for quick demo during hackathon presentation

### Required Flutter Packages

```yaml
dependencies:
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x
  google_sign_in: ^6.x.x
  provider: ^6.x.x
  fl_chart: ^0.x.x
```
