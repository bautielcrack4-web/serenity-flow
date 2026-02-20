import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as api_ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/main.dart'; // To restart app
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  int _poseDuration = 30; // Restoring this missing variable

  bool _isAnonymous = false;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _isPro = RevenueCatService().isPro;
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
            const SnackBar(content: Text("Account successfully linked! Progress saved. ✅")),
          );
        }
      }
    } catch (e) {
      debugPrint("Sign in error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign in failed: ${e.toString()}")),
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
                child: Text("Settings", style: Theme.of(context).textTheme.displayLarge),
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
                    
                    _buildSectionPadding("SESSION"),
                    _buildPillSelector(),
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding("PREFERENCES"),
                    _buildSettingsCard([
                      _buildSwitchTile("Sound", _soundEnabled, Icons.volume_up_rounded, (v) => setState(() => _soundEnabled = v)),
                      _buildDivider(),
                      _buildSwitchTile("Haptics", _vibrationEnabled, Icons.vibration_rounded, (v) => setState(() => _vibrationEnabled = v)),
                    ]),
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding("NOTIFICATIONS"),
                    _buildSettingsCard([
                      _buildSwitchTile("Reminders", _notificationsEnabled, Icons.notifications_active_rounded, (v) => setState(() => _notificationsEnabled = v)),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionPadding("LEGAL"),
                    _buildSettingsCard([
                      _buildActionTile("Privacy Policy", Icons.privacy_tip_outlined, () {
                         _launchUrl("https://sites.google.com/view/yunaapp/privacy-policy");
                      }),
                      _buildDivider(),
                      _buildActionTile("Terms of Service", Icons.description_outlined, () {
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
          const Text("Pose Duration", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.dark)),
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
        child: Text("Reset Practice Data", style: TextStyle(color: AppColors.coral.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w900)),
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
            Icon(Icons.chevron_right_rounded, color: AppColors.gray.withOpacity(0.5)),
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
              title: const Text("Delete Account"),
              content: const Text("Are you sure? This action is irreversible and will delete all your progress."),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text("Delete"),
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog
                    await SupabaseService().deleteAccount();
                    if (!mounted) return;
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
          "Delete Account",
          style: TextStyle(color: Colors.red.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSignInBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.turquoise.withOpacity(0.1), AppColors.coral.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.turquoise.withOpacity(0.3), width: 1.5),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Protect Your Progress",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Sign in with Apple to save your routines & progress in the cloud",
                  style: TextStyle(fontSize: 12, color: AppColors.gray),
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
          colors: [AppColors.gold.withOpacity(0.2), AppColors.coral.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unlock Pro Access",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Get unlimited access to all advanced yoga routines & premium features",
                  style: TextStyle(fontSize: 12, color: AppColors.gray),
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
