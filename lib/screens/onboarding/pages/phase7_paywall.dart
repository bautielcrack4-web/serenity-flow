import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';

/// PHASE 7: Paywall (5 pages)
/// Purpose: Convert → Subscribe with deeply personalized messaging + real RevenueCat purchases
List<Widget> buildPhase7Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
  VoidCallback completeOnboarding,
) {
  return [
    // PAGE 42: Personalized paywall with real RevenueCat
    _PersonalizedPaywall(
      data: data,
      onPurchaseSuccess: () {
        answer('selected_plan', 'pro');
        completeOnboarding();
      },
      onSkip: next,
    ),

    // PAGE 43: Guarantee
    _GuaranteePage(onContinue: next),

    // PAGE 44: Price comparison
    _PriceComparisonPage(data: data, onContinue: next),

    // PAGE 45: Final push
    _FinalPushPage(
      data: data,
      onStart: () {
        // Show paywall again as a bottom sheet or navigate back
        completeOnboarding();
      },
    ),

    // PAGE 46: Exit intent
    _ExitIntentPage(
      data: data,
      onAccept: completeOnboarding,
      onDecline: completeOnboarding,
    ),
  ];
}

// ---- Internal widgets ----

/// 💰 Personalized Paywall — Real RevenueCat integration
class _PersonalizedPaywall extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onPurchaseSuccess;
  final VoidCallback onSkip;
  const _PersonalizedPaywall({required this.data, required this.onPurchaseSuccess, required this.onSkip});

  @override
  State<_PersonalizedPaywall> createState() => _PersonalizedPaywallState();
}

class _PersonalizedPaywallState extends State<_PersonalizedPaywall> {
  List<Package> _packages = [];
  Package? _selectedPackage;
  bool _isLoadingPackages = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final packages = await RevenueCatService().getOfferings();
    if (mounted) {
      setState(() {
        _packages = packages;
        if (packages.isNotEmpty) {
          // Default to annual (best value)
          _selectedPackage = packages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => packages.first,
          );
        }
        _isLoadingPackages = false;
      });
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null && !kIsWeb) return;
    HapticFeedback.mediumImpact();
    setState(() => _isPurchasing = true);

    bool success = false;
    if (kIsWeb) {
      // Demo mode for web
      await Future.delayed(const Duration(seconds: 2));
      success = true;
    } else {
      success = await RevenueCatService().purchasePackage(_selectedPackage!);
    }

    if (mounted) {
      setState(() => _isPurchasing = false);
      if (success) {
        HapticFeedback.heavyImpact();
        await SupabaseService().updateProStatus(true);
        widget.onPurchaseSuccess();
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    await RevenueCatService().restorePurchases();
    final isPro = RevenueCatService().isPro;
    if (mounted) {
      setState(() => _isPurchasing = false);
      if (isPro) {
        await SupabaseService().updateProStatus(true);
        widget.onPurchaseSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron compras anteriores')),
        );
      }
    }
  }

  List<String> _buildPlanFeatures() {
    final features = <String>[];
    if ((widget.data.stressLevel ?? 5) >= 6) features.add('Anti-estrés');
    if (widget.data.emotionalEating != null && widget.data.emotionalEating != 'nunca') features.add('Control emocional');
    if (widget.data.dietaryRestrictions.isNotEmpty) features.add('Recetas adaptadas');
    features.add('Yoga + Meditación');
    if (features.length < 4) features.add('Tracking inteligente');
    return features.take(4).toList();
  }

  String _getPriceString(Package? pkg) {
    if (pkg == null) return '';
    return pkg.storeProduct.priceString;
  }

  String _getMonthlyPrice(Package pkg) {
    if (pkg.packageType == PackageType.annual) {
      final monthly = pkg.storeProduct.price / 12;
      return '${pkg.storeProduct.currencyCode} ${monthly.toStringAsFixed(2)}';
    }
    if (pkg.packageType == PackageType.threeMonth) {
      final monthly = pkg.storeProduct.price / 3;
      return '${pkg.storeProduct.currencyCode} ${monthly.toStringAsFixed(2)}';
    }
    return pkg.storeProduct.priceString;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data.displayName ?? '';
    final weeks = ((widget.data.currentWeight ?? 70) - (widget.data.targetWeight ?? 60)) > 0
        ? (((widget.data.currentWeight ?? 70) - (widget.data.targetWeight ?? 60)) / 0.75).ceil()
        : 8;
    final features = _buildPlanFeatures();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Personalized header
              FadeSlideIn(
                child: Text(
                  name.isNotEmpty ? '$name, tu plan de $weeks semanas está listo' : 'Tu plan de $weeks semanas está listo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.dark, height: 1.2),
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  '${widget.data.currentWeight?.toStringAsFixed(0) ?? "--"} kg → ${widget.data.targetWeight?.toStringAsFixed(0) ?? "--"} kg',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.coral),
                ),
              ),
              const SizedBox(height: 14),
              // Plan mini-summary chips
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: features.map((f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.coral.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.coral),
                        const SizedBox(width: 4),
                        Text(f, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 22),

              // Loading state or real packages
              if (_isLoadingPackages)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: AppColors.coral),
                )
              else if (_packages.isNotEmpty)
                ..._buildRealPackages()
              else if (kIsWeb)
                ..._buildDemoPackages()
              else
                ..._buildFallbackPackages(),

              const SizedBox(height: 24),

              // CTA
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: PulseGlow(
                  child: SizedBox(
                    width: double.infinity, height: 58,
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.coral.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Activar mi plan',
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 700),
                child: Text('7 días de prueba gratis · Cancelá cuando quieras',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.4))),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  child: Text('Restaurar compra', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.3))),
                  onPressed: _handleRestore,
                ),
                Text(' · ', style: TextStyle(color: AppColors.dark.withValues(alpha: 0.2))),
                TextButton(child: Text('Términos', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.3))), onPressed: () {}),
                Text(' · ', style: TextStyle(color: AppColors.dark.withValues(alpha: 0.2))),
                TextButton(child: Text('Privacidad', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.3))), onPressed: () {}),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Skip button (X) top-right — required by App Store
        Positioned(
          top: 8,
          right: 8,
          child: FadeSlideIn(
            delay: const Duration(seconds: 3), // Delay to reduce skip rate
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.dark.withValues(alpha: 0.25), size: 22),
              onPressed: widget.onSkip,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRealPackages() {
    final widgets = <Widget>[];
    // Sort: annual first, then by price descending
    final sorted = List<Package>.from(_packages);
    sorted.sort((a, b) {
      const order = {PackageType.annual: 0, PackageType.threeMonth: 1, PackageType.monthly: 2};
      return (order[a.packageType] ?? 3).compareTo(order[b.packageType] ?? 3);
    });

    for (var i = 0; i < sorted.length; i++) {
      final pkg = sorted[i];
      final isAnnual = pkg.packageType == PackageType.annual;
      final isSelected = _selectedPackage == pkg;
      final monthlyPrice = _getMonthlyPrice(pkg);
      final title = isAnnual ? 'Plan Anual' : (pkg.packageType == PackageType.threeMonth ? 'Plan Trimestral' : 'Plan Mensual');

      widgets.add(
        FadeSlideIn(
          delay: Duration(milliseconds: 300 + i * 100),
          child: isSelected && isAnnual
              ? GlowingBorder(
                  borderRadius: 24,
                  borderWidth: 2.5,
                  colors: const [AppColors.coral, Color(0xFFFFD700), AppColors.lavender, AppColors.turquoise],
                  child: _PlanCardContent(
                    title: title,
                    price: isAnnual ? monthlyPrice : _getPriceString(pkg),
                    period: '/mes',
                    totalPrice: isAnnual ? '${_getPriceString(pkg)}/año' : null,
                    badge: isAnnual ? 'MEJOR VALOR 🔥' : null,
                    savings: isAnnual ? 'Ahorrás 72%' : null,
                    isSelected: true,
                    onTap: () => setState(() => _selectedPackage = pkg),
                  ),
                )
              : _PlanCard(
                  title: title,
                  price: isAnnual ? monthlyPrice : _getPriceString(pkg),
                  period: '/mes',
                  totalPrice: isAnnual ? '${_getPriceString(pkg)}/año' : (pkg.packageType == PackageType.threeMonth ? '${_getPriceString(pkg)}/trimestre' : null),
                  badge: isAnnual ? 'MEJOR VALOR 🔥' : null,
                  savings: isAnnual ? 'Ahorrás 72%' : null,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedPackage = pkg),
                ),
        ),
      );
      if (i < sorted.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }

  List<Widget> _buildDemoPackages() {
    return _buildFallbackPackages();
  }

  List<Widget> _buildFallbackPackages() {
    // Hardcoded fallback when packages can't be loaded (offline, web, etc.)
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 300),
        child: GlowingBorder(
          borderRadius: 24,
          borderWidth: 2.5,
          colors: const [AppColors.coral, Color(0xFFFFD700), AppColors.lavender, AppColors.turquoise],
          child: _PlanCardContent(
            title: 'Plan Anual',
            price: '\$4.17',
            period: '/mes',
            totalPrice: '\$49.99/año',
            badge: 'MEJOR VALOR 🔥',
            savings: 'Ahorrás 72%',
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
      const SizedBox(height: 12),
      FadeSlideIn(
        delay: const Duration(milliseconds: 400),
        child: _PlanCard(
          title: 'Plan Mensual',
          price: '\$14.99',
          period: '/mes',
          isSelected: false,
          onTap: () {},
        ),
      ),
    ];
  }
}

/// Plan card content (for inside GlowingBorder)
class _PlanCardContent extends StatelessWidget {
  final String title, price, period;
  final String? totalPrice, badge, savings;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCardContent({
    required this.title, required this.price, required this.period,
    this.totalPrice, this.badge, this.savings,
    required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.coralStatusGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              const Spacer(),
              Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.coral : Colors.grey.withValues(alpha: 0.3), size: 26),
            ]),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price, style: const TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.coral)),
                Text(period, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
                if (totalPrice != null) ...[
                  const Spacer(),
                  Text(totalPrice!, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.4))),
                ],
              ],
            ),
            if (savings != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(savings!, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standard plan card
class _PlanCard extends StatelessWidget {
  final String title, price, period;
  final String? totalPrice, badge, savings;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title, required this.price, required this.period,
    this.totalPrice, this.badge, this.savings,
    required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.coral : Colors.grey.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.15), blurRadius: 16)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.coralStatusGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              const Spacer(),
              Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.coral : Colors.grey.withValues(alpha: 0.3), size: 26),
            ]),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price, style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.coral : AppColors.dark)),
                Text(period, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5))),
                if (totalPrice != null) ...[
                  const Spacer(),
                  Text(totalPrice!, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.4))),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Guarantee page with shield reveal
class _GuaranteePage extends StatelessWidget {
  final VoidCallback onContinue;
  const _GuaranteePage({required this.onContinue});

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
                BreathingAura(color: const Color(0xFF4CAF50), size: 180),
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                  ),
                  child: const Center(child: Text('🛡️', style: TextStyle(fontSize: 52))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: const Text('Garantía sin riesgo', textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 700),
            child: Text(
              '7 días gratis. Cancelá cuando quieras.\nSin compromiso, sin preguntas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.dark.withValues(alpha: 0.6), height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          ...[
            ('✅', 'Prueba gratis de 7 días'),
            ('✅', 'Cancelación en 1 tap'),
            ('✅', 'Sin cargos ocultos'),
          ].asMap().entries.map((e) {
            return FadeSlideIn(
              delay: Duration(milliseconds: 900 + e.key * 150),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(e.value.$1, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Text(e.value.$2, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.dark)),
                  ],
                ),
              ),
            );
          }),
          const Spacer(flex: 3),
          FadeSlideIn(
            delay: const Duration(milliseconds: 1300),
            child: PremiumCTAButton(text: 'Continuar', onPressed: onContinue, showGlow: false),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Price comparison with personalized Yuna row
class _PriceComparisonPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onContinue;
  const _PriceComparisonPage({required this.data, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🧘', 'App de meditación', '\$12.99/mes'),
      ('🍽️', 'Nutricionista', '\$5,000/mes'),
      ('💪', 'App de fitness', '\$14.99/mes'),
      ('📊', 'Coach personal', '\$8,000/mes'),
    ];

    final weeks = ((data.currentWeight ?? 70) - (data.targetWeight ?? 60)) > 0
        ? (((data.currentWeight ?? 70) - (data.targetWeight ?? 60)) / 0.75).ceil()
        : 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(
            child: const Text('Todo-en-uno por menos',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ),
          const SizedBox(height: 24),
          ...items.asMap().entries.map((e) {
            final item = e.value;
            return FadeSlideIn(
              delay: Duration(milliseconds: 200 + e.key * 150),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Text(item.$1, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(child: Text(item.$2, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.dark))),
                      Text(item.$3, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.dark.withValues(alpha: 0.4), decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Yuna row — personalized
          FadeSlideIn(
            delay: const Duration(milliseconds: 800),
            child: GlowingBorder(
              colors: const [AppColors.coral, Color(0xFFFFD700), AppColors.lavender],
              borderRadius: 18,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('🌸', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        const Expanded(child: Text('Yuna — Tu plan completo', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.coral))),
                        const Text('\$4.17/mes', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.coral)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$weeks semanas personalizadas para vos',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 1000),
            child: PremiumCTAButton(text: 'Activar mi plan', onPressed: onContinue),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Final push with confetti and personalized messaging
class _FinalPushPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onStart;
  const _FinalPushPage({required this.data, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final name = data.displayName ?? '';
    final target = data.targetWeight?.toStringAsFixed(0) ?? '--';

    return Stack(
      children: [
        const Positioned.fill(
          child: FloatingParticles(count: 20, color: AppColors.coral, maxSize: 6),
        ),
        const Positioned.fill(
          child: ConfettiOverlay(count: 35),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ScaleReveal(
                delay: const Duration(milliseconds: 300),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BreathingAura(color: AppColors.coral, size: 200),
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.coralStatusGradient,
                        boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Center(child: Text('🚀', style: TextStyle(fontSize: 56))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  name.isNotEmpty ? '¡$name, tu plan está listo!' : '¡Tu plan está listo!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.dark),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 800),
                child: Text(
                  'Empezá tu prueba gratuita de 7 días\ny llegá a $target kg con Yuna.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.dark.withValues(alpha: 0.6), height: 1.5),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: PremiumCTAButton(text: 'Activar mi plan 🎉', onPressed: onStart),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

/// Exit intent with personalized discount offer
class _ExitIntentPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _ExitIntentPage({required this.data, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final name = data.displayName ?? '';
    final weeks = ((data.currentWeight ?? 70) - (data.targetWeight ?? 60)) > 0
        ? (((data.currentWeight ?? 70) - (data.targetWeight ?? 60)) / 0.75).ceil()
        : 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ScaleReveal(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.15), blurRadius: 30)],
              ),
              child: Column(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    name.isNotEmpty ? '¡Esperá, $name!' : '¡Esperá!',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark),
                  ),
                  const SizedBox(height: 8),
                  Text('Tu plan de $weeks semanas tiene un descuento exclusivo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.coral)),
                  const SizedBox(height: 16),
                  // Discount badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.coralStatusGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 16)],
                    ),
                    child: const Text('50% OFF', style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  Text('\$2.08/mes en vez de \$4.17',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ),
          const Spacer(flex: 3),
          FadeSlideIn(
            delay: const Duration(milliseconds: 600),
            child: PulseGlow(
              maxBlur: 24,
              child: SizedBox(
                width: double.infinity, height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    onAccept();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: AppColors.coral.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('¡Quiero esta oferta!',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onDecline,
            child: Text('No, gracias',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.35))),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
