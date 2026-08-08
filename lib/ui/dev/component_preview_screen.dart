import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/glass_nav_bar.dart';
import 'package:nlp_digitox/ui/common/glass_card.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/status_dot.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';

/// Throwaway dev screen (NOT linked to navigation) for visually verifying the
/// Task 2 primitives against the reference images in both light and dark.
class ComponentPreviewScreen extends StatelessWidget {
  const ComponentPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: TreatedBackgroundImage(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GlassCard',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  tint: scheme.primary,
                  elevationLevel: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layered glass surface',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('Gradient fill · gradient border · tinted shadow'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('PillButton',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    PillButton(
                      label: 'Primary',
                      icon: FluentIcons.target_20_filled,
                      onPressed: () {},
                    ),
                    PillButton(
                      label: 'Outlined',
                      outlined: true,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('StatusDot',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    StatusDot(kind: StatusDotKind.good),
                    SizedBox(width: 16),
                    StatusDot(kind: StatusDotKind.warn),
                    SizedBox(width: 16),
                    StatusDot(kind: StatusDotKind.bad),
                  ],
                ),
                const SizedBox(height: 24),

                Text('GlassNavBar',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                GlassNavBar(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                  items: const [
                    PillNavItem(
                      icon: FluentIcons.home_20_regular,
                      filledIcon: FluentIcons.home_20_filled,
                      label: 'Home',
                    ),
                    PillNavItem(
                      icon: FluentIcons.target_20_regular,
                      filledIcon: FluentIcons.target_20_filled,
                      label: 'Focus',
                    ),
                    PillNavItem(
                      icon: FluentIcons.person_20_regular,
                      filledIcon: FluentIcons.person_20_filled,
                      label: 'Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
