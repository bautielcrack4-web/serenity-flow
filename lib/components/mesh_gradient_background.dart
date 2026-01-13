import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'dart:ui' as api_ui; // Import needed for ImageFilter

import 'dart:math';

class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  const MeshGradientBackground({super.key, required this.child});

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // Independent movements for blobs
  late Animation<double> _move1;
  late Animation<double> _move2;
  late Animation<double> _move3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slow, organic movement
    )..repeat(reverse: true);

    _move1 = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _move2 = Tween<double>(begin: 30, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );
    _move3 = Tween<double>(begin: -20, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
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
        // Base Background
        Container(color: AppColors.cream),
        
        // Animated Blobs (OPTIMIZED: Isolated with RepaintBoundary)
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Blob 1: Coral (Top Left)
                  Positioned(
                    top: -100 + _move1.value,
                    left: -50 + _move2.value,
                    child: _buildBlob(300, AppColors.coral.withOpacity(0.2)),
                  ),
                  
                  // Blob 2: Lavender (Middle Right)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3 + _move2.value,
                    right: -80 + _move3.value,
                    child: _buildBlob(350, AppColors.lavender.withOpacity(0.2)),
                  ),
                  
                  // Blob 3: Turquoise (Bottom Left)
                  Positioned(
                    bottom: -50 + _move3.value,
                    left: -20 + _move1.value,
                    child: _buildBlob(320, AppColors.turquoise.withOpacity(0.15)),
                  ),
                ],
              );
            },
          ),
        ),
        
        // Unified Glass Blur (OPTIMIZED: Lower Sigma for smoothness)
        BackdropFilter(
          filter: api_ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18), 
          child: Container(color: Colors.white.withOpacity(0.1)), 
        ),

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
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
