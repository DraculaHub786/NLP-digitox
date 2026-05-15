
import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';

class DefaultSearchBar extends StatefulWidget {
  const DefaultSearchBar({
    super.key,
    this.hintText = "",
    required this.onSubmitted,
    this.debounceDelay = const Duration(milliseconds: 250),
  });

  final String hintText;
  final Duration debounceDelay;

  /// Will be call instantly when submitted otherwise it will be called after
  /// the debounce delay when the query is changed but haven't submitted.
  final ValueChanged<String> onSubmitted;

  @override
  State<DefaultSearchBar> createState() => _DefaultSearchBarState();
}

class _DefaultSearchBarState extends State<DefaultSearchBar> {
  Timer? _debouncer;

  @override
  void dispose() {
    _debouncer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultListTile(
      color: Theme.of(context).colorScheme.secondaryContainer,
      leading: Icon(
        FluentIcons.search_20_filled,
        color: Theme.of(context).hintColor,
      ),
      title: TextField(
        textInputAction: TextInputAction.search,
        decoration: InputDecoration.collapsed(
          hintText: widget.hintText,
        ),
        onChanged: (v) {
          _debouncer?.cancel();
          _debouncer = Timer(widget.debounceDelay, () => widget.onSubmitted(v));
        },
        onSubmitted: widget.onSubmitted,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}
