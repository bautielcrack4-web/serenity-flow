import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 2: Body Profile (7 pages)
/// Purpose: Collect physical data for real personalization
List<Widget> buildPhase2Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  return [
    // PAGE 6: Age
    _SliderPage(
      question: '¿Cuántos años tenés?',
      subtitle: 'Tu edad influye en tu metabolismo',
      emoji: '🎂',
      unit: 'años',
      min: 16, max: 70, initial: 28, divisions: 54,
      onSubmit: (val) => answer('age', val.toInt()),
    ),

    // PAGE 7: Height
    _SliderPage(
      question: '¿Cuánto medís?',
      subtitle: 'Necesitamos esto para calcular tu plan',
      emoji: '📏',
      unit: 'cm',
      min: 140, max: 195, initial: 165, divisions: 55,
      onSubmit: (val) => answer('height', val),
    ),

    // PAGE 8: Current Weight
    _SliderPage(
      question: '¿Cuánto pesás actualmente?',
      subtitle: 'Esto es 100% privado 🔒',
      emoji: '⚖️',
      unit: 'kg',
      min: 40, max: 150, initial: 70, divisions: 220,
      onSubmit: (val) => answer('current_weight', val),
    ),

    // PAGE 9: Target Weight
    _SliderPage(
      question: '¿Cuál es tu peso objetivo?',
      subtitle: 'Los expertos recomiendan metas realistas y progresivas',
      emoji: '🎯',
      unit: 'kg',
      min: 40, max: 130, initial: 60, divisions: 180,
      onSubmit: (val) => answer('target_weight', val),
    ),

    // PAGE 10: Info break
    InfoBreakCard(
      emoji: '🧬',
      title: 'Tu metabolismo es único',
      fact:
          'Por eso Yuna analiza +15 factores para crear un plan que funcione específicamente para VOS. No hay dos planes iguales.',
      onContinue: next,
    ),

    // PAGE 11: Body type
    _BodyTypePage(
      onSelect: (val) => answer('body_type', val),
      selected: data.bodyType,
    ),

    // PAGE 12: Menstrual cycle
    _QuizPage(
      question: '¿Tu ciclo menstrual es regular?',
      subtitle: 'Esto nos ayuda a adaptar tu plan a tus hormonas',
      options: [
        _Opt('✅', 'Sí, es bastante regular', 'yes'),
        _Opt('🔄', 'No, es irregular', 'no'),
        _Opt('🤷', 'No estoy segura', 'unsure'),
        _Opt('➖', 'No aplica', 'na'),
      ],
      onSelect: (val) => answer('cycle_regular', val == 'yes'),
      selectedValue: data.cycleRegular == true
          ? 'yes'
          : data.cycleRegular == false
              ? 'no'
              : null,
    ),
  ];
}

// ---- Internal helpers ----

class _Opt {
  final String emoji, text, value;
  const _Opt(this.emoji, this.text, this.value);
}

class _QuizPage extends StatelessWidget {
  final String question;
  final String? subtitle;
  final List<_Opt> options;
  final Function(String) onSelect;
  final String? selectedValue;

  const _QuizPage({
    required this.question,
    this.subtitle,
    required this.options,
    required this.onSelect,
    this.selectedValue,
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
                  isSelected: selectedValue == o.value,
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

class _SliderPage extends StatelessWidget {
  final String question, subtitle, unit, emoji;
  final double min, max, initial;
  final int divisions;
  final Function(double) onSubmit;

  const _SliderPage({
    required this.question,
    required this.subtitle,
    required this.emoji,
    required this.unit,
    required this.min,
    required this.max,
    required this.initial,
    required this.divisions,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    double currentVal = initial;
    return StatefulBuilder(
      builder: (context, setState) {
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
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Text(subtitle,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
              ),
              const Spacer(),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Center(
                  child: ScaleReveal(
                    delay: const Duration(milliseconds: 400),
                    child: Text(emoji, style: const TextStyle(fontSize: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: AnimatedSliderInput(
                  label: question,
                  unit: unit,
                  min: min,
                  max: max,
                  initialValue: initial,
                  divisions: divisions,
                  onChanged: (val) => setState(() => currentVal = val),
                ),
              ),
              const Spacer(),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: PremiumCTAButton(
                  text: 'Continuar',
                  onPressed: () => onSubmit(currentVal),
                  showGlow: false,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _BodyTypePage extends StatelessWidget {
  final Function(String) onSelect;
  final String? selected;
  const _BodyTypePage({required this.onSelect, this.selected});

  @override
  Widget build(BuildContext context) {
    final types = [
      ('🍎', 'Manzana', 'apple', 'Más volumen en el torso'),
      ('🍐', 'Pera', 'pear', 'Más volumen en caderas'),
      ('⏳', 'Reloj de arena', 'hourglass', 'Proporciones equilibradas'),
      ('▬', 'Rectángulo', 'rectangle', 'Proporciones uniformes'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: const Text('¿Cuál es tu tipo de cuerpo?',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text('Esto nos ayuda a personalizar tus ejercicios',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              physics: const BouncingScrollPhysics(),
              children: types.asMap().entries.map((entry) {
                final i = entry.key;
                final t = entry.value;
                final isSelected = selected == t.$3;
                return FadeSlideIn(
                  delay: Duration(milliseconds: 150 * i),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSelect(t.$3);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.coral.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.coral : Colors.grey.withValues(alpha: 0.1),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.2), blurRadius: 16)]
                            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.$1, style: const TextStyle(fontSize: 44)),
                          const SizedBox(height: 10),
                          Text(t.$2,
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.coral : AppColors.dark)),
                          const SizedBox(height: 4),
                          Text(t.$4,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
