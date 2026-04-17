import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../utils/constants.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../widgets/mic_button.dart';
import 'result_screen.dart';

const _moodEmojis = ['😫', '😟', '😐', '🙂', '😄'];
const _moodLabels = ['Awful', 'Bad', 'Okay', 'Good', 'Great'];
const _groqApiKey = String.fromEnvironment('GROQ_API_KEY');

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CheckInViewModel>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ══ Header ══
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How are you feeling',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('today?',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                _AIButton(onTap: () => _showNLSheet(context, vm)),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Live wellness score card (yellow) ══
            _LiveScoreCard(score: (100 - vm.liveScore).round()),
            const SizedBox(height: 20),

            // ══ Mood selector ══
            Text('Choose your mood',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _MoodRow(
              selected: vm.mood,
              onSelect: (m) {
                HapticFeedback.selectionClick();
                vm.mood = m;
              },
            ),
            const SizedBox(height: 24),

            // ══ Input cards (bento) ══
            Row(
              children: [
                Expanded(child: _InputCard(
                  icon: Icons.nights_stay_rounded,
                  iconColor: const Color(0xFF42A5F5),
                  label: 'Sleep',
                  value: vm.sleepHours,
                  min: kMinSleep, max: kMaxSleep,
                  display: '${vm.sleepHours.toStringAsFixed(1)}h',
                  onChanged: (v) => vm.sleepHours = v,
                )),
                const SizedBox(width: 12),
                Expanded(child: _InputCard(
                  icon: Icons.work_rounded,
                  iconColor: const Color(0xFFE07C54),
                  label: 'Work',
                  value: vm.workHours,
                  min: kMinWork, max: kMaxWork,
                  display: '${vm.workHours.toStringAsFixed(1)}h',
                  onChanged: (v) => vm.workHours = v,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _InputCard(
                  icon: Icons.phone_android_rounded,
                  iconColor: const Color(0xFFFFA726),
                  label: 'Screen',
                  value: vm.screenTime,
                  min: kMinScreenTime, max: kMaxScreenTimeInput,
                  display: '${vm.screenTime.toStringAsFixed(1)}h',
                  onChanged: (v) => vm.screenTime = v,
                )),
                const SizedBox(width: 12),
                Expanded(child: _InputCard(
                  icon: Icons.coffee_rounded,
                  iconColor: const Color(0xFFAB47BC),
                  label: 'Caffeine',
                  value: vm.caffeine.toDouble(),
                  min: 0, max: kMaxCaffeineInput.toDouble(),
                  display: '${vm.caffeine} cups',
                  onChanged: (v) => vm.caffeine = v.round(),
                )),
              ],
            ),
            const SizedBox(height: 16),

            // ══ Exercise toggle ══
            _ExerciseCard(
              exercised: vm.exercised,
              onTap: () {
                HapticFeedback.selectionClick();
                vm.exercised = !vm.exercised;
              },
            ),
            const SizedBox(height: 12),

            // ══ Presets ══
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PresetChip(label: 'Student', emoji: '🎓',
                    onTap: () => vm.loadPreset('student')),
                const SizedBox(width: 8),
                _PresetChip(label: 'Work', emoji: '💼',
                    onTap: () => vm.loadPreset('work')),
                const SizedBox(width: 8),
                _PresetChip(label: 'Rest', emoji: '🏖️',
                    onTap: () => vm.loadPreset('rest')),
              ],
            ),

            if (vm.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(vm.errorMessage!,
                  style: const TextStyle(color: AppTheme.riskCritical, fontSize: 12),
                  textAlign: TextAlign.center),
            ],

            const SizedBox(height: 20),

            // ══ Submit (yellow pill) ══
            _SubmitButton(
              isLoading: vm.isLoading,
              onTap: () async {
                HapticFeedback.heavyImpact();
                await vm.submit();
                if (vm.result != null && context.mounted) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ResultScreen()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ══ Live Score Card ══
class _LiveScoreCard extends StatelessWidget {
  final int score;
  const _LiveScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.2),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Preview',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                        color: AppTheme.onAccent, height: 1.2)),
                const SizedBox(height: 4),
                Text('$score%',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
                        color: AppTheme.onAccent, height: 1)),
                const SizedBox(height: 2),
                const Text('wellness today',
                    style: TextStyle(fontSize: 12, color: AppTheme.onAccent)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.onAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_graph_rounded,
                size: 28, color: AppTheme.onAccent),
          ),
        ],
      ),
    );
  }
}

// ══ AI button ══
class _AIButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AIButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.outline(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 12, color: AppTheme.onAccent),
            ),
            const SizedBox(width: 8),
            Text('AI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppTheme.tp(context))),
          ],
        ),
      ),
    );
  }
}

// ══ Mood Row ══
class _MoodRow extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const _MoodRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Map the 1-10 mood to one of the 5 buckets (indices 0..4, values 2/4/6/8/10).
    // Round-half-up so e.g. mood=3 → bucket 1 (value 4), mood=5 → bucket 2 (value 6).
    final selectedIndex = ((selected.clamp(1, 10) - 1) ~/ 2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final moodValue = (i * 2) + 2;
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(moodValue),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accent.withValues(alpha: 0.15)
                      : AppTheme.card(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.accent : AppTheme.outline(context),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(_moodEmojis[i],
                    style: TextStyle(fontSize: isSelected ? 26 : 22)),
              ),
              const SizedBox(height: 4),
              Text(_moodLabels[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppTheme.accent : AppTheme.th(context),
                  )),
            ],
          ),
        );
      }),
    );
  }
}

// ══ Input Card ══
class _InputCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String display;
  final double value, min, max;
  final ValueChanged<double> onChanged;

  const _InputCard({
    required this.icon, required this.iconColor, required this.label,
    required this.display, required this.value, required this.min,
    required this.max, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.th(context))),
            ],
          ),
          const SizedBox(height: 14),
          Text(display,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppTheme.tp(context), height: 1.1)),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: iconColor,
              inactiveTrackColor: iconColor.withValues(alpha: 0.15),
              thumbColor: iconColor,
              overlayColor: iconColor.withValues(alpha: 0.12),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

// ══ Exercise Card ══
class _ExerciseCard extends StatelessWidget {
  final bool exercised;
  final VoidCallback onTap;
  const _ExerciseCard({required this.exercised, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: exercised
              ? AppTheme.mintAccent.withValues(alpha: 0.1)
              : AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: exercised ? AppTheme.mintAccent : AppTheme.outline(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: exercised
                    ? AppTheme.mintAccent.withValues(alpha: 0.2)
                    : AppTheme.sl(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                exercised ? Icons.check_rounded : Icons.fitness_center_rounded,
                size: 18,
                color: exercised ? AppTheme.mintAccent : AppTheme.textHint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercised ? 'Exercised today' : 'Did you exercise?',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: exercised ? AppTheme.mintAccent : AppTheme.tp(context),
                      )),
                  Text(exercised ? '-5 burnout pts' : 'Reduces burnout risk',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.th(context))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ Preset Chip ══
class _PresetChip extends StatelessWidget {
  final String label, emoji;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.outline(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                    color: AppTheme.tp(context))),
          ],
        ),
      ),
    );
  }
}

// ══ Submit Button ══
class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SubmitButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.25),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text('Submit Check-In',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppTheme.onAccent,
                  )),
            ),
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.onAccent,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.accent),
                    )
                  : const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ NL Bottom Sheet ══
void _showNLSheet(BuildContext context, CheckInViewModel vm) {
  final controller = TextEditingController();
  bool isLoading = false;
  final gemini = GeminiService(apiKey: _groqApiKey);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textHint, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 16, color: AppTheme.onAccent),
                ),
                const SizedBox(width: 10),
                const Text('Describe your day',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller, maxLines: 3, autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'e.g. "Slept 5 hours, worked all day"',
                      hintStyle: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                MicButton(size: 42, onResult: (text) {
                  final cur = controller.text;
                  controller.text = cur.isEmpty ? text : '$cur $text';
                  controller.selection = TextSelection.collapsed(offset: controller.text.length);
                }),
              ],
            ),
            const VoiceListeningOverlay(),
            const SizedBox(height: 16),
            _SubmitButton(
              isLoading: isLoading,
              onTap: () async {
                if (controller.text.trim().isEmpty) return;
                setState(() => isLoading = true);
                try {
                  final parsed = await gemini.extractCheckinFromText(controller.text);
                  if (parsed != null) {
                    if (parsed['sleepHours'] != null) { vm.sleepHours = (parsed['sleepHours'] as num).toDouble(); }
                    if (parsed['workHours'] != null) { vm.workHours = (parsed['workHours'] as num).toDouble(); }
                    if (parsed['mood'] != null) { vm.mood = (parsed['mood'] as num).toInt(); }
                    if (parsed['screenTime'] != null) { vm.screenTime = (parsed['screenTime'] as num).toDouble(); }
                    if (parsed['caffeine'] != null) { vm.caffeine = (parsed['caffeine'] as num).toInt(); }
                    if (ctx.mounted) { Navigator.pop(ctx); }
                  } else {
                    setState(() => isLoading = false);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Could not understand. Try the sliders.')));
                    }
                  }
                } catch (_) { setState(() => isLoading = false); }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
