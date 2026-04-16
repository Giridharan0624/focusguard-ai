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
    final checkinVM = context.watch<CheckInViewModel>();
    final result = checkinVM.result;
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

            // ── AI Insight ──
            if (checkinVM.isAiLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              )
            else if (checkinVM.aiInsight != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          checkinVM.aiInsight!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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

            // ── Suggestions (AI or rule-based) ──
            Builder(builder: (_) {
              final suggestions =
                  checkinVM.aiSuggestions ?? result.suggestions;
              if (suggestions.isEmpty) return const SizedBox.shrink();
              return _Section(
                title: checkinVM.aiSuggestions != null
                    ? 'AI Recovery Plan'
                    : 'Recovery Plan',
                child: Column(
                  children: suggestions
                      .map((s) => SuggestionTile(suggestion: s))
                      .toList(),
                ),
              );
            }),

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
                  Icon(Icons.arrow_forward_rounded,
                      color: AppTheme.th(context)),
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
            style: TextStyle(fontSize: 12, color: AppTheme.th(context))),
      ],
    );
  }
}
