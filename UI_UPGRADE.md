# Overall UI Upgrade Plan

The goal of this UI overhaul is to make the FocusGuard AI application look "stunning" and "premium" at first glance. We will transition from a basic flat dark mode to a rich, vibrant, modern aesthetic using glassmorphism, subtle glowing gradients, and improved typography.

## Proposed Changes

### Configuration & Packages

#### [MODIFY] `pubspec.yaml`
- Add `google_fonts: ^6.2.1` to the dependencies to enable premium typography (we will use **Outfit** or **Inter** for a sleek, modern tech feel).
- Add `flutter_animate: ^4.5.0` (or similar) if we need micro-animations, though we can also use built-in `AnimatedContainer` and `AnimatedOpacity`.

---

### Core Theme & Styling

#### [MODIFY] `lib/theme/app_theme.dart`
- **Color Palette Upgrade**: Switch from plain gray (`#121212`) to a richer, deep atmospheric dark mode (e.g., deep navy and violet tones).
- **Typography Integration**: Integrate `GoogleFonts.outfitTextTheme()` or `GoogleFonts.interTextTheme()` mapping to the dark theme.
- **Glassmorphism Base**: Define constants for glass container opacities, borders, and gradient offsets.

#### [NEW] `lib/widgets/glass_card.dart`
- Create a reusable `GlassCard` widget utilizing `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))` with a translucent background and thin 1px white-border overlay (opacity 0.1). This will replace standard flat opaque `Card`s.

---

### Components Upgrade

#### [MODIFY] `lib/widgets/burnout_gauge.dart`
- Add a glowing drop shadow (`BoxShadow` with the arc's color) beneath the score arc to make it look alive.
- Update typography to use the new modern fonts. 
- Improve the track background to be slightly translucent.

#### [MODIFY] `lib/widgets/suggestion_tile.dart` & `lib/widgets/cause_chart.dart`
- Enclose the chart portions and suggestion components in `GlassCard`s.

---

### Screens Makeover

#### [MODIFY] `lib/views/home_screen.dart`
- Add a continuous subtle background gradient or mesh to the entire app scaffold (e.g., wrapped around the `IndexedStack`).
- Upgrade the `BottomNavigationBar` to have a floating dock feel, or at least modify its background to be translucent.

#### [MODIFY] `lib/views/dashboard_screen.dart`
- Replace the solid `_Stat` containers and other flat cards with the new `GlassCard` component.
- Apply gradient text to the greeting ("Good morning, Priya").

#### [MODIFY] `lib/views/checkin_screen.dart`
- Switch the form elements and sliders to sit inside `GlassCard`s. 
- Update the sliders to have glowing thumb indicators and translucent tracks.

#### [MODIFY] `lib/views/result_screen.dart`
- Repackage the different sections (Cause Chart, Prediction, Simulation) into cohesive, beautifully spaced glassmorphism sections.

## Next Steps

1. Configure dependencies.
2. Build core theme and base `GlassCard`.
3. Apply to widgets and screens.
4. Verify aesthetics.
