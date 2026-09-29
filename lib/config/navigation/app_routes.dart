
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/enums/usage_type.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/auth/forgot_password_new_screen.dart';
import 'package:nlp_digitox/ui/auth/forgot_password_otp_screen.dart';
import 'package:nlp_digitox/ui/auth/forgot_password_request_screen.dart';
import 'package:nlp_digitox/ui/auth/login_screen.dart';
import 'package:nlp_digitox/ui/auth/signup_screen.dart';
import 'package:nlp_digitox/ui/onboarding/onboarding_screen.dart';
import 'package:nlp_digitox/ui/screens/active_session/active_session_screen.dart';
import 'package:nlp_digitox/ui/screens/achievements/achievements_screen.dart';
import 'package:nlp_digitox/ui/screens/app_dashboard/app_dashboard_screen.dart';
import 'package:nlp_digitox/ui/screens/change_logs/change_logs_screen.dart';
import 'package:nlp_digitox/ui/screens/chat/chat_screen.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_screen.dart';
import 'package:nlp_digitox/ui/screens/home/home_screen.dart';
import 'package:nlp_digitox/ui/screens/parental_controls/parental_controls_gate.dart';
import 'package:nlp_digitox/ui/screens/profile/profile_screen.dart';
import 'package:nlp_digitox/ui/screens/restriction_groups/restriction_groups_screen.dart';
import 'package:nlp_digitox/ui/screens/settings/settings_screen.dart';
import 'package:nlp_digitox/ui/screens/shorts_blocking/shorts_blocking_screen.dart';
import 'package:nlp_digitox/ui/screens/notifications/notifications_screen.dart';
import 'package:nlp_digitox/ui/screens/websites_blocking/websites_blocking_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/sessions_list_screen.dart';
import 'package:nlp_digitox/ui/splash_screen.dart';

class AppRoutes {
  static const String loginPath = '/login';
  static const String signupPath = '/signup';
  static const String forgotPasswordRequestPath = '/forgotPasswordRequest';
  static const String forgotPasswordOtpPath = '/forgotPasswordOtp';
  static const String forgotPasswordNewPath = '/forgotPasswordNew';
  static const String splashPath = '/splash';
  static const String rootSplashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String changeLogsPath = '/changeLogs';
  static const String settingsPath = '/settings';

  static const String homePath = '/home';
  static const String activeSessionPath = '/activeSession';
  static const String focusModePath = '/focus';

  static const String parentalControlsPath = '/parentalControls';
  static const String restrictionGroupsPath = '/restrictionGroups';
  static const String shortsBlockingPath = '/shortsBlocking';
  static const String websitesBlockingPath = '/websitesBlocking';

  static const String appDashboardPath = '/appDashboard';
  static const String notificationsPath = '/notifications';
  static const String achievementsPath = '/achievements';
  static const String profilePath = '/profile';
  static const String chatPath = '/chat';

  /// Shared focus sessions (create/join/browse)
  static const String sharedSessionsPath = '/sharedSessions';

  static final Map<String, Widget Function(BuildContext)> routes = {
    /// Auth screens
    loginPath: (context) => const LoginScreen(),
    signupPath: (context) => const SignupScreen(),
    forgotPasswordRequestPath: (context) => const ForgotPasswordRequestScreen(),
    forgotPasswordOtpPath: (context) => const ForgotPasswordOtpScreen(),
    forgotPasswordNewPath: (context) => const ForgotPasswordNewScreen(),

    /// Root
    rootSplashPath: (context) => const SplashScreen(),
    splashPath: (context) => const SplashScreen(),

    /// Onboarding screen
    onboardingPath: (context) => OnboardingScreen(
          isOnboardingDone:
              context.resolveParam<bool>("isOnboardingDone") ?? false,
        ),

    /// Change logs screen
    changeLogsPath: (context) => const ChangeLogsScreen(),

    /// Settings screen
    settingsPath: (context) => SettingsScreen(
          initialTabIndex: context.resolveParam<int>("tab"),
        ),

    /// Home screen
    homePath: (context) => HomeScreen(
          initialTabIndex: context.resolveParam<int>("tab"),
        ),

    /// Parental controls screen
    parentalControlsPath: (context) => const ParentalControlsGate(),

    /// Restriction groups screen
    restrictionGroupsPath: (context) => const RestrictionGroupsScreen(),

    /// Shorts blocking screen
    shortsBlockingPath: (context) => const ShortsBlockingScreen(),

    /// Websites blocking screen
    websitesBlockingPath: (context) => const WebsitesBlockingScreen(),

    /// Notifications list screen
    notificationsPath: (context) => NotificationsScreen(
          initialTabIndex: context.resolveParam<int>("tab"),
        ),

    /// Achievements screen
    achievementsPath: (context) => const AchievementsScreen(),

    /// Profile screen
    profilePath: (context) => const ProfileScreen(),

    /// Chat screen
    chatPath: (context) => const ChatScreen(),

    /// Shared focus sessions screen
    sharedSessionsPath: (context) => const SessionsListScreen(),

    /// Focus mode screen
    focusModePath: (context) => FocusScreen(
          initialTabIndex: context.resolveParam<int>("tab"),
        ),

    /// Active focus session screen
    activeSessionPath: (context) => const ActiveSessionScreen(),

    /// App dashboard screen
    appDashboardPath: (context) => AppDashboardScreen(
          packageName: context.resolveParam<String>("package") ?? "",
          initialUsageType:
              UsageType.values[(context.resolveParam<int>("usageType") ?? 0) % 2],
          selectedDay: context.resolveParam<DateTime>("day"),
        ),
  };
}
