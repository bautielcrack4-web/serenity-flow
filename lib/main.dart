import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/onboarding/questionnaire_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';

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
      title: 'Serenity Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTypography.theme,
      home: const QuestionnaireScreen(), // Direct to Quiz
    );
  }
}
