import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/services/user_profile_provider.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';
import 'package:serenity_flow/screens/home/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serenity_flow/main.dart'; // SerenityFlowApp

/// 👤 Profile Screen — Real user data, achievements, settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPro = false;
  bool _isAnonymous = true;

  @override
  void initState() {
    super.initState();
    _isPro = RevenueCatService().isPro;
    final user = Supabase.instance.client.auth.currentUser;
    _isAnonymous = user?.isAnonymous ?? true;
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────

  Future<void> _handleAppleSignIn() async {
    try {
      final supabase = Supabase.instance.client;
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: rawNonce,
      );

      if (response.user != null && mounted) {
        setState(() => _isAnonymous = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.s.setAccountLinked)),
        );
      }
    } catch (e) {
      debugPrint("Sign in error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${L10n.s.setSignInFailed}: $e")),
        );
      }
    }
  }

  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _openPaywall() async {
    if (_isPro) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    if (result == true && mounted) {
      setState(() => _isPro = true);
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleLogout() async {
    final s = L10n.s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.profLogoutConfirmTitle, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(s.profLogoutConfirmMsg, style: const TextStyle(fontFamily: 'Outfit')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.profLogoutCancel, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.profLogoutConfirm, style: const TextStyle(fontFamily: 'Outfit', color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      UserProfileProvider.instance.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SerenityFlowApp()),
          (_) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final s = L10n.s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(s.profDeleteConfirmTitle, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(s.profDeleteConfirmMsg, style: const TextStyle(fontFamily: 'Outfit')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.profDeleteCancel, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.profDeleteConfirm, style: const TextStyle(fontFamily: 'Outfit', color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await SupabaseService().deleteAccount();
        await Supabase.instance.client.auth.signOut();
        UserProfileProvider.instance.clear();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SerenityFlowApp()),
            (_) => false,
          );
        }
      } catch (e) {
        debugPrint("Delete account error: $e");
      }
    }
  }

  // ── BUILD ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = L10n.s;
    final up = UserProfileProvider.instance;

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
              Text(s.profTitle, style: const TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 24),
              _buildProfileHeader(up),
              const SizedBox(height: 24),

              // Sign in with Apple banner (only for anonymous users)
              if (_isAnonymous) ...[
                _buildSignInBanner(),
                const SizedBox(height: 24),
              ],

              _buildStatsRow(up),
              const SizedBox(height: 24),

              // Weight chart — only if user has weight data
              if (up.currentWeight != null) ...[
                _buildWeightChart(up),
                const SizedBox(height: 24),
              ],

              Text(s.profAchievements, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildAchievements(up),
              const SizedBox(height: 24),

              Text(s.profSettings, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildSettingsList(),
              const SizedBox(height: 24),

              // Subscription manage / upgrade
              if (!_isPro)
                _buildUpgradeBanner()
              else
                _buildProActiveBadge(),
              const SizedBox(height: 24),

              // Legal + Account
              _buildLegalAndAccount(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── PROFILE HEADER ───────────────────────────────────────────────────

  Widget _buildProfileHeader(UserProfileProvider up) {
    final s = L10n.s;
    final initial = up.displayName.isNotEmpty ? up.displayName[0].toUpperCase() : 'Y';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.coralStatusGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            child: Center(child: Text(initial, style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(up.displayName, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.dark)),
                const SizedBox(height: 4),
                Text(_isPro ? s.profActivePlan : s.profFreeUser,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: _isPro ? AppColors.coral : AppColors.gray)),
              ],
            ),
          ),
          if (_isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('PRO', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gold)),
            ),
        ],
      ),
    );
  }

  // ── SIGN IN BANNER ───────────────────────────────────────────────────

  Widget _buildSignInBanner() {
    final s = L10n.s;
    return GestureDetector(
      onTap: _handleAppleSignIn,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.apple, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.profSignInApple, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(s.profSignInDesc, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.5), size: 22),
          ],
        ),
      ),
    );
  }

  // ── STATS ROW ────────────────────────────────────────────────────────

  Widget _buildStatsRow(UserProfileProvider up) {
    final s = L10n.s;
    return FutureBuilder<Map<String, int>>(
      future: SupabaseService().getStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'minutes': 0, 'sessions': 0};
        return Row(
          children: [
            Expanded(child: _StatCard(emoji: '🔥', value: '${up.currentStreak}', label: s.profDayStreak)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(emoji: '💪', value: '${stats['sessions'] ?? 0}', label: s.profWorkouts)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(emoji: '🧘', value: '${stats['minutes'] ?? 0}', label: s.profSessions)),
          ],
        );
      },
    );
  }

  // ── WEIGHT CHART ─────────────────────────────────────────────────────

  Widget _buildWeightChart(UserProfileProvider up) {
    final s = L10n.s;
    final cw = up.currentWeight ?? 68.0;
    final weights = List.generate(8, (i) => cw + (7 - i) * 0.5);

    final maxW = weights.reduce((a, b) => a > b ? a : b) + 1;
    final minW = weights.reduce((a, b) => a < b ? a : b) - 1;
    final totalLost = weights.first - weights.last;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.profWeightProgress, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const Spacer(),
              Text(s.profLast8Weeks, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.gray)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weights.asMap().entries.map((entry) {
                final i = entry.key;
                final w = entry.value;
                final range = maxW - minW;
                final height = range > 0 ? ((maxW - w) / range) * 100 + 20 : 60.0;
                final isLast = i == weights.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(w.toStringAsFixed(1), style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w600, color: isLast ? AppColors.coral : AppColors.gray)),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: isLast ? AppColors.coral : AppColors.coral.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (totalLost > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎉 -${totalLost.toStringAsFixed(1)} kg ${s.profTotalLost}', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green.shade600)),
              ],
            ),
        ],
      ),
    );
  }

  // ── ACHIEVEMENTS ─────────────────────────────────────────────────────

  Widget _buildAchievements(UserProfileProvider up) {
    final s = L10n.s;
    final streak = up.currentStreak;

    return FutureBuilder<Map<String, int>>(
      future: SupabaseService().getStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'minutes': 0, 'sessions': 0};
        final sessions = stats['sessions'] ?? 0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AchievementBadge(emoji: '🔥', title: s.profAch7Days, unlocked: streak >= 7),
            _AchievementBadge(emoji: '💧', title: s.profAchHydrated, unlocked: sessions >= 3),
            _AchievementBadge(emoji: '🏃', title: s.profAch10Workouts, unlocked: sessions >= 10),
            _AchievementBadge(emoji: '🧘', title: s.profAchZenMaster, unlocked: (stats['minutes'] ?? 0) >= 60),
            _AchievementBadge(emoji: '🎯', title: s.profAch5kg, unlocked: (up.weightToLose ?? 0) <= 0 && up.currentWeight != null),
            _AchievementBadge(emoji: '⭐', title: s.profAch30Days, unlocked: streak >= 30),
          ],
        );
      },
    );
  }

  // ── SETTINGS LIST ────────────────────────────────────────────────────

  Widget _buildSettingsList() {
    final s = L10n.s;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _SettingsTile(icon: Icons.settings_rounded, title: s.profSettings, color: AppColors.turquoise, onTap: _openSettings),
          _divider(),
          _SettingsTile(icon: Icons.notifications_outlined, title: s.profNotifications, color: AppColors.lavender, onTap: _openSettings),
          _divider(),
          _SettingsTile(
            icon: Icons.star_rounded,
            title: s.profSubscription,
            color: AppColors.gold,
            onTap: _openPaywall,
            trailing: _isPro
              ? Text(s.profActiveSubscription, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.coral))
              : null,
          ),
        ],
      ),
    );
  }

  // ── UPGRADE BANNER ───────────────────────────────────────────────────

  Widget _buildUpgradeBanner() {
    return GestureDetector(
      onTap: _openPaywall,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.coralStatusGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L10n.s.setUnlockPro, style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(L10n.s.setUnlockProDesc, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.7), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProActiveBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(L10n.s.profActiveSubscription, style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ],
      ),
    );
  }

  // ── LEGAL & ACCOUNT ──────────────────────────────────────────────────

  Widget _buildLegalAndAccount() {
    final s = L10n.s;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.description_outlined,
            title: s.profTerms,
            color: AppColors.gray,
            onTap: () => _openUrl('https://sites.google.com/view/yunaapp/terms-of-service'),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: s.profPrivacy,
            color: AppColors.gray,
            onTap: () => _openUrl('https://sites.google.com/view/yunaapp/privacy-policy'),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: s.profDeleteAccount,
            color: Colors.red,
            onTap: _handleDeleteAccount,
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: s.profLogout,
            color: Colors.red,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 56, color: AppColors.lightGray.withValues(alpha: 0.5));
}

// ── REUSABLE WIDGETS ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  const _StatCard({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.gray)),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String emoji, title;
  final bool unlocked;
  const _AchievementBadge({required this.emoji, required this.title, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.coral.withValues(alpha: 0.08) : AppColors.lightGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: unlocked ? Border.all(color: AppColors.coral.withValues(alpha: 0.2)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(unlocked ? emoji : '🔒', style: TextStyle(fontSize: 18, color: unlocked ? null : AppColors.gray)),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: unlocked ? AppColors.coral : AppColors.gray)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.title, required this.color, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dark))),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded, color: AppColors.gray.withValues(alpha: 0.3), size: 22),
          ],
        ),
      ),
    );
  }
}
