import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

/// 🍽️ Nutrition Screen — Meal plans, recipes, water tracker
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _waterGlasses = 3;
  int _selectedDay = DateTime.now().weekday - 1; // 0-indexed Monday

  static const _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
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
              const Text('Nutrición', style: TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 4),
              Text('Tu plan alimenticio personalizado', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
              const SizedBox(height: 24),

              // Macro rings
              _buildMacroSummary(),
              const SizedBox(height: 20),

              // Water tracker
              _buildWaterTracker(),
              const SizedBox(height: 20),

              // Day selector
              _buildDaySelector(),
              const SizedBox(height: 20),

              // Meals
              const Text('Comidas del día', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              ..._meals.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MealCard(meal: m),
              )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroSummary() {
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
              const Text('Macros de hoy', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const Spacer(),
              Text('1,420 / 1,800 cal', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _MacroRing(label: 'Proteínas', value: 0.65, grams: '85g', target: '130g', color: AppColors.coral)),
              Expanded(child: _MacroRing(label: 'Carbos', value: 0.55, grams: '145g', target: '260g', color: AppColors.turquoise)),
              Expanded(child: _MacroRing(label: 'Grasas', value: 0.7, grams: '42g', target: '60g', color: AppColors.lavender)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() {
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
              const Text('Agua', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const Spacer(),
              Text('$_waterGlasses / 8 vasos', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.turquoise)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(8, (i) {
              final filled = i < _waterGlasses;
              return GestureDetector(
                onTap: () => setState(() => _waterGlasses = (i + 1 == _waterGlasses) ? i : i + 1),
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
              onTap: () => setState(() => _selectedDay = i),
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
                  value: value,
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

class _MealData {
  final String emoji, name, description, time, calories;
  final bool isCompleted;
  const _MealData({required this.emoji, required this.name, required this.description, required this.time, required this.calories, this.isCompleted = false});
}

const _meals = [
  _MealData(emoji: '🥣', name: 'Desayuno', description: 'Avena con frutas y semillas de chía', time: '8:00', calories: '350 cal', isCompleted: true),
  _MealData(emoji: '🍎', name: 'Snack mañana', description: 'Manzana con mantequilla de almendras', time: '10:30', calories: '180 cal', isCompleted: true),
  _MealData(emoji: '🥗', name: 'Almuerzo', description: 'Ensalada de pollo con quinoa y aguacate', time: '13:00', calories: '480 cal'),
  _MealData(emoji: '🥜', name: 'Snack tarde', description: 'Yogur griego con nueces', time: '16:00', calories: '200 cal'),
  _MealData(emoji: '🍗', name: 'Cena', description: 'Salmón al horno con verduras asadas', time: '20:00', calories: '420 cal'),
];

class _MealCard extends StatelessWidget {
  final _MealData meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
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
                Text(meal.calories, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Icon(
            meal.isCompleted ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
            color: meal.isCompleted ? AppColors.turquoise : AppColors.gray.withValues(alpha: 0.3),
            size: 28,
          ),
        ],
      ),
    );
  }
}
