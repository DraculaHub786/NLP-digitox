// Privacy Settings Screen — Task 10 — NLP-Digitox

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/providers/privacy_provider.dart';

/// Full-featured Privacy & Compliance settings screen.
/// Glassmorphic design with opt-in toggles, data export, and deletion.
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState
    extends ConsumerState<PrivacySettingsScreen> {
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final privacy = ref.watch(privacyProvider);
    final notifier = ref.read(privacyProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Privacy & Data',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Section: Sync & Connectivity
                      _SectionHeader(
                        label: 'Sync & Connectivity',
                        icon: Icons.sync_rounded,
                        delay: 100.ms,
                      ),
                      _PrivacyToggleCard(
                        icon: Icons.cloud_sync_outlined,
                        title: 'Cloud Sync',
                        subtitle:
                            'Sync your app usage quotas and limits across devices via Firebase. '
                            'When off, all data stays on this device only.',
                        value: privacy.cloudSyncEnabled,
                        onChanged: (v) => notifier.setCloudSync(v),
                        delay: 150.ms,
                      ),
                      _PrivacyToggleCard(
                        icon: Icons.devices_rounded,
                        title: 'Cross-Device Features',
                        subtitle:
                            'Allow device locking and shared quota enforcement across your '
                            'devices. Requires Cloud Sync to be enabled.',
                        value: privacy.effectiveCrossDevice,
                        enabled: privacy.cloudSyncEnabled,
                        disabledReason: 'Enable Cloud Sync first',
                        onChanged: (v) => notifier.setCrossDevice(v),
                        delay: 200.ms,
                      ),

                      const SizedBox(height: 8),

                      // Section: Personal Data
                      _SectionHeader(
                        label: 'Personal Data',
                        icon: Icons.person_outline_rounded,
                        delay: 250.ms,
                      ),
                      _PrivacyToggleCard(
                        icon: Icons.mood_rounded,
                        title: 'Mood & Sentiment Tracking',
                        subtitle:
                            'Record your emotional state over time to get personalised '
                            'wellbeing suggestions. Data stays on-device.',
                        value: privacy.moodTrackingEnabled,
                        onChanged: (v) => notifier.setMoodTracking(v),
                        delay: 300.ms,
                      ),
                      _PrivacyToggleCard(
                        icon: Icons.analytics_outlined,
                        title: 'Anonymous Analytics',
                        subtitle:
                            'Share anonymised usage analytics to help improve the app. '
                            'No personal data is included.',
                        value: privacy.analyticsEnabled,
                        onChanged: (v) => notifier.setAnalytics(v),
                        delay: 350.ms,
                      ),

                      const SizedBox(height: 8),

                      // Section: Your Data
                      _SectionHeader(
                        label: 'Your Data',
                        icon: Icons.folder_outlined,
                        delay: 400.ms,
                      ),

                      _InfoCard(
                        delay: 420.ms,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What we store',
                              style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _BulletPoint(
                                'App usage quotas and daily limits (Firebase RTDB)'),
                            _BulletPoint('Session membership (Firebase RTDB)'),
                            _BulletPoint(
                                'Mood history — on-device only (SharedPreferences)'),
                            _BulletPoint(
                                'Persona profile — on-device only (SharedPreferences)'),
                            _BulletPoint(
                                'No passwords, payment info, or browsing history'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Export Button
                      _ActionCard(
                        icon: Icons.download_rounded,
                        title: 'Export My Data',
                        subtitle:
                            'Download a copy of all your local preferences and settings as JSON.',
                        color: theme.colorScheme.primary,
                        isLoading: _isExporting,
                        delay: 480.ms,
                        onTap: () => _exportData(context),
                      ),

                      const SizedBox(height: 12),

                      // Delete Data Button
                      _ActionCard(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete All My Data',
                        subtitle:
                            'Permanently removes your data from our servers and this device. '
                            'Your account will remain active.',
                        color: Colors.red.shade400,
                        isLoading: _isDeleting,
                        delay: 530.ms,
                        onTap: () => _confirmDeleteData(context),
                      ),

                      const SizedBox(height: 24),

                      // Footnote
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '🔒 Your privacy is important. We never sell your data. '
                          'Cloud features use Firebase with hashed device identifiers.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate(delay: 580.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _exportData(BuildContext context) async {
    setState(() => _isExporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json =
          await ref.read(privacyProvider.notifier).exportData();
      if (!mounted) return;

      // Show the export in a bottom sheet the user can copy
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => _ExportBottomSheet(jsonContent: json),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _confirmDeleteData(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final result =
          await ref.read(privacyProvider.notifier).deleteAllData();
      if (!mounted) return;

      if (result.success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('All your data has been deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final failures = result.partialResults.entries
            .where((e) => !e.value)
            .map((e) => e.key)
            .join(', ');
        messenger.showSnackBar(
          SnackBar(
            content: Text(
                'Partial deletion. Failed: $failures. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Deletion failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Duration delay;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
      child: Row(
        children: [
          Icon(icon, size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 350.ms);
  }
}

class _PrivacyToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final String? disabledReason;
  final ValueChanged<bool> onChanged;
  final Duration delay;

  const _PrivacyToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.delay,
    this.enabled = true,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveEnabled = enabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.white : theme.colorScheme.primary)
                      .withValues(alpha: effectiveEnabled ? 0.08 : 0.03),
                  (isDark ? Colors.white : theme.colorScheme.primary)
                      .withValues(alpha: effectiveEnabled ? 0.03 : 0.01),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (effectiveEnabled
                        ? theme.colorScheme.primary
                        : Colors.grey)
                    .withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (effectiveEnabled
                            ? theme.colorScheme.primary
                            : Colors.grey)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: effectiveEnabled
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: effectiveEnabled ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        effectiveEnabled
                            ? subtitle
                            : (disabledReason ?? subtitle),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: effectiveEnabled ? 0.6 : 0.4),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value && effectiveEnabled,
                  onChanged: effectiveEnabled ? onChanged : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;
  final Duration delay;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.10),
                    color.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: color,
                            ),
                          )
                        : Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _InfoCard({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    ).animate(delay: delay).fadeIn(duration: 350.ms);
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall
                  ?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete confirmation dialog
// ---------------------------------------------------------------------------

class _DeleteConfirmDialog extends StatefulWidget {
  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
          const SizedBox(width: 10),
          const Text('Delete All Data?'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will permanently delete:\n'
            '• Your usage quotas and limits (Firebase)\n'
            '• Your session memberships (Firebase)\n'
            '• Your local preferences and history\n\n'
            'Your login account will NOT be deleted.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _understood,
            onChanged: (v) => setState(() => _understood = v ?? false),
            title: const Text('I understand this cannot be undone'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _understood
              ? () => Navigator.pop(context, true)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Delete Data'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Export bottom sheet
// ---------------------------------------------------------------------------

class _ExportBottomSheet extends StatelessWidget {
  final String jsonContent;

  const _ExportBottomSheet({required this.jsonContent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exported Data',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  tooltip: 'Copy to clipboard',
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: jsonContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.outline
                          .withValues(alpha: 0.1)),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: SelectableText(
                    jsonContent,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
