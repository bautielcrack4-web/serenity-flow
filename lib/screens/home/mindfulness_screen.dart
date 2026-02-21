import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';

/// 🧘 Mindfulness Screen — Breathing, meditation, sleep routines
class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

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
              Text(s.mindTitle, style: const TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 4),
              Text(s.mindSubtitle, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
              const SizedBox(height: 24),

              // Featured: Quick breathing
              _BreathingFeatureCard(),
              const SizedBox(height: 24),

              // Meditations
              Text(s.mindMeditations, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _MeditationCard(emoji: '🧘', title: s.mindMorningMeditation, subtitle: s.mindMorningMeditationDesc, duration: '10 min', color: AppColors.lavender),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '🌊', title: s.mindInnerCalm, subtitle: s.mindInnerCalmDesc, duration: '7 min', color: AppColors.turquoise),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '🌸', title: s.mindBodyScan, subtitle: s.mindBodyScanDesc, duration: '5 min', color: const Color(0xFFE91E63)),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '🎯', title: s.mindGoalVisualization, subtitle: s.mindGoalVisualizationDesc, duration: '8 min', color: AppColors.coral, isPremium: true),

              const SizedBox(height: 20),
              Text(s.mindSleepRoutines, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _MeditationCard(emoji: '🌙', title: s.mindBedtimeRoutine, subtitle: s.mindBedtimeRoutineDesc, duration: '15 min', color: const Color(0xFF5C6BC0)),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '🌿', title: s.mindNatureSounds, subtitle: s.mindNatureSoundsDesc, duration: '30 min', color: const Color(0xFF2E7D32)),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '✨', title: s.mindNightBodyScan, subtitle: s.mindNightBodyScanDesc, duration: '10 min', color: AppColors.lavender, isPremium: true),

              const SizedBox(height: 20),
              Text(s.mindEmotionalEating, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _MeditationCard(emoji: '🤗', title: s.mindPauseBeforeEating, subtitle: s.mindPauseBeforeEatingDesc, duration: '3 min', color: AppColors.coral),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '💭', title: s.mindEmotionDiary, subtitle: s.mindEmotionDiaryDesc, duration: '5 min', color: AppColors.lavender),
              const SizedBox(height: 12),
              _MeditationCard(emoji: '🍫', title: s.mindSweetCraving, subtitle: s.mindSweetCravingDesc, duration: '4 min', color: const Color(0xFFFF8F00), isPremium: true),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingFeatureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('🫁', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          Text(s.mindQuickBreathing, style: const TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          Text(s.mindQuickBreathingDesc, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha: 0.8), height: 1.3), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStat('⏱️', '3 min'),
              const SizedBox(width: 24),
              _buildMiniStat('😌', s.mindCalm),
              const SizedBox(width: 24),
              _buildMiniStat('🔄', '4-7-8'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                showDialog(
                  context: context,
                  builder: (_) => const _BreathingExerciseDialog(),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF7C4DFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(s.mindStartNow, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
      ],
    );
  }
}

/// 🫁 4-7-8 Breathing Exercise Dialog
class _BreathingExerciseDialog extends StatefulWidget {
  const _BreathingExerciseDialog();

  @override
  State<_BreathingExerciseDialog> createState() => _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<_BreathingExerciseDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _cycles = 0;
  static const _totalCycles = 3;
  String _phase = 'Inhale';
  int _countdown = 4;

  // Phase durations in seconds for 4-7-8 breathing
  static const _inhaleDuration = 4;
  static const _holdDuration = 7;
  static const _exhaleDuration = 8;

  @override
  void initState() {
    super.initState();
    final totalPhaseMs = (_inhaleDuration + _holdDuration + _exhaleDuration) * 1000;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: totalPhaseMs * _totalCycles));
    _controller.addListener(_updatePhase);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _phase = 'Done ✨');
      }
    });
    _controller.forward();
  }

  void _updatePhase() {
    final totalPhase = _inhaleDuration + _holdDuration + _exhaleDuration;
    final elapsed = _controller.value * totalPhase * _totalCycles;
    final cyclePos = elapsed % totalPhase;
    final cycle = (elapsed / totalPhase).floor();

    String newPhase;
    int newCountdown;
    if (cyclePos < _inhaleDuration) {
      newPhase = 'Inhale';
      newCountdown = _inhaleDuration - cyclePos.floor();
    } else if (cyclePos < _inhaleDuration + _holdDuration) {
      newPhase = 'Hold';
      newCountdown = _holdDuration - (cyclePos - _inhaleDuration).floor();
    } else {
      newPhase = 'Exhale';
      newCountdown = _exhaleDuration - (cyclePos - _inhaleDuration - _holdDuration).floor();
    }

    if (newPhase != _phase || newCountdown != _countdown || cycle != _cycles) {
      setState(() {
        _phase = newPhase;
        _countdown = newCountdown;
        _cycles = cycle;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _phase == 'Done ✨';
    final progress = _controller.value;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🫁', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('4-7-8 Breathing', style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 32),

            // Animated breathing circle
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: _phase == 'Inhale' ? 1.0 : _phase == 'Hold' ? 1.0 : 0.6),
              duration: const Duration(milliseconds: 800),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                    ),
                    child: Center(
                      child: isDone
                        ? const Text('✨', style: TextStyle(fontSize: 48))
                        : Text('$_countdown', style: const TextStyle(fontFamily: 'Outfit', fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(_phase, style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text(isDone ? 'Great job! 🎉' : 'Cycle ${_cycles + 1}/$_totalCycles', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),

            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 4),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF7C4DFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(isDone ? 'Done' : 'Close', style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  final String emoji, title, subtitle, duration;
  final Color color;
  final bool isPremium;
  const _MeditationCard({required this.emoji, required this.title, required this.subtitle, required this.duration, required this.color, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title — coming soon! 🧘'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark))),
                      if (isPremium) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                          child: const Text('PRO', style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Column(
              children: [
                Icon(Icons.play_circle_filled_rounded, color: color, size: 36),
                const SizedBox(height: 2),
                Text(duration, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
