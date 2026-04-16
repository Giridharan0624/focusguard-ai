import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../widgets/burnout_gauge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final checkinVM = context.watch<CheckInViewModel>();
    final result = checkinVM.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi, ${authVM.userProfile?.name ?? 'there'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authVM.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Score gauge ──
              if (result != null) ...[
                BurnoutGauge(score: result.score),
                const SizedBox(height: 8),
                Text(
                  result.topCauseInsight,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Quick stats ──
                Row(
                  children: [
                    _StatCard(
                      label: 'Tomorrow',
                      value: result.predictedTomorrow.round().toString(),
                      color: AppTheme.riskColor(
                        CheckInViewModel.riskLevel(result.predictedTomorrow),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'After Fix',
                      value: result.simulatedScore.round().toString(),
                      color: AppTheme.riskLow,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ] else ...[
                // ── No check-in yet ──
                const SizedBox(height: 40),
                const Icon(Icons.shield_rounded,
                    size: 80, color: AppTheme.surfaceLight),
                const SizedBox(height: 16),
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete a check-in to see your burnout score',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
              ],

              // ── Demo button ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    checkinVM.loadDemoData();
                    checkinVM.submit();
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Try Demo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
