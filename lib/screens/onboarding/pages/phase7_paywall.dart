import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_animations.dart';
import 'package:url_launcher/url_launcher.dart';

/// PHASE 7: Paywall (1 page — handles welcome + exit discount internally)
/// Purpose: Convert → Subscribe with deeply personalized messaging + real RevenueCat purchases
List<Widget> buildPhase7Pages(
  OnboardingData data,
  VoidCallback next,
  Function(String, dynamic) answer,
  VoidCallback completeOnboarding,
) {
  return [
    // Single paywall page — handles:
    // ✅ Purchase success → welcome overlay → home
    // ❌ Skip (X) → exit discount bottom sheet → purchase or free
    _PersonalizedPaywall(
      data: data,
      onPurchaseSuccess: () {
        answer('selected_plan', 'pro');
        completeOnboarding();
      },
      onSkipFree: completeOnboarding,
    ),
  ];
}

// ---- Internal widgets ----

/// 💰 Personalized Paywall — Real RevenueCat integration
class _PersonalizedPaywall extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onPurchaseSuccess;
  final VoidCallback onSkipFree;
  const _PersonalizedPaywall({required this.data, required this.onPurchaseSuccess, required this.onSkipFree});

  @override
  State<_PersonalizedPaywall> createState() => _PersonalizedPaywallState();
}

class _PersonalizedPaywallState extends State<_PersonalizedPaywall> {
  List<Package> _packages = [];
  Package? _selectedPackage;
  Package? _monthlyPackage; // Stored for exit discount offer
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
      // Store monthly package separately for exit discount
      _monthlyPackage = packages.where((p) =>
        p.packageType == PackageType.monthly
      ).firstOrNull;

      // Filter out monthly — only keep weekly + annual on main paywall
      final filtered = packages.where((p) =>
        p.packageType == PackageType.annual ||
        p.packageType == PackageType.weekly
      ).toList();
      setState(() {
        _packages = filtered;
        if (filtered.isNotEmpty) {
          // Default to annual (best value / anchor)
          _selectedPackage = filtered.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => filtered.first,
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
        // Show welcome overlay then navigate home
        _showWelcomeOverlay();
      }
    }
  }

  void _showWelcomeOverlay() {
    final name = widget.data.displayName ?? '';
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, a1, a2, child) {
        return FadeTransition(opacity: a1, child: ScaleTransition(scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack), child: child));
      },
      pageBuilder: (ctx, a1, a2) {
        return _WelcomeOverlayContent(
          name: name,
          onComplete: () {
            Navigator.of(ctx).pop();
            widget.onPurchaseSuccess();
          },
        );
      },
    );
  }

  void _showExitDiscountSheet() {
    final name = widget.data.displayName ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExitDiscountSheet(
        name: name,
        monthlyPackage: _monthlyPackage,
        onPurchaseSuccess: () {
          Navigator.of(ctx).pop();
          _showWelcomeOverlay();
        },
        onDecline: () {
          Navigator.of(ctx).pop();
          widget.onSkipFree();
        },
      ),
    );
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    await RevenueCatService().restorePurchases();
    final isPro = RevenueCatService().isPro;
    if (mounted) {
      setState(() => _isPurchasing = false);
      if (isPro) {
        await SupabaseService().updateProStatus(true);
        _showWelcomeOverlay();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous purchases found')),
        );
      }
    }
  }

  List<String> _buildPlanFeatures() {
    final features = <String>[];
    if ((widget.data.stressLevel ?? 5) >= 6) features.add(L10n.s.p7FeatureAntiStress);
    if (widget.data.emotionalEating != null && widget.data.emotionalEating != 'nunca') features.add(L10n.s.p7FeatureEmotionalControl);
    if (widget.data.dietaryRestrictions.isNotEmpty) features.add(L10n.s.p7FeatureAdaptedRecipes);
    features.add(L10n.s.p7FeatureYogaMeditation);
    if (features.length < 4) features.add(L10n.s.p7FeatureSmartTracking);
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

  String _getWeeklyPrice(Package pkg) {
    if (pkg.packageType == PackageType.annual) {
      final weekly = pkg.storeProduct.price / 52;
      return '${pkg.storeProduct.currencyCode} ${weekly.toStringAsFixed(2)}';
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
                  name.isNotEmpty ? L10n.s.p7PlanReadyNamed.replaceAll('{name}', name).replaceAll('{weeks}', '$weeks') : L10n.s.p7PlanReady.replaceAll('{weeks}', '$weeks'),
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
              // Social proof trust badge
              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (i) => Icon(
                        Icons.star_rounded, size: 16,
                        color: i < 5 ? const Color(0xFFFFB800) : Colors.grey.shade300,
                      )),
                      const SizedBox(width: 6),
                      Text('4.8', style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.dark)),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 16, color: Colors.grey.withValues(alpha: 0.15)),
                      const SizedBox(width: 8),
                      Text(L10n.s.p7SocialProof,
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.dark.withValues(alpha: 0.5))),
                    ],
                  ),
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
                          : Text(L10n.s.p7ActivateBtn,
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 700),
                child: Text('Cancelá cuando quieras',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark.withValues(alpha: 0.4))),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  onPressed: _handleRestore,
                  child: Text(L10n.s.p7RestoreBtn, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.3))),
                ),
                Text(' · ', style: TextStyle(color: AppColors.dark.withValues(alpha: 0.2))),
                TextButton(child: Text(L10n.s.p7TermsBtn, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.3))), onPressed: () => launchUrl(Uri.parse('https://sites.google.com/view/yunaapp/terms-of-service'))),
                Text(' · ', style: TextStyle(color: AppColors.dark.withValues(alpha: 0.2))),
                TextButton(child: Text(L10n.s.p7PrivacyBtn, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.3))), onPressed: () => launchUrl(Uri.parse('https://sites.google.com/view/yunaapp/privacy-policy'))),
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
              onPressed: _showExitDiscountSheet,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRealPackages() {
    final widgets = <Widget>[];
    // Sort: annual first (hero), then weekly (decoy)
    final sorted = List<Package>.from(_packages);
    sorted.sort((a, b) {
      const order = {PackageType.annual: 0, PackageType.weekly: 1, PackageType.threeMonth: 2, PackageType.monthly: 3};
      return (order[a.packageType] ?? 4).compareTo(order[b.packageType] ?? 4);
    });

    for (var i = 0; i < sorted.length; i++) {
      final pkg = sorted[i];
      final isAnnual = pkg.packageType == PackageType.annual;
      final isWeekly = pkg.packageType == PackageType.weekly;
      final isSelected = _selectedPackage == pkg;
      final monthlyPrice = _getMonthlyPrice(pkg);
      final weeklyPrice = isAnnual ? _getWeeklyPrice(pkg) : null;
      final title = isAnnual
          ? L10n.s.p7PlanAnnual
          : isWeekly
              ? L10n.s.p7PlanWeekly
              : (pkg.packageType == PackageType.threeMonth ? L10n.s.p7PlanQuarterly : L10n.s.p7PlanMonthly);

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
                    price: isAnnual ? weeklyPrice ?? monthlyPrice : _getPriceString(pkg),
                    period: isAnnual ? L10n.s.p7PerWeek : (isWeekly ? L10n.s.p7PerWeek : L10n.s.p7PerMonth),
                    totalPrice: isAnnual ? '${_getPriceString(pkg)}${L10n.s.p7PerYear}' : null,
                    badge: isAnnual ? L10n.s.p7BestValue : null,
                    savings: isAnnual ? L10n.s.p7Save86 : null,
                    introTag: isAnnual ? L10n.s.p7IntroPrice : null,
                    isSelected: true,
                    onTap: () => setState(() => _selectedPackage = pkg),
                  ),
                )
              : _PlanCard(
                  title: title,
                  price: isWeekly ? _getPriceString(pkg) : (isAnnual ? weeklyPrice ?? monthlyPrice : _getPriceString(pkg)),
                  period: isWeekly ? L10n.s.p7PerWeek : (isAnnual ? L10n.s.p7PerWeek : L10n.s.p7PerMonth),
                  totalPrice: isAnnual ? '${_getPriceString(pkg)}${L10n.s.p7PerYear}' : null,
                  badge: isAnnual ? L10n.s.p7BestValue : null,
                  savings: isAnnual ? L10n.s.p7Save86 : null,
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
    // Hardcoded fallback: Weekly + Annual (no monthly)
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 300),
        child: GlowingBorder(
          borderRadius: 24,
          borderWidth: 2.5,
          colors: const [AppColors.coral, Color(0xFFFFD700), AppColors.lavender, AppColors.turquoise],
          child: _PlanCardContent(
            title: L10n.s.p7PlanAnnual,
            price: '\$0.96',
            period: L10n.s.p7PerWeek,
            totalPrice: '\$49.99${L10n.s.p7PerYear}',
            badge: L10n.s.p7BestValue,
            savings: L10n.s.p7Save86,
            introTag: L10n.s.p7IntroPrice,
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
      const SizedBox(height: 12),
      FadeSlideIn(
        delay: const Duration(milliseconds: 400),
        child: _PlanCard(
          title: L10n.s.p7PlanWeekly,
          price: '\$6.99',
          period: L10n.s.p7PerWeek,
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
  final String? totalPrice, badge, savings, introTag;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCardContent({
    required this.title, required this.price, required this.period,
    this.totalPrice, this.badge, this.savings, this.introTag,
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
              if (introTag != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.3)),
                  ),
                  child: Text(introTag!, style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFE65100))),
                ),
              ],
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(savings!, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))),
                  ),
                ],
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

/// ✅ Welcome overlay shown after successful purchase
class _WelcomeOverlayContent extends StatefulWidget {
  final String name;
  final VoidCallback onComplete;
  const _WelcomeOverlayContent({required this.name, required this.onComplete});

  @override
  State<_WelcomeOverlayContent> createState() => _WelcomeOverlayContentState();
}

class _WelcomeOverlayContentState extends State<_WelcomeOverlayContent>
    with TickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final AnimationController _textCtrl;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // Sequence: check → text → auto-dismiss
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5F5), Color(0xFFFFFBF0), AppColors.cream],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ConfettiOverlay(count: 50),
            ),
            const Positioned.fill(
              child: FloatingParticles(count: 25, color: AppColors.coral, maxSize: 5),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated checkmark in glowing circle
                  ScaleTransition(
                    scale: CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.coralStatusGradient,
                        boxShadow: [
                          BoxShadow(color: AppColors.coral.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Title
                  FadeTransition(
                    opacity: _textCtrl,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                          .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)),
                      child: Column(
                        children: [
                          Text(
                            widget.name.isNotEmpty
                                ? '${L10n.s.p7WelcomeTitle.replaceAll('!', '')}, ${widget.name}!'
                                : L10n.s.p7WelcomeTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            L10n.s.p7WelcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 17,
                              color: AppColors.dark.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ❌ Exit discount bottom sheet with exclusive $4.99 monthly offer
class _ExitDiscountSheet extends StatefulWidget {
  final String name;
  final Package? monthlyPackage;
  final VoidCallback onPurchaseSuccess;
  final VoidCallback onDecline;
  const _ExitDiscountSheet({
    required this.name,
    required this.monthlyPackage,
    required this.onPurchaseSuccess,
    required this.onDecline,
  });

  @override
  State<_ExitDiscountSheet> createState() => _ExitDiscountSheetState();
}

class _ExitDiscountSheetState extends State<_ExitDiscountSheet> {
  bool _isPurchasing = false;

  Future<void> _handleDiscountPurchase() async {
    if (widget.monthlyPackage == null && !kIsWeb) {
      // No monthly package available — just skip
      widget.onDecline();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isPurchasing = true);

    bool success = false;
    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 2));
      success = true;
    } else {
      success = await RevenueCatService().purchasePackage(widget.monthlyPackage!);
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

  @override
  Widget build(BuildContext context) {
    final priceStr = widget.monthlyPackage?.storeProduct.priceString ?? '\$4.99';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.dark.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Text(
            widget.name.isNotEmpty
                ? L10n.s.p7ExitWaitNamed.replaceAll('{name}', widget.name)
                : L10n.s.p7ExitWait,
            style: const TextStyle(
              fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),

          // Exclusive tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.coralStatusGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              L10n.s.p7ExitExclusive,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),

          // Offer card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.coralStatusGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(L10n.s.p7ExitMonthlyOffer,
                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(L10n.s.p7ExitOriginalPrice,
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.dark.withValues(alpha: 0.4), decoration: TextDecoration.lineThrough)),
                              const SizedBox(width: 8),
                              Text('$priceStr${L10n.s.p7PerMonth}',
                                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.coral)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CTA
          PulseGlow(
            maxBlur: 20,
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isPurchasing ? null : _handleDiscountPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.coral.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isPurchasing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text(L10n.s.p7ExitWantOffer,
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Decline
          TextButton(
            onPressed: _isPurchasing ? null : widget.onDecline,
            child: Text(L10n.s.p7ExitDecline,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.35))),
          ),
        ],
      ),
    );
  }
}

