import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/utils/widget_utils.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// Global list tile used throughout the app
///
/// Alternative to [ListTile] as the list tile widget have some artifact when scrolling while in focus state
class DefaultListTile extends StatelessWidget {
  const DefaultListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.titleText,
    this.subtitleText,
    this.color,
    this.accent,
    this.onPressed,
    this.switchValue,
    this.isSelected,
    this.position,
    this.margin,
    this.enabled = true,
    this.isPrimary = false,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final IconData? leadingIcon;
  final String? titleText;
  final String? subtitleText;
  final Color? color;
  final Color? accent;
  final bool? switchValue;
  final bool? isSelected;
  final ItemPosition? position;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isPrimary;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: margin ?? const EdgeInsets.only(top: 4),
      borderRadius:
          getBorderRadiusFromPosition(position ?? ItemPosition.none).topLeft.x,
      elevation: 0,
      tint: isPrimary ? Theme.of(context).colorScheme.secondaryContainer : color,
      onTap: enabled ? onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Leading widget
          leadingIcon != null
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled
                        ? (accent ?? colorScheme.primary)
                            .withValues(alpha: 0.14)
                        : colorScheme.onSurface.withValues(alpha: 0.10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    leadingIcon!,
                    size: 20,
                    color: enabled
                        ? (accent ?? colorScheme.primary)
                        : Theme.of(context).hintColor,
                  ),
                )
              : leading ?? 0.hBox,

          /// leading space
          if (leading != null || leadingIcon != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title widget
                titleText != null
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        clipBehavior: Clip.none,
                        child: StyledText(
                          titleText!,
                          fontSize: 16,
                          maxLines: 1,
                          fontWeight: isPrimary ? FontWeight.w500 : null,
                          color: enabled ? accent : Theme.of(context).hintColor,
                        ),
                      )
                    : title ?? 0.vBox,

                /// Subtitle widget
                subtitleText != null
                    ? StyledText(
                        subtitleText!,
                        fontSize: 14,
                        isSubtitle: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : subtitle ?? 0.vBox,
              ],
            ),
          ),

          if (switchValue != null || isSelected != null || trailing != null)
            4.hBox,

          /// Trailing widget
          switchValue != null
              ? IgnorePointer(
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: switchValue ?? false,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AccentPalette.orange,
                      onChanged: (_) {},
                    ),
                  ),
                )
              : isSelected != null
                  ? IgnorePointer(
                      child: Checkbox(
                        value: isSelected,
                        splashRadius: 0,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: enabled ? (_) {} : null,
                      ),
                    )
                  : trailing ?? 0.hBox,
        ],
      ),
    );
  }
}
