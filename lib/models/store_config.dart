import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:revenuecat_integration/util/defines.dart';

class StoreConfig {
  final Store store;
  final String apiKey;
  final String entitlement;
  final TemplateType templateType;

  StoreConfig({required this.store, required this.apiKey, required this.entitlement, this.templateType = TemplateType.custom});

  bool isForAppleStore() => store == Store.appStore;

  bool isForGooglePlay() => store == Store.playStore;

  bool isForAmazonAppstore() => store == Store.amazon;
}
