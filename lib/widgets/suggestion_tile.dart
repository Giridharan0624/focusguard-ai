import 'package:flutter/material.dart';
import '../models/suggestion.dart';
import '../theme/app_theme.dart';

class SuggestionTile extends StatelessWidget {
  final Suggestion suggestion;

  const SuggestionTile({super.key, required this.suggestion});

  IconData get _icon {
    switch (suggestion.category) {
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'mood':
        return Icons.mood_rounded;
      case 'meetings':
        return Icons.groups_rounded;
      case 'caffeine':
        return Icons.coffee_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Color get _priorityColor {
    switch (suggestion.priority) {
      case 'high':
        return AppTheme.riskCritical;
      case 'medium':
        return AppTheme.riskModerate;
      default:
        return AppTheme.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _priorityColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.text,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '-${suggestion.expectedReduction.round()} pts',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.riskLow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
