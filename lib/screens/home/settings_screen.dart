import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/main.dart'; // To restart app
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';
import 'package:serenity_flow/services/sound_service.dart';
import 'package:serenity_flow/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  bool _streakNotif = true;
  bool _waterNotif = true;
  bool _weeklyNotif = true;
  TimeOfDay _practiceTime = const TimeOfDay(hour: 8, minute: 0);
  int _poseDuration = 30; // Restoring this missing variable

  bool _isAnonymous = false;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _isPro = RevenueCatService().isPro;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _soundEnabled = SoundService().enabled;
    _notificationsEnabled = await NotificationService().isEnabled;
    _streakNotif = await NotificationService().isStreakEnabled;
    _waterNotif = await NotificationService().isWaterEnabled;
    _weeklyNotif = await NotificationService().isWeeklyEnabled;
    _practiceTime = await NotificationService().practiceTime;
    if (mounted) setState(() {});
  }

  void _checkUserStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _isAnonymous = user?.isAnonymous ?? true;
    });
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Generate a secure nonce for the Apple ID Token
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      
      // Link/Sign in with the Apple credential
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: rawNonce,
      );
      
      if (response.user != null) {
        // Update local state
        setState(() {
          _isAnonymous = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10n.s.setAccountLinked)),
          );
        }
      }
    } catch (e) {
      debugPrint("Sign in error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${L10n.s.setSignInFailed}: ${e.toString()}")),
        );
      }
    }
  }

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
                child: Text(L10n.s.setTitle, style: Theme.of(context).textTheme.displayLarge),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Sign in with Apple Banner (Only for anonymous users)
                    if (_isAnonymous) ...[
                      GestureDetector(
                        onTap: _handleAppleSignIn,
                        child: _buildSignInBanner(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Upgrade to Pro Banner
                    if (!_isPro) ...[
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaywallScreen()),
                          );
                          if (result == true) {
                            setState(() {
                              _isPro = true;
                            });
                          }
                        },
                        child: _buildUpgradeBanner(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    _buildSectionPadding(L10n.s.setSession),
                    _buildPillSelector(),
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding(L10n.s.setPreferences),
                    _buildSettingsCard([
                      _buildSwitchTile(L10n.s.setSound, _soundEnabled, Icons.volume_up_rounded, (v) {
                        setState(() => _soundEnabled = v);
                        SoundService().setEnabled(v);
                      }),
                      _buildDivider(),
                      _buildSwitchTile(L10n.s.setHaptics, _vibrationEnabled, Icons.vibration_rounded, (v) => setState(() => _vibrationEnabled = v)),
                    ]),
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding(L10n.s.setNotificationsSection),
                    _buildSettingsCard([
                      _buildSwitchTile(L10n.s.setReminders, _notificationsEnabled, Icons.notifications_active_rounded, (v) {
                        setState(() => _notificationsEnabled = v);
                        NotificationService().setEnabled(v);
                      }),
                      if (_notificationsEnabled) ...[
                        _buildDivider(),
                        _buildTimeTile(),
                        _buildDivider(),
                        _buildSwitchTile('🔥 Streak', _streakNotif, Icons.local_fire_department_rounded, (v) {
                          setState(() => _streakNotif = v);
                          NotificationService().setStreakEnabled(v);
                        }),
                        _buildDivider(),
                        _buildSwitchTile('💧 Agua', _waterNotif, Icons.water_drop_rounded, (v) {
                          setState(() => _waterNotif = v);
                          NotificationService().setWaterEnabled(v);
                        }),
                        _buildDivider(),
                        _buildSwitchTile('📊 Semanal', _weeklyNotif, Icons.bar_chart_rounded, (v) {
                          setState(() => _weeklyNotif = v);
                          NotificationService().setWeeklyEnabled(v);
                        }),
                      ],
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding(L10n.s.setLegal),
                    _buildSettingsCard([
                      _buildActionTile(L10n.s.setPrivacyPolicy, Icons.privacy_tip_outlined, () {
                         _launchUrl("https://sites.google.com/view/yunaapp/privacy-policy");
                      }),
                      _buildDivider(),
                      _buildActionTile(L10n.s.setTermsOfService, Icons.description_outlined, () {
                         _launchUrl("https://sites.google.com/view/yunaapp/terms-of-service");
                      }),
                    ]),

                    const SizedBox(height: 32),
                    _buildResetButton(),
                    const SizedBox(height: 20),
                    _buildDeleteAccountButton(),
                    const SizedBox(height: 60),
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
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gray.withValues(alpha: 0.8), letterSpacing: 1.2)),
    );
  }

  Widget _buildPillSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: AppShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s.setPoseDuration, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.dark)),
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
          boxShadow: isSelected ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
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
            activeTrackColor: AppColors.coral,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile() {
    final timeStr = _practiceTime.format(context);
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _practiceTime,
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.coral),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _practiceTime = picked);
          NotificationService().setPracticeTime(picked);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: AppColors.lavender, size: 24),
            const SizedBox(width: 16),
            const Expanded(child: Text('⏰ Hora de práctica', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(timeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.coral)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, thickness: 1, indent: 60, endIndent: 20, color: AppColors.lightGray.withValues(alpha: 0.5));

  Widget _buildResetButton() {
    return Center(
      child: TextButton(
        onPressed: () => HapticFeedback.heavyImpact(),
        child: Text(L10n.s.setResetData, style: TextStyle(color: AppColors.coral.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.lavender, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark))),
            Icon(Icons.chevron_right_rounded, color: AppColors.gray.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Confirm Dialog
          showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(L10n.s.setDeleteConfirmTitle),
              content: Text(L10n.s.setDeleteConfirmMessage),
              actions: [
                CupertinoDialogAction(
                  child: Text(L10n.s.setDeleteCancel),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(L10n.s.setDeleteConfirm),
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog
                    await SupabaseService().deleteAccount();
                    if (!context.mounted) return;
                    // Restart App
                     Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const SerenityFlowApp()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
        child: Text(
          L10n.s.setDeleteAccount,
          style: TextStyle(color: Colors.red.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSignInBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.turquoise.withValues(alpha: 0.1), AppColors.coral.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.turquoise.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
            child: const Icon(Icons.cloud_upload_outlined, color: AppColors.turquoise, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.s.setProtectProgress,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  L10n.s.setProtectDesc,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withValues(alpha: 0.2), AppColors.coral.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
            child: const Icon(Icons.star_rounded, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.s.setUnlockPro,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  L10n.s.setUnlockProDesc,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
