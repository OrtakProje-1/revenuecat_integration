// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class RevenueCatIntegrationTheme {
  final Color? packageSelectedBg;
  final Color? packageUnselectedBg;
  final Color? packageBorderColor;
  final Color? popularBadgeBg;
  final Color? popularBadgeText;
  final Color? trialText;
  final Color? saveText;
  final Color? closeButton;
  final Color? closeButtonBg;
  final Color? packageTextColor;
  final Color? packageRadioColor;
  final Color? titleColor;
  final Color? subTitleColor;
  final Color? purchaseButtonColor;
  final Color? purchaseButtonTextColor;
  final Color? backgroundColor;
  final Color? errorColor;

  RevenueCatIntegrationTheme({
    this.packageSelectedBg,
    this.packageUnselectedBg,
    this.packageBorderColor,
    this.popularBadgeBg,
    this.popularBadgeText,
    this.trialText,
    this.saveText,
    this.closeButton,
    this.closeButtonBg,
    this.packageTextColor,
    this.packageRadioColor,
    this.titleColor,
    this.subTitleColor,
    this.purchaseButtonColor,
    this.purchaseButtonTextColor,
    this.backgroundColor,
    this.errorColor,
  });

  RevenueCatIntegrationTheme copyWith({
    Color? packageSelectedBg,
    Color? packageUnselectedBg,
    Color? packageBorderColor,
    Color? popularBadgeBg,
    Color? popularBadgeText,
    Color? trialText,
    Color? saveText,
    Color? closeButton,
    Color? closeButtonBg,
    Color? packageTextColor,
    Color? packageRadioColor,
    Color? titleColor,
    Color? subTitleColor,
    Color? purchaseButtonColor,
    Color? purchaseButtonTextColor,
    Color? backgroundColor,
    Color? errorColor,
  }) {
    return RevenueCatIntegrationTheme(
      packageSelectedBg: packageSelectedBg ?? this.packageSelectedBg,
      packageUnselectedBg: packageUnselectedBg ?? this.packageUnselectedBg,
      packageBorderColor: packageBorderColor ?? this.packageBorderColor,
      popularBadgeBg: popularBadgeBg ?? this.popularBadgeBg,
      popularBadgeText: popularBadgeText ?? this.popularBadgeText,
      trialText: trialText ?? this.trialText,
      saveText: saveText ?? this.saveText,
      closeButton: closeButton ?? this.closeButton,
      closeButtonBg: closeButtonBg ?? this.closeButtonBg,
      packageTextColor: packageTextColor ?? this.packageTextColor,
      packageRadioColor: packageRadioColor ?? this.packageRadioColor,
      titleColor: titleColor ?? this.titleColor,
      subTitleColor: subTitleColor ?? this.subTitleColor,
      purchaseButtonColor: purchaseButtonColor ?? this.purchaseButtonColor,
      purchaseButtonTextColor: purchaseButtonTextColor ?? this.purchaseButtonTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  // static final light = RevenueCatIntegrationTheme(
  //   packageSelectedBg: const Color(0xffffea00).withAlpha(40),
  //   packageUnselectedBg: const Color(0xffffea00).withAlpha(20),
  //   packageBorderColor: const Color(0xffe68816),
  //   popularBadgeBg: const Color(0xffe68816),
  //   popularBadgeText: Colors.white,
  //   trialText: const Color(0xffe68816),
  //   saveText: const Color(0xffffea00),
  //   errorColor: Colors.red.shade400,
  // );

  // static final dark = RevenueCatIntegrationTheme(
  //   packageSelectedBg: Colors.blue.shade900,
  //   packageUnselectedBg: Colors.grey.shade900,
  //   packageBorderColor: Colors.blue,
  //   popularBadgeBg: Colors.blue,
  //   popularBadgeText: Colors.white,
  //   trialText: Colors.green,
  //   saveText: Colors.orange,
  //   errorColor: Colors.red.shade800,
  // );

  RevenueCatIntegrationTheme lerp(
    RevenueCatIntegrationTheme? other,
    double t,
  ) {
    if (other is! RevenueCatIntegrationTheme) return this;
    return RevenueCatIntegrationTheme(
      packageSelectedBg: Color.lerp(packageSelectedBg, other.packageSelectedBg, t)!,
      packageUnselectedBg: Color.lerp(packageUnselectedBg, other.packageUnselectedBg, t)!,
      packageBorderColor: Color.lerp(packageBorderColor, other.packageBorderColor, t)!,
      popularBadgeBg: Color.lerp(popularBadgeBg, other.popularBadgeBg, t)!,
      popularBadgeText: Color.lerp(popularBadgeText, other.popularBadgeText, t)!,
      trialText: Color.lerp(trialText, other.trialText, t)!,
      saveText: Color.lerp(saveText, other.saveText, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
    );
  }
}
