
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/ui/common/default_slide_to_remove.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class WebsiteTile extends ConsumerWidget {
  const WebsiteTile({
    super.key,
    required this.websitehost,
    required this.isRemovable,
    this.position,
  });

  final String websitehost;
  final ItemPosition? position;
  final bool isRemovable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    return DefaultHero(
      tag: HeroTags.websiteTileTag(websitehost),
      child: DefaultSlideToRemove(
        key: Key(websitehost),
        position: position ?? ItemPosition.none,
        removable: isRemovable,
        onDismiss: () => ref
            .read(wellBeingProvider.notifier)
            .insertRemoveBlockedSite(websitehost, false),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRemovable
                      ? colorScheme.secondary.withValues(alpha: 0.15)
                      : colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isRemovable
                      ? Icons.language_rounded
                      : Icons.block_rounded,
                  size: 18,
                  color: isRemovable
                      ? colorScheme.secondary
                      : colorScheme.error,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StyledText(
                  websitehost,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRemovable)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
