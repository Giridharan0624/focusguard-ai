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
    final vm = context.read<HistoryViewModel>();
    Future.microtask(() {
      if (mounted) vm.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 64, color: AppTheme.surfaceLight),
                      const SizedBox(height: 12),
                      const Text(
                        'No check-ins yet',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Start your first one!',
                        style: TextStyle(
                            color: AppTheme.textHint, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
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
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
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
    );
  }
}
