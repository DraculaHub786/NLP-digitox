// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/NLP ditix)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/ui/screens/chat_settings/chat_settings_screen.dart';

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
                                    
                                    // Also clear SharedPreferences cache
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('last_sentiment_analysis');
                                    await prefs.remove('last_sentiment_analysis_date');
                                    
                                    // Force refresh providers
                                    ref.invalidate(aiSentimentProvider);
                                    ref.invalidate(aiRecommendationsProvider);
                                    
                                    debugPrint('🔄 Manually refreshed sentiment analysis');
                                  },
                                  child: Icon(
                                    FluentIcons.arrow_clockwise_20_regular,
                                    size: 14,
                                    color: colorScheme.primary.withOpacity(0.7),
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
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                        // Settings button
                        IconButton(
                          icon: Icon(
                            FluentIcons.settings_20_regular,
                            size: 18,
                            color: colorScheme.onSurface.withOpacity(0.6),
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
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
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
                                  ? colorScheme.onPrimary.withOpacity(0.7)
                                  : colorScheme.onSurface.withOpacity(0.6),
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
                            color: Colors.red.withOpacity(0.7),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
              leading: const Icon(FluentIcons.delete_20_regular, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
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
      debugPrint('🚀 Sending message to AI: $message');
      
      // Send message to AI and get response
      final response = await AIChatbotService.instance.sendMessage(message);
      
      debugPrint('✅ AI Response received: $response');

      // Update chat history immediately after receiving response
      ref.read(aiChatMessagesProvider.notifier).state = 
          List.from(AIChatbotService.instance.chatHistory);

      // Update sentiment AI with chat context for better future analysis
      try {
        final sentimentAsync = ref.read(aiSentimentProvider);
        final todayUsage = ref.read(weeklyDeviceUsageProvider(dateToday.weekRange))[dateToday] ?? const UsageModel();
        final wellbeingSettings = await DriftDbService.instance.driftDb.uniqueRecordsDao.loadWellBeingSettings();
        
        await sentimentAsync.whenOrNull(
          data: (sentiment) async {
            await AIChatbotService.instance.updateWithSentiment(
              sentiment: sentiment,
              screenTimeSeconds: todayUsage.screenTime,
              goalSeconds: wellbeingSettings.allowedShortsTimeSec,
            );
          },
        );
      } catch (e) {
        debugPrint('⚠️ Error updating sentiment context: $e');
      }

      // Refresh recommendations based on new chat context
      ref.invalidate(aiRecommendationsProvider);

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
