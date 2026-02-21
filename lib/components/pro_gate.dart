import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';

/// 🔒 ProGate — Soft-lock overlay for free users.
///
/// Shows a blurred preview of gated content with a "PRO" badge.
/// Free users see the content blurred; tapping shows a paywall sheet.
/// Pro users see the content normally.
///
/// Usage:
///   ProGate(child: SomeProWidget())
///   showProGate(context)  // shows paywall bottom sheet directly

class ProGate extends StatelessWidget {
  final Widget child;
  final String? featureLabel;

  const ProGate({super.key, required this.child, this.featureLabel});

  @override
  Widget build(BuildContext context) {
    final isPro = RevenueCatService().isPro;
    if (isPro) return child;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showProGate(context);
      },
      child: Stack(
        children: [
          // Blurred content preview
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AbsorbPointer(child: child),
            ),
          ),

          // PRO badge overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon with glow
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFD700),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (featureLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      featureLabel!,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Show the ProGate bottom sheet — a mini paywall that converts.
/// Returns true if the user purchased, false otherwise.
Future<bool> showProGate(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ProGateSheet(),
  );
  return result ?? false;
}

class _ProGateSheet extends StatelessWidget {
  const _ProGateSheet();

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Lock icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),

          Text(
            s.proGateTitle,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.proGateSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),

          // Feature bullets
          _buildBullet('✨', 'Unlimited workouts & routines'),
          _buildBullet('🍽️', 'Full nutrition tracking'),
          _buildBullet('🧘', 'All meditation sessions'),
          _buildBullet('📊', 'Advanced analytics & insights'),

          const SizedBox(height: 24),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, false);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
                // If purchased, caller should refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.coral.withValues(alpha: 0.3),
              ),
              child: Text(
                s.proGateUnlock,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dismiss
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Not now',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🏷️ Free Sessions Banner — Shows remaining free sessions
/// Place at the top of gated screens.
class FreeSessionsBanner extends StatelessWidget {
  final int used;
  final int total;

  const FreeSessionsBanner({super.key, required this.used, this.total = 3});

  @override
  Widget build(BuildContext context) {
    final isPro = RevenueCatService().isPro;
    if (isPro) return const SizedBox.shrink();

    final remaining = (total - used).clamp(0, total);
    final s = L10n.s;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.1),
            AppColors.coral.withValues(alpha: 0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.dark),
                children: [
                  TextSpan(
                    text: '$used ',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coral),
                  ),
                  TextSpan(text: s.proGateSessionsUsed),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: remaining > 0 ? AppColors.turquoise.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$remaining ${s.proGateFreeSessionsBanner}',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: remaining > 0 ? AppColors.turquoise : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
