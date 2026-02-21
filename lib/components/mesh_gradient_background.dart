import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'dart:ui' as api_ui;

class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  const MeshGradientBackground({super.key, required this.child});

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // Independent movements for 5 blobs
  late List<Animation<double>> _movements;
  late List<Animation<double>> _scales;

  // Configuration for "Serene Dawn" (Restored as Default)
  final Color backgroundColor = AppColors.dawnBackground;
  final List<Color> blobColors = AppColors.dawnBlobs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Very slow, ambient movement
    )..repeat(reverse: true);

    // Initialize 5 distinct movement patterns
    _movements = [
      Tween<double>(begin: -30, end: 30).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)),
      Tween<double>(begin: 40, end: -40).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad)),
      Tween<double>(begin: -20, end: 50).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic)),
      Tween<double>(begin: 20, end: -30).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart)),
      Tween<double>(begin: 0, end: 40).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)),
    ];

    // Breathing animations (Scaling up/down)
    _scales = [
      Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut))),
      Tween<double>(begin: 1.2, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeInOut))),
      Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeInOut))),
      Tween<double>(begin: 1.1, end: 0.8).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.6, curve: Curves.easeInOut))),
      Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeInOut))),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (blobColors.length < 5) return Container(color: backgroundColor, child: widget.child);

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base Background
        Container(color: backgroundColor),
        
        // Animated Blobs
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Blob 1: Top Left (Large Foundation)
                  Positioned(
                    top: -100 + _movements[0].value,
                    left: -100 + _movements[1].value,
                    child: _buildBlob(400 * _scales[0].value, blobColors[0]),
                  ),
                  
                  // Blob 2: Bottom Right (Large Foundation)
                  Positioned(
                    bottom: -150 + _movements[1].value,
                    right: -100 + _movements[2].value,
                    child: _buildBlob(450 * _scales[1].value, blobColors[1]),
                  ),
                  
                  // Blob 3: Center Right (Accent)
                  Positioned(
                    top: size.height * 0.3 + _movements[2].value,
                    right: -50 + _movements[3].value,
                    child: _buildBlob(300 * _scales[2].value, blobColors[2]),
                  ),

                  // Blob 4: Bottom Left (Accent)
                  Positioned(
                    bottom: 100 + _movements[3].value,
                    left: -50 + _movements[4].value,
                    child: _buildBlob(350 * _scales[3].value, blobColors[3]),
                  ),

                  // Blob 5: Top Center/Right (Highlight)
                  Positioned(
                    top: 50 + _movements[4].value,
                    right: 80 + _movements[0].value,
                    child: _buildBlob(250 * _scales[4].value, blobColors[4].withValues(alpha: 0.4)),
                  ),
                ],
              );
            },
          ),
        ),
        
        // Unified Atmosphere Blur (High Sigma for Dreamy Effect)
        BackdropFilter(
          filter: api_ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60), 
          child: Container(color: Colors.transparent), 
        ),

        // Subtle Noise/Grain (Optional, simulate with low opacity white overlay)
        Container(color: Colors.white.withValues(alpha: 0.01)),

        // Child Content
        // Child Content
        widget.child,
      ],
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2), // Lower opacity for subtler effect
        shape: BoxShape.circle,
      ),
    );
  }
}
