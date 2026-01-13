import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Confetti particle for celebration effects
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final Animation<double> animation;

  ConfettiPainter({required this.particles, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final progress = animation.value;
      final x = particle.startX + (particle.velocityX * progress * size.width);
      final y = particle.startY + (particle.velocityY * progress * size.height) + (progress * progress * 200); // Gravity
      
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 4);
      
      if (particle.shape == ConfettiShape.circle) {
        canvas.drawCircle(Offset.zero, particle.size, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size),
          paint,
        );
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

enum ConfettiShape { circle, square }

class ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.shape,
  });
}

/// Mini confetti celebration widget
class MiniConfetti extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const MiniConfetti({
    super.key,
    required this.child,
    required this.trigger,
  });

  @override
  State<MiniConfetti> createState() => _MiniConfettiState();
}

class _MiniConfettiState extends State<MiniConfetti> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _generateParticles();
  }

  @override
  void didUpdateWidget(MiniConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !_hasTriggered) {
      _hasTriggered = true;
      _controller.forward(from: 0.0);
    } else if (!widget.trigger) {
      _hasTriggered = false;
    }
  }

  void _generateParticles() {
    final random = math.Random();
    final colors = [
      const Color(0xFFFF7A65),
      const Color(0xFFA88DD0),
      const Color(0xFF5DBBB3),
      const Color(0xFFFFD700),
    ];

    _particles = List.generate(15, (index) {
      return ConfettiParticle(
        startX: 0.5,
        startY: 0.5,
        velocityX: (random.nextDouble() - 0.5) * 0.8,
        velocityY: -random.nextDouble() * 0.6 - 0.2,
        color: colors[random.nextInt(colors.length)],
        size: random.nextDouble() * 6 + 4,
        shape: random.nextBool() ? ConfettiShape.circle : ConfettiShape.square,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_hasTriggered)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(
                  particles: _particles,
                  animation: _controller,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
