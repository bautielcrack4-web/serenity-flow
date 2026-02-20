import 'package:flutter/material.dart';

/// Data model for workout exercises and workout sessions
class Exercise {
  final String name;
  final String emoji;
  final int durationSeconds;
  final String? description;
  final bool isRest;

  const Exercise({
    required this.name,
    required this.emoji,
    required this.durationSeconds,
    this.description,
    this.isRest = false,
  });
}

class Workout {
  final String id;
  final String title;
  final String emoji;
  final String category;
  final String level;
  final String duration;
  final int calories;
  final Color color;
  final String description;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
    required this.duration,
    required this.calories,
    required this.color,
    required this.description,
    required this.exercises,
  });

  int get totalDurationSeconds =>
      exercises.fold(0, (sum, e) => sum + e.durationSeconds);
}

/// Pre-built workout library
class WorkoutLibrary {
  static const _coral = Color(0xFFFF6B6B);
  static const _lavender = Color(0xFF9C89B8);
  static const _turquoise = Color(0xFF4ECDC4);
  static const _pink = Color(0xFFE91E63);
  static const _indigo = Color(0xFF5C6BC0);

  static final List<Workout> all = [
    hiitQuemagrasa,
    tabataTotalBody,
    yogaFlexibilidad,
    powerYogaFlow,
    caminataEnergizante,
    danceCardio,
    fuerzaSinEquipo,
    gluteosYPiernas,
    stretchingNocturno,
    cardioBlast,
  ];

  static final hiitQuemagrasa = Workout(
    id: 'hiit_quemagrasa',
    title: 'HIIT Quemagrasa Express',
    emoji: '🔥',
    category: 'HIIT',
    level: 'Intermedio',
    duration: '15 min',
    calories: 200,
    color: _coral,
    description: 'Intervalos de alta intensidad para maximizar la quema de grasa.',
    exercises: [
      const Exercise(name: 'Jumping Jacks', emoji: '⭐', durationSeconds: 30, description: 'Brazos arriba, piernas abiertas'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Burpees', emoji: '💪', durationSeconds: 30, description: 'Plancha, flexión, salto'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Mountain Climbers', emoji: '🏔️', durationSeconds: 30, description: 'Rodillas al pecho, rápido'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Sentadillas con salto', emoji: '🦵', durationSeconds: 30, description: 'Sentadilla profunda + salto'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'High Knees', emoji: '🏃', durationSeconds: 30, description: 'Rodillas altas con velocidad'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 15, isRest: true),
      const Exercise(name: 'Plancha', emoji: '🧱', durationSeconds: 30, description: 'Mantén la posición firme'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Jumping Lunges', emoji: '🦿', durationSeconds: 30, description: 'Zancadas alternas con salto'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Burpees finales', emoji: '🔥', durationSeconds: 30, description: '¡Último esfuerzo, dalo todo!'),
    ],
  );

  static final tabataTotalBody = Workout(
    id: 'tabata_total',
    title: 'Tabata Total Body',
    emoji: '🔥',
    category: 'HIIT',
    level: 'Avanzado',
    duration: '20 min',
    calories: 300,
    color: _coral,
    description: '8 rondas de trabajo/descanso que trabajan todo el cuerpo.',
    exercises: [
      const Exercise(name: 'Squat Jumps', emoji: '🦵', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Push Ups', emoji: '💪', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Bicycle Crunches', emoji: '🚴', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Lateral Lunges', emoji: '🦿', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Plank Jacks', emoji: '🧱', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Tricep Dips', emoji: '💪', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'High Knees', emoji: '🏃', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Burpees', emoji: '🔥', durationSeconds: 20),
    ],
  );

  static final yogaFlexibilidad = Workout(
    id: 'yoga_flex',
    title: 'Yoga para Flexibilidad',
    emoji: '🧘',
    category: 'Yoga',
    level: 'Principiante',
    duration: '25 min',
    calories: 120,
    color: _lavender,
    description: 'Posturas suaves para mejorar tu flexibilidad y relajarte.',
    exercises: [
      const Exercise(name: 'Respiración profunda', emoji: '🫁', durationSeconds: 60, description: 'Inhala 4s, exhala 6s'),
      const Exercise(name: 'Gato-Vaca', emoji: '🐱', durationSeconds: 45, description: 'Alterna entre arco y redondeo de espalda'),
      const Exercise(name: 'Perro boca abajo', emoji: '🐕', durationSeconds: 45, description: 'V invertida, empuja caderas al cielo'),
      const Exercise(name: 'Guerrero I', emoji: '⚔️', durationSeconds: 45, description: 'Pierna adelante flexionada, brazos arriba'),
      const Exercise(name: 'Guerrero II', emoji: '🗡️', durationSeconds: 45, description: 'Brazos extendidos, mirada al frente'),
      const Exercise(name: 'Triángulo', emoji: '📐', durationSeconds: 45, description: 'Extiende al lateral, mano al tobillo'),
      const Exercise(name: 'Paloma', emoji: '🕊️', durationSeconds: 60, description: 'Apertura profunda de cadera'),
      const Exercise(name: 'Torsión sentada', emoji: '🌀', durationSeconds: 45, description: 'Giro suave, mira sobre el hombro'),
      const Exercise(name: 'Mariposa', emoji: '🦋', durationSeconds: 45, description: 'Plantas de los pies juntas, rodillas al piso'),
      const Exercise(name: 'Savasana', emoji: '🌙', durationSeconds: 90, description: 'Relaja completamente todo el cuerpo'),
    ],
  );

  static final powerYogaFlow = Workout(
    id: 'power_yoga',
    title: 'Power Yoga Flow',
    emoji: '🧘',
    category: 'Yoga',
    level: 'Intermedio',
    duration: '30 min',
    calories: 180,
    color: _lavender,
    description: 'Yoga dinámico que combina fuerza y flexibilidad.',
    exercises: [
      const Exercise(name: 'Saludo al sol A', emoji: '☀️', durationSeconds: 60),
      const Exercise(name: 'Saludo al sol B', emoji: '🌅', durationSeconds: 60),
      const Exercise(name: 'Warrior Flow', emoji: '⚔️', durationSeconds: 45),
      const Exercise(name: 'Chair Pose', emoji: '🪑', durationSeconds: 30),
      const Exercise(name: 'Crow Pose', emoji: '🐦', durationSeconds: 30),
      const Exercise(name: 'Plank Hold', emoji: '🧱', durationSeconds: 45),
      const Exercise(name: 'Side Plank', emoji: '📏', durationSeconds: 30),
      const Exercise(name: 'Boat Pose', emoji: '🚤', durationSeconds: 30),
      const Exercise(name: 'Wheel Pose', emoji: '🎡', durationSeconds: 30),
      const Exercise(name: 'Cool Down', emoji: '🌙', durationSeconds: 120),
    ],
  );

  static final caminataEnergizante = Workout(
    id: 'caminata',
    title: 'Caminata Energizante',
    emoji: '🚶',
    category: 'Caminar',
    level: 'Principiante',
    duration: '30 min',
    calories: 150,
    color: _turquoise,
    description: 'Intervalos de caminata rápida y normal para quemar calorías.',
    exercises: [
      const Exercise(name: 'Caminata suave', emoji: '🚶', durationSeconds: 120, description: 'Calentamiento a ritmo suave'),
      const Exercise(name: 'Caminata rápida', emoji: '🏃', durationSeconds: 90, description: 'Aumenta el ritmo'),
      const Exercise(name: 'Caminata normal', emoji: '🚶', durationSeconds: 60, description: 'Ritmo moderado'),
      const Exercise(name: 'Power walk', emoji: '⚡', durationSeconds: 90, description: 'Lo más rápido que puedas sin correr'),
      const Exercise(name: 'Caminata lateral', emoji: '↔️', durationSeconds: 60, description: 'Pasos laterales'),
      const Exercise(name: 'Power walk', emoji: '⚡', durationSeconds: 90, description: '¡A tope!'),
      const Exercise(name: 'Enfriamiento', emoji: '🧊', durationSeconds: 120, description: 'Reduce el ritmo gradualmente'),
    ],
  );

  static final danceCardio = Workout(
    id: 'dance_cardio',
    title: 'Dance Cardio',
    emoji: '💃',
    category: 'Cardio',
    level: 'Principiante',
    duration: '20 min',
    calories: 220,
    color: _pink,
    description: 'Baila y quema calorías con movimientos divertidos.',
    exercises: [
      const Exercise(name: 'Warm-up groove', emoji: '🎵', durationSeconds: 60, description: 'Mueve el cuerpo libremente'),
      const Exercise(name: 'Step touch', emoji: '👟', durationSeconds: 45, description: 'Paso lateral con brazos'),
      const Exercise(name: 'Grapevine', emoji: '🍇', durationSeconds: 45, description: 'Cruce lateral rítmico'),
      const Exercise(name: 'Body roll', emoji: '🌊', durationSeconds: 30, description: 'Ondulación de torso'),
      const Exercise(name: 'Salsa steps', emoji: '💃', durationSeconds: 60, description: 'Paso básico de salsa'),
      const Exercise(name: 'Jump & shake', emoji: '🤸', durationSeconds: 45, description: 'Salta y sacude brazos'),
      const Exercise(name: 'Reggaeton bounce', emoji: '🎶', durationSeconds: 60, description: 'Rebote con cadera'),
      const Exercise(name: 'Freestyle', emoji: '⭐', durationSeconds: 60, description: '¡Mueve como quieras!'),
      const Exercise(name: 'Cool down sway', emoji: '🌙', durationSeconds: 60, description: 'Balanceo suave'),
    ],
  );

  static final fuerzaSinEquipo = Workout(
    id: 'fuerza_sin_equipo',
    title: 'Fuerza sin Equipo',
    emoji: '🏋️',
    category: 'Fuerza',
    level: 'Intermedio',
    duration: '25 min',
    calories: 200,
    color: _indigo,
    description: 'Construye fuerza usando solo tu peso corporal.',
    exercises: [
      const Exercise(name: 'Push-ups', emoji: '💪', durationSeconds: 40, description: 'Flexiones clásicas'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 15, isRest: true),
      const Exercise(name: 'Sentadillas', emoji: '🦵', durationSeconds: 40, description: 'Profundas y controladas'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 15, isRest: true),
      const Exercise(name: 'Plancha', emoji: '🧱', durationSeconds: 45, description: 'Cuerpo recto como tabla'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 15, isRest: true),
      const Exercise(name: 'Lunges', emoji: '🦿', durationSeconds: 40, description: 'Zancadas alternas'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 15, isRest: true),
      const Exercise(name: 'Tricep dips', emoji: '💪', durationSeconds: 40, description: 'En silla o borde'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 15, isRest: true),
      const Exercise(name: 'Glute bridge', emoji: '🍑', durationSeconds: 40, description: 'Eleva la cadera al máximo'),
      const Exercise(name: 'Superman', emoji: '🦸', durationSeconds: 30, description: 'Brazos y piernas al cielo'),
    ],
  );

  static final gluteosYPiernas = Workout(
    id: 'gluteos_piernas',
    title: 'Glúteos & Piernas',
    emoji: '🏋️',
    category: 'Fuerza',
    level: 'Intermedio',
    duration: '20 min',
    calories: 180,
    color: _indigo,
    description: 'Enfocado en tren inferior para tonificar y fortalecer.',
    exercises: [
      const Exercise(name: 'Sentadilla sumo', emoji: '🦵', durationSeconds: 40, description: 'Piernas bien abiertas'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Glute kickback', emoji: '🍑', durationSeconds: 35, description: 'Patada trasera, aprieta glúteo'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Wall sit', emoji: '🧱', durationSeconds: 40, description: 'Sentada invisible contra la pared'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Clamshells', emoji: '🐚', durationSeconds: 35, description: 'Abre y cierra rodillas'),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Bulgarian split squat', emoji: '🦿', durationSeconds: 35, description: 'Pie trasero elevado'),
      const Exercise(name: 'Fire hydrants', emoji: '🔥', durationSeconds: 30, description: 'Rodilla al lateral como hidrante'),
    ],
  );

  static final stretchingNocturno = Workout(
    id: 'stretch_nocturno',
    title: 'Stretching Nocturno',
    emoji: '🧘',
    category: 'Yoga',
    level: 'Principiante',
    duration: '15 min',
    calories: 60,
    color: _lavender,
    description: 'Estiramientos suaves para relajarte antes de dormir.',
    exercises: [
      const Exercise(name: 'Cuello y hombros', emoji: '🦢', durationSeconds: 60, description: 'Círculos de cuello suaves'),
      const Exercise(name: 'Estiramiento de espalda', emoji: '🐱', durationSeconds: 60, description: 'Gato-vaca lento'),
      const Exercise(name: 'Piriforme', emoji: '🦵', durationSeconds: 60, description: 'Cruza tobillo sobre rodilla'),
      const Exercise(name: 'Isquiotibiales', emoji: '🦿', durationSeconds: 60, description: 'Pierna extendida al frente'),
      const Exercise(name: 'Torsión acostada', emoji: '🌀', durationSeconds: 60, description: 'Rodillas al lado, brazos abiertos'),
      const Exercise(name: 'Niño feliz', emoji: '👶', durationSeconds: 60, description: 'Agarra pies, mece suavemente'),
      const Exercise(name: 'Respiración final', emoji: '🌙', durationSeconds: 90, description: 'Inhala paz, exhala tensión'),
    ],
  );

  static final cardioBlast = Workout(
    id: 'cardio_blast',
    title: 'Cardio Blast',
    emoji: '🔥',
    category: 'HIIT',
    level: 'Avanzado',
    duration: '10 min',
    calories: 180,
    color: _coral,
    description: 'Cardio intenso en solo 10 minutos. ¡Sin excusas!',
    exercises: [
      const Exercise(name: 'Jumping Jacks', emoji: '⭐', durationSeconds: 30),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Burpees', emoji: '💪', durationSeconds: 30),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Speed skaters', emoji: '⛸️', durationSeconds: 30),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Tuck jumps', emoji: '🤸', durationSeconds: 20),
      const Exercise(name: 'Descanso', emoji: '😮‍💨', durationSeconds: 10, isRest: true),
      const Exercise(name: 'Mountain climbers', emoji: '🏔️', durationSeconds: 30),
      const Exercise(name: 'Sprint en sitio', emoji: '🏃', durationSeconds: 20, description: '¡DALO TODO!'),
    ],
  );
}
