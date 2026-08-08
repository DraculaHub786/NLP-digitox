
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class DefaultSegmentedButton<T> extends StatelessWidget {
  const DefaultSegmentedButton({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.segments,
  });

  final T selected;
  final ValueChanged<T> onChanged;
  final List<SegmentItem<T>> segments;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      showSelectedIcon: false,
      selected: {selected},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) onChanged(set.first);
      },
      style: const ButtonStyle().copyWith(
        visualDensity: VisualDensity.standard,
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).iconTheme.color,
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
          ),
        ),
      ),
      segments: segments
          .map(
            (e) => ButtonSegment<T>(
              icon: e.icon != null
                  ? Icon(
                      selected == e.value && e.filledIcon != null
                          ? e.filledIcon
                          : e.icon,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : null,
              label: e.label != null ? Text(e.label!) : null,
              value: e.value,
            ),
          )
          .toList(),
    );
  }
}

class SegmentItem<T> {
  const SegmentItem({
    required this.value,
    this.label,
    this.icon,
    this.filledIcon,
  });

  /// Value used to identify the segment.
  final T value;

  /// Optional icon displayed in the segment.
  final IconData? icon;

  /// Optional icon displayed in the segment.
  final IconData? filledIcon;

  /// Optional label displayed in the segment.
  final String? label;
}
