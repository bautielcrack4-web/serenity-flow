import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

class QuestionProgressBar extends StatefulWidget {
  final int totalSteps;
  final int currentStep;

  const QuestionProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  State<QuestionProgressBar> createState() => _QuestionProgressBarState();
}

class _QuestionProgressBarState extends State<QuestionProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.totalSteps, (index) {
            final isCompleted = index < widget.currentStep - 1;
            final isCurrent = index == widget.currentStep - 1;
            
            Widget circle = Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isCompleted || isCurrent) ? AppColors.coral : Colors.transparent,
                border: Border.all(
                  color: (isCompleted || isCurrent) ? AppColors.coral : AppColors.lightGray,
                  width: 1,
                ),
              ),
            );

            if (isCurrent) {
              circle = ScaleTransition(scale: _pulseAnimation, child: circle);
            }

            return Padding(
              padding: EdgeInsets.only(right: index == widget.totalSteps - 1 ? 0 : 8),
              child: circle,
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          "${widget.currentStep} of ${widget.totalSteps}",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
