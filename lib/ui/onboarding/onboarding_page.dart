
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.imgArtPath,
    required this.title,
    required this.description,
    this.showLogo = false,
    this.bottomPadding = -1,
  });

  final String imgArtPath;
  final String title;
  final String description;

  /// Show the square logo mark above the illustration (used on the
  /// welcome page, which is the first thing seen after the splash).
  final bool showLogo;

  /// Bottom padding under the text block. Defaults to a responsive value
  /// (~12% of screen height). The old flat 148px left a large dead gap on
  /// tall screens, which read as "content only on half the screen".
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final responsiveBottomPadding = bottomPadding < 0
        ? MediaQuery.sizeOf(context).height * 0.12
        : bottomPadding;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: responsiveBottomPadding,
        top: 24,
      ),
      child: Column(
        // `spaceBetween` with only two visual blocks stranded the
        // illustration at the top and text at the bottom with a huge
        // empty band between them. A top-aligned flow with explicit
        // gaps fills the screen naturally on every device height.
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showLogo) ...[
            /// Logo mark — same square "prev" artwork used on the splash.
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo-prev.png',
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            24.vBox,
          ],

          /// Illustration
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              imgArtPath,
              fit: BoxFit.contain,
            ),
          ),

          40.vBox,

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Title — serif display (Alice)
              StyledText(
                title,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                isHeadline: true,
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.primary,
              ),
              4.vBox,

              /// Description
              StyledText(
                description,
                fontSize: 16,
                color: Theme.of(context).hintColor,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
