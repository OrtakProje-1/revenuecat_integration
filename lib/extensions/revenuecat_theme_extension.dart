// Custom theme extension for subscription screen
import 'package:flutter/material.dart';

class RevenuecatThemeExtension extends ThemeExtension<RevenuecatThemeExtension> {
  final Color packageSelectedBg;
  final Color packageUnselectedBg;
  final Color packageBorderColor;
  final Color popularBadgeBg;
  final Color popularBadgeText;
  final Color trialText;
  final Color saveText;

  RevenuecatThemeExtension({
    required this.packageSelectedBg,
    required this.packageUnselectedBg,
    required this.packageBorderColor,
    required this.popularBadgeBg,
    required this.popularBadgeText,
    required this.trialText,
    required this.saveText,
  });

  static final light = RevenuecatThemeExtension(
    packageSelectedBg: const Color(0xffffea00).withOpacity(0.16),
    packageUnselectedBg: const Color(0xffffea00).withOpacity(0.08),
    packageBorderColor: const Color(0xffe68816),
    popularBadgeBg: const Color(0xffe68816),
    popularBadgeText: Colors.white,
    trialText: const Color(0xffe68816),
    saveText: const Color(0xffffea00),
  );

  static final dark = RevenuecatThemeExtension(
    packageSelectedBg: Colors.blue.shade900,
    packageUnselectedBg: Colors.grey.shade900,
    packageBorderColor: Colors.blue,
    popularBadgeBg: Colors.blue,
    popularBadgeText: Colors.white,
    trialText: Colors.green,
    saveText: Colors.orange,
  );

  @override
  ThemeExtension<RevenuecatThemeExtension> copyWith({
  
    Color? packageSelectedBg,
    Color? packageUnselectedBg,
    Color? packageBorderColor,
    Color? popularBadgeBg,
    Color? popularBadgeText,
    Color? trialText,
    Color? saveText,
  }) {
    return RevenuecatThemeExtension(
      packageSelectedBg: packageSelectedBg ?? this.packageSelectedBg,
      packageUnselectedBg: packageUnselectedBg ?? this.packageUnselectedBg,
      packageBorderColor: packageBorderColor ?? this.packageBorderColor,
      popularBadgeBg: popularBadgeBg ?? this.popularBadgeBg,
      popularBadgeText: popularBadgeText ?? this.popularBadgeText,
      trialText: trialText ?? this.trialText,
      saveText: saveText ?? this.saveText,
    );
  }

  @override
  ThemeExtension<RevenuecatThemeExtension> lerp(
    ThemeExtension<RevenuecatThemeExtension>? other,
    double t,
  ) {
    if (other is! RevenuecatThemeExtension) return this;
    return RevenuecatThemeExtension(
      packageSelectedBg: Color.lerp(packageSelectedBg, other.packageSelectedBg, t)!,
      packageUnselectedBg: Color.lerp(packageUnselectedBg, other.packageUnselectedBg, t)!,
      packageBorderColor: Color.lerp(packageBorderColor, other.packageBorderColor, t)!,
      popularBadgeBg: Color.lerp(popularBadgeBg, other.popularBadgeBg, t)!,
      popularBadgeText: Color.lerp(popularBadgeText, other.popularBadgeText, t)!,
      trialText: Color.lerp(trialText, other.trialText, t)!,
      saveText: Color.lerp(saveText, other.saveText, t)!,
    );
  }
}
