import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CauseChart extends StatelessWidget {
  final Map<String, double> causes;

  const CauseChart({super.key, required this.causes});

  @override
  Widget build(BuildContext context) {
    final entries = causes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: entries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  color: AppTheme.causeColor(e.key),
                  radius: 40,
                  title: '${e.value.round()}%',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.causeColor(e.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.key,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.ts(context),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
