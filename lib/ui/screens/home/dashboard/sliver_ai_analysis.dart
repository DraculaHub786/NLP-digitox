// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/NLP ditix)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:sliver_tools/sliver_tools.dart' as sliver show MultiSliver;
import 'package:nlp_digitox/providers/ai_providers.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class SliverAIAnalysis extends ConsumerStatefulWidget {
  const SliverAIAnalysis({super.key});

  @override
  ConsumerState<SliverAIAnalysis> createState() => _SliverAIAnalysisState();
}

class _SliverAIAnalysisState extends ConsumerState<SliverAIAnalysis> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isChatExpanded = false;

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sentimentAsync = ref.watch(aiSentimentProvider);
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);
    final chatMessages = ref.watch(aiChatMessagesProvider);
    final isLoading = ref.watch(aiChatLoadingProvider);
    
    return sliver.MultiSliver(
      children: [
        const ContentSectionHeader(title: "AI Analysis"),
        
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
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
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
                                const SizedBox(width: 4),
                                Flexible(
                                  child: StyledText(
                                    'Sentiment',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: sentimentData.entries.map((entry) {
                                  Color sentimentColor;
                                  IconData sentimentIcon;
                                  switch (entry.key) {
                                    case 'Positive':
                                      sentimentColor = Colors.green;
                                      sentimentIcon = FluentIcons.emoji_smile_slight_20_filled;
                                      break;
                                    case 'Neutral':
                                      sentimentColor = Colors.orange;
                                      sentimentIcon = FluentIcons.emoji_meh_20_filled;
                                      break;
                                    case 'Negative':
                                      sentimentColor = Colors.red;
                                      sentimentIcon = FluentIcons.emoji_sad_20_filled;
                                      break;
                                    case 'Anxious':
                                      sentimentColor = Colors.deepOrange;
                                      sentimentIcon = FluentIcons.brain_20_filled;
                                      break;
                                    case 'Focused':
                                      sentimentColor = Colors.blue;
                                      sentimentIcon = FluentIcons.target_20_filled;
                                      break;
                                    default:
                                      sentimentColor = Colors.grey;
                                      sentimentIcon = FluentIcons.circle_20_filled;
                                  }
                                  
                                  return Row(
                                    children: [
                                      Icon(
                                        sentimentIcon,
                                        size: 12,
                                        color: sentimentColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: StyledText(
                                          entry.key,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      StyledText(
                                        '${entry.value.toStringAsFixed(0)}%',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: sentimentColor,
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
                        height: 220,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
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
                  ],
                ),
                loading: () => _buildLoadingState(colorScheme),
                error: (_, __) => _buildErrorState(colorScheme),
              ),
              loading: () => _buildLoadingState(colorScheme),
              error: (_, __) => _buildErrorState(colorScheme),
            ),
          ),
        ),
        
        // AI Chat Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chat header with expand/collapse
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChatExpanded = !_isChatExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.chat_sparkle_20_regular,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StyledText(
                                'Chat with AI Coach',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 2),
                              StyledText(
                                _isChatExpanded 
                                    ? 'Get personalized wellbeing support'
                                    : 'Tap to start conversation',
                                fontSize: 11,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isChatExpanded 
                              ? FluentIcons.chevron_up_20_regular
                              : FluentIcons.chevron_down_20_regular,
                          size: 20,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Expanded chat interface
                if (_isChatExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Chat messages
                        Expanded(
                          child: chatMessages.isEmpty
                              ? _buildEmptyChat(colorScheme)
                              : ListView.builder(
                                  controller: _chatScrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: chatMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = chatMessages[index];
                                    return _buildChatBubble(
                                      message,
                                      colorScheme,
                                    );
                                  },
                                ),
                        ),
                        
                        // Suggested prompts (show if no messages)
                        if (chatMessages.isEmpty)
                          _buildSuggestedPrompts(colorScheme),
                        
                        // Chat input
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  enabled: !isLoading,
                                  decoration: InputDecoration(
                                    hintText: isLoading ? 'AI is typing...' : 'Type your message...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerHighest,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    isDense: true,
                                  ),
                                  maxLines: null,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: isLoading ? null : _sendMessage,
                                icon: Icon(
                                  isLoading 
                                      ? FluentIcons.spinner_ios_20_regular
                                      : FluentIcons.send_20_filled,
                                  color: isLoading 
                                      ? colorScheme.onSurface.withOpacity(0.3)
                                      : colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for UI components
  
  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.warning_20_regular,
                  color: colorScheme.error,
                  size: 32,
                ),
                const SizedBox(height: 12),
                StyledText(
                  'AI Analysis Unavailable',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                StyledText(
                  'Please check your API key',
                  fontSize: 11,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.warning_20_regular,
                  color: colorScheme.error,
                  size: 32,
                ),
                const SizedBox(height: 12),
                StyledText(
                  'Recommendations Unavailable',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChat(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.bot_20_regular,
            size: 48,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          StyledText(
            'Start a conversation',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          StyledText(
            'Ask me about your digital wellbeing!',
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, ColorScheme colorScheme) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentIcons.bot_20_filled,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser 
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: StyledText(
                message.message,
                fontSize: 13,
                color: isUser 
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentIcons.person_20_filled,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts(ColorScheme colorScheme) {
    final suggestedPromptsAsync = ref.watch(aiSuggestedPromptsProvider);
    
    return suggestedPromptsAsync.when(
      data: (prompts) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledText(
              'Suggested topics:',
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prompts.map((prompt) {
                return InkWell(
                  onTap: () {
                    _chatController.text = prompt;
                    _sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: StyledText(
                      prompt,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    // Clear input
    _chatController.clear();

    // Set loading state
    ref.read(aiChatLoadingProvider.notifier).state = true;

    try {
      // Send message to AI
      await AIChatbotService.instance.sendMessage(message);

      // Update chat history
      ref.read(aiChatMessagesProvider.notifier).state = 
          AIChatbotService.instance.chatHistory;

      // Update sentiment AI with chat context
      final sentimentAsync = ref.read(aiSentimentProvider);
      sentimentAsync.whenData((sentiment) async {
        await AIChatbotService.instance.updateWithSentiment(
          sentiment: sentiment,
          screenTimeSeconds: 0, // Will be updated from provider
          goalSeconds: 0, // Will be updated from provider
        );
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      // Clear loading state
      ref.read(aiChatLoadingProvider.notifier).state = false;
    }
  }
}
