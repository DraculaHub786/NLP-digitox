
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/ui/dialogs/glance_customization_dialog.dart';

class CustomizeGlanceCards extends ConsumerWidget {
  const CustomizeGlanceCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(
          FluentIcons.table_edit_20_filled,
          color: colorScheme.onSurface,
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const GlanceCustomizationDialog(),
        ),
      ),
    );
  }
}
