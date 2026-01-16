import 'dart:io';
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
    try {
      // Enable debug logging for development
      await Purchases.setLogLevel(LogLevel.debug);

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
      await updatePurchaseStatus();
    } catch (e) {
      print("RevenueCat initialization failed: $e");
      // Continue without RevenueCat - app will work but purchases won't
    }
  }

  Future<void> updatePurchaseStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
      
      // Auto-Sync: Keep Supabase source of truth updated with Apple/Google status
      // This removes the need for complex server-side webhooks for the MVP
      await SupabaseService().updateProStatus(_isPro);
      
    } catch (e) {
      print("Failed to update purchase status: $e");
      // If error (offline), we keep previous state or default to false safely
    }
  }

  Future<List<Package>> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (e) {
      print("Error fetching offerings: $e");
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      _isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
      return _isPro;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Error purchasing package: $e");
      }
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
    } on PlatformException catch (e) {
      print("Error restoring purchases: $e");
    }
  }
}
