import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:serenity_flow/services/supabase_service.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint("RevenueCat not supported on Web");
      return;
    }

    try {
      // Use error-level logging in production
      await Purchases.setLogLevel(LogLevel.error);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        // Add Google key here when available
        configuration = PurchasesConfiguration("goog_placeholder_key"); 
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration("appl_mlpCXPpLqHeoIdyPyneUwxHqvCx");
      } else {
        return;
      }

      await Purchases.configure(configuration);
      
      // Add listener for subscription changes
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        // Check both possible IDs to be safe
        _isPro = (customerInfo.entitlements.all['pro_access']?.isActive ?? false) ||
                 (customerInfo.entitlements.all['Yuna yoga app Pro']?.isActive ?? false);
                 
        // Sync to Supabase whenever RevenueCat detects a change
        SupabaseService().updateProStatus(_isPro);
        debugPrint("RevenueCat listener: Pro status updated to $_isPro");
      });
      
      await updatePurchaseStatus();
    } catch (e) {
      debugPrint("RevenueCat initialization failed: $e");
      // Continue without RevenueCat - app will work but purchases won't
    }
  }

  Future<void> updatePurchaseStatus() async {
    if (kIsWeb) return;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPro = (customerInfo.entitlements.all['pro_access']?.isActive ?? false) ||
               (customerInfo.entitlements.all['Yuna yoga app Pro']?.isActive ?? false);
      
      // Auto-Sync: Keep Supabase source of truth updated with Apple/Google status
      // This removes the need for complex server-side webhooks for the MVP
      await SupabaseService().updateProStatus(_isPro);
      
    } catch (e) {
      debugPrint("Failed to update purchase status: $e");
      // If error (offline), we keep previous state or default to false safely
    }
  }

  Future<List<Package>> getOfferings() async {
    if (kIsWeb) return [];
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (e) {
      debugPrint("Error fetching offerings: $e");
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      _isPro = (customerInfo.entitlements.all['pro_access']?.isActive ?? false) ||
               (customerInfo.entitlements.all['Yuna yoga app Pro']?.isActive ?? false);
      return _isPro;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint("Error purchasing package: $e");
      }
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _isPro = (customerInfo.entitlements.all['pro_access']?.isActive ?? false) ||
               (customerInfo.entitlements.all['Yuna yoga app Pro']?.isActive ?? false);
    } on PlatformException catch (e) {
      debugPrint("Error restoring purchases: $e");
    }
  }

  Future<void> logIn(String userId) async {
    if (kIsWeb) return;
    try {
      await Purchases.logIn(userId);
      debugPrint("RevenueCat logIn successful for: $userId");
    } catch (e) {
      debugPrint("RevenueCat logIn error: $e");
    }
  }

  /// Set email as subscriber attribute in RevenueCat
  /// This links the captured email to the subscription for lead tracking
  Future<void> setEmail(String email) async {
    if (kIsWeb || email.isEmpty) return;
    try {
      await Purchases.setEmail(email);
      debugPrint("RevenueCat email set: $email");
    } catch (e) {
      debugPrint("RevenueCat setEmail error: $e");
    }
  }
}
