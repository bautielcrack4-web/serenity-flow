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
  final LinearGradient themeGradient;
  bool isFavorite;
  final bool isCustom;

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
    this.isCustom = false,
  });

  // Total duration in seconds
  int get totalDurationSeconds {
    return poses.fold(0, (sum, pose) => sum + pose.duration);
  }

  // Computed duration in minutes based on actual pose durations
  String get computedDuration {
    int totalSeconds = totalDurationSeconds;
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'duration': duration,
      'perSide': perSide,
    };
  }

  factory Pose.fromMap(Map<String, dynamic> map) {
    return Pose(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      duration: map['duration'] ?? 30,
      perSide: map['perSide'] ?? false,
    );
  }
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
  Routine(
    id: 'fuerza_guerrero',
    name: 'Warrior Strength',
    description: 'Build power and stability',
    duration: '15 min',
    poseCount: 6,
    difficulty: 3,
    icon: 'assets/images/poses/pose_guerrero_2.png',
    themeGradient: AppColors.sunsetGradient,
    poses: [
      Pose(name: 'Mountain', image: 'assets/images/poses/pose_montana.png', duration: 30),
      Pose(name: 'Warrior I', image: 'assets/images/poses/pose_guerrero_1.png', duration: 45, perSide: true),
      Pose(name: 'Warrior II', image: 'assets/images/poses/pose_guerrero_2.png', duration: 45, perSide: true),
      Pose(name: 'Warrior III', image: 'assets/images/poses/pose_guerrero_3.png', duration: 30, perSide: true),
      Pose(name: 'Plank', image: 'assets/images/poses/pose_plancha.png', duration: 45),
      Pose(name: 'Child\'s Pose', image: 'assets/images/poses/pose_nino.png', duration: 60),
    ],
  ),
  Routine(
    id: 'flex_flow',
    name: 'Flex & Flow',
    description: 'Improve spine flexibility',
    duration: '12 min',
    poseCount: 6,
    difficulty: 2,
    icon: 'assets/images/poses/pose_perro_abajo.png',
    themeGradient: AppColors.oceanGradient,
    poses: [
      Pose(name: 'Cat-Cow', image: 'assets/images/poses/pose_gato_vaca.png', duration: 60),
      Pose(name: 'Downward Dog', image: 'assets/images/poses/pose_perro_abajo.png', duration: 45),
      Pose(name: 'Upward Dog', image: 'assets/images/poses/pose_perro_arriba.png', duration: 45),
      Pose(name: 'Triangle', image: 'assets/images/poses/pose_triangulo.png', duration: 30, perSide: true),
      Pose(name: 'Forward Fold', image: 'assets/images/poses/pose_pinza_pie.png', duration: 45),
      Pose(name: 'Savasana', image: 'assets/images/poses/pose_savasana.png', duration: 60),
    ],
  ),
  Routine(
    id: 'centro_balance',
    name: 'Core & Balance',
    description: 'Focus and core power',
    duration: '14 min',
    poseCount: 6,
    difficulty: 3,
    icon: 'assets/images/poses/pose_arbol.png',
    themeGradient: AppColors.forestGradient,
    poses: [
      Pose(name: 'Tree Pose', image: 'assets/images/poses/pose_arbol.png', duration: 45, perSide: true),
      Pose(name: 'Chair Pose', image: 'assets/images/poses/pose_silla.png', duration: 45),
      Pose(name: 'Side Plank', image: 'assets/images/poses/pose_plancha_lateral.png', duration: 30, perSide: true),
      Pose(name: 'Half Moon', image: 'assets/images/poses/pose_media_luna.png', duration: 30, perSide: true),
      Pose(name: 'Tiger Pose', image: 'assets/images/poses/pose_tigre.png', duration: 45, perSide: true),
      Pose(name: 'Mountain', image: 'assets/images/poses/pose_montana.png', duration: 30),
    ],
  ),
  Routine(
    id: 'recuperacion_cadera',
    name: 'Hip Recovery',
    description: 'Deep lower body release',
    duration: '16 min',
    poseCount: 6,
    difficulty: 1,
    icon: 'assets/images/poses/pose_mariposa_sentada.png',
    themeGradient: AppColors.royalGradient,
    poses: [
      Pose(name: 'Butterfly', image: 'assets/images/poses/pose_mariposa_sentada.png', duration: 90),
      Pose(name: 'Wide Angle', image: 'assets/images/poses/pose_angulo_abierto.png', duration: 60),
      Pose(name: 'Quad Stretch', image: 'assets/images/poses/pose_estiramiento_cuadriceps.png', duration: 45, perSide: true),
      Pose(name: 'Spinal Twist', image: 'assets/images/poses/pose_giro_espinal.png', duration: 45, perSide: true),
      Pose(name: 'Seated Fold', image: 'assets/images/poses/pose_pinza_sentada.png', duration: 60),
      Pose(name: 'Savasana', image: 'assets/images/poses/pose_savasana.png', duration: 120),
    ],
  ),
  Routine(
    id: 'alivio_oficina',
    name: 'Office Relief',
    description: 'Perfect for desk work breaks',
    duration: '8 min',
    poseCount: 7,
    difficulty: 1,
    icon: 'assets/images/poses/pose_estiramiento_muneca.png',
    themeGradient: AppColors.peachGradient,
    poses: [
      Pose(name: 'Neck Circles', image: 'assets/images/poses/pose_circulo_cuello.png', duration: 30),
      Pose(name: 'Side Neck Stretch', image: 'assets/images/poses/pose_cuello_lateral.png', duration: 30, perSide: true),
      Pose(name: 'Shoulder Rolls', image: 'assets/images/poses/pose_circulo_hombros.png', duration: 30),
      Pose(name: 'Triceps Stretch', image: 'assets/images/poses/pose_estiramiento_triceps.png', duration: 30, perSide: true),
      Pose(name: 'Wrist Stretch', image: 'assets/images/poses/pose_estiramiento_muneca.png', duration: 30),
      Pose(name: 'Seated Twist', image: 'assets/images/poses/pose_torsion_sentada.png', duration: 30, perSide: true),
      Pose(name: 'Seated Side Lean', image: 'assets/images/poses/pose_flexion_lateral_sentada.png', duration: 30, perSide: true),
    ],
  ),
  Routine(
    id: 'flujo_tarde',
    name: 'Evening Flow',
    description: 'Wind down after a long day',
    duration: '10 min',
    poseCount: 7,
    difficulty: 2,
    icon: 'assets/images/poses/pose_media_luna.png',
    themeGradient: AppColors.sunsetGradient,
    poses: [
      Pose(name: 'Low Lunge', image: 'assets/images/poses/pose_estocada_baja.png', duration: 45, perSide: true),
      Pose(name: 'Low Moon', image: 'assets/images/poses/pose_media_luna_baja.png', duration: 45, perSide: true),
      Pose(name: 'Half Moon', image: 'assets/images/poses/pose_media_luna.png', duration: 30, perSide: true),
      Pose(name: 'Happy Baby', image: 'assets/images/poses/pose_happy_baby.png', duration: 60),
      Pose(name: 'Bridge Pose', image: 'assets/images/poses/pose_puente.png', duration: 45),
      Pose(name: 'Knee Hug', image: 'assets/images/poses/pose_abrazo_rodillas.png', duration: 45),
      Pose(name: 'Savasana', image: 'assets/images/poses/pose_savasana.png', duration: 60),
    ],
  ),
  Routine(
    id: 'maestria_cadera',
    name: 'Hip Mastery',
    description: 'Elite hip flexibility focus',
    duration: '12 min',
    poseCount: 6,
    difficulty: 3,
    icon: 'assets/images/poses/pose_cisne.png',
    themeGradient: AppColors.royalGradient,
    poses: [
      Pose(name: 'Standing Hip Opener', image: 'assets/images/poses/pose_apertura_cadera_pie.png', duration: 45, perSide: true),
      Pose(name: 'Standing Figure Four', image: 'assets/images/poses/pose_figura_4_pie.png', duration: 45, perSide: true),
      Pose(name: 'Swan Pose', image: 'assets/images/poses/pose_cisne.png', duration: 60, perSide: true),
      Pose(name: 'Pigeon Pose', image: 'assets/images/poses/pose_paloma.png', duration: 60, perSide: true),
      Pose(name: 'Butterfly', image: 'assets/images/poses/pose_mariposa_sentada.png', duration: 60),
      Pose(name: 'Legs Up Wall', image: 'assets/images/poses/pose_piernas_pared.png', duration: 60),
    ],
  ),
  Routine(
    id: 'flujo_total',
    name: 'Full Body Flow',
    description: 'Complete mind-body harmony',
    duration: '22 min',
    poseCount: 12,
    difficulty: 2,
    icon: 'assets/images/poses/pose_perro_abajo.png',
    themeGradient: AppColors.oceanGradient,
    poses: [
      Pose(name: 'Mountain', image: 'assets/images/poses/pose_montana.png', duration: 45),
      Pose(name: 'Neck Circles', image: 'assets/images/poses/pose_circulo_cuello.png', duration: 45),
      Pose(name: 'Cat-Cow', image: 'assets/images/poses/pose_gato_vaca.png', duration: 60),
      Pose(name: 'Downward Dog', image: 'assets/images/poses/pose_perro_abajo.png', duration: 60),
      Pose(name: 'Warrior I', image: 'assets/images/poses/pose_guerrero_1.png', duration: 60, perSide: true),
      Pose(name: 'Triangle', image: 'assets/images/poses/pose_triangulo.png', duration: 45, perSide: true),
      Pose(name: 'Plank', image: 'assets/images/poses/pose_plancha.png', duration: 45),
      Pose(name: 'Cobra', image: 'assets/images/poses/pose_perro_arriba.png', duration: 45),
      Pose(name: 'Child\'s Pose', image: 'assets/images/poses/pose_nino.png', duration: 90),
      Pose(name: 'Butterfly', image: 'assets/images/poses/pose_mariposa_sentada.png', duration: 60),
      Pose(name: 'Knee Hug', image: 'assets/images/poses/pose_abrazo_rodillas.png', duration: 60),
      Pose(name: 'Savasana', image: 'assets/images/poses/pose_savasana.png', duration: 180),
    ],
  ),
  Routine(
    id: 'poder_yoga',
    name: 'Power Challenge',
    description: 'Intense strength & stamina',
    duration: '20 min',
    poseCount: 10,
    difficulty: 3,
    icon: 'assets/images/poses/pose_guerrero_3.png',
    themeGradient: AppColors.fireGradient,
    poses: [
      Pose(name: 'Plank', image: 'assets/images/poses/pose_plancha.png', duration: 60),
      Pose(name: 'Side Plank', image: 'assets/images/poses/pose_plancha_lateral.png', duration: 45, perSide: true),
      Pose(name: 'Warrior II', image: 'assets/images/poses/pose_guerrero_2.png', duration: 60, perSide: true),
      Pose(name: 'Warrior III', image: 'assets/images/poses/pose_guerrero_3.png', duration: 45, perSide: true),
      Pose(name: 'Chair Pose', image: 'assets/images/poses/pose_silla.png', duration: 60),
      Pose(name: 'Half Moon', image: 'assets/images/poses/pose_media_luna.png', duration: 45, perSide: true),
      Pose(name: 'Tiger Pose', image: 'assets/images/poses/pose_tigre.png', duration: 60, perSide: true),
      Pose(name: 'Downward Dog', image: 'assets/images/poses/pose_perro_abajo.png', duration: 45),
      Pose(name: 'Table Top', image: 'assets/images/poses/pose_mesa.png', duration: 60),
      Pose(name: 'Mountain', image: 'assets/images/poses/pose_montana.png', duration: 60),
    ],
  ),
  Routine(
    id: 'maestro_zen',
    name: 'Deep Zen Master',
    description: 'Ultimate meditation experience',
    duration: '30 min',
    poseCount: 9,
    difficulty: 1,
    icon: 'assets/images/poses/pose_savasana.png',
    themeGradient: AppColors.turquoiseSoftGradient,
    poses: [
      Pose(name: 'Breathing', image: 'assets/images/poses/pose_respiracion_brazos.png', duration: 120),
      Pose(name: 'Child\'s Pose', image: 'assets/images/poses/pose_nino.png', duration: 180),
      Pose(name: 'Butterfly', image: 'assets/images/poses/pose_mariposa_sentada.png', duration: 120),
      Pose(name: 'Legs Up Wall', image: 'assets/images/poses/pose_piernas_pared.png', duration: 240),
      Pose(name: 'Reclined Twist', image: 'assets/images/poses/pose_torsion_reclinada.png', duration: 90, perSide: true),
      Pose(name: 'Happy Baby', image: 'assets/images/poses/pose_happy_baby.png', duration: 120),
      Pose(name: 'Pigeon Pose', image: 'assets/images/poses/pose_paloma.png', duration: 120, perSide: true),
      Pose(name: 'Bridge', image: 'assets/images/poses/pose_puente.png', duration: 120),
      Pose(name: 'Final Savasana', image: 'assets/images/poses/pose_savasana.png', duration: 480),
    ],
  ),
];
