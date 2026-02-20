import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 6: Commitment + Social Proof (5 pages)
/// Purpose: Cement commitment before the paywall
List<Widget> buildPhase6Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  return [
    // PAGE 37: Testimonials
    _TestimonialsPage(onContinue: next),

    // PAGE 38: Commitment
    _CommitmentPage(name: data.displayName ?? '', onContinue: next),

    // PAGE 39: Info break — urgency
    InfoBreakCard(
      emoji: '⏰',
      title: 'Las primeras 48 horas son clave',
      fact: 'Los estudios muestran que empezar HOY aumenta 4x la probabilidad de alcanzar tu objetivo. Tu plan está listo para comenzar ahora mismo.',
      onContinue: next,
    ),

    // PAGE 40: Notifications permission warm-up
    _NotificationsPage(onSubmit: (v) => answer('notifications_accepted', v)),

    // PAGE 41: Personalized urgency with session timer
    _PersonalizedUrgencyPage(data: data, onContinue: next),
  ];
}

/// Testimonials with staggered animated star ratings
class _TestimonialsPage extends StatelessWidget {
  final VoidCallback onContinue;
  const _TestimonialsPage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      ('María, 28', 5, 'Perdí 12kg en 3 meses. La meditación me ayudó a dejar de comer por ansiedad.', '🇦🇷'),
      ('Valentina, 35', 5, 'Por fin no siento culpa al comer. Yuna cambió mi relación con la comida.', '🇲🇽'),
      ('Camila, 24', 5, 'Las rutinas de respiración me cambiaron la vida. Bajé 8kg sin pasar hambre.', '🇨🇴'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: const Text('Historias reales',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text('Mujeres como vos que lograron su objetivo',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: testimonials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final t = testimonials[i];
                return FadeSlideIn(
                  delay: Duration(milliseconds: 200 + i * 200),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(t.$4, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text(t.$1, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                        const Spacer(),
                        Row(
                          children: List.generate(t.$2, (starIdx) {
                            return ScaleReveal(
                              delay: Duration(milliseconds: 400 + i * 200 + starIdx * 80),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                              ),
                            );
                          }),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Text('"${t.$3}"',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.dark.withValues(alpha: 0.7), fontStyle: FontStyle.italic, height: 1.4)),
                    ]),
                  ),
                );
              },
            ),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 800),
            child: PremiumCTAButton(text: 'Continuar', onPressed: onContinue, showGlow: false),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Commitment page with floating particles and pulsing butterfly
class _CommitmentPage extends StatelessWidget {
  final String name;
  final VoidCallback onContinue;
  const _CommitmentPage({required this.name, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        children: [
          const Positioned.fill(
            child: FloatingParticles(count: 15, color: AppColors.lavender, maxSize: 6),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ScaleReveal(
                delay: const Duration(milliseconds: 300),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BreathingAura(color: AppColors.lavender, size: 180),
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lavender.withValues(alpha: 0.1),
                        boxShadow: [BoxShadow(color: AppColors.lavender.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5)],
                      ),
                      child: const Center(child: Text('🦋', style: TextStyle(fontSize: 52))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  name.isNotEmpty ? '¿Estás lista, $name?' : '¿Estás lista?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.dark),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 800),
                child: Text(
                  'Tu transformación empieza hoy.\nYuna va a acompañarte cada día.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.dark.withValues(alpha: 0.6), height: 1.5),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: PremiumCTAButton(text: '¡Estoy lista! 🎉', onPressed: onContinue),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}

/// Notifications with premium styling
class _NotificationsPage extends StatelessWidget {
  final Function(bool) onSubmit;
  const _NotificationsPage({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ScaleReveal(
            delay: const Duration(milliseconds: 200),
            child: Stack(
              alignment: Alignment.center,
              children: [
                BreathingAura(color: AppColors.coral, size: 140),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coral.withValues(alpha: 0.08),
                  ),
                  child: const Center(child: Text('🔔', style: TextStyle(fontSize: 40))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: const Text('Recordatorios diarios', textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 600),
            child: Text(
              'Las usuarias con recordatorios activados tienen 3x más éxito en alcanzar su objetivo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6), height: 1.4),
            ),
          ),
          const Spacer(flex: 3),
          FadeSlideIn(
            delay: const Duration(milliseconds: 800),
            child: PremiumCTAButton(text: 'Activar recordatorios', onPressed: () => onSubmit(true)),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 900),
            child: TextButton(
              onPressed: () => onSubmit(false),
              child: Text('No, gracias', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.4))),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ⏰ Personalized Urgency — Live session timer + dynamic stats
class _PersonalizedUrgencyPage extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _PersonalizedUrgencyPage({required this.data, required this.onContinue});

  @override
  State<_PersonalizedUrgencyPage> createState() => _PersonalizedUrgencyPageState();
}

class _PersonalizedUrgencyPageState extends State<_PersonalizedUrgencyPage> {
  late Timer _timer;
  int _elapsedMinutes = 0;
  int _activeUsers = 1247;

  @override
  void initState() {
    super.initState();
    // Calculate estimated elapsed time (assume ~2 min per page, user is on page ~41)
    _elapsedMinutes = ((DateTime.now().minute) % 20).clamp(5, 18);
    // Slowly increment active users for realism
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _activeUsers += 1 + (DateTime.now().second % 3);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data.displayName ?? '';
    final weeks = ((widget.data.currentWeight ?? 70) - (widget.data.targetWeight ?? 60)) > 0
        ? (((widget.data.currentWeight ?? 70) - (widget.data.targetWeight ?? 60)) / 0.75).ceil()
        : 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          const Positioned.fill(
            child: FloatingParticles(count: 15, color: Color(0xFFFF5722), maxSize: 6),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ScaleReveal(
                delay: const Duration(milliseconds: 200),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BreathingAura(color: AppColors.coral, size: 200),
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.coralStatusGradient,
                        boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                      ),
                      child: const Center(child: Text('🔥', style: TextStyle(fontSize: 56))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  name.isNotEmpty ? '$name, tu plan está listo' : 'Tu plan está listo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark),
                ),
              ),
              const SizedBox(height: 16),
              // Session time badge
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerGradient(
                        child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.coral),
                      ),
                      const SizedBox(width: 8),
                      Text('Plan generado hace $_elapsedMinutes min',
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.coral)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Active users counter
              FadeSlideIn(
                delay: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PulseGlow(
                        glowColor: const Color(0xFF4CAF50),
                        child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4CAF50)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$_activeUsers ', style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.coral)),
                      Text('mujeres similares empezaron hoy',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Personalized summary
              FadeSlideIn(
                delay: const Duration(milliseconds: 800),
                child: Text(
                  'Plan de $weeks semanas optimizado para vos.\nSi no empezás ahora, los resultados se retrasan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6), height: 1.5),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: PremiumCTAButton(text: 'Activar mi plan ahora', onPressed: widget.onContinue),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
