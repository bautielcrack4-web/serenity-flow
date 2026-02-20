import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:serenity_flow/screens/monetization/widgets/horizontal_benefit_row.dart';
import 'package:serenity_flow/screens/monetization/widgets/expandable_legal_section.dart';
import 'package:serenity_flow/services/haptic_service.dart';

class PaywallScreen extends StatefulWidget {
  final bool showCloseButton;
  final VoidCallback? onFinish;
  const PaywallScreen({super.key, this.showCloseButton = true, this.onFinish});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late ConfettiController _confettiController;
  List<Package> _packages = [];
  Package? _selectedPackage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadOfferings();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadOfferings() async {
    List<Package> packages = await RevenueCatService().getOfferings();
    
    // Web Fallback / Demo mode
    if (kIsWeb && packages.isEmpty) {
      debugPrint("Simulating demo packages for Web");
    }

    if (mounted) {
      setState(() {
        _packages = packages;
        
        if (packages.isNotEmpty) {
          _selectedPackage = packages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => packages.first,
          );
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePurchase() async {
    HapticPatterns.buttonPress();
    setState(() => _isLoading = true);
    
    bool success = false;

    if (kIsWeb) {
      // Direct simulation for Web demo
      await Future.delayed(const Duration(seconds: 2));
      success = true;
    } else {
      if (_selectedPackage == null) {
        setState(() => _isLoading = false);
        return;
      }
      success = await RevenueCatService().purchasePackage(_selectedPackage!);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _confettiController.play();
        HapticPatterns.success();
        
        // Sync with Supabase (will work local-only if guest)
        await SupabaseService().updateProStatus(true);
        
        // Delay to show celebration
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          if (widget.onFinish != null) {
            widget.onFinish!();
          } else {
            Navigator.pop(context, true);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Background Gradient (Subtle)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cream,
                    AppColors.turquoise.withOpacity(0.05),
                    AppColors.cream,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Compact Header
                  _buildHeader(),
                  
                  // Horizontal Benefits (Saves vertical space)
                  const SizedBox(height: 20),
                  const HorizontalBenefitRow(),
                  
                  const Spacer(),
                  
                  // Pricing Cards (The Core - Above Fold)
                  _buildSubscriptionOptions(),
                  
                  const Spacer(),
                  
                  // Action & Legal
                  _buildFooter(),
                ],
              ),
            ),
          ),
          
          if (widget.showCloseButton)
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.dark.withOpacity(0.4), size: 28),
                onPressed: () {
                  if (widget.onFinish != null) {
                    widget.onFinish!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            
          if (_isLoading && _packages.isEmpty)
             const Center(child: CircularProgressIndicator(color: AppColors.turquoise)),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.turquoise,
                AppColors.coral,
                AppColors.gold,
                AppColors.lavender,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "Unlock your body's\nfull potential.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.dark, height: 1.1),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              "Trusted by 10k+ Yogis",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.dark.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Feel great with only 5 minutes a day.\nStart your journey now.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.dark.withOpacity(0.5), fontWeight: FontWeight.w600, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions() {
    if (kIsWeb && _packages.isEmpty) {
      return _buildDemoOptions();
    }

    return Column(
      children: _packages.map((package) {
        bool isAnnual = package.packageType == PackageType.annual;
        return _buildPricingCard(
          package: package, 
          isAnnual: isAnnual, 
          isSelected: _selectedPackage == package
        );
      }).toList(),
    );
  }

  Widget _buildPricingCard({required Package package, required bool isAnnual, required bool isSelected}) {
    String mainPrice = package.storeProduct.priceString;
    String secondaryPrice = isAnnual 
        ? "${package.storeProduct.currencyCode} ${(package.storeProduct.price / 12).toStringAsFixed(2)} / mo" 
        : "";

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Tighter spacing
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.turquoise : Colors.transparent, 
            width: isSelected ? 3 : 0
          ),
          boxShadow: [
            if (isSelected) 
              BoxShadow(color: AppColors.turquoise.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // Radio Circle
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? AppColors.turquoise : AppColors.lightGray, width: 2),
                    color: isSelected ? AppColors.turquoise : Colors.transparent,
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnnual ? "Annual Plan" : "Monthly Plan",
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w700, 
                          color: AppColors.dark.withOpacity(0.8)
                        ),
                      ),
                      if (isAnnual && secondaryPrice.isNotEmpty)
                        Text(
                          "Calculated at $secondaryPrice",
                          style: TextStyle(
                            fontSize: 12, 
                            color: AppColors.dark.withOpacity(0.4),
                            fontWeight: FontWeight.w500
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Price Right Side
                Text(
                  mainPrice,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.dark),
                ),
              ],
            ),
            
            if (isAnnual)
              Positioned(
                top: -28,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.3), blurRadius: 6)],
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoOptions() {
    return Column(
      children: [
        _buildDemoCard("Annual Plan", "US\$ 14.99", "US\$ 1.24 / mo", true),
        _buildDemoCard("Monthly Plan", "US\$ 4.99", "", false),
      ],
    );
  }

  Widget _buildDemoCard(String title, String mainPrice, String secondaryPrice, bool isSelected) {
    // Reusing the same logic visually as _buildPricingCard structure
    // Simplified for demo
    return GestureDetector(
      onTap: () => setState(() {}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.turquoise : Colors.transparent, 
            width: isSelected ? 3 : 0
          ),
          boxShadow: [
             if (isSelected) 
              BoxShadow(color: AppColors.turquoise.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.turquoise : AppColors.lightGray, width: 2),
                color: isSelected ? AppColors.turquoise : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark.withOpacity(0.8))),
                  if (secondaryPrice.isNotEmpty)
                     Text("Calculated at $secondaryPrice", style: TextStyle(fontSize: 12, color: AppColors.dark.withOpacity(0.4), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
             Text(mainPrice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.dark)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPurchaseButton(),
        // New Expandable Legal Section
        ExpandableLegalSection(
          onRestore: () => RevenueCatService().restorePurchases(),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.turquoiseStatusGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.turquoise.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handlePurchase,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text("CONTINUE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),
      ),
    );
  }
}
