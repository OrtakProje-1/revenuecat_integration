import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:revenuecat_integration/models/lottie_widget_config.dart';

class LottieWidget extends StatefulWidget {
  final LottieWidgetConfig config;
  const LottieWidget({
    super.key,
    required this.config,
  });

  @override
  State<LottieWidget> createState() => _LottieWidgetState();
}

class _LottieWidgetState extends State<LottieWidget> with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      (widget.config.package ?? "").isNotEmpty ? "packages/${widget.config.package}/${widget.config.asset}" : widget.config.asset,
      fit: BoxFit.cover,
      width: widget.config.size.width,
      height: widget.config.size.height,
      repeat: widget.config.repeat,
      reverse: widget.config.repeat,
      controller: animationController,
      alignment: Alignment.bottomCenter,
      onLoaded: (s) {
        animationController = animationController..duration = s.duration;
        Future.delayed(Duration(milliseconds: widget.config.delayMs), () {
          if (widget.config.repeat) {
            animationController.repeat(reverse: widget.config.reverse);
          } else {
            animationController.forward();
          }
        });
      },
    );
  }
}
