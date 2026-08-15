import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/system/mindful_settings_provider.dart';
import 'package:nlp_digitox/ui/common/profile_avatar.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/input_field_dialog.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class GreetingsUsername extends ConsumerWidget {
  const GreetingsUsername({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _editUserName(
      BuildContext context, WidgetRef ref, String initialName) async {
    final userName = await showUsernameInputDialog(
      context: context,
      heroTag: HeroTags.editUsernameTag,
      initialText: initialName,
    );

    if (userName == null) return;
    ref.read(mindfulSettingsProvider.notifier).changeUsername(userName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username =
        ref.watch(mindfulSettingsProvider.select((v) => v.username));
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Left side - Greeting and username
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: StyledText(
                      _getGreeting(),
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '👋',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              DefaultHero(
                tag: HeroTags.editUsernameTag,
                child: InkWell(
                  onLongPress: () => _editUserName(context, ref, username),
                  onTap: () => context.showSnackAlert(
                    context.locale.username_snack_alert,
                    icon: FluentIcons.edit_20_filled,
                  ),
                  splashColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: StyledText(
                          username,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          isHeadline: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                        ),
                        child: Icon(
                          FluentIcons.edit_16_regular,
                          size: 14,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Right side - Profile pic shortcut
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.profilePath,
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            child: const ProfileAvatar(size: 40),
          ),
        ),
      ],
    );
  }
}
