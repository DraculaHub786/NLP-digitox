import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';
import 'package:nlp_digitox/ui/transitions/hero_page_route.dart';

/// Animates the hero widget to an alert dialog used to manage the website
/// domains associated with a single app.
///
/// The websites listed here are blocked by the native side the moment this
/// app's own usage restriction (timer / launch limit / active period) is
/// actually hit, and unblocked again on the next midnight reset.
///
/// Returns the final, de-duplicated list of hosts, or `null` when the user
/// cancels the dialog.
Future<List<String>?> showAppAssociatedDomainsDialog({
  required BuildContext context,
  required Object heroTag,
  required String appName,
  required List<String> initialDomains,
}) async {
  return await Navigator.of(context).push<List<String>>(
    HeroPageRoute(
      builder: (context) => _AssociatedDomainsDialog(
        heroTag: heroTag,
        appName: appName,
        initialDomains: initialDomains,
      ),
    ),
  );
}

class _AssociatedDomainsDialog extends StatefulWidget {
  const _AssociatedDomainsDialog({
    required this.heroTag,
    required this.appName,
    required this.initialDomains,
  });

  final Object heroTag;
  final String appName;
  final List<String> initialDomains;

  @override
  State<_AssociatedDomainsDialog> createState() =>
      _AssociatedDomainsDialogState();
}

class _AssociatedDomainsDialogState extends State<_AssociatedDomainsDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late List<String> _domains = [...widget.initialDomains];
  String? _errorText;

  @override
  void initState() {
    super.initState();

    Future.delayed(AppConstants.defaultAnimDuration * 1.75, () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Parses, validates and appends the current text field value as a host.
  Future<void> _addDomain() async {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      setState(
        () => _errorText =
            context.locale.app_associated_domains_dialog_error_empty,
      );
      return;
    }

    /// Normalize through the same native parser the websites-blocking screen uses.
    final host = await MethodChannelService.instance.parseHostFromUrl(
      input.toLowerCase(),
    );

    if (!mounted) return;

    if (host.isEmpty || !host.contains('.') || host.contains(' ')) {
      setState(
        () => _errorText =
            context.locale.app_associated_domains_dialog_error_invalid,
      );
      return;
    }

    if (_domains.contains(host)) {
      setState(
        () => _errorText =
            context.locale.app_associated_domains_dialog_error_duplicate,
      );
      return;
    }

    setState(() {
      _domains = [..._domains, host];
      _errorText = null;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeDomain(String host) {
    setState(() {
      _domains = _domains.where((e) => e != host).toList();
      _errorText = null;
    });
  }

  void _onTextChanged(String _) {
    if (_errorText != null) setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: DefaultHero(
            tag: widget.heroTag,
            child: AlertDialog(
              scrollable: true,
              icon: const Icon(FluentIcons.globe_search_20_filled),
              title: StyledText(
                context.locale.app_associated_domains_dialog_title,
                fontSize: 16,
              ),
              insetPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StyledText(
                        context.locale.app_associated_domains_dialog_info(
                          widget.appName,
                        ),
                      ),
                      20.vBox,

                      /// Domain input field
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        onChanged: _onTextChanged,
                        onSubmitted: (_) => _addDomain(),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        decoration: InputDecoration(
                          label: Text(
                            context.locale
                                .app_associated_domains_dialog_field_label,
                          ),
                          hintText:
                              context.locale.app_associated_domains_dialog_hint,
                          errorText: _errorText,
                          prefixIcon: const Icon(FluentIcons.globe_20_regular),
                          suffixIcon: IconButton(
                            tooltip: context
                                .locale.app_associated_domains_dialog_add_button,
                            icon: const Icon(FluentIcons.add_20_filled),
                            onPressed: _addDomain,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      20.vBox,

                      /// Added domains
                      if (_domains.isEmpty)
                        StyledText(
                          context.locale.app_associated_domains_dialog_empty,
                          isSubtitle: true,
                          textAlign: TextAlign.center,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _domains
                              .map(
                                (host) => InputChip(
                                  label: StyledText(host, fontSize: 13),
                                  avatar: Icon(
                                    FluentIcons.globe_20_regular,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  onDeleted: () => _removeDomain(host),
                                  deleteIcon: const Icon(
                                    FluentIcons.dismiss_20_regular,
                                    size: 16,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: Text(context.locale.dialog_button_cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.maybePop(context, _domains),
                  child: Text(context.locale.dialog_button_set),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
