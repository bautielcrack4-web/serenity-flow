import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as api_ui;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  int _poseDuration = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Text("Ajustes", style: Theme.of(context).textTheme.displayLarge),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildSectionPadding("SESIÓN"),
                    _buildPillSelector(),
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding("PREFERENCIAS"),
                    _buildSettingsCard([
                      _buildSwitchTile("Sonido", _soundEnabled, Icons.volume_up_rounded, (v) => setState(() => _soundEnabled = v)),
                      _buildDivider(),
                      _buildSwitchTile("Haptics", _vibrationEnabled, Icons.vibration_rounded, (v) => setState(() => _vibrationEnabled = v)),
                    ]),
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding("NOTIFICACIONES"),
                    _buildSettingsCard([
                      _buildSwitchTile("Recordatorios", _notificationsEnabled, Icons.notifications_active_rounded, (v) => setState(() => _notificationsEnabled = v)),
                    ]),
                    
                    const SizedBox(height: 48),
                    _buildResetButton(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionPadding(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gray.withOpacity(0.8), letterSpacing: 1.2)),
    );
  }

  Widget _buildPillSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: AppShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Duración por pose", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.dark)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDurationPill(20),
              _buildDurationPill(30),
              _buildDurationPill(45),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPill(int seconds) {
    final isSelected = _poseDuration == seconds;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _poseDuration = seconds);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85, height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.coral, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.coral.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Text("${seconds}s", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppColors.coral)),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: AppShadows.card),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, bool value, IconData icon, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lavender, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark))),
          CupertinoSwitch(
            value: value,
            activeColor: AppColors.coral,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, thickness: 1, indent: 60, endIndent: 20, color: AppColors.lightGray.withOpacity(0.5));

  Widget _buildResetButton() {
    return Center(
      child: TextButton(
        onPressed: () => HapticFeedback.heavyImpact(),
        child: Text("Reiniciar datos de práctica", style: TextStyle(color: AppColors.coral.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
