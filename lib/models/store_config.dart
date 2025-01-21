// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:revenuecat_integration/util/defines.dart';

class StoreConfig {
  final String entitlement;
  final DesignTemplateType templateType;
  final PurchasesConfiguration configuration;

  StoreConfig({
    required this.entitlement,
    required this.configuration,
    this.templateType = DesignTemplateType.custom,
  });
}
