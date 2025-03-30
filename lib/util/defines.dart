import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/period_unit.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

typedef SubscriptionScreenBackgroundBuilder = Widget Function(BuildContext context, double height, double width);
typedef SubscriptionScreenForegroundBuilder = Widget Function(BuildContext context, List<Package> packages, bool isError, bool isLoading);

typedef EditableText = String Function(int value);
typedef TrialDaysEditableText = String Function(int value, PeriodUnit periodUnit);

enum DesignTemplateType { custom, defaultUI }
