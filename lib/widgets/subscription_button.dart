import 'package:flutter/material.dart';
import 'package:revenuecat_integration/models/lottie_widget_config.dart';
import 'package:revenuecat_integration/revenuecat_integration.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/widgets/lottie_widget.dart';

class SubscriptionButton extends StatelessWidget {
  final SubscriptionScreenUiConfig? uiConfig;
  final DesignTemplateType? templateType;
  final LottieWidgetConfig? lottieWidgetConfig;
  final ButtonStyle? style;
  const SubscriptionButton({super.key, this.uiConfig, this.templateType, this.lottieWidgetConfig, this.style});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => RevenuecatIntegrationService.instance.goToSubscriptionPage(context, uiConfig: uiConfig, templateType: templateType ?? DesignTemplateType.custom),
      icon: LottieWidget(config: lottieWidgetConfig ?? LottieWidgetConfig(asset: "assets/animations/premium.json", package: "revenuecat_integration")),
      style: style,
    );
  }
}
