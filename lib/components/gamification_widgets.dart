import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/gamification_model.dart';

/// XP Progress Bar Widget
class XPProgressBar extends StatelessWidget {
  final int totalXP;
  final bool showLabel;

  const XPProgressBar({
    super.key,
    required this.totalXP,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final level = LevelSystem.calculateLevel(totalXP);
    final progress = LevelSystem.progressToNextLevel(totalXP);
    final xpNeeded = LevelSystem.xpForNextLevel(totalXP);
    final levelTitle = LevelSystem.getLevelTitle(level);
    final levelColor = LevelSystem.getLevelColor(level);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor.withValues(alpha: 0.15), levelColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: levelColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: levelColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nivel $level",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: levelColor,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$xpNeeded XP",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [levelColor, levelColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            Text(
              "Siguiente nivel: ${((1 - progress) * 100).toInt()}% restante",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: levelColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Achievement Badge Widget
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: unlocked
                  ? RadialGradient(
                      colors: [
                        achievement.color.withValues(alpha: 0.3),
                        achievement.color.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              color: unlocked ? null : AppColors.lightGray.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? achievement.color : AppColors.gray.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: achievement.color.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              achievement.icon,
              size: 40,
              color: unlocked ? achievement.color : AppColors.gray.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: unlocked ? AppColors.dark : AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}
