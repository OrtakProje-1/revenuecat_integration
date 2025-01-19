import 'package:flutter/material.dart';
import 'package:revenuecat_integration/revenuecat_integration.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/widgets/lottie_widget.dart';

class PremiumButton extends StatelessWidget {
  final SubscriptionScreenUiConfig? uiConfig;
  final DesignTemplateType? templateType;
  const PremiumButton({super.key, this.uiConfig, this.templateType});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => RevenuecatIntegrationService.instance.goToSubscriptionPage(context, uiConfig: uiConfig, templateType: templateType ?? DesignTemplateType.custom),
        icon: const LottieWidget(asset: "premium"));
  }
}
