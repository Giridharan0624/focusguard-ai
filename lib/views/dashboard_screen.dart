import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import '../widgets/burnout_gauge.dart';
import 'chat_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const DashboardScreen({super.key, required this.onSwitchTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().load();
    });
  }

  String _greeting(double? score) {
    final hour = DateTime.now().hour;
    final time = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    if (score == null) return 'Good $time';
    if (score <= 25) return 'Great $time';
    if (score <= 50) return 'Good $time';
    if (score <= 75) return 'Hang in there';
    return 'Take it easy';
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final checkinVM = context.watch<CheckInViewModel>();
    final historyVM = context.watch<HistoryViewModel>();
    final result = checkinVM.result;

    // Extract history scores for mini trend
    final historyScores = historyVM.entries
        .take(7)
        .map((e) => (e['burnout_score'] as num?)?.toDouble() ?? 0.0)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatScreen())),
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
                        Text('${_greeting(result?.score)},',
                            style: TextStyle(fontSize: 14, color: AppTheme.th(context))),
                        Text(authVM.userProfile?.name ?? 'there',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  // Streak
                  if (historyScores.length >= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.warmAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('\u{1F525}', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('${historyScores.length}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppTheme.warmAccent)),
                        ],
                      ),
                    ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.sl(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.settings_rounded, size: 20,
                          color: AppTheme.th(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (result != null) ...[
                // ── Score ──
                Center(child: BurnoutGauge(score: result.score, size: 180)),
                const SizedBox(height: 12),

                // ── AI insight ──
                Center(
                  child: checkinVM.isAiLoading
                      ? SizedBox(height: 16, width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                      : Text(
                          checkinVM.aiInsight ?? result.topCauseInsight,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppTheme.ts(context)),
                        ),
                ),
                const SizedBox(height: 20),

                // ── Stats row ──
                Row(
                  children: [
                    _Stat(label: 'Tomorrow',
                        value: '${result.predictedTomorrow.round()}',
                        color: AppTheme.riskColor(CheckInViewModel.riskLevel(result.predictedTomorrow))),
                    const SizedBox(width: 10),
                    _Stat(label: 'After fix',
                        value: '${result.simulatedScore.round()}',
                        color: AppTheme.riskLow),
                  ],
                ),
                const SizedBox(height: 12),

                // ── View results ──
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ResultScreen())),
                    child: const Text('View full results  \u2192'),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Today's summary card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCard(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Check-In",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppTheme.th(context))),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MiniStat(icon: Icons.bedtime_rounded,
                              value: '${result.score > 0 ? checkinVM.sleepHours.toStringAsFixed(1) : "-"}h',
                              label: 'Sleep', color: AppTheme.colorSleep),
                          _MiniStat(icon: Icons.work_rounded,
                              value: '${result.score > 0 ? checkinVM.workHours.toStringAsFixed(1) : "-"}h',
                              label: 'Work', color: AppTheme.colorWork),
                          _MiniStat(icon: Icons.phone_android_rounded,
                              value: '${result.score > 0 ? checkinVM.screenTime.toStringAsFixed(1) : "-"}h',
                              label: 'Screen', color: AppTheme.colorScreenTime),
                          _MiniStat(icon: Icons.coffee_rounded,
                              value: '${result.score > 0 ? checkinVM.caffeine : "-"}',
                              label: 'Caffeine', color: AppTheme.colorCaffeine),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 7-day mini trend ──
                if (historyScores.length >= 2)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassCard(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('7-Day Trend',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                    color: AppTheme.th(context))),
                            const Spacer(),
                            Text('${historyScores.length} check-ins',
                                style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 60,
                          child: LineChart(
                            LineChartData(
                              minY: 0, maxY: 100,
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: historyScores.asMap().entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                                  isCurved: true,
                                  color: AppTheme.accent,
                                  barWidth: 2.5,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (s, v, b, i) => FlDotCirclePainter(
                                      radius: 3,
                                      color: AppTheme.riskColor(
                                          CheckInViewModel.riskLevel(s.y)),
                                      strokeWidth: 0,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.accent.withValues(alpha: 0.08),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                // ── Empty state ──
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.accent.withValues(alpha: 0.25),
                                blurRadius: 24, spreadRadius: 2),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text('No check-in yet today',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Start your daily check-in to track burnout',
                          style: TextStyle(fontSize: 14, color: AppTheme.th(context))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 12),

              // ── Demo button ──
              Center(
                child: TextButton.icon(
                  onPressed: checkinVM.isLoading ? null : () {
                    HapticFeedback.lightImpact();
                    checkinVM.loadDemoData();
                    checkinVM.submit();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(result != null ? 'Run demo again' : 'Try demo',
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

// ── Stat card ──
class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: AppTheme.glassCard(context),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: AppTheme.th(context))),
          ],
        ),
      ),
    );
  }
}

// ── Mini stat in today's summary ──
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _MiniStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.th(context))),
      ],
    );
  }
}

