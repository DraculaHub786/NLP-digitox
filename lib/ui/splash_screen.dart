// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/auth_service.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/config/navigation/navigation_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/providers/system/mindful_settings_provider.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/breathing_widget.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_effects.dart';
import 'package:nlp_digitox/ui/common/modern_background.dart';
import 'package:nlp_digitox/ui/common/glassmorphic_container.dart';

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
      if (mounted) {
        await Future.delayed(250.ms);
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginPath);
      }
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
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: ModernGradientBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// Modern breathing logo with glassmorphic effect
              BreathingWidget(
                dimension: min(320, MediaQuery.of(context).size.width * 0.7),
                child: GlassmorphicContainer(
                  borderRadius: 160,
                  blur: 20,
                  opacity: 0.1,
                  padding: const EdgeInsets.all(60),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(40),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  /// Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ).createShader(bounds),
                    child: const StyledText(
                      "NLP digitox",
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Tag line
                  StyledText(
                    "Your digital detox companion",
                    fontSize: 18,
                    isSubtitle: true,
                  ),
                ],
              ),

              const Divider(color: Colors.transparent),
              _isAccessProtected
                  ? GlassButton(
                      onPressed: _authenticate,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FluentIcons.fingerprint_20_regular, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(context.locale.unlock_button_label),
                        ],
                      ),
                    )
                  : 0.vBox,

              ///Presence Over Pixels
              GlassmorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                borderRadius: 16,
                opacity: 0.05,
                blur: 10,
                child: const StyledText(
                  "Presence Over Pixels",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ].animate(
              effects: DefaultEffects.transitionIn,
              delay: 100.ms,
              interval: 100.ms,
            ),
          ),
        ),
      ),
    );
  }
}
