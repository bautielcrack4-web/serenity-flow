import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/onboarding/onboarding_flow.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/screens/home/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: 'https://ggurnxgfbdetqzcizeun.supabase.co',
      anonKey: 'sb_publishable_nXIIb_p4hxt3qVcn-7-0Zg_amh60p4I',
    );
    
    // Ensure anonymous sign-in right away
    final supabaseService = SupabaseService();
    await supabaseService.signInAnonymously();
    
    // Initialize RevenueCat
    await RevenueCatService().init();
  } catch (e) {
    debugPrint("Initialization Error: $e");
    // We continue to allow the app to run, but services might be null
  }

  runApp(const SerenityFlowApp());
}

class SerenityFlowApp extends StatelessWidget {
  const SerenityFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuna',
      debugShowCheckedModeBanner: false,
      theme: AppTypography.theme,
      routes: {
        '/home': (context) => const MainNavigationScreen(),
      },
      home: FutureBuilder<bool>(
        future: _checkOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.coral)));
          }
          if (snapshot.data == true) {
            return const MainNavigationScreen();
          }
          return const OnboardingFlow();
        },
      ), 
    );
  }

  Future<bool> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}
