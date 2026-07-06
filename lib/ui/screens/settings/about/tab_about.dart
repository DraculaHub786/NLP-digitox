
import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/ui/common/breathing_widget.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class TabAbout extends ConsumerWidget {
  const TabAbout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appVersion = MethodChannelService.instance.deviceInfo.mindfulVersion;
    final dbVersion = DriftDbService.instance.driftDb.schemaVersion;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        /// Hero Section - App Info Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  /// Breathing logo
                  BreathingWidget(
                    dimension: min(200, MediaQuery.of(context).size.width * 0.45),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  20.vBox,

                  StyledText(
                    "NLP-Digitox",
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  8.vBox,

                  StyledText(
                    context.locale.mindful_tagline,
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    textAlign: TextAlign.justify,
                  ),
                  16.vBox,

                  /// Version badges row
                  // Use Wrap + center alignment so badges don't overflow on narrow screens
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(context, appVersion, FluentIcons.apps_20_regular, colorScheme),
                      _buildBadge(context, 'db-v$dbVersion', FluentIcons.database_20_regular, colorScheme),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Support & Community Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModernSectionHeader(title: 'Support & Community'),
                12.vBox,
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      /// Donation
                      _buildActionTile(
                        context: context,
                        icon: FluentIcons.handshake_20_regular,
                        iconColor: colorScheme.primary,
                        title: context.locale.donation_card_title,
                        subtitle: context.locale.donation_card_info,
                        trailing: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          icon: const Icon(FluentIcons.heart_20_filled, size: 16),
                          label: Text(context.locale.donation_card_button_donate),
                          onPressed: () {},
                        ),
                      ),
                      8.vBox,

                      /// Changelog
                      ModernListTile(
                        title: context.locale.changelog_tile_title,
                        subtitle: context.locale.changelog_tile_subtitle,
                        icon: FluentIcons.slide_text_20_regular,
                        iconColor: colorScheme.primary,
                        showChevron: true,
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.changeLogsPath),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        24.vSliverBox,

        /// Contribute Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModernSectionHeader(title: 'Contribute'),
                12.vBox,
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      ModernListTile(
                        title: context.locale.github_tile_title,
                        subtitle: context.locale.github_tile_subtitle,
                        icon: FluentIcons.code_20_regular,
                        iconColor: colorScheme.primary,
                        showChevron: true,
                        onTap: () => MethodChannelService.instance.launchUrl(AppConstants.githubUrl),
                      ),
                      8.vBox,
                      ModernListTile(
                        title: context.locale.report_issue_tile_title,
                        subtitle: context.locale.redirected_to_github_subtitle,
                        icon: FluentIcons.bug_20_regular,
                        iconColor: colorScheme.secondary,
                        showChevron: true,
                        onTap: () => MethodChannelService.instance.launchUrl(AppConstants.githubIssueDirectUrl),
                      ),
                      8.vBox,
                      ModernListTile(
                        title: context.locale.suggest_idea_tile_title,
                        subtitle: context.locale.redirected_to_github_subtitle,
                        icon: FluentIcons.lightbulb_filament_20_regular,
                        iconColor: colorScheme.tertiary,
                        showChevron: true,
                        onTap: () => MethodChannelService.instance.launchUrl(AppConstants.githubSuggestionDirectUrl),
                      ),
                      8.vBox,
                      ModernListTile(
                        title: context.locale.write_email_tile_title,
                        subtitle: context.locale.write_email_tile_subtitle,
                        icon: FluentIcons.mail_20_regular,
                        iconColor: colorScheme.primary,
                        showChevron: true,
                        onTap: () => MethodChannelService.instance.launchUrl(AppConstants.supportEmailUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        24.vSliverBox,

        /// Privacy Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FluentIcons.shield_keyhole_20_regular,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      12.hBox,
                      StyledText(
                        context.locale.privacy_policy_heading,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  12.vBox,
                  StyledText(
                    context.locale.privacy_policy_info,
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    textAlign: TextAlign.justify,
                  ),
                  16.vBox,
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      icon: const Icon(FluentIcons.info_20_regular, size: 18),
                      label: Text(context.locale.more_details_button),
                      onPressed: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        32.vSliverBox,

        const SliverTabsBottomPadding(),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          6.hBox,
          StyledText(
            label,
            fontSize: 12,
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          16.hBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                if (subtitle != null) ...[
                  2.vBox,
                  StyledText(
                    subtitle,
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            8.hBox,
            Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ],
        ],
      ),
    );
  }
}
