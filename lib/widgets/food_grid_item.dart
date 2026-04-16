import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';

class FoodGridItem extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const FoodGridItem({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(food.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  food.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, height: 1.2),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${food.protein.round()}g P | ${food.calories.round()} cal',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
