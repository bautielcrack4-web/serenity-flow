import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

class Routine {
  final String id;
  final String name;
  final String description;
  final String duration;
  final int poseCount;
  final int difficulty;
  final String icon;
  final List<Pose> poses;
  final LinearGradient themeGradient; // Changed from Color
  bool isFavorite;

  Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.poseCount,
    required this.difficulty,
    required this.icon,
    required this.poses,
    required this.themeGradient,
    this.isFavorite = false,
  });

  // Total duration in seconds
  int get totalDurationSeconds {
    return poses.fold(0, (sum, pose) => sum + pose.duration);
  }

  // Computed duration in minutes based on actual pose durations
  String get computedDuration {
    int totalSeconds = 0;
    for (var pose in poses) {
      totalSeconds += pose.duration;
      if (pose.perSide) totalSeconds += pose.duration; // Count both sides
    }
    int minutes = (totalSeconds / 60).ceil();
    return '$minutes min';
  }
}

class Pose {
  final String name;
  final String image;
  final int duration;
  final bool perSide;

  Pose({
    required this.name,
    required this.image,
    required this.duration,
    this.perSide = false,
  });
}

final List<Routine> routinesData = [
  Routine(
    id: 'despertar_suave',
    name: 'Gentle Wake Up',
    description: 'Activate your body softly',
    duration: '8 min',
    poseCount: 6,
    difficulty: 1,
    icon: 'assets/images/poses/pose_montana.png',
    themeGradient: AppColors.peachGradient,
    poses: [
      Pose(name: 'Mountain', image: 'assets/images/poses/pose_montana.png', duration: 30),
      Pose(name: 'Cat-Cow', image: 'assets/images/poses/pose_gato_vaca.png', duration: 45),
      Pose(name: 'Side Stretch', image: 'assets/images/poses/pose_estiramiento_lateral.png', duration: 30, perSide: true),
      Pose(name: 'Seated Twist', image: 'assets/images/poses/pose_torsion_sentada.png', duration: 30, perSide: true),
      Pose(name: 'Child\'s Pose', image: 'assets/images/poses/pose_nino.png', duration: 45),
      Pose(name: 'Energizing Breath', image: 'assets/images/poses/pose_respiracion_brazos.png', duration: 30),
    ],
  ),
  Routine(
    id: 'alivio_tension',
    name: 'Tension Relief',
    description: 'Release neck and shoulders',
    duration: '10 min',
    poseCount: 7,
    difficulty: 2,
    icon: 'assets/images/poses/pose_circulo_cuello.png',
    themeGradient: AppColors.lavenderSoftGradient,
    poses: [
      Pose(name: 'Seated Breathing', image: 'assets/images/poses/pose_respiracion_brazos.png', duration: 30),
      Pose(name: 'Neck Circles', image: 'assets/images/poses/pose_circulo_cuello.png', duration: 30),
      Pose(name: 'Shoulder Rolls', image: 'assets/images/poses/pose_circulo_hombros.png', duration: 30),
      Pose(name: 'Cross Arm Stretch', image: 'assets/images/poses/pose_brazo_cruzado.png', duration: 30, perSide: true),
      Pose(name: 'Seated Twist', image: 'assets/images/poses/pose_torsion_sentada.png', duration: 45, perSide: true),
      Pose(name: 'Cat-Cow', image: 'assets/images/poses/pose_gato_vaca.png', duration: 60),
      Pose(name: 'Child\'s Pose', image: 'assets/images/poses/pose_nino.png', duration: 60),
    ],
  ),
  Routine(
    id: 'sueno_reparador',
    name: 'Deep Sleep',
    description: 'Relax before bed',
    duration: '12 min',
    poseCount: 6,
    difficulty: 1,
    icon: 'assets/images/poses/pose_savasana.png',
    themeGradient: AppColors.turquoiseSoftGradient,
    poses: [
      Pose(name: 'Deep Breathing', image: 'assets/images/poses/pose_respiracion_brazos.png', duration: 60),
      Pose(name: 'Reclined Butterfly', image: 'assets/images/poses/pose_mariposa_reclinada.png', duration: 90),
      Pose(name: 'Legs Up the Wall', image: 'assets/images/poses/pose_piernas_pared.png', duration: 120),
      Pose(name: 'Reclined Twist', image: 'assets/images/poses/pose_torsion_reclinada.png', duration: 60, perSide: true),
      Pose(name: 'Knee Hug', image: 'assets/images/poses/pose_abrazo_rodillas.png', duration: 60),
      Pose(name: 'Savasana', image: 'assets/images/poses/pose_savasana.png', duration: 180),
    ],
  ),
];
