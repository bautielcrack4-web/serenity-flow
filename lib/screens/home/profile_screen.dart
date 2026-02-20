import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

/// 👤 Profile Screen — Weight chart, achievements, settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text('Perfil', style: TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 24),

              // Profile header
              _buildProfileHeader(),
              const SizedBox(height: 24),

              // Weight chart placeholder
              _buildWeightChart(),
              const SizedBox(height: 24),

              // Stats row
              _buildStatsRow(),
              const SizedBox(height: 24),

              // Achievements
              const Text('Logros', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildAchievements(),
              const SizedBox(height: 24),

              // Settings list
              const Text('Configuración', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildSettingsList(context),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            child: const Center(child: Text('Y', style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yuna User', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.dark)),
                SizedBox(height: 4),
                Text('Plan activo · Semana 3', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.gray)),
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

  Widget _buildWeightChart() {
    // Simplified weight chart with visual bars
    final weights = [72.0, 71.5, 71.0, 70.5, 70.0, 69.2, 68.5, 68.0];
    final maxW = 73.0;
    final minW = 67.0;

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
          const Row(
            children: [
              Text('Progreso de peso', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              Spacer(),
              Text('Últimas 8 semanas', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.gray)),
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
                final height = ((maxW - w) / (maxW - minW)) * 100 + 20;
                final isLast = i == weights.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${w.toStringAsFixed(1)}', style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w600, color: isLast ? AppColors.coral : AppColors.gray)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎉 -4.0 kg en total', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(emoji: '🔥', value: '28', label: 'Día streak')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(emoji: '💪', value: '15', label: 'Workouts')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(emoji: '🧘', value: '22', label: 'Sesiones')),
      ],
    );
  }

  Widget _buildAchievements() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _AchievementBadge(emoji: '🔥', title: '7 días seguidos', unlocked: true),
        _AchievementBadge(emoji: '💧', title: 'Hidratada', unlocked: true),
        _AchievementBadge(emoji: '🏃', title: '10 workouts', unlocked: true),
        _AchievementBadge(emoji: '🧘', title: 'Zen master', unlocked: false),
        _AchievementBadge(emoji: '🎯', title: '-5 kg', unlocked: false),
        _AchievementBadge(emoji: '⭐', title: '30 días', unlocked: false),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _SettingsTile(icon: Icons.person_outline_rounded, title: 'Editar perfil', color: AppColors.coral),
          _divider(),
          _SettingsTile(icon: Icons.fitness_center_rounded, title: 'Objetivos', color: AppColors.turquoise),
          _divider(),
          _SettingsTile(icon: Icons.notifications_outlined, title: 'Notificaciones', color: AppColors.lavender),
          _divider(),
          _SettingsTile(icon: Icons.star_rounded, title: 'Suscripción', color: AppColors.gold),
          _divider(),
          _SettingsTile(icon: Icons.help_outline_rounded, title: 'Ayuda', color: AppColors.gray),
          _divider(),
          _SettingsTile(icon: Icons.logout_rounded, title: 'Cerrar sesión', color: Colors.red),
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
