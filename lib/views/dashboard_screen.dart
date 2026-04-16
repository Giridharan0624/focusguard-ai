import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../widgets/burnout_gauge.dart';
import 'chat_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final checkinVM = context.watch<CheckInViewModel>();
    final result = checkinVM.result;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.psychology_rounded),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()},',
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textHint),
                        ),
                        Text(
                          authVM.userProfile?.name ?? 'there',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded,
                        color: AppTheme.textHint),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              if (result != null) ...[
                // ── Score ──
                Center(child: BurnoutGauge(score: result.score, size: 200)),
                const SizedBox(height: 16),

                // ── Insight (AI or static) ──
                Center(
                  child: checkinVM.isAiLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          checkinVM.aiInsight ?? result.topCauseInsight,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textSecondary),
                        ),
                ),
                const SizedBox(height: 24),

                // ── Two stats ──
                Row(
                  children: [
                    _Stat(
                      label: 'Tomorrow',
                      value: '${result.predictedTomorrow.round()}',
                      color: AppTheme.riskColor(
                          CheckInViewModel.riskLevel(
                              result.predictedTomorrow)),
                    ),
                    const SizedBox(width: 12),
                    _Stat(
                      label: 'If you fix it',
                      value: '${result.simulatedScore.round()}',
                      color: AppTheme.riskLow,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ���─ View details ──
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ResultScreen())),
                    child: const Text('View full results →'),
                  ),
                ),
              ] else ...[
                // ── Empty state ──
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded,
                            size: 56, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 20),
                      const Text('No check-in yet today',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text(
                          'Tap Check-In to get your burnout score',
                          style: TextStyle(
                              fontSize: 14, color: AppTheme.textHint)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const SizedBox(height: 8),

              // ── Demo (subtle) ──
              Center(
                child: TextButton.icon(
                  onPressed: checkinVM.isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          checkinVM.loadDemoData();
                          checkinVM.submit();
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                      result != null ? 'Run demo again' : 'Try demo',
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;

  const _Stat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textHint)),
          ],
        ),
      ),
    );
  }
}
