// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get mindful_tagline => 'Focus op wat er echt toe doet';

  @override
  String get unlock_button_label => 'Ontgrendelen';

  @override
  String get permission_status_off => 'Uit';

  @override
  String get permission_status_allowed => 'Toegestaan';

  @override
  String get permission_status_not_allowed => 'Niet toegestaan';

  @override
  String get permission_button_grant_permission => 'Toestemming verlenen';

  @override
  String get permission_button_agree_and_continue => 'Akkoord en doorgaan';

  @override
  String get permission_button_not_now => 'Niet nu';

  @override
  String get permission_button_help => 'Hulp?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox is 100% veilig en werkt offline. Wij verzamelen of bewaren geen persoonlijke gegevens.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Klik op de knop $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Selecteer NLP digitox in het volgende scherm.';

  @override
  String get permission_grant_step_three =>
      '3. Klik en zet de schakelaar aan, zoals hieronder.';

  @override
  String get permission_notification_title => 'Meldingen verzenden';

  @override
  String get permission_alarms_title => 'Alarmen en herinneringen';

  @override
  String get permission_alarms_info =>
      'Geef toestemming voor het instellen van alarmen en herinneringen. Hierdoor kan NLP digitox uw bedtijdschema op tijd starten en de app-timers dagelijks om middernacht opnieuw instellen, zodat u op het goede spoor kunt blijven.';

  @override
  String get permission_alarms_device_tile_label =>
      'Sta het instellen van alarmen en herinneringen toe';

  @override
  String get permission_usage_title => 'Gebruikstoegang';

  @override
  String get permission_usage_info =>
      'Verleen toestemming voor gebruikstoegang. Hierdoor kan NLP digitox het app-gebruik monitoren en de toegang tot bepaalde apps beheren, waardoor een meer gerichte en gecontroleerde digitale omgeving wordt gegarandeerd.';

  @override
  String get permission_usage_device_tile_label => 'Gebruikstoegang toestaan';

  @override
  String get permission_overlay_title => 'Weergave-overlay';

  @override
  String get permission_overlay_info =>
      'Geef toestemming voor weergave-overlay. Hierdoor kan NLP digitox een overlay weergeven wanneer een gepauzeerde app wordt geopend, zodat u gefocust kunt blijven en uw planning kunt behouden.';

  @override
  String get permission_overlay_device_tile_label =>
      'Sta weergave boven andere apps toe';

  @override
  String get permission_accessibility_title => 'Toegankelijkheid';

  @override
  String get permission_accessibility_info =>
      'Geef toegankelijkheidstoestemming. Hierdoor kan NLP digitox de toegang tot korte video-inhoud (bijvoorbeeld Reels, Shorts) binnen sociale media-apps en browsers beperken en ongepaste websites filteren.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox vereist toegankelijkheidstoestemming om korte inhoud en websites effectief te blokkeren.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Gebruik NLP digitox';

  @override
  String get permission_dnd_title => 'Niet storen';

  @override
  String get permission_dnd_info =>
      'Verleen \'Niet storen\'-toegang. Hierdoor kan NLP digitox de modus Niet storen starten en stoppen tijdens het bedtijdschema.';

  @override
  String get permission_dnd_tile_title => 'Begin niet storen';

  @override
  String get permission_dnd_tile_subtitle =>
      'Schakel ook de modus Niet storen in.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Negeer batterijoptimalisatie';

  @override
  String get permission_battery_optimization_status_enabled => 'Al onbeperkt';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Schakel achtergrondbeperking uit';

  @override
  String get permission_battery_optimization_allow_info =>
      'Als u \'Batterijoptimalisatie negeren\' toestaat, wordt op sommige apparaten automatisch de machtiging \'Alarmen en herinneringen\' verleend.';

  @override
  String get permission_vpn_title => 'Maak een VPN';

  @override
  String get permission_vpn_info =>
      'Geef toestemming om een VPN-verbinding (virtueel particulier netwerk) te maken. Hierdoor kan NLP digitox de internettoegang voor bepaalde applicaties beperken door een lokale VPN op het apparaat te creëren.';

  @override
  String get permission_admin_title => 'Beheerder';

  @override
  String get permission_admin_info =>
      'Beheerdersrechten zijn alleen nodig voor essentiële handelingen om ervoor te zorgen dat de app goed werkt en fraudebestendig blijft.';

  @override
  String get permission_admin_snack_alert =>
      'De sabotagebeveiliging kan alleen tijdens het geselecteerde tijdvenster worden uitgeschakeld.';

  @override
  String get permission_notification_access_title => 'Toegang tot meldingen';

  @override
  String get permission_notification_access_info =>
      'Geef toestemming voor toegang tot meldingen. Hierdoor kan NLP digitox uw meldingen organiseren en volgens uw planning afleveren.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox vereist toegang tot meldingen voor batch- en planningsmeldingen.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Toegang tot meldingen toestaan';

  @override
  String get day_today => 'Vandaag';

  @override
  String get day_yesterday => 'Gisteren';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dagen',
      one: '1 dag',
      zero: '0 dagen',
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
      other: '$countString uur',
      one: '1 uur',
      zero: '0 uur',
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
      other: '$countString minuten',
      one: '1 minuut',
      zero: '0 minuten',
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
      other: '$countString seconden',
      one: '1 seconde',
      zero: '0 seconden',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'en';

  @override
  String get timer_status_active => 'Actief';

  @override
  String get timer_status_paused => 'Gepauzeerd';

  @override
  String get create_button => 'Creëer';

  @override
  String get update_button => 'Bijwerken';

  @override
  String get dialog_button_cancel => 'Annuleer';

  @override
  String get dialog_button_remove => 'Verwijderen';

  @override
  String get dialog_button_set => 'Instellen';

  @override
  String get dialog_button_reset => 'Opnieuw instellen';

  @override
  String get dialog_button_infinite => 'Oneindig';

  @override
  String get schedule_start_label => 'Begin';

  @override
  String get schedule_end_label => 'Einde';

  @override
  String get exit_without_saving_dialog_info =>
      'Weet u zeker dat u wilt afsluiten zonder op te slaan?';

  @override
  String get development_dialog_info =>
      'NLP digitox wordt momenteel ontwikkeld en bevat mogelijk bugs of onvolledige functies. Als u problemen ondervindt, kunt u deze melden om ons te helpen verbeteren.\n\nBedankt voor uw feedback!';

  @override
  String get development_dialog_button_report_issue => 'Rapporteer probleem';

  @override
  String get development_dialog_button_close => 'Sluiten';

  @override
  String get dnd_settings_tile_title => 'Instellingen niet storen';

  @override
  String get dnd_settings_tile_subtitle =>
      'Beheer welke apps en meldingen u kunnen bereiken in Niet storen.';

  @override
  String get quick_actions_heading => 'Snelle acties';

  @override
  String get select_distracting_apps_heading => 'Selecteer afleidende apps';

  @override
  String get your_distracting_apps_heading => 'Je afleidende apps';

  @override
  String get select_more_apps_heading => 'Selecteer meer apps';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Het toevoegen van belangrijke systeemapps aan de lijst met afleidende apps is niet toegestaan.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Schermgebruik en beperkingen zijn niet beschikbaar voor deze applicatie. Momenteel is alleen netwerkgebruik toegankelijk';

  @override
  String get create_group_fab_button => 'Groep aanmaken';

  @override
  String get active_period_info =>
      'Stel een periode in waarin toegang is toegestaan. Buiten dit tijdsbestek is de toegang beperkt.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Selecteer ten minste één afleidende app.';

  @override
  String get donation_card_title => 'Steun ons';

  @override
  String get donation_card_info =>
      'NLP digitox is gratis en open-source, ontwikkeld met maandenlange toewijding. Als het u heeft geholpen, zou uw donatie alles voor ons betekenen. Elke bijdrage helpt ons om het voor iedereen te blijven verbeteren en behouden.';

  @override
  String get operation_failed_snack_alert =>
      'Operatie mislukt, er is iets misgegaan!';

  @override
  String get donation_card_button_donate => 'Doneer';

  @override
  String get app_restart_dialog_title => 'Herstart nodig';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox wordt automatisch opnieuw opgestart zodra het aftellen is voltooid. Even geduld, aangezien er wijzigingen worden toegepast.';

  @override
  String get accessibility_tip =>
      'Wilt u slimmer en batterijvriendelijker blokkeren? Schakel Toegankelijkheidsmachtiging in voor NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox werkt niet? Sta \'Batterijoptimalisatie negeren\' toe in Instellingen om ervoor te zorgen dat alles soepel blijft werken.';

  @override
  String get invincible_mode_tip =>
      'Per ongeluk beperkingen verwijderd? Gebruik de Invincible-modus om ze te vergrendelen tot de volgende dag of het aanpassingsvenster.';

  @override
  String get glance_usage_tip =>
      'Wil je inzichten? Controleer het gedeelte Glans om uw gebruikspatronen en schermtijd te bekijken.';

  @override
  String get tamper_protection_tip =>
      'NLP digitox verwijderen? Schakel het verwijderingsvenster in om de sabotagebeveiliging eerst veilig uit te schakelen.';

  @override
  String get notification_blocking_tip =>
      'Wil je afleiding verminderen? Gebruik Meldingsblokkering om geselecteerde apps te dempen.';

  @override
  String get usage_history_tip =>
      'Wil je reflecteren op je gewoontes? Controleer Gebruiksgeschiedenis om patronen uit het verleden te bekijken.';

  @override
  String get focus_mode_tip =>
      'Diepe focus nodig? Schakel de Focusmodus in om apps en meldingen tijdens taken te blokkeren.';

  @override
  String get bedtime_reminder_tip =>
      'Wilt u uw slaap verbeteren? Stel een bedtijdherinnering in om \'s avonds tot rust te komen.';

  @override
  String get custom_blocking_tip =>
      'Een ervaring op maat nodig? Maak app-blokkeerregels die aan uw behoeften voldoen.';

  @override
  String get session_timeline_tip =>
      'Wilt u focussessies volgen? Bekijk de tijdlijn om uw focusreis te zien.';

  @override
  String get short_content_blocking_tip =>
      'Afgeleid door sociale apps? Blokkeer korte inhoud op Instagram, YouTube, enz. om gefocust te blijven.';

  @override
  String get parental_controls_tip =>
      'Ouderlijk toezicht nodig? Stel beperkingen in voor het apparaat van uw kind om een ​​veilige ervaring te garanderen.';

  @override
  String get notification_batching_tip =>
      'Wil je afleiding verminderen? Gebruik Notification Batching om meldingen te groeperen en ze in één keer te controleren.';

  @override
  String get notification_scheduling_tip =>
      'Wilt u meldingen beheren? Plan wanneer u meldingen ontvangt voor specifieke apps.';

  @override
  String get quick_focus_tile_tip =>
      'Snelle toegang tot focus nodig? Voeg een Quick Focus Tile toe om de focusmodus onmiddellijk te activeren.';

  @override
  String get app_shortcuts_tip =>
      'Wilt u direct app-toegang? Voeg snelkoppelingen toe door lang op het app-pictogram te drukken voor snelle acties.';

  @override
  String get backup_usage_db_tip =>
      'Wilt u uw gegevens opslaan? Maak een back-up van uw gebruiksdatabase om uw gegevens veilig te houden.';

  @override
  String get dynamic_material_color_tip =>
      'Wilt u een aangepast thema? Schakel dynamisch materiaal in. Je kleur past bij het thema van je apparaat.';

  @override
  String get amoled_dark_theme_tip =>
      'Wil je de batterij sparen? Gebruik AMOLED Dark Theme om het stroomverbruik op OLED-schermen te verminderen.';

  @override
  String get customize_usage_history_tip =>
      'Wilt u de gebruiksgeschiedenis bijhouden? Pas aan hoeveel weken aan gegevens u wilt opslaan in Gebruiksgeschiedenis.';

  @override
  String get grouped_apps_blocking_tip =>
      'Wil je apps samen blokkeren? Gebruik Beperkingsgroepen om app-limieten te groeperen en meerdere apps tegelijk te blokkeren.';

  @override
  String get websites_blocking_tip =>
      'Wilt u een schonere browse-ervaring? Blokkeer aangepaste of NSFW-websites voor een meer gerichte online tijd.';

  @override
  String get data_usage_tip =>
      'Wilt u uw gegevens bijhouden? Houd uw mobiele en Wi-Fi-datagebruik in de gaten voor internetgebruik.';

  @override
  String get block_internet_tip =>
      'Wilt u het internet van een app blokkeren? Sluit het internet voor een specifieke app af via het dashboard van de app.';

  @override
  String get emergency_passes_tip =>
      'Een pauze nodig? Gebruik dagelijks 3 Noodpassen om apps tijdelijk gedurende 5 minuten te deblokkeren.';

  @override
  String get onboarding_skip_btn_label => 'Overslaan';

  @override
  String get onboarding_finish_setup_btn_label => 'Voltooi de installatie';

  @override
  String get onboarding_page_welcome_title => 'Welkom bij NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Neem de controle over je digitale leven en bouw gezondere schermgewoonten op. NLP digitox helpt je gefocust te blijven, afleiding te minimaliseren en elke dag bewuste keuzes te maken.';

  @override
  String get onboarding_page_statistics_title => 'Leer je gewoonten kennen.';

  @override
  String get onboarding_page_statistics_info =>
      'Begrijp je digitale patronen met gedetailleerde inzichten over schermtijd, app-gebruik en focustrends. Volg je voortgang en zie hoe kleine veranderingen tot grote verbeteringen leiden.';

  @override
  String get onboarding_page_one_title => 'Meesterfocus.';

  @override
  String get onboarding_page_one_info =>
      'Pauzeer afleidende apps, blokkeer korte inhoud en blijf op koers met aanpasbare focussessies. Of je nu werkt, studeert of ontspant, NLP digitox helpt je de controle te behouden.';

  @override
  String get onboarding_page_two_title => 'Blokkeer afleidingen.';

  @override
  String get onboarding_page_two_info =>
      'Stel gebruikslimieten in, pauzeer apps automatisch en creëer gezondere digitale gewoonten. Gebruik de Bedtijdmodus om te ontspannen en te genieten van een avond zonder afleiding.';

  @override
  String get onboarding_page_three_title => 'Privacy eerst.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox is 100% open-source en werkt volledig offline. Wij verzamelen of delen uw persoonlijke gegevens niet; uw privacy is op alle mogelijke manieren gegarandeerd.';

  @override
  String get onboarding_page_permissions_title => 'Essentiële machtigingen.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox vereist de volgende essentiële machtigingen om uw schermtijd bij te houden en te beheren, waardoor afleiding wordt verminderd en de focus wordt verbeterd.';

  @override
  String get dashboard_tab_title => 'Dashboard';

  @override
  String get focus_now_fab_button => 'Focus nu';

  @override
  String get welcome_greetings => 'Welkom terug,';

  @override
  String get username_snack_alert =>
      'Druk lang om de gebruikersnaam te bewerken.';

  @override
  String get username_dialog_title => 'Gebruikersnaam';

  @override
  String get username_dialog_info =>
      'Voer uw gebruikersnaam in die op het dashboard wordt weergegeven.';

  @override
  String get username_dialog_button_apply => 'Toepassen';

  @override
  String get glance_tile_title => 'Blik';

  @override
  String get glance_tile_subtitle => 'Bekijk snel uw verbruik.';

  @override
  String get parental_controls_tile_subtitle =>
      'Onoverwinnelijke modus en sabotagebeveiliging.';

  @override
  String get restrictions_heading => 'Beperkingen';

  @override
  String get apps_blocking_tile_title => 'Apps blokkeren';

  @override
  String get apps_blocking_tile_subtitle => 'Beperk apps op meerdere manieren.';

  @override
  String get grouped_apps_blocking_tile_title => 'Gegroepeerde apps blokkeren';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Beperk de groep apps tegelijk.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Beperk korte inhoud op meerdere platforms.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Beperk websites voor volwassenen en aangepaste websites.';

  @override
  String get screen_time_label => 'Schermtijd';

  @override
  String get total_data_label => 'Totaal gegevens';

  @override
  String get mobile_data_label => 'Mobiele gegevens';

  @override
  String get wifi_data_label => 'Wifi-gegevens';

  @override
  String get focus_today_label => 'Focus vandaag';

  @override
  String get focus_weekly_label => 'Wekelijks focussen';

  @override
  String get focus_monthly_label => 'Maandelijks focussen';

  @override
  String get focus_lifetime_label => 'Levensduur van focus';

  @override
  String get longest_streak_label => 'Langste reeks';

  @override
  String get current_streak_label => 'Huidige reeks';

  @override
  String get successful_sessions_label => 'Succesvolle sessies';

  @override
  String get failed_sessions_label => 'Mislukte sessies';

  @override
  String get statistics_tab_title => 'Statistieken';

  @override
  String get screen_segment_label => 'Scherm';

  @override
  String get data_segment_label => 'Gegevens';

  @override
  String get mobile_label => 'Mobiel';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Meest gebruikte apps';

  @override
  String get show_all_apps_tile_title => 'Toon alle apps';

  @override
  String get search_apps_hint => 'Apps zoeken...';

  @override
  String get notifications_tab_title => 'Meldingen';

  @override
  String get notifications_tab_info =>
      'Batch notificaties van apps en stel schema\'s in zoals \'s ochtends, \'s middags, \'s avonds en \'s nachts. Blijf op de hoogte zonder constante onderbrekingen.';

  @override
  String get batched_apps_tile_title => 'Gebatcheerde apps';

  @override
  String get batch_recap_dropdown_title => 'Type batchoverzicht';

  @override
  String get batch_recap_dropdown_info =>
      'Kies wat u wilt pushen wanneer een schema wordt geactiveerd: alle meldingen of alleen een samenvatting.';

  @override
  String get batch_recap_option_summery_only => 'Alleen samenvatting';

  @override
  String get batch_recap_option_all_notifications => 'Alle meldingen';

  @override
  String get notification_history_tile_title => 'Meldingsgeschiedenis';

  @override
  String get store_all_tile_title => 'Bewaar alle meldingen';

  @override
  String get store_all_tile_subtitle => 'Bewaar ook niet-batchmeldingen.';

  @override
  String get schedules_heading => 'Schema\'s';

  @override
  String get new_schedule_fab_button => 'Nieuw schema';

  @override
  String get new_schedule_dialog_info =>
      'Voer een naam in voor het meldingsschema, zodat u het gemakkelijk kunt identificeren.';

  @override
  String get new_schedule_dialog_field_label => 'Naam van schema';

  @override
  String get bedtime_tab_title => 'Bedtijd';

  @override
  String get bedtime_tab_info =>
      'Stel uw bedtijdschema in door een tijdsperiode en dagen van de week te selecteren. Kies afleidende apps om te blokkeren en schakel de modus Niet storen (DND) in voor een rustige nacht.';

  @override
  String get schedule_tile_title => 'Schema';

  @override
  String get schedule_tile_subtitle => 'Dagelijks schema in- of uitschakelen.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Selecteer minimaal één dag van de week.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'De totale bedtijd moet minimaal 30 minuten zijn.';

  @override
  String get distracting_apps_tile_title => 'Afleidende apps';

  @override
  String get distracting_apps_tile_subtitle =>
      'Selecteer welke apps u afleiden van uw bedtijdroutine.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Wijzigingen in de lijst met afleidende apps zijn niet toegestaan ​​zolang het bedtijdschema actief is.';

  @override
  String get parental_controls_tab_title => 'Ouderlijk toezicht';

  @override
  String get invincible_mode_heading => 'Onoverwinnelijke modus';

  @override
  String get invincible_mode_tile_title => 'Activeer de onoverwinnelijke modus';

  @override
  String get invincible_mode_info =>
      'Als de onoverwinnelijke modus is ingeschakeld, kun je de geselecteerde limieten niet meer aanpassen nadat je je dagelijkse quotum hebt bereikt. U kunt echter binnen een geselecteerd onoverwinnelijk venster van 10 minuten wijzigingen aanbrengen.';

  @override
  String get invincible_mode_snack_alert =>
      'Vanwege de onoverwinnelijke modus zijn wijzigingen in de beperkingen niet toegestaan.';

  @override
  String get invincible_mode_dialog_info =>
      'Weet je absoluut zeker dat je de Invincible Mode wilt inschakelen? Deze actie is onomkeerbaar. Zodra de onoverwinnelijke modus is ingeschakeld, kunt u deze niet meer uitschakelen zolang deze app op uw apparaat is geïnstalleerd.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'De onoverwinnelijke modus kan niet worden uitgeschakeld zolang deze app op uw apparaat geïnstalleerd blijft.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Begin toch maar';

  @override
  String get invincible_mode_include_timer_tile_title => 'Inclusief timer';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Inclusief lanceerlimiet';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Inclusief actieve periode';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'App-beperkingen';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Voorkom wijzigingen in de geselecteerde beperkingen van de app zodra de dagelijkse limieten worden overschreden.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Groepsbeperkingen';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Voorkom wijzigingen in de geselecteerde beperkingen van de groep zodra de dagelijkse limieten worden overschreden.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Inclusief korte timer';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Voorkomt wijzigingen nadat u uw dagelijkse kortetermijnlimiet heeft bereikt.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Inclusief bedtijd';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Voorkomt veranderingen tijdens het actieve bedtijdschema.';

  @override
  String get protected_access_tile_title => 'Beveiligde toegang';

  @override
  String get protected_access_tile_subtitle =>
      'Bescherm NLP digitox met uw apparaatvergrendeling.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Stel eerst een biometrisch slot in op uw apparaat om deze functie in te schakelen.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Uw apparaatvergrendeling is verwijderd. Stel een nieuw slot in om door te gaan.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Authenticatie mislukt. U moet uw apparaatvergrendeling verifiëren om door te gaan.';

  @override
  String get tamper_protection_tile_title => 'Bescherming tegen manipulatie';

  @override
  String get tamper_protection_tile_subtitle =>
      'Voorkom het verwijderen en forceer het stoppen van de app.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Eenmaal ingeschakeld, kunt u de gegevens van NLP digitox niet meer verwijderen, geforceerd stoppen of wissen, behalve tijdens het geselecteerde verwijderingsvenster. Er zijn geen oplossingen.\n\nGa verder op eigen risico.';

  @override
  String get uninstall_window_tile_title => 'Venster verwijderen';

  @override
  String get uninstall_window_tile_subtitle =>
      'Sabotagebeveiliging kan binnen 10 minuten na de geselecteerde tijd worden uitgeschakeld.';

  @override
  String get invincible_window_tile_title => 'Onoverwinnelijk raam';

  @override
  String get invincible_window_tile_subtitle =>
      'Geselecteerde limieten kunnen binnen 10 minuten vanaf het geselecteerde tijdstip worden gewijzigd.';

  @override
  String get shorts_blocking_tab_title => 'Korte broek blokkeert';

  @override
  String get shorts_blocking_tab_info =>
      'Bepaal hoeveel tijd u besteedt aan korte inhoud op platforms zoals Instagram, YouTube, Snapchat en Facebook, inclusief hun websites.';

  @override
  String get short_content_heading => 'Korte inhoud';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Links van $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Stel een dagelijkse tijdslimiet in voor korte inhoud. Zodra uw limiet is bereikt, wordt de korte inhoud gepauzeerd tot middernacht.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Beperk functies op Instagram.';

  @override
  String get instagram_features_block_reels => 'Beperk de haspelsectie.';

  @override
  String get instagram_features_block_explore => 'Beperk de verkenningssectie.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle => 'Beperk functies op Snapchat.';

  @override
  String get snapchat_features_block_spotlight => 'Spotlight-sectie beperken.';

  @override
  String get snapchat_features_block_discover => 'Beperk de ontdekkingssectie.';

  @override
  String get youtube_features_tile_title => 'YouTube';

  @override
  String get youtube_features_tile_subtitle => 'Beperk korte films op YouTube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Beperk rollen op Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Beperk shorts op reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Beperk de videofeed op X.';

  @override
  String get threads_features_tile_title => 'Draden';

  @override
  String get threads_features_tile_subtitle =>
      'Beperk video/rollen op Threads.';

  @override
  String get websites_blocking_tab_title => 'Websites blokkeren';

  @override
  String get websites_blocking_tab_info =>
      'Blokkeer websites voor volwassenen en alle aangepaste sites die u kiest om een veiligere en meer gerichte online-ervaring te creëren. Neem de leiding over uw browsen en blijf vrij van afleiding.';

  @override
  String get adult_content_heading => 'Inhoud voor volwassenen';

  @override
  String get block_nsfw_title => 'Blok Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Voorkom dat browsers websites voor volwassenen en pornowebsites openen.';

  @override
  String get block_nsfw_dialog_info =>
      'Weet je het zeker? Deze actie is onomkeerbaar. Zodra de blokkering van sites voor volwassenen is ingeschakeld, kunt u deze niet meer uitschakelen zolang deze app op uw apparaat is geïnstalleerd.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Toch blokkeren';

  @override
  String get blocked_websites_heading => 'Geblokkeerde websites';

  @override
  String get blocked_websites_empty_list_hint =>
      'Klik op de knop \'+ Website toevoegen\' om afleidende websites toe te voegen die u wilt blokkeren.';

  @override
  String get add_website_fab_button => 'Website toevoegen';

  @override
  String get add_website_dialog_title => 'Afleidende website';

  @override
  String get add_website_dialog_info =>
      'Voer de URL in van een website die u wilt blokkeren.';

  @override
  String get add_website_dialog_is_nsfw => 'Is een nsfw-site?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Waarschuwing: Nsfw-sites kunnen na toevoeging niet meer worden verwijderd.';

  @override
  String get add_website_dialog_button_block => 'Blok';

  @override
  String get add_website_already_exist_snack_alert =>
      'De URL is al toegevoegd aan de lijst met geblokkeerde websites.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Ongeldige URL! Kan de hostnaam niet parseren.';

  @override
  String get remove_website_dialog_title => 'Website verwijderen';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Weet je het zeker? u wilt \'$websitehost\' van geblokkeerde websites verwijderen.';
  }

  @override
  String get focus_tab_title => 'Focus';

  @override
  String get focus_tab_info =>
      'Als je tijd nodig hebt om je te concentreren, start je een nieuwe sessie door het type te selecteren, afleidende apps te kiezen om te pauzeren en Niet storen in te schakelen voor ononderbroken concentratie.';

  @override
  String get active_session_card_title => 'Actieve sessie';

  @override
  String get active_session_card_info =>
      'Je hebt een actieve focussessie lopen! Klik op \'Bekijken\' om uw voortgang te controleren en te zien hoeveel tijd er is verstreken.';

  @override
  String get active_session_card_view_button => 'Bekijk';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Het verwijderen van apps uit de lijst met afleidende apps is niet toegestaan zolang een Focussessie actief is. Gedurende deze tijd kunt u echter nog steeds extra apps aan de lijst toevoegen.';

  @override
  String get focus_profile_tile_title => 'Focusprofiel';

  @override
  String get focus_session_duration_tile_title => 'Sessieduur';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Oneindig (tenzij je stopt)';

  @override
  String get focus_session_duration_dialog_info =>
      'Selecteer de gewenste duur voor deze focussessie en bepaal hoe lang u gefocust en zonder afleiding wilt blijven.';

  @override
  String get focus_profile_customization_tile_title => 'Profielaanpassing';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Pas de instellingen voor het geselecteerde profiel aan.';

  @override
  String get focus_enforce_tile_title => 'Sessie afdwingen';

  @override
  String get focus_enforce_tile_subtitle =>
      'Voorkomt dat een sessie wordt beëindigd voordat de tijd is verstreken.';

  @override
  String get focus_session_start_button => 'Veeg om de sessie te starten';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Selecteer ten minste één afleidende app om de focussessie te starten';

  @override
  String get focus_session_already_active_snack_alert =>
      'Je hebt al een actieve focussessie lopen. Voltooi of stop uw huidige sessie voordat u een nieuwe start.';

  @override
  String get focus_session_type_study => 'Studeer';

  @override
  String get focus_session_type_work => 'Werk';

  @override
  String get focus_session_type_exercise => 'Oefening';

  @override
  String get focus_session_type_meditation => 'Meditatie';

  @override
  String get focus_session_type_creativeWriting => 'Creatief schrijven';

  @override
  String get focus_session_type_reading => 'Lezen';

  @override
  String get focus_session_type_programming => 'Programmering';

  @override
  String get focus_session_type_chores => 'Klusjes';

  @override
  String get focus_session_type_projectPlanning => 'Projectplanning';

  @override
  String get focus_session_type_artAndDesign => 'Kunst en ontwerp';

  @override
  String get focus_session_type_languageLearning => 'Taal leren';

  @override
  String get focus_session_type_musicPractice => 'Muziek praktijk';

  @override
  String get focus_session_type_selfCare => 'Zelfzorg';

  @override
  String get focus_session_type_brainstorming => 'Brainstormen';

  @override
  String get focus_session_type_skillDevelopment =>
      'Ontwikkeling van vaardigheden';

  @override
  String get focus_session_type_research => 'Onderzoek';

  @override
  String get focus_session_type_networking => 'Netwerken';

  @override
  String get focus_session_type_cooking => 'Koken';

  @override
  String get focus_session_type_sportsTraining => 'Sporttraining';

  @override
  String get focus_session_type_restAndRelaxation => 'Rust en ontspanning';

  @override
  String get focus_session_type_other => 'Anders';

  @override
  String get timeline_tab_title => 'Tijdlijn';

  @override
  String get focus_timeline_tab_info =>
      'Ontdek uw focusreis door een datum in de kalender te selecteren. Houd uw voortgang bij, bekijk uw successen opnieuw en leer van de uitdagingen.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Uw totale productieve tijd voor de geselecteerde maand is $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Productieve dagen';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'U heeft in de geselecteerde maand in totaal $daysCount productieve dagen gehad.';
  }

  @override
  String get selected_day_focused_time_label => 'Geconcentreerde tijd';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Uw totale focustijd voor de geselecteerde dag is $timeString.';
  }

  @override
  String get calender_heading => 'Kalender';

  @override
  String get your_sessions_heading => 'Jouw sessies';

  @override
  String get your_sessions_empty_list_hint =>
      'Er zijn geen focussessies opgenomen voor de geselecteerde dag.';

  @override
  String get focus_session_tile_timestamp_label => 'Tijdstempel';

  @override
  String get focus_session_tile_duration_label => 'Duur';

  @override
  String get focus_session_tile_reflection_label => 'Reflectie';

  @override
  String get focus_session_state_active => 'Actief';

  @override
  String get focus_session_state_successful => 'Succesvol';

  @override
  String get focus_session_state_failed => 'Mislukt';

  @override
  String get active_session_tab_title => 'Sessie';

  @override
  String get active_session_none_warning =>
      'Geen actieve sessie gevonden. Terugkeren naar het startscherm.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Blijf duwen';

  @override
  String get active_session_finish_dialog_title => 'Afwerking';

  @override
  String get active_session_finish_dialog_info =>
      'Blijf sterk! Je bouwt waardevolle focus op. Weet je zeker dat je deze focussessie wilt beëindigen? Elk extra moment telt mee voor uw doelen.';

  @override
  String get active_session_giveup_dialog_title => 'Geef het op';

  @override
  String get active_session_giveup_dialog_info =>
      'Wacht even! Je bent er bijna, geef nu niet op! Weet je zeker dat je deze focussessie eerder wilt beëindigen? De vooruitgang zal verloren gaan.';

  @override
  String get active_session_reflection_dialog_title => 'Sessie reflectie';

  @override
  String get active_session_reflection_dialog_info =>
      'Neem even de tijd om na te denken over uw voortgang. Wat is je doel voor deze sessie? Wat heb je bereikt tijdens deze sessie?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tip: Je kunt dit altijd later in de sessietijdlijn bewerken.';

  @override
  String get active_session_giveup_snack_alert =>
      'Je gaf het op! Maak je geen zorgen, de volgende keer kun je het beter doen. Elke inspanning telt – blijf gewoon doorgaan';

  @override
  String get active_session_quote_one =>
      'Elke stap telt, blijf sterk en ga door';

  @override
  String get active_session_quote_two =>
      'Blijf gefocust! je boekt geweldige vooruitgang';

  @override
  String get active_session_quote_three =>
      'Je verplettert het! Houd het momentum gaande';

  @override
  String get active_session_quote_four =>
      'Nog even te gaan, je doet het fantastisch';

  @override
  String active_session_quote_five(String durationString) {
    return 'Gefeliciteerd 🎉 \n Je hebt je focussessie van $durationString.\n\n Goed gedaan, ga zo door';
  }

  @override
  String get restriction_groups_tab_title => 'Beperkingsgroepen';

  @override
  String get restriction_groups_tab_info =>
      'Stel een gecombineerde schermtijdlimiet in voor een groep apps. Zodra het totale gebruik uw limiet bereikt, worden alle apps in de groep gepauzeerd om de focus en balans te behouden.';

  @override
  String get restriction_group_time_spent_label => 'Tijd besteed vandaag';

  @override
  String get restriction_group_time_left_label => 'Vandaag nog tijd over';

  @override
  String get restriction_group_name_tile_title => 'Groepsnaam';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Voer een naam in voor de beperkingsgroep, zodat u deze eenvoudig kunt identificeren en beheren.';

  @override
  String get restriction_group_timer_tile_title => 'Groepstimer';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Stel een dagelijkse tijdslimiet in voor deze groep. Zodra uw limiet is bereikt, worden alle apps in deze groep tot middernacht gepauzeerd.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Groep actieve periode';

  @override
  String get remove_restriction_group_dialog_title => 'Groep verwijderen';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Weet je het zeker? u wilt \'$groupName\' verwijderen uit beperkingsgroepen.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Stel een timer of een actieve periodelimiet in.';

  @override
  String get notifications_empty_list_hint =>
      'Er zijn die dag geen meldingen verzameld.';

  @override
  String get conversations_label => 'Gesprekken';

  @override
  String get last_24_hours_heading => 'Afgelopen 24 uur';

  @override
  String get notification_timeline_tab_info =>
      'Blader door uw meldingsgeschiedenis door een datum in de kalender te selecteren. Bekijk welke apps uw aandacht hebben getrokken en reflecteer op uw digitale gewoonten.';

  @override
  String get monthly_label => 'Maandelijks';

  @override
  String get daily_label => 'Dagelijks';

  @override
  String get search_notifications_sheet_info =>
      'Vind eenvoudig eerdere meldingen door op hun titel of inhoud te zoeken. Helpt u snel belangrijke waarschuwingen te vinden.';

  @override
  String get search_notifications_hint => 'Meldingen zoeken...';

  @override
  String get search_notifications_empty_list_hint =>
      'Er zijn geen meldingen gevonden die overeenkomen met uw zoekopdracht.';

  @override
  String get app_info_none_warning =>
      'Kan de app voor het opgegeven pakket niet vinden. Terugkeren naar het startscherm.';

  @override
  String get emergency_fab_button => 'Noodsituatie';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Met deze actie wordt de app-blokkering gedurende de volgende vijf minuten onderbroken. Je hebt nog $leftPassesCount-passen over. Nadat alle passen zijn gebruikt, blijft de app geblokkeerd tot middernacht, of eindigt de actieve focussessie.\n\nWilt u nog steeds doorgaan?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Hoe dan ook gebruiken';

  @override
  String get emergency_started_snack_alert =>
      'De app-blokkering is gepauzeerd en wordt over 5 minuten hervat.';

  @override
  String get emergency_already_active_snack_alert =>
      'De app-blokkering is momenteel gepauzeerd of inactief. Als meldingen zijn ingeschakeld, ontvangt u updates over de resterende tijd.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'U heeft al uw noodpassen gebruikt. De geblokkeerde apps blijven geblokkeerd tot middernacht, of de actieve focussessie eindigt.';

  @override
  String get app_limit_status_not_set => 'Niet ingesteld';

  @override
  String get app_timer_tile_title => 'App-timer';

  @override
  String get app_timer_picker_dialog_info =>
      'Stel een dagelijkse tijdslimiet in voor deze app. Zodra uw limiet is bereikt, wordt de app gepauzeerd tot middernacht.';

  @override
  String get usage_reminders_tile_title => 'Gebruiksherinneringen';

  @override
  String get usage_reminders_tile_subtitle =>
      'Zachte duwtjes bij het gebruik van getimede apps.';

  @override
  String get app_launch_limit_tile_title => 'Lanceringslimiet';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Vandaag $count keer gelanceerd.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Stel in hoe vaak u deze app per dag kunt openen. Zodra de limiet is bereikt, wordt deze gepauzeerd tot middernacht.';

  @override
  String get app_active_period_tile_title => 'Actieve periode';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Van $startTime tot $endTime';
  }

  @override
  String get internet_access_tile_title => 'Internettoegang';

  @override
  String get internet_access_tile_subtitle =>
      'Schakel uit om het internet van de app te blokkeren.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Het internet van $appName is geblokkeerd.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Het internet van $appName is gedeblokkeerd.';
  }

  @override
  String get launch_app_tile_title => 'Start app';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Open $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Ga naar app-instellingen';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Beheer app-instellingen zoals meldingen, rechten, opslag en meer.';

  @override
  String get include_in_stats_tile_title => 'Meenemen in schermgebruik';

  @override
  String get include_in_stats_tile_subtitle =>
      'Schakel uit om deze app uit te sluiten van het totale schermgebruik.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName is uitgesloten van het totale schermgebruik.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName is inbegrepen bij het totale schermgebruik.';
  }

  @override
  String get general_tab_title => 'Algemeen';

  @override
  String get appearance_heading => 'Uiterlijk';

  @override
  String get theme_mode_tile_title => 'Thema-modus';

  @override
  String get theme_mode_system_label => 'Systeem';

  @override
  String get theme_mode_light_label => 'Licht';

  @override
  String get theme_mode_dark_label => 'Donker';

  @override
  String get material_color_tile_title => 'Materiaal kleur';

  @override
  String get amoled_dark_tile_title => 'AMOLED-donker';

  @override
  String get amoled_dark_tile_subtitle =>
      'Gebruik puur zwarte kleur voor het donkere thema.';

  @override
  String get dynamic_colors_tile_title => 'Dynamische kleuren';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Gebruik apparaatkleuren indien ondersteund.';

  @override
  String get defaults_heading => 'Standaardwaarden';

  @override
  String get app_language_tile_title => 'App-taal';

  @override
  String get default_home_tab_tile_title => 'Tabblad Start';

  @override
  String get usage_history_tile_title => 'Gebruiksgeschiedenis';

  @override
  String get usage_history_15_days => '15 dagen';

  @override
  String get usage_history_1_month => '1 maand';

  @override
  String get usage_history_3_month => '3 maanden';

  @override
  String get usage_history_6_month => '6 maanden';

  @override
  String get usage_history_1_year => '1 jaar';

  @override
  String get service_heading => 'Dienst';

  @override
  String get service_stopping_warning =>
      'Als NLP digitox onverwacht stopt met werken, geef dan de toestemming \'Batterijoptimalisatie negeren\' om de app op de achtergrond actief te houden. Als het probleem zich blijft voordoen, probeer dan NLP digitox op de witte lijst te zetten voor ononderbroken prestaties.';

  @override
  String get whitelist_app_tile_title => 'Witte lijst NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Laat NLP digitox automatisch starten.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Dit apparaat ondersteunt geen automatisch opstartbeheer.';

  @override
  String get database_tab_title => 'Database';

  @override
  String get import_db_tile_title => 'Database importeren';

  @override
  String get import_db_tile_subtitle => 'Importeer database uit een bestand.';

  @override
  String get export_db_tile_title => 'Database exporteren';

  @override
  String get export_db_tile_subtitle => 'Database exporteren naar een bestand.';

  @override
  String get analysis_tab_title => 'Analyse';

  @override
  String get analysis_7_days => '7 dagen';

  @override
  String get analysis_30_days => '30 dagen';

  @override
  String get analysis_90_days => '90 dagen';

  @override
  String get analysis_screen_time_trend => 'Schermtijdtendens';

  @override
  String get analysis_no_data_info =>
      'Voor deze periode zijn nog geen schermtijdgegevens geregistreerd.';

  @override
  String get analysis_daily_average => 'Daggemiddelde';

  @override
  String get analysis_total => 'Totaal';

  @override
  String get analysis_no_change => 'Hetzelfde als vorige week';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% minder dan vorige week';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% meer dan vorige week';
  }

  @override
  String get crash_logs_heading => 'Crashlogboeken';

  @override
  String get crash_logs_info =>
      'Als u een probleem tegenkomt, kunt u dit samen met het logbestand op GitHub melden. Het bestand bevat details zoals de fabrikant, het model, de Android-versie, de SDK-versie en crashlogboeken van uw apparaat. Deze informatie zal ons helpen het probleem effectiever te identificeren en op te lossen.';

  @override
  String get crash_logs_export_tile_title => 'Crashlogboeken exporteren';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Crashlogboeken exporteren naar een json-bestand.';

  @override
  String get crash_logs_view_tile_title => 'Bekijk logboeken';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Ontdek opgeslagen crashlogboeken.';

  @override
  String get crash_logs_empty_list_hint =>
      'Tot nu toe geen crash geregistreerd.';

  @override
  String get crash_logs_clear_tile_title => 'Logboeken wissen';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Verwijder alle crashlogboeken uit de database.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Weet u zeker dat u alle crashlogboeken uit de database wilt wissen?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Toch duidelijk';

  @override
  String get about_tab_title => 'Over';

  @override
  String get changelog_tile_title => 'Wijzigingslog';

  @override
  String get changelog_tile_subtitle => 'Ontdek wat er nieuw is.';

  @override
  String get full_changelog_tile_title => 'Volledige changelog';

  @override
  String get redirected_to_github_subtitle =>
      'U wordt doorgestuurd naar GitHub.';

  @override
  String get contribute_heading => 'Draag bij';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Bekijk de broncode.';

  @override
  String get report_issue_tile_title => 'Rapporteer een probleem';

  @override
  String get suggest_idea_tile_title => 'Stel een idee voor';

  @override
  String get write_email_tile_title => 'Schrijf ons via e-mail';

  @override
  String get write_email_tile_subtitle =>
      'U wordt doorgestuurd naar de E-mailapp.';

  @override
  String get privacy_policy_heading => 'Privacybeleid';

  @override
  String get privacy_policy_info =>
      'NLP digitox doet er alles aan om uw privacy te beschermen. Wij verzamelen, bewaren of dragen geen enkel type gebruikersgegevens over. De app werkt volledig offline en vereist geen internetverbinding, zodat uw persoonlijke gegevens privé en veilig op uw apparaat blijven. Als gratis en open source software (FOSS) applicatie garandeert NLP digitox volledige transparantie en gebruikerscontrole over hun gegevens.';

  @override
  String get more_details_button => 'Meer details';
}
