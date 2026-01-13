import 'package:flutter/material.dart';

/// Shimmer loading skeleton for premium loading states
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final ShimmerShape shape;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = ShimmerShape.rectangle,
  });

  const ShimmerLoading.circular({
    super.key,
    required double size,
  }) : width = size,
       height = size,
       borderRadius = null,
       shape = ShimmerShape.circle;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

enum ShimmerShape { rectangle, circle }

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.shape == ShimmerShape.circle 
              ? BorderRadius.circular(widget.width / 2)
              : widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for routine card
class RoutineCardSkeleton extends StatelessWidget {
  const RoutineCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const ShimmerLoading.circular(size: 100),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerLoading(width: double.infinity, height: 24, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(height: 8),
                  ShimmerLoading(width: 150, height: 16, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ShimmerLoading(width: 80, height: 28, borderRadius: BorderRadius.circular(12)),
                      const SizedBox(width: 12),
                      ShimmerLoading(width: 80, height: 28, borderRadius: BorderRadius.circular(12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
