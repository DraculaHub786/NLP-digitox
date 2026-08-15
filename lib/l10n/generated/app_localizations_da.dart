// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get mindful_tagline => 'Fokus på det, der virkelig betyder noget';

  @override
  String get unlock_button_label => 'Lås op';

  @override
  String get permission_status_off => 'Fra';

  @override
  String get permission_status_allowed => 'Tilladt';

  @override
  String get permission_status_not_allowed => 'Ikke tilladt';

  @override
  String get permission_button_grant_permission => 'Giv tilladelse';

  @override
  String get permission_button_agree_and_continue => 'Enig & Fortsæt';

  @override
  String get permission_button_not_now => 'Ikke nu';

  @override
  String get permission_button_help => 'Hjælp?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox er 100 % sikker og fungerer offline. Vi indsamler eller opbevarer ingen personlige data.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Klik på knappen $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Vælg NLP digitox på næste skærmbillede.';

  @override
  String get permission_grant_step_three =>
      '3. Klik og tænd for kontakten som nedenfor.';

  @override
  String get permission_notification_title => 'Send meddelelser';

  @override
  String get permission_alarms_title => 'Alarmer og påmindelser';

  @override
  String get permission_alarms_info =>
      'Giv venligst tilladelse til at indstille alarmer og påmindelser. Dette vil give NLP digitox mulighed for at starte din sengetidsplan til tiden og nulstille app-timere dagligt ved midnat og hjælpe dig med at holde styr på sporet.';

  @override
  String get permission_alarms_device_tile_label =>
      'Tillad indstilling af alarmer og påmindelser';

  @override
  String get permission_usage_title => 'Brugsadgang';

  @override
  String get permission_usage_info =>
      'Giv venligst adgangstilladelse til brug. Dette vil give NLP digitox mulighed for at overvåge app-brug og administrere adgang til visse apps, hvilket sikrer et mere fokuseret og kontrolleret digitalt miljø.';

  @override
  String get permission_usage_device_tile_label => 'Tillad brugsadgang';

  @override
  String get permission_overlay_title => 'Display Overlay';

  @override
  String get permission_overlay_info =>
      'Giv venligst tilladelse til at vise overlejring. Dette giver NLP digitox mulighed for at vise en overlejring, når en app, der er sat på pause, åbnes, hvilket hjælper dig med at holde fokus og opretholde din tidsplan.';

  @override
  String get permission_overlay_device_tile_label =>
      'Tillad visning over andre apps';

  @override
  String get permission_accessibility_title => 'Tilgængelighed';

  @override
  String get permission_accessibility_info =>
      'Giv venligst tilgængelighedstilladelse. Dette vil gøre det muligt for NLP digitox at begrænse adgangen til videoindhold i kort format (f.eks. Reels, Shorts) i apps og browsere på sociale medier og filtrere upassende websteder.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox kræver tilgængelighedstilladelse for at blokere kort indhold og websteder effektivt.';

  @override
  String get permission_accessibility_device_tile_label => 'Brug NLP digitox';

  @override
  String get permission_dnd_title => 'Forstyr ikke';

  @override
  String get permission_dnd_info =>
      'Giv venligst Forstyr ikke-adgang. Dette vil tillade NLP digitox at starte og stoppe Forstyr ikke-tilstand under sengetidsplanen.';

  @override
  String get permission_dnd_tile_title => 'Start DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Aktiver også Forstyr ikke-tilstand.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignorer batterioptimering';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Allerede ubegrænset';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Deaktiver baggrundsbegrænsning';

  @override
  String get permission_battery_optimization_allow_info =>
      'Hvis du tillader \'Ignorer batterioptimering\', vil du automatisk give tilladelsen \'Alarmer og påmindelser\' på nogle enheder.';

  @override
  String get permission_vpn_title => 'Opret VPN';

  @override
  String get permission_vpn_info =>
      'Giv venligst tilladelse til at oprette forbindelse til virtuelt privat netværk (VPN). Dette vil gøre det muligt for NLP digitox at begrænse internetadgang for udpegede applikationer ved at oprette lokal VPN på enheden.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Administrative rettigheder er kun nødvendige for væsentlige operationer for at sikre, at appen fungerer korrekt og forbliver manipulationssikker.';

  @override
  String get permission_admin_snack_alert =>
      'Sabotagebeskyttelse kan kun deaktiveres i det valgte tidsvindue.';

  @override
  String get permission_notification_access_title => 'Adgang til meddelelser';

  @override
  String get permission_notification_access_info =>
      'Giv venligst adgangstilladelse til notifikationer. Dette giver NLP digitox mulighed for at organisere dine meddelelser og levere dem efter din tidsplan.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox kræver meddelelsesadgang til batch- og tidsplanmeddelelser.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Tillad meddelelsesadgang';

  @override
  String get day_today => 'I dag';

  @override
  String get day_yesterday => 'I går';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dage',
      one: '1 dag',
      zero: '0 dage',
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
      other: '$countString timer',
      one: '1 time',
      zero: '0 timer',
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
      other: '$countString minutter',
      one: '1 minut',
      zero: '0 minutter',
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
      other: '$countString sekunder',
      one: '1 sekund',
      zero: '0 sekunder',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'og';

  @override
  String get timer_status_active => 'Aktiv';

  @override
  String get timer_status_paused => 'Pause';

  @override
  String get create_button => 'Opret';

  @override
  String get update_button => 'Opdatering';

  @override
  String get dialog_button_cancel => 'Annuller';

  @override
  String get dialog_button_remove => 'Fjern';

  @override
  String get dialog_button_set => 'Sæt';

  @override
  String get dialog_button_reset => 'Nulstil';

  @override
  String get dialog_button_infinite => 'Uendelig';

  @override
  String get schedule_start_label => 'Start';

  @override
  String get schedule_end_label => 'Slut';

  @override
  String get exit_without_saving_dialog_info =>
      'Er du sikker på, at du vil afslutte uden at gemme?';

  @override
  String get development_dialog_info =>
      'NLP digitox er i øjeblikket under udvikling og kan have fejl eller ufuldstændige funktioner. Hvis du støder på problemer, bedes du rapportere dem for at hjælpe os med at blive bedre.\n\nTak for din feedback!';

  @override
  String get development_dialog_button_report_issue => 'Rapportér problem';

  @override
  String get development_dialog_button_close => 'Luk';

  @override
  String get dnd_settings_tile_title => 'Forstyr ikke indstillinger';

  @override
  String get dnd_settings_tile_subtitle =>
      'Administrer, hvilke apps og meddelelser der kan nå dig i DND.';

  @override
  String get quick_actions_heading => 'Hurtige handlinger';

  @override
  String get select_distracting_apps_heading => 'Vælg distraherende apps';

  @override
  String get your_distracting_apps_heading => 'Dine distraherende apps';

  @override
  String get select_more_apps_heading => 'Vælg flere apps';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Tilføjelse af vigtige systemapps til listen over distraherende apps er ikke tilladt.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Skærmbrug og begrænsninger er ikke tilgængelige for denne applikation. På nuværende tidspunkt er det kun netværksbrug, der er tilgængeligt';

  @override
  String get create_group_fab_button => 'Opret gruppe';

  @override
  String get active_period_info =>
      'Indstil en tidsperiode, hvor adgang vil være tilladt. Uden for denne tidsramme vil adgangen være begrænset.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Vælg mindst én distraherende app.';

  @override
  String get donation_card_title => 'Støt os';

  @override
  String get donation_card_info =>
      'NLP digitox er gratis og open source, udviklet med måneders dedikation. Hvis det har hjulpet dig, ville din donation betyde alverden for os. Hvert bidrag hjælper os med at fortsætte med at forbedre og vedligeholde det for alle.';

  @override
  String get operation_failed_snack_alert =>
      'Operation mislykkedes, noget gik galt!';

  @override
  String get donation_card_button_donate => 'Doner';

  @override
  String get app_restart_dialog_title => 'Skal genstartes';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox genstarter automatisk, når nedtællingen er færdig. Vær tålmodig, da ændringerne bliver anvendt.';

  @override
  String get accessibility_tip =>
      'Vil du have smartere og mere batterivenlig blokering? Aktiver tilgængelighedstilladelse for NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox virker ikke? Tillad \"Ignorer batterioptimering\" i Indstillinger for at holde det kørende.';

  @override
  String get invincible_mode_tip =>
      'Fjernet restriktioner ved et uheld? Brug Invincible Mode til at låse dem indtil næste dag eller justering vindue.';

  @override
  String get glance_usage_tip =>
      'Vil du have indsigt? Tjek sektionen Glance for at se dine brugsmønstre og skærmtid.';

  @override
  String get tamper_protection_tip =>
      'Afinstallerer NLP digitox? Aktiver afinstallationsvinduet for sikkert at deaktivere manipulationsbeskyttelse først.';

  @override
  String get notification_blocking_tip =>
      'Vil du reducere distraktioner? Brug meddelelsesblokering til at gøre valgte apps lydløse.';

  @override
  String get usage_history_tip =>
      'Vil du reflektere over dine vaner? Tjek Brugshistorik for at se tidligere mønstre.';

  @override
  String get focus_mode_tip =>
      'Har du brug for dyb fokus? Slå Fokustilstand til for at blokere apps og meddelelser under opgaver.';

  @override
  String get bedtime_reminder_tip =>
      'Vil du forbedre din søvn? Indstil en sengetidspåmindelse til at slappe af hver nat.';

  @override
  String get custom_blocking_tip =>
      'Har du brug for en skræddersyet oplevelse? Opret appblokeringsregler, der passer til dine behov.';

  @override
  String get session_timeline_tip =>
      'Vil du spore fokussessioner? Se tidslinjen for at se din fokusrejse.';

  @override
  String get short_content_blocking_tip =>
      'Distraheret af sociale apps? Bloker kort indhold på Instagram, YouTube osv. for at holde fokus.';

  @override
  String get parental_controls_tip =>
      'Har du brug for forældrekontrol? Indstil begrænsninger for dit barns enhed for at sikre en sikker oplevelse.';

  @override
  String get notification_batching_tip =>
      'Vil du reducere distraktioner? Brug Notification Batching til at gruppere notifikationer og kontrollere dem på én gang.';

  @override
  String get notification_scheduling_tip =>
      'Har du brug for at administrere notifikationer? Planlæg, hvornår du modtager notifikationer for specifikke apps.';

  @override
  String get quick_focus_tile_tip =>
      'Har du brug for hurtig adgang til fokus? Tilføj en Quick Focus Tile for øjeblikkeligt at aktivere Focus Mode.';

  @override
  String get app_shortcuts_tip =>
      'Vil du have øjeblikkelig appadgang? Tilføj genveje ved at trykke længe på app-ikonet for hurtige handlinger.';

  @override
  String get backup_usage_db_tip =>
      'Vil du gemme dine data? Sikkerhedskopier din brugsdatabase for at holde dine optegnelser sikre.';

  @override
  String get dynamic_material_color_tip =>
      'Vil du have et tilpasset tema? Aktiver dynamisk materiale, du farver, så det passer til din enheds tema.';

  @override
  String get amoled_dark_theme_tip =>
      'Vil du spare på batteriet? Brug AMOLED Dark Theme til at reducere strømforbruget på OLED-skærme.';

  @override
  String get customize_usage_history_tip =>
      'Vil du beholde brugshistorikken? Tilpas, hvor mange ugers data der skal gemmes i Brugshistorik.';

  @override
  String get grouped_apps_blocking_tip =>
      'Vil du blokere apps sammen? Brug begrænsningsgrupper til at gruppere appgrænser og blokere flere apps på én gang.';

  @override
  String get websites_blocking_tip =>
      'Vil du have en renere browseroplevelse? Bloker tilpassede eller NSFW-websteder for en mere fokuseret onlinetid.';

  @override
  String get data_usage_tip =>
      'Vil du spore dine data? Overvåg dit mobil- og Wi-Fi-dataforbrug for internetforbrug.';

  @override
  String get block_internet_tip =>
      'Har du brug for at blokere en apps internet? Afbryd internettet for specifik app fra appens dashboard.';

  @override
  String get emergency_passes_tip =>
      'Har du brug for en pause? Brug 3 nødpas dagligt til midlertidigt at fjerne blokeringen af ​​apps i 5 minutter.';

  @override
  String get onboarding_skip_btn_label => 'Spring over';

  @override
  String get onboarding_finish_setup_btn_label => 'Afslut opsætning';

  @override
  String get onboarding_page_welcome_title => 'Velkommen til NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Tag kontrol over dit digitale liv og opbyg sundere skærmvaner. NLP digitox hjælper dig med at forblive fokuseret, minimere distraktioner og træffe bevidste valg hver dag.';

  @override
  String get onboarding_page_statistics_title => 'Kend dine vaner.';

  @override
  String get onboarding_page_statistics_info =>
      'Forstå dine digitale mønstre med detaljerede indsigter om skærmtid, app-brug og fokustendenser. Følg dine fremskridt, og se hvordan små ændringer fører til store forbedringer.';

  @override
  String get onboarding_page_one_title => 'Mesterfokus.';

  @override
  String get onboarding_page_one_info =>
      'Sæt distraherende apps på pause, bloker kort indhold, og hold dig på sporet med tilpassede fokussessioner. Uanset om du arbejder, studerer eller slapper af, hjælper NLP digitox dig med at holde kontrollen.';

  @override
  String get onboarding_page_two_title => 'Bloker distraktioner.';

  @override
  String get onboarding_page_two_info =>
      'Indstil brugsgrænser, sæt apps automatisk på pause, og skab sundere digitale vaner. Brug sengetidstilstand til at slappe af og nyde en distraktionsfri nat.';

  @override
  String get onboarding_page_three_title => 'Privatliv først.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox er 100 % open source og fungerer helt offline. Vi indsamler eller deler ikke dine personlige data - dit privatliv er garanteret på alle måder.';

  @override
  String get onboarding_page_permissions_title => 'Væsentlige tilladelser.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox kræver følgende vigtige tilladelser for at spore og administrere din skærmtid, hvilket hjælper med at reducere distraktioner og forbedre fokus.';

  @override
  String get dashboard_tab_title => 'Dashboard';

  @override
  String get focus_now_fab_button => 'Fokuser nu';

  @override
  String get welcome_greetings => 'Velkommen tilbage,';

  @override
  String get username_snack_alert => 'Tryk længe for at redigere brugernavn.';

  @override
  String get username_dialog_title => 'Brugernavn';

  @override
  String get username_dialog_info =>
      'Indtast dit brugernavn, som vil blive vist på dashboardet.';

  @override
  String get username_dialog_button_apply => 'Ansøg';

  @override
  String get glance_tile_title => 'Blik';

  @override
  String get glance_tile_subtitle => 'Tag et hurtigt blik på dit forbrug.';

  @override
  String get parental_controls_tile_subtitle =>
      'Uovervindelig tilstand og sabotagebeskyttelse.';

  @override
  String get restrictions_heading => 'Begrænsninger';

  @override
  String get apps_blocking_tile_title => 'Apps blokering';

  @override
  String get apps_blocking_tile_subtitle => 'Begræns apps på flere måder.';

  @override
  String get grouped_apps_blocking_tile_title => 'Blokering af grupperede apps';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Begræns gruppe af apps samtidigt.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Begræns kort indhold på flere platforme.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Begræns voksne og tilpassede websteder.';

  @override
  String get screen_time_label => 'Skærmtid';

  @override
  String get total_data_label => 'Samlede data';

  @override
  String get mobile_data_label => 'Mobil data';

  @override
  String get wifi_data_label => 'Wifi data';

  @override
  String get focus_today_label => 'Fokus i dag';

  @override
  String get focus_weekly_label => 'Fokus ugentlig';

  @override
  String get focus_monthly_label => 'Fokus månedligt';

  @override
  String get focus_lifetime_label => 'Fokus levetid';

  @override
  String get longest_streak_label => 'Længste streak';

  @override
  String get current_streak_label => 'Nuværende streak';

  @override
  String get successful_sessions_label => 'Vellykkede sessioner';

  @override
  String get failed_sessions_label => 'Mislykkede sessioner';

  @override
  String get statistics_tab_title => 'Statistik';

  @override
  String get screen_segment_label => 'Skærm';

  @override
  String get data_segment_label => 'Data';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Mest brugte apps';

  @override
  String get show_all_apps_tile_title => 'Vis alle apps';

  @override
  String get search_apps_hint => 'Søg i apps...';

  @override
  String get notifications_tab_title => 'Meddelelser';

  @override
  String get notifications_tab_info =>
      'Batchbesked fra apps og sæt tidsplaner som morgen, middag, aften og nat. Hold dig opdateret uden konstante afbrydelser.';

  @override
  String get batched_apps_tile_title => 'Batchede apps';

  @override
  String get batch_recap_dropdown_title => 'Batch recap type';

  @override
  String get batch_recap_dropdown_info =>
      'Vælg, hvad du vil skubbe, når en tidsplan udløser - alle meddelelser eller blot en oversigt.';

  @override
  String get batch_recap_option_summery_only => 'Kun resumé';

  @override
  String get batch_recap_option_all_notifications => 'Alle meddelelser';

  @override
  String get notification_history_tile_title => 'Notifikationshistorik';

  @override
  String get store_all_tile_title => 'Gem alle meddelelser';

  @override
  String get store_all_tile_subtitle => 'Gem også ikke-batchede meddelelser.';

  @override
  String get schedules_heading => 'Tidsplaner';

  @override
  String get new_schedule_fab_button => 'Nyt skema';

  @override
  String get new_schedule_dialog_info =>
      'Indtast et navn til underretningsplanen for at hjælpe med at identificere den nemt.';

  @override
  String get new_schedule_dialog_field_label => 'Tidsplanens navn';

  @override
  String get bedtime_tab_title => 'Sengetid';

  @override
  String get bedtime_tab_info =>
      'Indstil din sengetidsplan ved at vælge et tidsrum og ugedage. Vælg distraherende apps for at blokere og aktivere tilstanden Forstyr ikke (DND) for en fredelig nat.';

  @override
  String get schedule_tile_title => 'Tidsplan';

  @override
  String get schedule_tile_subtitle =>
      'Aktiver eller deaktiver daglig tidsplan.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Vælg mindst én dag i ugen.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Den samlede sengetid skal være mindst 30 minutter.';

  @override
  String get distracting_apps_tile_title => 'Distraherende apps';

  @override
  String get distracting_apps_tile_subtitle =>
      'Vælg, hvilke apps der distraherer dig fra din sengetidsrutine.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Ændringer af listen over distraherende apps er ikke tilladt, mens sengetidsplanen er aktiv.';

  @override
  String get parental_controls_tab_title => 'Forældrekontrol';

  @override
  String get invincible_mode_heading => 'Uovervindelig tilstand';

  @override
  String get invincible_mode_tile_title => 'Aktiver uovervindelig tilstand';

  @override
  String get invincible_mode_info =>
      'Når Invincible Mode er slået til, vil du ikke være i stand til at justere valgte grænser, efter at du har nået din daglige kvote. Du kan dog foretage ændringer inden for et udvalgt 10-minutters uovervindeligt vindue.';

  @override
  String get invincible_mode_snack_alert =>
      'På grund af uovervindelig tilstand er ændringer af restriktioner ikke tilladt.';

  @override
  String get invincible_mode_dialog_info =>
      'Er du helt sikker på, at du vil aktivere Invincible Mode? Denne handling er irreversibel. Når Invincible Mode er slået til, kan du ikke slå den fra, så længe denne app er installeret på din enhed.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Mode kan ikke slås fra, så længe denne app forbliver installeret på din enhed.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Start alligevel';

  @override
  String get invincible_mode_include_timer_tile_title => 'Inkluder timer';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Inkluder lanceringsgrænse';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Inkluder aktiv periode';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'App-begrænsninger';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Undgå ændringer af appens valgte begrænsninger, når de daglige grænser er overskredet.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Gruppebegrænsninger';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Undgå ændringer af gruppens valgte begrænsninger, når de daglige grænser er overskredet.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Inkluder shorts timer';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Forhindrer ændringer efter at have nået din daglige shorts-grænse.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Inkluder sengetid';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Forhindrer ændringer under den aktive sengetidsplan.';

  @override
  String get protected_access_tile_title => 'Beskyttet adgang';

  @override
  String get protected_access_tile_subtitle =>
      'Beskyt NLP digitox med din enhedslås.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Opsæt en biometrisk lås på din enhed først for at aktivere denne funktion.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Din enhedslås er blevet fjernet. For at fortsætte skal du konfigurere en ny lås.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Godkendelse mislykkedes. Du skal bekræfte din enhedslås for at fortsætte.';

  @override
  String get tamper_protection_tile_title => 'Sabotagebeskyttelse';

  @override
  String get tamper_protection_tile_subtitle =>
      'Forhindre afinstallation og tvinge standsning af appen.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Når det er aktiveret, vil du ikke være i stand til at afinstallere, tvinge stop eller rydde NLP digitox\'s data, undtagen under det valgte afinstallationsvindue. Der er ingen løsninger.\n\nFortsæt på egen risiko.';

  @override
  String get uninstall_window_tile_title => 'Afinstaller vinduet';

  @override
  String get uninstall_window_tile_subtitle =>
      'Sabotagebeskyttelse kan deaktiveres inden for 10 minutter fra det valgte tidspunkt.';

  @override
  String get invincible_window_tile_title => 'Uovervindeligt vindue';

  @override
  String get invincible_window_tile_subtitle =>
      'Valgte grænser kan ændres inden for 10 minutter fra det valgte tidspunkt.';

  @override
  String get shorts_blocking_tab_title => 'Shorts blokerer';

  @override
  String get shorts_blocking_tab_info =>
      'Styr, hvor meget tid du bruger på kort indhold på tværs af platforme som Instagram, YouTube, Snapchat og Facebook, inklusive deres websteder.';

  @override
  String get short_content_heading => 'Kort indhold';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Venstre fra $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Indstil en daglig tidsgrænse for kort indhold. Når din grænse er nået, vil det korte indhold blive sat på pause indtil midnat.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Begræns funktioner på instagram.';

  @override
  String get instagram_features_block_reels => 'Begræns hjulsektionen.';

  @override
  String get instagram_features_block_explore => 'Begræns Udforsk sektion.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Begræns funktioner på snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Begræns spotlight-sektionen.';

  @override
  String get snapchat_features_block_discover => 'Begræns opdagelsessektionen.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle => 'Begræns shorts på youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Begræns ruller på facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Begræns shorts på reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Begræns videofeed på X.';

  @override
  String get threads_features_tile_title => 'Tråde';

  @override
  String get threads_features_tile_subtitle => 'Begræns video/ruller på tråde.';

  @override
  String get websites_blocking_tab_title => 'Blokering af websteder';

  @override
  String get websites_blocking_tab_info =>
      'Bloker voksenwebsteder og eventuelle tilpassede websteder, du vælger for at skabe en sikrere og mere fokuseret onlineoplevelse. Tag ansvaret for din browsing og forbliv distraktionsfri.';

  @override
  String get adult_content_heading => 'Voksenindhold';

  @override
  String get block_nsfw_title => 'Bloker Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Begræns browsere fra at åbne voksen- og pornowebsteder.';

  @override
  String get block_nsfw_dialog_info =>
      'Er du sikker? Denne handling er irreversibel. Når blokering af voksenwebsteder er slået TIL, kan du ikke slå den FRA, så længe denne app er installeret på din enhed.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Bloker alligevel';

  @override
  String get blocked_websites_heading => 'Blokerede hjemmesider';

  @override
  String get blocked_websites_empty_list_hint =>
      'Klik på knappen \'+ Tilføj websted\' for at tilføje distraherende websteder, som du ønsker at blokere.';

  @override
  String get add_website_fab_button => 'Tilføj hjemmeside';

  @override
  String get add_website_dialog_title => 'Distraherende hjemmeside';

  @override
  String get add_website_dialog_info =>
      'Indtast url på et websted, som du vil blokere.';

  @override
  String get add_website_dialog_is_nsfw => 'Er nsfw websted?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Advarsel: Nsfw-websteder kan ikke fjernes, når først de er tilføjet.';

  @override
  String get add_website_dialog_button_block => 'Bloker';

  @override
  String get add_website_already_exist_snack_alert =>
      'URL\'en er allerede blevet tilføjet til listen over blokerede websteder.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Ugyldig URL! Kan ikke parse værtsnavnet.';

  @override
  String get remove_website_dialog_title => 'Fjern hjemmesiden';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Er du sikker? du vil fjerne \'$websitehost\' fra blokerede websteder.';
  }

  @override
  String get focus_tab_title => 'Fokus';

  @override
  String get focus_tab_info =>
      'Når du har brug for tid til at fokusere, skal du starte en ny session ved at vælge typen, vælge distraherende apps til pause og aktivere Forstyr ikke for uafbrudt koncentration.';

  @override
  String get active_session_card_title => 'Aktiv session';

  @override
  String get active_session_card_info =>
      'Du har en aktiv fokussession kørende! Klik på \'Vis\' for at tjekke dine fremskridt og se, hvor lang tid der er gået.';

  @override
  String get active_session_card_view_button => 'Visning';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Fjernelse af apps fra listen over distraherende apps er ikke tilladt, mens en fokussession er aktiv. Du kan dog stadig tilføje yderligere apps til listen i løbet af denne tid.';

  @override
  String get focus_profile_tile_title => 'Fokus profil';

  @override
  String get focus_session_duration_tile_title => 'Sessionens varighed';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Uendelig (medmindre du stopper)';

  @override
  String get focus_session_duration_dialog_info =>
      'Vælg venligst den ønskede varighed for denne fokussession, for at bestemme, hvor længe du ønsker at forblive fokuseret og uden distraktion.';

  @override
  String get focus_profile_customization_tile_title => 'Tilpasning af profil';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Tilpas indstillinger for den valgte profil.';

  @override
  String get focus_enforce_tile_title => 'Håndhæve session';

  @override
  String get focus_enforce_tile_subtitle =>
      'Forhindrer at afslutte en session før tiden slutter.';

  @override
  String get focus_session_start_button => 'Stryg for at starte session';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Vælg mindst én distraherende app for at starte fokussession';

  @override
  String get focus_session_already_active_snack_alert =>
      'Du har allerede en aktiv fokussession kørende. Udfyld eller stop din nuværende session, før du starter en ny.';

  @override
  String get focus_session_type_study => 'Studie';

  @override
  String get focus_session_type_work => 'Arbejde';

  @override
  String get focus_session_type_exercise => 'Motion';

  @override
  String get focus_session_type_meditation => 'Meditation';

  @override
  String get focus_session_type_creativeWriting => 'Kreativ skrivning';

  @override
  String get focus_session_type_reading => 'Læsning';

  @override
  String get focus_session_type_programming => 'Programmering';

  @override
  String get focus_session_type_chores => 'gøremål';

  @override
  String get focus_session_type_projectPlanning => 'Projektplanlægning';

  @override
  String get focus_session_type_artAndDesign => 'Kunst og design';

  @override
  String get focus_session_type_languageLearning => 'Sprogindlæring';

  @override
  String get focus_session_type_musicPractice => 'Musikpraksis';

  @override
  String get focus_session_type_selfCare => 'Selvpleje';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Færdighedsudvikling';

  @override
  String get focus_session_type_research => 'Forskning';

  @override
  String get focus_session_type_networking => 'Netværk';

  @override
  String get focus_session_type_cooking => 'Madlavning';

  @override
  String get focus_session_type_sportsTraining => 'Sportstræning';

  @override
  String get focus_session_type_restAndRelaxation => 'Hvile og afslapning';

  @override
  String get focus_session_type_other => 'Andet';

  @override
  String get timeline_tab_title => 'Tidslinje';

  @override
  String get focus_timeline_tab_info =>
      'Udforsk din fokusrejse ved at vælge en dato fra kalenderen. Følg dine fremskridt, gense dine succeser, og lær af udfordringerne.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Din samlede produktive tid for den valgte måned er $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktive dage';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Du har i alt haft $daysCount produktive dage i den valgte måned.';
  }

  @override
  String get selected_day_focused_time_label => 'Fokuseret tid';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Din samlede fokuserede tid for den valgte dag er $timeString.';
  }

  @override
  String get calender_heading => 'Kalender';

  @override
  String get your_sessions_heading => 'Dine sessioner';

  @override
  String get your_sessions_empty_list_hint =>
      'Der er ikke optaget fokussessioner for den valgte dag.';

  @override
  String get focus_session_tile_timestamp_label => 'Tidsstempel';

  @override
  String get focus_session_tile_duration_label => 'Varighed';

  @override
  String get focus_session_tile_reflection_label => 'Refleksion';

  @override
  String get focus_session_state_active => 'Aktiv';

  @override
  String get focus_session_state_successful => 'Vellykket';

  @override
  String get focus_session_state_failed => 'Mislykkedes';

  @override
  String get active_session_tab_title => 'Session';

  @override
  String get active_session_none_warning =>
      'Ingen aktiv session fundet. Vender tilbage til startskærmen.';

  @override
  String get active_session_dialog_button_keep_pushing =>
      'Bliv ved med at skubbe';

  @override
  String get active_session_finish_dialog_title => 'Afslut';

  @override
  String get active_session_finish_dialog_info =>
      'Bliv stærk! Du opbygger værdifuldt fokus. Er du sikker på, at du vil afslutte denne fokussession? Hvert ekstra øjeblik tæller mod dine mål.';

  @override
  String get active_session_giveup_dialog_title => 'Giv op';

  @override
  String get active_session_giveup_dialog_info =>
      'Hold fast! Du er der næsten, giv ikke op nu! Er du sikker på, at du vil afslutte denne fokussession tidligt? Fremskridt vil gå tabt.';

  @override
  String get active_session_reflection_dialog_title => 'Sessionsrefleksion';

  @override
  String get active_session_reflection_dialog_info =>
      'Brug et øjeblik på at reflektere over dine fremskridt. Hvad er dit mål for denne session? Hvad opnåede du under denne session?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tip: Du kan altid redigere dette senere på sessionens tidslinje.';

  @override
  String get active_session_giveup_snack_alert =>
      'Du gav op! Bare rolig, du kan gøre det bedre næste gang. Hver indsats tæller - bare fortsæt';

  @override
  String get active_session_quote_one =>
      'Hvert skridt tæller, vær stærk og fortsæt';

  @override
  String get active_session_quote_two =>
      'Hold fokus! du gør fantastiske fremskridt';

  @override
  String get active_session_quote_three =>
      'Du knuser det! Hold momentum i gang';

  @override
  String get active_session_quote_four =>
      'Bare lidt mere tilbage, du gør det fantastisk';

  @override
  String active_session_quote_five(String durationString) {
    return 'Tillykke 🎉 \n Du har gennemført din fokussession med $durationString.\n\nFantastisk arbejde, fortsæt det fantastiske arbejde';
  }

  @override
  String get restriction_groups_tab_title => 'Restriktionsgrupper';

  @override
  String get restriction_groups_tab_info =>
      'Indstil en kombineret skærmtidsgrænse for en gruppe apps. Når det samlede forbrug når din grænse, vil alle apps i gruppen blive sat på pause for at hjælpe med at bevare fokus og balance.';

  @override
  String get restriction_group_time_spent_label => 'Tid brugt i dag';

  @override
  String get restriction_group_time_left_label => 'Tid tilbage i dag';

  @override
  String get restriction_group_name_tile_title => 'Gruppenavn';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Indtast et navn til begrænsningsgruppen for nemt at identificere og administrere den.';

  @override
  String get restriction_group_timer_tile_title => 'Gruppetimer';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Indstil en daglig tidsgrænse for denne gruppe. Når din grænse er nået, vil alle apps i denne gruppe blive sat på pause indtil midnat.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Gruppe aktiv periode';

  @override
  String get remove_restriction_group_dialog_title => 'Fjern gruppe';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Er du sikker? du vil fjerne \'$groupName\' fra begrænsningsgrupper.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Indstil enten en timer eller en aktiv periodegrænse.';

  @override
  String get notifications_empty_list_hint =>
      'Ingen notifikationer er blevet samlet for dagen.';

  @override
  String get conversations_label => 'Samtaler';

  @override
  String get last_24_hours_heading => 'Sidste 24 timer';

  @override
  String get notification_timeline_tab_info =>
      'Gennemse din notifikationshistorik ved at vælge en dato fra kalenderen. Se hvilke apps, der fangede din opmærksomhed, og reflekter over dine digitale vaner.';

  @override
  String get monthly_label => 'Månedligt';

  @override
  String get daily_label => 'Dagligt';

  @override
  String get search_notifications_sheet_info =>
      'Find nemt tidligere meddelelser ved at søge gennem deres titel eller indhold. Hjælper dig med hurtigt at finde vigtige advarsler.';

  @override
  String get search_notifications_hint => 'Søg underretninger...';

  @override
  String get search_notifications_empty_list_hint =>
      'Der blev ikke fundet nogen notifikationer, der matcher din søgning.';

  @override
  String get app_info_none_warning =>
      'Kunne ikke finde appen til den givne pakke. Vender tilbage til startskærmen.';

  @override
  String get emergency_fab_button => 'Nødsituation';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Denne handling vil sætte app-blokeringen på pause i de næste 5 minutter. Du har $leftPassesCount-pas tilbage. Efter at have brugt alle pas, forbliver appen blokeret indtil midnat, eller den aktive fokussession slutter.\n\nVil du stadig fortsætte?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Brug alligevel';

  @override
  String get emergency_started_snack_alert =>
      'App-blokeringen er sat på pause og genoptager blokeringen om 5 minutter.';

  @override
  String get emergency_already_active_snack_alert =>
      'App-blokeringen er i øjeblikket enten sat på pause eller inaktiv. Hvis notifikationer er aktiveret, vil du modtage opdateringer vedrørende den resterende tid.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Du har brugt alle dine nødpas. De blokerede apps forbliver blokeret indtil midnat, eller den aktive fokussession slutter.';

  @override
  String get app_limit_status_not_set => 'Ikke indstillet';

  @override
  String get app_timer_tile_title => 'App timer';

  @override
  String get app_timer_picker_dialog_info =>
      'Indstil en daglig tidsgrænse for denne app. Når din grænse er nået, sættes appen på pause indtil midnat.';

  @override
  String get usage_reminders_tile_title => 'Brugspåmindelser';

  @override
  String get usage_reminders_tile_subtitle =>
      'Blide skub ved brug af tidsindstillede apps.';

  @override
  String get app_launch_limit_tile_title => 'Startgrænse';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Lanceret $count gange i dag.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Indstil, hvor mange gange du kan åbne denne app hver dag. Når grænsen er nået, vil den blive sat på pause indtil midnat.';

  @override
  String get app_active_period_tile_title => 'Aktiv periode';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Fra $startTime til $endTime';
  }

  @override
  String get internet_access_tile_title => 'Internetadgang';

  @override
  String get internet_access_tile_subtitle =>
      'Sluk for at blokere appens internet.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '$appName\'s internet er blokeret.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '$appName\'s internet er ophævet.';
  }

  @override
  String get launch_app_tile_title => 'Start app';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Åbn $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Gå til appindstillinger';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Administrer appindstillinger som meddelelser, tilladelser, lagring og mere.';

  @override
  String get include_in_stats_tile_title => 'Inkluder i skærmbrug';

  @override
  String get include_in_stats_tile_subtitle =>
      'Sluk for at udelukke denne app fra det samlede skærmbrug.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName er udelukket fra det samlede skærmbrug.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName er inkluderet for det samlede skærmforbrug.';
  }

  @override
  String get general_tab_title => 'Generelt';

  @override
  String get appearance_heading => 'Udseende';

  @override
  String get theme_mode_tile_title => 'Tematilstand';

  @override
  String get theme_mode_system_label => 'System';

  @override
  String get theme_mode_light_label => 'Lys';

  @override
  String get theme_mode_dark_label => 'Mørk';

  @override
  String get material_color_tile_title => 'Materiale farve';

  @override
  String get amoled_dark_tile_title => 'AMOLED mørk';

  @override
  String get amoled_dark_tile_subtitle =>
      'Brug ren sort farve til det mørke tema.';

  @override
  String get dynamic_colors_tile_title => 'Dynamiske farver';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Brug enhedsfarver, hvis de understøttes.';

  @override
  String get defaults_heading => 'Standarder';

  @override
  String get app_language_tile_title => 'App sprog';

  @override
  String get default_home_tab_tile_title => 'Fanen Hjem';

  @override
  String get usage_history_tile_title => 'Brugshistorik';

  @override
  String get usage_history_15_days => '15 dage';

  @override
  String get usage_history_1_month => '1 måned';

  @override
  String get usage_history_3_month => '3 måneder';

  @override
  String get usage_history_6_month => '6 måneder';

  @override
  String get usage_history_1_year => '1 år';

  @override
  String get service_heading => 'Service';

  @override
  String get service_stopping_warning =>
      'Hvis NLP digitox stopper med at fungere uventet, skal du give tilladelsen \'Ignorer batterioptimering\' for at holde den kørende i baggrunden. Hvis problemet fortsætter, kan du prøve at hvidliste NLP digitox for uafbrudt ydeevne.';

  @override
  String get whitelist_app_tile_title => 'Hvidliste NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Tillad NLP digitox at starte automatisk.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Denne enhed understøtter ikke automatisk opstartsadministration.';

  @override
  String get database_tab_title => 'Database';

  @override
  String get import_db_tile_title => 'Importer database';

  @override
  String get import_db_tile_subtitle => 'Importer database fra en fil.';

  @override
  String get export_db_tile_title => 'Eksporter database';

  @override
  String get export_db_tile_subtitle => 'Eksporter database til en fil.';

  @override
  String get analysis_tab_title => 'Analyse';

  @override
  String get analysis_7_days => '7 dage';

  @override
  String get analysis_30_days => '30 dage';

  @override
  String get analysis_90_days => '90 dage';

  @override
  String get analysis_screen_time_trend => 'Skærmtidstendens';

  @override
  String get analysis_no_data_info =>
      'Ingen skærmtidsdata er endnu registreret for denne periode.';

  @override
  String get analysis_daily_average => 'Dagligt gennemsnit';

  @override
  String get analysis_total => 'I alt';

  @override
  String get analysis_no_change => 'Samme som sidste uge';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% mindre end sidste uge';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% mere end sidste uge';
  }

  @override
  String get crash_logs_heading => 'Crash logs';

  @override
  String get crash_logs_info =>
      'Hvis du støder på et problem, kan du rapportere det på GitHub sammen med logfilen. Filen vil indeholde detaljer såsom din enheds producent, model, Android-version, SDK-version og nedbrudslogfiler. Disse oplysninger hjælper os med at identificere og løse problemet mere effektivt.';

  @override
  String get crash_logs_export_tile_title => 'Eksporter crashlogs';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Eksporter nedbrudslogfiler til en json-fil.';

  @override
  String get crash_logs_view_tile_title => 'Se logfiler';

  @override
  String get crash_logs_view_tile_subtitle => 'Udforsk lagrede crashlogs.';

  @override
  String get crash_logs_empty_list_hint => 'Ingen crash logget indtil nu.';

  @override
  String get crash_logs_clear_tile_title => 'Ryd logfiler';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Slet alle nedbrudslogfiler fra databasen.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Er du sikker på, at du vil rydde alle nedbrudslogfiler fra databasen?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Klar alligevel';

  @override
  String get about_tab_title => 'Om';

  @override
  String get changelog_tile_title => 'Ændringslog';

  @override
  String get changelog_tile_subtitle => 'Find ud af, hvad der er nyt.';

  @override
  String get full_changelog_tile_title => 'Fuld ændringslog';

  @override
  String get redirected_to_github_subtitle =>
      'Du vil blive omdirigeret til GitHub.';

  @override
  String get contribute_heading => 'Bidrag';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Se kildekoden.';

  @override
  String get report_issue_tile_title => 'Rapporter et problem';

  @override
  String get suggest_idea_tile_title => 'Foreslå en idé';

  @override
  String get write_email_tile_title => 'Skriv til os via e-mail';

  @override
  String get write_email_tile_subtitle =>
      'Du vil blive omdirigeret til e-mail-appen.';

  @override
  String get privacy_policy_heading => 'Privatlivspolitik';

  @override
  String get privacy_policy_info =>
      'NLP digitox er forpligtet til at beskytte dit privatliv. Vi indsamler, opbevarer eller overfører ikke nogen form for brugerdata. Appen fungerer helt offline og kræver ikke en internetforbindelse, hvilket sikrer, at dine personlige oplysninger forbliver private og sikre på din enhed. NLP digitox garanterer fuldstændig gennemsigtighed og brugerkontrol over deres data, som en gratis og åben kildesoftware (FOSS) applikation.';

  @override
  String get more_details_button => 'Flere detaljer';
}
