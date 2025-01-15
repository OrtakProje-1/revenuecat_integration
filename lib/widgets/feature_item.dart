import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem({super.key, required this.title, this.icon, this.description, this.titleStyle, this.descriptionStyle, this.isDense = true});
  final String title;
  final Icon? icon;
  final String? description;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: isDense,
      leading: icon,
      title: Text(title, style: titleStyle),
      subtitle: description != null
          ? Text(
              description!,
              style: descriptionStyle,
            )
          : null,
    );
  }
}
