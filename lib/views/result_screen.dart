import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/checkin_viewmodel.dart';
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

    final wellness = (100 - result.score).round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ══ Header ══
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.outline(context)),
                    ),
                    child: Icon(Icons.arrow_back_rounded, size: 18,
                        color: AppTheme.tp(context)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('Results',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Wellness hero ══
            _WellnessHero(
              wellnessScore: wellness,
              riskLevel: result.riskLevel,
            ),
            const SizedBox(height: 20),

            // ══ AI Insight ══
            if (checkinVM.isAiLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline(context)),
                ),
                child: Row(
                  children: [
                    SizedBox(height: 16, width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.accent)),
                    const SizedBox(width: 12),
                    Text('Generating insight...',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              )
            else if (checkinVM.aiInsight != null)
              _AIInsightCard(text: checkinVM.aiInsight!),

            const SizedBox(height: 16),

            // ══ Simulation (Before/After) ══
            _SimulationCard(
              current: result.score,
              simulated: result.simulatedScore,
              changes: result.simulatedChanges,
            ),
            const SizedBox(height: 16),

            // ══ Causes ══
            _SectionCard(
              icon: Icons.pie_chart_rounded,
              iconColor: const Color(0xFFAB47BC),
              title: "What's Causing It",
              subtitle: result.topCauseInsight,
              child: CauseChart(causes: result.causes),
            ),
            const SizedBox(height: 16),

            // ══ Prediction ══
            _SectionCard(
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF42A5F5),
              title: '3-Day Prediction',
              subtitle: result.threeDay.isNotEmpty
                  ? 'Projected score in 3 days: ${result.threeDay.last.round()}'
                  : null,
              child: TrendChart(todayScore: result.score, threeDay: result.threeDay),
            ),
            const SizedBox(height: 16),

            // ══ Recovery Plan ══
            Builder(builder: (_) {
              final suggestions = checkinVM.aiSuggestions ?? result.suggestions;
              if (suggestions.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          checkinVM.aiSuggestions != null
                              ? Icons.auto_awesome_rounded
                              : Icons.lightbulb_rounded,
                          size: 14, color: AppTheme.onAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        checkinVM.aiSuggestions != null ? 'AI Recovery Plan' : 'Recovery Plan',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...suggestions.map((s) => SuggestionTile(suggestion: s)),
                ],
              );
            }),

            const SizedBox(height: 20),

            // ══ Done button ══
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.22),
                      blurRadius: 16, offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text('Done',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppTheme.onAccent)),
                    ),
                    Icon(Icons.check_rounded, color: AppTheme.onAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessHero extends StatelessWidget {
  final int wellnessScore;
  final String riskLevel;
  const _WellnessHero({required this.wellnessScore, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.22),
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
                const Text('Wellness Score',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppTheme.onAccent)),
                const SizedBox(height: 4),
                Text('$wellnessScore%',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700,
                        color: AppTheme.onAccent, height: 1)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.onAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    CheckInViewModel.riskLabel(riskLevel).toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppTheme.onAccent, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(90, 90),
                  painter: _RingPainter(percent: wellnessScore / 100),
                ),
                Icon(Icons.favorite_rounded, size: 28, color: AppTheme.onAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final bg = Paint()
      ..color = AppTheme.onAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    if (percent > 0) {
      final fg = Paint()
        ..color = AppTheme.onAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, 2 * pi * percent, false, fg,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percent != percent;
}

class _AIInsightCard extends StatelessWidget {
  final String text;
  const _AIInsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(
                color: AppTheme.accent, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 16, color: AppTheme.onAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Insight',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppTheme.accent, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(text,
                    style: TextStyle(fontSize: 13, color: AppTheme.ts(context), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  final double current, simulated;
  final Map<String, double> changes;
  const _SimulationCard({required this.current, required this.simulated,
      required this.changes});

  @override
  Widget build(BuildContext context) {
    final reduction = (current - simulated).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.mintAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_fix_high_rounded,
                    size: 14, color: AppTheme.mintAccent),
              ),
              const SizedBox(width: 10),
              Text('If You Fix It',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreBox(
                label: 'Current', score: current,
                color: AppTheme.riskColor(CheckInViewModel.riskLevel(current)),
              ),
              Column(
                children: [
                  Icon(Icons.arrow_forward_rounded,
                      size: 22, color: AppTheme.th(context)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.mintAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('-$reduction',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppTheme.mintAccent)),
                  ),
                ],
              ),
              _ScoreBox(
                label: 'After', score: simulated,
                color: AppTheme.riskColor(CheckInViewModel.riskLevel(simulated)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  const _ScoreBox({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          alignment: Alignment.center,
          child: Text(score.round().toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppTheme.th(context))),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;
  const _SectionCard({required this.icon, required this.iconColor,
      required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
