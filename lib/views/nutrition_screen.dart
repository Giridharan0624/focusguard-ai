import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/macro_donut.dart';
import '../widgets/mic_button.dart';
import '../widgets/nutrition_progress_bar.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    final vm = context.read<NutritionViewModel>();
    Future.microtask(() { if (mounted) vm.loadToday(); });
  }

  Future<void> _handleVoiceFood(BuildContext context, String text) async {
    final vm = context.read<NutritionViewModel>();
    // Use Groq to parse food from voice
    const groqKey = String.fromEnvironment('GROQ_API_KEY');
    if (groqKey.isEmpty) return;
    final gemini = GeminiService(apiKey: groqKey);

    final parsed = await gemini.parseFoodFromVoice(text);
    if (parsed == null || parsed.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not understand. Try tapping a food item.')),
        );
      }
      return;
    }

    // Match parsed names to food items and add them
    int added = 0;
    for (final item in parsed) {
      final name = (item['name'] as String? ?? '').toLowerCase();
      final qty = (item['quantity'] as num?)?.toDouble() ?? 1.0;
      final match = vm.foodItems.where(
        (f) => f.name.toLowerCase().contains(name) || name.contains(f.name.toLowerCase()),
      );
      if (match.isNotEmpty) {
        await vm.addFood(match.first.id.toString(), qty);
        added++;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(added > 0 ? 'Added $added item${added > 1 ? "s" : ""}' : 'No matching foods found')),
      );
    }
  }

  void _addFood(String foodId, String name) {
    double qty = 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.textHint,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: qty > 0.5 ? () => set(() => qty -= 0.5) : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 28)),
                  const SizedBox(width: 16),
                  Text(qty.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => set(() => qty += 0.5),
                    icon: const Icon(Icons.add_circle_outline, size: 28)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<NutritionViewModel>().addFood(foodId, qty);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();

    if (vm.isLoading && vm.foodItems.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: Calorie ring + Grade + Water ──
              if (vm.summary != null)
                Row(
                  children: [
                    CalorieRing(
                        consumed: vm.summary!.totalCalories,
                        goal: vm.summary!.calorieGoal,
                        size: 120),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          // Grade
                          Text(vm.grade,
                              style: TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold,
                                  color: vm.gradeColor)),
                          const Text('Nutrition Grade',
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.textHint)),
                          const SizedBox(height: 12),
                          // Water
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: vm.removeWater,
                                  child: const Icon(Icons.remove, size: 18,
                                      color: AppTheme.textHint)),
                              const SizedBox(width: 6),
                              const Icon(Icons.water_drop_rounded,
                                  size: 16, color: Color(0xFF42A5F5)),
                              Text(' ${vm.waterGlasses}',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold,
                                      color: Color(0xFF42A5F5))),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  vm.addWater();
                                },
                                child: const Icon(Icons.add, size: 18,
                                    color: Color(0xFF42A5F5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // ── Burnout penalty (only if present) ──
              if (vm.burnoutPenalty > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.riskCritical.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppTheme.riskCritical, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '+${vm.burnoutPenalty.round()} burnout penalty — eat more to fix',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.riskCritical),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── AI Food Advice ──
              if (vm.isAiFoodLoading)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(height: 16, width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Getting AI meal suggestions...',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              else if (vm.aiFoodAdvice != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: AppTheme.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${vm.mealTimeSuggestion} Ideas',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(vm.aiFoodAdvice!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Macros (expandable) ─��
              if (vm.summary != null)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Macros & Goals',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  initiallyExpanded: false,
                  children: [
                    MacroDonut(
                      protein: vm.summary!.totalProtein,
                      carbs: vm.summary!.totalCarbs,
                      fat: vm.summary!.totalFat,
                    ),
                    const SizedBox(height: 12),
                    NutritionProgressBar(label: 'Protein',
                        current: vm.summary!.totalProtein,
                        goal: vm.summary!.proteinGoal),
                    NutritionProgressBar(label: 'Calories',
                        current: vm.summary!.totalCalories,
                        goal: vm.summary!.calorieGoal, unit: 'kcal'),
                    NutritionProgressBar(label: 'Carbs',
                        current: vm.summary!.totalCarbs,
                        goal: vm.summary!.carbGoal),
                    NutritionProgressBar(label: 'Fat',
                        current: vm.summary!.totalFat,
                        goal: vm.summary!.fatGoal),
                    const SizedBox(height: 8),
                  ],
                ),

              // ── Logged meals ──
              if (vm.todayLogs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Logged',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${vm.todayLogs.length} items',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textHint)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: vm.todayLogs.map((log) {
                      final food = vm.foodItems.firstWhere(
                        (f) => f.id.toString() == log.foodItemId,
                        orElse: () => vm.foodItems.first,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text('${food.icon} ${food.name}',
                              style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: log.id != null
                              ? () => vm.removeLog(log.id!)
                              : null,
                          backgroundColor: AppTheme.surfaceLight,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── Voice food logging ──
              const VoiceListeningOverlay(),

              // ── Add food section ──
              Row(
                children: [
                  const Text('Add Food',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  MicButton(
                    size: 34,
                    onResult: (text) => _handleVoiceFood(context, text),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filter chips
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final f in [
                      ['all', 'All'],
                      ['protein-rich', 'Protein'],
                      ['energy', 'Energy'],
                      ['balanced', 'Balanced'],
                      ['light', 'Light'],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f[0]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _filter == f[0]
                                  ? AppTheme.primary
                                  : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Text(f[1],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _filter == f[0]
                                        ? Colors.white
                                        : AppTheme.textSecondary)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Food grid
              Builder(builder: (_) {
                var foods = vm.foodItems;
                if (_filter != 'all') {
                  foods = foods.where((f) => f.category == _filter).toList();
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (_, i) {
                    final food = foods[i];
                    return GestureDetector(
                      onTap: () =>
                          _addFood(food.id.toString(), food.name),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(food.icon,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(food.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, height: 1.2)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
