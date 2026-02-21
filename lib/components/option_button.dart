import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/services/audio_service.dart';

class OptionButton extends StatefulWidget {
  final String text;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    this.emoji,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

  void _handleTap() {
    audioService.playClick();
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.coral : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected ? AppColors.coral : AppColors.lightGray,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.emoji != null) ...[
                Text(
                  widget.emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: widget.isSelected ? AppColors.white : AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
