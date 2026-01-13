import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/screens/home/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // In a real app, you would send this to Supabase
      // Auth.signInWithApple(idToken: credential.identityToken!)
      
      // For now, we simulate success and go to Home
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Apple Sign In Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                    boxShadow: AppShadows.card,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/brand/app_logo.png'),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  "Welcome back",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to sync your progress and Pro status across all your devices.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.dark.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                
                if (_isLoading)
                  const CircularProgressIndicator(color: AppColors.coral)
                else ...[
                  SignInWithAppleButton(
                    onPressed: _handleAppleSignIn,
                    style: SignInWithAppleButtonStyle.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Continue as Guest",
                      style: TextStyle(
                        color: AppColors.dark.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
