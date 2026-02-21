import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 5: Personalized Plan (9 pages)
/// Purpose: Show the result, create ownership feeling ("this is MINE")
List<Widget> buildPhase5Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  return [
    // PAGE 28: Smart loading — shows each factor being analyzed
    _PlanLoadingPage(onComplete: next),

    // PAGE 29: Profile result with confetti
    _ProfileResultPage(data: data, onContinue: next),

    // PAGE 30: Animated projection graph
    _ProjectionGraphPage(data: data, onContinue: next),

    // PAGE 31: Social proof
    InfoBreakCard(
      emoji: '🏆',
      title: L10n.s.p5SocialProofTitle,
      fact: L10n.s.p5SocialProofFact,
      onContinue: next,
    ),

    // PAGE 32: Plan summary WITH DATA ECHO
    _PersonalizedPlanPage(data: data, onContinue: next),

    // PAGE 33: Smart features based on responses
    _SmartFeaturesPage(data: data, onContinue: next),

    // PAGE 34: With vs Without comparison
    _ComparisonPage(data: data, onContinue: next),

    // PAGE 35: IKEA Effect — Confirm YOUR plan
    _ConfirmPlanPage(data: data, onConfirm: next),

    // PAGE 36: Name input
    _NameInputPage(onSubmit: (name) => answer('display_name', name)),
  ];
}

// ---- Internal widgets ----

/// 🔥 Premium Plan Loading — Multi-ring scanning animation
class _PlanLoadingPage extends StatefulWidget {
  final VoidCallback onComplete;
  const _PlanLoadingPage({required this.onComplete});

  @override
  State<_PlanLoadingPage> createState() => _PlanLoadingPageState();
}

class _PlanLoadingPageState extends State<_PlanLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _ringController;
  final _factors = [
    () => L10n.s.p5FactorMetabolism,
    () => L10n.s.p5FactorStress,
    () => L10n.s.p5FactorEating,
    () => L10n.s.p5FactorHormonal,
    () => L10n.s.p5FactorActivity,
    () => L10n.s.p5FactorSleep,
    () => L10n.s.p5FactorBodyType,
    () => L10n.s.p5FactorGoals,
  ];
  int _currentFactor = 0;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() {
        final newFactor = (_progressController.value * _factors.length)
            .floor()
            .clamp(0, _factors.length - 1);
        if (newFactor != _currentFactor) {
          HapticFeedback.lightImpact();
          setState(() => _currentFactor = newFactor);
        }
      });

    _progressController.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: FloatingParticles(count: 12, color: AppColors.coral, maxSize: 4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 120, height: 120,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_progressController, _ringController]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ScanRingPainter(
                        progress: _progressController.value,
                        rotation: _ringController.value * math.pi * 2,
                      ),
                      child: Center(
                        child: Text(
                          '${(_progressController.value * 100).toInt()}%',
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.coral),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(L10n.s.p5LoadingTitle, textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 24),
              // Factor checklist
              ...List.generate(_factors.length, (i) {
                final isAnalyzed = i < _currentFactor;
                final isCurrent = i == _currentFactor;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isAnalyzed
                            ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18, key: ValueKey('done'))
                            : isCurrent
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral),
                                  )
                                : Icon(Icons.circle_outlined, color: Colors.grey.withValues(alpha: 0.3), size: 18, key: const ValueKey('pending')),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _factors[i](),
                        style: TextStyle(
                          fontFamily: 'Outfit', fontSize: 14,
                          color: isAnalyzed ? const Color(0xFF4CAF50) : isCurrent ? AppColors.coral : AppColors.dark.withValues(alpha: 0.3),
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanRingPainter extends CustomPainter {
  final double progress;
  final double rotation;
  _ScanRingPainter({required this.progress, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.coral.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, progress * math.pi * 2, false,
      Paint()
        ..color = AppColors.coral
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    final dotAngle = rotation;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    canvas.drawCircle(Offset(dotX, dotY), 5, Paint()
      ..color = AppColors.coral
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  @override
  bool shouldRepaint(covariant _ScanRingPainter old) => true;
}

/// Profile Result with staggered profile chips + confetti
class _ProfileResultPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _ProfileResultPage({required this.data, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    final chips = [
      ('🎯', s.p5ProfileGoalLabel, data.goalType == 'lose_weight' ? s.p5ProfileGoalLoseWeight : data.goalType == 'tone' ? s.p5ProfileGoalTone : s.p5ProfileGoalWellness),
      ('⚖️', s.p5ProfileCurrentWeight, '${data.currentWeight?.toStringAsFixed(1) ?? "--"} kg'),
      ('🎯', s.p5ProfileTargetWeight, '${data.targetWeight?.toStringAsFixed(1) ?? "--"} kg'),
      ('📏', s.p5ProfileHeight, '${data.height?.toStringAsFixed(0) ?? "--"} cm'),
      ('😰', s.p5ProfileStress, '${data.stressLevel ?? "--"}/10'),
      ('💪', s.p5ProfileActivity, data.activityLevel ?? '--'),
    ];

    return Stack(
      children: [
        const Positioned.fill(child: ConfettiOverlay(count: 30)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              FadeSlideIn(
                child: Text(s.p5ProfileTitle, style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
              ),
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Text(s.p5CreatedForYou,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 28),
              ...chips.asMap().entries.map((e) {
                return FadeSlideIn(
                  delay: Duration(milliseconds: 200 + e.key * 100),
                  child: _ProfileChip(e.value.$1, e.value.$2, e.value.$3),
                );
              }),
              const Spacer(),
              FadeSlideIn(
                delay: const Duration(milliseconds: 900),
                child: PremiumCTAButton(text: s.p5ViewPlanBtn, onPressed: onContinue),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String emoji, label, value;
  const _ProfileChip(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6))),
            const Spacer(),
            Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}

/// 📉 Animated Weight Projection Graph
class _ProjectionGraphPage extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _ProjectionGraphPage({required this.data, required this.onContinue});

  @override
  State<_ProjectionGraphPage> createState() => _ProjectionGraphPageState();
}

class _ProjectionGraphPageState extends State<_ProjectionGraphPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double get _currentWeight => widget.data.currentWeight ?? 70;
  double get _targetWeight => widget.data.targetWeight ?? 60;
  int get _weeks {
    final toLose = _currentWeight - _targetWeight;
    return toLose > 0 ? (toLose / 0.75).ceil().clamp(4, 52) : 8;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: const Text('Tu proyección', textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text(
              '${_currentWeight.toStringAsFixed(1)} kg → ${_targetWeight.toStringAsFixed(1)} kg en $_weeks semanas',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.coral, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 28),
          // Premium dark gradient graph card
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0F3460).withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 12)),
                  BoxShadow(color: AppColors.coral.withValues(alpha: 0.08), blurRadius: 40),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Subtle radial glow behind the graph
                    Positioned(
                      top: -20, right: -20,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [AppColors.coral.withValues(alpha: 0.12), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _PremiumWeightGraphPainter(
                              progress: Curves.easeOutCubic.transform(_controller.value),
                              currentWeight: _currentWeight,
                              targetWeight: _targetWeight,
                              weeks: _weeks,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Milestones with glassmorphic cards
          FadeSlideIn(
            delay: const Duration(milliseconds: 800),
            child: _MilestoneCard('🌱', L10n.s.p5Week2Milestone, L10n.s.p5Week2Desc),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 1000),
            child: _MilestoneCard('🔥', '${L10n.s.p5WeekLabel} ${(_weeks * 0.5).round()}', L10n.s.p5HalfwayMilestoneDesc),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 1200),
            child: _MilestoneCard('🎯', '${L10n.s.p5WeekLabel} $_weeks', '${_targetWeight.toStringAsFixed(1)} kg — ${L10n.s.p5GoalMilestoneDesc}'),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 1400),
            child: PremiumCTAButton(text: L10n.s.p5ViewFullPlanBtn, onPressed: widget.onContinue),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String emoji, title, desc;
  const _MilestoneCard(this.emoji, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.coral.withValues(alpha: 0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.coral.withValues(alpha: 0.12), AppColors.lavender.withValues(alpha: 0.12)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.coral)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(desc, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.55)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumWeightGraphPainter extends CustomPainter {
  final double progress;
  final double currentWeight;
  final double targetWeight;
  final int weeks;

  _PremiumWeightGraphPainter({
    required this.progress,
    required this.currentWeight,
    required this.targetWeight,
    required this.weeks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final padding = 40.0;
    final graphW = w - padding * 2;
    final graphH = h - padding;
    final weightRange = currentWeight - targetWeight;

    // Y axis labels (white text on dark background)
    final labelStyle = TextStyle(fontFamily: 'Outfit', fontSize: 11, color: Colors.white.withValues(alpha: 0.5));
    _drawText(canvas, '${currentWeight.toStringAsFixed(0)} kg', Offset(0, padding * 0.3), labelStyle);
    _drawText(canvas, '${targetWeight.toStringAsFixed(0)} kg', Offset(0, graphH), TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50).withValues(alpha: 0.9)));

    // X axis labels
    _drawText(canvas, L10n.s.p5Today, Offset(padding, h - 10), labelStyle);
    _drawText(canvas, '${L10n.s.p5WeekLabel} $weeks', Offset(w - padding - 30, h - 10), labelStyle);

    // Subtle grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = padding + (graphH - padding) * i / 3;
      canvas.drawLine(Offset(padding, y), Offset(w - padding, y), gridPaint);
    }

    // Curve path
    final path = Path();
    final totalPoints = 50;
    final drawnPoints = (totalPoints * progress).round();

    for (var i = 0; i <= drawnPoints; i++) {
      final t = i / totalPoints;
      final x = padding + graphW * t;
      final weightAtT = currentWeight - weightRange * (1 - math.pow(1 - t, 2.2));
      final y = padding + (graphH - padding) * ((weightAtT - targetWeight) / weightRange).clamp(0, 1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Gradient fill under curve (higher opacity)
    if (drawnPoints > 0) {
      final fillPath = Path.from(path);
      final lastX = padding + graphW * (drawnPoints / totalPoints);
      fillPath.lineTo(lastX, graphH);
      fillPath.lineTo(padding, graphH);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.coral.withValues(alpha: 0.3), const Color(0xFFFFD700).withValues(alpha: 0.05), Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(fillPath, fillPaint);
    }

    // Glow line (thick, blurred)
    canvas.drawPath(path, Paint()
      ..color = AppColors.coral.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Main neon gradient line
    if (drawnPoints > 0) {
      final lastX = padding + graphW * (drawnPoints / totalPoints);
      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(
          colors: [AppColors.coral, const Color(0xFFFFD700)],
        ).createShader(Rect.fromLTWH(padding, 0, lastX - padding, h))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);
    }

    // Milestone dots on curve (15%, 50%, 100%)
    for (final milestone in [0.15, 0.5, 1.0]) {
      final mPoint = (totalPoints * milestone).round();
      if (mPoint <= drawnPoints) {
        final t = mPoint / totalPoints;
        final mx = padding + graphW * t;
        final mWeight = currentWeight - weightRange * (1 - math.pow(1 - t, 2.2));
        final my = padding + (graphH - padding) * ((mWeight - targetWeight) / weightRange).clamp(0, 1);

        // Dot ring
        canvas.drawCircle(Offset(mx, my), 4, Paint()..color = Colors.white.withValues(alpha: 0.3));
        canvas.drawCircle(Offset(mx, my), 2.5, Paint()..color = Colors.white);
      }
    }

    // Endpoint dot with animated pulse
    if (drawnPoints > 0) {
      final endT = drawnPoints / totalPoints;
      final endX = padding + graphW * endT;
      final endWeight = currentWeight - weightRange * (1 - math.pow(1 - endT, 2.2));
      final endY = padding + (graphH - padding) * ((endWeight - targetWeight) / weightRange).clamp(0, 1);

      // Pulse ripple
      canvas.drawCircle(Offset(endX, endY), 12, Paint()
        ..color = AppColors.coral.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(Offset(endX, endY), 7, Paint()
        ..color = AppColors.coral.withValues(alpha: 0.3));
      canvas.drawCircle(Offset(endX, endY), 5, Paint()..color = AppColors.coral);
      canvas.drawCircle(Offset(endX, endY), 3, Paint()..color = Colors.white);
    }

    // Target line (dashed, green)
    final targetY = graphH;
    final dashPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (var x = padding; x < w - padding; x += 8) {
      canvas.drawLine(Offset(x, targetY), Offset(x + 4, targetY), dashPaint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _PremiumWeightGraphPainter old) => old.progress != progress;
}

/// 🪞 DATA ECHO — Personalized Plan Summary
class _PersonalizedPlanPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _PersonalizedPlanPage({required this.data, required this.onContinue});

  List<(String, String, String, String)> _buildPhases() {
    final stressHigh = (data.stressLevel ?? 5) >= 7;
    final emotional = data.emotionalEating != null && data.emotionalEating != 'nunca';
    final lowSleep = data.sleepHours == 'less_than_6' || data.sleepHours == '6_hours';

    final s = L10n.s;
    return [
      ('🌱', s.p5PlanPhase1Title,
        stressHigh
            ? '${s.p5PlanPhase1DescStress} ${data.stressLevel}/10'
            : s.p5PlanPhase1DescNormal,
        s.p5PlanPhase1Tag),
      ('🔥', s.p5PlanPhase2Title,
        emotional
            ? s.p5PlanPhase2DescEmotional
            : s.p5PlanPhase2DescNormal,
        s.p5PlanPhase2Tag),
      ('🌙', s.p5PlanPhase3Title,
        lowSleep
            ? '${s.p5PlanPhase3DescLowSleep} ${data.sleepHours == "less_than_6" ? "<6h" : "~6h"}'
            : s.p5PlanPhase3DescNormal,
        s.p5PlanPhase3Tag),
      ('💎', s.p5PlanPhase4Title,
        '${s.p5PlanPhase4Desc} ${data.targetWeight?.toStringAsFixed(1) ?? "--"} kg',
        s.p5PlanPhase4Tag),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final phases = _buildPhases();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(L10n.s.p5PlanTitle,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 6),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerGradient(
                    child: const Icon(Icons.auto_awesome, size: 14, color: AppColors.coral),
                  ),
                  const SizedBox(width: 6),
                  Text(L10n.s.p5PlanAiBadge,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.coral)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...phases.asMap().entries.map((e) {
            final p = e.value;
            return FadeSlideIn(
              delay: Duration(milliseconds: 200 + e.key * 200),
              child: _PersonalizedPhaseTile(p.$1, p.$2, p.$3, p.$4),
            );
          }),
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 1000),
            child: PremiumCTAButton(text: L10n.s.continueBtn, onPressed: onContinue, showGlow: false),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PersonalizedPhaseTile extends StatelessWidget {
  final String emoji, title, desc, tag;
  const _PersonalizedPhaseTile(this.emoji, this.title, this.desc, this.tag);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tag, style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.coral)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(desc, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.dark.withValues(alpha: 0.6), height: 1.4)),
          ],
        ),
      ),
    );
  }
}

/// 🎯 Smart Features — Dynamic based on user answers
class _SmartFeaturesPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _SmartFeaturesPage({required this.data, required this.onContinue});

  List<(String, String, String, bool)> _buildFeatures() {
    final features = <(String, String, String, bool)>[];
    final stressHigh = (data.stressLevel ?? 5) >= 6;
    final emotional = data.emotionalEating != null && data.emotionalEating != 'nunca';
    final hasRestrictions = data.dietaryRestrictions.isNotEmpty;
    final lowActivity = data.activityLevel == 'sedentary' || data.activityLevel == 'light';

    final s = L10n.s;
    if (stressHigh) {
      features.add(('🧘', s.p5FeatureMeditationTitle, '${s.p5FeatureMeditationDescHigh} ${data.stressLevel}/10', true));
    } else {
      features.add(('🧘', s.p5FeatureMeditationTitle, s.p5FeatureMeditationDescNormal, false));
    }

    if (emotional) {
      features.add(('🧠', s.p5FeatureEmotionalTitle, s.p5FeatureEmotionalDesc, true));
    }

    if (hasRestrictions) {
      final restr = data.dietaryRestrictions.take(2).join(', ');
      features.add(('🥗', s.p5FeatureRecipesTitle, '${s.p5FeatureRecipesDescRestricted} ($restr)', true));
    } else {
      features.add(('🥗', s.p5FeatureRecipesTitle, s.p5FeatureRecipesDescNormal, false));
    }

    features.add(('📊', s.p5FeatureTrackingTitle, s.p5FeatureTrackingDesc, false));

    if (lowActivity) {
      features.add(('💪', s.p5FeatureWorkoutsBeginnerTitle, data.activityLevel == "sedentary" ? s.p5FeatureWorkoutsBeginnerDescSedentary : s.p5FeatureWorkoutsBeginnerDescLight, true));
    } else {
      features.add(('💪', s.p5FeatureWorkoutsTitle, '${s.p5ForYouTag}: ${data.preferredExercise ?? "yoga"}', true));
    }

    features.add(('🌙', s.p5FeatureSleepTitle, data.sleepHours ?? '--', data.sleepHours != null));

    return features;
  }

  @override
  Widget build(BuildContext context) {
    final features = _buildFeatures();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(L10n.s.p5FeaturesTitle,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.coral.withValues(alpha: 0.1), AppColors.lavender.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Text(L10n.s.p5FeatureAiBadge,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.coral)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...features.asMap().entries.map((e) {
            final f = e.value;
            return FadeSlideIn(
              delay: Duration(milliseconds: 200 + e.key * 120),
              child: _SmartFeatureCard(f.$1, f.$2, f.$3, f.$4),
            );
          }),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 900),
            child: PremiumCTAButton(text: L10n.s.continueBtn, onPressed: onContinue, showGlow: false),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SmartFeatureCard extends StatelessWidget {
  final String emoji, title, desc;
  final bool isPersonalized;
  const _SmartFeatureCard(this.emoji, this.title, this.desc, this.isPersonalized);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isPersonalized
              ? Border.all(color: AppColors.coral.withValues(alpha: 0.15), width: 1.5)
              : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                      ),
                      if (isPersonalized)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Para vos', style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.coral)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(desc, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.55), height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Con Yuna vs Sin plan — with data echo
class _ComparisonPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _ComparisonPage({required this.data, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final weeks = ((data.currentWeight ?? 70) - (data.targetWeight ?? 60)) > 0
        ? (((data.currentWeight ?? 70) - (data.targetWeight ?? 60)) / 0.75).ceil()
        : 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(L10n.s.p5ComparisonTitle,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Row(children: [
              Expanded(
                child: _CompareColumn(
                  L10n.s.p5ComparisonWithoutTitle, [
                    ('❌', L10n.s.p5WithoutRestrictive),
                    ('❌', L10n.s.p5WithoutEmotional),
                    ('❌', L10n.s.p5WithoutRebound),
                    ('❌', L10n.s.p5WithoutSlow),
                  ], Colors.grey.shade100, null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GlowingBorder(
                  colors: const [AppColors.coral, Color(0xFFFFD700), AppColors.lavender],
                  borderRadius: 20,
                  child: _CompareColumn(
                    L10n.s.p5ComparisonWithTitle, [
                      ('✅', '$weeks${L10n.s.p5WithPlanWeeks}'),
                      ('✅', L10n.s.p5WithAntiStress),
                      ('✅', L10n.s.p5WithLastingResults),
                      ('✅', '${data.targetWeight?.toStringAsFixed(0) ?? "--"} ${L10n.s.p5WithGoalKg}'),
                    ], AppColors.coral.withValues(alpha: 0.04), AppColors.coral,
                  ),
                ),
              ),
            ]),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: PremiumCTAButton(text: L10n.s.p5WantYunaBtn, onPressed: onContinue),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _CompareColumn extends StatelessWidget {
  final String title;
  final List<(String, String)> items;
  final Color bg;
  final Color? accent;
  const _CompareColumn(this.title, this.items, this.bg, this.accent);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: accent != null && accent != AppColors.coral ? Border.all(color: accent!.withValues(alpha: 0.3), width: 2) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: accent ?? AppColors.dark)),
        const SizedBox(height: 14),
        ...items.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.value.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(e.value.$2,
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.7), height: 1.3)),
                ),
              ],
            ),
          );
        }),
      ]),
    );
  }
}

/// 🧩 IKEA EFFECT — "Confirm YOUR plan" — Premium Redesign
class _ConfirmPlanPage extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onConfirm;
  const _ConfirmPlanPage({required this.data, required this.onConfirm});

  @override
  State<_ConfirmPlanPage> createState() => _ConfirmPlanPageState();
}

class _ConfirmPlanPageState extends State<_ConfirmPlanPage> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final weeks = ((widget.data.currentWeight ?? 70) - (widget.data.targetWeight ?? 60)) > 0
        ? (((widget.data.currentWeight ?? 70) - (widget.data.targetWeight ?? 60)) / 0.75).ceil()
        : 8;

    return Stack(
      children: [
        if (_confirmed) const Positioned.fill(child: ConfettiOverlay(count: 40)),
        const Positioned.fill(
          child: FloatingParticles(count: 8, color: AppColors.lavender, maxSize: 5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 28),
                // Premium animated seal
                FadeSlideIn(
                  child: ScaleReveal(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BreathingAura(color: AppColors.coral, size: 130),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          width: 85, height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _confirmed
                                ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)])
                                : AppColors.coralStatusGradient,
                            boxShadow: [BoxShadow(
                              color: (_confirmed ? const Color(0xFF4CAF50) : AppColors.coral).withValues(alpha: 0.35),
                              blurRadius: 24,
                            )],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _confirmed
                                  ? const Icon(Icons.check_rounded, key: ValueKey('check'), size: 44, color: Colors.white)
                                  : const Text('✨', key: ValueKey('sparkle'), style: TextStyle(fontSize: 38)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(L10n.s.p5ConfirmReady, textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.dark)),
                ),
                const SizedBox(height: 6),
                // Endowed progress badge
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.coral.withValues(alpha: 0.08), AppColors.lavender.withValues(alpha: 0.08)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: AppColors.coral.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Text('Personalizado con tus 36 respuestas',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Premium blueprint card
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.coral.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(color: AppColors.coral.withValues(alpha: 0.06), blurRadius: 24),
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        _BlueprintRow('🎯', L10n.s.p5BlueprintGoal, '${widget.data.currentWeight?.toStringAsFixed(0) ?? "--"} → ${widget.data.targetWeight?.toStringAsFixed(0) ?? "--"} kg'),
                        _BlueprintRow('📅', L10n.s.p5BlueprintDuration, '$weeks ${L10n.s.p5BlueprintWeeks}'),
                        _BlueprintRow('🧘', L10n.s.p5BlueprintIncludes, L10n.s.p5BlueprintIncludesValue),
                        _BlueprintRow('🔥', L10n.s.p5BlueprintIntensity, widget.data.activityLevel == 'sedentary' ? L10n.s.p5BlueprintIntensityGradual : L10n.s.p5BlueprintIntensityModerate),
                        if ((widget.data.stressLevel ?? 5) >= 7)
                          _BlueprintRow('😌', L10n.s.p5BlueprintExtra, L10n.s.p5BlueprintAntiStress),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Value stacking section
                FadeSlideIn(
                  delay: const Duration(milliseconds: 550),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(L10n.s.p7ValueStack,
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark)),
                        const SizedBox(height: 10),
                        _ValueStackRow('🍎', 'Nutricionista', '\$80.000/mes'),
                        _ValueStackRow('🧘', 'App de meditación', '\$8.99/mes'),
                        _ValueStackRow('💪', 'App de fitness', '\$12.99/mes'),
                        _ValueStackRow('🧠', 'Coach personal', '\$120.000/mes'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.coral.withValues(alpha: 0.06), AppColors.lavender.withValues(alpha: 0.06)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Yuna = Todo incluido ✨',
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.coral)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 700),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _confirmed
                        ? PremiumCTAButton(
                            key: const ValueKey('continue'),
                            text: L10n.s.p5ConfirmContinueBtn,
                            onPressed: widget.onConfirm,
                          )
                        : PremiumCTAButton(
                            key: const ValueKey('confirm'),
                            text: L10n.s.p5ConfirmBtn,
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              setState(() => _confirmed = true);
                              Future.delayed(const Duration(milliseconds: 1200), () {
                                if (mounted) widget.onConfirm();
                              });
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueStackRow extends StatelessWidget {
  final String emoji, service, price;
  const _ValueStackRow(this.emoji, this.service, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(service, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.6))),
          const Spacer(),
          Text(price,
            style: TextStyle(
              fontFamily: 'Outfit', fontSize: 13,
              color: AppColors.dark.withValues(alpha: 0.3),
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.dark.withValues(alpha: 0.3),
            )),
        ],
      ),
    );
  }
}

class _BlueprintRow extends StatelessWidget {
  final String emoji, label, value;
  const _BlueprintRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.5))),
          const Spacer(),
          Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.dark)),
        ],
      ),
    );
  }
}

/// Name input page with premium styling
class _NameInputPage extends StatefulWidget {
  final Function(String) onSubmit;
  const _NameInputPage({required this.onSubmit});

  @override
  State<_NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<_NameInputPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            child: Text(L10n.s.p5NameTitle,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text(L10n.s.p5NameSubtitle,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.dark),
              decoration: InputDecoration(
                hintText: L10n.s.p5NameHint,
                hintStyle: TextStyle(color: AppColors.dark.withValues(alpha: 0.15)),
                border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.coral.withValues(alpha: 0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.coral, width: 2.5)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: AnimatedOpacity(
              opacity: _controller.text.trim().isNotEmpty ? 1 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: PremiumCTAButton(
                text: L10n.s.p5NameContinueBtn,
                onPressed: _controller.text.trim().isNotEmpty
                    ? () => widget.onSubmit(_controller.text.trim())
                    : () {},
                showGlow: _controller.text.trim().isNotEmpty,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
