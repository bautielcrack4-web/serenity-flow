import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

/// Level/XP System for gamification
class LevelSystem {
  static const int xpPerLevel = 100;
  static const int xpPerSession = 10;
  static const int xpPerStreak = 5;
  
  static int calculateLevel(int totalXP) {
    return (totalXP / xpPerLevel).floor() + 1;
  }
  
  static int xpForNextLevel(int totalXP) {
    int currentLevel = calculateLevel(totalXP);
    return currentLevel * xpPerLevel - totalXP;
  }
  
  static double progressToNextLevel(int totalXP) {
    int currentLevel = calculateLevel(totalXP);
    int xpAtLevelStart = (currentLevel - 1) * xpPerLevel;
    int xpInCurrentLevel = totalXP - xpAtLevelStart;
    return xpInCurrentLevel / xpPerLevel;
  }
  
  static String getLevelTitle(int level) {
    if (level < 5) return "Novice";
    if (level < 10) return "Apprentice";
    if (level < 20) return "Practitioner";
    if (level < 30) return "Expert";
    if (level < 50) return "Master";
    return "Guru";
  }
  
  static Color getLevelColor(int level) {
    if (level < 5) return AppColors.coral;
    if (level < 10) return AppColors.lavender;
    if (level < 20) return AppColors.turquoise;
    if (level < 30) return const Color(0xFFFFD700); // Gold
    if (level < 50) return const Color(0xFFFF6B9D); // Pink
    return const Color(0xFF9D50BB); // Purple
  }
}

/// Achievement/Badge System
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredValue;
  final AchievementType type;
  
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredValue,
    required this.type,
  });
}

enum AchievementType {
  sessions,
  streak,
  minutes,
  level,
}

final List<Achievement> achievements = [
  Achievement(
    id: 'first_session',
    name: 'First Session',
    description: 'Complete your first session',
    icon: Icons.star_rounded,
    color: AppColors.coral,
    requiredValue: 1,
    type: AchievementType.sessions,
  ),
  Achievement(
    id: 'streak_3',
    name: 'Fire Streak',
    description: '3 consecutive days',
    icon: Icons.local_fire_department_rounded,
    color: Colors.orange,
    requiredValue: 3,
    type: AchievementType.streak,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Perfect Week',
    description: '7 consecutive days',
    icon: Icons.emoji_events_rounded,
    color: Colors.amber,
    requiredValue: 7,
    type: AchievementType.streak,
  ),
  Achievement(
    id: 'sessions_10',
    name: 'Dedication',
    description: '10 sessions completed',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.lavender,
    requiredValue: 10,
    type: AchievementType.sessions,
  ),
  Achievement(
    id: 'sessions_50',
    name: 'Warrior',
    description: '50 sessions completed',
    icon: Icons.shield_rounded,
    color: AppColors.turquoise,
    requiredValue: 50,
    type: AchievementType.sessions,
  ),
  Achievement(
    id: 'level_10',
    name: 'Master',
    description: 'Reach level 10',
    icon: Icons.diamond_rounded,
    color: const Color(0xFF00D1FF),
    requiredValue: 10,
    type: AchievementType.level,
  ),
];
