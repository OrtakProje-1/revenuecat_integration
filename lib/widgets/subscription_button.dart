import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:revenuecat_integration/models/lottie_widget_config.dart';
import 'package:revenuecat_integration/revenuecat_integration.dart';
import 'package:revenuecat_integration/util/defines.dart';
import 'package:revenuecat_integration/widgets/lottie_widget.dart';

class SubscriptionButton extends StatelessWidget {
  final SubscriptionScreenUiConfig? uiConfig;
  final DesignTemplateType? templateType;
  final LottieWidgetConfig? lottieWidgetConfig;
  final ButtonStyle? style;
  final RevenuecatIntegrationTheme? theme;
  final ValueChanged<PaywallResult?>? onPaywallResult;
  const SubscriptionButton({super.key, this.uiConfig, this.templateType, this.lottieWidgetConfig, this.style, this.theme, this.onPaywallResult});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        var paywallResult = await RevenuecatIntegrationService.instance.goToSubscriptionPage(context, uiConfig: uiConfig, templateType: templateType ?? DesignTemplateType.custom);
        onPaywallResult?.call(paywallResult);
      },
      icon: LottieWidget(config: lottieWidgetConfig ?? LottieWidgetConfig(asset: "assets/animations/premium.json", package: "revenuecat_integration")),
      style: style,
    );
  }
}
