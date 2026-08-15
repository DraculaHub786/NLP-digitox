// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get mindful_tagline => 'Zaměřte se na to, na čem skutečně záleží';

  @override
  String get unlock_button_label => 'Odemknout';

  @override
  String get permission_status_off => 'Vypnuto';

  @override
  String get permission_status_allowed => 'Povoleno';

  @override
  String get permission_status_not_allowed => 'Není povoleno';

  @override
  String get permission_button_grant_permission => 'Udělení povolení';

  @override
  String get permission_button_agree_and_continue => 'Souhlasit a pokračovat';

  @override
  String get permission_button_not_now => 'Teď ne';

  @override
  String get permission_button_help => 'pomoci?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox je 100% bezpečný a funguje offline. Neshromažďujeme ani neuchováváme žádné osobní údaje.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Klikněte na tlačítko $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Na další obrazovce vyberte NLP digitox.';

  @override
  String get permission_grant_step_three =>
      '3. Klikněte a zapněte vypínač, jak je uvedeno níže.';

  @override
  String get permission_notification_title => 'Odeslat oznámení';

  @override
  String get permission_alarms_title => 'Alarmy a připomenutí';

  @override
  String get permission_alarms_info =>
      'Udělte prosím oprávnění k nastavení budíků a připomenutí. To umožní NLP digitox zahájit váš plán před spaním včas a denně o půlnoci resetovat časovače aplikací a pomůže vám zůstat na správné cestě.';

  @override
  String get permission_alarms_device_tile_label =>
      'Povolit nastavení budíků a připomenutí';

  @override
  String get permission_usage_title => 'Přístup k použití';

  @override
  String get permission_usage_info =>
      'Udělte prosím přístupové oprávnění k použití. To umožní NLP digitox monitorovat používání aplikací a spravovat přístup k určitým aplikacím, což zajistí cílenější a kontrolovanější digitální prostředí.';

  @override
  String get permission_usage_device_tile_label => 'Povolit přístup k použití';

  @override
  String get permission_overlay_title => 'Překryvná obrazovka';

  @override
  String get permission_overlay_info =>
      'Udělte prosím oprávnění k zobrazení překryvné vrstvy. To umožní NLP digitox zobrazit překryvnou vrstvu při otevření pozastavené aplikace, což vám pomůže soustředit se a udržet si svůj plán.';

  @override
  String get permission_overlay_device_tile_label =>
      'Povolit zobrazení přes jiné aplikace';

  @override
  String get permission_accessibility_title => 'Přístupnost';

  @override
  String get permission_accessibility_info =>
      'Udělte prosím oprávnění k usnadnění. To umožní NLP digitox omezit přístup ke krátkému videoobsahu (např. Reels, Shorts) v aplikacích a prohlížečích sociálních médií a filtrovat nevhodné webové stránky.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox vyžaduje oprávnění pro přístupnost k efektivnímu blokování krátkého obsahu a webových stránek.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Použijte NLP digitox';

  @override
  String get permission_dnd_title => 'Nerušit';

  @override
  String get permission_dnd_info =>
      'Udělte prosím přístup k režimu Nerušit. To umožní NLP digitox spustit a zastavit režim Nerušit během plánu večerky.';

  @override
  String get permission_dnd_tile_title => 'Začněte DND';

  @override
  String get permission_dnd_tile_subtitle => 'Aktivujte také režim Nerušit.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignorujte optimalizaci baterie';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Již bez omezení';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Zakázat omezení na pozadí';

  @override
  String get permission_battery_optimization_allow_info =>
      'Povolením „Ignorovat optimalizaci baterie“ automaticky udělíte oprávnění „Alarmy a připomenutí“ na některých zařízeních.';

  @override
  String get permission_vpn_title => 'Vytvořte VPN';

  @override
  String get permission_vpn_info =>
      'Udělte prosím oprávnění k vytvoření připojení k virtuální privátní síti (VPN). To umožní NLP digitox omezit přístup k internetu pro určené aplikace vytvořením místní VPN na zařízení.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Administrátorská oprávnění jsou potřebná pouze pro základní operace, aby aplikace fungovala správně a zůstala odolná proti neoprávněné manipulaci.';

  @override
  String get permission_admin_snack_alert =>
      'Ochranu proti manipulaci lze deaktivovat pouze během zvoleného časového okna.';

  @override
  String get permission_notification_access_title => 'Přístup k oznámení';

  @override
  String get permission_notification_access_info =>
      'Udělte prosím oprávnění k přístupu k oznámení. To umožní NLP digitox organizovat vaše oznámení a doručovat je podle vašeho plánu.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox vyžaduje přístup k oznámením pro dávková a plánovaná oznámení.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Povolit přístup k oznámením';

  @override
  String get day_today => 'dnes';

  @override
  String get day_yesterday => 'včera';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dní',
      one: '1 den',
      zero: '0 dní',
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
      other: '$countString hodin',
      one: '1 hodina',
      zero: '0 hodin',
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
      other: '$countString minut',
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
      other: '$countString sekund',
      one: '1 sekunda',
      zero: '0 sekund',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'a';

  @override
  String get timer_status_active => 'Aktivní';

  @override
  String get timer_status_paused => 'Pozastaveno';

  @override
  String get create_button => 'Vytvořit';

  @override
  String get update_button => 'Aktualizovat';

  @override
  String get dialog_button_cancel => 'Zrušit';

  @override
  String get dialog_button_remove => 'Odebrat';

  @override
  String get dialog_button_set => 'Set';

  @override
  String get dialog_button_reset => 'Resetovat';

  @override
  String get dialog_button_infinite => 'Nekonečné';

  @override
  String get schedule_start_label => 'Začněte';

  @override
  String get schedule_end_label => 'Konec';

  @override
  String get exit_without_saving_dialog_info =>
      'Opravdu chcete skončit bez uložení?';

  @override
  String get development_dialog_info =>
      'NLP digitox je v současné době ve vývoji a může obsahovat chyby nebo neúplné funkce. Pokud narazíte na nějaké problémy, nahlaste je, pomůžete nám to zlepšit.\n\nDěkujeme za vaši zpětnou vazbu!';

  @override
  String get development_dialog_button_report_issue => 'Nahlásit problém';

  @override
  String get development_dialog_button_close => 'Zavřít';

  @override
  String get dnd_settings_tile_title => 'Nastavení Nerušit';

  @override
  String get dnd_settings_tile_subtitle =>
      'Spravujte, které aplikace a oznámení vás mohou dostávat v DND.';

  @override
  String get quick_actions_heading => 'Rychlé akce';

  @override
  String get select_distracting_apps_heading => 'Vyberte rušivé aplikace';

  @override
  String get your_distracting_apps_heading => 'Vaše rušivé aplikace';

  @override
  String get select_more_apps_heading => 'Vyberte další aplikace';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Přidávání důležitých systémových aplikací do seznamu rušivých aplikací není povoleno.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Použití obrazovky a omezení nejsou pro tuto aplikaci k dispozici. V současné době je přístupné pouze využití sítě';

  @override
  String get create_group_fab_button => 'Vytvořit skupinu';

  @override
  String get active_period_info =>
      'Nastavte časové období, během kterého bude přístup povolen. Mimo tento časový rámec bude přístup omezen.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Vyberte alespoň jednu rušivou aplikaci.';

  @override
  String get donation_card_title => 'Podpořte nás';

  @override
  String get donation_card_info =>
      'NLP digitox je zdarma a s otevřeným zdrojovým kódem, vyvíjený s měsíčním nasazením. Pokud vám to pomohlo, váš dar by pro nás znamenal celý svět. Každý příspěvek nám pomáhá jej nadále zlepšovat a udržovat pro všechny.';

  @override
  String get operation_failed_snack_alert =>
      'Operace se nezdařila, něco se pokazilo!';

  @override
  String get donation_card_button_donate => 'Darovat';

  @override
  String get app_restart_dialog_title => 'Je třeba restartovat';

  @override
  String get app_restart_dialog_info =>
      'Jakmile odpočítávání skončí, NLP digitox se automaticky restartuje. Buďte prosím trpěliví, protože změny se projeví.';

  @override
  String get accessibility_tip =>
      'Chcete chytřejší blokování šetrnější k baterii? Povolte oprávnění k usnadnění pro NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox nefunguje? Chcete-li, aby fungovala hladce, povolte v Nastavení možnost Ignorovat optimalizaci baterie.';

  @override
  String get invincible_mode_tip =>
      'Náhodně odstraněná omezení? Použijte Invincible Mode k jejich uzamčení do dalšího dne nebo okna úprav.';

  @override
  String get glance_usage_tip =>
      'Chcete statistiky? Chcete-li zobrazit vzorce používání a dobu strávenou na obrazovce, podívejte se do části Pohled.';

  @override
  String get tamper_protection_tip =>
      'Odinstalování NLP digitox? Chcete-li nejprve bezpečně deaktivovat ochranu proti neoprávněné manipulaci, povolte okno Uninstall Window.';

  @override
  String get notification_blocking_tip =>
      'Chcete omezit rozptylování? Pomocí Blokování oznámení ztište vybrané aplikace.';

  @override
  String get usage_history_tip =>
      'Chcete se zamyslet nad svými zvyky? Zkontrolujte historii používání, abyste viděli minulé vzory.';

  @override
  String get focus_mode_tip =>
      'Potřebujete hluboké zaměření? Chcete-li během úkolů blokovat aplikace a oznámení, zapněte režim zaměření.';

  @override
  String get bedtime_reminder_tip =>
      'Chcete zlepšit svůj spánek? Nastavte si připomenutí před spaním, abyste večer utichli.';

  @override
  String get custom_blocking_tip =>
      'Potřebujete vlastní zkušenost? Vytvořte pravidla blokování aplikací, která vyhovují vašim potřebám.';

  @override
  String get session_timeline_tip =>
      'Chcete sledovat soustředění? Zobrazte časovou osu, abyste viděli svou soustředěnou cestu.';

  @override
  String get short_content_blocking_tip =>
      'Rozptylují vás sociální aplikace? Blokujte krátký obsah na Instagramu, YouTube atd., abyste se mohli soustředit.';

  @override
  String get parental_controls_tip =>
      'Potřebujete rodičovskou kontrolu? Nastavte omezení pro zařízení vašeho dítěte, abyste zajistili bezpečný zážitek.';

  @override
  String get notification_batching_tip =>
      'Chcete omezit rozptylování? Pomocí Dávkování oznámení můžete seskupit oznámení a zkontrolovat je najednou.';

  @override
  String get notification_scheduling_tip =>
      'Potřebujete spravovat oznámení? Naplánujte si, kdy obdržíte oznámení pro konkrétní aplikace.';

  @override
  String get quick_focus_tile_tip =>
      'Potřebujete rychlý přístup k zaostření? Přidejte dlaždici rychlého zaostření a okamžitě aktivujte režim zaostření.';

  @override
  String get app_shortcuts_tip =>
      'Chcete okamžitý přístup k aplikaci? Přidejte zkratky dlouhým stisknutím ikony aplikace pro rychlé akce.';

  @override
  String get backup_usage_db_tip =>
      'Chcete uložit svá data? Zálohujte si databázi využití, aby byly vaše záznamy v bezpečí.';

  @override
  String get dynamic_material_color_tip =>
      'Chcete vlastní motiv? Povolte barvu Dynamic Material You, aby odpovídala motivu vašeho zařízení.';

  @override
  String get amoled_dark_theme_tip =>
      'Chcete šetřit baterii? Použijte tmavý motiv AMOLED ke snížení spotřeby energie na obrazovkách OLED.';

  @override
  String get customize_usage_history_tip =>
      'Chcete uchovávat historii používání? Přizpůsobte si, kolik týdnů se mají data ukládat do Historie využití.';

  @override
  String get grouped_apps_blocking_tip =>
      'Chcete blokovat aplikace společně? Pomocí skupin omezení můžete seskupit limity aplikací a blokovat více aplikací najednou.';

  @override
  String get websites_blocking_tip =>
      'Chcete čistší zážitek z prohlížení? Zablokujte vlastní webové stránky nebo webové stránky NSFW pro soustředěnější online čas.';

  @override
  String get data_usage_tip =>
      'Chcete sledovat svá data? Sledujte využití mobilních a Wi-Fi dat pro spotřebu internetu.';

  @override
  String get block_internet_tip =>
      'Potřebujete aplikaci zablokovat internet? Odřízněte internet pro konkrétní aplikaci z řídicího panelu aplikace.';

  @override
  String get emergency_passes_tip =>
      'Potřebujete přestávku? Použijte 3 nouzové průchody denně k dočasnému odblokování aplikací na 5 minut.';

  @override
  String get onboarding_skip_btn_label => 'Přeskočit';

  @override
  String get onboarding_finish_setup_btn_label => 'Dokončete nastavení';

  @override
  String get onboarding_page_welcome_title => 'Vítejte v NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Převezměte kontrolu nad svým digitálním životem a budujte zdravější návyky při používání obrazovky. NLP digitox vám pomáhá zůstat soustředění, omezit rušivé vlivy a každý den se rozhodovat vědomě.';

  @override
  String get onboarding_page_statistics_title => 'Poznejte své návyky.';

  @override
  String get onboarding_page_statistics_info =>
      'Porozumějte svým digitálním vzorcům díky podrobným přehledům o čase stráveném na obrazovce, používání aplikací a trendech soustředění. Sledujte svůj pokrok a uvidíte, jak malé změny vedou k velkým zlepšením.';

  @override
  String get onboarding_page_one_title => 'Master Focus.';

  @override
  String get onboarding_page_one_info =>
      'Pozastavte rušivé aplikace, zablokujte krátký obsah a zůstaňte v obraze díky přizpůsobitelným relacím soustředění. Ať už pracujete, studujete nebo odpočíváte, NLP digitox vám pomůže zůstat pod kontrolou.';

  @override
  String get onboarding_page_two_title => 'Blokovat rozptýlení.';

  @override
  String get onboarding_page_two_info =>
      'Nastavte limity využití, automaticky pozastavte aplikace a vytvořte si zdravější digitální návyky. Pomocí režimu před spaním si odpočiňte a užijte si noc bez rozptylování.';

  @override
  String get onboarding_page_three_title => 'Soukromí na prvním místě.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox je 100% open source a funguje zcela offline. Neshromažďujeme ani nesdílíme vaše osobní údaje – vaše soukromí je ve všech směrech zaručeno.';

  @override
  String get onboarding_page_permissions_title => 'Základní oprávnění.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox vyžaduje dodržování základních oprávnění ke sledování a správě času stráveného na obrazovce, což pomáhá omezit rušivé vlivy a zlepšit soustředění.';

  @override
  String get dashboard_tab_title => 'Dashboard';

  @override
  String get focus_now_fab_button => 'Soustřeďte se nyní';

  @override
  String get welcome_greetings => 'vítej zpět,';

  @override
  String get username_snack_alert =>
      'Dlouhým stisknutím upravíte uživatelské jméno.';

  @override
  String get username_dialog_title => 'Uživatelské jméno';

  @override
  String get username_dialog_info =>
      'Zadejte své uživatelské jméno, které se zobrazí na hlavním panelu.';

  @override
  String get username_dialog_button_apply => 'Použít';

  @override
  String get glance_tile_title => 'Pohled';

  @override
  String get glance_tile_subtitle => 'Podívejte se rychle na své použití.';

  @override
  String get parental_controls_tile_subtitle =>
      'Neporazitelný režim a ochrana proti neoprávněné manipulaci.';

  @override
  String get restrictions_heading => 'Omezení';

  @override
  String get apps_blocking_tile_title => 'Blokování aplikací';

  @override
  String get apps_blocking_tile_subtitle => 'Omezte aplikace několika způsoby.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Blokování seskupených aplikací';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Omezte skupinu aplikací současně.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Omezte krátký obsah na více platformách.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Omezte webové stránky pro dospělé a vlastní webové stránky.';

  @override
  String get screen_time_label => 'Čas na obrazovce';

  @override
  String get total_data_label => 'Celková data';

  @override
  String get mobile_data_label => 'Mobilní data';

  @override
  String get wifi_data_label => 'Wifi data';

  @override
  String get focus_today_label => 'Soustřeďte se dnes';

  @override
  String get focus_weekly_label => 'Zaměřte se každý týden';

  @override
  String get focus_monthly_label => 'Zaměřte se měsíčně';

  @override
  String get focus_lifetime_label => 'Životnost zaměření';

  @override
  String get longest_streak_label => 'Nejdelší série';

  @override
  String get current_streak_label => 'Aktuální série';

  @override
  String get successful_sessions_label => 'Úspěšné sezení';

  @override
  String get failed_sessions_label => 'Neúspěšné relace';

  @override
  String get statistics_tab_title => 'Statistiky';

  @override
  String get screen_segment_label => 'Obrazovka';

  @override
  String get data_segment_label => 'Data';

  @override
  String get mobile_label => 'Mobilní';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Nejpoužívanější aplikace';

  @override
  String get show_all_apps_tile_title => 'Zobrazit všechny aplikace';

  @override
  String get search_apps_hint => 'Hledat aplikace...';

  @override
  String get notifications_tab_title => 'Oznámení';

  @override
  String get notifications_tab_info =>
      'Hromadné oznámení z aplikací a nastavení plánů, jako je ráno, poledne, večer a noc. Zůstaňte v obraze bez neustálých přerušení.';

  @override
  String get batched_apps_tile_title => 'Dávkové aplikace';

  @override
  String get batch_recap_dropdown_title => 'Typ rekapitulace dávky';

  @override
  String get batch_recap_dropdown_info =>
      'Vyberte, co se má odeslat, když se spustí plán – všechna oznámení nebo jen souhrn.';

  @override
  String get batch_recap_option_summery_only => 'Pouze shrnutí';

  @override
  String get batch_recap_option_all_notifications => 'Všechna oznámení';

  @override
  String get notification_history_tile_title => 'Historie oznámení';

  @override
  String get store_all_tile_title => 'Ukládat všechna oznámení';

  @override
  String get store_all_tile_subtitle => 'Ukládejte i nedávková oznámení.';

  @override
  String get schedules_heading => 'Jízdní řády';

  @override
  String get new_schedule_fab_button => 'Nový rozvrh';

  @override
  String get new_schedule_dialog_info =>
      'Zadejte název plánu oznámení, abyste jej mohli snadno identifikovat.';

  @override
  String get new_schedule_dialog_field_label => 'Název rozvrhu';

  @override
  String get bedtime_tab_title => 'Před spaním';

  @override
  String get bedtime_tab_info =>
      'Nastavte si plán večerky výběrem časového období a dnů v týdnu. Vyberte si rušivé aplikace, které chcete blokovat, a aktivujte režim Nerušit (DND) pro klidnou noc.';

  @override
  String get schedule_tile_title => 'Rozvrh';

  @override
  String get schedule_tile_subtitle => 'Povolit nebo zakázat denní plán.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Vyberte alespoň jeden den v týdnu.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Celková doba před spaním musí být alespoň 30 minut.';

  @override
  String get distracting_apps_tile_title => 'Rušivé aplikace';

  @override
  String get distracting_apps_tile_subtitle =>
      'Vyberte, které aplikace vás vyrušují z vaší rutiny před spaním.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Během aktivního rozvrhu večerky nejsou povoleny úpravy seznamu rušivých aplikací.';

  @override
  String get parental_controls_tab_title => 'Rodičovská kontrola';

  @override
  String get invincible_mode_heading => 'Neporazitelný režim';

  @override
  String get invincible_mode_tile_title => 'Aktivujte nepřemožitelný režim';

  @override
  String get invincible_mode_info =>
      'Když je nepřemožitelný režim zapnutý, po dosažení denní kvóty nebudete moci upravit vybrané limity. Změny však můžete provést během vybraného 10minutového neporazitelného okna.';

  @override
  String get invincible_mode_snack_alert =>
      'Vzhledem k nepřemožitelnému režimu nejsou povoleny úpravy omezení.';

  @override
  String get invincible_mode_dialog_info =>
      'Jste si naprosto jisti, že chcete povolit Invincible Mode? Tato akce je nevratná. Jakmile je Invincible Mode zapnutý, nemůžete jej vypnout, dokud je tato aplikace nainstalována ve vašem zařízení.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Mode nelze vypnout, pokud tato aplikace zůstane nainstalovaná ve vašem zařízení.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Přesto začněte';

  @override
  String get invincible_mode_include_timer_tile_title => 'Zahrnout časovač';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Zahrnout limit spuštění';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Zahrnout aktivní období';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'Omezení aplikací';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Po překročení denních limitů zabraňte změnám ve vybraných omezeních aplikace.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Skupinová omezení';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Po překročení denních limitů zabraňte změnám ve vybraných omezeních skupiny.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Zahrnout časovač šortek';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Zabraňuje změnám po dosažení denního limitu šortek.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Zahrňte před spaním';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Zabraňuje změnám během aktivního plánu večerky.';

  @override
  String get protected_access_tile_title => 'Chráněný přístup';

  @override
  String get protected_access_tile_subtitle =>
      'Chraňte NLP digitox pomocí zámku zařízení.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Chcete-li tuto funkci aktivovat, nejprve na svém zařízení nastavte biometrický zámek.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Zámek vašeho zařízení byl odstraněn. Chcete-li pokračovat, nastavte nový zámek.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Ověření se nezdařilo. Chcete-li pokračovat, musíte ověřit zámek zařízení.';

  @override
  String get tamper_protection_tile_title =>
      'Ochrana proti neoprávněné manipulaci';

  @override
  String get tamper_protection_tile_subtitle =>
      'Zabránit odinstalaci a vynutit zastavení aplikace.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Po aktivaci nebudete moci odinstalovat, vynutit zastavení nebo vymazat data NLP digitox, s výjimkou vybraného okna odinstalace. Neexistují žádná řešení.\n\nPokračujte na vlastní riziko.';

  @override
  String get uninstall_window_tile_title => 'Odinstalovat okno';

  @override
  String get uninstall_window_tile_subtitle =>
      'Ochranu proti neoprávněné manipulaci lze deaktivovat do 10 minut od zvoleného času.';

  @override
  String get invincible_window_tile_title => 'Nepřemožitelné okno';

  @override
  String get invincible_window_tile_subtitle =>
      'Vybrané limity lze upravit do 10 minut od zvoleného času.';

  @override
  String get shorts_blocking_tab_title => 'Blokování šortek';

  @override
  String get shorts_blocking_tab_info =>
      'Mějte pod kontrolou, kolik času strávíte krátkým obsahem na platformách jako Instagram, YouTube, Snapchat a Facebook, včetně jejich webových stránek.';

  @override
  String get short_content_heading => 'Krátký obsah';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Vlevo od $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Nastavte denní časový limit pro krátký obsah. Po dosažení limitu bude krátký obsah pozastaven do půlnoci.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle => 'Omezte funkce na instagramu.';

  @override
  String get instagram_features_block_reels => 'Omezit sekci válců.';

  @override
  String get instagram_features_block_explore => 'Omezit sekci prozkoumat.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle => 'Omezte funkce na snapchatu.';

  @override
  String get snapchat_features_block_spotlight => 'Omezit sekci reflektorů.';

  @override
  String get snapchat_features_block_discover => 'Omezit sekci objevování.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle => 'Omezit šortky na youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Omezte kotouče na Facebooku.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Omezte šortky na redditu.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Omezit přenos videa na X.';

  @override
  String get threads_features_tile_title => 'Vlákna';

  @override
  String get threads_features_tile_subtitle =>
      'Omezit video/válce ve vláknech.';

  @override
  String get websites_blocking_tab_title => 'Blokování webových stránek';

  @override
  String get websites_blocking_tab_info =>
      'Blokujte webové stránky pro dospělé a jakékoli vlastní webové stránky, které si vyberete, abyste vytvořili bezpečnější a cílenější online zážitek. Převezměte kontrolu nad svým procházením a zůstaňte bez rušení.';

  @override
  String get adult_content_heading => 'Obsah pro dospělé';

  @override
  String get block_nsfw_title => 'Blokovat Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Omezte prohlížeče v otevírání webových stránek pro dospělé a pornografie.';

  @override
  String get block_nsfw_dialog_info =>
      'jsi si jistý? Tato akce je nevratná. Jakmile je blokování webů pro dospělé ZAPNUTO, nelze jej vypnout, pokud je tato aplikace nainstalována ve vašem zařízení.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Každopádně blokovat';

  @override
  String get blocked_websites_heading => 'Blokované webové stránky';

  @override
  String get blocked_websites_empty_list_hint =>
      'Kliknutím na tlačítko „+ Přidat web“ přidáte rušivé weby, které chcete zablokovat.';

  @override
  String get add_website_fab_button => 'Přidat web';

  @override
  String get add_website_dialog_title => 'Rušivý web';

  @override
  String get add_website_dialog_info =>
      'Zadejte adresu URL webu, který chcete zablokovat.';

  @override
  String get add_website_dialog_is_nsfw => 'Je stránka nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Upozornění: Stránky Nsfw nelze po přidání odstranit.';

  @override
  String get add_website_dialog_button_block => 'Blokovat';

  @override
  String get add_website_already_exist_snack_alert =>
      'Adresa URL již byla přidána do seznamu blokovaných webových stránek.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Neplatná adresa URL! Nelze analyzovat název hostitele.';

  @override
  String get remove_website_dialog_title => 'Odebrat web';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'jsi si jistý? chcete odstranit \'$websitehost\' z blokovaných webových stránek.';
  }

  @override
  String get focus_tab_title => 'Zaměřte se';

  @override
  String get focus_tab_info =>
      'Když potřebujete čas na soustředění, začněte novou relaci výběrem typu, výběrem rušivých aplikací, které chcete pozastavit, a zapnutím funkce Nerušit pro nepřerušované soustředění.';

  @override
  String get active_session_card_title => 'Aktivní relace';

  @override
  String get active_session_card_info =>
      'Probíhá aktivní soustředění! Kliknutím na „Zobrazit“ můžete zkontrolovat svůj postup a zjistit, kolik času uplynulo.';

  @override
  String get active_session_card_view_button => 'Zobrazit';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Odebrání aplikací ze seznamu rušivých aplikací není povoleno, pokud je aktivní relace Focus Session. Během této doby však stále můžete do seznamu přidávat další aplikace.';

  @override
  String get focus_profile_tile_title => 'Zaměření profilu';

  @override
  String get focus_session_duration_tile_title => 'Doba trvání relace';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Nekonečný (pokud se nezastavíš)';

  @override
  String get focus_session_duration_dialog_info =>
      'Vyberte prosím požadovanou dobu trvání tohoto soustředění a určete, jak dlouho chcete zůstat soustředění a bez rozptylování.';

  @override
  String get focus_profile_customization_tile_title => 'Přizpůsobení profilu';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Přizpůsobte nastavení pro vybraný profil.';

  @override
  String get focus_enforce_tile_title => 'Vynutit relaci';

  @override
  String get focus_enforce_tile_subtitle =>
      'Zabraňuje ukončení relace před uplynutím času.';

  @override
  String get focus_session_start_button => 'Přejetím zahájíte relaci';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Chcete-li zahájit relaci soustředění, vyberte alespoň jednu rušivou aplikaci';

  @override
  String get focus_session_already_active_snack_alert =>
      'Již máte spuštěnou relaci aktivního soustředění. Před zahájením nové prosím dokončete nebo zastavte aktuální relaci.';

  @override
  String get focus_session_type_study => 'Studium';

  @override
  String get focus_session_type_work => 'Práce';

  @override
  String get focus_session_type_exercise => 'Cvičení';

  @override
  String get focus_session_type_meditation => 'Meditace';

  @override
  String get focus_session_type_creativeWriting => 'Kreativní psaní';

  @override
  String get focus_session_type_reading => 'Čtení';

  @override
  String get focus_session_type_programming => 'Programování';

  @override
  String get focus_session_type_chores => 'Domácí práce';

  @override
  String get focus_session_type_projectPlanning => 'Plánování projektu';

  @override
  String get focus_session_type_artAndDesign => 'Umění a design';

  @override
  String get focus_session_type_languageLearning => 'Výuka jazyků';

  @override
  String get focus_session_type_musicPractice => 'Hudební praxe';

  @override
  String get focus_session_type_selfCare => 'Péče o sebe';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Rozvoj dovedností';

  @override
  String get focus_session_type_research => 'Výzkum';

  @override
  String get focus_session_type_networking => 'vytváření sítí';

  @override
  String get focus_session_type_cooking => 'Vaření';

  @override
  String get focus_session_type_sportsTraining => 'Sportovní trénink';

  @override
  String get focus_session_type_restAndRelaxation => 'Odpočinek a relaxace';

  @override
  String get focus_session_type_other => 'Jiné';

  @override
  String get timeline_tab_title => 'Časová osa';

  @override
  String get focus_timeline_tab_info =>
      'Prozkoumejte svou soustředěnou cestu výběrem data z kalendáře. Sledujte svůj pokrok, vraťte se ke svým úspěchům a poučte se z výzev.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Váš celkový produktivní čas za vybraný měsíc je $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktivní dny';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Ve vybraném měsíci jste měli celkem $daysCount produktivních dní.';
  }

  @override
  String get selected_day_focused_time_label => 'Soustředěný čas';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Váš celkový čas soustředění pro vybraný den je $timeString.';
  }

  @override
  String get calender_heading => 'Kalendář';

  @override
  String get your_sessions_heading => 'Vaše relace';

  @override
  String get your_sessions_empty_list_hint =>
      'Pro vybraný den nebyly zaznamenány žádné soustředění.';

  @override
  String get focus_session_tile_timestamp_label => 'Časové razítko';

  @override
  String get focus_session_tile_duration_label => 'Doba trvání';

  @override
  String get focus_session_tile_reflection_label => 'Reflexe';

  @override
  String get focus_session_state_active => 'Aktivní';

  @override
  String get focus_session_state_successful => 'Úspěšné';

  @override
  String get focus_session_state_failed => 'Nepodařilo se';

  @override
  String get active_session_tab_title => 'Relace';

  @override
  String get active_session_none_warning =>
      'Nebyla nalezena žádná aktivní relace. Návrat na domovskou obrazovku.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Tlačte dál';

  @override
  String get active_session_finish_dialog_title => 'Dokončit';

  @override
  String get active_session_finish_dialog_info =>
      'Zůstaňte silní! Budujete cenné soustředění. Opravdu chcete ukončit toto soustředění? Každý okamžik navíc se počítá do vašich cílů.';

  @override
  String get active_session_giveup_dialog_title => 'vzdát se';

  @override
  String get active_session_giveup_dialog_info =>
      'vydrž! Už jsi skoro tam, nevzdávej to! Opravdu chcete ukončit toto soustředění dříve? Pokrok bude ztracen.';

  @override
  String get active_session_reflection_dialog_title => 'Relace reflexe';

  @override
  String get active_session_reflection_dialog_info =>
      'Udělejte si chvilku na zamyšlení nad svým pokrokem. Jaký je váš cíl pro tuto relaci? Co jste během tohoto sezení dokázali?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tip: Toto můžete kdykoli upravit později na časové ose relace.';

  @override
  String get active_session_giveup_snack_alert =>
      'Vzdal jsi to! Nebojte se, příště to zvládnete lépe. Každá snaha se počítá – jen tak dál';

  @override
  String get active_session_quote_one =>
      'Každý krok se počítá, zůstaňte silní a pokračujte';

  @override
  String get active_session_quote_two => 'Soustřeďte se! děláš úžasné pokroky';

  @override
  String get active_session_quote_three => 'Ty to drtíš! Udržujte tempo';

  @override
  String get active_session_quote_four =>
      'Ještě kousek, jde vám to fantasticky';

  @override
  String active_session_quote_five(String durationString) {
    return 'Gratulujeme 🎉 \n Dokončili jste soustředění $durationString.\n\nSkvělá práce, pokračujte v úžasné práci';
  }

  @override
  String get restriction_groups_tab_title => 'Omezovací skupiny';

  @override
  String get restriction_groups_tab_info =>
      'Nastavte kombinovaný limit času na zařízení pro skupinu aplikací. Jakmile celkové využití dosáhne vašeho limitu, všechny aplikace ve skupině budou pozastaveny, aby bylo možné udržet pozornost a rovnováhu.';

  @override
  String get restriction_group_time_spent_label => 'Dnes strávený čas';

  @override
  String get restriction_group_time_left_label => 'Dnes zbývá čas';

  @override
  String get restriction_group_name_tile_title => 'Název skupiny';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Zadejte název skupiny omezení, abyste ji mohli snadno identifikovat a spravovat.';

  @override
  String get restriction_group_timer_tile_title => 'Skupinový časovač';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Nastavte pro tuto skupinu denní časový limit. Po dosažení limitu budou všechny aplikace v této skupině pozastaveny až do půlnoci.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Aktivní období skupiny';

  @override
  String get remove_restriction_group_dialog_title => 'Odebrat skupinu';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'jsi si jistý? chcete odstranit \'$groupName\' ze skupin omezení.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Nastavte buď časovač nebo limit aktivního období.';

  @override
  String get notifications_empty_list_hint =>
      'Pro daný den nebyla přidána žádná oznámení.';

  @override
  String get conversations_label => 'Konverzace';

  @override
  String get last_24_hours_heading => 'Posledních 24 hodin';

  @override
  String get notification_timeline_tab_info =>
      'Procházejte svou historii oznámení výběrem data z kalendáře. Podívejte se, které aplikace zaujaly vaši pozornost, a zamyslete se nad svými digitálními návyky.';

  @override
  String get monthly_label => 'Měsíční';

  @override
  String get daily_label => 'denně';

  @override
  String get search_notifications_sheet_info =>
      'Snadno najděte minulá oznámení prohledáním jejich názvu nebo obsahu. Pomůže vám rychle najít důležitá upozornění.';

  @override
  String get search_notifications_hint => 'Hledat oznámení...';

  @override
  String get search_notifications_empty_list_hint =>
      'Nebyla nalezena žádná oznámení odpovídající vašemu hledání.';

  @override
  String get app_info_none_warning =>
      'Aplikaci pro daný balíček se nepodařilo najít. Návrat na domovskou obrazovku.';

  @override
  String get emergency_fab_button => 'Pohotovost';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Tato akce pozastaví blokování aplikací na dalších 5 minut. Zbývají vám průkazy $leftPassesCount. Po použití všech průchodů zůstane aplikace zablokována až do půlnoci nebo skončí relace aktivního soustředění.\n\nPřejete si přesto pokračovat?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Přesto použít';

  @override
  String get emergency_started_snack_alert =>
      'Blokování aplikací je pozastaveno a bude pokračovat v blokování za 5 minut.';

  @override
  String get emergency_already_active_snack_alert =>
      'Blokování aplikací je momentálně pozastaveno nebo neaktivní. Pokud jsou upozornění povolena, budete dostávat aktualizace týkající se zbývajícího času.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Využili jste všechny své nouzové průkazy. Zablokované aplikace zůstanou blokovány až do půlnoci, nebo skončí aktivní relace.';

  @override
  String get app_limit_status_not_set => 'Nenastaveno';

  @override
  String get app_timer_tile_title => 'Časovač aplikace';

  @override
  String get app_timer_picker_dialog_info =>
      'Nastavte pro tuto aplikaci denní časový limit. Po dosažení limitu bude aplikace pozastavena do půlnoci.';

  @override
  String get usage_reminders_tile_title => 'Připomenutí použití';

  @override
  String get usage_reminders_tile_subtitle =>
      'Jemné šťouchnutí při používání časovaných aplikací.';

  @override
  String get app_launch_limit_tile_title => 'Limit spuštění';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Dnes spuštěno $count krát.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Nastavte, kolikrát denně můžete tuto aplikaci otevřít. Po dosažení limitu se pozastaví do půlnoci.';

  @override
  String get app_active_period_tile_title => 'Aktivní období';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Od $startTime do $endTime';
  }

  @override
  String get internet_access_tile_title => 'Přístup k internetu';

  @override
  String get internet_access_tile_subtitle =>
      'Chcete-li aplikaci zablokovat internet, vypněte ji.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Internet $appName je blokován.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Internet $appName je odblokován.';
  }

  @override
  String get launch_app_tile_title => 'Spusťte aplikaci';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Otevřete $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Přejděte do nastavení aplikace';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Spravujte nastavení aplikací, jako jsou oznámení, oprávnění, úložiště a další.';

  @override
  String get include_in_stats_tile_title => 'Zahrnout do použití obrazovky';

  @override
  String get include_in_stats_tile_subtitle =>
      'Vypněte, chcete-li tuto aplikaci vyloučit z celkového využití obrazovky.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName je vyloučeno z celkového využití obrazovky.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName je součástí celkového využití obrazovky.';
  }

  @override
  String get general_tab_title => 'Generál';

  @override
  String get appearance_heading => 'Vzhled';

  @override
  String get theme_mode_tile_title => 'Tématický režim';

  @override
  String get theme_mode_system_label => 'Systém';

  @override
  String get theme_mode_light_label => 'Světlo';

  @override
  String get theme_mode_dark_label => 'Tmavý';

  @override
  String get material_color_tile_title => 'Barva materiálu';

  @override
  String get amoled_dark_tile_title => 'AMOLED tmavý';

  @override
  String get amoled_dark_tile_subtitle =>
      'Pro tmavé téma použijte čistě černou barvu.';

  @override
  String get dynamic_colors_tile_title => 'Dynamické barvy';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Použijte barvy zařízení, pokud jsou podporovány.';

  @override
  String get defaults_heading => 'Výchozí';

  @override
  String get app_language_tile_title => 'Jazyk aplikace';

  @override
  String get default_home_tab_tile_title => 'Karta Domů';

  @override
  String get usage_history_tile_title => 'Historie použití';

  @override
  String get usage_history_15_days => '15 dní';

  @override
  String get usage_history_1_month => '1 měsíc';

  @override
  String get usage_history_3_month => '3 měsíce';

  @override
  String get usage_history_6_month => '6 měsíců';

  @override
  String get usage_history_1_year => '1 rok';

  @override
  String get service_heading => 'Servis';

  @override
  String get service_stopping_warning =>
      'Pokud NLP digitox neočekávaně přestane fungovat, udělte prosím oprávnění \'Ignorovat optimalizaci baterie\', aby zůstala spuštěna na pozadí. Pokud problém přetrvává, zkuste NLP digitox přidat na seznam povolených, abyste zajistili nepřerušovaný výkon.';

  @override
  String get whitelist_app_tile_title => 'Whitelist NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Povolte automatické spuštění NLP digitox.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Toto zařízení nepodporuje automatickou správu spouštění.';

  @override
  String get database_tab_title => 'databáze';

  @override
  String get import_db_tile_title => 'Importovat databázi';

  @override
  String get import_db_tile_subtitle => 'Import databáze ze souboru.';

  @override
  String get export_db_tile_title => 'Export databáze';

  @override
  String get export_db_tile_subtitle => 'Export databáze do souboru.';

  @override
  String get analysis_tab_title => 'Analýza';

  @override
  String get analysis_7_days => '7 dní';

  @override
  String get analysis_30_days => '30 dní';

  @override
  String get analysis_90_days => '90 dní';

  @override
  String get analysis_screen_time_trend => 'Trend času na obrazovce';

  @override
  String get analysis_no_data_info =>
      'Pro toto období zatím nejsou zaznamenána žádná data o čase na obrazovce.';

  @override
  String get analysis_daily_average => 'Denní průměr';

  @override
  String get analysis_total => 'Celkem';

  @override
  String get analysis_no_change => 'Stejně jako minulý týden';

  @override
  String analysis_trend_less(String percent) {
    return 'o $percent% méně než minulý týden';
  }

  @override
  String analysis_trend_more(String percent) {
    return 'o $percent% více než minulý týden';
  }

  @override
  String get crash_logs_heading => 'Protokoly o haváriích';

  @override
  String get crash_logs_info =>
      'Pokud narazíte na nějaký problém, můžete jej nahlásit na GitHubu spolu se souborem protokolu. Soubor bude obsahovat podrobnosti, jako je výrobce vašeho zařízení, model, verze Androidu, verze SDK a protokoly selhání. Tyto informace nám pomohou efektivněji identifikovat a vyřešit problém.';

  @override
  String get crash_logs_export_tile_title => 'Exportujte protokoly o selhání';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Exportujte protokoly o selhání do souboru json.';

  @override
  String get crash_logs_view_tile_title => 'Zobrazit protokoly';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Prozkoumejte uložené protokoly o selhání.';

  @override
  String get crash_logs_empty_list_hint => 'Dosud nebyl zaznamenán žádný pád.';

  @override
  String get crash_logs_clear_tile_title => 'Vymazat protokoly';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Odstraňte všechny protokoly o selhání z databáze.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Opravdu chcete vymazat všechny protokoly o selhání z databáze?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Každopádně jasné';

  @override
  String get about_tab_title => 'O';

  @override
  String get changelog_tile_title => 'Seznam změn';

  @override
  String get changelog_tile_subtitle => 'Zjistěte, co je nového.';

  @override
  String get full_changelog_tile_title => 'Kompletní changelog';

  @override
  String get redirected_to_github_subtitle => 'Budete přesměrováni na GitHub.';

  @override
  String get contribute_heading => 'Přispějte';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Prohlédněte si zdrojový kód.';

  @override
  String get report_issue_tile_title => 'Nahlásit problém';

  @override
  String get suggest_idea_tile_title => 'Navrhněte nápad';

  @override
  String get write_email_tile_title => 'Napište nám na email';

  @override
  String get write_email_tile_subtitle =>
      'Budete přesměrováni do aplikace E-mail.';

  @override
  String get privacy_policy_heading => 'Zásady ochrany osobních údajů';

  @override
  String get privacy_policy_info =>
      'NLP digitox se zavazuje chránit vaše soukromí. Neshromažďujeme, neukládáme ani nepřenášíme žádný typ uživatelských dat. Aplikace funguje zcela offline a nevyžaduje připojení k internetu, což zajišťuje, že vaše osobní údaje zůstanou na vašem zařízení soukromé a zabezpečené. Jako aplikace svobodného a otevřeného softwaru (FOSS) zaručuje NLP digitox úplnou transparentnost a uživatelskou kontrolu nad svými daty.';

  @override
  String get more_details_button => 'Další podrobnosti';
}
