import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'data/firestore_service.dart';
import 'data/checkin_repository.dart';
import 'data/nutrition_repository.dart';
import 'data/user_repository.dart';
import 'services/auth_service.dart';
import 'services/burnout_calculator.dart';
import 'services/cause_analyzer.dart';
import 'services/prediction_service.dart';
import 'services/recommendation_service.dart';
import 'services/simulation_service.dart';
import 'services/nutrition_service.dart';
import 'services/food_recommendation_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/checkin_viewmodel.dart';
import 'viewmodels/nutrition_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Data layer ──
  final firestoreService = FirestoreService();

  // Seed food items in background — don't block app startup
  firestoreService.seedFoodItemsIfNeeded().catchError((_) {});

  final userRepo = UserRepository(firestoreService);
  final checkinRepo = CheckInRepository(firestoreService);
  final nutritionRepo = NutritionRepository(firestoreService);

  // ── Services ──
  final authService = AuthService();
  final calculator = BurnoutCalculator();
  final causeAnalyzer = CauseAnalyzer(calculator);
  final predictionService = PredictionService();
  final recommendationService = RecommendationService();
  final simulationService = SimulationService(calculator);
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
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(
            authService: authService,
            repository: checkinRepo,
          ),
        ),
      ],
      child: const FocusGuardApp(),
    ),
  );
}
