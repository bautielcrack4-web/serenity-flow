import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';

import 'package:serenity_flow/screens/monetization/paywall_screen.dart';
import 'package:serenity_flow/screens/auth/auth_screen.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:serenity_flow/services/audio_service.dart';
import 'package:serenity_flow/services/haptic_service.dart';
import 'package:flutter/services.dart';


class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> with TickerProviderStateMixin {
  int _currentStep = 1;
  final int _totalSteps = 8;
  
  late AnimationController _stepController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    // Transition Controller
    _stepController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _stepController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _stepController, curve: Curves.easeOutQuart));

    // Pulse for active dot
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _stepController.forward();
  }

  @override
  void dispose() {
    _stepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      _stepController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentStep++);
        _stepController.forward();
      });
    } else {
      HapticFeedback.heavyImpact();
      
      // Save completion flag
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('onboarding_complete', true);
      });

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => PaywallScreen(
            showCloseButton: true,
            onFinish: () {
              Navigator.pushReplacement(
                context, 
                // Navigate to AuthScreen instead of legacy LoginScreen
                MaterialPageRoute(builder: (context) => const AuthScreen())
              );
            },
          )
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(flex: 5, child: _buildIllustrationSection()),
              Expanded(flex: 5, child: _buildOptionsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep - 1;
          final isActual = index == _currentStep - 1;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: isActual 
              ? ScaleTransition(
                  scale: _pulseScale,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.coral, boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.4), blurRadius: 10)])
                  ),
                )
              : Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? AppColors.coral : AppColors.dark.withValues(alpha: 0.1)),
                ),
          );
        }),
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Aura Glow
                  Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [AppColors.coral.withValues(alpha: 0.15), Colors.transparent])
                    ),
                  ),
                  Container(
                    width: 240, height: 240,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.4)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(_getCharacterImage(), fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 100, color: AppColors.lavender)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _getQuestionText(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26, height: 1.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    final options = _getOptions();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: options.map((opt) => QuestionnaireOption(
              key: ValueKey("$_currentStep-$opt"),
              text: opt, 
              onTap: _nextStep,
              isLast: _currentStep == _totalSteps,
            )).toList(),
          ),
        ),
      ),
    );
  }

  String _getCharacterImage() {
     switch (_currentStep) {
       case 1: return 'assets/images/onboarding/onboard_01_saludo.png';
       case 2: return 'assets/images/onboarding/onboard_02_pensativa.png';
       case 3: return 'assets/images/onboarding/onboard_05_energia.png';
       case 4: return 'assets/images/onboarding/onboard_06_dolor.png';
       case 5: return 'assets/images/onboarding/onboard_04_sol.png';
       case 6: return 'assets/images/onboarding/onboard_03_reloj.png';
       case 7: return 'assets/images/onboarding/onboard_02_pensativa.png';
       default: return 'assets/images/onboarding/onboard_01_saludo.png';
     }
  }

  String _getQuestionText() {
    final s = L10n.s;
    switch (_currentStep) {
      case 1: return s.questQ1;
      case 2: return s.questQ2;
      case 3: return s.questQ3;
      case 4: return s.questQ4;
      case 5: return s.questQ5;
      case 6: return s.questQ6;
      case 7: return s.questQ7;
      default: return s.questQ8;
    }
  }

  List<String> _getOptions() {
    final s = L10n.s;
    switch (_currentStep) {
      case 1: return [s.questFlexibility, s.questStrength, s.questRelaxation, s.questMeditationOpt];
      case 2: return [s.questNever, s.questOccasionally, s.questRegularly, s.questDaily];
      case 3: return [s.questLowEnergy, s.questMediumEnergy, s.questHighEnergy, s.questLotsEnergy];
      case 4: return [s.questBack, s.questNeck, s.questKnees, s.questNone];
      case 5: return [s.questLowStress, s.questMediumStress, s.questHighStress];
      case 6: return [s.questTime5, s.questTime15, s.questTime30];
      case 7: return [s.questGuided, s.questSilent, s.questSoftMusic];
      default: return [s.questStartNow];
    }
  }
}

class QuestionnaireOption extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLast;

  const QuestionnaireOption({super.key, required this.text, required this.onTap, this.isLast = false});

  @override
  State<QuestionnaireOption> createState() => _QuestionnaireOptionState();
}

class _QuestionnaireOptionState extends State<QuestionnaireOption> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isSelected = true),
      onTapUp: (_) {
        HapticPatterns.buttonPress();
        audioService.playPop();
        Future.delayed(const Duration(milliseconds: 100), widget.onTap);
      },
      onTapCancel: () => setState(() => _isSelected = false),
      child: AnimatedScale(
        scale: _isSelected ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: _isSelected ? AppColors.coral : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.card,
            border: Border.all(color: _isSelected ? AppColors.coral : Colors.white, width: 2),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 17, 
              fontWeight: FontWeight.bold, 
              color: _isSelected ? Colors.white : AppColors.dark
            ),
          ),
        ),
      ),
    );
  }
}
