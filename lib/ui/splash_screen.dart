import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/auth_service.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/persona_service.dart';
import 'package:nlp_digitox/config/navigation/navigation_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/providers/system/mindful_settings_provider.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/botanical_background.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/splash_aurora.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _haveAllEssentialPermissions = false;
  bool _isOnboardingDone = false;
  bool _isAccessProtected = false;
  bool _isAppUpdated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndInit();
  }

  void _checkAuthenticationAndInit() async {
    // Check if user is logged in with Firebase
    bool isLoggedIn = false;

    try {
      isLoggedIn = FirebaseAuthService.instance.isLoggedIn;
    } catch (e) {
      debugPrint('Firebase auth check failed: $e');
      // If Firebase is not available, skip login and go to onboarding
      isLoggedIn = false;
    }

    if (!isLoggedIn) {
      // Not logged in - redirect to login screen
      // Capture the navigator before the async gap so no BuildContext is
      // used after it (satisfies use_build_context_synchronously).
      final navigator = Navigator.of(context);
      await Future.delayed(250.ms);
      if (!mounted) return;
      navigator.pushReplacementNamed(AppRoutes.loginPath);
      return;
    }

    // User is logged in - proceed with normal initialization
    _checkOnboardingAndPerms();
  }

  void _checkOnboardingAndPerms() async {
    final perms =
        await ref.read(permissionProvider.notifier).fetchPermissionsStatus();

    final settings = await ref.read(mindfulSettingsProvider.notifier).init();
    _isOnboardingDone = settings.isOnboardingDone;
    _isAppUpdated = settings.appVersion !=
        MethodChannelService.instance.deviceInfo.mindfulVersion;

    _isAccessProtected =
        (await ref.read(parentalControlsProvider.notifier).init())
            .protectedAccess;
    _haveAllEssentialPermissions = perms.haveUsageAccessPermission &&
        perms.haveDisplayOverlayPermission &&
        perms.haveAlarmsPermission &&
        perms.haveNotificationPermission;

    // Q-8: Use PersonaService as the authoritative quiz-completion check.
    // If the persona is corrupted (flag true but key missing), isQuizCompleted()
    // returns false and the user is shown the onboarding/quiz again.
    final quizCompleted = await PersonaService.instance.isQuizCompleted();
    // Override _isOnboardingDone: only true if the quiz was actually completed
    // AND the MindfulSettings flag is set.
    _isOnboardingDone = _isOnboardingDone && quizCompleted;

    if (mounted) setState(() {});
    _isAccessProtected ? _authenticate() : _goToNextScreen(true);
  }

  void _goToNextScreen(bool shouldDelay) async {
    if (shouldDelay) await Future.delayed(250.ms);
    if (!mounted) return;

    if (_haveAllEssentialPermissions && _isOnboardingDone) {
      NavigationService.instance.init(showChangeLogsToo: _isAppUpdated);
    } else {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.onboardingPath,
        arguments: {"isOnboardingDone": _isOnboardingDone},
      );
    }
  }

  void _authenticate() async {
    final isAuthenticated = await AuthService.instance.authenticate();

    /// Return if not mounted
    if (!mounted) return;

    /// If removed locks
    if (isAuthenticated == null) {
      context.showSnackAlert(
        context.locale.protected_access_removed_lock_snack_alert,
        icon: FluentIcons.fingerprint_20_filled,
      );
      return;
    }

    /// If aborted the auth
    if (!isAuthenticated) {
      context.showSnackAlert(
        context.locale.protected_access_failed_lock_snack_alert,
        icon: FluentIcons.fingerprint_20_filled,
      );

      return;
    }

    _goToNextScreen(false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) => SystemNavigator.pop(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
        ),
        body: BotanicalBackground(
          // Modern aurora-mesh wash layered over the botanical photo,
          // giving the splash a soft gradient-glow feel.
          child: SplashAurora(
            child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    /// Brand mark — gradient-ring orb over a soft glow plaque.
                    ///
                    /// A conic gradient ring + a rounded-rect glass plaque
                    /// reads more "modern launch screen" than the old circular
                    /// breathing chip. The logo sits in a rounded square so
                    /// the artwork renders cleanly with its own corners.
                    Container(
                      width: 184,
                      height: 184,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(44),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.16),
                            DesignPalette.gold.withValues(alpha: 0.10),
                          ],
                        ),
                        border: Border.all(
                          color: DesignPalette.gold
                              .withValues(alpha: isDark ? 0.40 : 0.30),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.18),
                            blurRadius: 48,
                            offset: const Offset(0, 18),
                          ),
                          BoxShadow(
                            color: DesignPalette.gold.withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/logo-prev.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.12, end: 0),

                    const SizedBox(height: 28),

                    /// Wordmark
                    Column(
                      children: [
                        /// Gold overline — the modern editorial kicker
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: DesignPalette.gold.withValues(alpha: isDark ? 0.14 : 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: StyledText(
                            'DIGITAL WELLBEING',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                            color: DesignPalette.gold,
                          ),
                        ),

                        StyledText(
                          'NLP digitox',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          isHeadline: true,
                          color: colorScheme.onSurface,
                        ),

                        const SizedBox(height: 10),

                        StyledText(
                          'Presence over pixels. Balance begins here.',
                          fontSize: 15,
                          isSubtitle: true,
                          height: 1.4,
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.12, end: 0),

                    const Spacer(flex: 4),

                    /// Protected-access unlock CTA
                    _isAccessProtected
                        ? PillButton(
                            label: context.locale.unlock_button_label,
                            icon: FluentIcons.fingerprint_20_regular,
                            onPressed: _authenticate,
                          )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 320.ms)
                            .slideY(begin: 0.1, end: 0)
                        : const SizedBox.shrink(),

                    const SizedBox(height: 20),

                    /// Presence Over Pixels — signature badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: DesignPalette.sage.withValues(alpha: isDark ? 0.20 : 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: DesignPalette.fern
                                .withValues(alpha: isDark ? 0.45 : 0.30),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DesignPalette.sage.withValues(alpha: isDark ? 0.12 : 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: StyledText(
                          'Presence Over Pixels',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: DesignPalette.fern,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 480.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 26),

                    /// Sweeping light bar — the "in progress" shimmer used by
                    /// modern splash screens instead of an unfilled progress
                    /// row. Sits at the bottom edge; animations only paint,
                    /// no layout changes.
                    const _SplashShimmerBar(),

                    const SizedBox(height: 14),
                  ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin rounded bar whose bright band sweeps left → right on a loop,
/// i.e. the "loading shimmer" of the modern splash screen.
class _SplashShimmerBar extends StatefulWidget {
  const _SplashShimmerBar();

  @override
  State<_SplashShimmerBar> createState() => _SplashShimmerBarState();
}

class _SplashShimmerBarState extends State<_SplashShimmerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final glowColor = DesignPalette.gold.withValues(alpha: isDark ? 0.55 : 0.45);

    return SizedBox(
      width: 120,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final x = (t * 1.6 - 0.3).clamp(-0.3, 1.0);
                return Align(
                  alignment: Alignment(x * 2 - 1, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            glowColor.withValues(alpha: 0),
                            glowColor.withValues(alpha: 0.75),
                            colorScheme.primary,
                            glowColor.withValues(alpha: 0.75),
                            glowColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
