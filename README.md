# FocusGuard AI 🛡️🔥

FocusGuard AI is a premium Flutter mobile application designed to predict, explain, and prevent burnout. By combining behavioral check-ins, macro-based nutrition logs, and state-of-the-art AI analysis, the application acts as a real-time burnout radar, recovery planner, and conversational wellness coach.

---

## 🌟 Key Features

### 1. Burnout Prediction & Analytics
* **Deterministic Risk Scoring (0–100):** Calculates a personalized burnout risk index based on daily sleep, work hours, mood, screen time, and caffeine intake.
* **Oversleep Penalty:** Adjusts sleep scores for hypersomnia ($>9$ hours) to reflect sluggishness and fatigue.
* **Explainable Causes:** Displays factor contributions as clear percentages on a pie chart, pinpointing the exact driver behind a high score.
* **Tomorrow & 3-Day Risk Forecast:** Iteratively predicts future risk levels based on decay formulas and 3-day history trends.
* **Outcome Simulation:** Simulates "what if" scenarios showing potential score reductions if targets (e.g. $\ge 7.5$h sleep, $\le 8$h work) are met.

### 2. AI Integration (Powered by Groq Llama 3.3)
* **Post-Check-In Insights:** Delivers context-aware, 2–3 sentence analysis of today's stats, highlighting trends and a concrete action point.
* **Personalized AI Recovery Plan:** Compiles a custom JSON list of actionable lifestyle tweaks, categorized by priority and expected score reduction.
* **AI Wellness Chat Coach:** Provides conversational, 24/7 empathetic coaching. The coach is supplied with full context, including the user's recent scores and current profiles.
* **Natural Language Check-In:** Allows text descriptions (e.g., *"slept 4 hours, worked all day, feeling exhausted, 5 coffees"*) which are automatically parsed into numeric parameters.
* **AI Food Recommendations:** Recommends meals based on protein/calorie deficits and current profile contexts.
* **AI Cache System:** Stores AI summaries locally under `ai_cache/` in Firestore to optimize network load and speed up responses.

### 3. Smart Nutrition Tracking
* **Macro Counter:** Logs daily Calories, Protein, Carbs, Fat, and water intake.
* **Unit-Based Logging:** Supports gram/ml/nos inputs (e.g., 2 eggs, 200g chicken, 250ml milk) with custom step sizes.
* **Burnout Penalty Banner:** Automatically applies a $+5$ point penalty for Protein deficits and a $+4$ point penalty for Calorie deficits over $50\%$.

### 4. On-Device Voice Controls
* Uses offline-capable speech-to-text systems.
* Supports **Append Mode** (users can build up phrases by tapping the mic multiple times).
* Integrated into three locations: Check-in NL text, Wellness Coach chat, and Nutrition logging (e.g., dictating *"I had 2 eggs and rice"* logs them).

---

## 🛠️ Architecture & Tech Stack

The application strictly implements **MVVM (Model-View-ViewModel) + Service Layer** architecture with **Provider** for Dependency Injection and State Management:

```
lib/
├── models/         # Plain Dart data models (toMap/fromMap serializing)
├── data/           # Repositories & Firestore services (food seeding)
├── services/       # Calculators, prediction algorithms, voice clients, AI wrappers
├── viewmodels/     # ChangeNotifier state machines (no UI references, fully testable)
├── views/          # Glassmorphic M3 UI widgets and screen views
└── theme/          # Custom light/dark themes and styling accessors
```

### Stack Details:
* **UI Framework:** Flutter 3.x (Material 3)
* **State/DI:** Provider
* **Backend:** Firebase (Authentication + Cloud Firestore)
* **AI Engine:** Groq API (`llama-3.3-70b-versatile`)
* **Voice:** Speech-to-text package (On-device engine)
* **Visuals:** FL Chart (for pie and line graphs), Poppins (font)

---

## 🚀 Getting Started

### 1. Prerequisites
* Flutter SDK (3.x recommended)
* Android SDK (API Level 21+) / iOS SDK (iOS 12.0+)
* A configured Firebase project containing security rules for Firestore.

### 2. Configure Environment
Create a `.env` file in the root directory:
```env
GROQ_API_KEY=gsk_your_groq_api_key_here
```

### 3. Run the App

Run with AI capabilities (reads `.env` parameters):
```bash
bash run.sh -d <device_id>
```

Alternative manual execution:
```bash
flutter run --dart-define=GROQ_API_KEY="gsk_your_groq_api_key_here" -d <device_id>
```

#### Run Without AI (Offline/Local Mode):
If no API key is specified, the application automatically disables AI features and degrades to deterministic rule-based algorithms:
```bash
flutter run -d <device_id>
```

---

## 🧪 Testing

Run unit tests (covers formulas, oversleep penalties, prediction models, and cause breakdowns):
```bash
flutter test
```
