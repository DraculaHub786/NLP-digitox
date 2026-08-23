// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get mindful_tagline => 'Skup się na tym, co naprawdę ważne';

  @override
  String get unlock_button_label => 'Odblokuj';

  @override
  String get permission_status_off => 'Włączone';

  @override
  String get permission_status_allowed => 'Zezwolono';

  @override
  String get permission_status_not_allowed => 'Nie zezwolono';

  @override
  String get permission_button_grant_permission => 'Udziel uprawnienia';

  @override
  String get permission_button_agree_and_continue => 'Zaakceptuj i Kontynuuj';

  @override
  String get permission_button_not_now => 'Nie teraz';

  @override
  String get permission_button_help => 'Pomoc';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox jest w 100% bezpieczny i działa offline. Nie zbieramy ani nie przechowujemy żadnych danych osobowych.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Kliknij przycisk $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Wybierz NLP digitox na następnym ekranie.';

  @override
  String get permission_grant_step_three =>
      '3. Kliknij i włącz przełącznik tak jak poniżej.';

  @override
  String get permission_notification_title => 'Wysyłaj powiadomienia';

  @override
  String get permission_alarms_title => 'Alarmy i przypomnienia';

  @override
  String get permission_alarms_info =>
      'Proszę udzielić pozwolenia na ustawianie alarmów i przypomnień. Dzięki temu NLP digitox będzie mógł rozpocząć Twój harmonogram snu na czas i resetować timery aplikacji codziennie o północy, co pomoże Ci utrzymać się na właściwej drodze.';

  @override
  String get permission_alarms_device_tile_label =>
      'Zezwalaj na ustawianie alarmów i przypomnień';

  @override
  String get permission_usage_title => 'Dostęp do danych o użyciu';

  @override
  String get permission_usage_info =>
      'Proszę udzielić pozwolenia na dostęp do danych o użyciu. Pozwoli to NLP digitox monitorować użytkowanie aplikacji i zarządzać dostępem do niektórych aplikacji, zapewniając bardziej skoncentrowane i kontrolowane środowisko cyfrowe.';

  @override
  String get permission_usage_device_tile_label =>
      'Zezwalaj na dostęp do danych o użyciu';

  @override
  String get permission_overlay_title => 'Wyświetl nakładkę';

  @override
  String get permission_overlay_info =>
      'Proszę udzielić pozwolenia na wyświetlanie nakładki. Umożliwi to NLP digitox wyświetlanie nakładki po otwarciu wstrzymanej aplikacji, co pomoże Ci zachować koncentrację i utrzymać harmonogram.';

  @override
  String get permission_overlay_device_tile_label =>
      'Zezwalaj na wyświetlanie nad innymi aplikacjami';

  @override
  String get permission_accessibility_title => 'Dostępność';

  @override
  String get permission_accessibility_info =>
      'Proszę udzielić zezwolenia na dostępność. Pozwoli to NLP digitox ograniczyć dostęp do krótkich treści wideo (np. Reels, Shorts) w aplikacjach mediów społecznościowych i przeglądarkach oraz filtrować nieodpowiednie witryny.';

  @override
  String get permission_accessibility_required =>
      'Pamiętaj, że aby skutecznie blokować krótkie treści i strony internetowe, wymagane jest pozwolenie na dostępność.';

  @override
  String get permission_accessibility_device_tile_label => 'Używaj NLP digitox';

  @override
  String get permission_dnd_title => 'Nie przeszkadzać';

  @override
  String get permission_dnd_info =>
      'Proszę udzielić dostępu do trybu \"Nie przeszkadzać\". Pozwoli to na uruchomienie i zatrzymanie trybu \"Nie przeszkadzać\" podczas snu.';

  @override
  String get permission_dnd_tile_title => 'Uruchom DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Włącz również tryb Nie przeszkadzać.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignoruj Optymalizację Baterii';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Są już wyłączone';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Wyłącz ograniczenia działania aplikacji w tle';

  @override
  String get permission_battery_optimization_allow_info =>
      'Pozwól na \'Ignorowanie optymalizacji baterii\' automatycznie przydzieli uprawnienia \'Alarmy & Przypomnienia\' na niektórych urządzeniach.';

  @override
  String get permission_vpn_title => 'Utwórz sieć VPN';

  @override
  String get permission_vpn_info =>
      'Proszę przyznać uprawnienia do tworzenia połączenia wirtualnej sieci prywatnej (VPN). Umożliwi to NLP digitox ograniczenie dostępu do internetu dla wyznaczonych aplikacji poprzez tworzenie lokalnych sieci VPN na urządzeniu.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Uprawnienia administratora są potrzebne tylko do wykonywania podstawowych operacji, aby mieć pewność, że aplikacja działa prawidłowo i jest zabezpieczona przed manipulacją.';

  @override
  String get permission_admin_snack_alert =>
      'Zabezpieczenie sabotażowe można wyłączyć tylko w wybranym oknie czasowym.';

  @override
  String get permission_notification_access_title => 'Dostęp do powiadomień';

  @override
  String get permission_notification_access_info =>
      'Proszę udzielić pozwolenia na dostęp do powiadomień. Umożliwi to NLP digitox organizowanie powiadomień i dostarczanie ich zgodnie z harmonogramem.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox wymaga dostępu do powiadomień w zakresie powiadomień zbiorczych i harmonogramów.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Zezwól na dostęp do powiadomień';

  @override
  String get day_today => 'Dziś';

  @override
  String get day_yesterday => 'Wczoraj';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dni',
      one: 'dzień',
      zero: '0 dni',
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
      other: '$countString godzin',
      one: '1 godzina',
      zero: '0 godzin',
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
      other: '$countString minuty',
      one: '1 minuta',
      zero: '0 minut',
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
      other: '$countString sekundy',
      one: '1 sekunda',
      zero: '0 sekundy',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'i';

  @override
  String get timer_status_active => 'Aktywny';

  @override
  String get timer_status_paused => 'Wstrzymano';

  @override
  String get create_button => 'Utwórz';

  @override
  String get update_button => 'Aktualizacja';

  @override
  String get dialog_button_cancel => 'Anuluj';

  @override
  String get dialog_button_remove => 'Usuń';

  @override
  String get dialog_button_set => 'Zestaw';

  @override
  String get dialog_button_reset => 'Zresetuj';

  @override
  String get dialog_button_infinite => 'Nieskończony';

  @override
  String get schedule_start_label => 'Zacznij';

  @override
  String get schedule_end_label => 'Koniec';

  @override
  String get exit_without_saving_dialog_info =>
      'Czy na pewno chcesz wyjść bez zapisywania?';

  @override
  String get development_dialog_info =>
      'NLP digitox jest obecnie w fazie rozwoju i może zawierać błędy lub niekompletne funkcje. Jeśli napotkasz jakiekolwiek problemy, zgłoś je, aby pomóc nam ulepszyć.\n\nDziękujemy za Twoją opinię!';

  @override
  String get development_dialog_button_report_issue => 'Zgłoś problem';

  @override
  String get development_dialog_button_close => 'Zamknij';

  @override
  String get dnd_settings_tile_title => 'Nie zakłócaj ustawień';

  @override
  String get dnd_settings_tile_subtitle =>
      'Zarządzaj, które aplikacje i powiadomienia mogą docierać do Ciebie w DND.';

  @override
  String get quick_actions_heading => 'Szybkie działania';

  @override
  String get select_distracting_apps_heading =>
      'Wybierz rozpraszające aplikacje';

  @override
  String get your_distracting_apps_heading => 'Twoje rozpraszające aplikacje';

  @override
  String get select_more_apps_heading => 'Wybierz więcej aplikacji';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Dodawanie ważnych aplikacji systemowych do listy aplikacji rozpraszających jest niedozwolone.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Użycie ekranu i ograniczenia są niedostępne dla tej aplikacji. Obecnie możliwe jest jedynie korzystanie z sieci';

  @override
  String get create_group_fab_button => 'Utwórz grupę';

  @override
  String get active_period_info =>
      'Ustaw okres czasu, w którym dostęp będzie dozwolony. Poza tym okresem dostęp będzie ograniczony.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Wybierz co najmniej jedną rozpraszającą aplikację.';

  @override
  String get donation_card_title => 'Wesprzyj nas';

  @override
  String get donation_card_info =>
      'NLP digitox jest darmowym oprogramowaniem typu open source, rozwijanym miesiącami poświęcenia. Jeśli to Ci pomogło, Twoja darowizna byłaby dla nas całym światem. Każdy wkład pomaga nam w dalszym ulepszaniu i utrzymywaniu go dla wszystkich.';

  @override
  String get operation_failed_snack_alert =>
      'Operacja nie powiodła się, coś poszło nie tak!';

  @override
  String get donation_card_button_donate => 'Przekaż darowiznę';

  @override
  String get app_restart_dialog_title => 'Potrzebujesz ponownego uruchomienia';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox automatycznie uruchomi się ponownie po zakończeniu odliczania. Prosimy o cierpliwość w trakcie stosowania zmian.';

  @override
  String get accessibility_tip =>
      'Chcesz inteligentniejszego i bardziej przyjaznego dla baterii blokowania? Włącz uprawnienia dostępności dla NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox nie działa? Zezwól na opcję „Ignoruj ​​optymalizację baterii” w Ustawieniach, aby zapewnić jej płynne działanie.';

  @override
  String get invincible_mode_tip =>
      'Przypadkowo usunięte ograniczenia? Użyj trybu Niezwyciężonego, aby zablokować je do następnego dnia lub okna dostosowawczego.';

  @override
  String get glance_usage_tip =>
      'Chcesz statystyki? Sprawdź sekcję Spojrzenie, aby zobaczyć wzorce użytkowania i czas korzystania z urządzenia.';

  @override
  String get tamper_protection_tip =>
      'Odinstalować NLP digitox? Włącz okno dezinstalacji, aby najpierw bezpiecznie wyłączyć ochronę przed manipulacją.';

  @override
  String get notification_blocking_tip =>
      'Chcesz ograniczyć czynniki rozpraszające? Użyj blokowania powiadomień, aby wyciszyć wybrane aplikacje.';

  @override
  String get usage_history_tip =>
      'Chcesz zastanowić się nad swoimi nawykami? Sprawdź historię użytkowania, aby zobaczyć wzorce z przeszłości.';

  @override
  String get focus_mode_tip =>
      'Potrzebujesz głębokiego skupienia? Włącz tryb skupienia, aby blokować aplikacje i powiadomienia podczas wykonywania zadań.';

  @override
  String get bedtime_reminder_tip =>
      'Chcesz poprawić swój sen? Ustaw przypomnienie o porze snu, aby co wieczór się zrelaksować.';

  @override
  String get custom_blocking_tip =>
      'Potrzebujesz niestandardowego doświadczenia? Twórz reguły blokowania aplikacji odpowiadające Twoim potrzebom.';

  @override
  String get session_timeline_tip =>
      'Chcesz śledzić sesje fokusowe? Wyświetl oś czasu, aby zobaczyć swoją podróż skupienia.';

  @override
  String get short_content_blocking_tip =>
      'Rozpraszają Cię aplikacje społecznościowe? Blokuj krótkie treści na Instagramie, YouTube itp., aby zachować koncentrację.';

  @override
  String get parental_controls_tip =>
      'Potrzebujesz kontroli rodzicielskiej? Ustaw ograniczenia dla urządzenia dziecka, aby zapewnić mu bezpieczeństwo.';

  @override
  String get notification_batching_tip =>
      'Chcesz ograniczyć czynniki rozpraszające? Użyj funkcji grupowania powiadomień, aby grupować powiadomienia i sprawdzać je jednocześnie.';

  @override
  String get notification_scheduling_tip =>
      'Chcesz zarządzać powiadomieniami? Zaplanuj, kiedy będziesz otrzymywać powiadomienia dotyczące określonych aplikacji.';

  @override
  String get quick_focus_tile_tip =>
      'Potrzebujesz szybkiego dostępu do ostrości? Dodaj płytkę szybkiego skupienia, aby natychmiast aktywować tryb skupienia.';

  @override
  String get app_shortcuts_tip =>
      'Chcesz natychmiastowego dostępu do aplikacji? Dodaj skróty, naciskając długo ikonę aplikacji, aby uzyskać szybkie działania.';

  @override
  String get backup_usage_db_tip =>
      'Chcesz zapisać swoje dane? Utwórz kopię zapasową bazy danych użytkowania, aby zabezpieczyć swoje dane.';

  @override
  String get dynamic_material_color_tip =>
      'Chcesz niestandardowy motyw? Włącz kolor materiału dynamicznego, aby dopasować go do motywu urządzenia.';

  @override
  String get amoled_dark_theme_tip =>
      'Chcesz oszczędzać baterię? Użyj ciemnego motywu AMOLED, aby zmniejszyć zużycie energii na ekranach OLED.';

  @override
  String get customize_usage_history_tip =>
      'Chcesz zachować historię użytkowania? Dostosuj liczbę tygodni przechowywania danych w Historii użytkowania.';

  @override
  String get grouped_apps_blocking_tip =>
      'Chcesz razem blokować aplikacje? Użyj grup ograniczeń, aby grupować limity aplikacji i blokować wiele aplikacji jednocześnie.';

  @override
  String get websites_blocking_tip =>
      'Chcesz czystszego przeglądania? Blokuj witryny niestandardowe lub witryny NSFW, aby uzyskać bardziej skoncentrowany czas online.';

  @override
  String get data_usage_tip =>
      'Chcesz śledzić swoje dane? Monitoruj wykorzystanie danych mobilnych i Wi-Fi do korzystania z Internetu.';

  @override
  String get block_internet_tip =>
      'Chcesz zablokować internet aplikacji? Odetnij internet dla określonej aplikacji z panelu aplikacji.';

  @override
  String get emergency_passes_tip =>
      'Potrzebujesz przerwy? Korzystaj z 3 karnetów awaryjnych dziennie, aby tymczasowo odblokować aplikacje na 5 minut.';

  @override
  String get onboarding_skip_btn_label => 'Pomiń';

  @override
  String get onboarding_finish_setup_btn_label => 'Zakończ konfigurację';

  @override
  String get onboarding_page_welcome_title => 'Witamy w NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Przejmij kontrolę nad swoim cyfrowym życiem i zbuduj zdrowsze nawyki korzystania z ekranu. NLP digitox pomaga Ci pozostać skupionym, ograniczać rozpraszacze i dokonywać świadomych wyborów każdego dnia.';

  @override
  String get onboarding_page_statistics_title => 'Poznaj swoje nawyki.';

  @override
  String get onboarding_page_statistics_info =>
      'Zrozum swoje cyfrowe wzorce dzięki szczegółowym informacjom o czasie spędzonym przed ekranem, korzystaniu z aplikacji i trendach koncentracji. Śledź swoje postępy i zobacz, jak małe zmiany prowadzą do dużych ulepszeń.';

  @override
  String get onboarding_page_one_title => 'Mistrz ostrości.';

  @override
  String get onboarding_page_one_info =>
      'Wstrzymuj rozpraszające aplikacje, blokuj krótkie treści i bądź na bieżąco dzięki konfigurowalnym sesjom skupienia. Niezależnie od tego, czy pracujesz, uczysz się, czy odpoczywasz, NLP digitox pomaga zachować kontrolę.';

  @override
  String get onboarding_page_two_title => 'Blokuj zakłócenia.';

  @override
  String get onboarding_page_two_info =>
      'Ustaw limity użytkowania, automatycznie wstrzymuj aplikacje i kształtuj zdrowsze nawyki cyfrowe. Użyj trybu nocnego, aby odpocząć i cieszyć się nocą wolną od zakłóceń.';

  @override
  String get onboarding_page_three_title => 'Najpierw prywatność.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox jest w 100% open source i działa całkowicie offline. Nie gromadzimy ani nie udostępniamy Twoich danych osobowych — Twoja prywatność jest gwarantowana pod każdym względem.';

  @override
  String get onboarding_page_permissions_title => 'Niezbędne uprawnienia.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox wymaga posiadania niezbędnych uprawnień do śledzenia czasu spędzanego na ekranie i zarządzania nim, co pomaga ograniczyć rozpraszanie uwagi i poprawić koncentrację.';

  @override
  String get dashboard_tab_title => 'Pulpit nawigacyjny';

  @override
  String get focus_now_fab_button => 'Skup się teraz';

  @override
  String get welcome_greetings => 'Witamy ponownie,';

  @override
  String get username_snack_alert =>
      'Naciśnij długo, aby edytować nazwę użytkownika.';

  @override
  String get username_dialog_title => 'Nazwa użytkownika';

  @override
  String get username_dialog_info =>
      'Wpisz swoją nazwę użytkownika, która będzie wyświetlana na pulpicie nawigacyjnym.';

  @override
  String get username_dialog_button_apply => 'Zastosuj';

  @override
  String get glance_tile_title => 'Spójrz';

  @override
  String get glance_tile_subtitle => 'Rzuć okiem na swoje wykorzystanie.';

  @override
  String get parental_controls_tile_subtitle =>
      'Tryb niezwyciężony i ochrona przed manipulacją.';

  @override
  String get restrictions_heading => 'Ograniczenia';

  @override
  String get apps_blocking_tile_title => 'Blokowanie aplikacji';

  @override
  String get apps_blocking_tile_subtitle =>
      'Ogranicz aplikacje na wiele sposobów.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Blokowanie zgrupowanych aplikacji';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Ogranicz grupę aplikacji jednocześnie.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Ogranicz krótkie treści na wielu platformach.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Ogranicz witryny dla dorosłych i niestandardowe.';

  @override
  String get screen_time_label => 'Czas ekranowy';

  @override
  String get total_data_label => 'Łączne dane';

  @override
  String get mobile_data_label => 'Dane mobilne';

  @override
  String get wifi_data_label => 'Dane Wi-Fi';

  @override
  String get focus_today_label => 'Skup się dzisiaj';

  @override
  String get focus_weekly_label => 'Skup się co tydzień';

  @override
  String get focus_monthly_label => 'Skoncentruj się co miesiąc';

  @override
  String get focus_lifetime_label => 'Skupić się na całe życie';

  @override
  String get longest_streak_label => 'Najdłuższa passa';

  @override
  String get current_streak_label => 'Aktualna passa';

  @override
  String get successful_sessions_label => 'Udane sesje';

  @override
  String get failed_sessions_label => 'Nieudane sesje';

  @override
  String get statistics_tab_title => 'Statystyki';

  @override
  String get screen_segment_label => 'Ekran';

  @override
  String get data_segment_label => 'Dane';

  @override
  String get mobile_label => 'Mobilny';

  @override
  String get wifi_label => 'Wi-Fi';

  @override
  String get most_used_apps_heading => 'Najczęściej używane aplikacje';

  @override
  String get show_all_apps_tile_title => 'Pokaż wszystkie aplikacje';

  @override
  String get search_apps_hint => 'Wyszukaj aplikacje...';

  @override
  String get notifications_tab_title => 'Powiadomienia';

  @override
  String get notifications_tab_info =>
      'Powiadomienia zbiorcze z aplikacji i ustawiaj harmonogramy, takie jak poranek, południe, wieczór i noc. Bądź na bieżąco bez ciągłych przerw.';

  @override
  String get batched_apps_tile_title => 'Aplikacje wsadowe';

  @override
  String get batch_recap_dropdown_title => 'Typ podsumowania partii';

  @override
  String get batch_recap_dropdown_info =>
      'Wybierz, co chcesz przekazać po uruchomieniu harmonogramu — wszystkie powiadomienia czy tylko podsumowanie.';

  @override
  String get batch_recap_option_summery_only => 'Tylko podsumowanie';

  @override
  String get batch_recap_option_all_notifications => 'Wszystkie powiadomienia';

  @override
  String get notification_history_tile_title => 'Historia powiadomień';

  @override
  String get store_all_tile_title => 'Przechowuj wszystkie powiadomienia';

  @override
  String get store_all_tile_subtitle =>
      'Zapisuj także powiadomienia niewsadowe.';

  @override
  String get schedules_heading => 'Harmonogramy';

  @override
  String get new_schedule_fab_button => 'Nowy harmonogram';

  @override
  String get new_schedule_dialog_info =>
      'Wprowadź nazwę harmonogramu powiadomień, aby ułatwić jego identyfikację.';

  @override
  String get new_schedule_dialog_field_label => 'Nazwa harmonogramu';

  @override
  String get bedtime_tab_title => 'Pora snu';

  @override
  String get bedtime_tab_info =>
      'Ustaw harmonogram pójścia spać, wybierając okres i dni tygodnia. Wybierz rozpraszające aplikacje, które chcesz zablokować, i włącz tryb Nie przeszkadzać (DND), aby zapewnić sobie spokojną noc.';

  @override
  String get schedule_tile_title => 'Harmonogram';

  @override
  String get schedule_tile_subtitle => 'Włącz lub wyłącz harmonogram dzienny.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Wybierz przynajmniej jeden dzień tygodnia.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Całkowity czas trwania snu musi wynosić co najmniej 30 minut.';

  @override
  String get distracting_apps_tile_title => 'Rozpraszające aplikacje';

  @override
  String get distracting_apps_tile_subtitle =>
      'Wybierz, które aplikacje odwracają Twoją uwagę od rutyny przed snem.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Modyfikacje listy rozpraszających aplikacji są niedozwolone, gdy harmonogram pory snu jest aktywny.';

  @override
  String get parental_controls_tab_title => 'Kontrola rodzicielska';

  @override
  String get invincible_mode_heading => 'Tryb niezwyciężony';

  @override
  String get invincible_mode_tile_title => 'Aktywuj tryb niezwyciężony';

  @override
  String get invincible_mode_info =>
      'Gdy tryb Niezwyciężonego jest włączony, nie będziesz mógł dostosować wybranych limitów po osiągnięciu dziennego limitu. Możesz jednak dokonać zmian w wybranym 10-minutowym niezwyciężonym oknie.';

  @override
  String get invincible_mode_snack_alert =>
      'Ze względu na tryb niezwyciężony modyfikacje ograniczeń są niedozwolone.';

  @override
  String get invincible_mode_dialog_info =>
      'Czy jesteś całkowicie pewien, że chcesz włączyć tryb Niezwyciężony? To działanie jest nieodwracalne. Po włączeniu trybu Niezwyciężonego nie można go wyłączyć, dopóki ta aplikacja jest zainstalowana na Twoim urządzeniu.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Trybu Niezwyciężonego nie można wyłączyć, dopóki ta aplikacja jest zainstalowana na Twoim urządzeniu.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Zacznij mimo to';

  @override
  String get invincible_mode_include_timer_tile_title => 'Dołącz timer';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Uwzględnij limit uruchamiania';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Uwzględnij okres aktywny';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Ograniczenia aplikacji';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Zapobiegaj zmianom wybranych ograniczeń aplikacji po przekroczeniu dziennych limitów.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Ograniczenia grupowe';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Zapobiegaj zmianom wybranych ograniczeń grupy po przekroczeniu limitów dziennych.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Dołącz licznik czasu dla krótkich spodenek';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Zapobiega zmianom po osiągnięciu dziennego limitu krótkich pozycji.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Uwzględnij porę snu';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Zapobiega zmianom w aktywnym harmonogramie pory snu.';

  @override
  String get protected_access_tile_title => 'Chroniony dostęp';

  @override
  String get protected_access_tile_subtitle =>
      'Chroń NLP digitox za pomocą blokady urządzenia.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Aby włączyć tę funkcję, skonfiguruj najpierw blokadę biometryczną na swoim urządzeniu.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Blokada Twojego urządzenia została usunięta. Aby kontynuować, skonfiguruj nową blokadę.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Uwierzytelnienie nie powiodło się. Aby kontynuować, musisz zweryfikować blokadę urządzenia.';

  @override
  String get tamper_protection_tile_title => 'Zabezpieczenie przed manipulacją';

  @override
  String get tamper_protection_tile_subtitle =>
      'Zapobiegnij odinstalowaniu i wymuś zatrzymanie aplikacji.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Po włączeniu nie będzie można odinstalować, wymusić zatrzymania ani wyczyścić danych NLP digitox, z wyjątkiem wybranego okna dezinstalacji. Nie ma żadnego obejścia.\n\nPostępujesz na własne ryzyko.';

  @override
  String get uninstall_window_tile_title => 'Odinstaluj okno';

  @override
  String get uninstall_window_tile_subtitle =>
      'Zabezpieczenie sabotażowe można wyłączyć w ciągu 10 minut od wybranego czasu.';

  @override
  String get invincible_window_tile_title => 'Niezwyciężone okno';

  @override
  String get invincible_window_tile_subtitle =>
      'Wybrane limity można modyfikować w ciągu 10 minut od wybranego czasu.';

  @override
  String get shorts_blocking_tab_title => 'Blokowanie spodenek';

  @override
  String get shorts_blocking_tab_info =>
      'Kontroluj, ile czasu spędzasz na krótkich treściach na platformach takich jak Instagram, YouTube, Snapchat i Facebook, w tym na ich stronach internetowych.';

  @override
  String get short_content_heading => 'Krótka treść';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Na lewo od $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Ustaw dzienny limit czasu dla krótkich treści. Po osiągnięciu limitu krótka treść zostanie wstrzymana do północy.';

  @override
  String get instagram_features_tile_title => 'Instagrama';

  @override
  String get instagram_features_tile_subtitle =>
      'Ogranicz funkcje na Instagramie.';

  @override
  String get instagram_features_block_reels => 'Ogranicz sekcję bębnów.';

  @override
  String get instagram_features_block_explore => 'Ogranicz sekcję eksploracji.';

  @override
  String get snapchat_features_tile_title => 'Snapchata';

  @override
  String get snapchat_features_tile_subtitle =>
      'Ogranicz funkcje na Snapchacie.';

  @override
  String get snapchat_features_block_spotlight => 'Ogranicz sekcję reflektora.';

  @override
  String get snapchat_features_block_discover => 'Ogranicz sekcję odkrywania.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Ogranicz oglądanie filmów Short na YouTube.';

  @override
  String get facebook_features_tile_title => 'Facebooku';

  @override
  String get facebook_features_tile_subtitle => 'Ogranicz rolki na Facebooku.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Ogranicz szorty na Reddicie.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle =>
      'Ogranicz kanał wideo na platformie X.';

  @override
  String get threads_features_tile_title => 'Wątki';

  @override
  String get threads_features_tile_subtitle =>
      'Ogranicz wideo/szpule w wątkach.';

  @override
  String get websites_blocking_tab_title => 'Blokowanie stron internetowych';

  @override
  String get websites_blocking_tab_info =>
      'Blokuj witryny dla dorosłych i wszelkie niestandardowe witryny, które wybierzesz, aby zapewnić bezpieczniejsze i bardziej skoncentrowane korzystanie z Internetu. Przejmij kontrolę nad przeglądaniem i nie rozpraszaj się.';

  @override
  String get adult_content_heading => 'Treści dla dorosłych';

  @override
  String get block_nsfw_title => 'Zablokuj Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Ogranicz przeglądarkom otwieranie witryn dla dorosłych i stron pornograficznych.';

  @override
  String get block_nsfw_dialog_info =>
      'Czy jesteś pewien? To działanie jest nieodwracalne. Po włączeniu blokady witryn dla dorosłych nie można jej wyłączyć, dopóki ta aplikacja jest zainstalowana na Twoim urządzeniu.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Zablokuj mimo wszystko';

  @override
  String get blocked_websites_heading => 'Zablokowane strony internetowe';

  @override
  String get blocked_websites_empty_list_hint =>
      'Kliknij przycisk „+ Dodaj witrynę”, aby dodać rozpraszające witryny internetowe, które chcesz zablokować.';

  @override
  String get add_website_fab_button => 'Dodaj witrynę';

  @override
  String get add_website_dialog_title => 'Interesująca witryna internetowa';

  @override
  String get add_website_dialog_info =>
      'Wpisz adres strony internetowej, którą chcesz zablokować.';

  @override
  String get add_website_dialog_is_nsfw => 'Czy jest to strona nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Ostrzeżenie: raz dodanych witryn Nsfw nie można usunąć.';

  @override
  String get add_website_dialog_button_block => 'Blok';

  @override
  String get add_website_already_exist_snack_alert =>
      'Adres URL został już dodany do listy zablokowanych stron internetowych.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Nieprawidłowy adres URL! Nie można przeanalizować nazwy hosta.';

  @override
  String get remove_website_dialog_title => 'Usuń witrynę';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Czy jesteś pewien? chcesz usunąć \'$websitehost\' z zablokowanych stron internetowych.';
  }

  @override
  String get focus_tab_title => 'Skup się';

  @override
  String get focus_tab_info =>
      'Jeśli potrzebujesz czasu na skupienie, rozpocznij nową sesję, wybierając jej typ, zatrzymując rozpraszające aplikacje i włączając opcję Nie przeszkadzać, aby nie zakłócać koncentracji.';

  @override
  String get active_session_card_title => 'Aktywna sesja';

  @override
  String get active_session_card_info =>
      'Masz aktywną sesję fokusową! Kliknij „Wyświetl”, aby sprawdzić swoje postępy i czas, jaki upłynął.';

  @override
  String get active_session_card_view_button => 'Zobacz';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Usuwanie aplikacji z listy aplikacji rozpraszających nie jest dozwolone, gdy sesja fokusowa jest aktywna. W tym czasie możesz jednak nadal dodawać do listy kolejne aplikacje.';

  @override
  String get focus_profile_tile_title => 'Profil ostrości';

  @override
  String get focus_session_duration_tile_title => 'Czas trwania sesji';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Nieskończony (chyba, że przestaniesz)';

  @override
  String get focus_session_duration_dialog_info =>
      'Wybierz żądany czas trwania tej sesji fokusowej, określając, jak długo chcesz pozostać skupiony i wolny od zakłóceń.';

  @override
  String get focus_profile_customization_tile_title => 'Dostosowanie profilu';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Dostosuj ustawienia dla wybranego profilu.';

  @override
  String get focus_enforce_tile_title => 'Wymuś sesję';

  @override
  String get focus_enforce_tile_subtitle =>
      'Zapobiega zakończeniu sesji przed upływem czasu.';

  @override
  String get focus_session_start_button => 'Przesuń, aby rozpocząć sesję';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Wybierz co najmniej jedną rozpraszającą aplikację, aby rozpocząć sesję skupienia';

  @override
  String get focus_session_already_active_snack_alert =>
      'Masz już aktywną sesję fokusową. Zakończ lub przerwij bieżącą sesję przed rozpoczęciem nowej.';

  @override
  String get focus_session_type_study => 'Studiuj';

  @override
  String get focus_session_type_work => 'Praca';

  @override
  String get focus_session_type_exercise => 'Ćwicz';

  @override
  String get focus_session_type_meditation => 'Medytacja';

  @override
  String get focus_session_type_creativeWriting => 'Twórcze pisanie';

  @override
  String get focus_session_type_reading => 'Czytanie';

  @override
  String get focus_session_type_programming => 'Programowanie';

  @override
  String get focus_session_type_chores => 'Obowiązki';

  @override
  String get focus_session_type_projectPlanning => 'Planowanie projektu';

  @override
  String get focus_session_type_artAndDesign => 'Sztuka i projektowanie';

  @override
  String get focus_session_type_languageLearning => 'Nauka języka';

  @override
  String get focus_session_type_musicPractice => 'Praktyka muzyczna';

  @override
  String get focus_session_type_selfCare => 'Opieka nad sobą';

  @override
  String get focus_session_type_brainstorming => 'Burza mózgów';

  @override
  String get focus_session_type_skillDevelopment => 'Rozwój umiejętności';

  @override
  String get focus_session_type_research => 'Badania';

  @override
  String get focus_session_type_networking => 'Sieć';

  @override
  String get focus_session_type_cooking => 'Gotowanie';

  @override
  String get focus_session_type_sportsTraining => 'Trening sportowy';

  @override
  String get focus_session_type_restAndRelaxation => 'Odpoczynek i relaks';

  @override
  String get focus_session_type_other => 'Inne';

  @override
  String get timeline_tab_title => 'Oś czasu';

  @override
  String get focus_timeline_tab_info =>
      'Poznaj swoją podróż skupienia, wybierając datę z kalendarza. Śledź swoje postępy, wracaj do sukcesów i wyciągaj wnioski z wyzwań.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Twój całkowity czas produktywności w wybranym miesiącu wynosi $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktywne dni';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'W wybranym miesiącu miałeś łącznie $daysCount produktywne dni.';
  }

  @override
  String get selected_day_focused_time_label => 'Skoncentrowany czas';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Twój całkowity czas skupienia w wybranym dniu wynosi $timeString.';
  }

  @override
  String get calender_heading => 'Kalendarz';

  @override
  String get your_sessions_heading => 'Twoje sesje';

  @override
  String get your_sessions_empty_list_hint =>
      'W wybranym dniu nie zarejestrowano żadnych sesji fokusowych.';

  @override
  String get focus_session_tile_timestamp_label => 'Znacznik czasu';

  @override
  String get focus_session_tile_duration_label => 'Czas trwania';

  @override
  String get focus_session_tile_reflection_label => 'Odbicie';

  @override
  String get focus_session_state_active => 'Aktywny';

  @override
  String get focus_session_state_successful => 'Pomyślne';

  @override
  String get focus_session_state_failed => 'Nie udało się';

  @override
  String get active_session_tab_title => 'Sesja';

  @override
  String get active_session_none_warning =>
      'Nie znaleziono aktywnej sesji. Wracając do ekranu głównego.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Naciskaj dalej';

  @override
  String get active_session_finish_dialog_title => 'Zakończ';

  @override
  String get active_session_finish_dialog_info =>
      'Bądź silny! Budujesz cenne skupienie. Czy na pewno chcesz zakończyć tę sesję fokusową? Każda dodatkowa chwila liczy się do osiągnięcia Twoich celów.';

  @override
  String get active_session_giveup_dialog_title => 'Poddaj się';

  @override
  String get active_session_giveup_dialog_info =>
      'Trzymaj się! Już prawie jesteś, nie poddawaj się! Czy na pewno chcesz wcześniej zakończyć tę sesję fokusową? Postęp zostanie utracony.';

  @override
  String get active_session_reflection_dialog_title => 'Refleksja sesyjna';

  @override
  String get active_session_reflection_dialog_info =>
      'Poświęć chwilę na zastanowienie się nad swoimi postępami. Jaki masz cel na tę sesję? Co udało Ci się osiągnąć podczas tej sesji?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Wskazówka: zawsze możesz to edytować później na osi czasu sesji.';

  @override
  String get active_session_giveup_snack_alert =>
      'Poddałeś się! Nie martw się, następnym razem pójdzie ci lepiej. Liczy się każdy wysiłek – po prostu idź dalej';

  @override
  String get active_session_quote_one =>
      'Liczy się każdy krok, bądź silny i idź dalej';

  @override
  String get active_session_quote_two =>
      'Bądź skupiony! robisz niesamowite postępy';

  @override
  String get active_session_quote_three => 'Rozwalasz to! Utrzymaj dynamikę';

  @override
  String get active_session_quote_four =>
      'Jeszcze trochę i radzisz sobie fantastycznie';

  @override
  String active_session_quote_five(String durationString) {
    return 'Gratulacje 🎉 \n Ukończyłeś sesję fokusową $durationString.\n\nŚwietna robota, kontynuuj niesamowitą pracę';
  }

  @override
  String get restriction_groups_tab_title => 'Grupy restrykcyjne';

  @override
  String get restriction_groups_tab_info =>
      'Ustaw łączny limit czasu korzystania z urządzenia dla grupy aplikacji. Gdy całkowite wykorzystanie osiągnie limit, wszystkie aplikacje w grupie zostaną wstrzymane, aby pomóc zachować koncentrację i równowagę.';

  @override
  String get restriction_group_time_spent_label => 'Czas spędzony dzisiaj';

  @override
  String get restriction_group_time_left_label => 'Czas pozostał dzisiaj';

  @override
  String get restriction_group_name_tile_title => 'Nazwa grupy';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Wprowadź nazwę grupy ograniczeń, aby ułatwić jej identyfikację i zarządzanie nią.';

  @override
  String get restriction_group_timer_tile_title => 'Timer grupowy';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Ustaw dzienny limit czasu dla tej grupy. Po osiągnięciu limitu wszystkie aplikacje w tej grupie zostaną wstrzymane do północy.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Okres aktywności grupy';

  @override
  String get remove_restriction_group_dialog_title => 'Usuń grupę';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Czy jesteś pewien? chcesz usunąć „$groupName” z grup ograniczeń.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Ustaw licznik czasu lub limit aktywnego okresu.';

  @override
  String get notifications_empty_list_hint =>
      'Na dany dzień nie zgrupowano żadnych powiadomień.';

  @override
  String get conversations_label => 'Rozmowy';

  @override
  String get last_24_hours_heading => 'Ostatnie 24 godziny';

  @override
  String get notification_timeline_tab_info =>
      'Przeglądaj historię powiadomień, wybierając datę z kalendarza. Zobacz, które aplikacje przykuły Twoją uwagę i zastanów się nad swoimi cyfrowymi nawykami.';

  @override
  String get monthly_label => 'Miesięcznie';

  @override
  String get daily_label => 'Codziennie';

  @override
  String get search_notifications_sheet_info =>
      'Z łatwością znajduj wcześniejsze powiadomienia, przeszukując ich tytuł lub treść. Pomaga szybko zlokalizować ważne alerty.';

  @override
  String get search_notifications_hint => 'Wyszukaj powiadomienia...';

  @override
  String get search_notifications_empty_list_hint =>
      'Nie znaleziono powiadomień pasujących do Twojego wyszukiwania.';

  @override
  String get app_info_none_warning =>
      'Nie można znaleźć aplikacji dla danego pakietu. Wracając do ekranu głównego.';

  @override
  String get emergency_fab_button => 'Awaryjne';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Ta czynność wstrzyma blokowanie aplikacji na następne 5 minut. Zostały Ci karnety $leftPassesCount. Po wykorzystaniu wszystkich karnetów aplikacja pozostanie zablokowana do północy lub do zakończenia aktywnej sesji fokusowej.\n\nCzy nadal chcesz kontynuować?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Użyj mimo to';

  @override
  String get emergency_started_snack_alert =>
      'Blokada aplikacji zostanie wstrzymana i wznowi blokowanie za 5 minut.';

  @override
  String get emergency_already_active_snack_alert =>
      'Blokada aplikacji jest obecnie wstrzymana lub nieaktywna. Jeśli powiadomienia są włączone, będziesz otrzymywać aktualizacje dotyczące pozostałego czasu.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Wykorzystałeś wszystkie przepustki awaryjne. Zablokowane aplikacje pozostaną zablokowane do północy lub do zakończenia aktywnej sesji fokusowej.';

  @override
  String get app_limit_status_not_set => 'Nie ustawiono';

  @override
  String get app_timer_tile_title => 'Minutnik aplikacji';

  @override
  String get app_timer_picker_dialog_info =>
      'Ustaw dzienny limit czasu dla tej aplikacji. Po osiągnięciu limitu aplikacja zostanie wstrzymana do północy.';

  @override
  String get usage_reminders_tile_title => 'Przypomnienia o użyciu';

  @override
  String get usage_reminders_tile_subtitle =>
      'Delikatne szturchnięcia podczas korzystania z aplikacji działających na czas.';

  @override
  String get app_launch_limit_tile_title => 'Limit uruchomienia';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Uruchomiono dzisiaj $count razy.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Ustaw, ile razy możesz otwierać tę aplikację każdego dnia. Po osiągnięciu limitu zostanie on wstrzymany do północy.';

  @override
  String get app_active_period_tile_title => 'Okres aktywny';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Od $startTime do $endTime';
  }

  @override
  String get internet_access_tile_title => 'Dostęp do Internetu';

  @override
  String get internet_access_tile_subtitle =>
      'Wyłącz, aby zablokować dostęp aplikacji do Internetu.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Internet $appName jest zablokowany.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Internet $appName jest odblokowany.';
  }

  @override
  String get launch_app_tile_title => 'Uruchom aplikację';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Otwórz $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Przejdź do ustawień aplikacji';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Zarządzaj ustawieniami aplikacji, takimi jak powiadomienia, uprawnienia, miejsce na dane i nie tylko.';

  @override
  String get include_in_stats_tile_title => 'Uwzględnij użycie ekranu';

  @override
  String get include_in_stats_tile_subtitle =>
      'Wyłącz, aby wykluczyć tę aplikację z całkowitego wykorzystania ekranu.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName nie jest uwzględniony w całkowitym wykorzystaniu ekranu.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return 'Całkowite wykorzystanie ekranu obejmuje $appName.';
  }

  @override
  String get general_tab_title => 'Generał';

  @override
  String get appearance_heading => 'Wygląd';

  @override
  String get theme_mode_tile_title => 'Tryb tematyczny';

  @override
  String get theme_mode_system_label => 'Systemu';

  @override
  String get theme_mode_light_label => 'Światło';

  @override
  String get theme_mode_dark_label => 'Ciemny';

  @override
  String get material_color_tile_title => 'Kolor materiału';

  @override
  String get amoled_dark_tile_title => 'AMOLED ciemny';

  @override
  String get amoled_dark_tile_subtitle =>
      'Użyj czystego czarnego koloru dla ciemnego motywu.';

  @override
  String get dynamic_colors_tile_title => 'Dynamiczne kolory';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Użyj kolorów urządzenia, jeśli są obsługiwane.';

  @override
  String get defaults_heading => 'Domyślne';

  @override
  String get app_language_tile_title => 'Język aplikacji';

  @override
  String get default_home_tab_tile_title => 'Zakładka Strona główna';

  @override
  String get usage_history_tile_title => 'Historia użytkowania';

  @override
  String get usage_history_15_days => '15 dni';

  @override
  String get usage_history_1_month => '1 miesiąc';

  @override
  String get usage_history_3_month => '3 miesiące';

  @override
  String get usage_history_6_month => '6 miesięcy';

  @override
  String get usage_history_1_year => '1 rok';

  @override
  String get service_heading => 'Serwis';

  @override
  String get service_stopping_warning =>
      'Jeśli NLP digitox nieoczekiwanie przestanie działać, przyznaj pozwolenie „Ignoruj optymalizację baterii”, aby nadal działał w tle. Jeśli problem będzie się powtarzał, spróbuj dodać NLP digitox do białej listy, aby uzyskać nieprzerwaną wydajność.';

  @override
  String get whitelist_app_tile_title => 'Biała lista NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Zezwól NLP digitox na automatyczne uruchomienie.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'To urządzenie nie obsługuje automatycznego zarządzania uruchamianiem.';

  @override
  String get database_tab_title => 'Baza danych';

  @override
  String get import_db_tile_title => 'Importuj bazę danych';

  @override
  String get import_db_tile_subtitle => 'Importuj bazę danych z pliku.';

  @override
  String get export_db_tile_title => 'Eksportuj bazę danych';

  @override
  String get export_db_tile_subtitle => 'Eksportuj bazę danych do pliku.';

  @override
  String get analysis_tab_title => 'Analiza';

  @override
  String get analysis_7_days => '7 dni';

  @override
  String get analysis_30_days => '30 dni';

  @override
  String get analysis_90_days => '90 dni';

  @override
  String get analysis_screen_time_trend => 'Trend czasu przed ekranem';

  @override
  String get analysis_no_data_info =>
      'Brak zarejestrowanych danych o czasie przed ekranem dla tego okresu.';

  @override
  String get analysis_daily_average => 'Średnia dzienna';

  @override
  String get analysis_total => 'Razem';

  @override
  String get analysis_no_change => 'Tak samo jak w zeszłym tygodniu';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% mniej niż w zeszłym tygodniu';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% więcej niż w zeszłym tygodniu';
  }

  @override
  String get crash_logs_heading => 'Dzienniki awarii';

  @override
  String get crash_logs_info =>
      'Jeśli napotkasz jakiś problem, możesz zgłosić go na GitHubie wraz z plikiem dziennika. Plik będzie zawierał szczegółowe informacje, takie jak producent i model urządzenia, wersja Androida, wersja pakietu SDK i dzienniki awarii. Informacje te pomogą nam skuteczniej zidentyfikować i rozwiązać problem.';

  @override
  String get crash_logs_export_tile_title => 'Eksportuj dzienniki awarii';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Eksportuj dzienniki awarii do pliku json.';

  @override
  String get crash_logs_view_tile_title => 'Wyświetl logi';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Przeglądaj zapisane dzienniki awarii.';

  @override
  String get crash_logs_empty_list_hint =>
      'Do tej pory nie zarejestrowano żadnej awarii.';

  @override
  String get crash_logs_clear_tile_title => 'Wyczyść logi';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Usuń wszystkie dzienniki awarii z bazy danych.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Czy na pewno chcesz usunąć wszystkie dzienniki awarii z bazy danych?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'W każdym razie jasne';

  @override
  String get about_tab_title => 'O';

  @override
  String get changelog_tile_title => 'Dziennik zmian';

  @override
  String get changelog_tile_subtitle => 'Dowiedz się, co nowego.';

  @override
  String get full_changelog_tile_title => 'Pełny dziennik zmian';

  @override
  String get redirected_to_github_subtitle =>
      'Zostaniesz przekierowany do GitHuba.';

  @override
  String get contribute_heading => 'Przyczynić się';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Zobacz kod źródłowy.';

  @override
  String get report_issue_tile_title => 'Zgłoś problem';

  @override
  String get suggest_idea_tile_title => 'Zaproponuj pomysł';

  @override
  String get write_email_tile_title => 'Napisz do nas e-mailem';

  @override
  String get write_email_tile_subtitle =>
      'Zostaniesz przekierowany do aplikacji e-mail.';

  @override
  String get privacy_policy_heading => 'Polityka prywatności';

  @override
  String get privacy_policy_info =>
      'NLP digitox zobowiązuje się do ochrony Twojej prywatności. Nie gromadzimy, nie przechowujemy ani nie przekazujemy żadnego rodzaju danych użytkownika. Aplikacja działa całkowicie offline i nie wymaga połączenia z Internetem, dzięki czemu Twoje dane osobowe pozostają prywatne i bezpieczne na Twoim urządzeniu. Jako aplikacja bezpłatna i typu open source (FOSS), NLP digitox gwarantuje całkowitą przejrzystość i kontrolę użytkownika nad swoimi danymi.';

  @override
  String get more_details_button => 'Więcej szczegółów';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
