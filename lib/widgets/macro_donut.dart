import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MacroDonut extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const MacroDonut({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total == 0) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No macros yet',
              style: TextStyle(color: AppTheme.textHint, fontSize: 13)),
        ),
      );
    }

    final pPct = (protein / total * 100).round();
    final cPct = (carbs / total * 100).round();
    final fPct = (fat / total * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 24,
              sections: [
                PieChartSectionData(
                  value: protein,
                  color: const Color(0xFF42A5F5),
                  radius: 18,
                  title: '',
                ),
                PieChartSectionData(
                  value: carbs,
                  color: const Color(0xFFFFA726),
                  radius: 18,
                  title: '',
                ),
                PieChartSectionData(
                  value: fat,
                  color: const Color(0xFFEF5350),
                  radius: 18,
                  title: '',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MacroRow(
                color: const Color(0xFF42A5F5),
                label: 'Protein',
                grams: protein,
                percent: pPct,
              ),
              const SizedBox(height: 8),
              _MacroRow(
                color: const Color(0xFFFFA726),
                label: 'Carbs',
                grams: carbs,
                percent: cPct,
              ),
              const SizedBox(height: 8),
              _MacroRow(
                color: const Color(0xFFEF5350),
                label: 'Fat',
                grams: fat,
                percent: fPct,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final Color color;
  final String label;
  final double grams;
  final int percent;

  const _MacroRow({
    required this.color,
    required this.label,
    required this.grams,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Text('${grams.round()}g',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Text('$percent%',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
