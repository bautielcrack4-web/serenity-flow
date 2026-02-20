import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/workout_model.dart';
import 'dart:async';

/// 🏋️ Workout Player — Timer-based exercise execution
class WorkoutPlayerScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutPlayerScreen({super.key, required this.workout});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> with TickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  late int _timeLeft;
  Timer? _timer;
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _isPaused = false;
  int _totalElapsed = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _breatheController;

  Exercise get _currentExercise => widget.workout.exercises[_currentExerciseIndex];
  int get _totalExercises => widget.workout.exercises.length;
  double get _overallProgress => (_currentExerciseIndex + 1) / _totalExercises;

  Color get _dynamicColor {
    if (_currentExercise.isRest) return AppColors.turquoise;
    if (_timeLeft > 10) return widget.workout.color;
    if (_timeLeft > 5) return AppColors.lavender;
    return AppColors.coral;
  }

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.workout.exercises.first.durationSeconds;

    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine));

    _breatheController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 1) {
          _countdown--;
          HapticFeedback.lightImpact();
        } else {
          _countdown = 0;
          _countdownTimer?.cancel();
          _startTimer();
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
            _totalElapsed++;
            if (_timeLeft <= 3 && _timeLeft > 0) {
              HapticFeedback.mediumImpact();
            }
          } else {
            _nextExercise();
          }
        });
      }
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _totalExercises - 1) {
      HapticFeedback.mediumImpact();
      setState(() {
        _currentExerciseIndex++;
        _timeLeft = _currentExercise.durationSeconds;
      });
    } else {
      _timer?.cancel();
      HapticFeedback.heavyImpact();
      _showCompletionDialog();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentExerciseIndex--;
        _timeLeft = _currentExercise.durationSeconds;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('¡Workout completo!',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 8),
              Text('Has completado ${widget.workout.title}',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.gray), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.workout.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompletionStat(label: 'Tiempo', value: _formatDuration(_totalElapsed), emoji: '⏱️'),
                    _CompletionStat(label: 'Calorías', value: '~${widget.workout.calories}', emoji: '🔥'),
                    _CompletionStat(label: 'Ejercicios', value: '${widget.workout.exercises.where((e) => !e.isRest).length}', emoji: '💪'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // dialog
                    Navigator.pop(context); // player
                    Navigator.pop(context); // detail
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.workout.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Volver a Workouts',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Breathing background aura
          AnimatedBuilder(
            animation: _breatheController,
            builder: (context, _) => Center(
              child: Container(
                width: 350 + (_breatheController.value * 80),
                height: 350 + (_breatheController.value * 80),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_dynamicColor.withValues(alpha: 0.08), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildProgressDots(),
                Expanded(child: _buildExerciseDisplay()),
                _buildTimerRing(),
                const SizedBox(height: 16),
                _buildControlButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),

          if (_isPaused) _buildPauseOverlay(),
          if (_countdown > 0) _buildCountdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showExitConfirmation(),
                child: const Icon(Icons.close_rounded, size: 28, color: AppColors.dark),
              ),
              const Spacer(),
              Text('${_currentExerciseIndex + 1} / $_totalExercises',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.dark)),
              const Spacer(),
              const SizedBox(width: 28),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: AppColors.lightGray.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(widget.workout.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 8,
        child: Row(
          children: List.generate(_totalExercises, (i) {
            final isDone = i < _currentExerciseIndex;
            final isCurrent = i == _currentExerciseIndex;
            final isRest = widget.workout.exercises[i].isRest;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: isRest ? 4 : 8,
                decoration: BoxDecoration(
                  color: isDone
                      ? widget.workout.color
                      : isCurrent
                          ? widget.workout.color.withValues(alpha: 0.5)
                          : AppColors.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildExerciseDisplay() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(_currentExerciseIndex),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rest indicator or exercise emoji
          Text(
            _currentExercise.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 20),
          Text(
            _currentExercise.name,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.dark),
            textAlign: TextAlign.center,
          ),
          if (_currentExercise.description != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _currentExercise.description!,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6), height: 1.3),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_currentExercise.isRest) ...[
            const SizedBox(height: 12),
            Text('DESCANSO', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.turquoise, letterSpacing: 3)),
          ],
          // Next up preview
          if (_currentExerciseIndex < _totalExercises - 1) ...[
            const SizedBox(height: 24),
            Text('Siguiente: ${widget.workout.exercises[_currentExerciseIndex + 1].name}',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.4))),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerRing() {
    final total = _currentExercise.durationSeconds.toDouble();
    final fraction = total > 0 ? _timeLeft / total : 0.0;

    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180, height: 180,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(_dynamicColor),
              backgroundColor: AppColors.lightGray.withValues(alpha: 0.15),
            ),
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Text(
              '$_timeLeft',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 64, fontWeight: FontWeight.w900, color: _dynamicColor, height: 1.0),
            ),
          ),
          Positioned(
            bottom: 40,
            child: Text('SEGUNDOS',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w800, color: _dynamicColor.withValues(alpha: 0.5), letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: _previousExercise,
          enabled: _currentExerciseIndex > 0,
        ),
        const SizedBox(width: 24),
        // Pause/Play
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _isPaused = !_isPaused);
          },
          child: Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [widget.workout.color, widget.workout.color.withValues(alpha: 0.8)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: widget.workout.color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Icon(
              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white, size: 36,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Skip
        _ControlButton(
          icon: Icons.skip_next_rounded,
          onTap: _nextExercise,
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_filled_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('PAUSA', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3)),
            const SizedBox(height: 8),
            Text(_formatDuration(_totalElapsed), style: TextStyle(fontFamily: 'Outfit', color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _isPaused = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.workout.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: widget.workout.color.withValues(alpha: 0.4), blurRadius: 16)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text('CONTINUAR', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Salir del workout', style: TextStyle(fontFamily: 'Outfit', color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: AppColors.cream.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.workout.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('PREPARATE', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w900, color: widget.workout.color, letterSpacing: 4)),
            const SizedBox(height: 24),
            Text('$_countdown', style: TextStyle(fontFamily: 'Outfit', fontSize: 120, fontWeight: FontWeight.w900, color: AppColors.dark)),
            const SizedBox(height: 16),
            Text(widget.workout.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray)),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Salir del workout?', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: const Text('Tu progreso no se guardará.', style: TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: widget.workout.color)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // player
            },
            child: const Text('Salir', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: AppColors.gray)),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _ControlButton({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          boxShadow: enabled ? AppShadows.button : [],
        ),
        child: Icon(icon, color: enabled ? AppColors.dark : AppColors.gray.withValues(alpha: 0.3), size: 30),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final String label, value, emoji;
  const _CompletionStat({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.dark)),
        Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.gray)),
      ],
    );
  }
}
