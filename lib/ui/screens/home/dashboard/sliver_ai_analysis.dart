// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/NLP ditix)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/providers/ai_providers.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:sliver_tools/sliver_tools.dart' as sliver show MultiSliver;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// Dashboard AI section: sentiment + tips cards and a static entry card that
/// opens the dedicated Chat screen. The chat UI itself lives in
/// `ui/screens/chat/chat_screen.dart`.
class SliverAIAnalysis extends ConsumerWidget {
  const SliverAIAnalysis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final sentimentAsync = ref.watch(aiSentimentProvider);
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);

    return sliver.MultiSliver(
      children: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ModernSectionHeader(title: "AI Analysis"),
          ),
        ),

        // Sentiment Analysis and Recommendations Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: sentimentAsync.when(
              data: (sentimentData) => recommendationsAsync.when(
                data: (recommendations) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left half - Sentiment Analysis
                    Expanded(
                      child: SurfaceCard(
                        padding: EdgeInsets.zero,
                        elevation: 1,
                        child: SizedBox(
                          height: 220,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FluentIcons.brain_circuit_20_regular,
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    StyledText(
                                      'Sentiment',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const Spacer(),
                                    // Refresh button
                                    InkWell(
                                      onTap: () async {
                                        AISentimentService.instance
                                            .clearSentimentCache();
                                        ref.invalidate(aiSentimentProvider);
                                        ref.invalidate(aiRecommendationsProvider);
                                        debugPrint(
                                            '🔄 Manually refreshed sentiment analysis');
                                      },
                                      child: Icon(
                                        FluentIcons.arrow_clockwise_20_regular,
                                        size: 14,
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: sentimentData.entries.map(
                                        (entry) {
                                      Color sentimentColor;
                                      IconData sentimentIcon;
                                      switch (entry.key) {
                                        case 'Positive':
                                          sentimentColor =
                                              AccentPalette.trendGood;
                                          sentimentIcon = FluentIcons
                                              .emoji_smile_slight_20_filled;
                                          break;
                                        case 'Neutral':
                                          sentimentColor =
                                              DesignPalette.gold;
                                          sentimentIcon =
                                              FluentIcons.emoji_meh_20_filled;
                                          break;
                                        case 'Negative':
                                          sentimentColor =
                                              AccentPalette.trendBad;
                                          sentimentIcon =
                                              FluentIcons.emoji_sad_20_filled;
                                          break;
                                        case 'Anxious':
                                          sentimentColor = DesignPalette.terra;
                                          sentimentIcon =
                                              FluentIcons.brain_20_filled;
                                          break;
                                        case 'Focused':
                                          sentimentColor = DesignPalette.fernDeep;
                                          sentimentIcon =
                                              FluentIcons.target_20_filled;
                                          break;
                                        default:
                                          sentimentColor =
                                              colorScheme.onSurfaceVariant;
                                          sentimentIcon =
                                              FluentIcons.circle_20_filled;
                                      }

                                      return Row(
                                        children: [
                                          Flexible(
                                            flex: 0,
                                            child: Icon(
                                              sentimentIcon,
                                              size: 12,
                                              color: sentimentColor,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            flex: 1,
                                            child: StyledText(
                                              entry.key,
                                              fontSize: 12,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            flex: 0,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: StyledText(
                                                '${entry.value.toStringAsFixed(0)}%',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: sentimentColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right half - Recommendations
                    Expanded(
                      child: SurfaceCard(
                        padding: EdgeInsets.zero,
                        elevation: 1,
                        child: SizedBox(
                          height: 220,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FluentIcons.lightbulb_20_regular,
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: StyledText(
                                        'Tips',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: recommendations.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: StyledText(
                                                recommendations[index],
                                                fontSize: 11,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => _buildLoadingState(colorScheme),
                error: (_, __) => _buildLoadingState(colorScheme),
              ),
              loading: () => _buildLoadingState(colorScheme),
              error: (_, __) => _buildLoadingState(colorScheme),
            ),
          ),
        ),

        // Static "Chat with AI" entry card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SurfaceCard(
              padding: const EdgeInsets.all(16),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.chatPath),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Icon(
                      FluentIcons.chat_sparkle_20_regular,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          'Chat with AI',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 2),
                        StyledText(
                          'Get personalized wellbeing support',
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    FluentIcons.chevron_right_20_regular,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            elevation: 1,
            child: SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            elevation: 1,
            child: SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
