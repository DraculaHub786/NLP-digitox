// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/ui/dialogs/glance_customization_dialog.dart';

class CustomizeGlanceCards extends ConsumerWidget {
  const CustomizeGlanceCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(FluentIcons.table_edit_20_filled),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => const GlanceCustomizationDialog(),
      ),
    );
  }
}
