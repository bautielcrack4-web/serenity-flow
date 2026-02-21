import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';
import 'package:serenity_flow/services/notification_service.dart';

/// PHASE 6: Commitment + Social Proof (5 pages + email)
/// Purpose: Cement commitment before the paywall
List<Widget> buildPhase6Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
) {
  final s = L10n.s;
  return [
    // PAGE 37: Testimonials
    _TestimonialsPage(onContinue: next),

    // PAGE 38: Commitment
    _CommitmentPage(name: data.displayName ?? '', onContinue: next),

    // PAGE 39: Info break — urgency
    InfoBreakCard(
      emoji: '⏰',
      title: s.p6UrgencyTitle,
      fact: s.p6UrgencyFact,
      onContinue: next,
    ),

    // PAGE 40: Notifications permission warm-up
    _NotificationsPage(onSubmit: (v) => answer('notifications_accepted', v)),

    // PAGE 41: Personalized urgency with session timer
    _PersonalizedUrgencyPage(data: data, onContinue: next),

    // PAGE 42: Email capture (before paywall)
    _EmailCapturePage(
      name: data.displayName ?? '',
      onSubmit: (email) {
        if (email != null && email.isNotEmpty) {
          answer('email', email);
        }
        next();
      },
    ),
  ];
}

/// Testimonials with staggered animated star ratings
class _TestimonialsPage extends StatelessWidget {
  final VoidCallback onContinue;
  const _TestimonialsPage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    final testimonials = [
      (s.p6Testimonial1Name, 5, s.p6Testimonial1Text, '🇪🇸'),
      (s.p6Testimonial2Name, 5, s.p6Testimonial2Text, '🇺🇸'),
      (s.p6Testimonial3Name, 5, s.p6Testimonial3Text, '🇨🇦'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Text(L10n.s.p6TestimonialsTitle,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text(L10n.s.p6TestimonialsSubtitle,
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
            child: PremiumCTAButton(text: L10n.s.continueBtn, onPressed: onContinue, showGlow: false),
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
                    BreathingAura(color: AppColors.lavender, size: 220),
                    Image.asset(
                      'assets/images/onboarding/onboard_01_saludo.png',
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                   name.isNotEmpty
                      ? L10n.s.p6CommitmentReadyNamed.replaceFirst('{name}', name)
                      : L10n.s.p6CommitmentReady,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.dark),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 800),
                child: Text(
                   L10n.s.p6CommitmentSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.dark.withValues(alpha: 0.6), height: 1.5),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: PremiumCTAButton(text: L10n.s.p6CommitmentBtn, onPressed: onContinue),
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
class _NotificationsPage extends StatefulWidget {
  final Function(bool) onSubmit;
  const _NotificationsPage({required this.onSubmit});

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  bool _loading = false;

  Future<void> _onAccept() async {
    setState(() => _loading = true);
    final granted = await NotificationService().requestPermission();
    if (granted) {
      await NotificationService().scheduleAll();
    }
    if (mounted) {
      setState(() => _loading = false);
      widget.onSubmit(granted);
    }
  }

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
                  child: const Text('🔔', style: TextStyle(fontSize: 40)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Text(L10n.s.p6NotificationsTitle, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 600),
            child: Text(
              L10n.s.p6NotificationsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6), height: 1.4),
            ),
          ),
          const Spacer(flex: 3),
          FadeSlideIn(
            delay: const Duration(milliseconds: 800),
            child: _loading
                ? const CircularProgressIndicator(color: AppColors.coral)
                : PremiumCTAButton(text: L10n.s.p6NotificationsBtn, onPressed: _onAccept),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 900),
            child: TextButton(
              onPressed: () => widget.onSubmit(false),
              child: Text(L10n.s.p6NotificationsSkip, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.4))),
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
                   name.isNotEmpty ? L10n.s.p6PlanReadyNamed.replaceFirst('{name}', name) : L10n.s.p6PlanReadyTitle,
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
                      Text(L10n.s.p6PlanGeneratedMin.replaceFirst('{min}', '$_elapsedMinutes'),
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
                      Text(L10n.s.p6ActiveUsersLabel,
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
                   L10n.s.p6PlanSummary
                      .replaceFirst('{weeks}', '$weeks'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6), height: 1.5),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: PremiumCTAButton(text: L10n.s.p6ActivatePlanBtn, onPressed: widget.onContinue),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}

/// 📧 Email Capture — Lead generation before paywall
/// Inspired by Noom, BetterMe, Calm pre-paywall email screens
class _EmailCapturePage extends StatefulWidget {
  final String name;
  final Function(String?) onSubmit;
  const _EmailCapturePage({required this.name, required this.onSubmit});

  @override
  State<_EmailCapturePage> createState() => _EmailCapturePageState();
}

class _EmailCapturePageState extends State<_EmailCapturePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);
  }

  void _onSubmit() {
    if (!_isValid) return;
    setState(() => _loading = true);
    widget.onSubmit(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Stack(
          children: [
            const Positioned.fill(
              child: FloatingParticles(count: 12, color: AppColors.lavender, maxSize: 5),
            ),
            Column(
              children: [
                const Spacer(flex: 2),
                // Animated envelope icon
                ScaleReveal(
                  delay: const Duration(milliseconds: 200),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                    BreathingAura(color: AppColors.lavender, size: 200),
                    Image.asset(
                      'assets/images/onboarding/illust_email.png',
                      width: 180,
                      height: 180,
                    ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    isEs ? '¿Dónde te enviamos\ntu plan?' : 'Where should we send\nyour plan?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Subtitle
                FadeSlideIn(
                  delay: const Duration(milliseconds: 550),
                  child: Text(
                    widget.name.isNotEmpty
                        ? (isEs
                            ? '${widget.name}, guarda tu progreso y recibe consejos personalizados'
                            : '${widget.name}, save your progress and receive personalized tips')
                        : (isEs
                            ? 'Guarda tu progreso y recibe consejos personalizados'
                            : 'Save your progress and receive personalized tips'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      color: AppColors.dark.withValues(alpha: 0.55),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                // Email Input
                FadeSlideIn(
                  delay: const Duration(milliseconds: 700),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (_isValid ? AppColors.coral : AppColors.lavender).withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onChanged: (v) => setState(() => _isValid = _validateEmail(v.trim())),
                      onSubmitted: (_) { if (_isValid) _onSubmit(); },
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                      decoration: InputDecoration(
                        hintText: isEs ? 'tu@email.com' : 'your@email.com',
                        hintStyle: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 17,
                          color: AppColors.dark.withValues(alpha: 0.3),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            Icons.email_rounded,
                            color: _isValid ? AppColors.coral : AppColors.dark.withValues(alpha: 0.3),
                            size: 22,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: _isValid
                            ? const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.check_circle_rounded, color: AppColors.coral, size: 22),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: AppColors.lavender.withValues(alpha: 0.3), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: _isValid ? AppColors.coral : AppColors.lavender,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Privacy assurance
                FadeSlideIn(
                  delay: const Duration(milliseconds: 850),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 13, color: AppColors.dark.withValues(alpha: 0.35)),
                      const SizedBox(width: 6),
                      Text(
                        isEs ? 'Sin spam. Solo tu bienestar.' : 'No spam. Only your wellness.',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: AppColors.dark.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // CTA
                FadeSlideIn(
                  delay: const Duration(milliseconds: 950),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isValid ? 1.0 : 0.5,
                    child: _loading
                        ? const CircularProgressIndicator(color: AppColors.coral)
                        : PremiumCTAButton(
                            text: isEs ? 'Continuar' : 'Continue',
                            onPressed: _isValid ? _onSubmit : () {},
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Skip
                FadeSlideIn(
                  delay: const Duration(milliseconds: 1050),
                  child: TextButton(
                    onPressed: () => widget.onSubmit(null),
                    child: Text(
                      isEs ? 'Omitir por ahora' : 'Skip for now',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        color: AppColors.dark.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
