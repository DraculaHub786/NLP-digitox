// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get mindful_tagline => 'התמקדו במה שבאמת חשוב';

  @override
  String get unlock_button_label => 'פתח את הנעילה';

  @override
  String get permission_status_off => 'כבוי';

  @override
  String get permission_status_allowed => 'מותר';

  @override
  String get permission_status_not_allowed => 'אסור';

  @override
  String get permission_button_grant_permission => 'תן רשות';

  @override
  String get permission_button_agree_and_continue => 'מסכים והמשך';

  @override
  String get permission_button_not_now => 'לא עכשיו';

  @override
  String get permission_button_help => 'עזרה?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox מאובטח ב-100% ועובד במצב לא מקוון. אנחנו לא אוספים או מאחסנים נתונים אישיים כלשהם.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. לחץ על כפתור $button_label.';
  }

  @override
  String get permission_grant_step_two => '2. בחר NLP digitox במסך הבא.';

  @override
  String get permission_grant_step_three => '3. לחץ והפעל את המתג כמו למטה.';

  @override
  String get permission_notification_title => 'שלח הודעות';

  @override
  String get permission_alarms_title => 'אזעקות ותזכורות';

  @override
  String get permission_alarms_info =>
      'אנא הענק הרשאה להגדרת אזעקות ותזכורות. זה יאפשר ל-NLP digitox להתחיל את לוח הזמנים של שעות השינה שלך בזמן ולאפס טיימרים של אפליקציות מדי יום בחצות ולעזור לך להישאר על המסלול.';

  @override
  String get permission_alarms_device_tile_label =>
      'אפשר להגדיר אזעקות ותזכורות';

  @override
  String get permission_usage_title => 'גישה לשימוש';

  @override
  String get permission_usage_info =>
      'אנא הענק הרשאת גישה לשימוש. זה יאפשר ל-NLP digitox לנטר את השימוש באפליקציה ולנהל גישה לאפליקציות מסוימות, מה שמבטיח סביבה דיגיטלית ממוקדת ומבוקרת יותר.';

  @override
  String get permission_usage_device_tile_label => 'אפשר גישה לשימוש';

  @override
  String get permission_overlay_title => 'שכבת-על לתצוגה';

  @override
  String get permission_overlay_info =>
      'אנא הענק הרשאת שכבת-על לתצוגה. זה יאפשר ל-NLP digitox להציג שכבת-על כאשר אפליקציה מושהית נפתחת, ויעזור לך להישאר ממוקד ולשמור על לוח הזמנים שלך.';

  @override
  String get permission_overlay_device_tile_label =>
      'אפשר תצוגה מעל אפליקציות אחרות';

  @override
  String get permission_accessibility_title => 'נגישות';

  @override
  String get permission_accessibility_info =>
      'אנא הענק הרשאת נגישות. זה יאפשר ל-NLP digitox להגביל את הגישה לתוכן וידאו בצורת קצר (למשל, Reels, Shorts) בתוך אפליקציות מדיה חברתית ודפדפנים, ולסנן אתרים לא הולמים.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox דורש הרשאת נגישות כדי לחסום תוכן ואתרי אינטרנט קצרים ביעילות.';

  @override
  String get permission_accessibility_device_tile_label =>
      'השתמש ב-NLP digitox';

  @override
  String get permission_dnd_title => 'אל תפריע';

  @override
  String get permission_dnd_info =>
      'אנא הענק גישה אל \'נא לא להפריע\'. זה יאפשר ל-NLP digitox להתחיל ולעצור את מצב \'נא לא להפריע\' במהלך לוח הזמנים של שעת השינה.';

  @override
  String get permission_dnd_tile_title => 'התחל DND';

  @override
  String get permission_dnd_tile_subtitle => 'הפעל גם את מצב \'נא לא להפריע\'.';

  @override
  String get permission_battery_optimization_tile_title =>
      'התעלם מאופטימיזציה של סוללות';

  @override
  String get permission_battery_optimization_status_enabled => 'כבר ללא הגבלה';

  @override
  String get permission_battery_optimization_status_disabled =>
      'השבת את הגבלת הרקע';

  @override
  String get permission_battery_optimization_allow_info =>
      'התרת \'התעלם מאופטימיזציה של סוללה\' תעניק אוטומטית את הרשאת \'התראות ותזכורות\' במכשירים מסוימים.';

  @override
  String get permission_vpn_title => 'צור VPN';

  @override
  String get permission_vpn_info =>
      'אנא הענק הרשאה ליצור חיבור לרשת וירטואלית פרטית (VPN). זה יאפשר ל-NLP digitox להגביל את הגישה לאינטרנט עבור יישומים ייעודיים על ידי יצירת VPN מקומי במכשיר.';

  @override
  String get permission_admin_title => 'מנהל מערכת';

  @override
  String get permission_admin_info =>
      'הרשאות ניהול נחוצות רק עבור פעולות חיוניות כדי להבטיח שהאפליקציה פועלת כראוי ונותרה חסינת פגיעה.';

  @override
  String get permission_admin_snack_alert =>
      'ניתן לבטל את ההגנה מפני חבלה רק במהלך חלון הזמן שנבחר.';

  @override
  String get permission_notification_access_title => 'גישה להודעות';

  @override
  String get permission_notification_access_info =>
      'אנא הענק הרשאת גישה להתראות. זה יאפשר ל-NLP digitox לארגן את ההתראות שלך ולמסור אותן לפי לוח הזמנים שלך.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox דורש גישה להתראות להודעות אצווה ותזמון.';

  @override
  String get permission_notification_access_device_tile_label =>
      'אפשר גישה להתראות';

  @override
  String get day_today => 'היום';

  @override
  String get day_yesterday => 'אתמול';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ימים',
      one: '1 יום',
      zero: '0 ימים',
    );
    return '$_temp0';
  }

  @override
  String nHours(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString שעות',
      one: '1 שעה',
      zero: '0 שעות',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString דקות',
      one: '1 דקה',
      zero: '0 דקות',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString שניות',
      one: '1 שנייה',
      zero: '0 שניות',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'ו';

  @override
  String get timer_status_active => 'פעיל';

  @override
  String get timer_status_paused => 'מושהה';

  @override
  String get create_button => 'צור';

  @override
  String get update_button => 'עדכון';

  @override
  String get dialog_button_cancel => 'בטל';

  @override
  String get dialog_button_remove => 'הסר';

  @override
  String get dialog_button_set => 'סט';

  @override
  String get dialog_button_reset => 'אפס';

  @override
  String get dialog_button_infinite => 'אינסופי';

  @override
  String get schedule_start_label => 'התחל';

  @override
  String get schedule_end_label => 'סוף';

  @override
  String get exit_without_saving_dialog_info =>
      'האם אתה בטוח שברצונך לצאת מבלי לשמור?';

  @override
  String get development_dialog_info =>
      'NLP digitox נמצא כעת בפיתוח וייתכן שיש בו באגים או תכונות לא שלמות. אם אתה נתקל בבעיות כלשהן, אנא דווח עליהן כדי לעזור לנו להשתפר.\n\nתודה על המשוב שלך!';

  @override
  String get development_dialog_button_report_issue => 'דווח על בעיה';

  @override
  String get development_dialog_button_close => 'סגור';

  @override
  String get dnd_settings_tile_title => 'אל תפריע להגדרות';

  @override
  String get dnd_settings_tile_subtitle =>
      'נהל אילו אפליקציות והתראות יכולות להגיע אליך ב-DND.';

  @override
  String get quick_actions_heading => 'פעולות מהירות';

  @override
  String get select_distracting_apps_heading => 'בחר אפליקציות שמסיחות את הדעת';

  @override
  String get your_distracting_apps_heading => 'האפליקציות המסיחות את הדעת שלך';

  @override
  String get select_more_apps_heading => 'בחר אפליקציות נוספות';

  @override
  String get imp_distracting_apps_snack_alert =>
      'הוספת אפליקציות מערכת חשובות לרשימת האפליקציות המסיחות את הדעת אינה מותרת.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'השימוש וההגבלות במסך אינם זמינים עבור יישום זה. נכון לעכשיו, רק השימוש ברשת נגיש';

  @override
  String get create_group_fab_button => 'צור קבוצה';

  @override
  String get active_period_info =>
      'הגדר פרק זמן שבמהלכו תתאפשר גישה. מחוץ למסגרת זמן זו, הגישה תהיה מוגבלת.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'בחר לפחות אפליקציה אחת מסיח דעת.';

  @override
  String get donation_card_title => 'תמכו בנו';

  @override
  String get donation_card_info =>
      'NLP digitox הוא חינמי וקוד פתוח, שפותח עם חודשים של מסירות. אם זה עזר לך, התרומה שלך תהיה כל העולם עבורנו. כל תרומה עוזרת לנו להמשיך לשפר ולתחזק אותה לכולם.';

  @override
  String get operation_failed_snack_alert => 'הפעולה נכשלה, משהו השתבש!';

  @override
  String get donation_card_button_donate => 'לתרום';

  @override
  String get app_restart_dialog_title => 'צריך הפעלה מחדש';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox יופעל מחדש באופן אוטומטי לאחר סיום הספירה לאחור. אנא התאזר בסבלנות כאשר השינויים יחולו.';

  @override
  String get accessibility_tip =>
      'רוצה חסימה חכמה יותר וידידותית יותר לסוללה? אפשר הרשאת נגישות עבור NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox לא עובד? אפשר \'התעלם מאופטימיזציה של סוללה\' בהגדרות כדי לשמור על פעילות חלקה.';

  @override
  String get invincible_mode_tip =>
      'הסרת הגבלות בטעות? השתמש במצב בלתי מנוצח כדי לנעול אותם עד למחרת או לחלון ההתאמה.';

  @override
  String get glance_usage_tip =>
      'רוצים תובנות? עיין בקטע מבט כדי להציג את דפוסי השימוש וזמן המסך שלך.';

  @override
  String get tamper_protection_tip =>
      'מסיר את ההתקנה של NLP digitox? הפעל תחילה את חלון הסרת ההתקנה כדי להשבית בבטחה את הגנת חבלה.';

  @override
  String get notification_blocking_tip =>
      'רוצים להפחית את הסחות הדעת? השתמש בחסימת התראות כדי להשתיק אפליקציות נבחרות.';

  @override
  String get usage_history_tip =>
      'רוצה לחשוב על ההרגלים שלך? בדוק את היסטוריית השימוש כדי לראות דפוסי עבר.';

  @override
  String get focus_mode_tip =>
      'צריך מיקוד עמוק? הפעל את מצב מיקוד כדי לחסום אפליקציות והתראות במהלך משימות.';

  @override
  String get bedtime_reminder_tip =>
      'רוצה לשפר את השינה שלך? הגדר תזכורת לשעת השינה לנוח מדי לילה.';

  @override
  String get custom_blocking_tip =>
      'צריכים חוויה מותאמת אישית? צור כללי חסימת אפליקציות המתאימים לצרכים שלך.';

  @override
  String get session_timeline_tip =>
      'רוצה לעקוב אחר מפגשי מיקוד? הצג את ציר הזמן כדי לראות את מסע המיקוד שלך.';

  @override
  String get short_content_blocking_tip =>
      'מוסחת על ידי אפליקציות חברתיות? חסום תוכן קצר באינסטגרם, יוטיוב וכו\' כדי להישאר ממוקד.';

  @override
  String get parental_controls_tip =>
      'צריכים בקרת הורים? הגדר הגבלות למכשיר של ילדך כדי להבטיח חוויה בטוחה.';

  @override
  String get notification_batching_tip =>
      'רוצים להפחית את הסחות הדעת? השתמש ב-Notification Batching כדי לקבץ הודעות ולבדוק אותן בבת אחת.';

  @override
  String get notification_scheduling_tip =>
      'צריך לנהל התראות? תזמן מתי אתה מקבל התראות עבור אפליקציות ספציפיות.';

  @override
  String get quick_focus_tile_tip =>
      'זקוק לגישה מהירה למיקוד? הוסף אריח פוקוס מהיר כדי להפעיל באופן מיידי את מצב פוקוס.';

  @override
  String get app_shortcuts_tip =>
      'רוצה גישה מיידית לאפליקציה? הוסף קיצורי דרך על ידי לחיצה ארוכה על סמל האפליקציה לפעולות מהירות.';

  @override
  String get backup_usage_db_tip =>
      'רוצה לשמור את הנתונים שלך? גבה את מסד הנתונים של השימוש שלך כדי לשמור על הרישומים שלך בטוחים.';

  @override
  String get dynamic_material_color_tip =>
      'רוצה עיצוב מותאם אישית? אפשר חומר דינמי שאתה צובע כך שיתאים לנושא המכשיר שלך.';

  @override
  String get amoled_dark_theme_tip =>
      'רוצים לחסוך בסוללה? השתמש ב-AMOLED Dark Theme כדי להפחית את צריכת החשמל במסכי OLED.';

  @override
  String get customize_usage_history_tip =>
      'רוצה לשמור היסטוריית שימוש? התאם אישית כמה שבועות של נתונים לאחסן בהיסטוריית שימוש.';

  @override
  String get grouped_apps_blocking_tip =>
      'רוצים לחסום אפליקציות ביחד? השתמש בקבוצות הגבלה כדי לקבץ מגבלות אפליקציות ולחסום אפליקציות מרובות בו-זמנית.';

  @override
  String get websites_blocking_tip =>
      'רוצה חווית גלישה נקייה יותר? חסום אתרים מותאמים אישית או NSFW לזמן מקוון ממוקד יותר.';

  @override
  String get data_usage_tip =>
      'רוצה לעקוב אחר הנתונים שלך? עקוב אחר השימוש בנתונים בנייד וב-Wi-Fi שלך לצריכת אינטרנט.';

  @override
  String get block_internet_tip =>
      'צריך לחסום את האינטרנט של אפליקציה? מנתק את האינטרנט עבור אפליקציה ספציפית מלוח המחוונים של האפליקציה.';

  @override
  String get emergency_passes_tip =>
      'צריך הפסקה? השתמש ב-3 כרטיסי חירום מדי יום כדי לבטל את חסימת האפליקציות באופן זמני למשך 5 דקות.';

  @override
  String get onboarding_skip_btn_label => 'דלג';

  @override
  String get onboarding_finish_setup_btn_label => 'סיים את ההגדרה';

  @override
  String get onboarding_page_welcome_title => 'ברוכים הבאים ל-NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'קחו שליטה על החיים הדיגיטליים שלכם ובנו הרגלי מסך בריאים יותר. NLP digitox עוזר לכם להישאר ממוקדים, לצמצם הסחות דעת ולקבל החלטות מודעות בכל יום.';

  @override
  String get onboarding_page_statistics_title => 'הכירו את ההרגלים שלכם.';

  @override
  String get onboarding_page_statistics_info =>
      'הבינו את הדפוסים הדיגיטליים שלכם עם תובנות מפורטות על זמן מסך, שימוש באפליקציות ומגמות ריכוז. עקבו אחר ההתקדמות שלכם וראו איך שינויים קטנים מובילים לשיפורים גדולים.';

  @override
  String get onboarding_page_one_title => 'מאסטר פוקוס.';

  @override
  String get onboarding_page_one_info =>
      'השהה אפליקציות שמסיחות את הדעת, חסום תוכן קצר והישאר על המסלול עם הפעלות מיקוד הניתנות להתאמה אישית. בין אם אתה עובד, לומד או נרגע, NLP digitox עוזר לך להישאר בשליטה.';

  @override
  String get onboarding_page_two_title => 'חסימת הסחות דעת.';

  @override
  String get onboarding_page_two_info =>
      'הגדר מגבלות שימוש, השהה אוטומטית אפליקציות וצור הרגלים דיגיטליים בריאים יותר. השתמש במצב שעת השינה כדי להירגע וליהנות מלילה נטול הסחות דעת.';

  @override
  String get onboarding_page_three_title => 'פרטיות ראשית.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox הוא 100% קוד פתוח ופועל באופן לא מקוון לחלוטין. אנחנו לא אוספים או משתפים את הנתונים האישיים שלך - הפרטיות שלך מובטחת בכל דרך.';

  @override
  String get onboarding_page_permissions_title => 'הרשאות חיוניות.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox דורש הרשאות חיוניות כדי לעקוב ולנהל את זמן המסך שלך, כדי לעזור להפחית הסחות דעת ולשפר את המיקוד.';

  @override
  String get dashboard_tab_title => 'לוח מחוונים';

  @override
  String get focus_now_fab_button => 'תתמקד עכשיו';

  @override
  String get welcome_greetings => 'ברוך שובך,';

  @override
  String get username_snack_alert => 'לחץ לחיצה ארוכה כדי לערוך את שם המשתמש.';

  @override
  String get username_dialog_title => 'שם משתמש';

  @override
  String get username_dialog_info =>
      'הזן את שם המשתמש שלך שיוצג בלוח המחוונים.';

  @override
  String get username_dialog_button_apply => 'החל';

  @override
  String get glance_tile_title => 'מבט';

  @override
  String get glance_tile_subtitle => 'תעיף מבט מהיר על השימוש שלך.';

  @override
  String get parental_controls_tile_subtitle =>
      'מצב בלתי מנוצח והגנה מפני חבלה.';

  @override
  String get restrictions_heading => 'הגבלות';

  @override
  String get apps_blocking_tile_title => 'חסימת אפליקציות';

  @override
  String get apps_blocking_tile_subtitle => 'הגבל אפליקציות במספר דרכים.';

  @override
  String get grouped_apps_blocking_tile_title => 'חסימת אפליקציות מקובצות';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'הגבל קבוצת אפליקציות בו זמנית.';

  @override
  String get shorts_blocking_tile_subtitle => 'הגבל תוכן קצר במספר פלטפורמות.';

  @override
  String get websites_blocking_tile_subtitle =>
      'הגבל אתרים למבוגרים ואתרים מותאמים אישית.';

  @override
  String get screen_time_label => 'זמן מסך';

  @override
  String get total_data_label => 'סך הנתונים';

  @override
  String get mobile_data_label => 'נתונים ניידים';

  @override
  String get wifi_data_label => 'נתוני Wifi';

  @override
  String get focus_today_label => 'התמקד היום';

  @override
  String get focus_weekly_label => 'התמקד מדי שבוע';

  @override
  String get focus_monthly_label => 'התמקד מדי חודש';

  @override
  String get focus_lifetime_label => 'פוקוס לכל החיים';

  @override
  String get longest_streak_label => 'הרצף הארוך ביותר';

  @override
  String get current_streak_label => 'רצף נוכחי';

  @override
  String get successful_sessions_label => 'מפגשים מוצלחים';

  @override
  String get failed_sessions_label => 'הפעלות שנכשלו';

  @override
  String get statistics_tab_title => 'סטטיסטיקה';

  @override
  String get screen_segment_label => 'מסך';

  @override
  String get data_segment_label => 'נתונים';

  @override
  String get mobile_label => 'נייד';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'האפליקציות הנפוצות ביותר';

  @override
  String get show_all_apps_tile_title => 'הצג את כל האפליקציות';

  @override
  String get search_apps_hint => 'חפש אפליקציות...';

  @override
  String get notifications_tab_title => 'התראות';

  @override
  String get notifications_tab_info =>
      'הודעות אצווה מאפליקציות וקבע לוחות זמנים כמו בוקר, צהריים, ערב ולילה. הישאר מעודכן ללא הפרעות תמידיות.';

  @override
  String get batched_apps_tile_title => 'אפליקציות באצווה';

  @override
  String get batch_recap_dropdown_title => 'סוג סיכום אצווה';

  @override
  String get batch_recap_dropdown_info =>
      'בחר מה לדחוף כאשר לוח זמנים מופעל - כל ההתראות או רק סיכום.';

  @override
  String get batch_recap_option_summery_only => 'סיכום בלבד';

  @override
  String get batch_recap_option_all_notifications => 'כל ההתראות';

  @override
  String get notification_history_tile_title => 'היסטוריית הודעות';

  @override
  String get store_all_tile_title => 'אחסן את כל ההתראות';

  @override
  String get store_all_tile_subtitle => 'שמור גם הודעות שאינן באצווה.';

  @override
  String get schedules_heading => 'לוחות זמנים';

  @override
  String get new_schedule_fab_button => 'לוח זמנים חדש';

  @override
  String get new_schedule_dialog_info =>
      'הזן שם ללוח הזמנים של ההתראות כדי לעזור לזהות אותו בקלות.';

  @override
  String get new_schedule_dialog_field_label => 'שם לוח זמנים';

  @override
  String get bedtime_tab_title => 'שעת השינה';

  @override
  String get bedtime_tab_info =>
      'הגדר את לוח השינה שלך על ידי בחירת פרק זמן וימים בשבוע. בחר אפליקציות שמסיחות את הדעת כדי לחסום ולהפעיל את מצב \'נא לא להפריע\' (DND) ללילה שקט.';

  @override
  String get schedule_tile_title => 'לוח זמנים';

  @override
  String get schedule_tile_subtitle => 'הפעל או השבת את לוח הזמנים היומי.';

  @override
  String get bedtime_no_days_selected_snack_alert => 'בחר לפחות יום אחד בשבוע.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'משך זמן השינה הכולל חייב להיות לפחות 30 דקות.';

  @override
  String get distracting_apps_tile_title => 'אפליקציות מסיחות דעת';

  @override
  String get distracting_apps_tile_subtitle =>
      'בחר אילו אפליקציות מסיחות את דעתך משגרת השינה שלך.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'שינויים ברשימת האפליקציות המסיחות את הדעת אינם מותרים בזמן שתזמון שעת השינה פעיל.';

  @override
  String get parental_controls_tab_title => 'בקרת הורים';

  @override
  String get invincible_mode_heading => 'מצב בלתי מנוצח';

  @override
  String get invincible_mode_tile_title => 'הפעל מצב בלתי מנוצח';

  @override
  String get invincible_mode_info =>
      'כאשר מצב בלתי מנוצח מופעל, לא תוכל להתאים את המגבלות שנבחרו לאחר שתגיע למכסה היומית שלך. עם זאת, אתה יכול לבצע שינויים בתוך חלון נבחר של 10 דקות בלתי מנוצח.';

  @override
  String get invincible_mode_snack_alert =>
      'עקב מצב בלתי מנוצח, שינויים בהגבלות אינם מותרים.';

  @override
  String get invincible_mode_dialog_info =>
      'האם אתה בטוח לחלוטין שאתה רוצה להפעיל מצב בלתי מנוצח? פעולה זו היא בלתי הפיכה. ברגע שהמצב הבלתי מנוצח מופעל, אינך יכול לכבות אותו כל עוד האפליקציה הזו מותקנת במכשיר שלך.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'לא ניתן לכבות את מצב Invincible כל עוד האפליקציה הזו נשארת מותקנת במכשיר שלך.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'תתחיל בכל זאת';

  @override
  String get invincible_mode_include_timer_tile_title => 'כלול טיימר';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'כלול מגבלת השקה';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'כלול תקופה פעילה';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'הגבלות אפליקציה';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'מנע שינויים בהגבלות שנבחרו באפליקציה לאחר חריגה מהמגבלות היומיות.';

  @override
  String get invincible_mode_group_restrictions_tile_title => 'הגבלות קבוצתיות';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'מנע שינויים בהגבלות שנבחרו בקבוצה לאחר חריגה מהמגבלות היומיות.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'כלול טיימר למכנסיים קצרים';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'מונע שינויים לאחר הגעת מגבלת המכנס היומי שלך.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'כלול את שעת השינה';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'מונע שינויים במהלך לוח הזמנים הפעיל של שעת השינה.';

  @override
  String get protected_access_tile_title => 'גישה מוגנת';

  @override
  String get protected_access_tile_subtitle =>
      'הגן על NLP digitox עם נעילת המכשיר שלך.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'אנא הגדר מנעול ביומטרי במכשיר שלך תחילה כדי להפעיל תכונה זו.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'נעילת המכשיר שלך הוסרה. כדי להמשיך, הגדר מנעול חדש.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'האימות נכשל. עליך לאמת את נעילת המכשיר שלך כדי להמשיך.';

  @override
  String get tamper_protection_tile_title => 'הגנה מפני חבלה';

  @override
  String get tamper_protection_tile_subtitle =>
      'מנע הסרת ההתקנה וכפה עצירה של האפליקציה.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'לאחר ההפעלה, לא תוכל להסיר את ההתקנה, לאלץ עצירה או לנקות את הנתונים של NLP digitox, אלא במהלך חלון הסרת ההתקנה שנבחר. אין דרכים לעקיפת הבעיה. \n\n המשך על אחריותך בלבד.';

  @override
  String get uninstall_window_tile_title => 'הסר חלון';

  @override
  String get uninstall_window_tile_subtitle =>
      'ניתן לבטל את ההגנה מפני חבלה תוך 10 דקות מהזמן שנבחר.';

  @override
  String get invincible_window_tile_title => 'חלון בלתי מנוצח';

  @override
  String get invincible_window_tile_subtitle =>
      'ניתן לשנות מגבלות נבחרות תוך 10 דקות מהזמן שנבחר.';

  @override
  String get shorts_blocking_tab_title => 'מכנסיים קצרים חוסמים';

  @override
  String get shorts_blocking_tab_info =>
      'שלוט כמה זמן אתה מבלה בתוכן קצר בפלטפורמות כמו אינסטגרם, YouTube, Snapchat ופייסבוק, כולל אתרי האינטרנט שלהם.';

  @override
  String get short_content_heading => 'תוכן קצר';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'שמאל מ-$timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'הגדר מגבלת זמן יומית לתוכן קצר. לאחר הגעת המגבלה שלך, התוכן הקצר יושהה עד חצות.';

  @override
  String get instagram_features_tile_title => 'אינסטגרם';

  @override
  String get instagram_features_tile_subtitle => 'הגבל תכונות באינסטגרם.';

  @override
  String get instagram_features_block_reels => 'הגבלת קטע סלילים.';

  @override
  String get instagram_features_block_explore => 'הגבל את קטע החקירה.';

  @override
  String get snapchat_features_tile_title => 'סנאפצ\'ט';

  @override
  String get snapchat_features_tile_subtitle => 'הגבל תכונות ב-Snapchat.';

  @override
  String get snapchat_features_block_spotlight => 'הגבל את קטע הזרקור.';

  @override
  String get snapchat_features_block_discover => 'הגבל קטע גילוי.';

  @override
  String get youtube_features_tile_title => 'יוטיוב';

  @override
  String get youtube_features_tile_subtitle => 'הגבל מכנסיים קצרים ביוטיוב.';

  @override
  String get facebook_features_tile_title => 'פייסבוק';

  @override
  String get facebook_features_tile_subtitle => 'הגבל סלילים בפייסבוק.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'הגבל מכנסיים קצרים ב-redit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'הגבל את הזנת הווידאו ב-X.';

  @override
  String get threads_features_tile_title => 'חוטים';

  @override
  String get threads_features_tile_subtitle => 'הגבל וידאו/סלילים ב-Threads.';

  @override
  String get websites_blocking_tab_title => 'חסימת אתרים';

  @override
  String get websites_blocking_tab_info =>
      'חסום אתרים למבוגרים וכל אתר מותאם אישית שתבחר כדי ליצור חוויה מקוונת בטוחה וממוקדת יותר. קח אחריות על הגלישה שלך והישאר ללא הסחות דעת.';

  @override
  String get adult_content_heading => 'תוכן למבוגרים';

  @override
  String get block_nsfw_title => 'חסום את Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'הגבל דפדפנים מלפתוח אתרי אינטרנט למבוגרים ופורנו.';

  @override
  String get block_nsfw_dialog_info =>
      'אתה בטוח? פעולה זו היא בלתי הפיכה. ברגע שחוסם אתרים למבוגרים מופעל, לא תוכל לכבות אותו כל עוד האפליקציה הזו מותקנת במכשיר שלך.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'חסום בכל מקרה';

  @override
  String get blocked_websites_heading => 'אתרים חסומים';

  @override
  String get blocked_websites_empty_list_hint =>
      'לחץ על כפתור \'+ הוסף אתר\' כדי להוסיף אתרים מסיחים שברצונך לחסום.';

  @override
  String get add_website_fab_button => 'הוסף אתר';

  @override
  String get add_website_dialog_title => 'אתר מסיח את הדעת';

  @override
  String get add_website_dialog_info => 'הזן כתובת אתר של אתר שאתה רוצה לחסום.';

  @override
  String get add_website_dialog_is_nsfw => 'האם אתר nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'אזהרה: לא ניתן להסיר אתרי Nsfw לאחר הוספה.';

  @override
  String get add_website_dialog_button_block => 'חסום';

  @override
  String get add_website_already_exist_snack_alert =>
      'כתובת האתר כבר נוספה לרשימת האתרים החסומים.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'כתובת אתר לא חוקית! לא ניתן לנתח את שם המארח.';

  @override
  String get remove_website_dialog_title => 'הסר אתר';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'אתה בטוח? אתה רוצה להסיר את \'$websitehost\' מאתרים חסומים.';
  }

  @override
  String get focus_tab_title => 'פוקוס';

  @override
  String get focus_tab_info =>
      'כאשר אתה צריך זמן להתמקד, התחל הפעלה חדשה על ידי בחירת הסוג, בחירת אפליקציות מסיחות להשהות והפעלת \'נא לא להפריע\' לריכוז ללא הפרעה.';

  @override
  String get active_session_card_title => 'הפעלה פעילה';

  @override
  String get active_session_card_info =>
      'יש לך הפעלת מיקוד פעילה! לחץ על \'הצג\' כדי לבדוק את ההתקדמות שלך ולראות כמה זמן חלף.';

  @override
  String get active_session_card_view_button => 'הצג';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'הסרה של אפליקציות מרשימת האפליקציות המסיחות את הדעת אינה מותרת בזמן שהפעלת פוקוס פעילה. עם זאת, אתה עדיין יכול להוסיף אפליקציות נוספות לרשימה במהלך תקופה זו.';

  @override
  String get focus_profile_tile_title => 'פרופיל מיקוד';

  @override
  String get focus_session_duration_tile_title => 'משך הפגישה';

  @override
  String get focus_session_duration_tile_subtitle =>
      'אינסופי (אלא אם כן תפסיק)';

  @override
  String get focus_session_duration_dialog_info =>
      'אנא בחר את משך הזמן הרצוי לפגישת התמקדות זו, וקבע כמה זמן אתה רוצה להישאר ממוקד וללא הסחות דעת.';

  @override
  String get focus_profile_customization_tile_title => 'התאמה אישית של פרופיל';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'התאם אישית את ההגדרות עבור הפרופיל שנבחר.';

  @override
  String get focus_enforce_tile_title => 'לאכוף הפעלה';

  @override
  String get focus_enforce_tile_subtitle => 'מונע סיום מפגש לפני שנגמר הזמן.';

  @override
  String get focus_session_start_button => 'החליקו כדי להתחיל את הסשן';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'בחר לפחות אפליקציה אחת מסיח דעת כדי להתחיל הפעלת מיקוד';

  @override
  String get focus_session_already_active_snack_alert =>
      'כבר יש לך הפעלת מיקוד פעילה. אנא השלם או הפסק את ההפעלה הנוכחית שלך לפני שתתחיל הפעלה חדשה.';

  @override
  String get focus_session_type_study => 'לימוד';

  @override
  String get focus_session_type_work => 'עבודה';

  @override
  String get focus_session_type_exercise => 'פעילות גופנית';

  @override
  String get focus_session_type_meditation => 'מדיטציה';

  @override
  String get focus_session_type_creativeWriting => 'כתיבה יצירתית';

  @override
  String get focus_session_type_reading => 'קריאה';

  @override
  String get focus_session_type_programming => 'תכנות';

  @override
  String get focus_session_type_chores => 'מטלות';

  @override
  String get focus_session_type_projectPlanning => 'תכנון פרויקט';

  @override
  String get focus_session_type_artAndDesign => 'אמנות ועיצוב';

  @override
  String get focus_session_type_languageLearning => 'לימוד שפה';

  @override
  String get focus_session_type_musicPractice => 'תרגול מוזיקה';

  @override
  String get focus_session_type_selfCare => 'טיפול עצמי';

  @override
  String get focus_session_type_brainstorming => 'סיעור מוחות';

  @override
  String get focus_session_type_skillDevelopment => 'פיתוח מיומנות';

  @override
  String get focus_session_type_research => 'מחקר';

  @override
  String get focus_session_type_networking => 'רשת';

  @override
  String get focus_session_type_cooking => 'בישול';

  @override
  String get focus_session_type_sportsTraining => 'אימון ספורט';

  @override
  String get focus_session_type_restAndRelaxation => 'מנוחה ורגיעה';

  @override
  String get focus_session_type_other => 'אחר';

  @override
  String get timeline_tab_title => 'ציר זמן';

  @override
  String get focus_timeline_tab_info =>
      'חקור את מסע המיקוד שלך על ידי בחירת תאריך מלוח השנה. עקוב אחר ההתקדמות שלך, בדוק מחדש את ההצלחות שלך ולמד מהאתגרים.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'הזמן הפרודוקטיבי הכולל שלך עבור החודש הנבחר הוא $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'ימים פרודוקטיביים';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'היו לך סה\"כ ימים פרודוקטיביים של $daysCount בחודש הנבחר.';
  }

  @override
  String get selected_day_focused_time_label => 'זמן ממוקד';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'הזמן הממוקד הכולל שלך עבור היום שנבחר הוא $timeString.';
  }

  @override
  String get calender_heading => 'לוח שנה';

  @override
  String get your_sessions_heading => 'המפגשים שלך';

  @override
  String get your_sessions_empty_list_hint =>
      'לא נרשמו הפעלות מיקוד עבור היום שנבחר.';

  @override
  String get focus_session_tile_timestamp_label => 'חותמת זמן';

  @override
  String get focus_session_tile_duration_label => 'משך זמן';

  @override
  String get focus_session_tile_reflection_label => 'השתקפות';

  @override
  String get focus_session_state_active => 'פעיל';

  @override
  String get focus_session_state_successful => 'מוצלח';

  @override
  String get focus_session_state_failed => 'נכשל';

  @override
  String get active_session_tab_title => 'מושב';

  @override
  String get active_session_none_warning =>
      'לא נמצאה הפעלה פעילה. חוזרים למסך הבית.';

  @override
  String get active_session_dialog_button_keep_pushing => 'תמשיך לדחוף';

  @override
  String get active_session_finish_dialog_title => 'סיים';

  @override
  String get active_session_finish_dialog_info =>
      'תישאר חזק! אתה בונה מיקוד בעל ערך. האם אתה בטוח שברצונך לסיים את מפגש המיקוד הזה? כל רגע נוסף נחשב למטרותיך.';

  @override
  String get active_session_giveup_dialog_title => 'לוותר';

  @override
  String get active_session_giveup_dialog_info =>
      'רגע! אתה כמעט שם אל תוותר עכשיו! האם אתה בטוח שברצונך לסיים את מפגש המיקוד הזה מוקדם? ההתקדמות תאבד.';

  @override
  String get active_session_reflection_dialog_title => 'השתקפות מושב';

  @override
  String get active_session_reflection_dialog_info =>
      'הקדישו רגע להרהר על ההתקדמות שלכם. מה המטרה שלך למפגש הזה? מה השגת במהלך הפגישה הזו?';

  @override
  String get active_session_reflection_dialog_tip =>
      'טיפ: תמיד תוכל לערוך את זה מאוחר יותר בציר הזמן של הפגישה.';

  @override
  String get active_session_giveup_snack_alert =>
      'ויתרת! אל תדאג, אתה יכול להשתפר בפעם הבאה. כל מאמץ חשוב - פשוט תמשיך';

  @override
  String get active_session_quote_one => 'כל צעד חשוב, הישארו חזקים ותמשיכו';

  @override
  String get active_session_quote_two => 'הישארו ממוקדים! אתה מתקדם מדהים';

  @override
  String get active_session_quote_three => 'אתה מוחץ את זה! תמשיך במומנטום';

  @override
  String get active_session_quote_four => 'רק עוד קצת לסיום, אתה מצליח פנטסטי';

  @override
  String active_session_quote_five(String durationString) {
    return 'מזל טוב 🎉 \n השלמת את סשן המיקוד שלך של $durationString.\n\n עבודה מצוינת, תמשיך בעבודה המדהימה';
  }

  @override
  String get restriction_groups_tab_title => 'קבוצות הגבלה';

  @override
  String get restriction_groups_tab_info =>
      'הגדר מגבלת זמן מסך משולבת עבור קבוצת אפליקציות. לאחר שהשימוש הכולל יגיע למגבלה שלך, כל האפליקציות בקבוצה יושהו כדי לעזור לשמור על מיקוד ואיזון.';

  @override
  String get restriction_group_time_spent_label => 'הזמן המושקע היום';

  @override
  String get restriction_group_time_left_label => 'נותר זמן היום';

  @override
  String get restriction_group_name_tile_title => 'שם הקבוצה';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'הזן שם לקבוצת ההגבלה כדי לעזור לזהות ולנהל אותה בקלות.';

  @override
  String get restriction_group_timer_tile_title => 'טיימר קבוצתי';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'הגדר מגבלת זמן יומית לקבוצה זו. לאחר הגעת המגבלה שלך, כל האפליקציות בקבוצה זו יושהו עד חצות.';

  @override
  String get restriction_group_active_period_tile_title => 'תקופה פעילה בקבוצה';

  @override
  String get remove_restriction_group_dialog_title => 'הסר את הקבוצה';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'אתה בטוח? אתה רוצה להסיר את \'$groupName\' מקבוצות הגבלה.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'הגדר טיימר או מגבלת תקופה פעילה.';

  @override
  String get notifications_empty_list_hint =>
      'לא נשלחו הודעות באצווה במשך היום.';

  @override
  String get conversations_label => 'שיחות';

  @override
  String get last_24_hours_heading => '24 השעות האחרונות';

  @override
  String get notification_timeline_tab_info =>
      'עיין בהיסטוריית ההתראות שלך על ידי בחירת תאריך מלוח השנה. ראה אילו אפליקציות משכו את תשומת הלב שלך וחשבו על ההרגלים הדיגיטליים שלך.';

  @override
  String get monthly_label => 'חודשי';

  @override
  String get daily_label => 'יומי';

  @override
  String get search_notifications_sheet_info =>
      'מצא בקלות התראות קודמות על ידי חיפוש בכותרת או בתוכן שלהן. עוזר לך לאתר במהירות התראות חשובות.';

  @override
  String get search_notifications_hint => 'חפש התראות...';

  @override
  String get search_notifications_empty_list_hint =>
      'לא נמצאו התראות התואמות לחיפוש שלך.';

  @override
  String get app_info_none_warning =>
      'לא ניתן היה למצוא את האפליקציה עבור החבילה הנתונה. חוזרים למסך הבית.';

  @override
  String get emergency_fab_button => 'חירום';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'פעולה זו תשהה את חוסם האפליקציות למשך 5 הדקות הבאות. נותרו לך אישורי $leftPassesCount. לאחר השימוש בכל הכרטיסים, האפליקציה תישאר חסומה עד חצות, או שהפעלת המיקוד הפעילה מסתיימת.\n\nהאם אתה עדיין רוצה להמשיך?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'השתמש בכל מקרה';

  @override
  String get emergency_started_snack_alert =>
      'חוסם האפליקציות מושהה ויחדש את החסימה בעוד 5 דקות.';

  @override
  String get emergency_already_active_snack_alert =>
      'חוסם האפליקציות כרגע מושהה או לא פעיל. אם הודעות מופעלות, תקבל עדכונים לגבי הזמן שנותר.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'השתמשת בכל כרטיסי החירום שלך. האפליקציות החסומות יישארו חסומות עד חצות, או שהפעלת המיקוד הפעילה תסתיים.';

  @override
  String get app_limit_status_not_set => 'לא מוגדר';

  @override
  String get app_timer_tile_title => 'טיימר אפליקציה';

  @override
  String get app_timer_picker_dialog_info =>
      'הגדר מגבלת זמן יומית עבור אפליקציה זו. לאחר הגעת המגבלה שלך, האפליקציה תושהה עד חצות.';

  @override
  String get usage_reminders_tile_title => 'תזכורות שימוש';

  @override
  String get usage_reminders_tile_subtitle =>
      'דחיפות עדינות בעת שימוש באפליקציות מתוזמנות.';

  @override
  String get app_launch_limit_tile_title => 'מגבלת השקה';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'הושק היום $count פעמים.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'הגדר כמה פעמים אתה יכול לפתוח את האפליקציה הזו בכל יום. לאחר הגעה למגבלה, הוא יושהה עד חצות.';

  @override
  String get app_active_period_tile_title => 'תקופה פעילה';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'מ-$startTime ל-$endTime';
  }

  @override
  String get internet_access_tile_title => 'גישה לאינטרנט';

  @override
  String get internet_access_tile_subtitle =>
      'כבה כדי לחסום את האינטרנט של האפליקציה.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'האינטרנט של $appName חסום.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'חסימת האינטרנט של $appName בוטלה.';
  }

  @override
  String get launch_app_tile_title => 'הפעל אפליקציה';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'פתח את $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'עבור להגדרות האפליקציה';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'נהל הגדרות אפליקציה כמו התראות, הרשאות, אחסון ועוד.';

  @override
  String get include_in_stats_tile_title => 'כלול בשימוש במסך';

  @override
  String get include_in_stats_tile_subtitle =>
      'כבה כדי לא לכלול את האפליקציה הזו מכלל השימוש במסך.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName אינו נכלל בשימוש הכולל במסך.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName כלול לשימוש הכולל במסך.';
  }

  @override
  String get general_tab_title => 'כללי';

  @override
  String get appearance_heading => 'מראה';

  @override
  String get theme_mode_tile_title => 'מצב ערכת נושא';

  @override
  String get theme_mode_system_label => 'מערכת';

  @override
  String get theme_mode_light_label => 'אור';

  @override
  String get theme_mode_dark_label => 'כהה';

  @override
  String get material_color_tile_title => 'צבע חומר';

  @override
  String get amoled_dark_tile_title => 'AMOLED כהה';

  @override
  String get amoled_dark_tile_subtitle => 'השתמש בצבע שחור טהור לנושא הכהה.';

  @override
  String get dynamic_colors_tile_title => 'צבעים דינמיים';

  @override
  String get dynamic_colors_tile_subtitle => 'השתמש בצבעי המכשיר אם זה נתמך.';

  @override
  String get defaults_heading => 'ברירות מחדל';

  @override
  String get app_language_tile_title => 'שפת האפליקציה';

  @override
  String get default_home_tab_tile_title => 'לשונית בית';

  @override
  String get usage_history_tile_title => 'היסטוריית שימוש';

  @override
  String get usage_history_15_days => '15 ימים';

  @override
  String get usage_history_1_month => '1 חודש';

  @override
  String get usage_history_3_month => '3 חודשים';

  @override
  String get usage_history_6_month => '6 חודשים';

  @override
  String get usage_history_1_year => '1 שנה';

  @override
  String get service_heading => 'שירות';

  @override
  String get service_stopping_warning =>
      'אם NLP digitox מפסיק לעבוד באופן בלתי צפוי, אנא הענק את הרשאת \'התעלם מאופטימיזציה של סוללה\' כדי להשאיר אותו פועל ברקע. אם הבעיה נמשכת, נסה לרשום את NLP digitox לביצועים ללא הפרעה.';

  @override
  String get whitelist_app_tile_title => 'רשימת היתרים NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'אפשר ל-NLP digitox להתחיל אוטומטית.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'מכשיר זה אינו תומך בניהול אתחול אוטומטי.';

  @override
  String get database_tab_title => 'מסד נתונים';

  @override
  String get import_db_tile_title => 'ייבוא מסד נתונים';

  @override
  String get import_db_tile_subtitle => 'ייבוא מסד נתונים מקובץ.';

  @override
  String get export_db_tile_title => 'ייצוא מסד נתונים';

  @override
  String get export_db_tile_subtitle => 'ייצוא מסד נתונים לקובץ.';

  @override
  String get analysis_tab_title => 'ניתוח';

  @override
  String get analysis_7_days => '7 ימים';

  @override
  String get analysis_30_days => '30 יום';

  @override
  String get analysis_90_days => '90 יום';

  @override
  String get analysis_screen_time_trend => 'מגמת זמן מסך';

  @override
  String get analysis_no_data_info => 'עדיין לא נרשמו נתוני זמן מסך לתקופה זו.';

  @override
  String get analysis_daily_average => 'ממוצע יומי';

  @override
  String get analysis_total => 'סה״כ';

  @override
  String get analysis_no_change => 'אותו דבר כמו בשבוע שעבר';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% פחות מהשבוע שעבר';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% יותר מהשבוע שעבר';
  }

  @override
  String get crash_logs_heading => 'יומני קריסה';

  @override
  String get crash_logs_info =>
      'אם אתה נתקל בבעיה כלשהי, תוכל לדווח עליה ב-GitHub יחד עם קובץ היומן. הקובץ יכלול פרטים כגון יצרן המכשיר, דגם, גרסת אנדרואיד, גרסת SDK ויומני קריסה. מידע זה יעזור לנו לזהות ולפתור את הבעיה בצורה יעילה יותר.';

  @override
  String get crash_logs_export_tile_title => 'ייצוא יומני קריסה';

  @override
  String get crash_logs_export_tile_subtitle => 'ייצא יומני קריסה לקובץ json.';

  @override
  String get crash_logs_view_tile_title => 'הצג יומנים';

  @override
  String get crash_logs_view_tile_subtitle => 'חקור יומני קריסה מאוחסנים.';

  @override
  String get crash_logs_empty_list_hint => 'לא נרשמה קריסה עד עכשיו.';

  @override
  String get crash_logs_clear_tile_title => 'נקה יומנים';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'מחק את כל יומני הקריסה ממסד הנתונים.';

  @override
  String get crash_logs_clear_dialog_info =>
      'האם אתה בטוח שברצונך לנקות את כל יומני הקריסה ממסד הנתונים?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'ברור בכל מקרה';

  @override
  String get about_tab_title => 'בערך';

  @override
  String get changelog_tile_title => 'יומן שינויים';

  @override
  String get changelog_tile_subtitle => 'גלה מה חדש.';

  @override
  String get full_changelog_tile_title => 'יומן שינויים מלא';

  @override
  String get redirected_to_github_subtitle => 'אתה תופנה אל GitHub.';

  @override
  String get contribute_heading => 'תרום';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'הצג את קוד המקור.';

  @override
  String get report_issue_tile_title => 'דווח על בעיה';

  @override
  String get suggest_idea_tile_title => 'הצע רעיון';

  @override
  String get write_email_tile_title => 'כתבו לנו במייל';

  @override
  String get write_email_tile_subtitle => 'אתה תופנה לאפליקציית אימייל.';

  @override
  String get privacy_policy_heading => 'מדיניות פרטיות';

  @override
  String get privacy_policy_info =>
      'NLP digitox מחויבת להגן על הפרטיות שלך. איננו אוספים, מאחסנים או מעבירים כל סוג של נתוני משתמש. האפליקציה פועלת באופן לא מקוון לחלוטין ואינה דורשת חיבור לאינטרנט, מה שמבטיח שהמידע האישי שלך יישאר פרטי ומאובטח במכשיר שלך. כיישום תוכנת קוד פתוח וחופשי (FOSS), NLP digitox מבטיח שקיפות מלאה ושליטה של ​​המשתמש על הנתונים שלהם.';

  @override
  String get more_details_button => 'פרטים נוספים';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
