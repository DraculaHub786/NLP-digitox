import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/enums/app_theme_mode.dart';
import 'package:nlp_digitox/core/enums/default_home_tab.dart';
import 'package:nlp_digitox/config/app_constants.dart';

@DataClassName("DigitoxSettings")
class DigitoxSettingsTable extends Table {
  /// Pin the physical SQLite table name to its historical value so existing
  /// installs keep their data without a migration. The Dart class was
  /// rebranded from [MindfulSettingsTable], but the on-disk table must stay
  /// `mindful_settings_table`.
  @override
  String get tableName => 'mindful_settings_table';

  /// Unique ID for app settings
  IntColumn get id => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  /// Default theme mode for app
  IntColumn get themeMode => intEnum<AppThemeMode>()
      .withDefault(Constant(AppConstants.defaultThemeMode.index))();

  /// Default material color for app
  TextColumn get accentColor =>
      text().withDefault(const Constant(AppConstants.defaultMaterialColor))();

  /// Username shown on the dashboard
  TextColumn get username =>
      text().withDefault(const Constant(AppConstants.defaultUsername))();

  /// App Locale (Language code)
  TextColumn get localeCode =>
      text().withDefault(const Constant(AppConstants.defaultLocale))();

  /// Flag indicating if to use pure amoled black color for dark theme
  BoolColumn get useAmoledDark =>
      boolean().withDefault(const Constant(false))();

  /// Flag indicating if to use wallpaper colors for themes
  BoolColumn get useDynamicColors =>
      boolean().withDefault(const Constant(false))();

  /// Default initial home tab
  IntColumn get defaultHomeTab => intEnum<DefaultHomeTab>()
      .withDefault(Constant(DefaultHomeTab.dashboard.index))();

  /// Maximum number of weeks till the app's usage history will be kept
  IntColumn get usageHistoryWeeks => integer().withDefault(const Constant(4))();

  /// Number of emergency break passes left for today
  IntColumn get leftEmergencyPasses =>
      integer().withDefault(const Constant(3))();

  /// Timestamp of the last used emergency break
  DateTimeColumn get lastEmergencyUsed =>
      dateTime().withDefault(Constant(DateTime(0)))();

  /// Flag indicating if onboarding is completed or not
  BoolColumn get isOnboardingDone =>
      boolean().withDefault(const Constant(false))();

  /// The currently installed version of Digitox.
  /// Mainly used to show changelogs screen.
  TextColumn get appVersion => text().withDefault(const Constant(""))();
}
