import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../widgets/burnout_gauge.dart';
import '../widgets/cause_chart.dart';
import '../widgets/trend_chart.dart';
import '../widgets/suggestion_tile.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.watch<CheckInViewModel>().result;
    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No results yet')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Burnout gauge ──
            BurnoutGauge(score: result.score, size: 220),
            const SizedBox(height: 24),

            // ── Cause Breakdown ──
            _SectionHeader(title: 'What\'s causing it'),
            const SizedBox(height: 12),
            CauseChart(causes: result.causes),
            const SizedBox(height: 28),

            // ── Prediction ──
            _SectionHeader(title: '3-Day Prediction'),
            const SizedBox(height: 12),
            TrendChart(
              todayScore: result.score,
              threeDay: result.threeDay,
            ),
            const SizedBox(height: 28),

            // ── Recovery Plan ──
            _SectionHeader(title: 'Recovery Plan'),
            const SizedBox(height: 12),
            if (result.suggestions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Looking good! No urgent actions needed.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ...result.suggestions.map((s) => SuggestionTile(suggestion: s)),

            const SizedBox(height: 28),

            // ── Simulation ──
            _SectionHeader(title: 'If You Fix It'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ScoreColumn(
                          label: 'Now',
                          score: result.score,
                          color: AppTheme.riskColor(result.riskLevel),
                        ),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.textHint, size: 28),
                        _ScoreColumn(
                          label: 'After',
                          score: result.simulatedScore,
                          color: AppTheme.riskColor(
                            CheckInViewModel.riskLevel(result.simulatedScore),
                          ),
                        ),
                      ],
                    ),
                    if (result.simulatedChanges.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.surfaceLight),
                      const SizedBox(height: 8),
                      ...result.simulatedChanges.entries.map((e) {
                        final sign = e.value > 0 ? '+' : '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                              Text(
                                '$sign${e.value.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: e.value > 0
                                      ? AppTheme.riskLow
                                      : AppTheme.riskCritical,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final double score;
  final Color color;

  const _ScoreColumn({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          score.round().toString(),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}
