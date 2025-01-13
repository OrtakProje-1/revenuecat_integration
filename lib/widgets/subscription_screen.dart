import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:revenuecat_integration/extensions/revenuecat_theme_extension.dart';
import 'package:revenuecat_integration/util/extensions.dart';

import 'lottie_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Package? selectedPackage;
  List<Package> packages = [];
  bool isLoading = true;

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
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        setState(() {
          packages = offerings.current!.availablePackages;
          isLoading = false;
          selectedPackage = packages.firstWhere(
            (package) => package.packageType == PackageType.annual,
            orElse: () => packages.first,
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    RevenuecatThemeExtension customTheme = Theme.of(context).extension<RevenuecatThemeExtension>()!;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
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
                    "Bir plan seçin",
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Daha fazla özellik ve içerik için bir plan seçin",
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

        return GestureDetector(
          onTap: () => setState(() => selectedPackage = package),
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
                      Text(
                        package.storeProduct.priceString,
                        style: context.textTheme.bodyLarge,
                      ),
                      if (_getTrialDays(package) != null)
                        Text(
                          _getTrialDays(package)!,
                          style: TextStyle(
                            color: customTheme.trialText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (_getSavePercentage(package) != null)
                        Text(
                          _getSavePercentage(package)!,
                          style: TextStyle(
                            color: customTheme.trialText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isPopular(package))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: customTheme.popularBadgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "En Popüler",
                      style: TextStyle(
                        color: customTheme.popularBadgeText,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Neleri içerir?",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(Icons.check_circle, "Tüm özelliklere sınırsız erişim"),
        _buildFeatureItem(Icons.block, "Reklamsız kullanım"),
        _buildFeatureItem(Icons.update, "Yeni özellikler"),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: context.revenuecatThemeExtension.trialText, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _handlePurchase(),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.revenuecatThemeExtension.trialText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "Satın Al",
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
      case PackageType.monthly:
        return "Aylık Plan";
      case PackageType.annual:
        return "Yıllık Plan";
      case PackageType.lifetime:
        return "Ömür Boyu Plan";
      default:
        return package.storeProduct.title;
    }
  }

  String? _getTrialDays(Package package) {
    final trialDuration = package.storeProduct.introductoryPrice?.periodNumberOfUnits;

    if (trialDuration == null || trialDuration <= 0) {
      return null;
    }

    return "$trialDuration günlük ücretsiz deneme";
  }

  String? _getSavePercentage(Package package) {
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

  bool _isPopular(Package package) {
    return package.packageType == PackageType.annual;
  }

  Future<void> _handlePurchase() async {
    if (selectedPackage == null) return;

    try {
      final purchaserInfo = await Purchases.purchasePackage(selectedPackage!);
      if (purchaserInfo.entitlements.all['premium']?.isActive ?? false) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      // Hata yönetimi
    }
  }
}
