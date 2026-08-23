// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get mindful_tagline =>
      'Сосредоточьтесь на том, что действительно важно';

  @override
  String get unlock_button_label => 'Разблокировать';

  @override
  String get permission_status_off => 'Выкл.';

  @override
  String get permission_status_allowed => 'Разрешено';

  @override
  String get permission_status_not_allowed => 'Не разрешено';

  @override
  String get permission_button_grant_permission => 'Предоставить разрешение';

  @override
  String get permission_button_agree_and_continue => 'Согласиться и продолжить';

  @override
  String get permission_button_not_now => 'Не сейчас';

  @override
  String get permission_button_help => 'Помощь?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox на 100% безопасен и работает в автономном режиме. Мы не собираем и не храним никаких персональных данных.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Нажмите кнопку $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Выберите NLP digitox на следующем экране.';

  @override
  String get permission_grant_step_three =>
      '3. Нажмите и включите переключатель, как показано ниже.';

  @override
  String get permission_notification_title => 'Отправлять уведомления';

  @override
  String get permission_alarms_title => 'Сигналы тревоги и напоминания';

  @override
  String get permission_alarms_info =>
      'Предоставьте разрешение на установку будильников и напоминаний. Это позволит NLP digitox вовремя начинать отход ко сну и сбрасывать таймеры приложений ежедневно в полночь, что поможет вам не сбиться с пути.';

  @override
  String get permission_alarms_device_tile_label =>
      'Разрешить установку будильников и напоминаний';

  @override
  String get permission_usage_title => 'Доступ к использованию';

  @override
  String get permission_usage_info =>
      'Пожалуйста, предоставьте разрешение на использование. Это позволит NLP digitox отслеживать использование приложений и управлять доступом к определенным приложениям, обеспечивая более целенаправленную и контролируемую цифровую среду.';

  @override
  String get permission_usage_device_tile_label =>
      'Разрешить доступ к использованию';

  @override
  String get permission_overlay_title => 'Наложение дисплея';

  @override
  String get permission_overlay_info =>
      'Предоставьте разрешение на наложение изображения. Это позволит NLP digitox отображать наложение при открытии приостановленного приложения, что поможет вам сосредоточиться и сохранить расписание.';

  @override
  String get permission_overlay_device_tile_label =>
      'Разрешить отображение поверх других приложений';

  @override
  String get permission_accessibility_title => 'Доступность';

  @override
  String get permission_accessibility_info =>
      'Пожалуйста, предоставьте разрешение на доступ. Это позволит NLP digitox ограничивать доступ к коротким видеоконтентам (например, роликам, короткометражкам) в приложениях и браузерах социальных сетей, а также фильтровать неподходящие веб-сайты.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox требует разрешения на доступ для эффективной блокировки короткого контента и веб-сайтов.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Используйте NLP digitox';

  @override
  String get permission_dnd_title => 'Не беспокоить';

  @override
  String get permission_dnd_info =>
      'Пожалуйста, предоставьте доступ к режиму «Не беспокоить». Это позволит NLP digitox запускать и отключать режим «Не беспокоить» во время сна.';

  @override
  String get permission_dnd_tile_title => 'Начать «Не беспокоить»';

  @override
  String get permission_dnd_tile_subtitle =>
      'Также включите режим «Не беспокоить».';

  @override
  String get permission_battery_optimization_tile_title =>
      'Игнорировать оптимизацию батареи';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Уже неограничено';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Отключить фоновое ограничение';

  @override
  String get permission_battery_optimization_allow_info =>
      'Разрешение «Игнорировать оптимизацию батареи» автоматически предоставит разрешение «Будильник и напоминания» на некоторых устройствах.';

  @override
  String get permission_vpn_title => 'Создать VPN';

  @override
  String get permission_vpn_info =>
      'Предоставьте разрешение на создание подключения к виртуальной частной сети (VPN). Это позволит NLP digitox ограничивать доступ в Интернет для определенных приложений, создавая локальную VPN на устройстве.';

  @override
  String get permission_admin_title => 'Админ';

  @override
  String get permission_admin_info =>
      'Административные привилегии необходимы только для основных операций, чтобы обеспечить правильную работу приложения и его защиту от несанкционированного доступа.';

  @override
  String get permission_admin_snack_alert =>
      'Защита от несанкционированного доступа может быть отключена только в течение выбранного временного окна.';

  @override
  String get permission_notification_access_title => 'Доступ к уведомлениям';

  @override
  String get permission_notification_access_info =>
      'Пожалуйста, предоставьте разрешение на доступ к уведомлениям. Это позволит NLP digitox систематизировать ваши уведомления и доставлять их по вашему расписанию.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox требует доступа к пакетным и запланированным уведомлениям.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Разрешить доступ к уведомлениям';

  @override
  String get day_today => 'Сегодня';

  @override
  String get day_yesterday => 'Вчера';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString дней',
      one: '1 день',
      zero: '0 дней',
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
      other: '$countString часов',
      one: '1 час',
      zero: '0 часов',
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
      other: '$countString минут',
      one: '1 минута',
      zero: '0 минут',
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
      other: '$countString секунд',
      one: '1 секунда',
      zero: '0 секунд',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'и';

  @override
  String get timer_status_active => 'Активный';

  @override
  String get timer_status_paused => 'Приостановлено';

  @override
  String get create_button => 'Создать';

  @override
  String get update_button => 'Обновить';

  @override
  String get dialog_button_cancel => 'Отмена';

  @override
  String get dialog_button_remove => 'Удалить';

  @override
  String get dialog_button_set => 'Установить';

  @override
  String get dialog_button_reset => 'Сброс';

  @override
  String get dialog_button_infinite => 'бесконечный';

  @override
  String get schedule_start_label => 'Старт';

  @override
  String get schedule_end_label => 'Конец';

  @override
  String get exit_without_saving_dialog_info =>
      'Вы уверены, что хотите выйти без сохранения?';

  @override
  String get development_dialog_info =>
      'NLP digitox в настоящее время находится в разработке и может содержать ошибки или неполные функции. Если у вас возникнут какие-либо проблемы, сообщите о них, чтобы помочь нам улучшить. \n\nСпасибо за ваш отзыв!';

  @override
  String get development_dialog_button_report_issue => 'Сообщить о проблеме';

  @override
  String get development_dialog_button_close => 'Закрыть';

  @override
  String get dnd_settings_tile_title => 'Настройки «Не беспокоить»';

  @override
  String get dnd_settings_tile_subtitle =>
      'Управляйте тем, какие приложения и уведомления могут доходить до вас в режиме «Не беспокоить».';

  @override
  String get quick_actions_heading => 'Быстрые действия';

  @override
  String get select_distracting_apps_heading =>
      'Выбирайте отвлекающие приложения';

  @override
  String get your_distracting_apps_heading => 'Ваши отвлекающие приложения';

  @override
  String get select_more_apps_heading => 'Выбрать больше приложений';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Добавление важных системных приложений в список отвлекающих приложений запрещено.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Использование экрана и ограничения недоступны для этого приложения. В настоящее время доступно только использование сети.';

  @override
  String get create_group_fab_button => 'Создать группу';

  @override
  String get active_period_info =>
      'Установите период времени, в течение которого будет разрешен доступ. Вне этого периода доступ будет ограничен.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Выберите хотя бы одно отвлекающее приложение.';

  @override
  String get donation_card_title => 'Поддержите нас';

  @override
  String get donation_card_info =>
      'NLP digitox — бесплатная программа с открытым исходным кодом, разработанная месяцами самоотверженной работы. Если это помогло вам, ваше пожертвование будет значить для нас мир. Каждый вклад помогает нам продолжать улучшать и поддерживать его для всех.';

  @override
  String get operation_failed_snack_alert =>
      'Операция провалилась, что-то пошло не так!';

  @override
  String get donation_card_button_donate => 'Пожертвовать';

  @override
  String get app_restart_dialog_title => 'Требуется перезагрузка';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox автоматически перезапустится после завершения обратного отсчета. Пожалуйста, будьте терпеливы, поскольку изменения применяются.';

  @override
  String get accessibility_tip =>
      'Хотите более умную и экономичную блокировку? Включите разрешение на доступность для NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox не работает? Разрешите «Игнорировать оптимизацию батареи» в настройках, чтобы обеспечить бесперебойную работу.';

  @override
  String get invincible_mode_tip =>
      'Случайно сняли ограничения? Используйте режим «Непобедимый», чтобы заблокировать их до следующего дня или окна корректировок.';

  @override
  String get glance_usage_tip =>
      'Хотите получить информацию? Проверьте раздел «Взгляд», чтобы просмотреть особенности использования и время использования экрана.';

  @override
  String get tamper_protection_tip =>
      'Удаление NLP digitox? Включите окно удаления, чтобы сначала безопасно отключить защиту от несанкционированного доступа.';

  @override
  String get notification_blocking_tip =>
      'Хотите уменьшить количество отвлекающих факторов? Используйте блокировку уведомлений, чтобы отключить звук выбранных приложений.';

  @override
  String get usage_history_tip =>
      'Хотите поразмышлять о своих привычках? Проверьте историю использования, чтобы увидеть прошлые шаблоны.';

  @override
  String get focus_mode_tip =>
      'Нужен глубокий фокус? Включите режим фокусировки, чтобы блокировать приложения и уведомления во время выполнения задач.';

  @override
  String get bedtime_reminder_tip =>
      'Хотите улучшить свой сон? Установите напоминание перед сном, чтобы расслабиться каждую ночь.';

  @override
  String get custom_blocking_tip =>
      'Нужен индивидуальный опыт? Создайте правила блокировки приложений, соответствующие вашим потребностям.';

  @override
  String get session_timeline_tip =>
      'Хотите отслеживать сеансы фокусировки? Просмотрите хронологию, чтобы увидеть свое фокусное путешествие.';

  @override
  String get short_content_blocking_tip =>
      'Вас отвлекают социальные приложения? Блокируйте короткий контент в Instagram, YouTube и т. д., чтобы оставаться сосредоточенным.';

  @override
  String get parental_controls_tip =>
      'Нужен родительский контроль? Установите ограничения для устройства вашего ребенка, чтобы обеспечить безопасность.';

  @override
  String get notification_batching_tip =>
      'Хотите уменьшить количество отвлекающих факторов? Используйте пакетную обработку уведомлений, чтобы группировать уведомления и проверять их одновременно.';

  @override
  String get notification_scheduling_tip =>
      'Нужно управлять уведомлениями? Запланируйте получение уведомлений для определенных приложений.';

  @override
  String get quick_focus_tile_tip =>
      'Нужен быстрый доступ к фокусу? Добавьте плитку быстрой фокусировки, чтобы мгновенно активировать режим фокусировки.';

  @override
  String get app_shortcuts_tip =>
      'Хотите мгновенный доступ к приложению? Добавьте ярлыки, нажав и удерживая значок приложения для быстрых действий.';

  @override
  String get backup_usage_db_tip =>
      'Хотите сохранить свои данные? Сделайте резервную копию базы данных об использовании, чтобы обеспечить безопасность ваших записей.';

  @override
  String get dynamic_material_color_tip =>
      'Хотите собственную тему? Включить динамический материал. Вы раскрашиваете его в соответствии с темой вашего устройства.';

  @override
  String get amoled_dark_theme_tip =>
      'Хотите сэкономить заряд батареи? Используйте AMOLED Dark Theme, чтобы снизить энергопотребление на OLED-экранах.';

  @override
  String get customize_usage_history_tip =>
      'Хотите сохранить историю использования? Настройте, сколько недель данные будут храниться в истории использования.';

  @override
  String get grouped_apps_blocking_tip =>
      'Хотите заблокировать приложения вместе? Используйте группы ограничений, чтобы сгруппировать ограничения приложений и заблокировать несколько приложений одновременно.';

  @override
  String get websites_blocking_tip =>
      'Хотите более чистый опыт просмотра? Блокируйте пользовательские веб-сайты или веб-сайты NSFW, чтобы более сконцентрировано проводить время в Интернете.';

  @override
  String get data_usage_tip =>
      'Хотите отслеживать свои данные? Контролируйте использование данных мобильного телефона и Wi-Fi для использования в Интернете.';

  @override
  String get block_internet_tip =>
      'Хотите заблокировать интернет для приложения? Отключите Интернет для конкретного приложения на панели управления приложения.';

  @override
  String get emergency_passes_tip =>
      'Нужен перерыв? Используйте 3 аварийных пропуска в день, чтобы временно разблокировать приложения на 5 минут.';

  @override
  String get onboarding_skip_btn_label => 'Пропустить';

  @override
  String get onboarding_finish_setup_btn_label => 'Завершить настройку';

  @override
  String get onboarding_page_welcome_title => 'Добро пожаловать в NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Возьмите под контроль свою цифровую жизнь и выработайте более здоровые привычки использования экрана. NLP digitox помогает вам оставаться сосредоточенным, сокращать отвлекающие факторы и делать осознанный выбор каждый день.';

  @override
  String get onboarding_page_statistics_title => 'Узнайте свои привычки.';

  @override
  String get onboarding_page_statistics_info =>
      'Поймите свои цифровые модели с помощью подробной информации о времени у экрана, использовании приложений и тенденциях концентрации. Отслеживайте свой прогресс и увидьте, как небольшие изменения приводят к большим улучшениям.';

  @override
  String get onboarding_page_one_title => 'Мастер Фокус.';

  @override
  String get onboarding_page_one_info =>
      'Приостанавливайте отвлекающие приложения, блокируйте короткий контент и не сбивайтесь с пути с помощью настраиваемых сеансов фокусировки. Независимо от того, работаете ли вы, учитесь или отдыхаете, NLP digitox поможет вам сохранять контроль.';

  @override
  String get onboarding_page_two_title => 'Блокируйте отвлекающие факторы.';

  @override
  String get onboarding_page_two_info =>
      'Устанавливайте ограничения на использование, автоматически приостанавливайте приложения и формируйте более здоровые цифровые привычки. Используйте ночной режим, чтобы расслабиться и провести ночь без отвлекающих факторов.';

  @override
  String get onboarding_page_three_title => 'Конфиденциальность прежде всего.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox на 100% имеет открытый исходный код и работает полностью в автономном режиме. Мы не собираем и не передаем ваши персональные данные — ваша конфиденциальность гарантируется всеми возможными способами.';

  @override
  String get onboarding_page_permissions_title => 'Основные разрешения.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox требует следующих основных разрешений, чтобы отслеживать и управлять временем, проведенным за экраном, помогая уменьшить отвлекающие факторы и улучшить концентрацию внимания.';

  @override
  String get dashboard_tab_title => 'Панель управления';

  @override
  String get focus_now_fab_button => 'Сосредоточьтесь сейчас';

  @override
  String get welcome_greetings => 'С возвращением,';

  @override
  String get username_snack_alert =>
      'Длительное нажатие, чтобы изменить имя пользователя.';

  @override
  String get username_dialog_title => 'Имя пользователя';

  @override
  String get username_dialog_info =>
      'Введите свое имя пользователя, которое будет отображаться на панели управления.';

  @override
  String get username_dialog_button_apply => 'Применить';

  @override
  String get glance_tile_title => 'Взгляд';

  @override
  String get glance_tile_subtitle => 'Взгляните на свое использование.';

  @override
  String get parental_controls_tile_subtitle =>
      'Непобедимый режим и защита от несанкционированного доступа.';

  @override
  String get restrictions_heading => 'Ограничения';

  @override
  String get apps_blocking_tile_title => 'Блокировка приложений';

  @override
  String get apps_blocking_tile_subtitle =>
      'Ограничьте приложения несколькими способами.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Блокировка групповых приложений';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Ограничьте группу приложений одновременно.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Ограничьте короткий контент на нескольких платформах.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Ограничьте количество сайтов для взрослых и пользовательских веб-сайтов.';

  @override
  String get screen_time_label => 'Экранное время';

  @override
  String get total_data_label => 'Общие данные';

  @override
  String get mobile_data_label => 'Мобильные данные';

  @override
  String get wifi_data_label => 'Данные Wi-Fi';

  @override
  String get focus_today_label => 'Сосредоточьтесь сегодня';

  @override
  String get focus_weekly_label => 'Фокус еженедельно';

  @override
  String get focus_monthly_label => 'Фокус ежемесячно';

  @override
  String get focus_lifetime_label => 'Срок службы фокуса';

  @override
  String get longest_streak_label => 'Самая длинная серия';

  @override
  String get current_streak_label => 'Текущая серия';

  @override
  String get successful_sessions_label => 'Успешные сессии';

  @override
  String get failed_sessions_label => 'Неудачные сеансы';

  @override
  String get statistics_tab_title => 'Статистика';

  @override
  String get screen_segment_label => 'Экран';

  @override
  String get data_segment_label => 'Данные';

  @override
  String get mobile_label => 'Мобильный';

  @override
  String get wifi_label => 'Wi-Fi';

  @override
  String get most_used_apps_heading => 'Наиболее часто используемые приложения';

  @override
  String get show_all_apps_tile_title => 'Показать все приложения';

  @override
  String get search_apps_hint => 'Поиск приложений...';

  @override
  String get notifications_tab_title => 'Уведомления';

  @override
  String get notifications_tab_info =>
      'Пакетное уведомление из приложений и установка расписаний, таких как утро, полдень, вечер и ночь. Будьте в курсе без постоянных перерывов.';

  @override
  String get batched_apps_tile_title => 'Пакетные приложения';

  @override
  String get batch_recap_dropdown_title => 'Тип пакетного отчета';

  @override
  String get batch_recap_dropdown_info =>
      'Выберите, что нажимать при срабатывании расписания — все уведомления или только сводку.';

  @override
  String get batch_recap_option_summery_only => 'Только сводка';

  @override
  String get batch_recap_option_all_notifications => 'Все уведомления';

  @override
  String get notification_history_tile_title => 'История уведомлений';

  @override
  String get store_all_tile_title => 'Сохранять все уведомления';

  @override
  String get store_all_tile_subtitle =>
      'Также сохраняйте непакетированные уведомления.';

  @override
  String get schedules_heading => 'Расписания';

  @override
  String get new_schedule_fab_button => 'Новое расписание';

  @override
  String get new_schedule_dialog_info =>
      'Введите имя расписания уведомлений, чтобы его можно было легко идентифицировать.';

  @override
  String get new_schedule_dialog_field_label => 'Название расписания';

  @override
  String get bedtime_tab_title => 'перед сном';

  @override
  String get bedtime_tab_info =>
      'Установите график сна, выбрав период времени и дни недели. Выберите отвлекающие приложения, которые нужно заблокировать, и включите режим «Не беспокоить» (DND), чтобы провести спокойную ночь.';

  @override
  String get schedule_tile_title => 'Расписание';

  @override
  String get schedule_tile_subtitle =>
      'Включить или отключить ежедневное расписание.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Выберите хотя бы один день недели.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Общая продолжительность сна должна составлять не менее 30 минут.';

  @override
  String get distracting_apps_tile_title => 'Отвлекающие приложения';

  @override
  String get distracting_apps_tile_subtitle =>
      'Выберите, какие приложения отвлекают вас от рутины перед сном.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Изменения в списке отвлекающих приложений не допускаются, пока активирован график отхода ко сну.';

  @override
  String get parental_controls_tab_title => 'Родительский контроль';

  @override
  String get invincible_mode_heading => 'Непобедимый режим';

  @override
  String get invincible_mode_tile_title => 'Активировать режим непобедимости';

  @override
  String get invincible_mode_info =>
      'Если режим «Непобедимый» включен, вы не сможете изменять выбранные лимиты после достижения дневной квоты. Однако вы можете внести изменения в течение выбранного 10-минутного окна непобедимости.';

  @override
  String get invincible_mode_snack_alert =>
      'Из-за режима непобедимости изменение ограничений не допускается.';

  @override
  String get invincible_mode_dialog_info =>
      'Вы абсолютно уверены, что хотите включить режим «Непобедимый»? Это действие необратимо. После включения режима «Непобедимый» вы не сможете его отключить, пока это приложение установлено на вашем устройстве.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Mode нельзя отключить, пока это приложение установлено на вашем устройстве.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Все равно начать';

  @override
  String get invincible_mode_include_timer_tile_title => 'Включить таймер';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Включить лимит запуска';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Включить активный период';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Ограничения приложений';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Запретить изменение выбранных ограничений приложения при превышении дневных лимитов.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Групповые ограничения';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Запретить изменение выбранных ограничений группы после превышения дневных лимитов.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Включить таймер коротких видео';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Предотвращает изменения после достижения дневного лимита коротких позиций.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Включить время сна';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Предотвращает изменения во время активного графика сна.';

  @override
  String get protected_access_tile_title => 'Защищенный доступ';

  @override
  String get protected_access_tile_subtitle =>
      'Защитите NLP digitox с помощью блокировки вашего устройства.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Чтобы включить эту функцию, сначала установите биометрическую блокировку на своем устройстве.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Блокировка вашего устройства снята. Чтобы продолжить, установите новый замок.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Аутентификация не удалась. Чтобы продолжить, вам необходимо подтвердить блокировку устройства.';

  @override
  String get tamper_protection_tile_title =>
      'Защита от несанкционированного доступа';

  @override
  String get tamper_protection_tile_subtitle =>
      'Запретить удаление и принудительно остановить приложение.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'После включения вы не сможете удалить, принудительно остановить или очистить данные NLP digitox, за исключением выбранного окна удаления. Обходных путей нет. \n\nДействуйте на свой страх и риск.';

  @override
  String get uninstall_window_tile_title => 'Окно удаления';

  @override
  String get uninstall_window_tile_subtitle =>
      'Защита от несанкционированного доступа может быть отключена в течение 10 минут с выбранного времени.';

  @override
  String get invincible_window_tile_title => 'Непобедимое окно';

  @override
  String get invincible_window_tile_subtitle =>
      'Выбранные лимиты можно изменить в течение 10 минут с выбранного времени.';

  @override
  String get shorts_blocking_tab_title => 'Блокировка шорт';

  @override
  String get shorts_blocking_tab_info =>
      'Контролируйте, сколько времени вы тратите на короткий контент на таких платформах, как Instagram, YouTube, Snapchat и Facebook, включая их веб-сайты.';

  @override
  String get short_content_heading => 'Короткий контент';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Слева от $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Установите дневной лимит времени для короткого контента. Как только ваш лимит будет достигнут, воспроизведение короткого контента будет приостановлено до полуночи.';

  @override
  String get instagram_features_tile_title => 'Инстаграм';

  @override
  String get instagram_features_tile_subtitle =>
      'Ограничить функции в Instagram.';

  @override
  String get instagram_features_block_reels => 'Ограничить раздел барабанов.';

  @override
  String get instagram_features_block_explore =>
      'Ограничить раздел исследования.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle => 'Ограничьте функции Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Ограничить раздел прожектора.';

  @override
  String get snapchat_features_block_discover =>
      'Ограничить раздел обнаружения.';

  @override
  String get youtube_features_tile_title => 'Ютуб';

  @override
  String get youtube_features_tile_subtitle => 'Ограничить шорты на YouTube.';

  @override
  String get facebook_features_tile_title => 'Фейсбук';

  @override
  String get facebook_features_tile_subtitle =>
      'Ограничить барабаны на Facebook.';

  @override
  String get reddit_features_tile_title => 'Реддит';

  @override
  String get reddit_features_tile_subtitle => 'Ограничьте шорты на Reddit.';

  @override
  String get x_features_tile_title => 'Х';

  @override
  String get x_features_tile_subtitle => 'Ограничить видеопоток на X.';

  @override
  String get threads_features_tile_title => 'Темы';

  @override
  String get threads_features_tile_subtitle =>
      'Ограничьте видео/ролики в темах.';

  @override
  String get websites_blocking_tab_title => 'Блокировка сайтов';

  @override
  String get websites_blocking_tab_info =>
      'Блокируйте веб-сайты для взрослых и любые пользовательские сайты, которые вы выберете, чтобы обеспечить более безопасную и целенаправленную работу в Интернете. Возьмите на себя ответственность за просмотр и не отвлекайтесь.';

  @override
  String get adult_content_heading => 'Контент для взрослых';

  @override
  String get block_nsfw_title => 'Блокировать Нсфв';

  @override
  String get block_nsfw_subtitle =>
      'Запретите браузерам открывать сайты для взрослых и порносайты.';

  @override
  String get block_nsfw_dialog_info =>
      'Вы уверены? Это действие необратимо. Если блокировщик сайтов для взрослых включен, вы не сможете его отключить, пока это приложение установлено на вашем устройстве.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Все равно заблокировать';

  @override
  String get blocked_websites_heading => 'Заблокированные сайты';

  @override
  String get blocked_websites_empty_list_hint =>
      'Нажмите кнопку «+ Добавить веб-сайт», чтобы добавить отвлекающие веб-сайты, которые вы хотите заблокировать.';

  @override
  String get add_website_fab_button => 'Добавить веб-сайт';

  @override
  String get add_website_dialog_title => 'Отвлекающий веб-сайт';

  @override
  String get add_website_dialog_info =>
      'Введите URL-адрес веб-сайта, который вы хотите заблокировать.';

  @override
  String get add_website_dialog_is_nsfw => 'Это сайт nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Предупреждение: сайты Nsfw невозможно удалить после добавления.';

  @override
  String get add_website_dialog_button_block => 'Блокировать';

  @override
  String get add_website_already_exist_snack_alert =>
      'URL-адрес уже добавлен в список заблокированных веб-сайтов.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Неверный URL! Невозможно проанализировать имя хоста.';

  @override
  String get remove_website_dialog_title => 'Удалить сайт';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Вы уверены? вы хотите удалить «$websitehost» с заблокированных веб-сайтов.';
  }

  @override
  String get focus_tab_title => 'Фокус';

  @override
  String get focus_tab_info =>
      'Когда вам нужно время, чтобы сосредоточиться, начните новый сеанс, выбрав тип, выбрав отвлекающие приложения для приостановки и включив режим «Не беспокоить» для непрерывной концентрации.';

  @override
  String get active_session_card_title => 'Активная сессия';

  @override
  String get active_session_card_info =>
      'У вас активная сессия фокусировки! Нажмите «Просмотр», чтобы проверить свой прогресс и узнать, сколько времени прошло.';

  @override
  String get active_session_card_view_button => 'Посмотреть';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Удаление приложений из списка отвлекающих приложений не допускается, пока активен сеанс фокусировки. Однако в течение этого времени вы все равно можете добавлять в список дополнительные приложения.';

  @override
  String get focus_profile_tile_title => 'Профиль фокуса';

  @override
  String get focus_session_duration_tile_title => 'Продолжительность сеанса';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Бесконечно (если ты не остановишься)';

  @override
  String get focus_session_duration_dialog_info =>
      'Пожалуйста, выберите желаемую продолжительность этого фокус-сессии, определив, как долго вы хотите оставаться сосредоточенным и не отвлекаться.';

  @override
  String get focus_profile_customization_tile_title => 'Настройка профиля';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Настройте параметры выбранного профиля.';

  @override
  String get focus_enforce_tile_title => 'Принудительный сеанс';

  @override
  String get focus_enforce_tile_subtitle =>
      'Предотвращает завершение сеанса до истечения времени.';

  @override
  String get focus_session_start_button =>
      'Проведите пальцем, чтобы начать сеанс';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Выберите хотя бы одно отвлекающее приложение, чтобы начать сеанс фокусировки.';

  @override
  String get focus_session_already_active_snack_alert =>
      'У вас уже есть активный сеанс фокусировки. Пожалуйста, завершите или остановите текущий сеанс, прежде чем начинать новый.';

  @override
  String get focus_session_type_study => 'Исследование';

  @override
  String get focus_session_type_work => 'Работа';

  @override
  String get focus_session_type_exercise => 'Упражнение';

  @override
  String get focus_session_type_meditation => 'Медитация';

  @override
  String get focus_session_type_creativeWriting => 'Творческое письмо';

  @override
  String get focus_session_type_reading => 'Чтение';

  @override
  String get focus_session_type_programming => 'Программирование';

  @override
  String get focus_session_type_chores => 'Домашние дела';

  @override
  String get focus_session_type_projectPlanning => 'Планирование проекта';

  @override
  String get focus_session_type_artAndDesign => 'Искусство и дизайн';

  @override
  String get focus_session_type_languageLearning => 'Изучение языка';

  @override
  String get focus_session_type_musicPractice => 'Музыкальная практика';

  @override
  String get focus_session_type_selfCare => 'Уход за собой';

  @override
  String get focus_session_type_brainstorming => 'Мозговой штурм';

  @override
  String get focus_session_type_skillDevelopment => 'Развитие навыков';

  @override
  String get focus_session_type_research => 'Исследования';

  @override
  String get focus_session_type_networking => 'сеть';

  @override
  String get focus_session_type_cooking => 'Кулинария';

  @override
  String get focus_session_type_sportsTraining => 'Спортивная подготовка';

  @override
  String get focus_session_type_restAndRelaxation => 'Отдых и релаксация';

  @override
  String get focus_session_type_other => 'Другое';

  @override
  String get timeline_tab_title => 'Хронология';

  @override
  String get focus_timeline_tab_info =>
      'Изучите свое фокус-путешествие, выбрав дату в календаре. Отслеживайте свой прогресс, вспоминайте свои успехи и учитесь на трудностях.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Ваше общее продуктивное время за выбранный месяц составляет $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Продуктивные дни';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Всего у вас было $daysCount продуктивных дней в выбранном месяце.';
  }

  @override
  String get selected_day_focused_time_label => 'Сосредоточенное время';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Ваше общее время концентрации за выбранный день — $timeString.';
  }

  @override
  String get calender_heading => 'календарь';

  @override
  String get your_sessions_heading => 'Ваши сеансы';

  @override
  String get your_sessions_empty_list_hint =>
      'В выбранный день не зарегистрировано ни одной фокус-сессии.';

  @override
  String get focus_session_tile_timestamp_label => 'Временная метка';

  @override
  String get focus_session_tile_duration_label => 'Продолжительность';

  @override
  String get focus_session_tile_reflection_label => 'Отражение';

  @override
  String get focus_session_state_active => 'Активный';

  @override
  String get focus_session_state_successful => 'Успешный';

  @override
  String get focus_session_state_failed => 'Не удалось';

  @override
  String get active_session_tab_title => 'Сессия';

  @override
  String get active_session_none_warning =>
      'Активный сеанс не найден. Возврат на главный экран.';

  @override
  String get active_session_dialog_button_keep_pushing =>
      'Продолжайте настаивать';

  @override
  String get active_session_finish_dialog_title => 'Готово';

  @override
  String get active_session_finish_dialog_info =>
      'Оставайся сильным! Вы создаете ценный фокус. Вы уверены, что хотите завершить фокус-сессию? Каждый дополнительный момент имеет значение для достижения ваших целей.';

  @override
  String get active_session_giveup_dialog_title => 'Сдавайся';

  @override
  String get active_session_giveup_dialog_info =>
      'Держись! Вы почти у цели, не сдавайтесь! Вы уверены, что хотите завершить фокус-сессию раньше? Прогресс будет потерян.';

  @override
  String get active_session_reflection_dialog_title => 'Отражение сеанса';

  @override
  String get active_session_reflection_dialog_info =>
      'Найдите минутку, чтобы подумать о своем прогрессе. Какова ваша цель на эту сессию? Чего вы достигли во время этой сессии?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Совет: вы всегда можете отредактировать это позже на временной шкале сеанса.';

  @override
  String get active_session_giveup_snack_alert =>
      'Ты сдался! Не волнуйтесь, в следующий раз вы сможете добиться большего. Каждое усилие имеет значение – просто продолжайте';

  @override
  String get active_session_quote_one =>
      'Каждый шаг имеет значение, оставайтесь сильными и продолжайте идти';

  @override
  String get active_session_quote_two =>
      'Оставайтесь сосредоточенными! ты делаешь потрясающий прогресс';

  @override
  String get active_session_quote_three =>
      'Ты сокрушаешь это! Продолжайте набирать обороты';

  @override
  String get active_session_quote_four =>
      'Осталось еще немного, у тебя все отлично';

  @override
  String active_session_quote_five(String durationString) {
    return 'Поздравляем 🎉 \n Вы завершили фокус-сессию $durationString.\n\nОтличная работа, продолжайте в том же духе';
  }

  @override
  String get restriction_groups_tab_title => 'Группы ограничения';

  @override
  String get restriction_groups_tab_info =>
      'Установите общий лимит времени использования экрана для группы приложений. Как только общее использование достигнет вашего предела, все приложения в группе будут приостановлены, чтобы помочь сохранить концентрацию и баланс.';

  @override
  String get restriction_group_time_spent_label => 'Время, потраченное сегодня';

  @override
  String get restriction_group_time_left_label => 'Осталось времени сегодня';

  @override
  String get restriction_group_name_tile_title => 'Название группы';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Введите имя группы ограничений, чтобы ее можно было легко идентифицировать и управлять ею.';

  @override
  String get restriction_group_timer_tile_title => 'Групповой таймер';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Установите дневной лимит времени для этой группы. Как только ваш лимит будет достигнут, все приложения в этой группе будут приостановлены до полуночи.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Активный период группы';

  @override
  String get remove_restriction_group_dialog_title => 'Удалить группу';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Вы уверены? вы хотите удалить «$groupName» из групп ограничений.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Установите таймер или ограничение активного периода.';

  @override
  String get notifications_empty_list_hint =>
      'Уведомлений за этот день не было.';

  @override
  String get conversations_label => 'Разговоры';

  @override
  String get last_24_hours_heading => 'Последние 24 часа';

  @override
  String get notification_timeline_tab_info =>
      'Просмотрите историю уведомлений, выбрав дату в календаре. Посмотрите, какие приложения привлекли ваше внимание, и подумайте о своих цифровых привычках.';

  @override
  String get monthly_label => 'Ежемесячно';

  @override
  String get daily_label => 'Ежедневно';

  @override
  String get search_notifications_sheet_info =>
      'Легко находите прошлые уведомления, выполнив поиск по их названию или содержимому. Помогает быстро найти важные оповещения.';

  @override
  String get search_notifications_hint => 'Уведомления о поиске...';

  @override
  String get search_notifications_empty_list_hint =>
      'Уведомлений, соответствующих вашему запросу, не найдено.';

  @override
  String get app_info_none_warning =>
      'Не удалось найти приложение для данного пакета. Возврат на главный экран.';

  @override
  String get emergency_fab_button => 'Чрезвычайная ситуация';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Это действие приостановит блокировку приложений на следующие 5 минут. У вас остались пасы $leftPassesCount. После использования всех пропусков приложение будет заблокировано до полуночи или до завершения активного сеанса фокусировки.\n\nВы все еще хотите продолжить?';
  }

  @override
  String get emergency_dialog_button_use_anyway =>
      'Использовать в любом случае';

  @override
  String get emergency_started_snack_alert =>
      'Блокировщик приложений приостановлен и возобновит блокировку через 5 минут.';

  @override
  String get emergency_already_active_snack_alert =>
      'Блокировщик приложений в настоящее время либо приостановлен, либо неактивен. Если уведомления включены, вы будете получать обновления об оставшемся времени.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Вы использовали все свои аварийные пропуска. Заблокированные приложения останутся заблокированными до полуночи или до завершения активного сеанса фокусировки.';

  @override
  String get app_limit_status_not_set => 'Не установлено';

  @override
  String get app_timer_tile_title => 'Таймер приложения';

  @override
  String get app_timer_picker_dialog_info =>
      'Установите дневной лимит времени для этого приложения. Как только ваш лимит будет достигнут, приложение будет приостановлено до полуночи.';

  @override
  String get usage_reminders_tile_title => 'Напоминания об использовании';

  @override
  String get usage_reminders_tile_subtitle =>
      'Легкие подталкивания при использовании приложений с таймером.';

  @override
  String get app_launch_limit_tile_title => 'Лимит запуска';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Сегодня запустил $count раз.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Установите, сколько раз вы можете открывать это приложение каждый день. Как только лимит будет достигнут, он будет приостановлен до полуночи.';

  @override
  String get app_active_period_tile_title => 'Активный период';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'От $startTime до $endTime';
  }

  @override
  String get internet_access_tile_title => 'доступ в Интернет';

  @override
  String get internet_access_tile_subtitle =>
      'Выключите, чтобы заблокировать Интернет приложения.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Интернет $appName заблокирован.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Интернет $appName разблокирован.';
  }

  @override
  String get launch_app_tile_title => 'Запустить приложение';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Откройте $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Зайти в настройки приложения';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Управляйте настройками приложения, такими как уведомления, разрешения, хранилище и многое другое.';

  @override
  String get include_in_stats_tile_title => 'Включить в использование экрана';

  @override
  String get include_in_stats_tile_subtitle =>
      'Выключите, чтобы исключить это приложение из общего использования экрана.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName исключен из общего использования экрана.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName включен в общее использование экрана.';
  }

  @override
  String get general_tab_title => 'Общий';

  @override
  String get appearance_heading => 'Внешний вид';

  @override
  String get theme_mode_tile_title => 'Тематический режим';

  @override
  String get theme_mode_system_label => 'Система';

  @override
  String get theme_mode_light_label => 'Свет';

  @override
  String get theme_mode_dark_label => 'Темный';

  @override
  String get material_color_tile_title => 'Цвет материала';

  @override
  String get amoled_dark_tile_title => 'AMOLED темный';

  @override
  String get amoled_dark_tile_subtitle =>
      'Используйте чистый черный цвет для темной темы.';

  @override
  String get dynamic_colors_tile_title => 'Динамические цвета';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Используйте цвета устройства, если они поддерживаются.';

  @override
  String get defaults_heading => 'По умолчанию';

  @override
  String get app_language_tile_title => 'Язык приложения';

  @override
  String get default_home_tab_tile_title => 'Вкладка «Главная»';

  @override
  String get usage_history_tile_title => 'История использования';

  @override
  String get usage_history_15_days => '15 дней';

  @override
  String get usage_history_1_month => '1 месяц';

  @override
  String get usage_history_3_month => '3 месяца';

  @override
  String get usage_history_6_month => '6 месяцев';

  @override
  String get usage_history_1_year => '1 год';

  @override
  String get service_heading => 'Сервис';

  @override
  String get service_stopping_warning =>
      'Если NLP digitox неожиданно перестает работать, предоставьте разрешение «Игнорировать оптимизацию батареи», чтобы он продолжал работать в фоновом режиме. Если проблема не исчезнет, ​​попробуйте внести NLP digitox в белый список для бесперебойной работы.';

  @override
  String get whitelist_app_tile_title => 'Белый список';

  @override
  String get whitelist_app_tile_subtitle =>
      'Разрешить NLP digitox автоматический запуск.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Это устройство не поддерживает автоматическое управление запуском.';

  @override
  String get database_tab_title => 'База данных';

  @override
  String get import_db_tile_title => 'Импортировать базу данных';

  @override
  String get import_db_tile_subtitle => 'Импортировать базу данных из файла.';

  @override
  String get export_db_tile_title => 'Экспорт базы данных';

  @override
  String get export_db_tile_subtitle => 'Экспорт базы данных в файл.';

  @override
  String get analysis_tab_title => 'Анализ';

  @override
  String get analysis_7_days => '7 дней';

  @override
  String get analysis_30_days => '30 дней';

  @override
  String get analysis_90_days => '90 дней';

  @override
  String get analysis_screen_time_trend => 'Тенденция времени у экрана';

  @override
  String get analysis_no_data_info =>
      'Для этого периода еще не записаны данные о времени у экрана.';

  @override
  String get analysis_daily_average => 'Среднесуточное значение';

  @override
  String get analysis_total => 'Итого';

  @override
  String get analysis_no_change => 'Так же, как на прошлой неделе';

  @override
  String analysis_trend_less(String percent) {
    return 'на $percent% меньше, чем на прошлой неделе';
  }

  @override
  String analysis_trend_more(String percent) {
    return 'на $percent% больше, чем на прошлой неделе';
  }

  @override
  String get crash_logs_heading => 'Журналы сбоев';

  @override
  String get crash_logs_info =>
      'Если у вас возникнет какая-либо проблема, вы можете сообщить об этом на GitHub вместе с файлом журнала. Файл будет содержать такие сведения, как производитель, модель вашего устройства, версия Android, версия SDK и журналы сбоев. Эта информация поможет нам более эффективно выявить и решить проблему.';

  @override
  String get crash_logs_export_tile_title => 'Экспортировать журналы сбоев';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Экспортируйте журналы сбоев в файл JSON.';

  @override
  String get crash_logs_view_tile_title => 'Просмотр журналов';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Изучите сохраненные журналы сбоев.';

  @override
  String get crash_logs_empty_list_hint =>
      'До сих пор не зарегистрировано ни одного сбоя.';

  @override
  String get crash_logs_clear_tile_title => 'Очистить журналы';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Удалите все журналы сбоев из базы данных.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Вы уверены, что хотите удалить все журналы сбоев из базы данных?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'Все равно очистить';

  @override
  String get about_tab_title => 'О';

  @override
  String get changelog_tile_title => 'Журнал изменений';

  @override
  String get changelog_tile_subtitle => 'Узнайте, что нового.';

  @override
  String get full_changelog_tile_title => 'Полный список изменений';

  @override
  String get redirected_to_github_subtitle =>
      'Вы будете перенаправлены на GitHub.';

  @override
  String get contribute_heading => 'Внести свой вклад';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Просмотрите исходный код.';

  @override
  String get report_issue_tile_title => 'Сообщить о проблеме';

  @override
  String get suggest_idea_tile_title => 'Предложить идею';

  @override
  String get write_email_tile_title => 'Напишите нам по электронной почте';

  @override
  String get write_email_tile_subtitle =>
      'Вы будете перенаправлены в приложение электронной почты.';

  @override
  String get privacy_policy_heading => 'Политика конфиденциальности';

  @override
  String get privacy_policy_info =>
      'NLP digitox стремится защитить вашу конфиденциальность. Мы не собираем, не храним и не передаем никакие пользовательские данные. Приложение работает полностью в автономном режиме и не требует подключения к Интернету, гарантируя, что ваша личная информация останется конфиденциальной и безопасной на вашем устройстве. Будучи бесплатным программным обеспечением с открытым исходным кодом (FOSS), NLP digitox гарантирует полную прозрачность и контроль пользователей над своими данными.';

  @override
  String get more_details_button => 'Подробнее';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
