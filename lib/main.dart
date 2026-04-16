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
import 'services/gemini_service.dart';
import 'services/prediction_service.dart';
import 'services/recommendation_service.dart';
import 'services/simulation_service.dart';
import 'services/nutrition_service.dart';
import 'services/food_recommendation_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/checkin_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/nutrition_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'services/voice_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Data layer ──
  final firestoreService = FirestoreService();
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

  // ── AI Service (Groq) ──
  const groqKey = String.fromEnvironment('GROQ_API_KEY');
  final geminiService =
      groqKey.isNotEmpty ? GeminiService(apiKey: groqKey) : null;

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
            geminiService: geminiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionViewModel(
            authService: authService,
            nutritionService: nutritionService,
            foodRecommendationService: foodRecommendationService,
            repository: nutritionRepo,
            firestoreService: firestoreService,
            geminiService: geminiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(
            authService: authService,
            repository: checkinRepo,
          ),
        ),
        if (geminiService != null)
          ChangeNotifierProvider(
            create: (_) => ChatViewModel(
              geminiService: geminiService,
              authService: authService,
              repository: checkinRepo,
            ),
          ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) {
          final voice = VoiceService();
          voice.initialize();
          return voice;
        }),
      ],
      child: const FocusGuardApp(),
    ),
  );
}
