
import 'package:flutter/material.dart';
import 'package:nlp_digitox/models/app_intent_model.dart';

/// Intent Prompt Dialog widget
/// Shows when user attempts to open an app and asks for the intent/context
/// of their app usage (education, entertainment, productivity, etc.)
class IntentPromptDialog extends StatefulWidget {
  /// Package name of the app being opened
  final String appPackage;

  /// Display name of the app
  final String appName;

  /// Callback when user selects an intent
  final Function(AppIntent) onIntentSelected;

  /// Callback when user cancels
  final VoidCallback? onCancel;

  /// Whether blocking is soft (allow override) or hard
  final bool isSoftBlock;

  const IntentPromptDialog({
    super.key,
    required this.appPackage,
    required this.appName,
    required this.onIntentSelected,
    this.onCancel,
    this.isSoftBlock = true,
  });

  @override
  State<IntentPromptDialog> createState() => _IntentPromptDialogState();

  /// Show intent prompt as a bottom sheet
  static Future<AppIntent?> showBottomSheet(
    BuildContext context, {
    required String appPackage,
    required String appName,
    required Function(AppIntent) onIntentSelected,
    VoidCallback? onCancel,
    bool isSoftBlock = true,
  }) {
    return showModalBottomSheet<AppIntent?>(
      context: context,
      isDismissible: isSoftBlock,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => IntentPromptDialog(
        appPackage: appPackage,
        appName: appName,
        onIntentSelected: onIntentSelected,
        onCancel: onCancel,
        isSoftBlock: isSoftBlock,
      ),
    );
  }

  /// Show intent prompt as a dialog
  static Future<AppIntent?> showAsDialog(
    BuildContext context, {
    required String appPackage,
    required String appName,
    required Function(AppIntent) onIntentSelected,
    VoidCallback? onCancel,
    bool isSoftBlock = true,
  }) {
    return showDialog<AppIntent?>(
      context: context,
      barrierDismissible: isSoftBlock,
      builder: (context) => IntentPromptDialog(
        appPackage: appPackage,
        appName: appName,
        onIntentSelected: onIntentSelected,
        onCancel: onCancel,
        isSoftBlock: isSoftBlock,
      ),
    );
  }
}

class _IntentPromptDialogState extends State<IntentPromptDialog> {
  AppIntent? _selectedIntent;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What are you using ${widget.appName} for?',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help us understand your app usage patterns',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isSoftBlock)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        widget.onCancel?.call();
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Intent Options Grid
              GridView.count(
                crossAxisCount: isMobile ? 2 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: AppIntent.values.map((intent) {
                  return _IntentOption(
                    intent: intent,
                    isSelected: _selectedIntent == intent,
                    onSelected: (selected) {
                      setState(() => _selectedIntent = selected);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.isSoftBlock)
                    TextButton(
                      onPressed: () {
                        widget.onCancel?.call();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedIntent == null
                        ? null
                        : () {
                            widget.onIntentSelected(_selectedIntent!);
                            Navigator.pop(context, _selectedIntent);
                          },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual intent option widget
class _IntentOption extends StatelessWidget {
  final AppIntent intent;
  final bool isSelected;
  final Function(AppIntent) onSelected;

  const _IntentOption({
    required this.intent,
    required this.isSelected,
    required this.onSelected,
  });

  IconData _getIconForIntent(AppIntent intent) {
    switch (intent) {
      case AppIntent.education:
        return Icons.school;
      case AppIntent.entertainment:
        return Icons.movie;
      case AppIntent.productivity:
        return Icons.work;
      case AppIntent.social:
        return Icons.people;
      case AppIntent.health:
        return Icons.fitness_center;
      case AppIntent.utility:
        return Icons.build;
      case AppIntent.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(intent),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForIntent(intent),
                size: 32,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                intent.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Intent Prompt Card - for in-app display
class IntentPromptCard extends StatefulWidget {
  final String appName;
  final String appPackage;
  final Function(AppIntent) onIntentSelected;
  final VoidCallback? onCancel;

  const IntentPromptCard({
    super.key,
    required this.appName,
    required this.appPackage,
    required this.onIntentSelected,
    this.onCancel,
  });

  @override
  State<IntentPromptCard> createState() => _IntentPromptCardState();
}

class _IntentPromptCardState extends State<IntentPromptCard> {
  AppIntent? _selectedIntent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you using ${widget.appName} for?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your answer helps us better manage your app usage',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppIntent.values.map((intent) {
                return FilterChip(
                  label: Text(intent.displayName),
                  selected: _selectedIntent == intent,
                  onSelected: (selected) {
                    setState(() => _selectedIntent = selected ? intent : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedIntent == null
                      ? null
                      : () {
                          widget.onIntentSelected(_selectedIntent!);
                        },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
