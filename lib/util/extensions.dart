import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  Future<T?> push<T>([Widget? page, Route<T>? route]) {
    return Navigator.push<T>(this, page != null ? MaterialPageRoute(builder: (_) => page) : route!);
  }

  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.pushAndRemoveUntil<T>(this, MaterialPageRoute(builder: (_) => page), (route) => false);
  }

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension NumExt on num {
  SizedBox get width => SizedBox(width: toDouble());
  SizedBox get height => SizedBox(height: toDouble());
}

extension StringExt on String {
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  bool get isPhoneNumber => RegExp(r'^\d{10}$').hasMatch(this);
  bool get isPassword => RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(this);
}

extension ObjectExt on Object? {
  bool get isNull => this == null;
  bool get isNotNull => this != null;
}
