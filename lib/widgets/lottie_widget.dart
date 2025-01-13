import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatefulWidget {
  final String asset;
  final Size size;
  final bool repeat;
  final int delayMs;
  final bool reverse;
  const LottieWidget({
    super.key,
    required this.asset,
    this.delayMs = 0,
    this.reverse = false,
    this.size = const Size(40, 40),
    this.repeat = false,
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
  Widget build(BuildContext context) {
    
    return Lottie.asset(
      "assets/animation/${widget.asset}.json",
      fit: BoxFit.cover,
      width: widget.size.width,
      height: widget.size.height,
      repeat: widget.repeat,
      reverse: widget.repeat,
      controller: animationController,
      alignment: Alignment.bottomCenter,
      onLoaded: (s) {
        animationController = animationController..duration = s.duration;
        Future.delayed(Duration(milliseconds: widget.delayMs), () {
          if (widget.repeat) {
            animationController.repeat(reverse: widget.reverse);
          } else {
            animationController.forward();
          }
        });
      },
    );
  }
}
