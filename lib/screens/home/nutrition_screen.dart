import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/services/nutrition_service.dart';
import 'package:serenity_flow/services/sound_service.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/components/pro_gate.dart';

/// 🍽️ Nutrition Screen — Meal plans, recipes, water tracker
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _waterGlasses = 0;
  int _selectedDay = DateTime.now().weekday - 1; // 0-indexed Monday
  bool _isLoading = true;
  List<MealData> _meals = [];

  final _nutritionService = NutritionService();

  static const _dayNamesEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayNamesEs = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  List<String> get _dayNames => L10n.locale == 'es' ? _dayNamesEs : _dayNamesEn;

  DateTime get _selectedDate {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: _selectedDay));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final date = _selectedDate;
    final results = await Future.wait([
      _nutritionService.getMealsForDate(date),
      _nutritionService.getWaterGlasses(date),
    ]);
    if (mounted) {
      setState(() {
        _meals = results[0] as List<MealData>;
        _waterGlasses = results[1] as int;
        _isLoading = false;
      });
    }
  }

  void _onDayChanged(int day) {
    setState(() => _selectedDay = day);
    _loadData();
  }

  void _onWaterTap(int index) {
    final newGlasses = (index + 1 == _waterGlasses) ? index : index + 1;
    setState(() => _waterGlasses = newGlasses);
    _nutritionService.setWaterGlasses(newGlasses, _selectedDate);
    SoundService().playWaterDrop();
  }

  void _onToggleMeal(MealData meal) {
    if (!RevenueCatService().isPro) {
      showProGate(context);
      return;
    }
    final newCompleted = !meal.isCompleted;
    setState(() {
      _meals = _meals.map((m) => m.mealType == meal.mealType
          ? MealData(
              emoji: m.emoji,
              name: m.name,
              description: m.description,
              time: m.time,
              calories: m.calories,
              mealType: m.mealType,
              isCompleted: newCompleted,
            )
          : m).toList();
    });
    _nutritionService.toggleMealCompleted(meal.mealType, _selectedDate, newCompleted);
    newCompleted ? SoundService().playComplete() : SoundService().playTap();
  }

  int get _totalCalories => _meals.fold(0, (sum, m) => sum + m.calories);
  int get _completedCalories => _meals.where((m) => m.isCompleted).fold(0, (sum, m) => sum + m.calories);

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(s.nutTitle, style: const TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 4),
              Text(s.nutSubtitle, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
              const SizedBox(height: 24),
              _buildMacroSummary(),
              const SizedBox(height: 20),
              _buildWaterTracker(),
              const SizedBox(height: 20),
              _buildDaySelector(),
              const SizedBox(height: 20),
              Text(s.nutMealsTitle, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: AppColors.coral),
                ))
              else
                ..._meals.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MealCard(meal: m, onToggle: () => _onToggleMeal(m)),
                )),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroSummary() {
    final s = L10n.s;
    final total = _totalCalories;
    final completed = _completedCalories;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.nutMacrosToday, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const Spacer(),
              Text('$completed / $total ${s.nutCalLabel}', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _MacroRing(label: s.nutProteins, value: total > 0 ? completed / total : 0, grams: '${(completed * 0.3 / 4).round()}g', target: '${(total * 0.3 / 4).round()}g', color: AppColors.coral)),
              Expanded(child: _MacroRing(label: s.nutCarbs, value: total > 0 ? completed / total * 0.85 : 0, grams: '${(completed * 0.45 / 4).round()}g', target: '${(total * 0.45 / 4).round()}g', color: AppColors.turquoise)),
              Expanded(child: _MacroRing(label: s.nutFats, value: total > 0 ? completed / total * 0.9 : 0, grams: '${(completed * 0.25 / 9).round()}g', target: '${(total * 0.25 / 9).round()}g', color: AppColors.lavender)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() {
    final s = L10n.s;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(s.nutWater, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const Spacer(),
              Text('$_waterGlasses / 8 ${s.nutGlasses}', style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.turquoise)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(8, (i) {
              final filled = i < _waterGlasses;
              return GestureDetector(
                onTap: () => _onWaterTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 42,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.turquoise.withValues(alpha: 0.15) : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: filled ? AppColors.turquoise : Colors.transparent, width: 2),
                  ),
                  child: Center(
                    child: Text(filled ? '💧' : '🥛', style: TextStyle(fontSize: filled ? 16 : 14)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (_, i) {
          final isSelected = i == _selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onDayChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.coral : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 8)] : AppShadows.card,
                ),
                child: Center(
                  child: Text(_dayNames[i], style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.dark)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  final String label, grams, target;
  final double value;
  final Color color;

  const _MacroRing({required this.label, required this.value, required this.grams, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64, height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64, height: 64,
                child: CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(grams, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark)),
        Text(target, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.gray.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealData meal;
  final VoidCallback onToggle;
  const _MealCard({required this.meal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: meal.isCompleted ? Border.all(color: AppColors.turquoise.withValues(alpha: 0.2)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: meal.isCompleted ? AppColors.turquoise.withValues(alpha: 0.1) : AppColors.lightGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(meal.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(meal.name, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: meal.isCompleted ? AppColors.turquoise : AppColors.dark)),
                    const SizedBox(width: 8),
                    Text(meal.time, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.gray.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(meal.description, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.6))),
                const SizedBox(height: 2),
                Text('${meal.calories} ${s.nutCalLabel}', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral.withValues(alpha: 0.7))),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              meal.isCompleted ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: meal.isCompleted ? AppColors.turquoise : AppColors.gray.withValues(alpha: 0.3),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
