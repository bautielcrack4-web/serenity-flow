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
    int xpNeededForCurrentLevel = (currentLevel - 1) * xpPerLevel;
    return currentLevel * xpPerLevel - totalXP;
  }
  
  static double progressToNextLevel(int totalXP) {
    int currentLevel = calculateLevel(totalXP);
    int xpAtLevelStart = (currentLevel - 1) * xpPerLevel;
    int xpInCurrentLevel = totalXP - xpAtLevelStart;
    return xpInCurrentLevel / xpPerLevel;
  }
  
  static String getLevelTitle(int level) {
    if (level < 5) return "Novato";
    if (level < 10) return "Aprendiz";
    if (level < 20) return "Practicante";
    if (level < 30) return "Experto";
    if (level < 50) return "Maestro";
    return "Gurú";
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
    name: 'Primera Sesión',
    description: 'Completa tu primera sesión',
    icon: Icons.star_rounded,
    color: AppColors.coral,
    requiredValue: 1,
    type: AchievementType.sessions,
  ),
  Achievement(
    id: 'streak_3',
    name: 'Racha de Fuego',
    description: '3 días consecutivos',
    icon: Icons.local_fire_department_rounded,
    color: Colors.orange,
    requiredValue: 3,
    type: AchievementType.streak,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Semana Perfecta',
    description: '7 días consecutivos',
    icon: Icons.emoji_events_rounded,
    color: Colors.amber,
    requiredValue: 7,
    type: AchievementType.streak,
  ),
  Achievement(
    id: 'sessions_10',
    name: 'Dedicación',
    description: '10 sesiones completadas',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.lavender,
    requiredValue: 10,
    type: AchievementType.sessions,
  ),
  Achievement(
    id: 'sessions_50',
    name: 'Guerrero',
    description: '50 sesiones completadas',
    icon: Icons.shield_rounded,
    color: AppColors.turquoise,
    requiredValue: 50,
    type: AchievementType.sessions,
  ),
  Achievement(
    id: 'level_10',
    name: 'Maestro',
    description: 'Alcanza nivel 10',
    icon: Icons.diamond_rounded,
    color: const Color(0xFF00D1FF),
    requiredValue: 10,
    type: AchievementType.level,
  ),
];
