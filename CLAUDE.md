# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

FocusGuard AI — Flutter app that predicts burnout from daily check-ins (sleep, work, mood, screen time, caffeine) and layers AI insights, recovery plans, a chat coach, and voice/NL input on top. Backend is Firebase (Auth + Firestore); AI is **Groq (Llama 3.3 70B)**, not Gemini (see "Naming gotchas").

Authoritative design docs live at the repo root: [PRD.md](PRD.md) (product), [TDD.md](TDD.md) (technical). Read these before any substantive change — they describe the scoring formula, Firestore schema, fallback strategy, and phasing.

## Commands

```bash
# Run with AI enabled (needs .env with GROQ_API_KEY=gsk_...)
bash run.sh -d <device_id>

# Equivalent manual invocation
flutter run --dart-define=GROQ_API_KEY="$GROQ_API_KEY" -d <device_id>

# Run WITHOUT AI — app still works, AI features silently disable and fall back to rule-based logic
flutter run -d <device_id>

# Release APK
flutter build apk --release --dart-define=GROQ_API_KEY="$GROQ_API_KEY"

# Static analysis (flutter_lints)
flutter analyze

# Tests
flutter test
flutter test test/widget_test.dart -p <plain_name>   # single test

# Dependency refresh
flutter pub get
```

The `GROQ_API_KEY` is read via `const String.fromEnvironment('GROQ_API_KEY')` at [lib/main.dart:53](lib/main.dart#L53). When empty, `geminiService` is `null` and the `ChatViewModel` provider is not registered — guard any new AI-dependent code the same way.

## Architecture

MVVM + Service layer, wired via `provider`. Layer boundaries (see [TDD.md](TDD.md#3-architecture)):

- **views/** — Flutter screens, observe ViewModels via `Consumer`/`Provider.of`.
- **viewmodels/** — `ChangeNotifier` state holders; orchestrate services; no UI, no direct Firestore.
- **services/** — Pure business logic: `BurnoutCalculator`, `CauseAnalyzer`, `PredictionService`, `SimulationService`, `NutritionService`, plus `AuthService`, `GeminiService` (Groq), `VoiceService`.
- **data/** — Firestore repositories (`CheckInRepository`, `NutritionRepository`, `UserRepository`) and `FirestoreService` (refs + food seeding). Only this layer talks to Firestore.
- **models/** — Plain Dart classes with `toMap`/`fromMap`.

Dependency graph is assembled in [lib/main.dart](lib/main.dart) — data layer → services → ViewModels via `MultiProvider`. New ViewModels should be added there, not created ad-hoc in screens.

### Burnout scoring is a single source of truth

`BurnoutCalculator` ([lib/services/burnout_calculator.dart](lib/services/burnout_calculator.dart)) owns the normalized formula (weights: sleep 0.30, work 0.25, mood 0.20, screen 0.15, caffeine 0.10; oversleep penalty >9h; exercise −5 applied in ViewModel). The same instance is reused by `CauseAnalyzer` and `SimulationService` — don't duplicate the math. Full formula in [PRD.md §6.2](PRD.md) and [TDD.md §6.1](TDD.md).

### AI + fallback contract

Every AI method on `GeminiService` returns `null` (or throws, caught by callers) on any failure. ViewModels **must** have a rule-based fallback:

- `generateInsight` → static `_insightFor(topCause)` map
- `generateRecoveryPlan` → `RecommendationService.generate()`
- `generateFoodAdvice` → `FoodRecommendationService`
- `extractCheckinFromText` → user-facing "Try the sliders" snackbar
- Chat failure → inline "Sorry, I couldn't connect" bubble

No AI failure should produce an error dialog — degrade silently. Rate limiter is in-memory sliding window (28 calls / 60s) inside `GeminiService`.

### Firestore schema and AI cache

```
users/{uid}                              profile
users/{uid}/check_ins/{date}             ONE doc per calendar day (doc ID = date, not autoId)
users/{uid}/nutrition_logs/{autoId}
users/{uid}/ai_cache/{docId}             insight_{date}, recovery_{date}, food_{date}_{mealTime}
food_items/{id}                          shared preset DB, auto-seeded
```

Check-in doc ID is the date — re-submitting the same day overwrites, it does not append. Always use `ai_cache/` before hitting Groq to avoid redundant calls. Security rules at [firestore.rules](firestore.rules).

### Food seeding auto-reseed

`FirestoreService.seedFoodItemsIfNeeded()` ([lib/main.dart:36](lib/main.dart#L36)) checks whether the first `food_items` doc has the `unit` field; if not, it deletes and re-seeds from [lib/data/food_data.dart](lib/data/food_data.dart). This is intentional — when you add/change fields on `FoodItem`, bump the detection key so old deployments re-seed cleanly rather than writing a migration.

### Voice

`VoiceService` ([lib/services/voice_service.dart](lib/services/voice_service.dart)) wraps `speech_to_text` — on-device, no network. Used in three places: NL check-in sheet, chat input, nutrition voice-log CTA. **Append mode**: each new result concatenates to the existing text (so users can tap mic multiple times). Requires `RECORD_AUDIO` + `INTERNET` in `AndroidManifest.xml`.

## Naming gotchas

- **`GeminiService` uses Groq, not Gemini.** The class name is preserved for git history after migrating off Gemini due to quota. Endpoint is `api.groq.com/openai/v1/chat/completions`, model `llama-3.3-70b-versatile`. Don't rename — many files reference it.
- "Burnout score" is the internal value (higher = worse). The UI shows **Wellness Score = 100 − burnoutScore** for positive framing. Don't swap these when touching result/dashboard widgets.
- Nutrition `quantity` semantics depend on `FoodItem.unit`: for `"nos"` it's a count; for `"grams"`/`"ml"` it's the absolute amount and must be divided by `servingSize` to get the macro multiplier ([TDD.md §6.2](TDD.md)).

## Theme

Use `AppTheme` accessors — `AppTheme.bg(context)`, `.card(context)`, `.sl(context)`, `.outline(context)`, `.tp(context)`, `.ts(context)`, `.th(context)` — instead of hard-coding colors so light/dark both work. Brand accent `#FBC02D` (amber yellow) is reserved for key CTAs and hero cards only; use colored icon badges (blue/orange/purple/green) for variety. Spacing is on a 4px grid via `AppTheme.spaceN` constants. Cards use `AppTheme.glassCard()`.
