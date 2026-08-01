
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/clay_widgets.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';
import 'package:nlp_digitox/ui/transitions/hero_page_route.dart';

/// Animates the hero widget to a alert dialog for the confirmation with the provided configurations
///
/// Returns a boolean indicating the user's intention TRUE if confirm otherwise FALSE
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required Object heroTag,
  required String title,
  required String info,
  required IconData icon,
  required String positiveLabel,
  bool isBarrierDismissible = true,
  String? negativeLabel,
}) async {
  return await Navigator.of(context).push<bool>(
        HeroPageRoute(
          isBarrierDismissible: isBarrierDismissible,
          builder: (context) => _ConfirmationDialog(
            heroTag: heroTag,
            title: title,
            info: info,
            icon: icon,
            positiveLabel: positiveLabel,
            negativeLabel: negativeLabel ?? context.locale.dialog_button_cancel,
          ),
        ),
      ) ??
      false;
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.heroTag,
    required this.title,
    required this.info,
    required this.icon,
    required this.positiveLabel,
    required this.negativeLabel,
  });

  final Object heroTag;
  final String title;
  final String info;
  final IconData icon;
  final String positiveLabel;
  final String negativeLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: DefaultHero(
            tag: heroTag,
            child: AlertDialog(
              scrollable: true,
              icon: Icon(icon),
              title: StyledText(title, fontSize: 16),
              insetPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: StyledText(
                    info,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              actions: [
                FittedBox(
                  child: TextButton(
                    onPressed: () => Navigator.maybePop(context, false),
                    child: Text(
                      negativeLabel,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                FittedBox(
                  child: ClayContainer(
                    baseColor: Theme.of(context).colorScheme.primary,
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    onTap: () => Navigator.maybePop(context, true),
                    child: Text(
                      positiveLabel,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: ClayStyle.foregroundColor(
                          Theme.of(context).colorScheme.primary,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
