import 'dart:math';

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
import 'package:nlp_digitox/ui/common/breathing_widget.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/splash_particles_painter.dart';
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
        // Phase 3.1: full botanical background + drifting splash particles
        // (fancy animation stays on splash/onboarding per design decisions).
        body: BotanicalBackground(
          child: SplashParticles(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// Breathing logo — glass-chip style, consistent with the app
                  BreathingWidget(
                    dimension:
                        min(220, MediaQuery.of(context).size.width * 0.55),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: (isDark
                                  ? DesignPalette.darkGlassBorder
                                  : DesignPalette.lightGlassBorder)
                              .withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),

                  Column(
                    children: [
                      /// Title — serif display (Alice)
                      StyledText(
                        "NLP digitox",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        isHeadline: true,
                        color: colorScheme.onSurface,
                      ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 10),

                      /// Tag line
                      StyledText(
                        "Your digital detox companion",
                        fontSize: 16,
                        isSubtitle: true,
                      ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _isAccessProtected
                      ? PillButton(
                          label: context.locale.unlock_button_label,
                          icon: FluentIcons.fingerprint_20_regular,
                          onPressed: _authenticate,
                        ).animate().fadeIn(duration: 300.ms, delay: 550.ms).slideY(begin: 0.1, end: 0)
                      : const SizedBox.shrink(),

                  /// Presence Over Pixels — light green glass pill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: DesignPalette.sage.withValues(alpha: isDark ? 0.22 : 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: DesignPalette.fern
                              .withValues(alpha: isDark ? 0.45 : 0.30),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DesignPalette.sage.withValues(alpha: isDark ? 0.15 : 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: StyledText(
                        "Presence Over Pixels",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: DesignPalette.fern,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 700.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
