import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/mic_button.dart';

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
    const groqKey = String.fromEnvironment('GROQ_API_KEY');
    if (groqKey.isEmpty) return;
    final gemini = GeminiService(apiKey: groqKey);
    final parsed = await gemini.parseFoodFromVoice(text);
    if (parsed == null || parsed.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not understand. Try tapping a food.')),
        );
      }
      return;
    }
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

  String _fmtQty(double qty) =>
      qty == qty.roundToDouble() ? qty.round().toString() : qty.toStringAsFixed(1);

  // Compute nutrition multiplier based on unit type
  double _multiplier(FoodItem food, double qty) =>
      food.unit == 'nos' ? qty : qty / food.servingSize;

  void _showAddSheet(BuildContext context, FoodItem food) {
    double qty = food.unit == 'nos' ? 1 : food.servingSize;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          final mult = _multiplier(food, qty);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.textHint,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),

                Text(food.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  food.unit == 'nos'
                      ? '${food.calories.round()} cal · ${food.protein.round()}g protein each'
                      : '${food.calories.round()} cal · ${food.protein.round()}g protein per ${food.servingSize.round()}${food.unit}',
                  style: TextStyle(fontSize: 12, color: AppTheme.th(context)),
                ),

                const SizedBox(height: 24),

                // Quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      enabled: qty > food.stepSize,
                      onTap: () => set(() => qty -= food.stepSize),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Text(_fmtQty(qty),
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                        Text(food.unit,
                            style: TextStyle(fontSize: 14, color: AppTheme.th(context),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    _QtyButton(
                      icon: Icons.add,
                      enabled: true,
                      onTap: () => set(() => qty += food.stepSize),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Nutrition preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.sl(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NutrientMini(label: 'Cal', value: '${(food.calories * mult).round()}'),
                      _NutrientMini(label: 'Protein', value: '${(food.protein * mult).round()}g'),
                      _NutrientMini(label: 'Carbs', value: '${(food.carbs * mult).round()}g'),
                      _NutrientMini(label: 'Fat', value: '${(food.fat * mult).round()}g'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.read<NutritionViewModel>().addFood(food.id.toString(), qty);
                      Navigator.pop(ctx);
                    },
                    child: Text('Add ${_fmtQty(qty)} ${food.unit}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();

    if (vm.isLoading && vm.foodItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Calorie ring + Grade + Water ──
              if (vm.summary != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCard(context),
                  child: Row(
                    children: [
                      CalorieRing(
                          consumed: vm.summary!.totalCalories,
                          goal: vm.summary!.calorieGoal,
                          size: 110),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Text(vm.grade,
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                                    color: vm.gradeColor)),
                            Text('Nutrition Grade',
                                style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                            const SizedBox(height: 10),
                            // Water
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                      onTap: vm.removeWater,
                                      child: Icon(Icons.remove_rounded, size: 16,
                                          color: AppTheme.th(context))),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.water_drop_rounded,
                                      size: 14, color: Color(0xFF42A5F5)),
                                  Text(' ${vm.waterGlasses}',
                                      style: const TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.w700,
                                          color: Color(0xFF42A5F5))),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () { HapticFeedback.selectionClick(); vm.addWater(); },
                                    child: const Icon(Icons.add_rounded, size: 16,
                                        color: Color(0xFF42A5F5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // ── Burnout penalty ──
              if (vm.burnoutPenalty > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.riskCritical.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppTheme.riskCritical, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('+${vm.burnoutPenalty.round()} burnout penalty',
                            style: const TextStyle(fontSize: 12, color: AppTheme.riskCritical)),
                      ),
                    ],
                  ),
                ),

              // ── AI Food Advice ──
              if (vm.isAiFoodLoading)
                _AiCard(child: Row(children: [
                  const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text('Getting meal ideas...', style: TextStyle(fontSize: 12, color: AppTheme.ts(context))),
                ]))
              else if (vm.aiFoodAdvice != null)
                _AiCard(child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${vm.mealTimeSuggestion} Ideas',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(vm.aiFoodAdvice!,
                            style: TextStyle(fontSize: 12, color: AppTheme.ts(context), height: 1.4)),
                      ],
                    )),
                  ],
                )),

              // ── Macros & Goals ──
              if (vm.summary != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCard(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pie_chart_rounded, size: 16, color: AppTheme.th(context)),
                          const SizedBox(width: 8),
                          const Text('Macro Split',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Macro circles row
                      Row(
                        children: [
                          _MacroCircle(
                            label: 'Protein',
                            current: vm.summary!.totalProtein,
                            goal: vm.summary!.proteinGoal,
                            color: const Color(0xFF42A5F5),
                            unit: 'g',
                          ),
                          const SizedBox(width: 10),
                          _MacroCircle(
                            label: 'Carbs',
                            current: vm.summary!.totalCarbs,
                            goal: vm.summary!.carbGoal,
                            color: const Color(0xFFFFA726),
                            unit: 'g',
                          ),
                          const SizedBox(width: 10),
                          _MacroCircle(
                            label: 'Fat',
                            current: vm.summary!.totalFat,
                            goal: vm.summary!.fatGoal,
                            color: const Color(0xFFEF5350),
                            unit: 'g',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Daily Goals progress ──
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCard(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 16, color: AppTheme.th(context)),
                          const SizedBox(width: 8),
                          const Text('Daily Goals',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _GoalRow(label: 'Protein', current: vm.summary!.totalProtein,
                          goal: vm.summary!.proteinGoal, unit: 'g', color: const Color(0xFF42A5F5)),
                      const SizedBox(height: 10),
                      _GoalRow(label: 'Calories', current: vm.summary!.totalCalories,
                          goal: vm.summary!.calorieGoal, unit: 'kcal', color: AppTheme.warmAccent),
                      const SizedBox(height: 10),
                      _GoalRow(label: 'Carbs', current: vm.summary!.totalCarbs,
                          goal: vm.summary!.carbGoal, unit: 'g', color: const Color(0xFFFFA726)),
                      const SizedBox(height: 10),
                      _GoalRow(label: 'Fat', current: vm.summary!.totalFat,
                          goal: vm.summary!.fatGoal, unit: 'g', color: const Color(0xFFEF5350)),
                    ],
                  ),
                ),
              ],

              // ── Logged meals ──
              if (vm.todayLogs.isNotEmpty) ...[
                Row(
                  children: [
                    const Text('Logged Today',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${vm.todayLogs.length} items',
                        style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                  ],
                ),
                const SizedBox(height: 8),
                ...vm.todayLogs.map((log) {
                  final food = vm.foodItems.firstWhere(
                    (f) => f.id.toString() == log.foodItemId,
                    orElse: () => vm.foodItems.first,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: AppTheme.glassCard(context),
                    child: Row(
                      children: [
                        Text(food.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(
                                '${_fmtQty(log.quantity)} ${food.unit} · ${(food.calories * _multiplier(food, log.quantity)).round()} cal',
                                style: TextStyle(fontSize: 11, color: AppTheme.th(context)),
                              ),
                            ],
                          ),
                        ),
                        if (log.id != null)
                          GestureDetector(
                            onTap: () => vm.removeLog(log.id!),
                            child: Icon(Icons.close_rounded, size: 16, color: AppTheme.th(context)),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],

              // ── Voice overlay ──
              const VoiceListeningOverlay(),

              // ── Add Food header ──
              Row(
                children: [
                  const Text('Add Food',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  MicButton(size: 32, onResult: (text) => _handleVoiceFood(context, text)),
                ],
              ),
              const SizedBox(height: 10),

              // ── Filter chips ──
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final f in [
                      ['all', 'All'], ['protein-rich', 'Protein'],
                      ['energy', 'Energy'], ['balanced', 'Balanced'], ['light', 'Light'],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f[0]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _filter == f[0] ? AppTheme.accent : AppTheme.sl(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(f[1], style: TextStyle(fontSize: 12,
                                color: _filter == f[0] ? Colors.white : AppTheme.ts(context))),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Food grid ──
              Builder(builder: (_) {
                var foods = vm.foodItems;
                if (_filter != 'all') {
                  foods = foods.where((f) => f.category == _filter).toList();
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (_, i) {
                    final food = foods[i];
                    return GestureDetector(
                      onTap: () => _showAddSheet(context, food),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppTheme.glassCard(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(food.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(food.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, height: 1.2)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                                food.unit == 'nos'
                                    ? '${food.calories.round()} cal each'
                                    : '${food.servingSize.round()}${food.unit}',
                                style: TextStyle(fontSize: 9, color: AppTheme.th(context))),
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

class _AiCard extends StatelessWidget {
  final Widget child;
  const _AiCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () { HapticFeedback.selectionClick(); onTap(); } : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.accent.withValues(alpha: 0.1) : AppTheme.sl(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22,
            color: enabled ? AppTheme.accent : AppTheme.th(context)),
      ),
    );
  }
}

class _NutrientMini extends StatelessWidget {
  final String label, value;
  const _NutrientMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.th(context))),
      ],
    );
  }
}

// ── Macro circle with progress ring ──
class _MacroCircle extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;

  const _MacroCircle({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 5,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '${(percent * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${current.round()}$unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(label,
                style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
          ],
        ),
      ),
    );
  }
}

// ── Goal progress row ──
class _GoalRow extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;
  final Color color;

  const _GoalRow({
    required this.label,
    required this.current,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - current).clamp(0.0, goal);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text(
              '${current.round()} / ${goal.round()} $unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: percent >= 0.7 ? AppTheme.mintAccent : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(
              percent >= 0.7 ? AppTheme.mintAccent : color,
            ),
          ),
        ),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${remaining.round()} $unit left',
                style: TextStyle(fontSize: 10, color: AppTheme.th(context)),
              ),
            ),
          ),
      ],
    );
  }
}
