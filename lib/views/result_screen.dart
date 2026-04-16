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
      return const Scaffold(body: Center(child: Text('No results yet')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ── Gauge ──
            BurnoutGauge(score: result.score, size: 180),
            const SizedBox(height: 20),

            // ── Causes ──
            _Section(
              title: "What's causing it",
              child: CauseChart(causes: result.causes),
            ),

            // ── Prediction ──
            _Section(
              title: '3-Day Prediction',
              child: TrendChart(
                  todayScore: result.score, threeDay: result.threeDay),
            ),

            // ── Suggestions ──
            if (result.suggestions.isNotEmpty)
              _Section(
                title: 'Recovery Plan',
                child: Column(
                  children: result.suggestions
                      .map((s) => SuggestionTile(suggestion: s))
                      .toList(),
                ),
              ),

            // ── Simulation ──
            _Section(
              title: 'If You Fix It',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreColumn(
                      label: 'Now',
                      score: result.score,
                      color: AppTheme.riskColor(result.riskLevel)),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppTheme.textHint),
                  _ScoreColumn(
                      label: 'After',
                      score: result.simulatedScore,
                      color: AppTheme.riskColor(
                          CheckInViewModel.riskLevel(result.simulatedScore))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final double score;
  final Color color;

  const _ScoreColumn(
      {required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(score.round().toString(),
            style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
      ],
    );
  }
}
