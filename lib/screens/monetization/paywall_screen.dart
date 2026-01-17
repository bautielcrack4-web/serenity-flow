import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:serenity_flow/services/haptic_service.dart';

class PaywallScreen extends StatefulWidget {
  final bool showCloseButton;
  final VoidCallback? onFinish;
  const PaywallScreen({super.key, this.showCloseButton = true, this.onFinish});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<Package> _packages = [];
  Package? _selectedPackage;
  bool _isLoading = true;

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
        // Default to annual if available
        _selectedPackage = packages.firstWhere(
          (p) => p.packageType == PackageType.annual,
          orElse: () => packages.isNotEmpty ? packages.first : packages.first, // fallback
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;
    
    HapticPatterns.buttonPress();
    setState(() => _isLoading = true);
    
    bool success = await RevenueCatService().purchasePackage(_selectedPackage!);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Sync with Supabase
        await SupabaseService().updateProStatus(true);
        
        if (widget.onFinish != null) {
          widget.onFinish!();
        } else {
          Navigator.pop(context);
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
          // Background Aura
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.turquoise.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeroCarousel(),
                        const SizedBox(height: 32),
                        _buildBenefitList(),
                        const SizedBox(height: 40),
                        _buildSubscriptionOptions(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Column(
        children: [
          const Text(
            "Unlock your body's full potential.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.dark, height: 1.1),
          ),
          const SizedBox(height: 16),
          Text(
            "Only US\$ 1.24 per month billed annually.\nThat's 50x cheaper than a personal trainer.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.dark.withOpacity(0.5), fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleIllustration(0.8),
          _buildCircleIllustration(1.0),
          _buildCircleIllustration(0.8),
        ],
      ),
    );
  }

  Widget _buildCircleIllustration(double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.turquoiseStatusGradient,
          boxShadow: [
            BoxShadow(color: AppColors.turquoise.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildBenefitList() {
    return Column(
      children: [
        const Text(
          "Feel great with only 5 minutes a day.",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.dark),
        ),
        const SizedBox(height: 24),
        _buildBenefitItem("Improve flexibility"),
        _buildBenefitItem("Reduce pain"),
        _buildBenefitItem("Prevent injuries"),
        _buildBenefitItem("Improve sleep"),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: AppColors.turquoise, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return Column(
      children: _packages.map((package) {
        bool isAnnual = package.packageType == PackageType.annual;
        bool isSelected = _selectedPackage == package;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedPackage = package),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.turquoise : Colors.transparent, 
                width: 2.5
              ),
              boxShadow: [
                if (isSelected) 
                  BoxShadow(color: AppColors.turquoise.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAnnual ? "Annual" : "Monthly",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.dark),
                        ),
                        if (isAnnual) ...[
                          const SizedBox(height: 4),
                          Text(
                            "US\$ 29.99  US\$ 14.99",
                            style: TextStyle(
                              fontSize: 14, 
                              color: AppColors.dark.withOpacity(0.4),
                              decoration: TextDecoration.lineThrough
                            ),
                          ),
                        ],
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isAnnual ? "US\$ 1.24 / mo" : "USD 4.99 / mo",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.dark),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.dark.withOpacity(0.2)),
                      ],
                    ),
                  ],
                ),
                if (isAnnual)
                  Positioned(
                    top: -35,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                      ),
                      child: const Text(
                        "Most Popular",
                        style: TextStyle(color: AppColors.turquoise, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => RevenueCatService().restorePurchases(),
            child: Text(
              "Restore purchases",
              style: TextStyle(color: AppColors.dark.withOpacity(0.5), fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.turquoiseStatusGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.turquoise.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handlePurchase,
          borderRadius: BorderRadius.circular(20),
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
