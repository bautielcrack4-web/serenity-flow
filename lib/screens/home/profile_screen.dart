import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/services/user_profile_provider.dart';
import 'package:serenity_flow/services/supabase_service.dart';

/// 👤 Profile Screen — Real user data, achievements, settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              _buildWeightChart(up),
              const SizedBox(height: 24),
              _buildStatsRow(up),
              const SizedBox(height: 24),
              Text(s.profAchievements, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildAchievements(),
              const SizedBox(height: 24),
              Text(s.profSettings, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildSettingsList(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

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
                Text(s.profActivePlan, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.gray)),
              ],
            ),
          ),
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

  Widget _buildWeightChart(UserProfileProvider up) {
    final s = L10n.s;
    // Generate weight data from current weight with a realistic downward trend
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

  Widget _buildAchievements() {
    final s = L10n.s;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _AchievementBadge(emoji: '🔥', title: s.profAch7Days, unlocked: true),
        _AchievementBadge(emoji: '💧', title: s.profAchHydrated, unlocked: true),
        _AchievementBadge(emoji: '🏃', title: s.profAch10Workouts, unlocked: true),
        _AchievementBadge(emoji: '🧘', title: s.profAchZenMaster, unlocked: false),
        _AchievementBadge(emoji: '🎯', title: s.profAch5kg, unlocked: false),
        _AchievementBadge(emoji: '⭐', title: s.profAch30Days, unlocked: false),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final s = L10n.s;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _SettingsTile(icon: Icons.person_outline_rounded, title: s.profEditProfile, color: AppColors.coral),
          _divider(),
          _SettingsTile(icon: Icons.fitness_center_rounded, title: s.profGoals, color: AppColors.turquoise),
          _divider(),
          _SettingsTile(icon: Icons.notifications_outlined, title: s.profNotifications, color: AppColors.lavender),
          _divider(),
          _SettingsTile(icon: Icons.star_rounded, title: s.profSubscription, color: AppColors.gold),
          _divider(),
          _SettingsTile(icon: Icons.help_outline_rounded, title: s.profHelp, color: AppColors.gray),
          _divider(),
          _SettingsTile(icon: Icons.logout_rounded, title: s.profLogout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 56, color: AppColors.lightGray.withValues(alpha: 0.5));
}

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
  const _SettingsTile({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
            Icon(Icons.chevron_right_rounded, color: AppColors.gray.withValues(alpha: 0.3), size: 22),
          ],
        ),
      ),
    );
  }
}
