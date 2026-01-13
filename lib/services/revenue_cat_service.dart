import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> init() async {
    // Enable debug logging for development
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      // Add Google key here when available
      configuration = PurchasesConfiguration("appl_mlpCXPpLqHeoIdyPyneUwxHqvCx"); 
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration("appl_mlpCXPpLqHeoIdyPyneUwxHqvCx");
    } else {
      return;
    }

    await Purchases.configure(configuration);
    await updatePurchaseStatus();
  }

  Future<void> updatePurchaseStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    _isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
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
