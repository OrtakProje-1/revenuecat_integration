// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class LottieWidgetConfig {
  final String asset;
  final String? package;
  final Size size;
  final bool repeat;
  final int delayMs;
  final bool reverse;
  LottieWidgetConfig({
    required this.asset,
    this.package,
    this.size = const Size(40, 40),
    this.repeat = false,
    this.delayMs = 0,
    this.reverse = false,
  });
}
