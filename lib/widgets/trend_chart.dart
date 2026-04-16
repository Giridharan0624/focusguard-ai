import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrendChart extends StatelessWidget {
  final double todayScore;
  final List<double> threeDay;

  const TrendChart({
    super.key,
    required this.todayScore,
    required this.threeDay,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      FlSpot(0, todayScore),
      for (int i = 0; i < threeDay.length; i++)
        FlSpot((i + 1).toDouble(), threeDay[i]),
    ];

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.surfaceLight,
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  const labels = ['Today', '+1', '+2', '+3'];
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, bar, index) => FlDotCirclePainter(
                  radius: 5,
                  color: AppTheme.primary,
                  strokeWidth: 2,
                  strokeColor: AppTheme.background,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
