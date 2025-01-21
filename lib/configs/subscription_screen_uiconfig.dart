import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:revenuecat_integration/configs/packages_text_config.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/widgets/feature_item.dart';

class SubscriptionScreenUiConfig {
  String title;
  String description;
  String purchaseButtonTitle;
  String popularBadgeText;
  String includesTitle;
  String activePackageText;
  String restorePurchases;
  List<FeatureItem> features;
  PackagesTextConfig packagesTextConfig;
  SubscriptionScreenBackgroundBuilder? backgroundBuilder;
  EditableText editingSavePercentageText;
  TrialDaysEditableText editingTrialDaysText;
  SubscriptionScreenUiConfig({
    this.title = 'Choose a plan',
    this.description = 'Unlock all the features by subscribing to our service',
    this.purchaseButtonTitle = 'Subscribe',
    this.popularBadgeText = 'Popular',
    this.includesTitle = 'Includes',
    this.activePackageText = 'Active package',
    this.restorePurchases = 'Restore purchases',
    this.backgroundBuilder,
    this.editingSavePercentageText = defaultEditingSavePercentageText,
    this.editingTrialDaysText = defaultTrialDaysText,
    this.features = const[],
    PackagesTextConfig? packagesTextConfig,
  }) : packagesTextConfig = packagesTextConfig ?? PackagesTextConfig.defaultConfig();
  
}

String defaultEditingSavePercentageText(int percentage) {
  return 'Save $percentage%';
}
String defaultTrialDaysText(int trialDays,PeriodUnit periodUnit ) {
  

String type = "day";

switch (periodUnit) {
  case PeriodUnit.day:
    type = PeriodUnit.day.name;
    break;
  case PeriodUnit.week:
    type = PeriodUnit.week.name;
    break;
  case PeriodUnit.month:
    type = PeriodUnit.month.name;
    break;
  case PeriodUnit.year:
    type = PeriodUnit.year.name;
    break;
  
  default:
  type = "day";
}
  return 'Free $trialDays $type trial';
}
