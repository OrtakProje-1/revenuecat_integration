import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem({super.key, required this.title, this.icon, this.description, this.titleStyle, this.descriptionStyle});
  final String title;
  final IconData? icon;
  final String? description;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
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
