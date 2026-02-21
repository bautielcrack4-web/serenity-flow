import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/services/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class RoutineCard extends StatefulWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback? onLongPress; // Optional long press
  final int index; // For staggered entrance

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    this.onLongPress,
    this.index = 0,
  });

  @override
  State<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<RoutineCard> with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _breathingController;
  late AnimationController _entranceController;
  
  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    
    // Tap Feedback
    _tapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    // Breathing (1.0 ↔ 1.02 every 3s)
    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    // Entrance Animation (Fade + Slide Up)
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutQuart),
    );

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) _entranceController.forward();
    });

    // Gyroscope Effect
    _sensorSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!mounted) return;
      setState(() {
        // Smoothly interpolate the tilt values
        _tiltX = (_tiltX * 0.9) + (event.y * 0.1);
        _tiltY = (_tiltY * 0.9) + (event.x * 0.1);
      });
    });
}

  @override
  void dispose() {
    _tapController.dispose();
    _breathingController.dispose();
    _entranceController.dispose();
    _sensorSubscription?.cancel();
    super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_tapController, _breathingController]),
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateX(_tiltX * 0.01)
                  ..rotateY(_tiltY * 0.01)
                  ..scale(_scaleAnimation.value * _breathingAnimation.value),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: GestureDetector(
              onTapDown: (_) => _tapController.forward(),
              onTapUp: (_) {
                 HapticFeedback.selectionClick();
                 audioService.playRise();
                 _tapController.reverse();
                 widget.onTap();
              },
              onLongPress: widget.onLongPress, // Handled here
              onTapCancel: () => _tapController.reverse(),
              child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 180,
              decoration: BoxDecoration(
                gradient: widget.routine.themeGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.card,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Stack(
                children: [
                  // Decorative Circle
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Icon/Image Hero
                        Hero(
                          tag: 'routine_icon_${widget.routine.id}',
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(widget.routine.icon, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.routine.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.routine.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.dark.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              
                              // Badges Row
                              Row(
                                children: [
                                  _buildMiniBadge(Icons.timer_outlined, widget.routine.computedDuration),
                                  const SizedBox(width: 12),
                                  _buildMiniBadge(Icons.accessibility_new_rounded, "${widget.routine.poseCount} poses"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Favorite Indicator
                  Positioned(
                    top: 16, right: 16,
                    child: Icon(
                      widget.routine.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: widget.routine.isFavorite ? AppColors.coral : AppColors.dark.withValues(alpha: 0.2),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.dark.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.dark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
