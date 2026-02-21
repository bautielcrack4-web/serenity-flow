import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 1: Emotional Hook (5 pages)
/// Purpose: Connect emotionally, establish Yuna is different
List<Widget> buildPhase1Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  final s = L10n.s;
  return [
    // PAGE 1: Welcome
    _WelcomePage(onContinue: next),

    // PAGE 2: Main Goal
    _QuizPageTemplate(
      question: s.p1GoalQuestion,
      subtitle: s.p1GoalSubtitle,
      options: [
        _Option('🔥', s.p1GoalLoseWeight, 'lose_weight'),
        _Option('💪', s.p1GoalTone, 'tone'),
        _Option('✨', s.p1GoalFeelBetter, 'feel_better'),
        _Option('⚡', s.p1GoalEnergy, 'energy'),
      ],
      onSelect: (val) => answer('goal_type', val),
      selectedValue: data.goalType,
    ),

    // PAGE 3: Info break — stat
    InfoBreakCard(
      emoji: '📊',
      title: s.p1InfoTitle,
      fact: s.p1InfoFact,
      onContinue: next,
    ),

    // PAGE 4: Motivation
    _QuizPageTemplate(
      question: s.p1MotivationQuestion,
      subtitle: s.p1MotivationSubtitle,
      options: [
        _Option('👗', s.p1MotivEvent, 'event'),
        _Option('❤️', s.p1MotivHealth, 'health'),
        _Option('🪞', s.p1MotivConfidence, 'confidence'),
        _Option('👖', s.p1MotivClothes, 'clothes'),
        _Option('🌱', s.p1MotivFreshStart, 'fresh_start'),
      ],
      onSelect: (val) => answer('motivation', val),
      selectedValue: data.motivation,
    ),

    // PAGE 5: Previous attempts
    _QuizPageTemplate(
      question: s.p1PrevQuestion,
      subtitle: s.p1PrevSubtitle,
      options: [
        _Option('😰', s.p1PrevMany, 'many_times'),
        _Option('🤔', s.p1PrevFew, 'few_times'),
        _Option('🌟', s.p1PrevFirst, 'first_time'),
      ],
      onSelect: (val) => answer('previous_attempts', val),
      selectedValue: data.previousAttempts,
    ),
  ];
}

// ---- Internal widgets ----

class _Option {
  final String emoji;
  final String text;
  final String value;
  const _Option(this.emoji, this.text, this.value);
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onContinue;
  const _WelcomePage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        children: [
          // Floating particles background
          const Positioned.fill(
            child: FloatingParticles(
              count: 20,
              color: AppColors.coral,
              maxSize: 6,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo with scale reveal + breathing aura
              ScaleReveal(
                delay: const Duration(milliseconds: 300),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BreathingAura(
                      color: AppColors.coral,
                      size: 220,
                    ),
                    Image.asset(
                      'assets/images/onboarding/illust_welcome.png',
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  s.p1WelcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 800),
                child: Text(
                  s.p1WelcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: AppColors.dark.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: PulseGlow(
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        '${s.continueBtn} ✨',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
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

class _QuizPageTemplate extends StatelessWidget {
  final String question;
  final String? subtitle;
  final List<_Option> options;
  final Function(String) onSelect;
  final String? selectedValue;

  const _QuizPageTemplate({
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
            child: Text(
              question,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = options[index];
                return QuizOptionButton(
                  text: option.text,
                  emoji: option.emoji,
                  isSelected: selectedValue == option.value,
                  onTap: () => onSelect(option.value),
                  staggerIndex: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
