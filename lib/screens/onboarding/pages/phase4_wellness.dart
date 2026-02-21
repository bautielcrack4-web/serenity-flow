import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
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
  final s = L10n.s;
  return [
    // PAGE 21: Stress level
    _StressLevelPage(onSubmit: (v) => answer('stress_level', v)),

    // PAGE 22: Sleep hours
    _QuizPage(
      question: s.p4SleepQuestion,
      options: [
        _O('😵', s.p4SleepLess5, '<5'),
        _O('😴', s.p4Sleep56, '5-6'),
        _O('😊', s.p4Sleep78, '7-8'),
        _O('😇', s.p4SleepMore8, '8+'),
      ],
      onSelect: (v) => answer('sleep_hours', v),
      selected: data.sleepHours,
    ),

    // PAGE 23: Info break — sleep & hunger
    InfoBreakCard(
      emoji: '🌙',
      title: s.p4SleepInfoTitle,
      fact: s.p4SleepInfoFact,
      onContinue: next,
    ),

    // PAGE 24: Activity level
    _QuizPage(
      question: s.p4ActivityQuestion,
      options: [
        _O('🛋️', s.p4ActivitySedentary, 'sedentary'),
        _O('🚶', s.p4ActivityLight, 'light'),
        _O('🏃', s.p4ActivityActive, 'active'),
        _O('💪', s.p4ActivityVeryActive, 'very_active'),
      ],
      onSelect: (v) => answer('activity_level', v),
      selected: data.activityLevel,
    ),

    // PAGE 25: Preferred exercise
    _QuizPage(
      question: s.p4ExerciseQuestion,
      subtitle: s.p4ExerciseSubtitle,
      options: [
        _O('🧘', s.p4ExerciseYoga, 'yoga'),
        _O('🚶', s.p4ExerciseWalking, 'walking'),
        _O('🔥', s.p4ExerciseHiit, 'hiit'),
        _O('🏋️', s.p4ExerciseGym, 'gym'),
        _O('💃', s.p4ExerciseDance, 'dance'),
        _O('😅', s.p4ExerciseNone, 'none'),
      ],
      onSelect: (v) => answer('preferred_exercise', v),
      selected: data.preferredExercise,
    ),

    // PAGE 26: Mindfulness experience
    _QuizPage(
      question: s.p4MindfulnessQuestion,
      options: [
        _O('🧘', s.p4MindfulnessYes, 'yes'),
        _O('🤔', s.p4MindfulnessSome, 'some'),
        _O('🆕', s.p4MindfulnessNever, 'never'),
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
    final s = L10n.s;
    if (_level <= 2) return s.p4StressVeryRelaxed;
    if (_level <= 4) return s.p4StressSome;
    if (_level <= 6) return s.p4StressModerate;
    if (_level <= 8) return s.p4StressPretty;
    return s.p4StressPretty; // 9-10
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
            child: Text(L10n.s.p4StressQuestion,
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
              text: L10n.s.continueBtn,
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
                child: Text(L10n.s.p4BreathingTitle, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                    L10n.s.p4BreathingSubtitle,
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
                              _breathController.value < 0.5 ? L10n.s.p4BreathingInhale : L10n.s.p4BreathingExhale,
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
                  text: L10n.s.continueBtn,
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
