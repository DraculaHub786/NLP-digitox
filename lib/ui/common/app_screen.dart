import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/botanical_background.dart';

/// Wrapper for pushed detail routes that live OUTSIDE the `ScaffoldShell`
/// stack. Used only by the Phase 4 screens (Group App Blocking, Shorts
/// Blocking, Website Blocking, Habits, Tasks, Notes, Parental Control).
/// Do NOT use this for the 5 shell tabs — they already get their background
/// from the shell.
class AppScreen extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool safeArea;

  const AppScreen({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = safeArea ? SafeArea(child: body) : body;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      // Intentionally no bottomNavigationBar — these are pushed detail
      // routes outside the shell and must not show tab navigation.
      body: BotanicalBackground(child: content),
    );
  }
}

class AppScreenBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const AppScreenBar({super.key, required this.title, this.actions, this.leading});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }
}
