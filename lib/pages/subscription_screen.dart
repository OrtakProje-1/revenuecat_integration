// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:revenuecat_integration/configs/subscription_screen_uiconfig.dart';
import 'package:revenuecat_integration/models/lottie_widget_config.dart';
import 'package:revenuecat_integration/models/revenuecat_integration_theme.dart';
import 'package:revenuecat_integration/util/extensions.dart';
import 'package:revenuecat_integration/widgets/feature_item.dart';
import '../service/revenuecat_integration_service.dart';
import '../widgets/lottie_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  final SubscriptionScreenUiConfig? uiConfig;
  final RevenuecatIntegrationTheme? theme;
  const SubscriptionScreen({super.key, this.uiConfig, this.theme});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Package? selectedPackage;
  List<Package> packages = [];
  bool isLoading = true;
  ValueNotifier<bool> restoringPurchases = ValueNotifier(false);

  RevenuecatIntegrationTheme get theme => widget.theme ?? (context.isDarkTheme ? RevenuecatIntegrationTheme.dark : RevenuecatIntegrationTheme.light);
  RevenuecatIntegrationService get service => RevenuecatIntegrationService.instance;
  SubscriptionScreenUiConfig get uiConfig =>
      widget.uiConfig ??
      SubscriptionScreenUiConfig(
        features: [
          const FeatureItem(title: "Unlimited access to all features", icon: Icon(Icons.check_circle)),
          const FeatureItem(title: "Ad-free use", icon: Icon(Icons.block)),
          const FeatureItem(title: "New features", icon: Icon(Icons.update)),
        ],
      );

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    fetchPackages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchPackages() async {
    try {
      final List<Package>? packages = await service.getPackages();
      if (packages != null) {
        setState(() {
          this.packages = packages;
          selectedPackage = packages.firstWhereOrNull((package) => package.packageType == PackageType.annual);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var lottieAsset = context.isDarkTheme ? "subscription_bg_dark_animation.json" : "subscription_bg_light_animation.json";

    return Scaffold(
      backgroundColor: uiConfig.backgroundBuilder == null ? null : Colors.transparent,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          if (uiConfig.backgroundBuilder != null) uiConfig.backgroundBuilder!(context, size.height, size.width),
          if (uiConfig.backgroundBuilder == null) ...[
            Positioned(
              top: 20,
              left: 0,
              child: Opacity(
                opacity: 0.3,
                child: LottieWidget(
                  config: LottieWidgetConfig(asset: 'assets/animations/$lottieAsset', package: "revenuecat_integration", repeat: true, size: const Size(300, 300)),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: 0,
              child: Transform.rotate(
                angle: 3.14,
                child: Opacity(
                  opacity: 0.3,
                  child: LottieWidget(
                    config: LottieWidgetConfig(asset: 'assets/animations/$lottieAsset', package: "revenuecat_integration", repeat: true, size: const Size(300, 300)),
                  ),
                ),
              ),
            ),
          ],

          SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: LottieWidget(
                      config: LottieWidgetConfig(asset: 'assets/animations/premium.json', package: "revenuecat_integration", repeat: true, size: const Size(250, 250)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    uiConfig.title,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uiConfig.description,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPackageCards(),
                  const SizedBox(height: 32),
                  _buildFeaturesList(),
                  const SizedBox(height: 24),
                  _buildSubscribeButton(context),
                  const SizedBox(height: 16),
                  _buildFooter(),
                ],
              ),
            ),
          ),
          // X butonu için Positioned widget
          Positioned(
            top: 48, // Safe area için üstten boşluk
            left: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: theme.trialText),
              onPressed: () => context.pop(PaywallResult.cancelled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCards() {
    return Column(
      children: packages.map((package) {
        var isDisabled = package.identifier == service.activePackageIdentifier;
        final isSelected = selectedPackage == package;
        final bool isPopular = service.isPopular(package);
        final int? trialDays = service.getTrialDays(package);
        final int? savePercentage = service.getSavePercentage(package, packages);
        final Widget child = Banner(
          color: isPopular ? theme.popularBadgeBg : Colors.transparent,
          message: isPopular ? uiConfig.popularBadgeText : "",
          location: BannerLocation.topEnd,
          shadow: BoxShadow(
            color: isPopular ? Colors.black.withAlpha(100) : Colors.black.withAlpha(0),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 32, top: 16),
            decoration: BoxDecoration(
              color: isSelected ? theme.packageSelectedBg : theme.packageUnselectedBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? theme.packageBorderColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                if (!isDisabled)
                  Radio(
                    activeColor: theme.trialText,
                    value: package,
                    groupValue: selectedPackage,
                    onChanged: (Package? value) {
                      setState(() => selectedPackage = value);
                    },
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPackageTitle(package),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (trialDays != null)
                        Text(
                          uiConfig.editingTrialDaysText(trialDays),
                          style: TextStyle(
                            color: theme.trialText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isDisabled)
                  Card(
                    elevation: 0,
                    color: theme.packageBorderColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(uiConfig.activePackageText),
                    ),
                  )
                else
                  Text(
                    package.storeProduct.priceString,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
        return GestureDetector(
          onTap: isDisabled ? null : () => setState(() => selectedPackage = package),
          child: Badge(
              label: savePercentage != null ? Text(uiConfig.editingSavePercentageText(savePercentage)) : null,
              backgroundColor: savePercentage != null ? theme.popularBadgeBg : null,
              textColor: theme.popularBadgeText,
              isLabelVisible: savePercentage != null,
              alignment: Alignment.topLeft,
              offset: const Offset(18, -8),
              child: ClipRRect(clipBehavior: Clip.hardEdge, child: child)),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesList() {
    if (uiConfig.features.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uiConfig.includesTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...uiConfig.features,
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ValueListenableBuilder(
          valueListenable: restoringPurchases,
          builder: (context, value, _) {
            return AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: value ? .4 : 1,
              child: ElevatedButton(
                onPressed: selectedPackage == null
                    ? null
                    : () async {
                        if (value) return;
                        try {
                          var result = await service.purchase(selectedPackage!);
                          if (!context.mounted) return;
                          context.pop(result ? PaywallResult.purchased : PaywallResult.cancelled);
                        } catch (e) {
                          context.pop(PaywallResult.error);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.trialText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  uiConfig.purchaseButtonTitle,
                  style: context.textTheme.titleSmall!.copyWith(color: theme.popularBadgeText),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: () async {
        var result = await service.restore();
        if (result) {
          context.pop(PaywallResult.restored);
        }
      },
      child: Text(uiConfig.restorePurchases),
    );
  }

  String _getPackageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.unknown:
        return uiConfig.packagesTextConfig.unknowPackageText;
      case PackageType.custom:
        return uiConfig.packagesTextConfig.customPackageText;
      case PackageType.lifetime:
        return uiConfig.packagesTextConfig.lifetimePackageText;
      case PackageType.annual:
        return uiConfig.packagesTextConfig.annualPackageText;
      case PackageType.sixMonth:
        return uiConfig.packagesTextConfig.sixMonthPackageText;
      case PackageType.threeMonth:
        return uiConfig.packagesTextConfig.threeMonthPackageText;
      case PackageType.twoMonth:
        return uiConfig.packagesTextConfig.twoMonthPackageText;
      case PackageType.monthly:
        return uiConfig.packagesTextConfig.monthlyPackageText;
      case PackageType.weekly:
        return uiConfig.packagesTextConfig.weeklyPackageText;
    }
  }
}
