import 'package:revenuecat_integration/configs/packages_text_config.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/widgets/feature_item.dart';

class SubscriptionScreenUiconfig {
  String title;
  String description;
  String purchaseButtonTitle;
  String popularBadgeText;
  String includesTitle;
  bool showFeaturesIcons;
  List<FeatureItem> features;
  PackagesTextConfig packagesTextConfig;
  SubscriptionScreenBackgroundBuilder? backgroundBuilder;
  SubscriptionScreenUiconfig({
    this.title = 'Choose a plan',
    this.description = 'Unlock all the features by subscribing to our service',
    this.purchaseButtonTitle = 'Subscribe',
    this.popularBadgeText = 'Popular',
    this.includesTitle = 'Includes',
    this.showFeaturesIcons = false,
    this.backgroundBuilder,
    this.features = const[],
    PackagesTextConfig? packagesTextConfig,
  }) : packagesTextConfig = packagesTextConfig ?? PackagesTextConfig.defaultConfig();
}
