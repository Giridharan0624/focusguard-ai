# FocusGuard AI — Product Requirements Document

## 1. Product Overview

FocusGuard AI is a mobile application that predicts, explains, and prevents burnout using behavioral and nutritional inputs with intelligent analysis.

It acts as a real-time burnout radar, recovery planner, and nutrition advisor — helping users understand *why* they feel burned out and *what* to do about it.

### What Makes It Different

- Predicts future burnout risk, not just tracks current state
- Identifies root causes with percentage contribution
- Suggests actionable interventions with expected outcomes
- Links nutrition to burnout through a unified scoring model
- Simulates recovery scenarios so users can see projected improvement

---

## 2. Problem Statement

Users experience burnout due to poor sleep, high workload, emotional stress, meeting overload, and poor nutrition. Existing wellness apps track data but do not:

- Predict burnout before it happens
- Explain which factors are driving risk
- Provide actionable, personalized recovery plans
- Connect nutrition deficits to fatigue and burnout
- Simulate outcomes of behavioral changes

---

## 3. Objectives

1. Enable a quick daily check-in (manual input + voice input)
2. Generate an accurate burnout risk score (0-100)
3. Provide explainable cause breakdown with contribution percentages
4. Predict burnout risk for the next 1-3 days
5. Suggest actionable recovery plans
6. Simulate improved outcomes after applying fixes
7. Track nutrition intake and detect deficits
8. Recommend food combinations aligned with burnout prevention

---

## 4. Target Users

**Primary:** Students, developers, and working professionals who face daily cognitive load and are at risk of burnout.

**Secondary:** Freelancers and founders managing irregular schedules and high stress.

### User Personas

**Priya (Student, 21)**
- Studies 10+ hours daily during exam season
- Skips meals, survives on coffee
- Wants to know when to take breaks before crashing

**Rahul (Developer, 28)**
- Back-to-back meetings, codes at night to compensate
- Sleeps 4-5 hours, mood drops by midweek
- Wants data-driven proof that he needs to push back on meetings

**Aisha (Freelancer, 32)**
- Irregular schedule, no clear work-life boundary
- Forgets to eat balanced meals while deep in work
- Wants nutrition nudges and burnout early-warnings

### User Stories

| # | As a... | I want to... | So that... |
|---|---------|-------------|-----------|
| 1 | User | Log my daily sleep, work, mood, meetings, and caffeine in under 30 seconds | I can track my state without friction |
| 2 | User | See a burnout risk score immediately after check-in | I know how I'm doing today |
| 3 | User | See which factor is hurting me the most | I know what to fix first |
| 4 | User | See my predicted burnout for tomorrow | I can take preventive action |
| 5 | User | Get specific recovery suggestions | I don't have to figure out solutions myself |
| 6 | User | Simulate what happens if I follow the suggestions | I feel motivated to make changes |
| 7 | User | Log my food intake quickly | I can track nutrition without overhead |
| 8 | User | See if I'm low on protein or calories | I know what to eat next |
| 9 | User | Get food recommendations for my deficits | I don't have to think about what to eat |
| 10 | User | See how nutrition affects my burnout score | I understand the full picture |
| 11 | User | Use a demo mode during presentation | I can showcase the app quickly at the hackathon |
| 12 | User | Create an account and log in | My data is saved and accessible across devices |
| 13 | User | Sign in with Google | I can get started quickly without creating a password |
| 14 | User | See my data persist after reinstalling | I don't lose my history when switching phones |
| 15 | User | Delete my account and data | I have control over my personal information |

---

## 5. Product Scope & Phasing

### Phase 1 — MVP (Hackathon Target)

- Onboarding splash screen (app name + tagline, skip to dashboard)
- **Firebase Authentication** (email/password + Google Sign-In)
- **User profile setup** (name, age, occupation — stored in Firestore)
- Manual check-in input screen
- Burnout score calculation with normalized formula
- Cause analysis with contribution breakdown
- Tomorrow prediction
- Recovery suggestions (rule-based)
- Outcome simulation (before/after comparison)
- **Check-in history synced to Cloud Firestore** (per-user, real-time)
- Basic nutrition input (quick-select from preset foods)
- Nutrition deficit detection
- Simple food recommendations
- **Nutrition logs stored in Cloud Firestore** (per-user)
- Demo mode button (pre-fills check-in with sample data for hackathon demo)
- Bottom navigation bar (Dashboard, Check-In, Nutrition, History)
- **Logout / account management in settings**

### Phase 2 — AI Integration

- Voice input via speech-to-text
- AI-based natural language parsing for food and check-in inputs
- AI-generated personalized recommendations (OpenAI API)
- Budget-based food suggestions
- Food combination generator
- Firebase Analytics for usage insights

### Phase 3 — Advanced

- Trend analytics with weekly/monthly charts
- Push notifications via **Firebase Cloud Messaging (FCM)**
- Personalization based on user history
- Wearable integration
- Camera-based food recognition
- **Multi-device sync** (data already in Firestore)

---

## 6. Core Features

### 6.1 Daily Check-In

Users submit a daily check-in with the following inputs:

| Input | Type | Range | Description |
|-------|------|-------|-------------|
| Sleep Hours | Numeric (decimal) | 0-16 | Hours of sleep last night |
| Work Hours | Numeric (decimal) | 0-24 | Hours worked today |
| Mood | Slider (integer) | 1-10 | Self-reported mood (1 = worst, 10 = best) |
| Meetings | Numeric (integer) | 0-20 | Number of meetings today |
| Caffeine | Numeric (integer) | 0-15 | Cups of coffee/tea consumed |

**Validation Rules:**
- All fields are required
- Values must fall within specified ranges
- Default values: sleep=7, workHours=8, mood=5, meetings=2, caffeine=2

**Multiple Check-Ins Per Day:**
- Only one check-in per calendar day is stored
- If the user submits a second check-in on the same day, it overwrites the previous one
- The latest check-in for today is always shown on the dashboard

---

### 6.2 Burnout Risk Score

**Score Range:** 0-100 (0 = no risk, 100 = extreme burnout)

**Normalized Formula:**

```
sleepDeficit = max(0, 8 - sleep)
sleepScore = (sleepDeficit / 8) * 100

// Oversleeping penalty: sleeping > 9 hours adds a mild fatigue signal
if sleep > 9:
  sleepScore = ((sleep - 9) / 7) * 30   // caps at ~30 for 16h sleep

workScore = (workHours / 16) * 100

moodScore = ((10 - mood) / 9) * 100

meetingScore = (meetings / 10) * 100

caffeineScore = (caffeine / 10) * 100

burnoutScore = (sleepScore * 0.30)
             + (workScore  * 0.25)
             + (moodScore  * 0.25)
             + (meetingScore * 0.12)
             + (caffeineScore * 0.08)

finalScore = clamp(burnoutScore, 0, 100)
```

**Note on Oversleeping:** Sleeping > 9 hours is often a sign of fatigue or depression. Instead of treating it as zero deficit, the formula applies a mild penalty (up to 30 points on the sleep component) to surface this as a concern.

**Weight Rationale:**
- Sleep (30%): Sleep deficit is the strongest burnout predictor
- Work (25%): Excessive work hours directly correlate with exhaustion
- Mood (25%): Low mood is both a cause and symptom of burnout
- Meetings (12%): Context-switching and meeting overload drain energy
- Caffeine (8%): High caffeine signals compensating for fatigue

**Risk Levels:**

| Score | Level | Color | Label |
|-------|-------|-------|-------|
| 0-25 | Low | Green | You're doing great |
| 26-50 | Moderate | Yellow | Watch out |
| 51-75 | High | Orange | Take action |
| 76-100 | Critical | Red | Burnout alert |

---

### 6.3 Cause Analysis

Displays each factor's contribution as a percentage of the total score:

```
factorContribution = (factorScore * factorWeight) / burnoutScore * 100
```

Displayed as a pie/bar chart showing which factors are driving risk. The top contributing factor is highlighted with a specific insight message.

**Example output:**
- Sleep deficit: 42%
- Work hours: 28%
- Low mood: 18%
- Meetings: 8%
- Caffeine: 4%
- Top cause: "Sleep deficit is your biggest burnout driver today"

---

### 6.4 Future Prediction

**Tomorrow Prediction:**

```
predictedScore = currentScore * decayFactor + trendAdjustment

decayFactor = 0.85 (assumes partial recovery overnight)

trendAdjustment:
  - If last 3 scores trending up: +8
  - If last 3 scores trending down: -5
  - If no history or stable: +3 (slight pessimistic bias for safety)
```

**3-Day Projection:**
Apply the prediction formula iteratively for 3 days, each using the previous day's predicted score as input.

If no history exists (first check-in), use only the current score with a flat +3 adjustment for tomorrow (slight pessimistic bias to encourage action).

---

### 6.5 Recovery Plan

Rule-based suggestions triggered by factor thresholds:

| Condition | Suggestion | Expected Reduction |
|-----------|------------|--------------------|
| Sleep < 4 hours | "Critical sleep deficit. Prioritize a 20-min nap today." | -15 points |
| Sleep < 6 hours | "Aim for 7-8 hours tonight. Set a bedtime alarm." | -10 points |
| Sleep > 9 hours | "Oversleeping can signal fatigue. Try a consistent sleep schedule." | -5 points |
| Work > 12 hours | "Overwork detected. Block tomorrow's calendar for recovery." | -12 points |
| Work > 10 hours | "Cap your workday at 8 hours. Delegate or defer tasks." | -8 points |
| Mood < 2 | "Consider talking to someone you trust about how you feel." | -8 points |
| Mood < 4 | "Take a 15-minute walk or call a friend." | -6 points |
| Meetings > 8 | "Meeting overload. Block focus time on your calendar." | -5 points |
| Meetings > 5 | "Decline or reschedule non-essential meetings." | -4 points |
| Caffeine > 8 | "Excessive caffeine. This may be masking fatigue." | -4 points |
| Caffeine > 5 | "Reduce caffeine gradually. Switch to water after 2 PM." | -3 points |
| Protein deficit > 50% | "Low protein may cause fatigue. Try eggs or dal." | -3 points |
| Calorie deficit > 50% | "Undereating can crash your energy. Have a balanced meal." | -2 points |

---

### 6.6 Outcome Simulation

When the user taps "Fix It", the system:

1. Identifies the top 2-3 contributing factors
2. Applies optimistic but realistic improvements:
   - Sleep: set to 7.5 hours
   - Work: set to 8 hours
   - Mood: increase by 2 (capped at 10)
   - Meetings: reduce by half
   - Caffeine: set to 2 cups
3. Recalculates the burnout score with improved values
4. Displays before/after comparison

**Example:**
- Current Score: 78 (Critical)
- Simulated Score: 38 (Moderate)
- Key Change: "Getting 7.5 hours of sleep would reduce your score by 24 points"

---

### 6.7 Nutrition Tracking (MVP Scope)

**Quick-Select Food Input:**
A curated list of 25 common food items with pre-defined nutritional values per standard serving:

Each food item includes:
- Name
- Default serving size (grams)
- Protein (g)
- Calories (kcal)
- Carbohydrates (g)
- Fat (g)
- Category (protein-rich, energy, balanced, light)

**Daily Nutrition Summary:**
- Total protein, calories, carbs, fat consumed
- Progress bars against daily goals

**Daily Goals (defaults, user-adjustable):**

| Nutrient | Default Goal |
|----------|-------------|
| Protein | 60g |
| Calories | 2000 kcal |
| Carbohydrates | 250g |
| Fat | 65g |

---

### 6.8 Nutrition Deficit Detection

```
deficit = max(0, dailyGoal - totalConsumed)
deficitPercent = (deficit / dailyGoal) * 100
```

**Alert thresholds:**
- Deficit > 50%: "You're significantly low on {nutrient} today"
- Deficit > 30%: "Consider adding more {nutrient} to your next meal"

---

### 6.9 Food Recommendations

When a deficit is detected, suggest foods from the preset list that are rich in the deficient nutrient.

**Filtering logic:**
1. Identify the nutrient with the largest deficit
2. Filter food items by category matching the deficit
3. Sort by nutrient density (amount per 100g)
4. Return top 3-5 suggestions

**Example:**
- Deficit: 25g protein
- Suggestions: "2 boiled eggs (12g protein), 1 cup dal (13g protein)"

---

### 6.10 Nutrition-Burnout Link

Nutrition status modifies the burnout score as an adjustment:

```
nutritionPenalty = 0

if proteinDeficit > 50%: nutritionPenalty += 5  (fatigue risk)
if calorieDeficit > 50%: nutritionPenalty += 4  (energy crash)
if caffeineScore > 60:   nutritionPenalty += 3  (anxiety/jitters)

adjustedBurnoutScore = clamp(burnoutScore + nutritionPenalty, 0, 100)
```

This keeps nutrition as a modifier rather than a core formula component, making it easy to add/remove without breaking the core scoring.

---

## 7. UI/UX Requirements

### Navigation Structure

Bottom navigation bar with 4 tabs:

| Tab | Icon | Screen |
|-----|------|--------|
| Home | Dashboard icon | Dashboard (default landing) |
| Check-In | Plus/edit icon | Check-in input form |
| Nutrition | Food/apple icon | Nutrition tracking |
| History | Clock/chart icon | Past check-ins list |

### Screen Flow

```
Auth Gate (checks Firebase Auth state)
├── Not logged in → Auth Screen
│     ├── Login (email/password)
│     ├── Register (email/password)
│     └── Google Sign-In
├── Logged in, no profile → Profile Setup Screen
│     └── Save profile → Dashboard
└── Logged in, has profile → Bottom Nav Bar
      ├── Tab 1: Home (Dashboard)
      │     ├── "Start Check-In" → Check-In Screen
      │     └── "View Details" → Results Detail Screen
      │           ├── Cause Breakdown (scrollable section)
      │           ├── Prediction View (scrollable section)
      │           ├── Recovery Plan (scrollable section)
      │           └── "Fix It" → Simulation (bottom sheet / section)
      ├── Tab 2: Check-In Screen
      │     └── Submit → Results Screen (auto-navigates)
      ├── Tab 3: Nutrition Screen
      │     ├── Food Input (quick-select grid)
      │     ├── Daily Summary (progress bars)
      │     └── Recommendations (expandable section)
      └── Tab 4: History Screen
            └── Tap entry → Past result detail
```

### Screen Descriptions

**0a. Auth Screen (login/register)**
- Toggle between Login and Register modes
- Email + password fields with validation
- "Sign in with Google" button
- App logo at top
- Error messages for invalid credentials, network errors

**0b. Profile Setup Screen (first login only)**
- Name (required)
- Age (optional, numeric)
- Occupation (optional, dropdown: Student, Developer, Designer, Manager, Freelancer, Other)
- "Continue" button → saves to Firestore, navigates to Dashboard

**0c. Onboarding / Splash Screen (first launch only)**
- App logo + name "FocusGuard AI"
- Tagline: "Predict. Prevent. Perform."
- Brief 2-3 slide intro (optional, can skip)
- "Get Started" button → Auth Screen

**1. Home / Dashboard**
- Greeting with user's name (from Firestore profile)
- Current burnout score with circular gauge meter
- Risk level label and color
- Today's nutrition summary (compact card)
- Quick action: "Start Check-In" button
- "Try Demo" button (fills sample data, submits, shows results)
- Last check-in timestamp
- If no check-in today: prominent CTA "How are you feeling today?"
- Settings icon (top-right) → Profile view, Logout

**2. Check-In Screen**
- Slider/number inputs for each factor
- Each slider shows its current value and label
- Pre-filled with defaults
- "Submit" button at bottom (primary action color)
- Clean, minimal design — should take < 30 seconds
- Inline validation: red text if value out of range

**3. Results Screen (single scrollable page with sections)**
- **Header:** Large circular burnout meter (animated) with score + risk label
- **Section 1 — Cause Breakdown:** Pie chart + top cause insight text
- **Section 2 — Prediction:** Tomorrow score + 3-day trend line chart
- **Section 3 — Recovery Plan:** List of suggestion cards with expected reduction
- **Section 4 — "Fix It" Button:** Expands to show simulation before/after

**4. Simulation (expanded section or bottom sheet)**
- Before/after score comparison (two gauges side-by-side)
- Animated transition between scores
- Specific changes listed (what was adjusted and by how much)
- "What changed" breakdown

**5. Nutrition Screen**
- **Top:** Daily summary card (total protein, calories, carbs, fat as progress bars)
- **Middle:** Grid of food items (quick-select tiles with emoji icons)
  - Tap tile → quantity selector (stepper: 0.5, 1, 1.5, 2...) → "Add" button
- **Bottom:** Deficit alerts (if any) + "Get Suggestions" → recommendations list
- Logged meals shown as dismissible chips/list below the grid

**6. History Screen**
- List of past check-ins sorted by date (newest first)
- Each entry shows: date, score, risk level color dot
- Tap entry → view full result detail for that day
- Empty state: "No check-ins yet. Start your first one!"

### Design Principles
- Dark theme preferred (easier on eyes, modern feel)
- Rounded cards with subtle shadows
- Smooth animations for score transitions
- Traffic-light color system (green/yellow/orange/red)
- Accessible font sizes (minimum 14sp)

---

## 8. Data Storage

### Cloud Storage (Firebase)

All user data stored in **Cloud Firestore**, organized per authenticated user:

**Firestore Collections:**

1. `users/{uid}` — user profile document
   - name, email, age, occupation, createdAt, updatedAt

2. `users/{uid}/check_ins/{date}` — daily check-in records (one document per day)
   - date, sleep, workHours, mood, meetings, caffeine, burnoutScore, createdAt

3. `users/{uid}/nutrition_logs/{autoId}` — food items logged per day
   - date, foodItemId, foodName, quantity, createdAt

4. `food_items/{id}` — preset food database (top-level shared collection, read-only for clients)
   - name, servingSize, protein, calories, carbs, fat, category, icon

**Firestore Security Rules:**
- Users can only read/write their own `users/{uid}` subtree
- `food_items` collection is read-only for all authenticated users
- Unauthenticated users have no access

**Offline Support:**
- Firestore offline persistence is enabled by default
- App works offline; data syncs when connection is restored

---

## 9. Success Metrics

For the hackathon demo:

- Complete check-in flow in under 30 seconds
- Burnout score calculates correctly and displays with proper risk level
- Cause breakdown percentages sum to 100%
- Prediction produces reasonable values
- At least 3 relevant recovery suggestions per check-in
- Simulation shows meaningful score improvement
- Nutrition quick-select works with deficit detection
- Smooth UI with no crashes during demo

---

## 10. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Time pressure (hackathon) | Core features incomplete | Strict MVP scope; nutrition is stretch goal |
| Burnout formula edge cases | Unrealistic scores | Normalization + clamping to 0-100 |
| No user history on first use | Prediction fails | Fallback: flat +5 adjustment, no trend |
| Voice input complexity | Delays Phase 2 | Manual input is primary; voice is additive |
| Too many food items to manage | Data entry overhead | Curated list of 25 items only |
| Scope creep | Missed deadline | Phase 2/3 features are explicitly deferred |
| Firebase config issues | Auth/store not working | Test Firebase setup early; use FlutterFire CLI |
| Network unavailable during demo | Data not saving | Firestore offline persistence enabled by default |
| Google Sign-In setup complexity | Auth flow broken | Email/password as primary; Google as optional |

---

## 11. Demo Flow (Hackathon Presentation)

Recommended 3-minute demo script:

1. **Open app** → Show login screen, sign in with pre-created demo account or Google (10s)
2. **Tap "Try Demo"** → Auto-fills check-in with high-burnout sample data (sleep=4, work=12, mood=3, meetings=7, caffeine=6) and submits (10s)
3. **Results screen** → Show the burnout gauge animating to ~75 (Critical). Point out the score and risk label (15s)
4. **Scroll to Cause Breakdown** → Show pie chart. "Sleep deficit is the #1 driver at 38%" (15s)
5. **Scroll to Prediction** → Show tomorrow's predicted score and 3-day trend going up. "If nothing changes, burnout will hit 80 by Thursday" (15s)
6. **Scroll to Recovery Plan** → Show suggestions. "The app suggests getting 7-8 hours of sleep, which alone would drop the score by 10 points" (15s)
7. **Tap "Fix It"** → Show simulation. Score drops from 75 to 35. "Following all suggestions would cut burnout risk in half" (15s)
8. **Switch to Nutrition tab** → Add a few foods, show deficit detection. "You're 25g low on protein — here are food suggestions" (30s)
9. **Switch to History tab** → Show past entries (if time permits) (10s)
10. **Wrap up** → "FocusGuard AI predicts burnout before it happens and tells you exactly what to fix" (10s)

**Demo data preset values:**

| Field | Demo Value | Produces |
|-------|-----------|----------|
| Sleep | 4 hours | High sleep deficit |
| Work | 12 hours | Overwork flag |
| Mood | 3 | Low mood |
| Meetings | 7 | Meeting overload |
| Caffeine | 6 | High caffeine |

Expected demo score: ~72-78 (High/Critical)

---

## 12. Privacy & Data Handling

- User data is stored in **Cloud Firestore** under the authenticated user's UID
- Data is isolated per user via Firestore security rules — users cannot access other users' data
- **Firebase Authentication** manages user identity (email/password or Google Sign-In)
- Minimal PII collected: name, email, age (optional), occupation (optional)
- Behavioral metrics (check-ins) and food logs are associated with user UID, not personal details
- Users can delete their account and all associated data from settings
- Firestore offline persistence ensures the app works without internet
- Phase 2 AI features (OpenAI API) will transmit check-in data — user consent required before enabling
- Firebase project should be configured with appropriate data residency settings

---

## 13. Out of Scope (MVP)

- Voice input
- AI-powered recommendations
- Camera-based food recognition
- Wearable integration
- Push notifications (FCM deferred to Phase 3)
- Budget-based food suggestions
- Social features
- Multi-language support
- Firebase Analytics (Phase 2)
