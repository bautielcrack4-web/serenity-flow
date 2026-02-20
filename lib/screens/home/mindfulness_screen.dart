import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

/// 🧘 Mindfulness Screen — Breathing, meditation, sleep routines
class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Mind', style: TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 4),
              Text('Tu espacio de paz interior', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
              const SizedBox(height: 24),

              // Featured: Quick breathing
              _BreathingFeatureCard(),
              const SizedBox(height: 24),

              // Categories
              const Text('Meditaciones', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              ..._meditations.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MeditationCard(data: m),
              )),

              const SizedBox(height: 20),
              const Text('Rutinas de sueño', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              ..._sleepRoutines.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MeditationCard(data: s),
              )),

              const SizedBox(height: 20),
              const Text('Manejo del hambre emocional', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              ..._emotionalEating.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MeditationCard(data: e),
              )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingFeatureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('🫁', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          const Text('Respiración rápida', style: TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Reduce el cortisol y la ansiedad en 3 minutos', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha: 0.8), height: 1.3), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStat('⏱️', '3 min'),
              const SizedBox(width: 24),
              _buildMiniStat('😌', 'Calma'),
              const SizedBox(width: 24),
              _buildMiniStat('🔄', '4-7-8'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF7C4DFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Comenzar ahora', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
      ],
    );
  }
}

class _MeditationData {
  final String emoji, title, subtitle, duration;
  final Color color;
  final bool isPremium;
  const _MeditationData({required this.emoji, required this.title, required this.subtitle, required this.duration, required this.color, this.isPremium = false});
}

const _meditations = [
  _MeditationData(emoji: '🧘', title: 'Meditación de la mañana', subtitle: 'Empieza tu día con intención clara', duration: '10 min', color: AppColors.lavender),
  _MeditationData(emoji: '🌊', title: 'Calma interior', subtitle: 'Relajación profunda para momentos de estrés', duration: '7 min', color: AppColors.turquoise),
  _MeditationData(emoji: '🌸', title: 'Body scan', subtitle: 'Conecta con tu cuerpo en 5 minutos', duration: '5 min', color: Color(0xFFE91E63)),
  _MeditationData(emoji: '🎯', title: 'Visualización de metas', subtitle: 'Imagina tu mejor versión', duration: '8 min', color: AppColors.coral, isPremium: true),
];

const _sleepRoutines = [
  _MeditationData(emoji: '🌙', title: 'Rutina antes de dormir', subtitle: 'Relaja cuerpo y mente para un sueño profundo', duration: '15 min', color: Color(0xFF5C6BC0)),
  _MeditationData(emoji: '🌿', title: 'Sonidos de la naturaleza', subtitle: 'Bosque, lluvia y olas del mar', duration: '30 min', color: Color(0xFF2E7D32)),
  _MeditationData(emoji: '✨', title: 'Escaneo corporal nocturno', subtitle: 'Suelta tensiones del día', duration: '10 min', color: AppColors.lavender, isPremium: true),
];

const _emotionalEating = [
  _MeditationData(emoji: '🤗', title: 'Pausa antes de comer', subtitle: '¿Tenés hambre real o emocional?', duration: '3 min', color: AppColors.coral),
  _MeditationData(emoji: '💭', title: 'Diario de emociones', subtitle: 'Conecta tus emociones con la alimentación', duration: '5 min', color: AppColors.lavender),
  _MeditationData(emoji: '🍫', title: 'Cuando querés algo dulce', subtitle: 'Maneja los antojos con consciencia', duration: '4 min', color: Color(0xFFFF8F00), isPremium: true),
];

class _MeditationCard extends StatelessWidget {
  final _MeditationData data;
  const _MeditationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(data.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(data.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark))),
                    if (data.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                        child: const Text('PRO', style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(data.subtitle, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.play_circle_filled_rounded, color: data.color, size: 36),
              const SizedBox(height: 2),
              Text(data.duration, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: data.color)),
            ],
          ),
        ],
      ),
    );
  }
}
