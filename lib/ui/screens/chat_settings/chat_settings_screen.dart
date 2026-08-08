/*
 * Copyright (c) 2024 NLP digitox
 * Author : Afjal Ansari
 *
 * This source code is licensed under the GPL-2.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/providers/ai_providers.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';

class ChatSettingsScreen extends ConsumerStatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  ConsumerState<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends ConsumerState<ChatSettingsScreen> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _sessions = AIChatbotService.instance.getAllSessions();
      _isLoading = false;
    });
  }

  Future<void> _deleteSession(ChatSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat Session'),
        content: Text('Are you sure you want to delete "${session.title}"?'),
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
      await AIChatbotService.instance.deleteSession(session.id);
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat session deleted')),
        );
      }
    }
  }

  Future<void> _renameSession(ChatSession session) async {
    final controller = TextEditingController(text: session.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat Session'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Session Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      await AIChatbotService.instance.renameSession(session.id, newTitle);
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat session renamed')),
        );
      }
    }
  }

  Future<void> _switchToSession(ChatSession session) async {
    await AIChatbotService.instance.switchToSession(session.id);
    if (mounted) {
      // Update the chat messages provider to reflect the switched session
      ref.read(aiChatMessagesProvider.notifier).state =
          List.from(AIChatbotService.instance.chatHistory);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to "${session.title}"')),
      );
    }
  }

  Future<void> _createNewSession() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat Session'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Session Title (optional)',
            border: OutlineInputBorder(),
            hintText: 'Leave empty for auto-generated title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (title != null) {
      final session = await AIChatbotService.instance.createNewSession(
        title: title.isEmpty ? null : title,
      );
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Created "${session.title}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentSession = AIChatbotService.instance.getCurrentSession();
    final oldChatsCount = AIChatbotService.instance.getOldChatsCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.add_circle_20_regular),
            onPressed: _createNewSession,
            tooltip: 'New Chat Session',
          ),
          IconButton(
            icon: const Icon(FluentIcons.broom_20_regular),
            onPressed: () async {
              await AIChatbotService.instance.cleanupOldChats();
              _loadSessions();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Old chats cleaned up')),
                );
              }
            },
            tooltip: 'Clean up old chats',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info cards
                if (oldChatsCount > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.warning_20_regular,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StyledText(
                            '$oldChatsCount chat(s) will be auto-deleted (older than 30 days)',
                            fontSize: 13,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Current session indicator
                if (currentSession != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.chat_sparkle_20_filled,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StyledText(
                                'Current Session',
                                fontSize: 11,
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                              StyledText(
                                currentSession.title,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sessions list
                Expanded(
                  child: _sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.chat_empty_20_regular,
                                size: 64,
                                color: colorScheme.outline,
                              ),
                              16.vBox,
                              StyledText(
                                'No chat sessions yet',
                                fontSize: 16,
                                color: colorScheme.outline,
                              ),
                              8.vBox,
                              FilledButton.icon(
                                onPressed: _createNewSession,
                                icon: const Icon(FluentIcons.add_20_regular),
                                label: const Text('Create New Session'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            final isCurrent = currentSession?.id == session.id;
                            final isOld = DateTime.now()
                                .difference(session.lastMessageAt)
                                .inDays >= 30;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isCurrent ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  GlassTokens.radiusCard,
                                ),
                              ),
                              color: isCurrent
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              child: InkWell(
                                onTap: isCurrent
                                    ? null
                                    : () => _switchToSession(session),
                                borderRadius: BorderRadius.circular(
                                  GlassTokens.radiusCard,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isCurrent
                                                ? FluentIcons
                                                    .chat_sparkle_20_filled
                                                : FluentIcons.chat_20_regular,
                                            size: 20,
                                            color: isCurrent
                                                ? colorScheme
                                                    .onPrimaryContainer
                                                : colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: StyledText(
                                              session.title,
                                              fontSize: 15,
                                              fontWeight: isCurrent
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isCurrent
                                                  ? colorScheme
                                                      .onPrimaryContainer
                                                  : colorScheme.onSurface,
                                            ),
                                          ),
                                          if (isOld)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme
                                                    .errorContainer,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  GlassTokens.radiusPill,
                                                ),
                                              ),
                                              child: StyledText(
                                                'OLD',
                                                fontSize: 10,
                                                color: colorScheme
                                                    .onErrorContainer,
                                              ),
                                            ),
                                          PopupMenuButton(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'rename',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      FluentIcons
                                                          .edit_20_regular,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text('Rename'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      FluentIcons
                                                          .delete_20_regular,
                                                      color: colorScheme.error,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color:
                                                            colorScheme.error,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'rename') {
                                                _renameSession(session);
                                              } else if (value == 'delete') {
                                                _deleteSession(session);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            FluentIcons
                                                .chat_bubbles_question_20_regular,
                                            size: 14,
                                            color: isCurrent
                                                ? colorScheme
                                                    .onPrimaryContainer
                                                    .withValues(alpha: 0.7)
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                          ),
                                          const SizedBox(width: 6),
                                          StyledText(
                                            '${session.messages.length} messages',
                                            fontSize: 12,
                                            color: isCurrent
                                                ? colorScheme
                                                    .onPrimaryContainer
                                                    .withValues(alpha: 0.7)
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            FluentIcons.clock_20_regular,
                                            size: 14,
                                            color: isCurrent
                                                ? colorScheme
                                                    .onPrimaryContainer
                                                    .withValues(alpha: 0.7)
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                          ),
                                          const SizedBox(width: 6),
                                          StyledText(
                                            _formatDate(session.lastMessageAt),
                                            fontSize: 12,
                                            color: isCurrent
                                                ? colorScheme
                                                    .onPrimaryContainer
                                                    .withValues(alpha: 0.7)
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
