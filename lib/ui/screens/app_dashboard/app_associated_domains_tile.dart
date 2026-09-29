import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/models/app_info.dart';
import 'package:nlp_digitox/providers/restrictions/apps_restrictions_provider.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/app_associated_domains_dialog.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

/// Lets the user attach the websites an app opens (e.g. "instagram.com" for
/// Instagram) so those sites are blocked automatically the moment this app's
/// own usage limit is actually hit.
///
/// Domains only ever come from what the user enters here — nothing is
/// hardcoded anywhere in the block pipeline.
class AppAssociatedDomainsTile extends ConsumerWidget {
  const AppAssociatedDomainsTile({
    required this.appInfo,
    super.key,
  });

  final AppInfo appInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(
      appsRestrictionsProvider.select(
        (v) => v[appInfo.packageName]?.associatedDomains ?? const <String>[],
      ),
    );

    return DefaultHero(
      tag: HeroTags.appAssociatedDomainsTileTag(appInfo.packageName),
      child: DefaultListTile(
        enabled: !appInfo.isImpSysApp,
        position: ItemPosition.mid,
        titleText: context.locale.app_associated_domains_tile_title,
        subtitleText: domains.isEmpty
            ? context.locale.app_associated_domains_tile_subtitle
            : context.locale
                .app_associated_domains_tile_subtitle_count(domains.length),
        leadingIcon: FluentIcons.globe_20_regular,
        trailing: domains.isEmpty
            ? StyledText(
                context.locale.app_limit_status_not_set,
                isSubtitle: true,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StyledText(
                  domains.length.toString(),
                  fontSize: 16,
                ),
              ),
        onPressed: () => _editDomains(context, ref, domains),
      ),
    );
  }

  Future<void> _editDomains(
    BuildContext context,
    WidgetRef ref,
    List<String> domains,
  ) async {
    final updated = await showAppAssociatedDomainsDialog(
      context: context,
      heroTag: HeroTags.appAssociatedDomainsTileTag(appInfo.packageName),
      appName: appInfo.name,
      initialDomains: domains,
    );

    if (updated == null) return;

    await ref
        .read(appsRestrictionsProvider.notifier)
        .updateAssociatedDomains(appInfo.packageName, updated);
  }
}
