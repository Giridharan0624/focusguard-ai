import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final riskColor = AppTheme.riskColor(result.riskLevel);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient header with gauge ──
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      riskColor.withValues(alpha: 0.12),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      BurnoutGauge(score: result.score, size: 180),
                      const SizedBox(height: 12),
                      // Risk badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          CheckInViewModel.riskLabel(result.riskLevel)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: riskColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.sl(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back_rounded, size: 20,
                    color: AppTheme.tp(context)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Results'),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── AI Insight ──
                if (checkinVM.isAiLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: SizedBox(height: 16, width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.accent)),
                    ),
                  )
                else if (checkinVM.aiInsight != null)
                  _AiInsightCard(text: checkinVM.aiInsight!),

                // ── Simulation (before/after) ──
                _GlassSection(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_fix_high_rounded,
                              size: 16, color: AppTheme.th(context)),
                          const SizedBox(width: 8),
                          Text('If You Fix It',
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.tp(context))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ScorePill(
                            label: 'Current',
                            score: result.score,
                            color: riskColor,
                          ),
                          Column(
                            children: [
                              Icon(Icons.trending_down_rounded,
                                  color: AppTheme.mintAccent, size: 24),
                              Text(
                                '-${(result.score - result.simulatedScore).round()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.mintAccent,
                                ),
                              ),
                            ],
                          ),
                          _ScorePill(
                            label: 'After',
                            score: result.simulatedScore,
                            color: AppTheme.riskColor(
                                CheckInViewModel.riskLevel(
                                    result.simulatedScore)),
                          ),
                        ],
                      ),
                      if (result.simulatedChanges.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Divider(color: AppTheme.sl(context)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: result.simulatedChanges.entries.map((e) {
                            final sign = e.value > 0 ? '+' : '';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (e.value > 0
                                        ? AppTheme.mintAccent
                                        : AppTheme.riskCritical)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${e.key} $sign${e.value.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: e.value > 0
                                      ? AppTheme.mintAccent
                                      : AppTheme.riskCritical,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Causes ──
                _GlassSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pie_chart_rounded,
                              size: 16, color: AppTheme.th(context)),
                          const SizedBox(width: 8),
                          Text("What's Causing It",
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.tp(context))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(result.topCauseInsight,
                          style: TextStyle(fontSize: 12,
                              color: AppTheme.ts(context), height: 1.4)),
                      const SizedBox(height: 12),
                      CauseChart(causes: result.causes),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Prediction ──
                _GlassSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timeline_rounded,
                              size: 16, color: AppTheme.th(context)),
                          const SizedBox(width: 8),
                          Text('3-Day Prediction',
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.tp(context))),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.riskColor(
                                CheckInViewModel.riskLevel(
                                    result.threeDay.isNotEmpty
                                        ? result.threeDay.last
                                        : result.score),
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              result.threeDay.isNotEmpty
                                  ? '${result.threeDay.last.round()} in 3d'
                                  : '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.riskColor(
                                  CheckInViewModel.riskLevel(
                                      result.threeDay.isNotEmpty
                                          ? result.threeDay.last
                                          : result.score),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TrendChart(
                          todayScore: result.score, threeDay: result.threeDay),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Recovery Plan ──
                Builder(builder: (_) {
                  final suggestions =
                      checkinVM.aiSuggestions ?? result.suggestions;
                  if (suggestions.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            checkinVM.aiSuggestions != null
                                ? Icons.auto_awesome_rounded
                                : Icons.lightbulb_rounded,
                            size: 16,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            checkinVM.aiSuggestions != null
                                ? 'AI Recovery Plan'
                                : 'Recovery Plan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.tp(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...suggestions
                          .map((s) => SuggestionTile(suggestion: s)),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // ── Share / Done button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Insight Card ──
class _AiInsightCard extends StatelessWidget {
  final String text;
  const _AiInsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.08),
            AppTheme.accent.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 14, color: AppTheme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Insight',
                    style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(text,
                    style: TextStyle(fontSize: 13,
                        color: AppTheme.ts(context), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass section wrapper ──
class _GlassSection extends StatelessWidget {
  final Widget child;
  const _GlassSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(context),
      child: child,
    );
  }
}

// ── Score pill (before/after) ──
class _ScorePill extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  const _ScorePill(
      {required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              score.round().toString(),
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppTheme.th(context))),
      ],
    );
  }
}
