
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SliverPrimaryActionContainer extends StatelessWidget {
  /// [RoundedContainer] with primary accent and a CTA button
  const SliverPrimaryActionContainer({
    super.key,
    required this.isVisible,
    required this.title,
    required this.information,
    required this.icon,
    this.margin = EdgeInsets.zero,
    this.positiveBtn,
    this.negativeBtn,
    this.radius,
  });

  final bool isVisible;
  final String title;
  final String information;
  final EdgeInsets margin;
  final IconData icon;
  final Widget? positiveBtn;
  final Widget? negativeBtn;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedPaintExtent(
      duration: AppConstants.defaultAnimDuration,
      curve: Curves.easeOutBack,
      child: SliverVisibility(
        visible: isVisible,
        sliver: RoundedContainer(
          borderRadius: radius ?? BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.secondaryContainer,
          padding: const EdgeInsets.all(16),
          margin: margin,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),

                6.vBox,

                /// title
                StyledText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

                2.vBox,

                ///  info
                StyledText(
                  information,
                  fontSize: 12,
                ),

                12.vBox,

                // A Row with a Spacer gave both buttons their full
                // intrinsic width with nothing able to shrink, so on
                // narrow screens the two together overflowed past the
                // right edge. Wrap lets the second button drop to its
                // own line instead of overflowing.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (negativeBtn != null) negativeBtn!,
                    if (positiveBtn != null) positiveBtn!,
                  ],
                ),
              ],
            ),
          ),
        ).sliver,
      ),
    );
  }
}
