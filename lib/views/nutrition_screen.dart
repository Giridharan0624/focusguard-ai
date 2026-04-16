import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../widgets/food_grid_item.dart';
import '../widgets/nutrition_progress_bar.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<NutritionViewModel>();
    Future.microtask(() {
      if (mounted) vm.loadToday();
    });
  }

  void _showAddDialog(BuildContext context, String foodId, String foodName) {
    double qty = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(foodName),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: qty > 0.5
                    ? () => setDialogState(() => qty -= 0.5)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                qty.toStringAsFixed(1),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setDialogState(() => qty += 0.5),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<NutritionViewModel>().addFood(foodId, qty);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Daily summary ──
                  if (vm.summary != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today\'s Nutrition',
                                style:
                                    Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            NutritionProgressBar(
                              label: 'Protein',
                              current: vm.summary!.totalProtein,
                              goal: vm.summary!.proteinGoal,
                            ),
                            NutritionProgressBar(
                              label: 'Calories',
                              current: vm.summary!.totalCalories,
                              goal: vm.summary!.calorieGoal,
                              unit: 'kcal',
                            ),
                            NutritionProgressBar(
                              label: 'Carbs',
                              current: vm.summary!.totalCarbs,
                              goal: vm.summary!.carbGoal,
                            ),
                            NutritionProgressBar(
                              label: 'Fat',
                              current: vm.summary!.totalFat,
                              goal: vm.summary!.fatGoal,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Logged meals ──
                  if (vm.todayLogs.isNotEmpty) ...[
                    Text('Logged Today',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: vm.todayLogs.map((log) {
                        final food = vm.foodItems.firstWhere(
                          (f) => f.id.toString() == log.foodItemId,
                          orElse: () => vm.foodItems.first,
                        );
                        return Chip(
                          label: Text(
                              '${food.icon} ${food.name} x${log.quantity}'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: log.id != null
                              ? () => vm.removeLog(log.id!)
                              : null,
                          backgroundColor: AppTheme.surfaceLight,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Deficit alerts ──
                  if (vm.summary != null) ...[
                    for (final entry in vm.summary!.deficitPercents.entries)
                      if (entry.value > 50)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            color: AppTheme.riskCritical.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_rounded,
                                      color: AppTheme.riskModerate, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Low ${entry.key} — ${vm.summary!.deficits[entry.key]!.round()}${entry.key == "calories" ? "kcal" : "g"} below goal',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],

                  // ── Recommendations ──
                  if (vm.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Suggested Foods',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.recommendations.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final food = vm.recommendations[i];
                          return SizedBox(
                            width: 100,
                            child: FoodGridItem(
                              food: food,
                              onTap: () => _showAddDialog(
                                  context, food.id.toString(), food.name),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Food grid ──
                  Text('Add Food',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: vm.foodItems.length,
                    itemBuilder: (_, i) {
                      final food = vm.foodItems[i];
                      return FoodGridItem(
                        food: food,
                        onTap: () => _showAddDialog(
                            context, food.id.toString(), food.name),
                      );
                    },
                  ),

                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(vm.errorMessage!,
                          style:
                              const TextStyle(color: AppTheme.riskCritical)),
                    ),
                ],
              ),
            ),
    );
  }
}
