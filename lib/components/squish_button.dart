import 'package:flutter/material.dart';

/// Premium squish button with elastic animation
/// Scale: 1.0 → 0.95 (press) → 1.05 (release) → 1.0 (settle)
class SquishButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final Curve curve;

  const SquishButton({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutBack,
  });

  @override
  State<SquishButton> createState() => _SquishButtonState();
}

class _SquishButtonState extends State<SquishButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      // Overshoot effect
      _controller.animateTo(1.05, duration: const Duration(milliseconds: 100), curve: Curves.easeOut)
        .then((_) => _controller.animateTo(1.0, duration: const Duration(milliseconds: 100)));
    });
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
