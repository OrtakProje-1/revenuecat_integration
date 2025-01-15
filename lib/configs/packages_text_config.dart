class PackagesTextConfig {
  String unknowPackageText;
  String customPackageText;
  String lifetimePackageText;
  String annualPackageText;
  String sixMonthPackageText;
  String threeMonthPackageText;
  String twoMonthPackageText;
  String monthlyPackageText;
  String weeklyPackageText;
  PackagesTextConfig({
    this.unknowPackageText = 'Unknown package',
    this.customPackageText = 'Custom package',
    this.lifetimePackageText = 'Lifetime package',
    this.annualPackageText = 'Annual package',
    this.sixMonthPackageText = 'Six month package',
    this.threeMonthPackageText = 'Three month package',
    this.twoMonthPackageText = 'Two month package',
    this.monthlyPackageText = 'Monthly package',
    this.weeklyPackageText = 'Weekly package',
  });

  PackagesTextConfig copyWith({
    String? unknowPackageText,
    String? customPackageText,
    String? lifetimePackageText,
    String? annualPackageText,
    String? sixMonthPackageText,
    String? threeMonthPackageText,
    String? twoMonthPackageText,
    String? monthlyPackageText,
    String? weeklyPackageText,
  }) {
    return PackagesTextConfig(
      unknowPackageText: unknowPackageText ?? this.unknowPackageText,
      customPackageText: customPackageText ?? this.customPackageText,
      lifetimePackageText: lifetimePackageText ?? this.lifetimePackageText,
      annualPackageText: annualPackageText ?? this.annualPackageText,
      sixMonthPackageText: sixMonthPackageText ?? this.sixMonthPackageText,
      threeMonthPackageText: threeMonthPackageText ?? this.threeMonthPackageText,
      twoMonthPackageText: twoMonthPackageText ?? this.twoMonthPackageText,
      monthlyPackageText: monthlyPackageText ?? this.monthlyPackageText,
      weeklyPackageText: weeklyPackageText ?? this.weeklyPackageText,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'unknowPackageText': unknowPackageText,
      'customPackageText': customPackageText,
      'lifetimePackageText': lifetimePackageText,
      'annualPackageText': annualPackageText,
      'sixMonthPackageText': sixMonthPackageText,
      'threeMonthPackageText': threeMonthPackageText,
      'twoMonthPackageText': twoMonthPackageText,
      'monthlyPackageText': monthlyPackageText,
      'weeklyPackageText': weeklyPackageText,
    };
  }

  factory PackagesTextConfig.defaultConfig() {
    return PackagesTextConfig();
  }
}
