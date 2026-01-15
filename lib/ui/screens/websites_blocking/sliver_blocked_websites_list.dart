// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/ui/common/empty_list_indicator.dart';
import 'package:nlp_digitox/ui/common/sliver_implicitly_animated_list.dart';
import 'package:nlp_digitox/ui/screens/websites_blocking/website_tile.dart';

class SliverBlockedWebsitesList extends ConsumerWidget {
  const SliverBlockedWebsitesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedWebsites = ref.watch(wellBeingProvider.select(
      (v) => v.blockedWebsites,
    ));
    final nsfwWebsites = ref.watch(wellBeingProvider.select(
      (v) => v.nsfwWebsites,
    ));

    final allWebsites = {...nsfwWebsites.reversed, ...blockedWebsites.reversed};

    return allWebsites.isNotEmpty
        ? SliverImplicitlyAnimatedList(
            itemExtent: 64,
            items: allWebsites.toList(),
            keyBuilder: (item) => item,
            itemBuilder: (context, i, item, position) => WebsiteTile(
              websitehost: item,
              isRemovable: !nsfwWebsites.contains(item),
              position: position,
            ),
          )
        : EmptyListIndicator(
            info: context.locale.blocked_websites_empty_list_hint,
          ).sliver;
  }
}
