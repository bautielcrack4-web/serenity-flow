import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// ✨ Reusable quiz option button with stagger animation
class QuizOptionButton extends StatefulWidget {
  final String text;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final int staggerIndex;

  const QuizOptionButton({
    super.key,
    required this.text,
    this.emoji,
    this.isSelected = false,
    required this.onTap,
    this.staggerIndex = 0,
  });

  @override
  State<QuizOptionButton> createState() => _QuizOptionButtonState();
}

class _QuizOptionButtonState extends State<QuizOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 80 * widget.staggerIndex),
      offsetY: 20,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.coral.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.coral
                    : Colors.grey.withValues(alpha: 0.12),
                width: widget.isSelected ? 2.5 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                if (widget.emoji != null) ...[
                  Text(widget.emoji!, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight:
                          widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isSelected ? AppColors.coral : AppColors.dark,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          key: ValueKey('check'),
                          color: AppColors.coral, size: 26)
                      : const SizedBox(key: ValueKey('empty'), width: 26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 📊 Info break card with animated emoji and staggered text
class InfoBreakCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String fact;
  final VoidCallback onContinue;

  const InfoBreakCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.fact,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // Floating particles background
          const Positioned.fill(
            child: FloatingParticles(count: 10, color: AppColors.coral, maxSize: 5),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated emoji with glow
              ScaleReveal(
                delay: const Duration(milliseconds: 200),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BreathingAura(color: AppColors.coral, size: 140),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coral.withValues(alpha: 0.08),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 48)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Title
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Fact
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  fact,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.dark.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Continue button with glow
              FadeSlideIn(
                delay: const Duration(milliseconds: 800),
                child: PulseGlow(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
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

/// Segmented progress bar with animated fill
class OnboardingProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalPhases;

  const OnboardingProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalPhases = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalPhases, (index) {
          final phaseStart = (index * totalPages / totalPhases).floor();
          final phaseEnd = ((index + 1) * totalPages / totalPhases).floor();
          final isCurrent =
              currentPage >= phaseStart && currentPage < phaseEnd;
          final isCompleted = currentPage >= phaseEnd;

          double phaseProgress = 0;
          if (isCompleted) {
            phaseProgress = 1.0;
          } else if (isCurrent) {
            phaseProgress =
                (currentPage - phaseStart) / (phaseEnd - phaseStart);
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < totalPhases - 1 ? 4 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: phaseProgress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 5,
                      backgroundColor: AppColors.coral.withValues(alpha: 0.08),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.coral),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Premium slider input with large animated value display
class AnimatedSliderInput extends StatefulWidget {
  final String label;
  final String unit;
  final double min;
  final double max;
  final double initialValue;
  final int divisions;
  final Function(double) onChanged;

  const AnimatedSliderInput({
    super.key,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.divisions,
    required this.onChanged,
  });

  @override
  State<AnimatedSliderInput> createState() => _AnimatedSliderInputState();
}

class _AnimatedSliderInputState extends State<AnimatedSliderInput> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Value display with glow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _value.toStringAsFixed(
                      widget.unit == 'kg' || widget.unit == 'cm' ? 1 : 0),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                TextSpan(
                  text: ' ${widget.unit}',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.coral,
            inactiveTrackColor: AppColors.coral.withValues(alpha: 0.1),
            thumbColor: Colors.white,
            overlayColor: AppColors.coral.withValues(alpha: 0.1),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 16,
              elevation: 4,
              pressedElevation: 8,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
          ),
          child: Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _value = val);
              widget.onChanged(val);
            },
          ),
        ),
        // Min/Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.min.toStringAsFixed(0)} ${widget.unit}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: AppColors.gray.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '${widget.max.toStringAsFixed(0)} ${widget.unit}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: AppColors.gray.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🔥 Premium CTA Button with shimmer and glow
class PremiumCTAButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool showGlow;

  const PremiumCTAButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (showGlow) {
      return PulseGlow(child: button);
    }
    return button;
  }
}
