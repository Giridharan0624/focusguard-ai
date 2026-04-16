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
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(food.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                food.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, height: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                '${food.protein.round()}g P | ${food.calories.round()} cal',
                style: const TextStyle(
                  fontSize: 10,
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
