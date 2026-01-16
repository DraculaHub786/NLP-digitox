// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SliverAIAnalysis extends StatefulWidget {
  const SliverAIAnalysis({super.key});

  @override
  State<SliverAIAnalysis> createState() => _SliverAIAnalysisState();
}

class _SliverAIAnalysisState extends State<SliverAIAnalysis> {
  // Default sentiment analysis data
  final Map<String, double> _sentimentData = {
    'Positive': 45.0,
    'Neutral': 35.0,
    'Negative': 20.0,
  };

  // Default recommendations
  final List<String> _recommendations = [
    'Consider reducing screen time during evening hours',
    'Try focus mode during work hours for better productivity',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MultiSliver(
      children: [
        const ContentSectionHeader(title: "AI Analysis"),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left half - Sentiment Analysis
                Expanded(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          'Sentiment Analysis',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _sentimentData.entries.map((entry) {
                              Color sentimentColor;
                              switch (entry.key) {
                                case 'Positive':
                                  sentimentColor = Colors.green;
                                  break;
                                case 'Neutral':
                                  sentimentColor = Colors.orange;
                                  break;
                                case 'Negative':
                                  sentimentColor = Colors.red;
                                  break;
                                default:
                                  sentimentColor = Colors.grey;
                              }
                              
                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: sentimentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: StyledText(
                                      entry.key,
                                      fontSize: 14,
                                    ),
                                  ),
                                  StyledText(
                                    '${entry.value.toStringAsFixed(0)}%',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
                const SizedBox(width: 12),
                // Right half - Recommendations
                Expanded(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          'Recommendations',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: StyledText(
                                        _recommendations[index],
                                        fontSize: 13,
                                        maxLines: 1,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
