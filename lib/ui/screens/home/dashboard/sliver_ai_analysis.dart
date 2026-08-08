// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/NLP ditix)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:sliver_tools/sliver_tools.dart' as sliver show MultiSliver;
import 'package:nlp_digitox/providers/ai_providers.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/ui/screens/chat_settings/chat_settings_screen.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

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
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ModernSectionHeader(title: "AI Analysis"),
          ),
        ),

        // Sentiment Analysis and Recommendations Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
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
                                    // Clear cache and refresh
                                    AISentimentService.instance.clearSentimentCache();

                                    // Force refresh providers
                                    ref.invalidate(aiSentimentProvider);
                                    ref.invalidate(aiRecommendationsProvider);

                                    debugPrint('🔄 Manually refreshed sentiment analysis');
                                  },
                                  child: Icon(
                                    FluentIcons.arrow_clockwise_20_regular,
                                    size: 14,
                                    color: colorScheme.primary.withValues(alpha: 0.7),
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
                                      sentimentColor = GlassTokens.of(context).statusGood;
                                      sentimentIcon = FluentIcons.emoji_smile_slight_20_filled;
                                      break;
                                    case 'Neutral':
                                      sentimentColor = GlassTokens.of(context).statusWarn;
                                      sentimentIcon = FluentIcons.emoji_meh_20_filled;
                                      break;
                                    case 'Negative':
                                      sentimentColor = GlassTokens.of(context).statusBad;
                                      sentimentIcon = FluentIcons.emoji_sad_20_filled;
                                      break;
                                    case 'Anxious':
                                      sentimentColor = DesignPalette.terra;
                                      sentimentIcon = FluentIcons.brain_20_filled;
                                      break;
                                    case 'Focused':
                                      sentimentColor = DesignPalette.fernDeep;
                                      sentimentIcon = FluentIcons.target_20_filled;
                                      break;
                                    default:
                                      sentimentColor = colorScheme.onSurfaceVariant;
                                      sentimentIcon = FluentIcons.circle_20_filled;
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
                    const SizedBox(width: 12),

                    // Right half - Recommendations
                    Expanded(
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
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
                error: (_, __) => _buildFallbackState(colorScheme),
              ),
              loading: () => _buildLoadingState(colorScheme),
              error: (_, __) => _buildFallbackState(colorScheme),
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
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
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
                                'Chat with AI',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 2),
                              StyledText(
                                _isChatExpanded
                                    ? 'Get personalized wellbeing support'
                                    : 'Tap to start conversation',
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Settings button
                        Flexible(
                          flex: 0,
                          child: IconButton(
                            icon: Icon(
                              FluentIcons.settings_20_regular,
                              size: 18,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatSettingsScreen(),
                                ),
                              );
                            },
                            tooltip: 'Chat Settings',
                          ),
                        ),
                        Icon(
                          _isChatExpanded
                              ? FluentIcons.chevron_up_20_regular
                              : FluentIcons.chevron_down_20_regular,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
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
                                color: colorScheme.outline.withValues(alpha: 0.2),
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
                                      borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
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
                                      ? colorScheme.onSurface.withValues(alpha: 0.3)
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
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
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
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
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

  Widget _buildFallbackState(ColorScheme colorScheme) {
    const fallbackSentiment = {
      'Positive': 30.0,
      'Neutral': 45.0,
      'Negative': 10.0,
      'Anxious': 10.0,
      'Focused': 5.0,
    };
    const fallbackTips = [
      'Set one small focus goal for the next 20 minutes.',
      'Take a short break and return with a clear next task.',
      'Review today\'s habits and complete one quick win now.',
    ];

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  'Sentiment',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: fallbackSentiment.entries.map((entry) {
                      return Row(
                        children: [
                          Expanded(
                            child: StyledText(
                              entry.key,
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            flex: 0,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: StyledText(
                                '${entry.value.toStringAsFixed(0)}%',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  'Tips',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: fallbackTips.length,
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
                                fallbackTips[index],
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
            color: colorScheme.primary.withValues(alpha: 0.5),
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
            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: colorScheme.primary.withValues(alpha: 0.1),
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
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showMessageOptions(message, colorScheme),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(GlassTokens.radiusCard),
                        topRight: const Radius.circular(GlassTokens.radiusCard),
                        bottomLeft: Radius.circular(isUser ? GlassTokens.radiusCard : 4),
                        bottomRight: Radius.circular(isUser ? 4 : GlassTokens.radiusCard),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          message.message,
                          fontSize: 13,
                          color: isUser
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                        if (message.isEdited)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: StyledText(
                              '(edited)',
                              fontSize: 10,
                              color: isUser
                                  ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                  : colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Message actions
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Copy button
                      InkWell(
                        onTap: () => _copyMessage(message),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            FluentIcons.copy_20_regular,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                      // Edit button (only for user messages)
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _editMessage(message),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              FluentIcons.edit_20_regular,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                      // Delete button
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _deleteMessage(message),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            FluentIcons.delete_20_regular,
                            size: 14,
                            color: colorScheme.error.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
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

  // Message action handlers
  void _copyMessage(ChatMessage message) {
    final text = AIChatbotService.instance.copyMessage(message.id);
    if (text != null) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message copied to clipboard')),
      );
    }
  }

  Future<void> _editMessage(ChatMessage message) async {
    final controller = TextEditingController(text: message.message);
    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newText != null && newText.isNotEmpty && newText != message.message) {
      // Show loading state
      ref.read(aiChatLoadingProvider.notifier).state = true;

      try {
        // Edit message and get new AI response
        final aiResponse = await AIChatbotService.instance.editMessage(message.id, newText);

        // Refresh chat messages
        ref.read(aiChatMessagesProvider.notifier).state =
            List.from(AIChatbotService.instance.chatHistory);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(aiResponse != null
                ? 'Message edited and AI response regenerated'
                : 'Message edited'),
            ),
          );

          // Scroll to bottom to show new AI response
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        ref.read(aiChatLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AIChatbotService.instance.deleteMessage(message.id);
      // Refresh chat messages
      ref.read(aiChatMessagesProvider.notifier).state =
          List.from(AIChatbotService.instance.chatHistory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted')),
        );
      }
    }
  }

  void _showMessageOptions(ChatMessage message, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.copy_20_regular),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(message);
              },
            ),
            if (message.isUser)
              ListTile(
                leading: const Icon(FluentIcons.edit_20_regular),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
            ListTile(
              leading: Icon(
                FluentIcons.delete_20_regular,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message);
              },
            ),
          ],
        ),
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
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledText(
              'Suggested topics:',
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
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
      debugPrint('🚀 Sending message to AI: $message');

      // Send message to AI and get response
      final response = await AIChatbotService.instance.sendMessage(message);

      debugPrint('✅ AI Response received: $response');

      // Update chat history immediately after receiving response
      ref.read(aiChatMessagesProvider.notifier).state =
          List.from(AIChatbotService.instance.chatHistory);

      // Update sentiment AI with chat context for better future analysis
      try {
        final sentiment = await ref.refresh(aiSentimentProvider.future);
        final todayUsage = ref.read(weeklyDeviceUsageProvider(dateToday.weekRange))[dateToday] ?? const UsageModel();
        final wellbeingSettings = await DriftDbService.instance.driftDb.uniqueRecordsDao.loadWellBeingSettings();
        await AIChatbotService.instance.updateWithSentiment(
          sentiment: sentiment,
          screenTimeSeconds: todayUsage.screenTime,
          goalSeconds: wellbeingSettings.dailyScreenTimeGoalSec,
        );
      } catch (e) {
        debugPrint('⚠️ Error updating sentiment context: $e');
      }

      // Refresh recommendations based on fresh chat+sentiment context
      try {
        final _ = await ref.refresh(aiRecommendationsProvider.future);
      } catch (e) {
        debugPrint('⚠️ Error refreshing recommendations: $e');
      }

      // Scroll to bottom to show new messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending message: $e');
      debugPrint('Stack trace: $stackTrace');

      // Show error message in chat
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Please check your internet connection and API key.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Clear loading state
      if (mounted) {
        ref.read(aiChatLoadingProvider.notifier).state = false;
      }
    }
  }

}
