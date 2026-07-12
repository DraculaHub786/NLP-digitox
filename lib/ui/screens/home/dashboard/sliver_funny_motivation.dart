// Copyright (c) 2024 NLP digitox
//
// Funny motivation card — a dismissible, cartoon-brutalist UI element that
// shows a witty AI-generated message based on the user's mood, persona, and
// recent behaviour. Visually and tonally separate from the serious AI Analysis
// section.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/providers/funny_motivation_provider.dart';

/// A sliver that displays a dismissible funny-motivation card.
/// Returns an empty sliver if the message is null (cached dismiss, privacy off,
/// or fetch failure).
class SliverFunnyMotivation extends ConsumerStatefulWidget {
  const SliverFunnyMotivation({super.key});

  @override
  ConsumerState<SliverFunnyMotivation> createState() =>
      _SliverFunnyMotivationState();
}

class _SliverFunnyMotivationState extends ConsumerState<SliverFunnyMotivation> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final asyncValue = ref.watch(funnyMotivationProvider);
    final isLoading = ref.watch(funnyMotivationLoadingProvider);
    final refresh = ref.read(funnyMotivationRefreshProvider);

    return asyncValue.when(
      data: (message) {
        if (message == null || message.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _FunnyMotivationCard(
              message: message,
              isLoading: false,
              onDismiss: () => setState(() => _dismissed = true),
              onRefresh: refresh,
            ),
          ),
        );
      },
      loading: () {
        if (!isLoading) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _FunnyMotivationCard(
              message: null,
              isLoading: true,
              onDismiss: () => setState(() => _dismissed = true),
              onRefresh: refresh,
            ),
          ),
        );
      },
      error: (_, __) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

/// The actual card widget — cartoon brutalist with bold black outlines,
/// flat colours, chunky emoji, and a snakeoil-salesman "tincture" vibe.
class _FunnyMotivationCard extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final VoidCallback onDismiss;
  final VoidCallback onRefresh;

  const _FunnyMotivationCard({
    required this.message,
    required this.isLoading,
    required this.onDismiss,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Flat solid background, no gradient
        color: isDark
            ? const Color(0xFF2D2A1A)
            : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
        // Thick black stroke — cartoon brutalist signature
        border: Border.all(
          color: isDark ? Colors.white70 : Colors.black,
          width: 2.5,
        ),
        // Chunky drop shadow
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0x33000000)),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji mascot
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '🤪',
                style: TextStyle(
                  fontSize: 28,
                  color: isDark ? Colors.white70 : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Message or shimmer
            Expanded(
              child: isLoading
                  ? _ShimmerBlock()
                  : Text(
                      message!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
            ),
            const SizedBox(width: 4),
            // Action buttons column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refresh (cheer me up)
                _ActionCircle(
                  emoji: '🔄',
                  onTap: onRefresh,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                // Dismiss
                _ActionCircle(
                  emoji: '✕',
                  onTap: onDismiss,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circular button with an emoji or symbol.
class _ActionCircle extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCircle({
    required this.emoji,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white54 : Colors.black,
            width: 1.8,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder shimmer while the API call is in-flight.
class _ShimmerBlock extends StatefulWidget {
  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        height: 18,
        width: double.infinity,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
