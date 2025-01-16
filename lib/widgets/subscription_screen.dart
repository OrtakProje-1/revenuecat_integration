import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:revenuecat_integration/configs/subscription_screen_uiconfig.dart';
import 'package:revenuecat_integration/extensions/revenuecat_theme_extension.dart';
import 'package:revenuecat_integration/util/extensions.dart';
import 'package:revenuecat_integration/widgets/feature_item.dart';
import '../service/revenuecat_integration_service.dart';
import 'lottie_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, this.uiConfig});
  final SubscriptionScreenUiconfig? uiConfig;
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Package? selectedPackage;
  List<Package> packages = [];
  bool isLoading = true;

  SubscriptionScreenUiconfig get uiConfig =>
      widget.uiConfig ??
      SubscriptionScreenUiconfig(
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
    fetchOffers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchOffers() async {
    try {
      final List<Package>? packages = await RevenuecatIntegrationService.instance.fetchOffers();
      if (packages != null) {
        setState(() {
          this.packages = packages;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    RevenuecatThemeExtension customTheme = Theme.of(context).extension<RevenuecatThemeExtension>()!;

    return Scaffold(
      backgroundColor: uiConfig.backgroundBuilder == null ? null : Colors.transparent,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          if (uiConfig.backgroundBuilder != null) uiConfig.backgroundBuilder!(context, MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          if (uiConfig.backgroundBuilder == null) ...[
            Positioned(
              top: 20,
              left: 0,
              child: Opacity(
                opacity: 0.3,
                child: LottieWidget(
                  asset: context.isDarkTheme ? "subscription_bg_dark_animation" : "subscription_bg_light_animation",
                  repeat: true,
                  size: const Size(300, 300),
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
                    asset: context.isDarkTheme ? "subscription_bg_dark_animation" : "subscription_bg_light_animation",
                    repeat: true,
                    size: const Size(300, 300),
                  ),
                ),
              ),
            ),
          ],

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: LottieWidget(
                      asset: 'premium',
                      size: Size(250, 250),
                      repeat: true,
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
                  _buildPackageCards(customTheme),
                  const SizedBox(height: 32),
                  _buildFeaturesList(),
                  const SizedBox(height: 24),
                  _buildSubscribeButton(),
                  const SizedBox(height: 16),
                  // _buildFooter(),
                ],
              ),
            ),
          ),
          // X butonu için Positioned widget
          Positioned(
            top: 48, // Safe area için üstten boşluk
            left: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: customTheme.trialText),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCards(RevenuecatThemeExtension customTheme) {
    return Column(
      children: packages.map((package) {
        final isSelected = selectedPackage == package;
        final bool isPopular = RevenuecatIntegrationService.instance.isPopular(package);
        final int? trialDays = RevenuecatIntegrationService.instance.getTrialDays(package);
        final int? savePercentage = RevenuecatIntegrationService.instance.getSavePercentage(package, packages);
        final Widget child = Banner(
          color: isPopular ? customTheme.popularBadgeBg : Colors.transparent,
          message: isPopular ? uiConfig.popularBadgeText : "",
          location: BannerLocation.topStart,
          shadow: BoxShadow(
            color: isPopular ? Colors.black.withAlpha(100) : Colors.black.withAlpha(0),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
          
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? customTheme.packageSelectedBg : customTheme.packageUnselectedBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? customTheme.packageBorderColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Radio(
                  activeColor: customTheme.trialText,
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
                            color: customTheme.trialText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (savePercentage != null)
                        Text(
                          uiConfig.editingSavePercentageText(savePercentage),
                          style: TextStyle(
                            color: customTheme.trialText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
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
          onTap: () => setState(() => selectedPackage = package),
          child: Badge(
              label: savePercentage != null ? Text(uiConfig.editingSavePercentageText(savePercentage)) : null,
              backgroundColor: savePercentage != null ? customTheme.popularBadgeBg : null,
              textColor: customTheme.popularBadgeText,
              offset: const Offset(-75, -6),
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                child: child,
              )),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesList() {
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

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => RevenuecatIntegrationService.instance.purchase(selectedPackage!),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.revenuecatThemeExtension.trialText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          uiConfig.purchaseButtonTitle,
          style: context.textTheme.titleSmall!.copyWith(color: context.revenuecatThemeExtension.popularBadgeText),
        ),
      ),
    );
  }

  Widget buildFooter() {
    return TextButton(
      onPressed: () => Purchases.restorePurchases(),
      child: const Text("Satın Almaları Geri Yükle"),
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
