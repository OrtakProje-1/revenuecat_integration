import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:revenuecat_integration/configs/subscription_screen_uiconfig.dart';
import 'package:revenuecat_integration/models/store_config.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/util/extensions.dart';
import 'package:revenuecat_integration/pages/subscription_screen.dart';

class RevenuecatIntegrationService {
  String entitlement = "";
  String? activePackageIdentifier;

  RevenuecatIntegrationService._();
  static RevenuecatIntegrationService? _instance;

  static RevenuecatIntegrationService get instance => _instance ?? RevenuecatIntegrationService._();

  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  /// Initialize the RevenueCat integration service.
  ///
  /// Throws [Exception] if the provided [StoreConfig] is invalid.
  ///
  /// [StoreConfig.apiKey] and [StoreConfig.entitlement] are required.
  ///
  /// If [StoreConfig.isForAmazonAppstore] is true, [Purchases.configure] is called with
  /// [AmazonConfiguration].
  ///
  /// Otherwise, [Purchases.configure] is called with [PurchasesConfiguration].
  ///
  /// The value of [isPremium] is set based on the customer's entitlement to the
  /// provided [entitlement].
  ///
  /// This method must be called before any other methods in this class.
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
    isPremium.value = customerInfo.entitlements.all[entitlement]?.isActive ?? false;
  }

  Future<bool> purchase(Package package, {String entitlementKey = "premium"}) async {
    final purchaserInfo = await Purchases.purchasePackage(package);
    var entitlementInfo = purchaserInfo.entitlements.all[entitlementKey];
    activePackageIdentifier = entitlementInfo?.identifier;
    isPremium.value = entitlementInfo?.isActive ?? false;
    return isPremium.value;
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
    int months = 0;

    switch (package.packageType) {
      case PackageType.annual:
        months = 12;
        break;
      case PackageType.sixMonth:
        months = 6;
        break;
      case PackageType.threeMonth:
        months = 3;
        break;
      case PackageType.twoMonth:
        months = 2;
        break;
      default:
        return null;
    }

    if (package.packageType == PackageType.annual) {
      final monthlyPackage = packages.firstWhereOrNull((p) => p.packageType == PackageType.monthly);

      if (monthlyPackage == null) return null;

      final packagePrice = package.storeProduct.price;
      final monthlyPrice = monthlyPackage.storeProduct.price;

      if (monthlyPrice > 0) {
        final totalMonthlyCost = monthlyPrice * months;
        final discountPercentage = ((totalMonthlyCost - packagePrice) / totalMonthlyCost * 100).round();

        return discountPercentage;
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

  Future<PaywallResult?> goToSubscriptionPage(BuildContext context, {SubscriptionScreenUiConfig? uiConfig, DesignTemplateType templateType = DesignTemplateType.custom}) async {
    if (templateType == DesignTemplateType.defaultUI) {
      try {
        return await RevenueCatUI.presentPaywallIfNeeded(entitlement);
      } catch (_) {}
    }
    return context.push<PaywallResult>(SubscriptionScreen(
      uiConfig: uiConfig ?? SubscriptionScreenUiConfig(),
    ));
  }
}
