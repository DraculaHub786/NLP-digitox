
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/utils/widget_utils.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UsageGlanceCard extends StatelessWidget {
  const UsageGlanceCard({
    super.key,
    required this.title,
    required this.info,
    this.icon,
    this.onTap,
    this.badge,
    this.isPrimary = false,
    this.position = ItemPosition.mid,
  });

  final IconData? icon;
  final bool isPrimary;
  final String title;
  final String info;
  final VoidCallback? onTap;
  final ItemPosition position;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final mini = icon == null;

    return RoundedContainer(
      circularRadius: 6,
      borderRadius: getBorderRadiusFromPosition(position),
      padding: const EdgeInsets.all(16),
      color:
          isPrimary ? Theme.of(context).colorScheme.secondaryContainer : null,
      onPressed: onTap,
      child: Stack(
        children: [
          /// Usage
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mini) Icon(icon),
              mini ? 0.vBox : 14.vBox,
              StyledText(
                title,
                fontSize: 12,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Skeleton.leaf(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: StyledText(
                    info.isEmpty ? " " : info,
                    fontSize: 24,
                    maxLines: 1,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          /// Badge
          Align(
            alignment: Alignment.topRight,
            child: badge ?? 0.hBox,
          )
        ],
      ),
    );
  }
}
