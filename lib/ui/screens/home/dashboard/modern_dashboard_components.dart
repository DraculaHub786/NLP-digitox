import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/glass_card.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  StyledText(
                    subtitle!,
                    fontSize: 12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class ModernListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const ModernListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileColor = iconColor ?? colorScheme.primary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: GlassTokens.radiusCard,
      tint: tileColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tileColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
            ),
            child: Icon(
              icon,
              color: tileColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  StyledText(
                    subtitle!,
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          trailing ??
              (showChevron
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                        FluentIcons.chevron_right_20_regular,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                        size: 22,
                      ),
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class ModernSettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ModernSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileColor = iconColor ?? colorScheme.primary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: GlassTokens.radiusCard,
      tint: tileColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tileColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
            ),
            child: Icon(
              icon,
              color: tileColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  StyledText(
                    subtitle!,
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            flex: 0,
            child: Transform.scale(
              scale: 0.85,
              child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: colorScheme.primary,
                activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernCategorySection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ModernCategorySection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(title: title),
        const SizedBox(height: 12),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            )),
      ],
    );
  }
}
