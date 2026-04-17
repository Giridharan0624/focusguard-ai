# FocusGuard AI — Product Requirements Document

## 1. Product Overview

FocusGuard AI is a mobile application that predicts, explains, and prevents burnout using behavioral and nutritional inputs combined with AI-driven analysis.

It acts as a real-time burnout radar, recovery planner, nutrition advisor, and conversational wellness coach — helping users understand *why* they feel burned out and *what* to do about it.

### What Makes It Different

- Predicts future burnout risk, not just tracks current state
- Identifies root causes with percentage contribution
- **AI-generated personalized insights** after every check-in
- **AI-powered wellness chat coach** for 24/7 support
- **Voice-driven check-in and food logging** — speak naturally instead of tapping
- **Natural-language check-in** — describe your day in plain English, AI extracts data
- Links nutrition deficits to burnout through a unified scoring model
- Simulates recovery scenarios with before/after comparison

---

## 2. Problem Statement

Users experience burnout due to poor sleep, long work hours, emotional stress, excessive screen time, and poor nutrition. Existing wellness apps:

- Track data but do not predict burnout
- Do not explain which factors are driving risk
- Provide only generic advice, not personalized recovery plans
- Fail to connect nutrition deficits to fatigue and burnout
- Don't simulate outcomes of behavioral changes
- Require tedious manual input with no voice support

---

## 3. Objectives

1. Enable fast daily check-in (manual, voice, or natural language text)
2. Generate an accurate burnout risk score (0-100) with normalized formula
3. Provide explainable cause breakdown with contribution percentages
4. Predict burnout risk for the next 1-3 days
5. Deliver AI-generated personalized insights and recovery plans
6. Simulate improved outcomes after applying fixes
7. Track nutrition intake with proper measurement units
8. Recommend AI-generated food combinations aligned with burnout prevention
9. Offer a conversational AI wellness coach for contextual support

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
- Long work hours, codes at night to compensate
- Sleeps 4-5 hours, mood drops by midweek
- Wants AI to analyze patterns and explain burnout triggers

**Aisha (Freelancer, 32)**
- Irregular schedule, no clear work-life boundary
- Forgets to eat balanced meals while deep in work
- Wants voice check-ins and AI meal suggestions

### User Stories

| # | As a... | I want to... | So that... |
|---|---------|-------------|-----------|
| 1 | User | Log my daily sleep, work, mood, screen time, and caffeine in under 30 seconds | I can track my state without friction |
| 2 | User | See a burnout risk score immediately after check-in | I know how I'm doing today |
| 3 | User | See which factor is hurting me the most | I know what to fix first |
| 4 | User | Get AI-generated insights after check-in | I receive personalized analysis, not generic tips |
| 5 | User | Chat with an AI wellness coach | I get contextual support whenever I need it |
| 6 | User | Speak my check-in instead of tapping | I can log quickly without using my hands |
| 7 | User | Type "slept 5 hours, feeling terrible" and have AI extract data | I don't have to adjust every slider |
| 8 | User | Toggle exercise as an input | I get credit for my workout reducing burnout |
| 9 | User | Log food in proper units (2 eggs, 200g rice, 250ml milk) | Nutrition is natural, not serving-based |
| 10 | User | Get AI meal recommendations based on deficits | I don't have to think about what to eat |
| 11 | User | Simulate what happens if I follow suggestions | I feel motivated to make changes |
| 12 | User | See my 7-day trend on the dashboard | I know if I'm improving or declining |
| 13 | User | Switch between light and dark themes | I can use the app comfortably in any environment |
| 14 | User | Create an account and log in | My data is saved and accessible across devices |
| 15 | User | Sign in with Google | I can start quickly without creating a password |
| 16 | User | Delete my account and data | I have control over my personal information |

---

## 5. Product Scope & Phasing

### Phase 1 — Foundation (MVP)

- Firebase Authentication (email/password + Google Sign-In)
- User profile setup (name, age, occupation)
- Manual check-in input screen (5 factors: sleep, work, mood, screen time, caffeine)
- Burnout score calculation with normalized formula
- Cause analysis with contribution breakdown
- Tomorrow prediction + 3-day projection
- Rule-based recovery suggestions
- Outcome simulation (before/after comparison)
- Check-in history synced to Cloud Firestore
- Basic nutrition input (quick-select from preset foods)
- Nutrition deficit detection
- Dark theme + Light theme

### Phase 2 — AI Integration (Groq)

- **AI Insight** after check-in — personalized paragraph analysis
- **AI Recovery Plan** — context-aware suggestions replacing rule-based ones
- **AI Wellness Coach Chat** — conversational support with full context
- **Natural Language Check-In** — free-text → AI extracts structured data
- **AI Food Recommendations** — personalized meal suggestions based on deficits
- **AI Food Parsing from Voice** — "I had 2 eggs and rice" → auto-adds to log

### Phase 3 — Voice Control

- **Voice check-in** — speak freely, AI parses into fields
- **Voice chat** — talk to wellness coach
- **Voice food logging** — speak meals to add to nutrition
- Live partial-speech display during recording
- Append mode — multiple recordings build up text

### Phase 4 — Polish & UX

- Bento-grid dashboard with colored icon cards
- Yellow accent brand color throughout
- Animated transitions and haptic feedback
- 7-day trend chart on dashboard
- Streak counter (🔥 fire emoji)
- Proper measurement units (grams, ml, nos) per food item
- Water tracker on nutrition page
- Nutrition grade (A-F) based on goal progress
- Profile tab in bottom navigation with stats

---

## 6. Core Features

### 6.1 Daily Check-In

**5 inputs + optional exercise toggle:**

| Input | Type | Range | Description |
|-------|------|-------|-------------|
| Sleep Hours | Decimal | 0-16 | Hours of sleep last night |
| Work Hours | Decimal | 0-24 | Hours worked today |
| Mood | Emoji slider | 1-10 | Self-reported mood via 5 emoji faces |
| Screen Time | Decimal | 0-16 | Hours of screen exposure today |
| Caffeine | Integer | 0-15 | Cups of coffee/tea consumed |
| Exercised | Boolean | yes/no | Whether user exercised (-5 burnout bonus) |

**Three input modes:**
1. **Slider input** — classic sliders with live score preview
2. **Voice input** — tap mic, speak, AI extracts data
3. **Natural language** — type "slept 5 hours, felt terrible", AI parses

**Presets:** Student Day, Work Day, Rest Day (one-tap fills)

**Multiple Check-Ins:**
- Only one check-in per calendar day stored
- New submission overwrites the same-day record

---

### 6.2 Burnout Risk Score (0-100)

**Normalized Formula:**

```
sleepDeficit = max(0, 8 - sleep)
sleepScore = (sleepDeficit / 8) × 100
If sleep > 9: sleepScore = ((sleep - 9) / 7) × 30   # oversleep penalty

workScore = (workHours / 16) × 100
moodScore = ((10 - mood) / 9) × 100
screenScore = (screenTime / 16) × 100
caffeineScore = (caffeine / 10) × 100

burnoutScore = (sleepScore × 0.30)
             + (workScore  × 0.25)
             + (moodScore  × 0.20)
             + (screenScore × 0.15)
             + (caffeineScore × 0.10)

If exercised: burnoutScore -= 5
finalScore = clamp(burnoutScore, 0, 100)
```

**Risk Levels:**

| Score | Level | Color | Label |
|-------|-------|-------|-------|
| 0-25 | Low | Mint | You're doing great |
| 26-50 | Moderate | Amber | Watch out |
| 51-75 | High | Orange | Take action |
| 76-100 | Critical | Red | Burnout alert |

**Wellness Score:** Displayed as `100 - burnoutScore` on UI for positive framing.

---

### 6.3 Cause Analysis

Each factor's weighted contribution as a percentage of total. Displayed as pie chart with legend. Top cause highlighted with insight text (static fallback, AI-generated when available).

---

### 6.4 Future Prediction

**Tomorrow:**
```
predictedScore = currentScore × 0.85 + trendAdjustment
trend = +8 if trending up, -5 if down, +3 if stable
```

**3-Day Projection:** Applied iteratively, feeding predictions back as input.

---

### 6.5 AI Insights (Phase 2)

After every check-in, Groq generates a personalized 2-3 sentence insight:

- References specific user numbers (e.g., "Your 4 hours of sleep combined with 12 work hours...")
- Identifies patterns if history exists
- Ends with one concrete, actionable suggestion
- Falls back to static `topCauseInsight` if API fails

Cached in Firestore under `users/{uid}/ai_cache/insight_{date}`.

---

### 6.6 AI Recovery Plan (Phase 2)

Groq generates 3-5 personalized suggestions as JSON:
- Category (sleep, work, mood, screen_time, caffeine, exercise)
- Context-aware text (references user's occupation, score)
- Expected reduction in points
- Priority (high/medium/low)

Falls back to rule-based `RecommendationService` if API fails.

---

### 6.7 AI Wellness Coach Chat (Phase 2)

Dedicated chat screen with:
- Header with AI badge + "Online" status
- Scrollable message history
- User messages (yellow bubbles, right-aligned)
- AI messages (surface bubbles, left-aligned)
- Typing indicator (3 animated dots)
- Quick-start chips on empty state
- Voice input via mic button
- Full user context sent to AI: score, inputs, history, profile

---

### 6.8 Natural Language Check-In (Phase 2)

- "Describe your day" bottom sheet
- Text input + mic button
- User types or speaks: *"Slept 5 hours, worked all day, 3 coffees"*
- Groq extracts: `{sleepHours: 5, workHours: 10, mood: 3, caffeine: 3}`
- Sliders auto-populate
- User reviews before submitting

---

### 6.9 Voice Control (Phase 3)

Uses `speech_to_text` package (on-device, free, offline-capable).

**Three locations:**
- **Check-In NL sheet:** speak freely, AI extracts
- **Chat screen:** speak messages to AI coach
- **Nutrition:** speak food items, AI parses and adds to log

**Features:**
- Mic button with visual state (idle/listening)
- Red pulsing dot + live partial-speech display while recording
- Cancel button to dismiss
- Rate limit: 30 seconds per recording
- **Append mode** — tap mic multiple times, text accumulates

---

### 6.10 Outcome Simulation

"What if I follow the suggestions?" — applies optimistic targets:
- Sleep: 7.5h
- Work: 8h
- Mood: +2
- Screen time: 4h
- Caffeine: 2 cups

Displays side-by-side before/after with reduction chip and change tags.

---

### 6.11 Nutrition Tracking (MVP Scope)

**25 curated food items** with:
- Icon (emoji)
- Serving size
- Protein, Calories, Carbs, Fat per serving
- Category (protein-rich, energy, balanced, light)
- **Unit** (nos / grams / ml) — proper measurement per food
- **Step size** — tap increment (1 for eggs, 50 for grams, 100 for ml)

**Examples:**
- Boiled Egg: 1, 2, 3 nos (1 step)
- Grilled Chicken: 50, 100, 150, 200 grams (50 step)
- Dal: 100, 200, 300 ml (100 step)
- Milk: 100, 200, 250 ml (100 step)

**Daily Goals:** Protein 60g, Calories 2000kcal, Carbs 250g, Fat 65g

**Grade System:** A/B/C/D/F based on average goal progress across all nutrients.

**Water Tracker:** + / - to count glasses.

---

### 6.12 AI Food Advice (Phase 2)

Groq generates meal suggestions based on:
- Current deficits (protein, calories, etc.)
- Time of day (breakfast, lunch, snack, dinner)
- User profile (occupation)

Displayed as card with sparkle icon + "Breakfast/Lunch/Dinner Ideas" heading.

---

### 6.13 Voice Food Logging (Phase 3)

- Tap mic CTA on nutrition page
- Speak: *"I had 2 eggs and rice"*
- Groq parses: `[{name: "Boiled Egg", quantity: 2}, {name: "White Rice", quantity: 1}]`
- Automatically matches to food database and adds to log
- Toast confirms items added

---

### 6.14 Nutrition-Burnout Link

Nutrition status modifies burnout score:

```
if proteinDeficit > 50%: penalty += 5
if calorieDeficit > 50%: penalty += 4
adjustedScore = clamp(burnoutScore + penalty, 0, 100)
```

Shown as red banner on nutrition page when penalty active.

---

## 7. UI/UX Requirements

### Design System
- **Primary accent:** Amber yellow (#FBC02D) with dark text on yellow
- **Background:** Near-black (#0A0D13) in dark mode, light gray (#F7F9FD) in light mode
- **Typography:** Poppins — Material 3 typography scale
- **Cards:** Glass-card with outlined border + subtle shadow
- **Radius:** 8/12/16/20 px (sm/md/lg/xl) + full-pill
- **Spacing:** 4px grid — 4/8/12/16/20/24/32/40

### Navigation Structure

Bottom navigation bar with **5 tabs**:

| Tab | Icon | Screen |
|-----|------|--------|
| Home | Dashboard | Bento-grid dashboard |
| Check-In | Plus circle | 5-input check-in form |
| Nutrition | Restaurant | Calorie ring + food logging |
| History | History clock | Past check-ins list |
| Profile | Person | Profile + stats + settings |

FAB: "Psychology" icon → AI Chat (floating on Home).

### Screen Descriptions

**0. Splash Screen** — animated logo with glow + "FocusGuard AI" + tagline

**1. Auth Flow**
- Login with yellow pill sign-in + Google button
- Register with email/password/confirm
- Profile setup (name required, age/occupation optional)

**2. Home / Dashboard**
- Welcome row: avatar (yellow gradient with initial), "Welcome back, [Name]", bell + profile icons
- **Yellow Daily Score card** — large wellness % + circular progress ring
- Bento 2×2 grid: Sleep / Work / Screen Time / Caffeine with colored icon badges
- "Talk to AI coach" yellow pill with arrow circle

**3. Check-In**
- Header + compact AI button
- Yellow live wellness preview card
- Mood emoji row (selected highlighted in yellow)
- Bento 2×2 input cards with colored icon badges + per-card sliders
- Exercise toggle (mint when active)
- Preset chips: Student / Work / Rest
- Yellow submit pill with arrow circle
- "Describe your day" bottom sheet with voice

**4. Results**
- Back button
- **Yellow wellness hero** with progress ring + risk badge
- AI Insight card with sparkle badge
- Simulation card: current → after with -X chip
- Causes section with pie chart
- Prediction section with trend chart
- AI Recovery Plan with colored tiles
- Yellow Done pill

**5. Nutrition**
- Header + grade badge
- **Yellow calorie hero** with progress ring + water tracker
- Burnout penalty banner (if present)
- AI food advice card
- 3-column macro rings (Protein / Carbs / Fat)
- Logged meals list
- Yellow voice-log CTA
- Category filter chips
- 3-column food grid

**6. History**
- Header with refresh
- **Yellow total check-ins hero**
- Recent check-ins list with score circles + risk pills + "Latest" badge

**7. Profile**
- Header
- **Yellow profile hero** with avatar, name, email, edit button, age/occupation chips
- Stats row: Check-ins / Latest / Streak
- Preferences: Dark mode toggle
- Account: Sign Out / Delete Account
- Footer: logo + version + tagline

**8. Chat (AI Coach)**
- Header with back button + yellow AI badge + "Online" status
- Empty state: glowing yellow circle + quick-start chips
- Message bubbles (user yellow, AI surface)
- Animated typing dots
- Input bar with voice + yellow send circle

### Design Principles
- Bento-grid layout for data density
- Yellow accent only on key CTAs and hero cards
- Colored icon badges (blue/orange/purple/green) for variety
- Consistent card styling via `AppTheme.glassCard()`
- Material 3 typography throughout
- Haptic feedback on interactions

---

## 8. Data Storage

### Cloud Storage (Firebase Firestore)

All user data stored in Cloud Firestore, organized per authenticated user:

**Collections:**

1. `users/{uid}` — user profile
   - name, email, age, occupation, createdAt, updatedAt

2. `users/{uid}/check_ins/{date}` — daily check-ins (one doc per day)
   - date, sleep_hours, work_hours, mood, screen_time, caffeine, burnout_score, created_at

3. `users/{uid}/nutrition_logs/{autoId}` — food logs
   - date, food_item_id, quantity, created_at

4. `users/{uid}/ai_cache/{docId}` — cached AI responses
   - type (insight / recovery / food), content, created_at

5. `food_items/{id}` — shared preset food database
   - name, serving_size, protein, calories, carbs, fat, category, icon, unit, step_size

**Security Rules:**
- Users can only read/write their own `users/{uid}` subtree
- `food_items` readable by all authenticated users; writable (to support seeding)
- Unauthenticated users have no access

**Offline Support:** Firestore offline persistence enabled by default.

---

## 9. Success Metrics

For the hackathon demo:

- Complete check-in flow in under 30 seconds
- Voice check-in extracts correct data in 90%+ of cases
- Burnout score calculates instantly and displays with proper risk level
- AI insight loads within 2 seconds after check-in
- AI chat responds within 3 seconds
- Smooth UI transitions with no stutter
- Zero crashes during demo
- Light/dark theme toggle works instantly

---

## 10. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Groq API downtime | AI features broken | Graceful fallback to rule-based logic |
| Groq quota exhausted | Rate limited mid-demo | In-memory sliding window (28/60s) |
| Voice recognition fails | Can't use mic | Manual input always available as fallback |
| Firestore API not enabled | App hangs at startup | Seed food items lazily on first nutrition load |
| Food grid items outdated | Missing units field | Auto re-seed when `unit` field missing |
| Network offline | Data not syncing | Firestore offline persistence enabled |

---

## 11. Demo Flow (Hackathon Presentation)

Recommended 3-minute demo:

1. **Splash → Login** — animated yellow logo → sign in (5s)
2. **Dashboard** — show empty state with yellow hero (10s)
3. **Check-In** — tap mic, speak *"Slept 4 hours, worked 12 hours, feeling terrible, 6 coffees, too much screen time"* → watch sliders auto-fill (30s)
4. **Submit** → wait for AI insight to appear with personalized analysis (15s)
5. **Results** — show wellness score + AI recovery plan + simulation before/after (30s)
6. **Chat** — open AI coach → ask "Why is my sleep so bad?" → read response (30s)
7. **Nutrition** — calorie ring + add "2 eggs and rice" by voice → show AI meal suggestions (30s)
8. **History** — show past check-ins with risk colors (10s)
9. **Profile** — toggle dark/light theme → show stats (10s)

---

## 12. Privacy & Data Handling

- User data stored in Cloud Firestore under authenticated user's UID
- Data isolated per user via Firestore security rules
- Firebase Authentication manages identity (email/password or Google)
- Minimal PII: name, email, age (optional), occupation (optional)
- Voice recordings processed locally via `speech_to_text` — never leaves device
- AI API calls (Groq) send anonymized text only — no PII
- Users can delete account and all associated data from Profile tab
- API keys passed via `--dart-define` at build time, never hardcoded

---

## 13. Out of Scope

- Camera-based food recognition
- Wearable integration
- Push notifications
- Budget-based food suggestions
- Social features (sharing, leaderboards)
- Multi-language support
- Apple Health / Google Fit sync
- Subscription/premium tier
