import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/services/audio_service.dart';
import 'package:serenity_flow/services/haptic_service.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/components/sentiment_review_dialog.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class CompletionScreen extends StatefulWidget {
  final Routine routine;
  final int durationSeconds;

  const CompletionScreen({
    super.key,
    required this.routine,
    required this.durationSeconds,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _statsController;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
    _statsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    
    _particles = List.generate(60, (i) => ConfettiParticle());
    
    // Process Session (Save & Check for Review)
    _processCompletion();

    HapticPatterns.achievement();
    // Delay slightly to match the visual explosion
    Future.delayed(const Duration(milliseconds: 300), () {
       audioService.playHarmony();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Falling Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(_particles, _confettiController.value),
                size: Size.infinite,
              );
            },
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Giant Animated Checkmark
                _buildCheckmark(),
                
                
                const SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.coral, AppColors.lavender],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "SESSION COMPLETED!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Body and mind in balance", style: AppTextStyles.caption.copyWith(color: AppColors.dark.withOpacity(0.5))),
                
                const Spacer(),
                
                // Staggered Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: _buildStaggeredStat("Minutes", "08", 0, AppColors.coral)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStaggeredStat("Streak", "04", 1, AppColors.lavender)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStaggeredStat("Daily Goal", "100%", 2, AppColors.turquoise),
                ),
                
                const Spacer(),
                
                _buildFinishButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckmark() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.turquoiseStatusGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.turquoise.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 90),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredStat(String label, String value, int index, Color color) {
    final animation = CurvedAnimation(
      parent: _statsController,
      curve: Interval(0.2 + (index * 0.2), 0.8 + (index * 0.05), curve: Curves.easeOutBack),
    );

    return ScaleTransition(
      scale: animation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          children: [
             Text(value, style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: color, height: 1.0)),
             const SizedBox(height: 4),
             Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
             HapticFeedback.lightImpact();
             _shareSuccess();
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.coral.withOpacity(0.2),
          highlightColor: AppColors.coral.withOpacity(0.1),
          child: Ink(
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
             decoration: BoxDecoration(color: AppColors.lightGray.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
             child: const Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.share_rounded, size: 20, color: AppColors.dark),
                 SizedBox(width: 8),
                 Text("SHARE VICTORY", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
               ],
             ),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          label: 'Volver al inicio de la aplicación',
          button: true,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 72,
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.dark,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                 elevation: 10,
              ),
              child: const Text("BACK TO HOME", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareSuccess() async {
    // In a real app, this would capture a Screenshot of a specific widget
    // For now, we will use the share_plus text share which is cleaner for the MVP
    // If screenshot package was fully configured with native permissions for Android/iOS, we'd use that.
    
    // Future implementation: await Share.share("Just completed my session today on Yuna! 🔥\n\n🎯 8 Minutes of Flow\n⚡ 4 Day Streak\n\nDownload Yuna and join the flow.");
    // Since we are mocking the dependency setup for this speedrun:
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening share menu... (Simulated)")));
  }

  Future<void> _processCompletion() async {
    // 1. Save Session
    await SupabaseService().saveSession(widget.routine, widget.durationSeconds);
    
    // 2. Check if this was the First Session
    final stats = await SupabaseService().getStats();
    if (stats['sessions'] == 1) { // Exact match for first time
      if (mounted) {
         // Slight delay so it doesn't pop up over the confetti immediately
         Future.delayed(const Duration(seconds: 2), _askForReview);
      }
    }
  }

  Future<void> _askForReview() async {
    // Step 1: Ultra UI Sentiment Filter
    // Returns true ONLY if they rated 9 or 10.
    final bool? needsRating = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SentimentReviewDialog(),
    );

    if (needsRating == true) {
      if (!mounted) return;
      // Step 2: "Rate Us" - Only shown if they love it (9-10)
      
      final bool? wantsToRate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Rate Us", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
          content: const Text("Thank you! Being a 5-star app helps us reach more people. Would you help us out?", style: TextStyle(color: AppColors.gray)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Later", style: TextStyle(color: AppColors.gray)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Rate Now", style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (wantsToRate == true) {
        final Uri url = Uri.parse("https://apps.apple.com/app/id6739506690"); 
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    }
  }
}

class ConfettiParticle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;
  late double angle;

  ConfettiParticle() {
    final rand = math.Random();
    x = rand.nextDouble();
    y = -rand.nextDouble() * 2;
    size = rand.nextDouble() * 10 + 5;
    color = [AppColors.coral, AppColors.turquoise, AppColors.lavender, Colors.amber][rand.nextInt(4)];
    speed = rand.nextDouble() * 0.02 + 0.01;
    angle = rand.nextDouble() * math.pi * 2;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color;
      double py = (p.y + (progress * p.speed * 100)) % 1.5;
      if (py > 1.0) continue;
      
      canvas.save();
      canvas.translate(p.x * size.width, py * size.height);
      canvas.rotate(p.angle + progress * 5);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size / 2), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => true;
}
