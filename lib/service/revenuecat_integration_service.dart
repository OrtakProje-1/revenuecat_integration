import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:revenuecat_integration/configs/subscription_screen_uiconfig.dart';
import 'package:revenuecat_integration/models/store_config.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/util/extensions.dart';
import 'package:revenuecat_integration/widgets/subscription_screen.dart';

class RevenuecatIntegrationService {
  String entitlement = "";

  RevenuecatIntegrationService._();
  static RevenuecatIntegrationService? _instance;

  static RevenuecatIntegrationService get instance => _instance ?? RevenuecatIntegrationService._();

  final StreamController<bool> purchaseController = StreamController.broadcast();
  Stream<bool> get purchaseStream => purchaseController.stream;

  Future<void> init(StoreConfig storeConfig) async {
    if (storeConfig.apiKey.isEmpty) {
      throw Exception('API key is required');
    }
    if (storeConfig.entitlement.isEmpty) {
      throw Exception('Entitlement is required');
    }

    entitlement = storeConfig.entitlement;
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
    PurchasesConfiguration configuration;
    if (storeConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(storeConfig.apiKey)..appUserID = null;
    } else {
      configuration = PurchasesConfiguration(storeConfig.apiKey)..appUserID = null;
    }
    await Purchases.configure(configuration);
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.allPurchasedProductIdentifiers.isNotEmpty) {
      purchaseController.sink.add(customerInfo.entitlements.all[entitlement]?.isActive ?? false);
    }
  }

  Future<bool> purchase(Package package, {String? entitlementKey = "premium"}) async {
    final purchaserInfo = await Purchases.purchasePackage(package);
    return purchaserInfo.entitlements.all[entitlementKey]?.isActive ?? false;
  }

  Future<void> restore() async {
    // Restore the purchases
  }

  Future<void> purchaseRestored() async {
    // Notify the app that the purchase is restored
  }

  Future<void> purchaseDeferred() async {
    // Notify the app that the purchase is deferred
  }

  Future<void> purchaseCancelled() async {
    // Notify the app that the purchase is cancelled
  }

  bool isPopular(Package package) {
    return package.packageType == PackageType.annual;
  }

  int? getSavePercentage(Package package, List<Package> packages) {
    if (package.packageType == PackageType.annual) {
      // Yıllık ve aylık paketleri bul
      final yearlyPackage = package;
      final monthlyPackage = packages.firstWhere(
        (p) => p.packageType == PackageType.monthly,
        orElse: () => package,
      );

      // Fiyatları al ve hesapla
      final yearlyPrice = yearlyPackage.storeProduct.price;
      final monthlyPrice = monthlyPackage.storeProduct.price;

      if (monthlyPrice > 0) {
        // Yıllık toplam = Aylık fiyat * 12 ay
        final yearlyTotal = monthlyPrice * 12;
        // Tasarruf yüzdesi = ((Yıllık toplam - Yıllık paket fiyatı) / Yıllık toplam) * 100
        final savePercentage = ((yearlyTotal - yearlyPrice) / yearlyTotal * 100).round();

        return savePercentage;
      }
    }
    return null;
  }

  int? getTrialDays(Package package) {
    final trialDuration = package.storeProduct.introductoryPrice?.periodNumberOfUnits;

    if (trialDuration == null || trialDuration <= 0) {
      return null;
    }

    return trialDuration;
  }

  Future<List<Package>?> getPackages() async {
    Offerings offerings = await fetchOfferings();

    if (offerings.current == null) {
      throw Exception('No offerings available');
    }
    if (offerings.current!.availablePackages.isEmpty) {
      throw Exception('No packages available');
    }
    return offerings.current!.availablePackages;
  }

  Future<Offerings> fetchOfferings() async {
    return await Purchases.getOfferings();
  }

  Future<PaywallResult?> goToSubscriptionPage(BuildContext context, {SubscriptionScreenUiConfig? uiConfig, TemplateType templateType = TemplateType.custom}) async {
    if (templateType == TemplateType.defaultUI) {
      try {
        return await RevenueCatUI.presentPaywallIfNeeded(entitlement);
      } catch (_) {}
    }
    return context.push<PaywallResult>(SubscriptionScreen(
      uiConfig: uiConfig ?? SubscriptionScreenUiConfig(),
    ));
  }
}
