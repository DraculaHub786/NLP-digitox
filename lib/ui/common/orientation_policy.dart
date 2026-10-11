import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Locks phones to portrait while leaving large screens free to rotate.
///
/// A phone-only focus app has no good reason to run in landscape, and locking
/// it removes a whole class of layout problems on small screens. Tablets and
/// foldables — any device whose *shortest* side is at least 600dp — still
/// rotate, because a wide window is a legitimate way to use them, and newer
/// Android versions no longer let an app force orientation on large screens
/// anyway.
///
/// The decision reads the *shortest* side, which does not change when the
/// device rotates. That is deliberate: keying on width or height would make the
/// policy flip-flop across a rotation, switching orientations back and forth
/// as the screen turns.
///
/// This is the "Layer 1" half of the rotation fix. Layer 2 is what makes the
/// tablet layouts survive landscape — see the header cap in `ScaffoldShell`
/// and the scroll-when-cramped session sheets.
class OrientationPolicy extends StatefulWidget {
  const OrientationPolicy({super.key, required this.child});

  final Widget child;

  @override
  State<OrientationPolicy> createState() => _OrientationPolicyState();
}

class _OrientationPolicyState extends State<OrientationPolicy> {
  /// The last decision made, so the platform is only touched when it changes.
  ///
  /// `didChangeDependencies` runs on every inherited-widget change (theme,
  /// locale, text scale…), and pushing the same preferred orientations on each
  /// one would be a needless platform round trip per rebuild.
  bool? _isLargeScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isLarge = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isLarge == _isLargeScreen) return;
    _isLargeScreen = isLarge;

    SystemChrome.setPreferredOrientations(
      isLarge
          ? DeviceOrientation.values
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
