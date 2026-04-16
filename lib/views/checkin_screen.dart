import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../utils/constants.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../widgets/burnout_gauge.dart';
import 'result_screen.dart';

const _moodEmojis = ['😫', '😟', '😐', '🙂', '😄'];

const _groqApiKey = String.fromEnvironment('GROQ_API_KEY');

void _showNLSheet(BuildContext context, CheckInViewModel vm) {
  final controller = TextEditingController();
  bool isLoading = false;
  final gemini = GeminiService(apiKey: _groqApiKey);

  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 20, color: AppTheme.primary),
                SizedBox(width: 8),
                Text('Describe your day',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText:
                    'e.g. "Slept 5 hours, worked all day, feeling terrible, too much coffee"',
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (controller.text.trim().isEmpty) return;
                        setState(() => isLoading = true);

                        try {
                          final parsed = await gemini
                              .extractCheckinFromText(controller.text);

                          if (parsed != null) {
                            if (parsed['sleepHours'] != null) {
                              vm.sleepHours =
                                  (parsed['sleepHours'] as num).toDouble();
                            }
                            if (parsed['workHours'] != null) {
                              vm.workHours =
                                  (parsed['workHours'] as num).toDouble();
                            }
                            if (parsed['mood'] != null) {
                              vm.mood = (parsed['mood'] as num).toInt();
                            }
                            if (parsed['screenTime'] != null) {
                              vm.screenTime =
                                  (parsed['screenTime'] as num).toDouble();
                            }
                            if (parsed['caffeine'] != null) {
                              vm.caffeine =
                                  (parsed['caffeine'] as num).toInt();
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          } else {
                            setState(() => isLoading = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Could not understand. Try the sliders.')),
                              );
                            }
                          }
                        } catch (_) {
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Extract & Fill'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CheckInViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // ── NL Check-In + Live score ──
              BurnoutGauge(score: vm.liveScore, size: 110, animate: false),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _showNLSheet(context, vm),
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Or describe your day',
                    style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 10),

              // ── Mood emoji row ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (i) {
                      final moodValue = (i * 2) + 2;
                      final selected = (vm.mood - moodValue).abs() <= 1;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          vm.mood = moodValue;
                        },
                        child: AnimatedScale(
                          scale: selected ? 1.25 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedOpacity(
                            opacity: selected ? 1.0 : 0.5,
                            duration: const Duration(milliseconds: 200),
                            child: Text(_moodEmojis[i],
                                style: const TextStyle(fontSize: 30)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Sliders ──
              _Slider(
                icon: Icons.bedtime_rounded,
                label: 'Sleep',
                value: vm.sleepHours,
                min: kMinSleep, max: kMaxSleep, divisions: 32,
                display: '${vm.sleepHours.toStringAsFixed(1)}h',
                color: _sleepColor(vm.sleepHours),
                onChanged: (v) => vm.sleepHours = v,
              ),
              _Slider(
                icon: Icons.work_rounded,
                label: 'Work',
                value: vm.workHours,
                min: kMinWork, max: kMaxWork, divisions: 48,
                display: '${vm.workHours.toStringAsFixed(1)}h',
                color: vm.workHours <= 8 ? AppTheme.riskLow : vm.workHours <= 10 ? AppTheme.riskModerate : AppTheme.riskCritical,
                onChanged: (v) => vm.workHours = v,
              ),
              _Slider(
                icon: Icons.phone_android_rounded,
                label: 'Screen',
                value: vm.screenTime,
                min: kMinScreenTime, max: kMaxScreenTimeInput, divisions: 32,
                display: '${vm.screenTime.toStringAsFixed(1)}h',
                color: vm.screenTime <= 4 ? AppTheme.riskLow : vm.screenTime <= 8 ? AppTheme.riskModerate : AppTheme.riskCritical,
                onChanged: (v) => vm.screenTime = v,
              ),
              _Slider(
                icon: Icons.coffee_rounded,
                label: 'Caffeine',
                value: vm.caffeine.toDouble(),
                min: 0, max: kMaxCaffeineInput.toDouble(), divisions: kMaxCaffeineInput,
                display: '${vm.caffeine} cups',
                color: vm.caffeine <= 3 ? AppTheme.riskLow : vm.caffeine <= 5 ? AppTheme.riskModerate : AppTheme.riskCritical,
                onChanged: (v) => vm.caffeine = v.round(),
              ),

              const SizedBox(height: 8),

              // ── Exercise chip ──
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  vm.exercised = !vm.exercised;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: vm.exercised ? AppTheme.riskLow.withValues(alpha: 0.15) : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: vm.exercised ? AppTheme.riskLow : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vm.exercised ? Icons.check_circle_rounded : Icons.fitness_center_rounded,
                        size: 18,
                        color: vm.exercised ? AppTheme.riskLow : AppTheme.textHint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vm.exercised ? 'Exercised today ✓' : 'Did you exercise?',
                        style: TextStyle(
                          fontSize: 13,
                          color: vm.exercised ? AppTheme.riskLow : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(vm.errorMessage!,
                      style: const TextStyle(color: AppTheme.riskCritical)),
                ),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          HapticFeedback.heavyImpact();
                          await vm.submit();
                          if (vm.result != null && context.mounted) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ResultScreen()));
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),

              // ── Quick presets (subtle, at bottom) ──
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MiniPreset(label: 'Student', onTap: () => vm.loadPreset('student')),
                  _MiniPreset(label: 'Work', onTap: () => vm.loadPreset('work')),
                  _MiniPreset(label: 'Rest', onTap: () => vm.loadPreset('rest')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _sleepColor(double h) {
    if (h >= 6.5 && h <= 9) return AppTheme.riskLow;
    if (h < 5 || h > 10) return AppTheme.riskCritical;
    return AppTheme.riskModerate;
  }
}

class _Slider extends StatelessWidget {
  final IconData icon;
  final String label;
  final String display;
  final double value, min, max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  const _Slider({
    required this.icon, required this.label, required this.display,
    required this.value, required this.min, required this.max,
    required this.divisions, required this.color, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.12),
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value, min: min, max: max,
                divisions: divisions, onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(display,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

class _MiniPreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MiniPreset({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textHint,
                decoration: TextDecoration.underline)),
      ),
    );
  }
}
