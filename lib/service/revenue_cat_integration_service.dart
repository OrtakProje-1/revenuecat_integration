import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:revenue_cat_integration/configs/subscription_screen_ui_config.dart';
import 'package:revenue_cat_integration/models/revenue_cat_integration_theme.dart';
import 'package:revenue_cat_integration/models/store_config.dart';
import 'package:revenue_cat_integration/pages/subscription_screen.dart';
import 'package:revenue_cat_integration/util/defines.dart';
import 'package:revenue_cat_integration/util/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RevenueCatIntegrationService {
  String entitlement = "";
  CustomerInfo? customerInfo;
  List<String> activeSubscriptions = [];

  RevenueCatIntegrationService._();
  static RevenueCatIntegrationService? _instance;

  static RevenueCatIntegrationService get instance => _instance ??= RevenueCatIntegrationService._();

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
    if (storeConfig.entitlement.isEmpty) {
      throw Exception('Entitlement is required');
    }

    entitlement = storeConfig.entitlement;
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
    await Purchases.configure(storeConfig.configuration);
    listenCustomerInfo();
    restore();
  }

  /// Listens for customer info updates and updates the [customerInfo] property accordingly.
  ///
  /// This is a convenience method to keep track of the customer info. It is
  /// recommended to call this method once the service is initialized.
  ///
  void listenCustomerInfo() {
    Purchases.addCustomerInfoUpdateListener((info) {
      customerInfo = info;
      isPremium.value = info.entitlements.all[entitlement]?.isActive ?? false;
      activeSubscriptions = info.activeSubscriptions;
    });
  }

  /// Checks if the customer is entitled to the configured entitlement.
  ///
  /// Returns true if the customer is entitled to the configured entitlement,
  /// false otherwise.
  ///
  /// Sets the value of [isPremium] based on the customer's entitlement to
  /// the configured entitlement.
  Future<bool> checkPremium() async {
    isPremium.value = customerInfo?.entitlements.all[entitlement]?.isActive ?? false;
    return isPremium.value;
  }

  /// Purchase a [Package].
  ///
  /// Purchases the provided [Package] and sets [activeSubscriptions] to the
  /// identifier of the package if the purchase is successful.
  ///
  /// Sets [isPremium] to true if the customer is entitled to the provided
  /// [entitlementKey].
  ///
  /// Returns [isPremium] (true if the customer is entitled to the provided
  /// entitlement, false otherwise).
  ///
  Future<PaywallResult> purchase(Package package, {String entitlementKey = "premium"}) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      var entitlementInfo = purchaserInfo.entitlements.all[entitlementKey];
      activeSubscriptions = purchaserInfo.activeSubscriptions;
      isPremium.value = entitlementInfo?.isActive ?? false;
      return isPremium.value ? PaywallResult.purchased : PaywallResult.error;
    } on PlatformException catch (error) {
      PurchasesErrorCode code = PurchasesErrorHelper.getErrorCode(error);
      return code == PurchasesErrorCode.purchaseCancelledError ? PaywallResult.cancelled : PaywallResult.error;
    }
  }

  /// Upgrades the current subscription.
  ///
  /// This function is used to upgrade the user's current subscription to a higher tier package.
  /// For example, upgrading from a monthly subscription to an annual subscription.
  ///
  /// The [package] parameter specifies the new package to upgrade to.
  /// The [entitlementKey] parameter defaults to "premium" and specifies the entitlement
  /// key to check after the upgrade.
  ///
  /// Returns [PaywallResult.purchased] on successful upgrade.
  /// Returns [PaywallResult.error] in case of any errors.
  ///
  Future<PaywallResult> upgradePackage(Package package, {String entitlementKey = "premium"}) async {
    try {
      bool canMakePayments = await Purchases.canMakePayments();
      if (!canMakePayments) {
        return PaywallResult.error;
      }
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isEmpty) {
        return PaywallResult.error;
      }
      await Purchases.syncPurchases();
      await Purchases.purchasePackage(package,
          googleProductChangeInfo: GoogleProductChangeInfo(
            customerInfo.entitlements.active.values.first.productIdentifier,
          ));
      return PaywallResult.purchased;
    } on PlatformException catch (e) {
      PurchasesErrorCode code = PurchasesErrorHelper.getErrorCode(e);
      return code == PurchasesErrorCode.purchaseCancelledError ? PaywallResult.cancelled : PaywallResult.error;
    }
  }

  // Future<bool> purchaseSubscriptionOption(SubscriptionOption option) async {
  //   try {
  //     final CustomerInfo info = await Purchases.purchaseSubscriptionOption(option);
  //     isPremium.value = info.entitlements.active[entitlement]?.isActive ?? false;
  //     return isPremium.value;
  //   } on PlatformException catch (error) {
  //     PurchasesErrorCode code = PurchasesErrorHelper.getErrorCode(error);
  //     log("---PurchaseError ${error.message}", error: error);
  //     debugPrint(code == PurchasesErrorCode.purchaseCancelledError ? "Purchase cancelled" : "There was an error with the purchase. Error code: $code, error: ${error.message}");
  //     return false;
  //   }
  // }

  /// Restore purchases and set [isPremium] to true if the customer is entitled to [entitlement].
  ///
  /// Returns true if the customer is entitled to the provided entitlement, false otherwise.
  Future<bool> restore() async {
    try {
      var info = await Purchases.restorePurchases();
      var isActive = info.entitlements.all[entitlement]?.isActive ?? false;
      isPremium.value = isActive;
      activeSubscriptions = info.activeSubscriptions;
      return isActive;
    } catch (e) {
      return false;
    }
  }

  /// Returns true if the provided [Package] is the popular one, false otherwise.
  bool isPopular(Package package) {
    return package.packageType == PackageType.annual;
  }

  /// Calculates the percentage of the savings of a [Package] compared to the
  /// monthly package price if it was purchased for the same duration as the
  /// package.
  /// For example, if the package type is [PackageType.annual], the function
  /// calculates the price of 12 months of the monthly package and compares it
  /// to the price of the annual package.
  /// Returns the percentage of the savings as an integer, or null if the
  /// package type is not [PackageType.annual].
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

    final monthlyPackage = packages.firstWhereOrNull((p) => p.packageType == PackageType.monthly);

    if (monthlyPackage == null) return null;

    final packagePrice = package.storeProduct.price;
    final monthlyPrice = monthlyPackage.storeProduct.price;

    if (monthlyPrice > 0) {
      final totalMonthlyCost = monthlyPrice * months;
      final discountPercentage = ((totalMonthlyCost - packagePrice) / totalMonthlyCost * 100).round();

      return discountPercentage;
    }
    return null;
  }

  /// Returns the number of days in the trial period of the given [Package] or null if
  /// there is no trial period.
  (int, PeriodUnit)? getTrialDays(Package package) {
    SubscriptionOption? subscriptionOption = package.storeProduct.defaultOption;
    if (subscriptionOption?.freePhase?.billingPeriod == null) {
      return null;
    }

    return (subscriptionOption!.freePhase!.billingPeriod!.value, subscriptionOption.freePhase!.billingPeriod!.unit);
  }

  /// Fetches the available packages for the user and returns them in a list, or
  /// throws an exception if no offerings or packages are available.
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

  /// Fetches the current offerings and their available packages from RevenueCat and
  /// returns them in an [Offerings] object.
  ///
  /// Throws an exception if there are no offerings available.
  Future<Offerings> fetchOfferings() async {
    return await Purchases.getOfferings();
  }

  /// Shows the subscription screen to the user. If [templateType] is
  /// [DesignTemplateType.defaultUI], this function will show the default UI
  /// paywall provided by RevenueCat. Otherwise, it will show the custom UI
  /// paywall provided by this package.
  ///
  /// The [uiConfig] parameter can be used to customize the look and feel of
  /// the custom UI paywall. The [theme] parameter can be used to customize
  /// the colors of the custom UI paywall.
  ///
  /// This function returns a [PaywallResult] if the user makes a purchase or
  /// cancels the paywall. Otherwise, it returns null.
  ///
  /// Note that this function only shows the paywall if the user does not
  /// already have an active entitlement. If the user does have an active
  /// entitlement, this function will return null without showing the paywall.
  ///
  /// This function must be called from within a [Widget] subtree, as it
  /// uses [Navigator.push] to show the paywall.
  Future<PaywallResult?> goToSubscriptionPage(BuildContext context,
      {SubscriptionScreenUiConfig? uiConfig, RevenueCatIntegrationTheme? theme, DesignTemplateType templateType = DesignTemplateType.custom}) async {
    if (templateType == DesignTemplateType.defaultUI) {
      try {
        var paywallResult = await RevenueCatUI.presentPaywallIfNeeded(entitlement);
        if (paywallResult == PaywallResult.purchased) {
          await checkPremium();
        }
        return paywallResult;
      } catch (_) {}
    }
    // ignore: use_build_context_synchronously
    return await context.push<PaywallResult>(SubscriptionScreen(
      theme: theme,
      uiConfig: uiConfig ?? SubscriptionScreenUiConfig(),
    ));
  }

  /// Returns a map containing the active package details, or null if there is no active subscription.
  ///
  /// The map contains the following keys:
  ///
  /// - 'package': the identifier of the active package.
  /// - 'expirationDate': the date when the subscription will expire, or the date when the subscription was cancelled.
  /// - 'willRenew': whether the subscription will renew or not.
  ///
  /// Note that this function returns the details of the active subscription, not the details of a specific package. If you
  /// want to get the details of a specific package, you can use [getPackages] instead.
  Future<Map<String, dynamic>?> getActivePackageDetails() async {
    final entitlementInfo = customerInfo?.entitlements.all[entitlement];

    if (entitlementInfo != null && entitlementInfo.isActive) {
      return {'package': entitlementInfo.identifier, 'expirationDate': entitlementInfo.expirationDate, 'willRenew': entitlementInfo.willRenew, 'productIdentifier': entitlementInfo.productIdentifier};
    }
    return null;
  }

  /// Returns the expiration date of the current subscription, or null if there
  /// is no active subscription. The expiration date is the date when the
  /// subscription will expire, or the date when the subscription was cancelled.
  ///
  /// The expiration date is returned as a [DateTime] object. If there is no
  /// active subscription, the function returns null.
  ///
  /// Note that this function returns the expiration date of the current
  /// subscription, not the expiration date of a specific package. If you
  /// want to get the expiration date of a specific package, you can use
  /// [getActivePackageDetails] instead.
  Future<DateTime?> getExpirationDate() async {
    final entitlementInfo = customerInfo?.entitlements.all[entitlement];
    if (entitlementInfo.isNotNull && entitlementInfo!.expirationDate.isNotNull) {
      return DateTime.parse(entitlementInfo.expirationDate!);
    }
    return null;
  }

  /// Launches the subscription management page for the current platform.
  ///
  /// This function opens the subscription settings page for the user, allowing
  /// them to manage their active subscriptions. For iOS devices, it opens the
  /// App Store subscriptions page. For Android devices, it opens the Google Play
  /// Store subscriptions page.
  ///
  /// The [context] parameter is required for potential future enhancements, but
  /// is not currently utilized within this function.
  ///
  /// Note: Ensure that the `url_launcher` package is properly configured in your
  /// project to allow launching URLs.
  ///
  /// Throws an exception if the URL cannot be launched.

  Future<bool> cancelSubscription(BuildContext context) async {
    final url = defaultTargetPlatform == TargetPlatform.iOS ? 'https://apps.apple.com/account/subscriptions' : 'https://play.google.com/store/account/subscriptions';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrlString(url);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
