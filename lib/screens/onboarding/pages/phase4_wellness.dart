import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 4: Emotional Wellness (7 pages)
/// Purpose: Activate Yuna's differentiator (meditation + emotional)
List<Widget> buildPhase4Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  return [
    // PAGE 21: Stress level
    _StressLevelPage(onSubmit: (v) => answer('stress_level', v)),

    // PAGE 22: Sleep hours
    _QuizPage(
      question: '¿Cuántas horas dormís por noche?',
      options: [
        _O('😵', 'Menos de 5 horas', '<5'),
        _O('😴', '5-6 horas', '5-6'),
        _O('😊', '7-8 horas', '7-8'),
        _O('😇', 'Más de 8 horas', '8+'),
      ],
      onSelect: (v) => answer('sleep_hours', v),
      selected: data.sleepHours,
    ),

    // PAGE 23: Info break — sleep & hunger
    InfoBreakCard(
      emoji: '🌙',
      title: 'Sueño y hambre',
      fact:
          'La falta de sueño aumenta la grelina (hormona del hambre) un 28% y reduce la leptina (hormona de saciedad). Yuna te ayuda a dormir mejor para perder peso de forma natural.',
      onContinue: next,
    ),

    // PAGE 24: Activity level
    _QuizPage(
      question: '¿Cuál es tu nivel de actividad?',
      options: [
        _O('🛋️', 'Sedentaria (poco movimiento)', 'sedentary'),
        _O('🚶', 'Algo activa (camino regularmente)', 'light'),
        _O('🏃', 'Activa (ejercicio 3-4 veces/semana)', 'active'),
        _O('💪', 'Muy activa (ejercicio diario)', 'very_active'),
      ],
      onSelect: (v) => answer('activity_level', v),
      selected: data.activityLevel,
    ),

    // PAGE 25: Preferred exercise
    _QuizPage(
      question: '¿Qué tipo de ejercicio te atrae más?',
      subtitle: 'Personalizaremos tu plan según tu preferencia',
      options: [
        _O('🧘', 'Yoga y stretching', 'yoga'),
        _O('🚶', 'Caminar', 'walking'),
        _O('🔥', 'HIIT (alta intensidad)', 'hiit'),
        _O('🏋️', 'Gym y pesas', 'gym'),
        _O('💃', 'Baile y cardio', 'dance'),
        _O('😅', 'No me gusta ejercitarme', 'none'),
      ],
      onSelect: (v) => answer('preferred_exercise', v),
      selected: data.preferredExercise,
    ),

    // PAGE 26: Mindfulness experience
    _QuizPage(
      question: '¿Practicaste meditación o respiración consciente alguna vez?',
      options: [
        _O('🧘', 'Sí, regularmente', 'yes'),
        _O('🤔', 'Un poco, pero no soy constante', 'some'),
        _O('🆕', 'Nunca probé', 'never'),
      ],
      onSelect: (v) => answer('mindfulness_experience', v),
      selected: data.mindfulnessExperience,
    ),

    // PAGE 27: Breathing demo
    _BreathingDemoPage(onContinue: next),
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

  const _QuizPage({required this.question, this.subtitle, required this.options, required this.onSelect, this.selected});

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

class _StressLevelPage extends StatefulWidget {
  final Function(int) onSubmit;
  const _StressLevelPage({required this.onSubmit});

  @override
  State<_StressLevelPage> createState() => _StressLevelPageState();
}

class _StressLevelPageState extends State<_StressLevelPage> {
  int _level = 5;

  String get _emoji {
    if (_level <= 2) return '😌';
    if (_level <= 4) return '🙂';
    if (_level <= 6) return '😐';
    if (_level <= 8) return '😰';
    return '🥵';
  }

  String get _label {
    if (_level <= 2) return 'Muy relajada';
    if (_level <= 4) return 'Algo de estrés';
    if (_level <= 6) return 'Estrés moderado';
    if (_level <= 8) return 'Bastante estresada';
    return 'Muy estresada';
  }

  Color get _trackColor {
    if (_level <= 3) return const Color(0xFF4CAF50);
    if (_level <= 6) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: const Text('¿Cómo describirías tu nivel de estrés?',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BreathingAura(color: _trackColor, size: 160),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(_emoji, key: ValueKey(_emoji), style: const TextStyle(fontSize: 72)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(_label, key: ValueKey(_label),
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.dark)),
              ),
            ),
          ),
          Center(
            child: Text('$_level / 10',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _trackColor,
                inactiveTrackColor: _trackColor.withValues(alpha: 0.12),
                thumbColor: Colors.white,
                overlayColor: _trackColor.withValues(alpha: 0.1),
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16, elevation: 4),
              ),
              child: Slider(
                value: _level.toDouble(),
                min: 1, max: 10, divisions: 9,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _level = v.toInt());
                },
              ),
            ),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: PremiumCTAButton(
              text: 'Continuar',
              onPressed: () => widget.onSubmit(_level),
              showGlow: false,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Mini breathing demo with enhanced animation
class _BreathingDemoPage extends StatefulWidget {
  final VoidCallback onContinue;
  const _BreathingDemoPage({required this.onContinue});

  @override
  State<_BreathingDemoPage> createState() => _BreathingDemoPageState();
}

class _BreathingDemoPageState extends State<_BreathingDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // Subtle particles
          const Positioned.fill(
            child: FloatingParticles(count: 12, color: AppColors.lavender, maxSize: 5),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              FadeSlideIn(
                child: const Text('Respirá con Yuna', textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                    'La meditación reduce el cortisol, que causa acumulación de grasa abdominal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6), height: 1.4)),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final scale = 0.5 + (_breathController.value * 0.5);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 200 * scale,
                        height: 200 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            AppColors.lavender.withValues(alpha: 0.15),
                            AppColors.lavender.withValues(alpha: 0.0),
                          ]),
                        ),
                      ),
                      // Inner circle
                      Container(
                        width: 140 * scale,
                        height: 140 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            AppColors.coral.withValues(alpha: 0.2 + _breathController.value * 0.15),
                            AppColors.coral.withValues(alpha: 0.03),
                          ]),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.2 * _breathController.value),
                              blurRadius: 40,
                              spreadRadius: 10 * _breathController.value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _breathController.value < 0.5 ? 'Inhalá' : 'Exhalá',
                              key: ValueKey(_breathController.value < 0.5),
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.coral.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: PremiumCTAButton(
                  text: 'Continuar',
                  onPressed: widget.onContinue,
                  showGlow: false,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
