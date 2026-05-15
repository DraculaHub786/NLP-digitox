
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/providers/glance_cards_provider.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/glance_cards/data_mobile_glance.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/glance_cards/data_total_glance.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/glance_cards/data_wifi_glance.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/glance_cards/focus_lifetime_glance.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/glance_cards/focus_monthly_glance.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/glance_cards/focus_weekly_glance.dart';

class GlanceCardsGrid extends ConsumerWidget {
  const GlanceCardsGrid({super.key});

  Widget _buildCard(GlanceCard card) {
    switch (card) {
      case GlanceCard.dataTotal:
        return const DataTotalGlance();
      case GlanceCard.dataMobile:
        return const DataMobileGlance();
      case GlanceCard.dataWifi:
        return const DataWifiGlance();
      case GlanceCard.focusWeekly:
        return const FocusWeeklyGlance();
      case GlanceCard.focusMonthly:
        return const FocusMonthlyGlance();
      case GlanceCard.focusLifetime:
        return const FocusLifetimeGlance();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(glanceCardsProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: constraints.maxWidth / 220,
        padding: const EdgeInsets.only(top: 4),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        physics: const NeverScrollableScrollPhysics(),
        children: cards.map((card) => _buildCard(card)).toList(),
      );
    });
  }
}
