import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:revenuecat_integration/models/store_config.dart';

class RevenuecatIntegrationService {
  RevenuecatIntegrationService._();
  static  RevenuecatIntegrationService? _instance;
  factory RevenuecatIntegrationService() => _instance ??= RevenuecatIntegrationService._();

  static RevenuecatIntegrationService get instance => _instance ?? RevenuecatIntegrationService._();

  final StreamController<bool> purchaseController = StreamController.broadcast();
  Stream<bool> get purchaseStream => purchaseController.stream;

  Future<void> init(StoreConfig storeConfig) async {
    await configureSDK(storeConfig.apiKey);
  }

  Future<void> configureSDK(String apiKey) async {
    if (apiKey.isEmpty) {
      throw Exception('API key is required');
    }
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
    PurchasesConfiguration configuration;
    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(apiKey)..appUserID = null;
    } else {
      configuration = PurchasesConfiguration(apiKey)..appUserID = null;
    }
    await Purchases.configure(configuration);
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.allPurchasedProductIdentifiers.isNotEmpty) {
      customerInfo.entitlements.all.forEach((key, value) {
        if (value.isActive) {
          purchaseController.sink.add(true);
        }
      });
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

  String? getSavePercentage(Package package, List<Package> packages) {
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

        return "%$savePercentage tasarruf et";
      }
    }
    return null;
  }

  String? getTrialDays(Package package) {
    final trialDuration = package.storeProduct.introductoryPrice?.periodNumberOfUnits;

    if (trialDuration == null || trialDuration <= 0) {
      return null;
    }

    return "$trialDuration günlük ücretsiz deneme";
  }

  Future<List<Package>?> fetchOffers() async {
    Offerings offerings = await Purchases.getOfferings();

    if (offerings.current == null) {
      throw Exception('No offerings available');
    }
    if (offerings.current!.availablePackages.isEmpty) {
      throw Exception('No packages available');
    }
    return offerings.current!.availablePackages;
  }
}


