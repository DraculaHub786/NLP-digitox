import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/navigation_service.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/features/onboarding/quiz.dart';
import 'package:nlp_digitox/models/permissions_model.dart';
import 'package:nlp_digitox/providers/system/digitox_settings_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/onboarding/onboarding_page.dart';
import 'package:nlp_digitox/ui/onboarding/permission_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    required this.isOnboardingDone,
    super.key,
  });

  final bool isOnboardingDone;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  ProviderSubscription? _subscription;
  final PageController _controller = PageController();
  final _animCurve = Curves.easeInOut;
  final _animDuration = AppConstants.defaultAnimDuration;
  late final List<Widget> _pages = [
    // Welcome — new front page
    OnboardingPage(
      title: context.locale.onboarding_page_welcome_title,
      imgArtPath: "assets/illustrations/onboarding_5.png",
      description: context.locale.onboarding_page_welcome_info,
      // The welcome page is the "animation just before the main screen" —
      // show the square logo mark here (same artwork as the splash).
      showLogo: true,
    ),
    // Statistics — new second page
    OnboardingPage(
      title: context.locale.onboarding_page_statistics_title,
      imgArtPath: "assets/illustrations/onboarding_6.png",
      description: context.locale.onboarding_page_statistics_info,
    ),
    // Master Focus
    OnboardingPage(
      title: context.locale.onboarding_page_one_title,
      imgArtPath: "assets/illustrations/onboarding_1.png",
      description: context.locale.onboarding_page_one_info,
    ),
    // Block Distractions
    OnboardingPage(
      title: context.locale.onboarding_page_two_title,
      imgArtPath: "assets/illustrations/onboarding_2.png",
      description: context.locale.onboarding_page_two_info,
    ),
    // Privacy First
    OnboardingPage(
      title: context.locale.onboarding_page_three_title,
      imgArtPath: "assets/illustrations/onboarding_3.png",
      description: context.locale.onboarding_page_three_info,
    ),
    const PermissionsPage(),
    OnboardingQuizPage(
      onComplete: _finishOnboarding,
      onPermissionsMissing: _goToPermissionsPage,
    ),
  ];

  @override
  void initState() {
    super.initState();

    /// Listen to permission changes and advance to the quiz page when
    /// user has granted all essential permissions (instead of finishing
    /// onboarding directly — the quiz still needs to be completed).
    _subscription = ref.listenManual<PermissionsModel>(
      permissionProvider,
      (_, perms) {
        final haveAllEssentialPermissions = perms.haveUsageAccessPermission &&
            perms.haveDisplayOverlayPermission &&
            perms.haveAlarmsPermission &&
            perms.haveNotificationPermission;

        if (!haveAllEssentialPermissions) return;
        _goToQuizPage();
        _subscription?.close();
      },
    );

    /// Go to permissions page if already done onboarding
    /// but user removed some essential permissions. Note: this only ever
    /// lands on the PermissionsPage, never back on the quiz — a returning
    /// user whose persona is already saved should never be asked to redo
    /// the quiz just because an OS permission got revoked.
    if (widget.isOnboardingDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToPermissionsPage();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.close();
  }

  void _finishOnboarding() async {
    if (mounted) {
      ref.read(digitoxSettingsProvider.notifier).markOnboardingDone();

      Future.delayed(
        200.ms,
        () {
          if (!mounted) return;
          NavigationService.instance
              .init(showChangeLogsToo: !widget.isOnboardingDone);
        },
      );
    }
  }

  /// Jumps to the PermissionsPage (second-to-last page). Used for a
  /// returning user who already has a saved persona and only needs to
  /// re-grant OS permissions after a reinstall.
  void _goToPermissionsPage() {
    if (mounted) {
      _controller.animateToPage(
        _pages.length - 2,
        duration: _animDuration,
        curve: _animCurve,
      );
    }
  }

  /// Jumps to the quiz page (last page). Only ever called once all
  /// essential permissions are confirmed granted.
  void _goToQuizPage() {
    if (mounted) {
      _controller.animateToPage(
        _pages.length - 1,
        duration: _animDuration,
        curve: _animCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    final isQuizPage = _pages[_currentPage] is OnboardingQuizPage;
    final isPermissionsPage = _pages[_currentPage] is PermissionsPage;
    final perms = ref.watch(permissionProvider);
    final haveAllEssentialPermissions = perms.haveUsageAccessPermission &&
        perms.haveDisplayOverlayPermission &&
        perms.haveAlarmsPermission &&
        perms.haveNotificationPermission;
    // Forward navigation is blocked while sitting on the PermissionsPage
    // until every essential permission is granted — this is what makes
    // granting permissions mandatory instead of just suggested.
    final blockedByMissingPermissions =
        isPermissionsPage && !haveAllEssentialPermissions;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) => SystemNavigator.pop(),
      child: Scaffold(
        body: Stack(
          children: [
            /// Onboarding Page
            PageView.builder(
              controller: _controller,
              // Swiping is disabled outright while permissions are missing
              // on the PermissionsPage — otherwise a swipe gesture could
              // reach the quiz page the same way the old Skip button did.
              // The back arrow button still works via IconButton.filledTonal
              // above, so the user isn't fully stuck.
              physics: blockedByMissingPermissions
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _pages[index],
              ),
            ),

            /// Overlay controls — hidden entirely on the quiz page
            /// because the quiz has its own self-contained navigation bar
            /// that would be covered by this overlay.
            if (!isQuizPage)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /// Bottom controls — tonal surface consistent with the
                      /// app's flat-card system (no frosted blur), keeping the
                      /// pill shape from the nav bar so controls read as a
                      /// single floating unit.
                      Container(
                        padding: const EdgeInsets.only(bottom: 32, top: 4),
                        decoration: BoxDecoration(
                          color: (Theme.of(context).brightness ==
                                  Brightness.dark
                              ? DesignPalette.darkGlassFill
                              : DesignPalette.lightGlassFill)
                              .withValues(alpha: 0.92),
                          border: Border.all(
                            color: (Theme.of(context).brightness ==
                                    Brightness.dark
                                ? DesignPalette.darkGlassBorder
                                : DesignPalette.lightGlassBorder)
                                .withValues(alpha: 0.5),
                            width: 1,
                          ),
                          borderRadius:
                              BorderRadius.circular(Radii.pill),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0.25
                                          : 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                              children: [
                                /// Page Dots
                                SmoothPageIndicator(
                                  controller: _controller,
                                  count: _pages.length,
                                  effect: ExpandingDotsEffect(
                                    dotWidth: 10,
                                    dotHeight: 10,
                                    spacing: 6,
                                    expansionFactor: 2.5,
                                    dotColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    activeDotColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),

                                /// Go to previous page
                                IconButton.filledTonal(
                                  onPressed: () => _controller.previousPage(
                                    curve: _animCurve,
                                    duration: _animDuration,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  icon: const Icon(
                                    FluentIcons.caret_left_20_filled,
                                  ),
                                ).animate(
                                  target:
                                      _currentPage > 0 && !isLastPage ? 1 : 0,
                                ).scale(duration: 150.ms),
                                4.hBox,

                                isLastPage

                                    /// Finish setup
                                    ? FilledButton(
                                        onPressed:
                                            haveAllEssentialPermissions
                                                ? () => _finishOnboarding()
                                                : null,
                                        child: Text(
                                          context.locale
                                              .onboarding_finish_setup_btn_label,
                                        ),
                                      ).animate(target: isLastPage ? 1 : 0).scale(
                                          duration: 250.ms,
                                          alignment: Alignment.centerRight,
                                        )

                                    /// Go to next page — disabled while on
                                    /// the PermissionsPage until every
                                    /// essential permission is granted, so
                                    /// permissions can't be swiped past.
                                    : IconButton.filled(
                                        padding: const EdgeInsets.all(10),
                                        onPressed: blockedByMissingPermissions
                                            ? null
                                            : () => _controller.nextPage(
                                                  curve: _animCurve,
                                                  duration: _animDuration,
                                                ),
                                        icon: const Icon(
                                          FluentIcons.caret_right_20_filled,
                                        ),
                                      ).animate(target: isLastPage ? 0 : 1)
                                        .scale(duration: 150.ms),
                              ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
