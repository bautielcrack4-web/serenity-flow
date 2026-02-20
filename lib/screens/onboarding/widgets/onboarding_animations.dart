import 'package:flutter/material.dart';
import 'dart:math' as math;

// ============================================================
// 🎬 ONBOARDING ANIMATION ENGINE
// Reusable, premium animations for maximum conversion
// ============================================================

/// ✨ FadeSlideIn — Fade + slide from bottom with configurable delay (stagger)
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offsetY = 30,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, widget.offsetY), end: Offset.zero)
            .animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    Future.delayed(widget.delay, () {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 🎯 ScaleReveal — Bouncy scale-in for emojis and icons
class ScaleReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const ScaleReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<ScaleReveal> createState() => _ScaleRevealState();
}

class _ScaleRevealState extends State<ScaleReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    Future.delayed(widget.delay, () {
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
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// 💎 ShimmerGradient — Animated shimmer that glides over surfaces
class ShimmerGradient extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerGradient({
    super.key,
    required this.child,
    this.baseColor = const Color(0x00FFFFFF),
    this.highlightColor = const Color(0x33FFFFFF),
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<ShimmerGradient> createState() => _ShimmerGradientState();
}

class _ShimmerGradientState extends State<ShimmerGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, -0.3),
              end: Alignment(1 + 2 * _controller.value, 0.3),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 🫧 FloatingParticles — Subtle bokeh dots floating in background
class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;
  final double maxSize;

  const FloatingParticles({
    super.key,
    this.count = 15,
    this.color = const Color(0xFFFF7A65),
    this.maxSize = 8,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _particles = List.generate(widget.count, (_) => _generateParticle());
  }

  _Particle _generateParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 2 + _random.nextDouble() * widget.maxSize,
      speed: 0.2 + _random.nextDouble() * 0.6,
      opacity: 0.05 + _random.nextDouble() * 0.15,
      phase: _random.nextDouble() * math.pi * 2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            color: widget.color,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x, y, size, speed, opacity, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width +
          math.sin(progress * math.pi * 2 * p.speed + p.phase) * 30;
      final dy = p.y * size.height +
          math.cos(progress * math.pi * 2 * p.speed + p.phase) * 20;
      final paint = Paint()
        ..color = color.withValues(alpha: p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5);
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}

/// 🔥 PulseGlow — Pulsing glow effect for CTAs
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlur;
  final Duration duration;

  const PulseGlow({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFFFF7A65),
    this.maxBlur = 20,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor
                    .withValues(alpha: 0.15 + _controller.value * 0.25),
                blurRadius: widget.maxBlur * (0.5 + _controller.value * 0.5),
                spreadRadius: _controller.value * 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 🎉 ConfettiOverlay — Burst of confetti particles for celebrations
class ConfettiOverlay extends StatefulWidget {
  final bool trigger;
  final int count;

  const ConfettiOverlay({
    super.key,
    this.trigger = true,
    this.count = 40,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _pieces = List.generate(widget.count, (_) => _ConfettiPiece(
      x: _random.nextDouble(),
      velocity: 0.3 + _random.nextDouble() * 0.7,
      wobble: _random.nextDouble() * math.pi * 2,
      size: 4 + _random.nextDouble() * 6,
      color: [
        const Color(0xFFFF7A65),
        const Color(0xFFA88DD0),
        const Color(0xFF5DBBB3),
        const Color(0xFFFFD700),
        const Color(0xFFFF9A9E),
        const Color(0xFF88D8B0),
      ][_random.nextInt(6)],
    ));
    if (widget.trigger) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(
              pieces: _pieces,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiPiece {
  final double x, velocity, wobble, size;
  final Color color;
  const _ConfettiPiece({
    required this.x,
    required this.velocity,
    required this.wobble,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    for (final p in pieces) {
      final dx = p.x * size.width +
          math.sin(progress * math.pi * 4 + p.wobble) * 40;
      final dy = -20 + progress * size.height * p.velocity * 1.2;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      final rotation = progress * math.pi * 4 + p.wobble;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

/// 🔢 AnimatedNumber — Counting up number animation
class AnimatedNumber extends StatelessWidget {
  final double value;
  final TextStyle style;
  final int decimals;
  final String suffix;
  final Duration duration;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 0,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '${val.toStringAsFixed(decimals)}$suffix',
          style: style,
        );
      },
    );
  }
}

/// 🌊 GlowingBorder — Animated gradient border for premium cards
class GlowingBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color> colors;
  final Duration duration;

  const GlowingBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.colors = const [
      Color(0xFFFF7A65),
      Color(0xFFA88DD0),
      Color(0xFF5DBBB3),
      Color(0xFFFFD700),
    ],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<GlowingBorder> createState() => _GlowingBorderState();
}

class _GlowingBorderState extends State<GlowingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              startAngle: _controller.value * math.pi * 2,
              colors: [...widget.colors, widget.colors.first],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.first.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(widget.borderRadius - widget.borderWidth),
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 🫧 BreathingAura — Subtle pulsing background circle
class BreathingAura extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const BreathingAura({
    super.key,
    this.color = const Color(0xFFFF7A65),
    this.size = 200,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<BreathingAura> createState() => _BreathingAuraState();
}

class _BreathingAuraState extends State<BreathingAura>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = 0.8 + _controller.value * 0.4;
        final opacity = 0.08 + _controller.value * 0.08;
        return Container(
          width: widget.size * scale,
          height: widget.size * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: opacity),
                widget.color.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}
