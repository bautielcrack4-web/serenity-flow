import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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
  List<Map<String, dynamic>> _weightLogs = [];
  bool _isLoadingWeights = true;

  @override
  void initState() {
    super.initState();
    _isPro = RevenueCatService().isPro;
    final user = Supabase.instance.client.auth.currentUser;
    _isAnonymous = user?.isAnonymous ?? true;
    _loadWeightLogs();
  }

  Future<void> _loadWeightLogs() async {
    final logs = await SupabaseService().getWeightLogs(limit: 8);
    if (mounted) setState(() { _weightLogs = logs; _isLoadingWeights = false; });
  }

  void _showLogWeightDialog() {
    final controller = TextEditingController(
      text: UserProfileProvider.instance.currentWeight?.toStringAsFixed(1) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Registrar peso', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            suffixText: 'kg',
            hintText: '65.0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: AppColors.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text.replaceAll(',', '.'));
              if (weight == null || weight < 20 || weight > 300) return;
              Navigator.pop(ctx);
              final ok = await SupabaseService().logWeight(weight);
              if (ok && mounted) {
                HapticFeedback.mediumImpact();
                UserProfileProvider.instance.setCurrentWeight(weight);
                _loadWeightLogs();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
              GestureDetector(
                onTap: _showLogWeightDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: AppColors.coral),
                      const SizedBox(width: 4),
                      Text('Registrar', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingWeights)
            const SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator(color: AppColors.coral, strokeWidth: 2)),
            )
          else if (_weightLogs.isEmpty)
            // Empty state — inviting CTA
            GestureDetector(
              onTap: _showLogWeightDialog,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [AppColors.coral.withValues(alpha: 0.04), AppColors.lavender.withValues(alpha: 0.06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.coral.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monitor_weight_outlined, size: 36, color: AppColors.coral.withValues(alpha: 0.5)),
                      const SizedBox(height: 10),
                      Text('Registrá tu peso para ver tu progreso',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark.withValues(alpha: 0.5))),
                      const SizedBox(height: 4),
                      Text('Tocá para empezar ✨',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.coral)),
                    ],
                  ),
                ),
              ),
            )
          else
            // Real data — premium line chart
            _buildRealWeightChart(),
        ],
      ),
    );
  }

  Widget _buildRealWeightChart() {
    // Reverse so oldest is first (left) → newest last (right)
    final sorted = _weightLogs.reversed.toList();
    final weights = sorted.map((l) => (l['weight'] as num).toDouble()).toList();
    final maxW = weights.reduce(math.max) + 0.5;
    final minW = weights.reduce(math.min) - 0.5;
    final totalChange = weights.first - weights.last;
    final targetW = UserProfileProvider.instance.targetWeight;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _WeightLineChartPainter(
              weights: weights,
              maxW: maxW,
              minW: minW,
              targetWeight: targetW,
            ),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 12),
        if (totalChange.abs() > 0.1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                totalChange > 0
                    ? '📉 -${totalChange.toStringAsFixed(1)} kg perdidos'
                    : '📈 +${totalChange.abs().toStringAsFixed(1)} kg ganados',
                style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700,
                  color: totalChange > 0 ? Colors.green.shade600 : AppColors.coral,
                ),
              ),
            ],
          ),
      ],
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

// ── PREMIUM LINE CHART PAINTER ────────────────────────────────────────

class _WeightLineChartPainter extends CustomPainter {
  final List<double> weights;
  final double maxW, minW;
  final double? targetWeight;

  _WeightLineChartPainter({
    required this.weights,
    required this.maxW,
    required this.minW,
    this.targetWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final padding = 36.0;
    final graphW = w - padding - 8;
    final graphH = h - 24;
    final range = maxW - minW;

    // Y-axis labels
    final labelStyle = TextStyle(fontFamily: 'Outfit', fontSize: 10, color: const Color(0xFF999999));
    _drawText(canvas, maxW.toStringAsFixed(0), Offset(0, 2), labelStyle);
    _drawText(canvas, minW.toStringAsFixed(0), Offset(0, graphH - 4), labelStyle);

    // Subtle grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5;
    for (var i = 0; i < 4; i++) {
      final y = 8.0 + graphH * i / 3;
      canvas.drawLine(Offset(padding, y), Offset(w, y), gridPaint);
    }

    // Target weight dashed line
    if (targetWeight != null && targetWeight! >= minW && targetWeight! <= maxW) {
      final targetY = 8.0 + graphH * (1 - (targetWeight! - minW) / range);
      final dashPaint = Paint()
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      for (var x = padding; x < w; x += 8) {
        canvas.drawLine(Offset(x, targetY), Offset(x + 4, targetY), dashPaint);
      }
      _drawText(canvas, '🎯', Offset(padding - 18, targetY - 8), const TextStyle(fontSize: 12));
    }

    // Build path
    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < weights.length; i++) {
      final t = weights.length == 1 ? 0.5 : i / (weights.length - 1);
      final x = padding + graphW * t;
      final y = 8.0 + graphH * (1 - (weights[i] - minW) / range);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Smooth curve
        final prev = points[i - 1];
        final cpX = (prev.dx + x) / 2;
        path.cubicTo(cpX, prev.dy, cpX, y, x, y);
      }
    }

    // Gradient fill below line
    if (points.length > 1) {
      final fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, graphH + 8);
      fillPath.lineTo(points.first.dx, graphH + 8);
      fillPath.close();
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x30FF6B6B), Color(0x05FF6B6B)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(fillPath, fillPaint);
    }

    // Glow line
    canvas.drawPath(path, Paint()
      ..color = AppColors.coral.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Main gradient line
    canvas.drawPath(path, Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFFD700)],
      ).createShader(Rect.fromLTWH(padding, 0, graphW, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Data points
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final isLast = i == points.length - 1;
      // Outer ring
      canvas.drawCircle(p, isLast ? 6 : 4, Paint()..color = Colors.white);
      canvas.drawCircle(p, isLast ? 5 : 3, Paint()..color = AppColors.coral);
      if (isLast) {
        canvas.drawCircle(p, 3, Paint()..color = Colors.white);
      }
      // Weight label
      final label = weights[i].toStringAsFixed(1);
      _drawText(canvas, label, Offset(p.dx - 14, p.dy - 18),
          TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w600,
              color: isLast ? AppColors.coral : const Color(0xFF999999)));
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WeightLineChartPainter old) =>
      old.weights != weights || old.maxW != maxW || old.minW != minW;
}
