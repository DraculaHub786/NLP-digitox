// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';

/// Opens modal bottom sheet with the passed sliver body
///
/// [initialSize] should be between 0-1
Future<void> showDefaultBottomSheet({
  required BuildContext context,
  required Widget sliverBody,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12),
  Widget? header,
  String? headerTitle,
  double initialSize = 0.5,
}) async =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(
        duration: AppConstants.defaultAnimDuration,
        curve: Curves.easeOutBack,
        reverseDuration: AppConstants.defaultAnimDuration,
        reverseCurve: Curves.easeOutBack.flipped,
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        builder: (context, scrollController) => Padding(
          padding: padding,
          child: Column(
            children: [
              /// Header
              headerTitle != null
                  ? ContentSectionHeader(
                      title: headerTitle,
                      padding: const EdgeInsets.only(bottom: 12),
                    )
                  : header ?? 0.vBox,

              /// Body
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    sliverBody,
                    const SliverTabsBottomPadding(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
