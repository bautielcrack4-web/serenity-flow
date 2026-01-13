import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/home/main_navigation_screen.dart';
import 'package:serenity_flow/services/audio_service.dart';
import 'package:confetti/confetti.dart';

class CompletionScreenNew extends StatefulWidget {
  const CompletionScreenNew({super.key});

  @override
  State<CompletionScreenNew> createState() => _CompletionScreenNewState();
}

class _CompletionScreenNewState extends State<CompletionScreenNew> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Play success sound and start confetti
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioService.playSuccess();
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.organicGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Celebrating Character
                    Image.asset(
                      'assets/images/onboard_06_dolor.png',
                      width: 300,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 300, height: 300,
                        decoration: BoxDecoration(
                          color: AppColors.white, 
                          shape: BoxShape.circle, 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1), 
                              blurRadius: 10, 
                              offset: const Offset(0, 4)
                            )
                          ]
                        ),
                        child: const Icon(Icons.celebration, size: 80, color: AppColors.coral),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    Text(
                      "You're all set, María! 🎉",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your personalized practice is ready",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.dark.withOpacity(0.6),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    ScaleTransition(
                      scale: _glowAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                            (route) => false,
                          );
                        },
                        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                          shadowColor: WidgetStateProperty.all(AppColors.coral.withOpacity(0.4)),
                          elevation: WidgetStateProperty.all(12),
                        ),
                        child: const Text("Start My Journey"),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.coral,
                AppColors.lavender,
                AppColors.turquoise,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
