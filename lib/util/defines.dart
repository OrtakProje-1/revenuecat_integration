import 'package:flutter/material.dart';
import 'package:revenuecat_integration/revenuecat_integration.dart';

typedef SubscriptionScreenBackgroundBuilder = Widget Function(BuildContext context, double height, double width);

typedef EditableText = String Function(int value);
typedef TrialDaysEditableText = String Function(int value,PeriodUnit periodUnit );

enum DesignTemplateType { custom, defaultUI }