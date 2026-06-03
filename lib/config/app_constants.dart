
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:nlp_digitox/core/enums/app_theme_mode.dart';

class AppConstants {
  // App Defaults
  static const defaultThemeMode = AppThemeMode.system;
  static const defaultMaterialColor = "Indigo";
  static const defaultLocale = "en";
  static const defaultUsername = "Achiever";
  static const defaultCurve = Curves.fastEaseInToSlowEaseOut;
  static const defaultAnimDuration = Duration(milliseconds: 350);

  // Custom packages
  static const appPackageName = "com.nlp.digitox";
  static const removedAppPackage = "com.android.removed";
  static const tetheringAppPackage = "com.android.tethering";

  /// Urls
  static const githubUrl = "https://github.com/DraculaHub786/NLP-digitox";
  static const bmcUrl = "https://buymeacoffee.com/afjalansari29162";
  static const instagramUrl = "https://www.instagram.com/_afjal___ansari_?igsh=ZGlkZDU4eHF6NGM4";
  static const linkedInUrl = "https://www.linkedin.com/in/afjal-ansari-999067299";
  static const telegramUrl = "https://t.me/mdDracula";
  static const supportEmailUrl = "mailto:afjalansari29162@gmail.com";
  static const privacyPolicyUrl = "https://bemindful.vercel.app/privacy";
  static const faqsUrl = "https://bemindful.vercel.app/#faqs";

  static String githubChangeLogUrl(String appVersion) =>
      "https://github.com/DraculaHub786/NLP-digitox/releases/tag/$appVersion";

  static const githubIssueDirectUrl =
      "https://github.com/DraculaHub786/NLP-digitox/issues/new";

  static const githubSuggestionDirectUrl =
      "https://github.com/DraculaHub786/NLP-digitox/issues/new";

  static const gitHubDonationSectionUrl =
      "https://github.com/DraculaHub786/NLP-digitox#donate";

  static const githubFeedbackSectionUrl =
      "https://github.com/DraculaHub786/NLP-digitox#feedback-and-support";

  /// Returns localized list of days in a week in short
  ///  e.g., ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  static List<String> daysShort(BuildContext context) {
    List<String> shortDays = [];

    final firstMonday = DateTime(0, 1, 2);
    for (int i = 1; i <= 7; i++) {
      String shortDay =
          DateFormat.E(Localizations.localeOf(context).languageCode)
              .format(firstMonday.add(i.days));
      shortDays.add(shortDay);
    }

    return shortDays;
  }
}
