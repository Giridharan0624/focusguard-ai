import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../viewmodels/checkin_viewmodel.dart';
import 'result_screen.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CheckInViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sleep ──
              _SliderInput(
                icon: Icons.bedtime_rounded,
                label: 'Sleep Hours',
                value: vm.sleepHours,
                min: kMinSleep,
                max: kMaxSleep,
                divisions: 32,
                valueLabel: '${vm.sleepHours.toStringAsFixed(1)}h',
                onChanged: (v) => vm.sleepHours = v,
              ),

              // ── Work ──
              _SliderInput(
                icon: Icons.work_rounded,
                label: 'Work Hours',
                value: vm.workHours,
                min: kMinWork,
                max: kMaxWork,
                divisions: 48,
                valueLabel: '${vm.workHours.toStringAsFixed(1)}h',
                onChanged: (v) => vm.workHours = v,
              ),

              // ── Mood ──
              _SliderInput(
                icon: Icons.mood_rounded,
                label: 'Mood',
                value: vm.mood.toDouble(),
                min: kMinMood.toDouble(),
                max: kMaxMood.toDouble(),
                divisions: kMaxMood - kMinMood,
                valueLabel: '${vm.mood}/10',
                onChanged: (v) => vm.mood = v.round(),
              ),

              // ── Meetings ──
              _SliderInput(
                icon: Icons.groups_rounded,
                label: 'Meetings',
                value: vm.meetings.toDouble(),
                min: kMinMeetings.toDouble(),
                max: kMaxMeetingsInput.toDouble(),
                divisions: kMaxMeetingsInput,
                valueLabel: '${vm.meetings}',
                onChanged: (v) => vm.meetings = v.round(),
              ),

              // ── Caffeine ──
              _SliderInput(
                icon: Icons.coffee_rounded,
                label: 'Caffeine (cups)',
                value: vm.caffeine.toDouble(),
                min: kMinCaffeine.toDouble(),
                max: kMaxCaffeineInput.toDouble(),
                divisions: kMaxCaffeineInput,
                valueLabel: '${vm.caffeine}',
                onChanged: (v) => vm.caffeine = v.round(),
              ),

              const SizedBox(height: 24),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppTheme.riskCritical),
                  ),
                ),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          await vm.submit();
                          if (vm.result != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ResultScreen()),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Check-In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _SliderInput({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(
                    valueLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
