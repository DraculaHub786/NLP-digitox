// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class ContentSectionHeader extends StatelessWidget {
  /// Global title text with primary accent mainly used as a header for different sections in a list of widgets
  const ContentSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(top: 18, bottom: 12),
    this.alignment = Alignment.centerLeft,
  });

  final String title;
  final EdgeInsets padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: alignment,
      child: StyledText(
        title,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
