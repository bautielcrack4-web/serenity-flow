import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 3: Eating Habits (8 pages)
/// Purpose: Understand her relationship with food
List<Widget> buildPhase3Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  final s = L10n.s;
  return [
    // PAGE 13: Meals per day
    _QuizPage(
      question: s.p3MealsQuestion,
      options: [
        _O('1️⃣', s.p3Meals12, '1-2'),
        _O('3️⃣', s.p3Meals3, '3'),
        _O('4️⃣', s.p3Meals45, '4-5'),
        _O('🔄', s.p3MealsIrregular, 'irregular'),
      ],
      onSelect: (v) => answer('meals_per_day', v),
      selected: data.mealsPerDay,
    ),

    // PAGE 14: Water intake
    _WaterPage(onSubmit: (v) => answer('water_glasses', v)),

    // PAGE 15: Info break — water fact
    InfoBreakCard(
      emoji: '💧',
      title: s.p3WaterInfoTitle,
      fact: s.p3WaterInfoFact,
      onContinue: next,
    ),

    // PAGE 16: Dietary restrictions (multi-select)
    _MultiSelectPage(
      question: s.p3DietQuestion,
      subtitle: s.p3DietSubtitle,
      options: [
        _O('🥬', s.p3DietVegetarian, 'vegetarian'),
        _O('🌱', s.p3DietVegan, 'vegan'),
        _O('🌾', s.p3DietGlutenFree, 'gluten_free'),
        _O('🥛', s.p3DietLactoseFree, 'lactose_free'),
        _O('🥜', s.p3DietNutFree, 'nut_free'),
        _O('✅', s.p3DietNone, 'none'),
      ],
      onSubmit: (vals) => answer('dietary_restrictions', vals),
    ),

    // PAGE 17: Snacking
    _QuizPage(
      question: s.p3SnackQuestion,
      options: [
        _O('🚫', s.p3SnackNever, 'never'),
        _O('☀️', s.p3SnackMorning, 'morning'),
        _O('🌅', s.p3SnackAfternoon, 'afternoon'),
        _O('🌙', s.p3SnackNight, 'night'),
        _O('😅', s.p3SnackAllDay, 'all_day'),
      ],
      onSelect: (v) => answer('snacking_time', v),
      selected: data.snackingTime,
    ),

    // PAGE 18: Emotional eating — KEY differentiator
    _QuizPage(
      question: s.p3EmotionalQuestion,
      subtitle: s.p3EmotionalSubtitle,
      options: [
        _O('😔', s.p3EmotionalAlways, 'always'),
        _O('🤷', s.p3EmotionalSometimes, 'sometimes'),
        _O('😌', s.p3EmotionalRarely, 'rarely'),
      ],
      onSelect: (v) => answer('emotional_eating', v),
      selected: data.emotionalEating,
    ),

    // PAGE 19: Cooking preference
    _QuizPage(
      question: s.p3CookingQuestion,
      options: [
        _O('👩‍🍳', s.p3CookingLove, 'love'),
        _O('🍳', s.p3CookingNecessity, 'necessity'),
        _O('📱', s.p3CookingNo, 'no'),
      ],
      onSelect: (v) => answer('cooking_preference', v),
      selected: data.cookingPreference,
    ),

    // PAGE 20: Info break — Yuna approach
    InfoBreakCard(
      emoji: '🧘',
      title: s.p3YunaInfoTitle,
      fact: s.p3YunaInfoFact,
      onContinue: next,
    ),
  ];
}

// ---- Internal helpers ----

class _O {
  final String emoji, text, value;
  const _O(this.emoji, this.text, this.value);
}

class _QuizPage extends StatelessWidget {
  final String question;
  final String? subtitle;
  final List<_O> options;
  final Function(String) onSelect;
  final String? selected;

  const _QuizPage({
    required this.question,
    this.subtitle,
    required this.options,
    required this.onSelect,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(question,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Text(subtitle!,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
            ),
          ],
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = options[i];
                return QuizOptionButton(
                  text: o.text,
                  emoji: o.emoji,
                  isSelected: selected == o.value,
                  onTap: () => onSelect(o.value),
                  staggerIndex: i,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterPage extends StatefulWidget {
  final Function(int) onSubmit;
  const _WaterPage({required this.onSubmit});

  @override
  State<_WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<_WaterPage> {
  int _glasses = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(L10n.s.p3WaterQuestion,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Center(
              child: ScaleReveal(
                delay: const Duration(milliseconds: 300),
                child: const Text('💧', style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Center(
              child: Text('$_glasses',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 64, fontWeight: FontWeight.w800, color: AppColors.dark)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(L10n.s.glassesUnit, style: TextStyle(fontFamily: 'Outfit', fontSize: 18, color: AppColors.dark.withValues(alpha: 0.5))),
          ),
          const SizedBox(height: 24),
          // Water glass icons with staggered animation
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(10, (i) {
                  final filled = i < _glasses;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _glasses = i + 1);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.coral.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: filled ? AppColors.coral.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.12),
                          width: filled ? 2 : 1,
                        ),
                        boxShadow: filled
                            ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.12), blurRadius: 8)]
                            : [],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            filled ? '💧' : '○',
                            key: ValueKey('water_${i}_$filled'),
                            style: TextStyle(fontSize: filled ? 22 : 16),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: PremiumCTAButton(
              text: L10n.s.continueBtn,
              onPressed: () => widget.onSubmit(_glasses),
              showGlow: false,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MultiSelectPage extends StatefulWidget {
  final String question;
  final String? subtitle;
  final List<_O> options;
  final Function(List<String>) onSubmit;

  const _MultiSelectPage({required this.question, this.subtitle, required this.options, required this.onSubmit});

  @override
  State<_MultiSelectPage> createState() => _MultiSelectPageState();
}

class _MultiSelectPageState extends State<_MultiSelectPage> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(widget.question,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Text(widget.subtitle!,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
            ),
          ],
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = widget.options[i];
                return QuizOptionButton(
                  text: o.text,
                  emoji: o.emoji,
                  isSelected: _selected.contains(o.value),
                  staggerIndex: i,
                  onTap: () {
                    setState(() {
                      if (o.value == 'none') {
                        _selected.clear();
                        _selected.add('none');
                      } else {
                        _selected.remove('none');
                        _selected.contains(o.value) ? _selected.remove(o.value) : _selected.add(o.value);
                      }
                    });
                  },
                );
              },
            ),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: PremiumCTAButton(
              text: 'Continuar',
              onPressed: _selected.isNotEmpty ? () => widget.onSubmit(_selected.toList()) : () {},
              showGlow: _selected.isNotEmpty,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
