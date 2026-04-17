import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    final entries = vm.entries;

    double avg = 0;
    if (entries.isNotEmpty) {
      avg = entries.fold<double>(0, (s, e) =>
          s + ((e['burnout_score'] as num?)?.toDouble() ?? 0)) / entries.length;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ══ Header ══
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('History',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => vm.load(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.outline(context)),
                    ),
                    child: Icon(Icons.refresh_rounded, size: 18,
                        color: AppTheme.tp(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Summary yellow card ══
            if (entries.isNotEmpty)
              Container(
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
                          const Text('Total Check-ins',
                              style: TextStyle(fontSize: 12, color: AppTheme.onAccent)),
                          const SizedBox(height: 4),
                          Text('${entries.length}',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
                                  color: AppTheme.onAccent, height: 1)),
                          const SizedBox(height: 4),
                          Text('Avg burnout: ${avg.round()}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.onAccent)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.onAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.timeline_rounded,
                          size: 28, color: AppTheme.onAccent),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // ══ History list ══
            if (vm.isLoading && entries.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator()))
            else if (entries.isEmpty)
              _EmptyState()
            else ...[
              Text('Recent Check-ins',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              ...entries.asMap().entries.map((entry) => _HistoryCard(
                  entry: entry.value, isFirst: entry.key == 0)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded,
                  size: 40, color: AppTheme.accent),
            ),
            const SizedBox(height: 16),
            const Text('No check-ins yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Your history will appear here',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isFirst;
  const _HistoryCard({required this.entry, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final date = entry['date'] as String? ?? '';
    final score = (entry['burnout_score'] as num?)?.toDouble() ?? 0;
    final level = CheckInViewModel.riskLevel(score);
    final color = AppTheme.riskColor(level);
    final sleep = (entry['sleep_hours'] as num?)?.toDouble() ?? 0;
    final work = (entry['work_hours'] as num?)?.toDouble() ?? 0;
    final mood = (entry['mood'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(score.round().toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(date,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (isFirst) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Latest',
                            style: TextStyle(fontSize: 9, color: AppTheme.onAccent,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.bedtime_rounded, size: 12, color: AppTheme.textHint),
                    Text(' ${sleep.toStringAsFixed(1)}h  ',
                        style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                    Icon(Icons.work_rounded, size: 12, color: AppTheme.textHint),
                    Text(' ${work.toStringAsFixed(1)}h  ',
                        style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                    Icon(Icons.mood_rounded, size: 12, color: AppTheme.textHint),
                    Text(' $mood/10',
                        style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(CheckInViewModel.riskLabel(level),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}
