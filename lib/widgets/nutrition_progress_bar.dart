import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;

  const NutritionProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (current / goal * 100).clamp(0.0, 100.0) : 0.0;
    final color = AppTheme.nutrientColor(percent);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
              Text(
                '${current.round()}$unit / ${goal.round()}$unit',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
