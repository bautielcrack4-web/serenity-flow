import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/session/completion_screen.dart';
import 'package:serenity_flow/services/audio_service.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PoseScreen extends StatefulWidget {
  final Routine routine;

  const PoseScreen({super.key, required this.routine});

  @override
  State<PoseScreen> createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> with TickerProviderStateMixin {
  int _currentPoseIndex = 0;
  bool _isRightSide = false;
  
  late int _timeLeft;
  Timer? _timer;
  bool _isPaused = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _auraController;

  @override
  void initState() {
    super.initState();
    _initializePose();
    audioService.playBowl();
    
    // Per-second pulse (1.0 -> 1.08)
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine));

    // Aura Breathing
    _auraController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  void _initializePose() {
    final pose = widget.routine.poses[_currentPoseIndex];
    _timeLeft = pose.duration; 
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
            if (_timeLeft <= 5) {
              HapticFeedback.mediumImpact();
            } else {
              HapticFeedback.selectionClick();
            }
          } else {
            _onTimerFinished();
          }
        });
      }
    });
  }

  void _onTimerFinished() {
    final currentPose = widget.routine.poses[_currentPoseIndex];
    if (currentPose.perSide && !_isRightSide) {
      HapticFeedback.mediumImpact();
      audioService.playClick();
      setState(() {
        _isRightSide = true;
        _timeLeft = currentPose.duration; 
      });
    } else {
      _nextPose();
    }
  }

  void _nextPose() {
    if (_currentPoseIndex < widget.routine.poses.length - 1) {
      HapticFeedback.mediumImpact();
      audioService.playClick();
      setState(() {
        _currentPoseIndex++;
        _isRightSide = false;
        _timeLeft = widget.routine.poses[_currentPoseIndex].duration;
      });
    } else {
      _timer?.cancel();
      HapticFeedback.heavyImpact();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompletionScreen(routine: widget.routine, durationSeconds: widget.routine.totalDurationSeconds)));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  Color get _dynamicColor {
    if (_timeLeft > 15) return AppColors.turquoise;
    if (_timeLeft > 5) return AppColors.lavender;
    return AppColors.coral;
  }

  @override
  Widget build(BuildContext context) {
    final currentPose = widget.routine.poses[_currentPoseIndex];
    String sideLabel = currentPose.perSide ? (_isRightSide ? "Right Side" : "Left Side") : "";

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Background Color Aura
          AnimatedBuilder(
            animation: _auraController,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 400 + (_auraController.value * 100),
                  height: 400 + (_auraController.value * 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_dynamicColor.withOpacity(0.08), Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildDynamicHeader(),
                Expanded(child: _buildPoseIllustration(currentPose, sideLabel)),
                _buildGiantCounter(),
              ],
            ),
          ),
          
          // Control Buttons (Previous, Pause, Skip) - Below Header
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Button
                GestureDetector(
                  onTap: () {
                    if (_currentPoseIndex > 0) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _currentPoseIndex--;
                        _isRightSide = false;
                        _timeLeft = widget.routine.poses[_currentPoseIndex].duration;
                        _isPaused = false;
                      });
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _currentPoseIndex > 0 ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                      boxShadow: _currentPoseIndex > 0 ? AppShadows.button : [],
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: _currentPoseIndex > 0 ? AppColors.dark : AppColors.gray,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Pause/Play Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isPaused = !_isPaused);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.button,
                    ),
                    child: Icon(
                      _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      color: AppColors.dark,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Skip Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _nextPose();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.button,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.dark,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isPaused) _buildPauseOverlay(),
        ],
      ),
    );
  }

  Widget _buildDynamicHeader() {
    double progress = (_currentPoseIndex + 1) / widget.routine.poses.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.close_rounded, size: 28), onPressed: () => Navigator.pop(context)),
              Text(
                "Pose ${_currentPoseIndex + 1} of ${widget.routine.poses.length}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.dark),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          // Gradient Horizontal Progress Bar
          Container(
            height: 8, width: double.infinity,
            decoration: BoxDecoration(color: AppColors.lightGray.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.turquoiseStatusGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoseIllustration(Pose pose, String sideLabel) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _auraController,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                   // Pulsing Aura behind illustration
                   Container(
                     width: 280 + (_auraController.value * 20),
                     height: 280 + (_auraController.value * 20),
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       gradient: RadialGradient(colors: [_dynamicColor.withOpacity(0.1), Colors.transparent]),
                     ),
                   ),
                   SizedBox(
                     width: 280, height: 280,
                     child: Image.asset(pose.image, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.accessibility_new, size: 100)),
                   ),
                ],
              ),
              const SizedBox(height: 32),
              Text(pose.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.dark, height: 1.1)),
              if (sideLabel.isNotEmpty)
                Text(sideLabel, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dynamicColor)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGiantCounter() {
    final double total = widget.routine.poses[_currentPoseIndex].duration.toDouble();
    final double fraction = _timeLeft / total;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 220px RING
            SizedBox(
              width: 220, height: 220,
              child: CircularProgressIndicator(
                value: fraction,
                strokeWidth: 16,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(_dynamicColor),
                backgroundColor: AppColors.lightGray.withOpacity(0.2),
              ),
            ),
            
            // PULSING NUMBER
            ScaleTransition(
              scale: _pulseAnimation,
              child: Text(
                "$_timeLeft",
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: _dynamicColor, height: 1.0, letterSpacing: -3),
              ),
            ),
            
            Positioned(
              bottom: 60,
              child: Text("SECONDS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _dynamicColor.withOpacity(0.6), letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_filled_rounded, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text("Paused", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
