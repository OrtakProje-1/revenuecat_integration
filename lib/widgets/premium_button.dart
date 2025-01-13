import 'package:flutter/material.dart';
import 'package:revenuecat_integration/widgets/lottie_widget.dart';
import 'package:revenuecat_integration/widgets/subscription_screen.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionScreen(),
              ),
            ),
        icon: const LottieWidget(asset: "premium"));
  }
}
