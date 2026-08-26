// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get mindful_tagline => 'ركّز على ما يهم حقًا';

  @override
  String get unlock_button_label => 'فتح';

  @override
  String get permission_status_off => 'إيقاف';

  @override
  String get permission_status_allowed => 'مسموح';

  @override
  String get permission_status_not_allowed => 'غير مسموح';

  @override
  String get permission_button_grant_permission => 'منح الإذن';

  @override
  String get permission_button_agree_and_continue => 'موافق ومتابعة';

  @override
  String get permission_button_not_now => 'ليس الآن';

  @override
  String get permission_button_help => 'مساعدة؟';

  @override
  String get permission_sheet_privacy_info =>
      'تطبيق NLP digitox آمن بنسبة ١٠٠% ويعمل دون اتصال بالإنترنت. ولا نقوم بجمع أو تخزين أي بيانات شخصية.';

  @override
  String permission_grant_step_one(String button_label) {
    return '١. انقر على زر $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '٢. حدد NLP digitox في الشاشة التالية.';

  @override
  String get permission_grant_step_three =>
      '٣. انقر فوق المفتاح وقم بتشغيله كما هو موضح أدناه.';

  @override
  String get permission_notification_title => 'إرسال الإشعارات';

  @override
  String get permission_alarms_title => 'التنبيهات والتذكيرات';

  @override
  String get permission_alarms_info =>
      'يرجى منح الإذن لضبط التنبيهات والتذكيرات. سيسمح هذا لتطبيق NLP digitox ببدء جدول وقت النوم في الوقت المحدد وإعادة ضبط مؤقتات التطبيق يوميًا عند منتصف الليل ومساعدتك على البقاء على المسار الصحيح.';

  @override
  String get permission_alarms_device_tile_label =>
      'السماح بإعداد التنبيهات والتذكيرات';

  @override
  String get permission_usage_title => 'الوصول إلى الاستخدام';

  @override
  String get permission_usage_info =>
      'يرجى منح إذن الوصول إلى الاستخدام. سيسمح هذا لـ NLP digitox بمراقبة استخدام التطبيق وإدارة الوصول إلى تطبيقات معينة، مما يضمن بيئة رقمية أكثر تركيزًا وتحكمًا.';

  @override
  String get permission_usage_device_tile_label =>
      'السماح بالوصول إلى الاستخدام';

  @override
  String get permission_overlay_title => 'عرض التراكب';

  @override
  String get permission_overlay_info =>
      'يرجى منح إذن عرض التراكب. سيسمح هذا لتطبيق NLP digitox بعرض تراكب عند فتح تطبيق متوقف مؤقتًا، مما يساعدك على البقاء مركزًا والالتزام بجدولك الزمني.';

  @override
  String get permission_overlay_device_tile_label =>
      'السماح بالعرض على التطبيقات الأخرى';

  @override
  String get permission_accessibility_title => 'إمكانية الوصول';

  @override
  String get permission_accessibility_info =>
      'يرجى منح إذن الوصول. سيسمح هذا لشركة NLP digitox بتقييد الوصول إلى محتوى الفيديو القصير (مثل Reels وShorts) داخل تطبيقات الوسائط الاجتماعية والمتصفحات، وتصفية المواقع الإلكترونية غير المناسبة.';

  @override
  String get permission_accessibility_required =>
      'يتطلب تطبيق NLP digitox إذن الوصول لتفعيل حظر المحتوى القصير والمواقع الإلكترونية بفعالية.';

  @override
  String get permission_accessibility_device_tile_label => 'استخدم NLP digitox';

  @override
  String get permission_dnd_title => 'عدم الإزعاج';

  @override
  String get permission_dnd_info =>
      'يرجى منح ميزة \"عدم الإزعاج\" حق الوصول. سيسمح هذا لتطبيق NLP digitox ببدء وإيقاف وضع \"عدم الإزعاج\" أثناء جدول وقت النوم.';

  @override
  String get permission_dnd_tile_title => 'ابدأ عدم الإزعاج';

  @override
  String get permission_dnd_tile_subtitle => 'قم أيضًا بتمكين وضع عدم الإزعاج.';

  @override
  String get permission_battery_optimization_tile_title =>
      'تجاهل تحسين البطارية';

  @override
  String get permission_battery_optimization_status_enabled =>
      'غير مقيد بالفعل';

  @override
  String get permission_battery_optimization_status_disabled =>
      'تعطيل تقييد الخلفية';

  @override
  String get permission_battery_optimization_allow_info =>
      'سيؤدي السماح بـ \"تجاهل تحسين البطارية\" إلى منح إذن \"التنبيهات والتذكيرات\" تلقائيًا على بعض الأجهزة';

  @override
  String get permission_vpn_title => 'إنشاء VPN';

  @override
  String get permission_vpn_info =>
      'يرجى منح الإذن لإنشاء اتصال بشبكة خاصة افتراضية (VPN). سيسمح هذا لـ NLP digitox بتقييد الوصول إلى الإنترنت للتطبيقات المحددة من خلال إنشاء شبكة VPN محلية على الجهاز.';

  @override
  String get permission_admin_title => 'مسؤول';

  @override
  String get permission_admin_info =>
      'تكون الامتيازات الإدارية ضرورية فقط للعمليات الأساسية لضمان عمل التطبيق بشكل صحيح وبقائه مقاومًا للتلاعب.';

  @override
  String get permission_admin_snack_alert =>
      'لا يمكن تعطيل الحماية من العبث إلا خلال فترة زمنية محددة.';

  @override
  String get permission_notification_access_title => 'الوصول إلى الإشعارات';

  @override
  String get permission_notification_access_info =>
      'يرجى منح إذن الوصول إلى الإشعارات. سيسمح هذا لـ NLP digitox بتنظيم إشعاراتك وتسليمها حسب جدولك.';

  @override
  String get permission_notification_access_required =>
      'يتطلب NLP digitox الوصول إلى الإشعارات للدفعات والإشعارات المجدولة.';

  @override
  String get permission_notification_access_device_tile_label =>
      'السماح بالوصول إلى الإشعارات';

  @override
  String get day_today => 'اليوم';

  @override
  String get day_yesterday => 'أمس';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString أيام',
      one: 'يوم واحد',
      zero: '٠ يوم',
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
      other: '$countString ساعات',
      one: 'ساعة واحدة',
      zero: '٠ ساعة',
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
      other: '$countString دقائق',
      one: 'دقيقة واحدة',
      zero: '٠ دقيقة',
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
      other: '$countString ثواني',
      one: 'ثانية واحدة',
      zero: '٩ ثانية',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'و';

  @override
  String get timer_status_active => 'نشيط';

  @override
  String get timer_status_paused => 'متوقف مؤقتا';

  @override
  String get create_button => 'إنشاء';

  @override
  String get update_button => 'تحديث';

  @override
  String get dialog_button_cancel => 'إلغاء';

  @override
  String get dialog_button_remove => 'حذف';

  @override
  String get dialog_button_set => 'تعيين';

  @override
  String get dialog_button_reset => 'إعادة ضبط';

  @override
  String get dialog_button_infinite => 'لانهائي';

  @override
  String get schedule_start_label => 'يبدأ';

  @override
  String get schedule_end_label => 'نهاية';

  @override
  String get exit_without_saving_dialog_info =>
      'هل أنت متأكد أنك تريد الخروج دون حفظ؟';

  @override
  String get development_dialog_info =>
      'تطبيق NLP digitox قيد التطوير حاليًا وقد يحتوي على أخطاء أو ميزات غير مكتملة. إذا واجهت أي مشكلات، فيرجى الإبلاغ عنها لمساعدتنا على التحسين.\n\nشكرًا لك على ملاحظاتك!';

  @override
  String get development_dialog_button_report_issue => 'الإبلاغ عن المشكلة';

  @override
  String get development_dialog_button_close => 'غلق';

  @override
  String get dnd_settings_tile_title => 'إعدادات عدم الإزعاج';

  @override
  String get dnd_settings_tile_subtitle =>
      'إدارة التطبيقات والإشعارات التي يمكنها الوصول إليك في وضع عدم الإزعاج.';

  @override
  String get quick_actions_heading => 'الإجراءات السريعة';

  @override
  String get select_distracting_apps_heading =>
      'حدد التطبيقات المشتتة للانتباه';

  @override
  String get your_distracting_apps_heading => 'تطبيقاتك المشتتة للانتباه';

  @override
  String get select_more_apps_heading => 'حدد المزيد من التطبيقات';

  @override
  String get imp_distracting_apps_snack_alert =>
      'لا يُسمح بإضافة تطبيقات النظام المهمة إلى قائمة التطبيقات المشتتة للانتباه.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'لا يتوفر استخدام الشاشة والقيود لهذا التطبيق. في الوقت الحالي، يمكن الوصول إلى استخدام الشبكة فقط';

  @override
  String get create_group_fab_button => 'إنشاء مجموعة';

  @override
  String get active_period_info =>
      'حدد مدّة زمنية يُسمح خلالها بالوصول. وخارج هذه المدّة الزمنية، سيتم تقييد الوصول.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'حدد تطبيقًا واحدًا علي الأقل يشتت انتباهك.';

  @override
  String get donation_card_title => 'ادعمنا';

  @override
  String get donation_card_info =>
      'NLP digitox هو تطبيق مجاني ومفتوح المصدر، تم تطويره بعد شهور من التفاني. إذا ساعدك التطبيق، فإن تبرعك يعني الكثير بالنسبة لنا. تساعدنا كل مساهمة في تحسينه وصيانته من أجل الجميع.';

  @override
  String get operation_failed_snack_alert => 'فشلت العملية، حدث خطأ ما!';

  @override
  String get donation_card_button_donate => 'تبرع';

  @override
  String get app_restart_dialog_title => 'بحاجة لإعادة التشغيل';

  @override
  String get app_restart_dialog_info =>
      'سيتم إعادة تشغيل NLP digitox تلقائيًا بمجرد انتهاء العد التنازلي. يرجى التحلي بالصبر أثناء تطبيق التغييرات.';

  @override
  String get accessibility_tip =>
      'هل ترغب في حظر أذكى وأكثر توفيرا للطاقة؟ فعل إذن إمكانية الوصول لتطبيق NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'هل لا يعمل تطبيق NLP digitox؟ اسمح بخيار \"تجاهل تحسين البطارية\" من الإعدادات ليعمل بسلاسة.';

  @override
  String get invincible_mode_tip =>
      'هل أزلت القيود عن طريق الخطأ؟ استخدم وضع الحماية القصوى لقفلها حتى اليوم التالي أو حتى نافذة التعديل.';

  @override
  String get glance_usage_tip =>
      'تريد الحصول على إحصاءات؟ تفقد قسم \"نظرة سريعة\" لعرض أنماط استخدامك ومدة وقت الشاشة.';

  @override
  String get tamper_protection_tip =>
      'هل تنوي إزالة تطبيق NLP digitox؟ فعل نافذة إلغاء التثبيت لتعطيل حماية العبث بأمان أولا.';

  @override
  String get notification_blocking_tip =>
      'تريد تقليل التشتت؟ استخدم ميزة حظر الإشعارات لكتم التطبيقات المحددة.';

  @override
  String get usage_history_tip =>
      'تريد التأمل في عاداتك؟ تفقد سجل الاستخدام للاطلاع على الأنماط السابقة.';

  @override
  String get focus_mode_tip =>
      'تحتاج إلى تركيز عميق؟ فعل وضع التركيز لحظر التطبيقات والإشعارات أثناء المهام.';

  @override
  String get bedtime_reminder_tip =>
      'تريد تحسين نومك؟ اضبط تذكير موعد النوم للاسترخاء كل ليلة.';

  @override
  String get custom_blocking_tip =>
      'تحتاج إلى تجربة مخصصة؟ أنشئ قواعد حظر التطبيقات التي تناسب احتياجاتك.';

  @override
  String get session_timeline_tip =>
      'تريد متابعة جلسات التركيز؟ اطلع على الجدول الزمني لرؤية رحلة تركيزك.';

  @override
  String get short_content_blocking_tip =>
      'تشتت بسبب تطبيقات التواصل الاجتماعي؟ احظر المحتوى القصير على إنستغرام ويوتيوب وغيرها للبقاء مركزا.';

  @override
  String get parental_controls_tip =>
      'تحتاج إلى رقابة أبوية؟ ضع قيودا على جهاز طفلك لضمان تجربة امنة.';

  @override
  String get notification_batching_tip =>
      'تريد تقليل التشتت؟ استخدم تجميع الإشعارات لجمعها معا والتحقق منها دفعة واحدة.';

  @override
  String get notification_scheduling_tip =>
      'تحتاج لإدارة الإشعارات؟ جدولة مواعيد استلام الإشعارات لتطبيقات معينة.';

  @override
  String get quick_focus_tile_tip =>
      'هل تحتاج إلى وصول سريع للتركيز؟ أضف لوحة تركيز سريعة لتفعيل وضع التركيز على الفور.';

  @override
  String get app_shortcuts_tip =>
      'تريد وصولا فوريا للتطبيقات؟ أضف اختصارات بالضغط المطول على أيقونة التطبيق للإجراءات السريعة.';

  @override
  String get backup_usage_db_tip =>
      'هل ترغب في حفظ بياناتك؟ قم بعمل نسخة احتياطية لقاعدة بيانات الاستخدام للحفاظ على سجلاتك بأمان.';

  @override
  String get dynamic_material_color_tip =>
      'تريد ثيم مخصص؟ فعل لون Material You الديناميكي ليتناسب مع ثيم جهازك.';

  @override
  String get amoled_dark_theme_tip =>
      'تريد توفير البطارية؟ استخدم الثيم الداكن AMOLED لتقليل استهلاك الطاقة على شاشات OLED.';

  @override
  String get customize_usage_history_tip =>
      'تريد الاحتفاظ بسجل الاستخدام؟ خصص عدد الأسابيع التي تريد تخزين بياناتها في سجل الاستخدام.';

  @override
  String get grouped_apps_blocking_tip =>
      'تريد حظر التطبيقات معا؟ استخدم مجموعات القيود لتجميع حدود التطبيقات وحظر عدة تطبيقات دفعة واحدة.';

  @override
  String get websites_blocking_tip =>
      'تريد تجربة تصفح أنظف؟ احظر مواقع مخصصة أو مواقع غير مناسبة لمزيد من التركيز أثناء التصفح.';

  @override
  String get data_usage_tip =>
      'تريد متابعة بياناتك؟ راقب استخدام بيانات الجوال والواي فاي لاستهلاك الإنترنت.';

  @override
  String get block_internet_tip =>
      'تحتاج لحظر إنترنت تطبيق؟ قم بقطع الإنترنت لتطبيق معين من لوحة التحكم الخاصة به.';

  @override
  String get emergency_passes_tip =>
      'تحتاج استراحة؟ استخدم 3 تصاريح طوارئ يوميا لفتح التطبيقات مؤقتا لمدة 5 دقائق.';

  @override
  String get onboarding_skip_btn_label => 'تخطي';

  @override
  String get onboarding_finish_setup_btn_label => 'إنهاء الإعداد';

  @override
  String get onboarding_page_welcome_title => 'مرحبًا بك في NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'تحكّم في حياتك الرقمية وابنِ عادات صحية لاستخدام الشاشة. يساعدك NLP digitox على البقاء مركّزًا وتقليل المشتتات واتخاذ خيارات واعية كل يوم.';

  @override
  String get onboarding_page_statistics_title => 'اعرف عاداتك.';

  @override
  String get onboarding_page_statistics_info =>
      'افهم أنماطك الرقمية من خلال رؤى مفصّلة حول وقت الشاشة واستخدام التطبيقات واتجاهات التركيز. تتبّع تقدّمك وشاهد كيف تؤدي التغييرات الصغيرة إلى تحسينات كبيرة.';

  @override
  String get onboarding_page_one_title => 'التركيز المتقن.';

  @override
  String get onboarding_page_one_info =>
      'قم بإيقاف التطبيقات المشتتة للانتباه مؤقتًا، وحظر المحتوى القصير، والتزم بالمسار الصحيح من خلال جلسات التركيز القابلة للتخصيص. سواء كنت تعمل أو تدرس أو تسترخي، يساعدك NLP digitox على البقاء متحكمًا.';

  @override
  String get onboarding_page_two_title => 'منع التشتيتات.';

  @override
  String get onboarding_page_two_info =>
      'قم بتعيين حدود الاستخدام وإيقاف التطبيقات تلقائيًا وإنشاء عادات رقمية أكثر صحة. استخدم وضع وقت النوم للاسترخاء والاستمتاع بليلة خالية من التشتيت.';

  @override
  String get onboarding_page_three_title => 'الخصوصية أولاً.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox هو تطبيق مفتوح المصدر بنسبة ١٠٠% ويعمل دون اتصال بالإنترنت بالكامل. نحن لا نجمع أو نشارك بياناتك الشخصية — خصوصيتك مضمونة بكل الطرق.';

  @override
  String get onboarding_page_permissions_title => 'الأذونات الأساسية.';

  @override
  String get onboarding_page_permissions_info =>
      'يتطلب NLP digitox اتباع الأذونات الأساسية لتتبع وإدارة وقت الشاشة، مما يساعد على تقليل عوامل التشتيت وتحسين التركيز.';

  @override
  String get dashboard_tab_title => 'لوحة التحكم';

  @override
  String get focus_now_fab_button => 'ركز الان';

  @override
  String get welcome_greetings => 'مرحبًا بعودتك،';

  @override
  String get username_snack_alert => 'اضغط لفترة طويلة لتعديل أسم المستخدم.';

  @override
  String get username_dialog_title => 'أسم المستخدم';

  @override
  String get username_dialog_info =>
      'أدخل أسم المستخدم الخاص بك والذي سيتم عرضه على لوحة التحكم.';

  @override
  String get username_dialog_button_apply => 'تطبيق';

  @override
  String get glance_tile_title => 'نظرة سريعة';

  @override
  String get glance_tile_subtitle => 'ألق نظرة سريعة على استخدامك.';

  @override
  String get parental_controls_tile_subtitle =>
      'وضع الحماية القصوى وحماية العبث.';

  @override
  String get restrictions_heading => 'القيود';

  @override
  String get apps_blocking_tile_title => 'حظر التطبيقات';

  @override
  String get apps_blocking_tile_subtitle =>
      'حدد قيودا على التطبيقات بطرق متعددة.';

  @override
  String get grouped_apps_blocking_tile_title => 'حظر التطبيقات المجمعة';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'حدد قيودا على مجموعة تطبيقات في وقت واحد.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'حدد قيودا على المحتوى القصير في عدة منصات.';

  @override
  String get websites_blocking_tile_subtitle =>
      'حدد قيودا على المواقع الإباحية والمخصصة.';

  @override
  String get screen_time_label => 'وقت استخدام الشاشة';

  @override
  String get total_data_label => 'إجمالي البيانات';

  @override
  String get mobile_data_label => 'بيانات الجوال';

  @override
  String get wifi_data_label => 'بيانات الواي فاي';

  @override
  String get focus_today_label => 'تركيز اليوم';

  @override
  String get focus_weekly_label => 'تركيز أسبوعي';

  @override
  String get focus_monthly_label => 'تركيز شهري';

  @override
  String get focus_lifetime_label => 'تركيز مدى الحياة';

  @override
  String get longest_streak_label => 'أطول سلسلة';

  @override
  String get current_streak_label => 'السلسلة الحالية';

  @override
  String get successful_sessions_label => 'جلسات ناجحة';

  @override
  String get failed_sessions_label => 'الجلسات الفاشلة';

  @override
  String get statistics_tab_title => 'إحصائيات';

  @override
  String get screen_segment_label => 'الشاشة';

  @override
  String get data_segment_label => 'بيانات';

  @override
  String get mobile_label => 'الجوال';

  @override
  String get wifi_label => 'الواي فاي';

  @override
  String get most_used_apps_heading => 'التطبيقات الأكثر استخداما';

  @override
  String get show_all_apps_tile_title => 'عرض جميع التطبيقات';

  @override
  String get search_apps_hint => 'ابحث عن التطبيقات...';

  @override
  String get notifications_tab_title => 'الإشعارات';

  @override
  String get notifications_tab_info =>
      'جمع الإشعارات من التطبيقات وضبط جداول مثل الصباح، الظهر، المساء، والليل. كن على اطلاع دون انقطاعات مستمرة.';

  @override
  String get batched_apps_tile_title => 'التطبيقات المجمعة';

  @override
  String get batch_recap_dropdown_title => 'نوع ملخص الدفعة';

  @override
  String get batch_recap_dropdown_info =>
      'اختر ما يتم إرساله عند تفعيل الجدول — كل الإشعارات أو ملخص فقط.';

  @override
  String get batch_recap_option_summery_only => 'الملخص فقط';

  @override
  String get batch_recap_option_all_notifications => 'جميع الإشعارات';

  @override
  String get notification_history_tile_title => 'سجل الإشعارات';

  @override
  String get store_all_tile_title => 'تخزين جميع الإشعارات';

  @override
  String get store_all_tile_subtitle => 'حفظ الإشعارات غير المجمعة أيضا.';

  @override
  String get schedules_heading => 'الجداول الزمنية';

  @override
  String get new_schedule_fab_button => 'جدول جديد';

  @override
  String get new_schedule_dialog_info =>
      'أدخل اسما لجدول الإشعارات لتسهيل التعرف عليه.';

  @override
  String get new_schedule_dialog_field_label => 'اسم الجدول';

  @override
  String get bedtime_tab_title => 'موعد النوم';

  @override
  String get bedtime_tab_info =>
      'قم بتعيين جدول وقت النوم الخاص بك عن طريق اختيار فترة زمنية وأيام الأسبوع. اختر التطبيقات المشتتة لحظرها وفعّل وضع عدم الإزعاج (DND) لقضاء ليلة هادئة.';

  @override
  String get schedule_tile_title => 'الجدول الزمني';

  @override
  String get schedule_tile_subtitle => 'تمكين أو تعطيل الجدول اليومي.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'اختر يوما واحدا على الأقل من أيام الأسبوع.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'يجب أن تكون مدة وقت النوم الإجمالية 30 دقيقة على الأقل.';

  @override
  String get distracting_apps_tile_title => 'التطبيقات المشتتة';

  @override
  String get distracting_apps_tile_subtitle =>
      'حدد التطبيقات التي تشتتك عن روتين وقت النوم.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'لا يسمح بتعديل قائمة التطبيقات المشتتة أثناء تفعيل جدول وقت النوم.';

  @override
  String get parental_controls_tab_title => 'الرقابة الأبوية';

  @override
  String get invincible_mode_heading => 'وضع غير قابل للهزيمة';

  @override
  String get invincible_mode_tile_title => 'تفعيل وضع غير قابل للهزيمة';

  @override
  String get invincible_mode_info =>
      'عند تفعيل وضع غير قابل للهزيمة، لن تتمكن من تعديل الحدود المختارة بعد الوصول إلى الحصة اليومية. ومع ذلك، يمكنك إجراء تغييرات خلال نافذة غير قابلة للهزيمة مدتها 10 دقائق.';

  @override
  String get invincible_mode_snack_alert =>
      'نظرا لتفعيل وضع غير قابل للهزيمة، لا يسمح بتعديل القيود.';

  @override
  String get invincible_mode_dialog_info =>
      'هل أنت متأكد تمامًا من رغبتك في تفعيل وضع غير قابل للهزيمة؟ هذا الإجراء لا يمكن التراجع عنه. بمجرد تفعيل وضع غير قابل للهزيمة، لن تتمكن من إيقافه طالما أن هذا التطبيق مثبت على جهازك.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'لا يمكن إيقاف وضع غير قابل للهزيمة طالما أن هذا التطبيق مثبت على جهازك.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'ابدأ على أي حال';

  @override
  String get invincible_mode_include_timer_tile_title => 'تضمين المؤقت';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'تضمين حد التشغيل';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'تضمين الفترة النشطة';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'قيود التطبيق';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'منع تعديل القيود المحددة للتطبيق بمجرد تجاوز الحدود اليومية.';

  @override
  String get invincible_mode_group_restrictions_tile_title => 'قيود المجموعة';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'منع تعديل القيود المحددة للمجموعة بمجرد تجاوز الحدود اليومية.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'تضمين مؤقت الفيديوهات القصيرة';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'يمنع التعديلات بعد الوصول إلى حد الفيديوهات القصيرة اليومي.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'تضمين وقت النوم';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'يمنع التعديلات أثناء تفعيل جدول وقت النوم.';

  @override
  String get protected_access_tile_title => 'وصول محمي';

  @override
  String get protected_access_tile_subtitle =>
      'احمِ تطبيق NLP digitox بواسطة قفل جهازك.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'يرجى إعداد قفل بيومتري على جهازك أولا لتمكين هذه الميزة.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'تم إزالة قفل جهازك. للمتابعة، يرجى إعداد قفل جديد.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'فشل التحقق. تحتاج إلى تأكيد قفل جهازك للمتابعة.';

  @override
  String get tamper_protection_tile_title => 'حماية من التلاعب';

  @override
  String get tamper_protection_tile_subtitle =>
      'منع إلغاء التثبيت وإيقاف التطبيق قسريا.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'بمجرد التفعيل، لن تتمكن من إلغاء التثبيت أو إيقاف التطبيق قسريا أو مسح بيانات NLP digitox، إلا خلال فترة إلغاء التثبيت المحددة. لا توجد حلول بديلة.\n\nتابع على مسؤوليتك الخاصة.';

  @override
  String get uninstall_window_tile_title => 'نافذة إلغاء التثبيت';

  @override
  String get uninstall_window_tile_subtitle =>
      'يمكن تعطيل حماية التلاعب خلال 10 دقائق من الوقت المحدد.';

  @override
  String get invincible_window_tile_title => 'نافذة الوضع غير القابل للهزيمة';

  @override
  String get invincible_window_tile_subtitle =>
      'يمكن تعديل الحدود المختارة خلال 10 دقائق من الوقت المحدد.';

  @override
  String get shorts_blocking_tab_title => 'حجب الفيديوهات القصيرة';

  @override
  String get shorts_blocking_tab_info =>
      'تحكم في الوقت الذي تقضيه في مشاهدة المحتوى القصير عبر منصات مثل إنستجرام، يوتيوب، سناب شات، وفيسبوك، بما في ذلك مواقعهم الإلكترونية.';

  @override
  String get short_content_heading => 'المحتوى القصير';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'المتبقي من $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'حدد حدا زمنيا يوميا للمحتوى القصير. عند الوصول إلى الحد، سيتوقف عرض المحتوى القصير حتى منتصف الليل.';

  @override
  String get instagram_features_tile_title => 'إنستجرام';

  @override
  String get instagram_features_tile_subtitle => 'تقييد الميزات على إنستجرام.';

  @override
  String get instagram_features_block_reels => 'تقييد قسم الريلز.';

  @override
  String get instagram_features_block_explore => 'تقييد قسم الاستكشاف.';

  @override
  String get snapchat_features_tile_title => 'سناب شات';

  @override
  String get snapchat_features_tile_subtitle => 'تقييد الميزات على سناب شات.';

  @override
  String get snapchat_features_block_spotlight => 'تقييد قسم Spotlight.';

  @override
  String get snapchat_features_block_discover => 'تقييد قسم Discover.';

  @override
  String get youtube_features_tile_title => 'يوتيوب';

  @override
  String get youtube_features_tile_subtitle =>
      'تقييد الفيديوهات القصيرة على يوتيوب.';

  @override
  String get facebook_features_tile_title => 'فيسبوك';

  @override
  String get facebook_features_tile_subtitle => 'تقييد الريلز على فيسبوك.';

  @override
  String get reddit_features_tile_title => 'ريديت';

  @override
  String get reddit_features_tile_subtitle =>
      'تقييد الفيديوهات القصيرة على ريديت.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'تقييد خلاصة الفيديو على X.';

  @override
  String get threads_features_tile_title => 'Threads';

  @override
  String get threads_features_tile_subtitle =>
      'تقييد الفيديو/الريلز على Threads.';

  @override
  String get websites_blocking_tab_title => 'حجب المواقع الإلكترونية';

  @override
  String get websites_blocking_tab_info =>
      'حظر مواقع البالغين وأي مواقع مخصصة تختارها لخلق تجربة تصفح أكثر أمانًا وتركيزًا. تحكم في تصفحك وابقَ خاليًا من التشتيت.';

  @override
  String get adult_content_heading => 'محتوى للبالغين';

  @override
  String get block_nsfw_title => 'حظر المحتوى للبالغين';

  @override
  String get block_nsfw_subtitle =>
      'تقييد المتصفحات من فتح المواقع الإباحية والمحتوى غير المناسب.';

  @override
  String get block_nsfw_dialog_info =>
      'هل أنت متأكد؟ هذا الإجراء لا يمكن التراجع عنه. بمجرد تفعيل حجب المواقع الإباحية، لن تتمكن من إيقافه طالما أن هذا التطبيق مثبت على جهازك.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'احجب على أي حال';

  @override
  String get blocked_websites_heading => 'المواقع المحجوبة';

  @override
  String get blocked_websites_empty_list_hint =>
      'انقر على زر «+ إضافة موقع» لإضافة المواقع المشتتة التي ترغب في حجبها.';

  @override
  String get add_website_fab_button => 'إضافة موقع';

  @override
  String get add_website_dialog_title => 'موقع مشتت';

  @override
  String get add_website_dialog_info => 'أدخل رابط الموقع الذي تريد حظره.';

  @override
  String get add_website_dialog_is_nsfw =>
      'هل الموقع يحتوي على محتوى للبالغين؟';

  @override
  String get add_website_dialog_nsfw_warning =>
      'تحذير: لا يمكن إزالة مواقع البالغين بعد إضافتها.';

  @override
  String get add_website_dialog_button_block => 'حظر';

  @override
  String get add_website_already_exist_snack_alert =>
      'تمت إضافة الرابط مسبقا إلى قائمة المواقع المحظورة.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'رابط غير صالح! تعذر تحليل اسم المضيف.';

  @override
  String get remove_website_dialog_title => 'إزالة الموقع';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'هل أنت متأكد أنك تريد إزالة \'$websitehost\' من المواقع المحجوبة.';
  }

  @override
  String get focus_tab_title => 'التركيز';

  @override
  String get focus_tab_info =>
      'عندما تحتاج إلى وقت للتركيز، ابدأ جلسة جديدة باختيار النوع، وتحديد التطبيقات المشتتة لإيقافها مؤقتا، وتفعيل وضع \"عدم الإزعاج\" لتحقيق تركيز دون انقطاع.';

  @override
  String get active_session_card_title => 'جلسة نشطة';

  @override
  String get active_session_card_info =>
      'لديك جلسة تركيز نشطة! انقر على \"عرض\" لمتابعة تقدمك ومعرفة الوقت المنقضي.';

  @override
  String get active_session_card_view_button => 'عرض';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'لا يسمح بإزالة التطبيقات من قائمة التطبيقات المشتتة أثناء جلسة التركيز النشطة. ومع ذلك، يمكنك إضافة تطبيقات إضافية إلى القائمة خلال هذه الفترة.';

  @override
  String get focus_profile_tile_title => 'ملف التركيز';

  @override
  String get focus_session_duration_tile_title => 'مدة الجلسة';

  @override
  String get focus_session_duration_tile_subtitle =>
      'غير محدودة (ما لم تقم بالإيقاف)';

  @override
  String get focus_session_duration_dialog_info =>
      'يرجى اختيار المدة المطلوبة لهذه جلسة التركيز لتحديد الفترة التي ترغب في البقاء خلالها مركزا وخاليا من المشتتات.';

  @override
  String get focus_profile_customization_tile_title => 'تخصيص الملف الشخصي';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'خصص الإعدادات للملف الشخصي المحدد.';

  @override
  String get focus_enforce_tile_title => 'فرض الجلسة';

  @override
  String get focus_enforce_tile_subtitle =>
      'يمنع إنهاء الجلسة قبل انتهاء الوقت المحدد.';

  @override
  String get focus_session_start_button => 'مرّر لبدء الجلسة';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'اختر تطبيقا واحدا على الأقل من التطبيقات المشتتة لبدء جلسة التركيز';

  @override
  String get focus_session_already_active_snack_alert =>
      'لديك جلسة تركيز نشطة بالفعل. يرجى إكمالها أو إيقافها قبل بدء جلسة جديدة.';

  @override
  String get focus_session_type_study => 'دراسة';

  @override
  String get focus_session_type_work => 'عمل';

  @override
  String get focus_session_type_exercise => 'تمرين';

  @override
  String get focus_session_type_meditation => 'تأمل';

  @override
  String get focus_session_type_creativeWriting => 'الكتابة الإبداعية';

  @override
  String get focus_session_type_reading => 'قراءة';

  @override
  String get focus_session_type_programming => 'برمجة';

  @override
  String get focus_session_type_chores => 'أعمال منزلية';

  @override
  String get focus_session_type_projectPlanning => 'تخطيط المشروع';

  @override
  String get focus_session_type_artAndDesign => 'الفن والتصميم';

  @override
  String get focus_session_type_languageLearning => 'تعلم اللغات';

  @override
  String get focus_session_type_musicPractice => 'تمرين الموسيقى';

  @override
  String get focus_session_type_selfCare => 'العناية الذاتية';

  @override
  String get focus_session_type_brainstorming => 'جلسة عصف ذهني';

  @override
  String get focus_session_type_skillDevelopment => 'تطوير المهارات';

  @override
  String get focus_session_type_research => 'بحث';

  @override
  String get focus_session_type_networking => 'تواصل اجتماعي';

  @override
  String get focus_session_type_cooking => 'طبخ';

  @override
  String get focus_session_type_sportsTraining => 'تدريب رياضي';

  @override
  String get focus_session_type_restAndRelaxation => 'راحة واسترخاء';

  @override
  String get focus_session_type_other => 'أخرى';

  @override
  String get timeline_tab_title => 'الجدول الزمني';

  @override
  String get focus_timeline_tab_info =>
      'استكشف رحلة تركيزك باختيار تاريخ من التقويم. تابع تقدمك، أعد زيارة نجاحاتك، وتعلم من التحديات.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'إجمالي وقت إنتاجيتك للشهر المحدد هو $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'الأيام الإنتاجية';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'لقد حققت إجمالي $daysCount يوما إنتاجيا في الشهر المحدد.';
  }

  @override
  String get selected_day_focused_time_label => 'وقت التركيز';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'إجمالي وقت تركيزك لليوم المحدد هو $timeString.';
  }

  @override
  String get calender_heading => 'التقويم';

  @override
  String get your_sessions_heading => 'جلساتك';

  @override
  String get your_sessions_empty_list_hint =>
      'لا توجد جلسات تركيز مسجلة لليوم المحدد.';

  @override
  String get focus_session_tile_timestamp_label => 'الطابع الزمني';

  @override
  String get focus_session_tile_duration_label => 'المدة';

  @override
  String get focus_session_tile_reflection_label => 'تأمل';

  @override
  String get focus_session_state_active => 'نشط';

  @override
  String get focus_session_state_successful => 'ناجح';

  @override
  String get focus_session_state_failed => 'فشل';

  @override
  String get active_session_tab_title => 'جلسة';

  @override
  String get active_session_none_warning =>
      'لم يتم العثور على جلسة نشطة. جار العودة إلى الشاشة الرئيسية.';

  @override
  String get active_session_dialog_button_keep_pushing => 'استمر في التقدم';

  @override
  String get active_session_finish_dialog_title => 'إنهاء';

  @override
  String get active_session_finish_dialog_info =>
      'ابق قويا! أنت تبني تركيزا قيما. هل أنت متأكد من رغبتك في إنهاء جلسة التركيز هذه؟ كل لحظة إضافية تساهم في تحقيق أهدافك.';

  @override
  String get active_session_giveup_dialog_title => 'الاستسلام';

  @override
  String get active_session_giveup_dialog_info =>
      'تمسك! أنت على وشك الانتهاء، لا تستسلم الان! هل أنت متأكد من رغبتك في إنهاء جلسة التركيز مبكرا؟ سيتم فقدان التقدم المحرز.';

  @override
  String get active_session_reflection_dialog_title => 'تأمل الجلسة';

  @override
  String get active_session_reflection_dialog_info =>
      'خذ لحظة للتأمل في تقدمك. ما هو هدفك من هذه الجلسة؟ ماذا أنجزت خلال هذه الجلسة؟';

  @override
  String get active_session_reflection_dialog_tip =>
      'نصيحة: يمكنك دائما تعديل هذا لاحقا في خط زمني الجلسة.';

  @override
  String get active_session_giveup_snack_alert =>
      'لقد استسلمت! لا تقلق، يمكنك أن تكون أفضل في المرة القادمة. كل جهد يحتسب – فقط واصل المحاولة';

  @override
  String get active_session_quote_one =>
      'كل خطوة تحتسب، ابق قويا واستمر في المضي قدما';

  @override
  String get active_session_quote_two => 'ابق مركزا! أنت تحقق تقدما مذهلا';

  @override
  String get active_session_quote_three =>
      'أنت تتألق! حافظ على هذا الزخم واستمر';

  @override
  String get active_session_quote_four => 'تبقى القليل فقط، أنت تقوم بعمل رائع';

  @override
  String active_session_quote_five(String durationString) {
    return 'تهانينا 🎉\nلقد أتممت جلسة التركيز التي استغرقت $durationString.\n\nعمل رائع، استمر في هذا الأداء المذهل';
  }

  @override
  String get restriction_groups_tab_title => 'مجموعات القيود';

  @override
  String get restriction_groups_tab_info =>
      'حدد حدا زمنيا مجمعا لاستخدام شاشة مجموعة من التطبيقات. عند الوصول إلى الحد الإجمالي، سيتم إيقاف جميع التطبيقات في المجموعة لمساعدتك على الحفاظ على التركيز والتوازن.';

  @override
  String get restriction_group_time_spent_label => 'الوقت المستغرق اليوم';

  @override
  String get restriction_group_time_left_label => 'الوقت المتبقي اليوم';

  @override
  String get restriction_group_name_tile_title => 'اسم المجموعة';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'أدخل اسما لمجموعة القيود لتسهيل التعرف عليها وإدارتها.';

  @override
  String get restriction_group_timer_tile_title => 'مؤقت المجموعة';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'حدد حدا زمنيا يوميا لهذه المجموعة. عند الوصول إلى الحد، سيتم إيقاف جميع التطبيقات في هذه المجموعة حتى منتصف الليل.';

  @override
  String get restriction_group_active_period_tile_title => 'فترة نشاط المجموعة';

  @override
  String get remove_restriction_group_dialog_title => 'حذف المجموعة';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'هل أنت متأكد من رغبتك في إزالة \'$groupName\' من مجموعات القيود.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'قم بتحديد مؤقت أو حد فترة نشاط.';

  @override
  String get notifications_empty_list_hint =>
      'لم يتم تجميع أي إشعارات لهذا اليوم.';

  @override
  String get conversations_label => 'المحادثات';

  @override
  String get last_24_hours_heading => 'آخر 24 ساعة';

  @override
  String get notification_timeline_tab_info =>
      'تصفح سجل إشعاراتك عن طريق اختيار تاريخ من التقويم. راجع التطبيقات التي لفتت انتباهك وتأمل في عاداتك الرقمية.';

  @override
  String get monthly_label => 'شهريا';

  @override
  String get daily_label => 'يوميا';

  @override
  String get search_notifications_sheet_info =>
      'ابحث بسهولة في الإشعارات السابقة من خلال العنوان أو المحتوى. يساعدك ذلك على العثور بسرعة على التنبيهات المهمة.';

  @override
  String get search_notifications_hint => 'ابحث في الإشعارات...';

  @override
  String get search_notifications_empty_list_hint =>
      'لم يتم العثور على إشعارات تطابق بحثك.';

  @override
  String get app_info_none_warning =>
      'تعذر العثور على التطبيق للحزمة المحددة. جار العودة إلى الشاشة الرئيسية.';

  @override
  String get emergency_fab_button => 'طوارئ';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'سيؤدي هذا الإجراء إلى إيقاف مؤقت لحاجز التطبيقات لمدة 5 دقائق القادمة. لديك $leftPassesCount فرص متبقية. بعد استخدام كل الفرص، سيظل التطبيق محظورا حتى منتصف الليل أو انتهاء جلسة التركيز النشطة.\n\nهل ترغب في المتابعة؟';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'استخدم على أي حال';

  @override
  String get emergency_started_snack_alert =>
      'تم إيقاف حاجز التطبيقات مؤقتا وسيستأنف الحظر خلال 5 دقائق.';

  @override
  String get emergency_already_active_snack_alert =>
      'مؤقت التطبيق حاليا إما موقوف أو غير نشط. إذا كانت الإشعارات مفعلة، ستتلقى تحديثات حول الوقت المتبقي.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'لقد استخدمت جميع فرص الطوارئ المتاحة لك. ستظل التطبيقات المحجوبة محظورة حتى منتصف الليل، أو حتى انتهاء جلسة التركيز النشطة.';

  @override
  String get app_limit_status_not_set => 'غير محدد';

  @override
  String get app_timer_tile_title => 'مؤقت التطبيق';

  @override
  String get app_timer_picker_dialog_info =>
      'حدد حدا زمنيا يوميا لهذا التطبيق. عند الوصول إلى الحد، سيتم إيقاف التطبيق حتى منتصف الليل.';

  @override
  String get usage_reminders_tile_title => 'تذكيرات الاستخدام';

  @override
  String get usage_reminders_tile_subtitle =>
      'تنبيهات لطيفة عند استخدام التطبيقات المحددة بالوقت.';

  @override
  String get app_launch_limit_tile_title => 'حد الإطلاق';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'تم الإطلاق $count مرة اليوم.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'حدد عدد المرات التي يمكنك فيها فتح هذا التطبيق يوميا. بمجرد الوصول إلى الحد، سيتم إيقافه مؤقتا حتى منتصف الليل.';

  @override
  String get app_active_period_tile_title => 'الفترة النشطة';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'من $startTime إلى $endTime';
  }

  @override
  String get internet_access_tile_title => 'الوصول إلى الإنترنت';

  @override
  String get internet_access_tile_subtitle =>
      'قم بإيقاف التشغيل لحظر اتصال التطبيق بالإنترنت.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'تم حظر الإنترنت لتطبيق $appName.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'تم رفع الحظر عن الإنترنت لتطبيق $appName.';
  }

  @override
  String get launch_app_tile_title => 'فتح التطبيق';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'افتح $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'اذهب إلى إعدادات التطبيق';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'قم بإدارة إعدادات التطبيق مثل الإشعارات، الأذونات، التخزين والمزيد.';

  @override
  String get include_in_stats_tile_title => 'تضمين في استخدام الشاشة';

  @override
  String get include_in_stats_tile_subtitle =>
      'قم بإيقاف التشغيل لاستبعاد هذا التطبيق من إجمالي استخدام الشاشة.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return 'تم استبعاد $appName من إجمالي استخدام الشاشة.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return 'تم تضمين $appName في إجمالي استخدام الشاشة.';
  }

  @override
  String get general_tab_title => 'عام';

  @override
  String get appearance_heading => 'المظهر';

  @override
  String get theme_mode_tile_title => 'وضع السمة';

  @override
  String get theme_mode_system_label => 'النظام';

  @override
  String get theme_mode_light_label => 'فاتح';

  @override
  String get theme_mode_dark_label => 'داكن';

  @override
  String get material_color_tile_title => 'لون المواد';

  @override
  String get amoled_dark_tile_title => 'الوضع الداكن AMOLED';

  @override
  String get amoled_dark_tile_subtitle =>
      'استخدم اللون الأسود النقي في وضع السمة الداكنة.';

  @override
  String get dynamic_colors_tile_title => 'ألوان ديناميكية';

  @override
  String get dynamic_colors_tile_subtitle =>
      'استخدم ألوان الجهاز إذا كانت مدعومة.';

  @override
  String get defaults_heading => 'الإعدادات الافتراضية';

  @override
  String get app_language_tile_title => 'لغة التطبيق';

  @override
  String get default_home_tab_tile_title => 'علامة التبويب الرئيسية';

  @override
  String get usage_history_tile_title => 'سجل الاستخدام';

  @override
  String get usage_history_15_days => '15 يوما';

  @override
  String get usage_history_1_month => 'شهر 1';

  @override
  String get usage_history_3_month => '3 أشهر';

  @override
  String get usage_history_6_month => '6 أشهر';

  @override
  String get usage_history_1_year => 'سنة 1';

  @override
  String get service_heading => 'خدمة';

  @override
  String get service_stopping_warning =>
      'إذا توقف تطبيق NLP digitox عن العمل فجأة، يرجى منح إذن \"تجاهل تحسين البطارية\" ليتمكن من العمل في الخلفية. إذا استمرت المشكلة، حاول إضافة NLP digitox إلى القائمة البيضاء لضمان أداء مستمر دون انقطاع.';

  @override
  String get whitelist_app_tile_title => 'أضف NLP digitox إلى القائمة البيضاء';

  @override
  String get whitelist_app_tile_subtitle =>
      'اسمح لتطبيق NLP digitox بالبدء التلقائي.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'هذا الجهاز لا يدعم إدارة التشغيل التلقائي.';

  @override
  String get database_tab_title => 'قاعدة البيانات';

  @override
  String get import_db_tile_title => 'استيراد قاعدة البيانات';

  @override
  String get import_db_tile_subtitle => 'استيراد قاعدة البيانات من ملف.';

  @override
  String get export_db_tile_title => 'تصدير قاعدة البيانات';

  @override
  String get export_db_tile_subtitle => 'تصدير قاعدة البيانات إلى ملف.';

  @override
  String get analysis_tab_title => 'التحليل';

  @override
  String get analysis_7_days => '7 أيام';

  @override
  String get analysis_30_days => '30 يومًا';

  @override
  String get analysis_90_days => '90 يومًا';

  @override
  String get analysis_screen_time_trend => 'اتجاه وقت الشاشة';

  @override
  String get analysis_no_data_info =>
      'لا توجد بيانات وقت شاشة مسجلة لهذه الفترة بعد.';

  @override
  String get analysis_daily_average => 'المتوسط اليومي';

  @override
  String get analysis_total => 'الإجمالي';

  @override
  String get analysis_no_change => 'نفس الأسبوع الماضي';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% أقل من الأسبوع الماضي';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% أكثر من الأسبوع الماضي';
  }

  @override
  String get crash_logs_heading => 'سجلات الأعطال';

  @override
  String get crash_logs_info =>
      'إذا واجهت أي مشكلة، يمكنك الإبلاغ عنها على GitHub مع ملف السجل. يحتوي الملف على تفاصيل مثل الشركة المصنعة لجهازك، الطراز، إصدار أندرويد، إصدار SDK، وسجلات الأعطال. ستساعدنا هذه المعلومات في تحديد المشكلة وحلها بشكل أفضل.';

  @override
  String get crash_logs_export_tile_title => 'تصدير سجلات الأعطال';

  @override
  String get crash_logs_export_tile_subtitle =>
      'تصدير سجلات الأعطال إلى ملف JSON.';

  @override
  String get crash_logs_view_tile_title => 'عرض السجلات';

  @override
  String get crash_logs_view_tile_subtitle => 'استعرض سجلات الأعطال المخزنة.';

  @override
  String get crash_logs_empty_list_hint => 'لم يتم تسجيل أي أعطال حتى الآن.';

  @override
  String get crash_logs_clear_tile_title => 'مسح السجلات';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'حذف جميع سجلات الأعطال من قاعدة البيانات.';

  @override
  String get crash_logs_clear_dialog_info =>
      'هل أنت متأكد أنك تريد مسح جميع سجلات الأعطال من قاعدة البيانات؟';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'امسح على أي حال';

  @override
  String get about_tab_title => 'حول';

  @override
  String get changelog_tile_title => 'سجل التغييرات';

  @override
  String get changelog_tile_subtitle => 'اكتشف الجديد.';

  @override
  String get full_changelog_tile_title => 'سجل التغييرات الكامل';

  @override
  String get redirected_to_github_subtitle => 'سيتم توجيهك إلى GitHub.';

  @override
  String get contribute_heading => 'شارك في التطوير';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'عرض كود المصدر.';

  @override
  String get report_issue_tile_title => 'الإبلاغ عن مشكلة';

  @override
  String get suggest_idea_tile_title => 'اقترح فكرة';

  @override
  String get write_email_tile_title => 'راسلنا عبر البريد الإلكتروني';

  @override
  String get write_email_tile_subtitle =>
      'سيتم توجيهك إلى تطبيق البريد الإلكتروني.';

  @override
  String get privacy_policy_heading => 'سياسة الخصوصية';

  @override
  String get privacy_policy_info =>
      'تلتزم NLP digitox بحماية خصوصيتك. نحن لا نجمع أو نخزن أو ننقل أي نوع من بيانات المستخدم. يعمل التطبيق بالكامل دون اتصال بالإنترنت، مما يضمن بقاء معلوماتك الشخصية خاصة وآمنة على جهازك. كبرنامج مجاني ومفتوح المصدر (FOSS)، يضمن NLP digitox شفافية كاملة وتحكم المستخدم الكامل في بياناته.';

  @override
  String get more_details_button => 'مزيد من التفاصيل';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
