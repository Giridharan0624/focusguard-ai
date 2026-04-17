import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import '../viewmodels/nutrition_viewmodel.dart';
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

  double _multiplier(FoodItem food, double qty) =>
      food.unit == 'nos' ? qty : qty / food.servingSize;

  String _fmtQty(double qty) =>
      qty == qty.roundToDouble() ? qty.round().toString() : qty.toStringAsFixed(1);

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
                        color: AppTheme.textHint, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text(food.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(food.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  food.unit == 'nos'
                      ? '${food.calories.round()} cal each'
                      : '${food.calories.round()} cal per ${food.servingSize.round()}${food.unit}',
                  style: TextStyle(fontSize: 12, color: AppTheme.th(context)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QtyBtn(icon: Icons.remove_rounded,
                        enabled: qty > food.stepSize,
                        onTap: () => set(() => qty -= food.stepSize)),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Text(_fmtQty(qty),
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                        Text(food.unit,
                            style: TextStyle(fontSize: 14, color: AppTheme.th(context))),
                      ],
                    ),
                    const SizedBox(width: 20),
                    _QtyBtn(icon: Icons.add_rounded,
                        enabled: true,
                        onTap: () => set(() => qty += food.stepSize)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.sl(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NutMini(label: 'Cal', value: '${(food.calories * mult).round()}'),
                      _NutMini(label: 'Protein', value: '${(food.protein * mult).round()}g'),
                      _NutMini(label: 'Carbs', value: '${(food.carbs * mult).round()}g'),
                      _NutMini(label: 'Fat', value: '${(food.fat * mult).round()}g'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _YellowPill(
                  label: 'Add ${_fmtQty(qty)} ${food.unit}',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.read<NutritionViewModel>().addFood(food.id.toString(), qty);
                    Navigator.pop(ctx);
                  },
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

    final s = vm.summary;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ══ Header ══
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('Nutrition',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                if (s != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: vm.gradeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      children: [
                        Text(vm.grade,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                color: vm.gradeColor)),
                        const SizedBox(width: 6),
                        Text('Grade',
                            style: TextStyle(fontSize: 11, color: vm.gradeColor)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Calorie hero (yellow) ══
            if (s != null)
              _CalorieHero(
                consumed: s.totalCalories,
                goal: s.calorieGoal,
                waterGlasses: vm.waterGlasses,
                onAddWater: () { HapticFeedback.selectionClick(); vm.addWater(); },
                onRemoveWater: vm.removeWater,
              ),
            const SizedBox(height: 20),

            // ══ Burnout penalty ══
            if (vm.burnoutPenalty > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.riskCritical.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.riskCritical.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.riskCritical.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_fire_department_rounded,
                          size: 18, color: AppTheme.riskCritical),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('+${vm.burnoutPenalty.round()} burnout penalty',
                          style: const TextStyle(fontSize: 13, color: AppTheme.riskCritical,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            // ══ AI food advice ══
            if (vm.aiFoodAdvice != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline(context)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome_rounded,
                          size: 16, color: AppTheme.onAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${vm.mealTimeSuggestion} Ideas',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(vm.aiFoodAdvice!,
                              style: TextStyle(fontSize: 12, color: AppTheme.ts(context), height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ══ Macros row ══
            if (s != null)
              Row(
                children: [
                  Expanded(child: _MacroCard(
                    label: 'Protein', current: s.totalProtein, goal: s.proteinGoal,
                    color: const Color(0xFF42A5F5), unit: 'g')),
                  const SizedBox(width: 10),
                  Expanded(child: _MacroCard(
                    label: 'Carbs', current: s.totalCarbs, goal: s.carbGoal,
                    color: const Color(0xFFFFA726), unit: 'g')),
                  const SizedBox(width: 10),
                  Expanded(child: _MacroCard(
                    label: 'Fat', current: s.totalFat, goal: s.fatGoal,
                    color: const Color(0xFFEF5350), unit: 'g')),
                ],
              ),
            const SizedBox(height: 16),

            // ══ Logged meals ══
            if (vm.todayLogs.isNotEmpty) ...[
              Row(
                children: [
                  Text('Logged Today',
                      style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  Text('${vm.todayLogs.length} items',
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 10),
              ...vm.todayLogs.map((log) {
                final food = vm.foodItems.firstWhere(
                  (f) => f.id.toString() == log.foodItemId,
                  orElse: () => vm.foodItems.first,
                );
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.outline(context)),
                  ),
                  child: Row(
                    children: [
                      Text(food.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                          child: Icon(Icons.close_rounded, size: 18, color: AppTheme.th(context)),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // ══ Voice food logging ══
            const VoiceListeningOverlay(),
            GestureDetector(
              onTap: () {
                final voice = context.read<VoiceService>();
                if (voice.isListening) {
                  voice.stopListening();
                } else {
                  voice.startListening(
                      onResult: (text) => _handleVoiceFood(context, text));
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.mic_rounded,
                          size: 18, color: AppTheme.onAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Log food by voice',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('"I had 2 eggs and rice"',
                              style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppTheme.th(context)),
                  ],
                ),
              ),
            ),

            // ══ Add Food ══
            Text('Add Food',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),

            // Filter chips
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in [
                    ['all', 'All'], ['protein-rich', 'Protein'],
                    ['energy', 'Energy'], ['balanced', 'Balanced'], ['light', 'Light'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f[0]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _filter == f[0] ? AppTheme.accent : AppTheme.card(context),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: _filter == f[0] ? AppTheme.accent : AppTheme.outline(context),
                            ),
                          ),
                          child: Text(f[1],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                  color: _filter == f[0] ? AppTheme.onAccent : AppTheme.ts(context))),
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
                  crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: foods.length,
                itemBuilder: (_, i) {
                  final food = foods[i];
                  return GestureDetector(
                    onTap: () => _showAddSheet(context, food),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outline(context)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(food.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Text(food.name,
                                textAlign: TextAlign.center, maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                              food.unit == 'nos'
                                  ? '${food.calories.round()} cal'
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
    );
  }
}

// ══ Calorie Hero ══
class _CalorieHero extends StatelessWidget {
  final double consumed;
  final double goal;
  final int waterGlasses;
  final VoidCallback onAddWater;
  final VoidCallback onRemoveWater;

  const _CalorieHero({
    required this.consumed, required this.goal,
    required this.waterGlasses,
    required this.onAddWater, required this.onRemoveWater,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - consumed).clamp(0.0, goal);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.22),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calories',
                        style: TextStyle(fontSize: 13, color: AppTheme.onAccent)),
                    const SizedBox(height: 4),
                    Text('${consumed.round()}',
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700,
                            color: AppTheme.onAccent, height: 1)),
                    const SizedBox(height: 2),
                    Text('${remaining.round()} kcal left',
                        style: const TextStyle(fontSize: 12, color: AppTheme.onAccent)),
                  ],
                ),
              ),
              SizedBox(
                width: 70, height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.onAccent.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.onAccent),
                    ),
                    Text('${(percent * 100).round()}%',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppTheme.onAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.onAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop_rounded, size: 16, color: AppTheme.onAccent),
                const SizedBox(width: 6),
                Text('$waterGlasses glasses of water',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppTheme.onAccent)),
                const Spacer(),
                GestureDetector(
                  onTap: onRemoveWater,
                  child: const Icon(Icons.remove_rounded, size: 18, color: AppTheme.onAccent),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onAddWater,
                  child: const Icon(Icons.add_rounded, size: 18, color: AppTheme.onAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══ Macro Card ══
class _MacroCard extends StatelessWidget {
  final String label;
  final double current, goal;
  final Color color;
  final String unit;
  const _MacroCard({required this.label, required this.current,
      required this.goal, required this.color, required this.unit});

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 44, height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent, strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text('${(percent * 100).round()}%',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('${current.round()}$unit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppTheme.th(context))),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () { HapticFeedback.selectionClick(); onTap(); } : null,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.accent : AppTheme.sl(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22,
            color: enabled ? AppTheme.onAccent : AppTheme.th(context)),
      ),
    );
  }
}

class _NutMini extends StatelessWidget {
  final String label, value;
  const _NutMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.th(context))),
      ],
    );
  }
}

class _YellowPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _YellowPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppTheme.onAccent)),
            ),
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: AppTheme.onAccent, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 18, color: AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}
