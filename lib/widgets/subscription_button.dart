import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:revenue_cat_integration/configs/subscription_screen_ui_config.dart';
import 'package:revenue_cat_integration/models/lottie_widget_config.dart';
import 'package:revenue_cat_integration/models/revenue_cat_integration_theme.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import 'package:revenue_cat_integration/util/defines.dart';
import 'package:revenue_cat_integration/widgets/lottie_widget.dart';

class SubscriptionButton extends StatelessWidget {
  final SubscriptionScreenUiConfig? uiConfig;
  final DesignTemplateType? templateType;
  final LottieWidgetConfig? lottieWidgetConfig;
  final ButtonStyle? style;
  final RevenueCatIntegrationTheme? theme;
  final ValueChanged<PaywallResult?>? onPaywallResult;
  const SubscriptionButton({super.key, this.uiConfig, this.templateType, this.lottieWidgetConfig, this.style, this.theme, this.onPaywallResult});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        var paywallResult = await RevenueCatIntegrationService.instance.goToSubscriptionPage(context, uiConfig: uiConfig, theme: theme, templateType: templateType ?? DesignTemplateType.custom);
        onPaywallResult?.call(paywallResult);
      },
      icon: LottieWidget(config: lottieWidgetConfig ?? LottieWidgetConfig(asset: "assets/animations/premium.json", package: "revenue_cat_integration")),
      style: style,
    );
  }
}
