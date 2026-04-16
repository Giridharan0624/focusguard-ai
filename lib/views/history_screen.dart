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

  void _showDetail(BuildContext context, Map<String, dynamic> entry) {
    final date = entry['date'] as String? ?? '';
    final score = (entry['burnout_score'] as num?)?.toDouble() ?? 0;
    final sleep = (entry['sleep_hours'] as num?)?.toDouble() ?? 0;
    final work = (entry['work_hours'] as num?)?.toDouble() ?? 0;
    final mood = (entry['mood'] as num?)?.toInt() ?? 0;
    final screenTime = (entry['screen_time'] as num?)?.toDouble() ?? 0;
    final caffeine = (entry['caffeine'] as num?)?.toInt() ?? 0;
    final level = CheckInViewModel.riskLevel(score);
    final color = AppTheme.riskColor(level);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(date,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Score: ${score.round()}',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            Text(CheckInViewModel.riskLabel(level),
                style: TextStyle(color: color, fontSize: 14)),
            const SizedBox(height: 20),
            _DetailRow(icon: Icons.bedtime_rounded, label: 'Sleep', value: '${sleep}h'),
            _DetailRow(icon: Icons.work_rounded, label: 'Work', value: '${work}h'),
            _DetailRow(icon: Icons.mood_rounded, label: 'Mood', value: '$mood/10'),
            _DetailRow(icon: Icons.phone_android_rounded, label: 'Screen Time', value: '${screenTime}h'),
            _DetailRow(icon: Icons.coffee_rounded, label: 'Caffeine', value: '$caffeine cups'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => vm.load(),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.history_rounded,
                          size: 64, color: AppTheme.surfaceLight),
                      SizedBox(height: 12),
                      Text(
                        'No check-ins yet',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete a check-in to see your history!',
                        style:
                            TextStyle(color: AppTheme.textHint, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => vm.load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.entries.length,
                    itemBuilder: (_, i) {
                      final entry = vm.entries[i];
                      final date = entry['date'] as String? ?? '';
                      final score =
                          (entry['burnout_score'] as num?)?.toDouble() ?? 0;
                      final level = CheckInViewModel.riskLevel(score);
                      final color = AppTheme.riskColor(level);
                      final sleep =
                          (entry['sleep_hours'] as num?)?.toDouble() ?? 0;
                      final work =
                          (entry['work_hours'] as num?)?.toDouble() ?? 0;
                      final mood = (entry['mood'] as num?)?.toInt() ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () => _showDetail(context, entry),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              score.round().toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          title: Text(date,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            'Sleep ${sleep}h  |  Work ${work}h  |  Mood $mood/10',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textHint),
                          ),
                          trailing: Text(
                            CheckInViewModel.riskLabel(level),
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textHint),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
