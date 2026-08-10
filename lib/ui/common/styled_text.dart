import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  /// Globally used text widget with provided configurations.
  ///
  /// Shades the text color to disabled color if [isSubtitle] is set to TRUE.
  ///
  /// Set [isHeadline] to TRUE to use the Alice serif display face — intended
  /// for titles/headlines only so the app keeps the "Leafora"-style serif
  /// headline + sans body hierarchy. Body copy, buttons and nav labels
  /// should stay on the default sans font.
  const StyledText(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.height,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
    this.isSubtitle = false,
    this.isHeadline = false,
    this.fontSize = 12,
  });

  final String text;
  final bool isSubtitle;
  final bool isHeadline;
  final Color? color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      // semanticsLabel: text,
      style: TextStyle(
        fontFamily: isHeadline ? 'Alice' : null,
        color: color ?? (isSubtitle ? Theme.of(context).disabledColor : null),
        fontSize: fontSize,
        fontWeight: fontWeight ?? (isHeadline ? FontWeight.w600 : null),
        height: height,
        overflow: overflow,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
