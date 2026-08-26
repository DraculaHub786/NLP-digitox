// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get mindful_tagline => 'Fokuser på det som virkelig betyr noe';

  @override
  String get unlock_button_label => 'Lås opp';

  @override
  String get permission_status_off => 'Av';

  @override
  String get permission_status_allowed => 'Tillatt';

  @override
  String get permission_status_not_allowed => 'Ikke tillatt';

  @override
  String get permission_button_grant_permission => 'Gi tillatelse';

  @override
  String get permission_button_agree_and_continue => 'Enig og fortsett';

  @override
  String get permission_button_not_now => 'Ikke nå';

  @override
  String get permission_button_help => 'Hjelp?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox er 100 % sikker og fungerer offline. Vi samler eller lagrer ingen personopplysninger.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Klikk på $button_label-knappen.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Velg NLP digitox i neste skjermbilde.';

  @override
  String get permission_grant_step_three =>
      '3. Klikk og slå på bryteren som nedenfor.';

  @override
  String get permission_notification_title => 'Send varsler';

  @override
  String get permission_alarms_title => 'Alarmer og påminnelser';

  @override
  String get permission_alarms_info =>
      'Gi tillatelse til å stille inn alarmer og påminnelser. Dette vil tillate NLP digitox å starte sengetidsplanen din i tide og tilbakestille app-tidtakere daglig ved midnatt og hjelpe deg med å holde deg på sporet.';

  @override
  String get permission_alarms_device_tile_label =>
      'Tillat innstilling av alarmer og påminnelser';

  @override
  String get permission_usage_title => 'Brukstilgang';

  @override
  String get permission_usage_info =>
      'Gi tilgangstillatelse for bruk. Dette vil tillate NLP digitox å overvåke appbruk og administrere tilgang til visse apper, og sikre et mer fokusert og kontrollert digitalt miljø.';

  @override
  String get permission_usage_device_tile_label => 'Tillat brukstilgang';

  @override
  String get permission_overlay_title => 'Vis overlegg';

  @override
  String get permission_overlay_info =>
      'Gi tillatelse til å vise overlegg. Dette vil tillate NLP digitox å vise et overlegg når en midlertidig stoppet app åpnes, noe som hjelper deg å holde fokus og opprettholde tidsplanen din.';

  @override
  String get permission_overlay_device_tile_label =>
      'Tillat visning over andre apper';

  @override
  String get permission_accessibility_title => 'Tilgjengelighet';

  @override
  String get permission_accessibility_info =>
      'Gi tilgangstillatelse. Dette vil tillate NLP digitox å begrense tilgangen til kortformat videoinnhold (f.eks. Reels, Shorts) i sosiale medier-apper og nettlesere, og filtrere upassende nettsteder.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox krever tilgjengelighetstillatelse for å blokkere kort innhold og nettsteder effektivt.';

  @override
  String get permission_accessibility_device_tile_label => 'Bruk NLP digitox';

  @override
  String get permission_dnd_title => 'Ikke forstyrr';

  @override
  String get permission_dnd_info =>
      'Gi Ikke forstyrr-tilgang. Dette vil tillate NLP digitox å starte og stoppe Ikke forstyrr-modus under sengetidsplanen.';

  @override
  String get permission_dnd_tile_title => 'Start DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Aktiver også Ikke forstyrr-modus.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignorer batterioptimalisering';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Allerede ubegrenset';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Deaktiver bakgrunnsbegrensning';

  @override
  String get permission_battery_optimization_allow_info =>
      'Å tillate \"Ignorer batterioptimalisering\" vil automatisk gi tillatelsen \"Alarmer og påminnelser\" på enkelte enheter.';

  @override
  String get permission_vpn_title => 'Opprett VPN';

  @override
  String get permission_vpn_info =>
      'Gi tillatelse til å opprette VPN-tilkobling (virtuelt privat nettverk). Dette vil gjøre det mulig for NLP digitox å begrense internettilgang for utpekte applikasjoner ved å opprette lokal VPN på enheten.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Administrative rettigheter er kun nødvendig for viktige operasjoner for å sikre at appen fungerer som den skal og forblir manipulasjonssikker.';

  @override
  String get permission_admin_snack_alert =>
      'Sabotasjebeskyttelse kan bare deaktiveres i det valgte tidsvinduet.';

  @override
  String get permission_notification_access_title => 'Varslingstilgang';

  @override
  String get permission_notification_access_info =>
      'Gi tilgangstillatelse for varsler. Dette vil tillate NLP digitox å organisere varslene dine og levere dem i henhold til timeplanen din.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox krever varslingstilgang til batch- og tidsplanvarsler.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Tillat varslingstilgang';

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
      other: '$countString dager',
      one: '1 dag',
      zero: '0 dager',
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
      one: '1 minutt',
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
  String get create_button => 'Opprett';

  @override
  String get update_button => 'Oppdater';

  @override
  String get dialog_button_cancel => 'Avbryt';

  @override
  String get dialog_button_remove => 'Fjern';

  @override
  String get dialog_button_set => 'Sett';

  @override
  String get dialog_button_reset => 'Tilbakestill';

  @override
  String get dialog_button_infinite => 'Uendelig';

  @override
  String get schedule_start_label => 'Start';

  @override
  String get schedule_end_label => 'Slutt';

  @override
  String get exit_without_saving_dialog_info =>
      'Er du sikker på at du vil avslutte uten å lagre?';

  @override
  String get development_dialog_info =>
      'NLP digitox er for tiden under utvikling og kan ha feil eller ufullstendige funksjoner. Hvis du støter på problemer, vennligst rapporter dem for å hjelpe oss med å forbedre oss.\n\nTakk for tilbakemeldingen din!';

  @override
  String get development_dialog_button_report_issue => 'Rapporter problem';

  @override
  String get development_dialog_button_close => 'Lukk';

  @override
  String get dnd_settings_tile_title => 'Ikke forstyrr innstillingene';

  @override
  String get dnd_settings_tile_subtitle =>
      'Administrer hvilke apper og varsler som kan nå deg i DND.';

  @override
  String get quick_actions_heading => 'Raske handlinger';

  @override
  String get select_distracting_apps_heading => 'Velg distraherende apper';

  @override
  String get your_distracting_apps_heading => 'Dine distraherende apper';

  @override
  String get select_more_apps_heading => 'Velg flere apper';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Det er ikke tillatt å legge til viktige systemapper i listen over distraherende apper.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Skjermbruk og begrensninger er utilgjengelige for denne applikasjonen. Foreløpig er det bare nettverksbruk som er tilgjengelig';

  @override
  String get create_group_fab_button => 'Opprett gruppe';

  @override
  String get active_period_info =>
      'Angi en tidsperiode som tilgang skal tillates. Utenfor denne tidsrammen vil tilgangen være begrenset.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Velg minst én distraherende app.';

  @override
  String get donation_card_title => 'Støtt oss';

  @override
  String get donation_card_info =>
      'NLP digitox er gratis og åpen kildekode, utviklet med måneders dedikasjon. Hvis det har hjulpet deg, vil donasjonen din bety all verden for oss. Hvert bidrag hjelper oss å fortsette å forbedre og vedlikeholde det for alle.';

  @override
  String get operation_failed_snack_alert =>
      'Operasjonen mislyktes, noe gikk galt!';

  @override
  String get donation_card_button_donate => 'Doner';

  @override
  String get app_restart_dialog_title => 'Trenger omstart';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox starter automatisk på nytt når nedtellingen er ferdig. Vær tålmodig mens endringer tas i bruk.';

  @override
  String get accessibility_tip =>
      'Vil du ha smartere, mer batterivennlig blokkering? Aktiver tilgjengelighetstillatelse for NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox fungerer ikke? Tillat \"Ignorer batterioptimalisering\" i Innstillinger for å holde den kjører jevnt.';

  @override
  String get invincible_mode_tip =>
      'Fjernet restriksjoner ved et uhell? Bruk Invincible Mode for å låse dem til neste dag eller til neste justeringsvindu.';

  @override
  String get glance_usage_tip =>
      'Vil du ha innsikt? Sjekk Glance-delen for å se dine bruksmønstre og skjermtid.';

  @override
  String get tamper_protection_tip =>
      'Avinstallerer du NLP digitox? Aktiver avinstalleringsvinduet for å trygt deaktivere sabotasjebeskyttelsen først.';

  @override
  String get notification_blocking_tip =>
      'Vil du redusere distraksjoner? Bruk varslingsblokkering for å dempe valgte apper.';

  @override
  String get usage_history_tip =>
      'Vil du reflektere over vanene dine? Sjekk Brukshistorikk for å se tidligere mønstre.';

  @override
  String get focus_mode_tip =>
      'Trenger du dypt fokus? Slå på fokusmodus for å blokkere apper og varsler under oppgaver.';

  @override
  String get bedtime_reminder_tip =>
      'Vil du forbedre søvnen din? Still inn en sengetidspåminnelse for å slappe av hver natt.';

  @override
  String get custom_blocking_tip =>
      'Trenger du en tilpasset opplevelse? Lag appblokkeringsregler som passer dine behov.';

  @override
  String get session_timeline_tip =>
      'Vil du spore fokusøkter? Se tidslinjen for å se fokusreisen din.';

  @override
  String get short_content_blocking_tip =>
      'Distrahert av sosiale apper? Blokker kort innhold på Instagram, YouTube, etc., for å holde fokus.';

  @override
  String get parental_controls_tip =>
      'Trenger du foreldrekontroll? Angi begrensninger for barnets enhet for å sikre en trygg opplevelse.';

  @override
  String get notification_batching_tip =>
      'Vil du redusere distraksjoner? Bruk Notification Batching for å gruppere varsler og sjekke dem med en gang.';

  @override
  String get notification_scheduling_tip =>
      'Trenger du å administrere varsler? Planlegg når du mottar varsler for bestemte apper.';

  @override
  String get quick_focus_tile_tip =>
      'Trenger du rask tilgang til fokus? Legg til en hurtigfokusflis for å aktivere fokusmodus umiddelbart.';

  @override
  String get app_shortcuts_tip =>
      'Vil du ha umiddelbar app-tilgang? Legg til snarveier ved å trykke lenge på appikonet for raske handlinger.';

  @override
  String get backup_usage_db_tip =>
      'Vil du lagre dataene dine? Sikkerhetskopier bruksdatabasen for å holde journalene dine trygge.';

  @override
  String get dynamic_material_color_tip =>
      'Vil du ha et tilpasset tema? Aktiver dynamisk materiale Du farger for å matche enhetens tema.';

  @override
  String get amoled_dark_theme_tip =>
      'Vil du spare batteri? Bruk AMOLED Dark Theme for å redusere strømforbruket på OLED-skjermer.';

  @override
  String get customize_usage_history_tip =>
      'Vil du beholde brukshistorikken? Tilpass hvor mange uker med data som skal lagres i bruksloggen.';

  @override
  String get grouped_apps_blocking_tip =>
      'Vil du blokkere apper sammen? Bruk restriksjonsgrupper for å gruppere appgrenser og blokkere flere apper samtidig.';

  @override
  String get websites_blocking_tip =>
      'Vil du ha en renere nettleseropplevelse? Blokker egendefinerte eller NSFW-nettsteder for en mer fokusert online tid.';

  @override
  String get data_usage_tip =>
      'Vil du spore dataene dine? Overvåk mobil- og Wi-Fi-databruken din for internettforbruk.';

  @override
  String get block_internet_tip =>
      'Trenger du å blokkere internett til en app? Kutt av internett for spesifikk app fra appens dashbord.';

  @override
  String get emergency_passes_tip =>
      'Trenger du en pause? Bruk 3 nødpass daglig for å oppheve blokkeringen av apper midlertidig i 5 minutter.';

  @override
  String get onboarding_skip_btn_label => 'Hopp over';

  @override
  String get onboarding_finish_setup_btn_label => 'Fullfør oppsettet';

  @override
  String get onboarding_page_welcome_title => 'Velkommen til NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Ta kontroll over ditt digitale liv og bygg sunnere skjermvaner. NLP digitox hjelper deg med å holde fokus, redusere distraksjoner og ta bevisste valg hver dag.';

  @override
  String get onboarding_page_statistics_title => 'Kjenn dine vaner.';

  @override
  String get onboarding_page_statistics_info =>
      'Forstå dine digitale mønstre med detaljert innsikt i skjermtid, app-bruk og fokustrender. Følg fremgangen din og se hvordan små endringer fører til store forbedringer.';

  @override
  String get onboarding_page_one_title => 'Mesterfokus.';

  @override
  String get onboarding_page_one_info =>
      'Sett distraherende apper på pause, blokker kort innhold og hold deg på sporet med tilpassbare fokusøkter. Enten du jobber, studerer eller slapper av, hjelper NLP digitox deg med å ha kontroll.';

  @override
  String get onboarding_page_two_title => 'Blokker distraksjoner.';

  @override
  String get onboarding_page_two_info =>
      'Angi bruksgrenser, pause apper automatisk og lag sunnere digitale vaner. Bruk sengetidsmodus for å slappe av og nyte en natt uten forstyrrelser.';

  @override
  String get onboarding_page_three_title => 'Personvern først.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox er 100 % åpen kildekode og opererer helt offline. Vi samler ikke inn eller deler dine personlige data – personvernet ditt er garantert på alle måter.';

  @override
  String get onboarding_page_permissions_title => 'Viktige tillatelser.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox krever følgende viktige tillatelser for å spore og administrere skjermtiden din, noe som bidrar til å redusere distraksjoner og forbedre fokus.';

  @override
  String get dashboard_tab_title => 'Dashbord';

  @override
  String get focus_now_fab_button => 'Fokuser nå';

  @override
  String get welcome_greetings => 'Velkommen tilbake,';

  @override
  String get username_snack_alert => 'Langt trykk for å redigere brukernavn.';

  @override
  String get username_dialog_title => 'Brukernavn';

  @override
  String get username_dialog_info =>
      'Skriv inn brukernavnet ditt som vil vises på dashbordet.';

  @override
  String get username_dialog_button_apply => 'Søk';

  @override
  String get glance_tile_title => 'Blikk';

  @override
  String get glance_tile_subtitle => 'Ta et raskt blikk på bruken din.';

  @override
  String get parental_controls_tile_subtitle =>
      'Uovervinnelig modus og sabotasjebeskyttelse.';

  @override
  String get restrictions_heading => 'Restriksjoner';

  @override
  String get apps_blocking_tile_title => 'Apper blokkerer';

  @override
  String get apps_blocking_tile_subtitle => 'Begrens apper på flere måter.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Blokkering av grupperte apper';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Begrens gruppe apper samtidig.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Begrens kort innhold på flere plattformer.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Begrens voksne og tilpassede nettsteder.';

  @override
  String get screen_time_label => 'Skjermtid';

  @override
  String get total_data_label => 'Totale data';

  @override
  String get mobile_data_label => 'Mobildata';

  @override
  String get wifi_data_label => 'Wifi-data';

  @override
  String get focus_today_label => 'Fokus i dag';

  @override
  String get focus_weekly_label => 'Fokus ukentlig';

  @override
  String get focus_monthly_label => 'Fokuser månedlig';

  @override
  String get focus_lifetime_label => 'Fokus levetid';

  @override
  String get longest_streak_label => 'Lengste rekke';

  @override
  String get current_streak_label => 'Nåværende rekke';

  @override
  String get successful_sessions_label => 'Vellykkede økter';

  @override
  String get failed_sessions_label => 'Mislykkede økter';

  @override
  String get statistics_tab_title => 'Statistikk';

  @override
  String get screen_segment_label => 'Skjerm';

  @override
  String get data_segment_label => 'Data';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Mest brukte apper';

  @override
  String get show_all_apps_tile_title => 'Vis alle apper';

  @override
  String get search_apps_hint => 'Søk etter apper...';

  @override
  String get notifications_tab_title => 'Varsler';

  @override
  String get notifications_tab_info =>
      'Batchvarsling fra apper og angi tidsplaner som morgen, middag, kveld og natt. Hold deg oppdatert uten konstante avbrudd.';

  @override
  String get batched_apps_tile_title => 'Batch-apper';

  @override
  String get batch_recap_dropdown_title => 'Batch oppsummering type';

  @override
  String get batch_recap_dropdown_info =>
      'Velg hva du vil presse når en tidsplan utløses – alle varsler eller bare et sammendrag.';

  @override
  String get batch_recap_option_summery_only => 'Bare sammendrag';

  @override
  String get batch_recap_option_all_notifications => 'Alle varsler';

  @override
  String get notification_history_tile_title => 'Varslingshistorikk';

  @override
  String get store_all_tile_title => 'Lagre alle varsler';

  @override
  String get store_all_tile_subtitle => 'Lagre ikke-batchede varsler også.';

  @override
  String get schedules_heading => 'Tidsplaner';

  @override
  String get new_schedule_fab_button => 'Ny timeplan';

  @override
  String get new_schedule_dialog_info =>
      'Skriv inn et navn for varslingsplanen for å gjøre det enkelt å identifisere det.';

  @override
  String get new_schedule_dialog_field_label => 'Tidsplanens navn';

  @override
  String get bedtime_tab_title => 'Sengetid';

  @override
  String get bedtime_tab_info =>
      'Angi sengetidsplanen din ved å velge en tidsperiode og ukedager. Velg distraherende apper for å blokkere og aktivere Ikke forstyrr-modus (DND) for en fredelig natt.';

  @override
  String get schedule_tile_title => 'Tidsplan';

  @override
  String get schedule_tile_subtitle =>
      'Aktiver eller deaktiver daglig tidsplan.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Velg minst én dag i uken.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Den totale sengetidsvarigheten må være minst 30 minutter.';

  @override
  String get distracting_apps_tile_title => 'Distraherende apper';

  @override
  String get distracting_apps_tile_subtitle =>
      'Velg hvilke apper som distraherer deg fra sengetidsrutinen din.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Endringer i listen over distraherende apper er ikke tillatt mens sengetidsplanen er aktiv.';

  @override
  String get parental_controls_tab_title => 'Foreldrekontroll';

  @override
  String get invincible_mode_heading => 'Uovervinnelig modus';

  @override
  String get invincible_mode_tile_title => 'Aktiver uovervinnelig modus';

  @override
  String get invincible_mode_info =>
      'Når Invincible Mode er på, vil du ikke kunne justere valgte grenser etter å ha nådd den daglige kvoten. Du kan imidlertid gjøre endringer innenfor et valgt 10-minutters uovervinnelig vindu.';

  @override
  String get invincible_mode_snack_alert =>
      'På grunn av uovervinnelig modus er modifikasjoner av restriksjoner ikke tillatt.';

  @override
  String get invincible_mode_dialog_info =>
      'Er du helt sikker på at du vil aktivere Invincible Mode? Denne handlingen er irreversibel. Når Invincible Mode er slått på, kan du ikke slå den av så lenge denne appen er installert på enheten din.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Mode kan ikke slås av så lenge denne appen forblir installert på enheten din.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Start uansett';

  @override
  String get invincible_mode_include_timer_tile_title => 'Inkluder timer';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Inkluder lanseringsgrense';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Inkluder aktiv periode';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'Apprestriksjoner';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Forhindre endringer i appens valgte restriksjoner når de daglige grensene er overskredet.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Gruppebegrensninger';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Forhindre endringer i gruppens valgte restriksjoner når de daglige grensene er overskredet.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Inkluder shorts timer';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Forhindrer endringer etter å ha nådd din daglige shorts-grense.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Inkluder leggetid';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Forhindrer endringer under den aktive leggetidsplanen.';

  @override
  String get protected_access_tile_title => 'Beskyttet tilgang';

  @override
  String get protected_access_tile_subtitle =>
      'Beskytt NLP digitox med enhetslåsen.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Sett opp en biometrisk lås på enheten din først for å aktivere denne funksjonen.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Enhetslåsen din er fjernet. For å fortsette må du sette opp en ny lås.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Autentisering mislyktes. Du må bekrefte enhetslåsen for å fortsette.';

  @override
  String get tamper_protection_tile_title => 'Sabotasjebeskyttelse';

  @override
  String get tamper_protection_tile_subtitle =>
      'Forhindre avinstallering og tvinge stopp av appen.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Når den er aktivert, vil du ikke kunne avinstallere, tvinge stopp eller slette NLP digitoxs data, bortsett fra i det valgte avinstalleringsvinduet. Det finnes ingen løsninger.\n\nFortsett på egen risiko.';

  @override
  String get uninstall_window_tile_title => 'Avinstaller vinduet';

  @override
  String get uninstall_window_tile_subtitle =>
      'Sabotasjebeskyttelse kan deaktiveres innen 10 minutter fra valgt tidspunkt.';

  @override
  String get invincible_window_tile_title => 'Uovervinnelig vindu';

  @override
  String get invincible_window_tile_subtitle =>
      'Valgte grenser kan endres innen 10 minutter fra valgt tidspunkt.';

  @override
  String get shorts_blocking_tab_title => 'Shorts som blokkerer';

  @override
  String get shorts_blocking_tab_info =>
      'Kontroller hvor mye tid du bruker på kort innhold på tvers av plattformer som Instagram, YouTube, Snapchat og Facebook, inkludert nettstedene deres.';

  @override
  String get short_content_heading => 'Kort innhold';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Venstre fra $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Angi en daglig tidsbegrensning for kort innhold. Når grensen din er nådd, blir det korte innholdet satt på pause til midnatt.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Begrens funksjoner på instagram.';

  @override
  String get instagram_features_block_reels => 'Begrens hjulseksjonen.';

  @override
  String get instagram_features_block_explore => 'Begrens utforske delen.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Begrens funksjoner på snapchat.';

  @override
  String get snapchat_features_block_spotlight => 'Begrens søkelysseksjonen.';

  @override
  String get snapchat_features_block_discover =>
      'Begrens oppdagelsesseksjonen.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle => 'Begrens shorts på youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Begrens ruller på facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Begrens shorts på reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Begrens videofeed på X.';

  @override
  String get threads_features_tile_title => 'Tråder';

  @override
  String get threads_features_tile_subtitle =>
      'Begrens video/ruller på tråder.';

  @override
  String get websites_blocking_tab_title => 'Blokkering av nettsteder';

  @override
  String get websites_blocking_tab_info =>
      'Blokker voksennettsteder og eventuelle tilpassede nettsteder du velger for å skape en tryggere og mer fokusert nettopplevelse. Ta kontroll over nettlesingen din og hold deg fri for distraksjoner.';

  @override
  String get adult_content_heading => 'Vokseninnhold';

  @override
  String get block_nsfw_title => 'Blokker Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Begrens nettlesere fra å åpne nettsteder for voksne og porno.';

  @override
  String get block_nsfw_dialog_info =>
      'Er du sikker? Denne handlingen er irreversibel. Når blokkering av voksne nettsteder er slått PÅ, kan du ikke slå den AV så lenge denne appen er installert på enheten din.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Blokker uansett';

  @override
  String get blocked_websites_heading => 'Blokkerte nettsteder';

  @override
  String get blocked_websites_empty_list_hint =>
      'Klikk på \'+ Legg til nettsted\'-knappen for å legge til distraherende nettsteder som du ønsker å blokkere.';

  @override
  String get add_website_fab_button => 'Legg til nettsted';

  @override
  String get add_website_dialog_title => 'Distraherende nettsted';

  @override
  String get add_website_dialog_info =>
      'Skriv inn url til et nettsted du vil blokkere.';

  @override
  String get add_website_dialog_is_nsfw => 'Er nsfw nettsted?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Advarsel: Nsfw-nettsteder kan ikke fjernes når de er lagt til.';

  @override
  String get add_website_dialog_button_block => 'Blokkér';

  @override
  String get add_website_already_exist_snack_alert =>
      'URL-en er allerede lagt til listen over blokkerte nettsteder.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Ugyldig URL! Kan ikke analysere vertsnavnet.';

  @override
  String get remove_website_dialog_title => 'Fjern nettstedet';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Er du sikker? du vil fjerne \'$websitehost\' fra blokkerte nettsteder.';
  }

  @override
  String get focus_tab_title => 'Fokus';

  @override
  String get focus_tab_info =>
      'Når du trenger tid til å fokusere, start en ny økt ved å velge typen, velge distraherende apper som skal settes på pause, og aktivere Ikke forstyrr for uavbrutt konsentrasjon.';

  @override
  String get active_session_card_title => 'Aktiv økt';

  @override
  String get active_session_card_info =>
      'Du har en aktiv fokusøkt i gang! Klikk \"Vis\" for å sjekke fremgangen din og se hvor lang tid som har gått.';

  @override
  String get active_session_card_view_button => 'Visning';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Fjerning av apper fra den distraherende applisten er ikke tillatt mens en fokusøkt er aktiv. Du kan imidlertid fortsatt legge til flere apper på listen i løpet av denne tiden.';

  @override
  String get focus_profile_tile_title => 'Fokus profil';

  @override
  String get focus_session_duration_tile_title => 'Sesjons varighet';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Uendelig (med mindre du stopper)';

  @override
  String get focus_session_duration_dialog_info =>
      'Velg ønsket varighet for denne fokusøkten, og avgjør hvor lenge du ønsker å forbli fokusert og distraksjonsfri.';

  @override
  String get focus_profile_customization_tile_title => 'Tilpasning av profil';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Tilpass innstillingene for den valgte profilen.';

  @override
  String get focus_enforce_tile_title => 'Håndheve økten';

  @override
  String get focus_enforce_tile_subtitle =>
      'Hindrer å avslutte en økt før tiden er over.';

  @override
  String get focus_session_start_button => 'Sveip for å starte økten';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Velg minst én distraherende app for å starte fokusøkten';

  @override
  String get focus_session_already_active_snack_alert =>
      'Du har allerede en aktiv fokusøkt i gang. Fullfør eller stopp den nåværende økten før du starter en ny.';

  @override
  String get focus_session_type_study => 'Studer';

  @override
  String get focus_session_type_work => 'Arbeid';

  @override
  String get focus_session_type_exercise => 'Trening';

  @override
  String get focus_session_type_meditation => 'Meditasjon';

  @override
  String get focus_session_type_creativeWriting => 'Kreativ skriving';

  @override
  String get focus_session_type_reading => 'Lesing';

  @override
  String get focus_session_type_programming => 'Programmering';

  @override
  String get focus_session_type_chores => 'Arbeidsoppgaver';

  @override
  String get focus_session_type_projectPlanning => 'Prosjektplanlegging';

  @override
  String get focus_session_type_artAndDesign => 'Kunst og design';

  @override
  String get focus_session_type_languageLearning => 'Språklæring';

  @override
  String get focus_session_type_musicPractice => 'Musikk praksis';

  @override
  String get focus_session_type_selfCare => 'Egenomsorg';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Ferdighetsutvikling';

  @override
  String get focus_session_type_research => 'Forskning';

  @override
  String get focus_session_type_networking => 'Nettverk';

  @override
  String get focus_session_type_cooking => 'Matlaging';

  @override
  String get focus_session_type_sportsTraining => 'Sportstrening';

  @override
  String get focus_session_type_restAndRelaxation => 'Hvile og avslapning';

  @override
  String get focus_session_type_other => 'Annet';

  @override
  String get timeline_tab_title => 'Tidslinje';

  @override
  String get focus_timeline_tab_info =>
      'Utforsk fokusreisen din ved å velge en dato fra kalenderen. Følg fremgangen din, se suksessene dine på nytt og lær av utfordringene.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Din totale produktive tid for den valgte måneden er $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktive dager';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Du har hatt totalt $daysCount produktive dager i den valgte måneden.';
  }

  @override
  String get selected_day_focused_time_label => 'Fokusert tid';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Din totale fokuserte tid for den valgte dagen er $timeString.';
  }

  @override
  String get calender_heading => 'Kalender';

  @override
  String get your_sessions_heading => 'Øktene dine';

  @override
  String get your_sessions_empty_list_hint =>
      'Ingen fokusøkter registrert for den valgte dagen.';

  @override
  String get focus_session_tile_timestamp_label => 'Tidsstempel';

  @override
  String get focus_session_tile_duration_label => 'Varighet';

  @override
  String get focus_session_tile_reflection_label => 'Refleksjon';

  @override
  String get focus_session_state_active => 'Aktiv';

  @override
  String get focus_session_state_successful => 'Vellykket';

  @override
  String get focus_session_state_failed => 'Mislyktes';

  @override
  String get active_session_tab_title => 'Sesjon';

  @override
  String get active_session_none_warning =>
      'Finner ingen aktiv økt. Går tilbake til startskjermen.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Fortsett å presse';

  @override
  String get active_session_finish_dialog_title => 'Fullfør';

  @override
  String get active_session_finish_dialog_info =>
      'Hold deg sterk! Du bygger verdifullt fokus. Er du sikker på at du vil avslutte denne fokusøkten? Hvert ekstra øyeblikk teller mot målene dine.';

  @override
  String get active_session_giveup_dialog_title => 'Gi opp';

  @override
  String get active_session_giveup_dialog_info =>
      'Hold ut! Du er nesten der, ikke gi opp nå! Er du sikker på at du vil avslutte denne fokusøkten tidlig? Fremskritt vil gå tapt.';

  @override
  String get active_session_reflection_dialog_title => 'Sesjonsrefleksjon';

  @override
  String get active_session_reflection_dialog_info =>
      'Ta deg tid til å reflektere over fremgangen din. Hva er målet ditt for denne økten? Hva har du oppnådd i løpet av denne økten?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tips: Du kan alltid redigere dette senere i øktens tidslinje.';

  @override
  String get active_session_giveup_snack_alert =>
      'Du ga opp! Ikke bekymre deg, du kan gjøre det bedre neste gang. Hver innsats teller - bare fortsett';

  @override
  String get active_session_quote_one =>
      'Hvert skritt teller, vær sterk og fortsett';

  @override
  String get active_session_quote_two =>
      'Hold fokus! du gjør utrolige fremskritt';

  @override
  String get active_session_quote_three => 'Du knuser det! Hold farten oppe';

  @override
  String get active_session_quote_four =>
      'Bare litt igjen, du gjør det fantastisk';

  @override
  String active_session_quote_five(String durationString) {
    return 'Gratulerer 🎉 \n Du har fullført fokusøkten din med $durationString.\n\nFlott jobb, fortsett med det fantastiske arbeidet';
  }

  @override
  String get restriction_groups_tab_title => 'Restriksjonsgrupper';

  @override
  String get restriction_groups_tab_info =>
      'Angi en kombinert skjermtidsgrense for en gruppe apper. Når den totale bruken når grensen din, blir alle apper i gruppen satt på pause for å opprettholde fokus og balanse.';

  @override
  String get restriction_group_time_spent_label => 'Tid brukt i dag';

  @override
  String get restriction_group_time_left_label => 'Tid igjen i dag';

  @override
  String get restriction_group_name_tile_title => 'Gruppenavn';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Skriv inn et navn for begrensningsgruppen for å hjelpe med å identifisere og administrere den enkelt.';

  @override
  String get restriction_group_timer_tile_title => 'Gruppetur';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Angi en daglig tidsbegrensning for denne gruppen. Når grensen din er nådd, blir alle appene i denne gruppen satt på pause til midnatt.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Gruppe aktiv periode';

  @override
  String get remove_restriction_group_dialog_title => 'Fjern gruppen';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Er du sikker? du vil fjerne \'$groupName\' fra restriksjonsgrupper.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Still inn enten en timer eller en aktiv periodegrense.';

  @override
  String get notifications_empty_list_hint =>
      'Ingen varsler har blitt samlet for dagen.';

  @override
  String get conversations_label => 'Samtaler';

  @override
  String get last_24_hours_heading => 'Siste 24 timer';

  @override
  String get notification_timeline_tab_info =>
      'Bla gjennom varslingsloggen din ved å velge en dato fra kalenderen. Se hvilke apper som fanget oppmerksomheten din og reflekter over dine digitale vaner.';

  @override
  String get monthly_label => 'Månedlig';

  @override
  String get daily_label => 'Daglig';

  @override
  String get search_notifications_sheet_info =>
      'Finn enkelt tidligere varsler ved å søke gjennom tittelen eller innholdet. Hjelper deg raskt å finne viktige varsler.';

  @override
  String get search_notifications_hint => 'Søk etter varsler...';

  @override
  String get search_notifications_empty_list_hint =>
      'Fant ingen varsler som samsvarer med søket ditt.';

  @override
  String get app_info_none_warning =>
      'Kunne ikke finne appen for den gitte pakken. Går tilbake til startskjermen.';

  @override
  String get emergency_fab_button => 'Nødsituasjon';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Denne handlingen vil sette appblokkeringen på pause i de neste 5 minuttene. Du har $leftPassesCount-pass igjen. Etter å ha brukt alle pass, vil appen forbli blokkert til midnatt, eller den aktive fokusøkten avsluttes.\n\nVil du fortsatt fortsette?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Bruk uansett';

  @override
  String get emergency_started_snack_alert =>
      'Appblokkeringen er satt på pause og vil gjenoppta blokkeringen om 5 minutter.';

  @override
  String get emergency_already_active_snack_alert =>
      'Appblokkeringen er for øyeblikket enten satt på pause eller inaktiv. Hvis varsler er aktivert, vil du motta oppdateringer om gjenværende tid.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Du har brukt alle nødpassene dine. De blokkerte appene forblir blokkert til midnatt, eller den aktive fokusøkten avsluttes.';

  @override
  String get app_limit_status_not_set => 'Ikke satt';

  @override
  String get app_timer_tile_title => 'App-timer';

  @override
  String get app_timer_picker_dialog_info =>
      'Angi en daglig tidsbegrensning for denne appen. Når grensen din er nådd, blir appen satt på pause til midnatt.';

  @override
  String get usage_reminders_tile_title => 'Brukspåminnelser';

  @override
  String get usage_reminders_tile_subtitle =>
      'Milde dytt når du bruker tidsstyrte apper.';

  @override
  String get app_launch_limit_tile_title => 'Startgrense';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Lanserte $count ganger i dag.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Angi hvor mange ganger du kan åpne denne appen hver dag. Når grensen er nådd, blir den satt på pause til midnatt.';

  @override
  String get app_active_period_tile_title => 'Aktiv periode';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Fra $startTime til $endTime';
  }

  @override
  String get internet_access_tile_title => 'Internett-tilgang';

  @override
  String get internet_access_tile_subtitle =>
      'Slå av for å blokkere appens internett.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '${appName}s internett er blokkert.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '${appName}s internett er opphevet.';
  }

  @override
  String get launch_app_tile_title => 'Start appen';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Åpne $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Gå til appinnstillinger';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Administrer appinnstillinger som varsler, tillatelser, lagring og mer.';

  @override
  String get include_in_stats_tile_title => 'Inkluder i skjermbruk';

  @override
  String get include_in_stats_tile_subtitle =>
      'Slå av for å ekskludere denne appen fra total skjermbruk.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName er ekskludert fra total skjermbruk.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName er inkludert for total skjermbruk.';
  }

  @override
  String get general_tab_title => 'Generelt';

  @override
  String get appearance_heading => 'Utseende';

  @override
  String get theme_mode_tile_title => 'Temamodus';

  @override
  String get theme_mode_system_label => 'System';

  @override
  String get theme_mode_light_label => 'Lys';

  @override
  String get theme_mode_dark_label => 'Mørkt';

  @override
  String get material_color_tile_title => 'Materialfarge';

  @override
  String get amoled_dark_tile_title => 'AMOLED mørk';

  @override
  String get amoled_dark_tile_subtitle =>
      'Bruk ren svart farge for det mørke temaet.';

  @override
  String get dynamic_colors_tile_title => 'Dynamiske farger';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Bruk enhetsfarger hvis det støttes.';

  @override
  String get defaults_heading => 'Standarder';

  @override
  String get app_language_tile_title => 'Appens språk';

  @override
  String get default_home_tab_tile_title => 'Hjem-fanen';

  @override
  String get usage_history_tile_title => 'Brukshistorikk';

  @override
  String get usage_history_15_days => '15 dager';

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
      'Hvis NLP digitox slutter å fungere uventet, vennligst gi tillatelsen \"Ignorer batterioptimalisering\" for å holde den kjørende i bakgrunnen. Hvis problemet vedvarer, prøv å hviteliste NLP digitox for uavbrutt ytelse.';

  @override
  String get whitelist_app_tile_title => 'Hviteliste NLP digitox';

  @override
  String get whitelist_app_tile_subtitle => 'La NLP digitox starte automatisk.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Denne enheten støtter ikke automatisk oppstartsadministrasjon.';

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
  String get analysis_7_days => '7 dager';

  @override
  String get analysis_30_days => '30 dager';

  @override
  String get analysis_90_days => '90 dager';

  @override
  String get analysis_screen_time_trend => 'Skjermtidstrend';

  @override
  String get analysis_no_data_info =>
      'Ingen skjermtidsdata er registrert for denne perioden ennå.';

  @override
  String get analysis_daily_average => 'Daglig gjennomsnitt';

  @override
  String get analysis_total => 'Totalt';

  @override
  String get analysis_no_change => 'Samme som forrige uke';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% mindre enn forrige uke';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% mer enn forrige uke';
  }

  @override
  String get crash_logs_heading => 'Krasjlogger';

  @override
  String get crash_logs_info =>
      'Hvis du støter på problemer, kan du rapportere det på GitHub sammen med loggfilen. Filen vil inneholde detaljer som enhetens produsent, modell, Android-versjon, SDK-versjon og krasjlogger. Denne informasjonen vil hjelpe oss med å identifisere og løse problemet mer effektivt.';

  @override
  String get crash_logs_export_tile_title => 'Eksporter krasjlogger';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Eksporter krasjlogger til en json-fil.';

  @override
  String get crash_logs_view_tile_title => 'Se logger';

  @override
  String get crash_logs_view_tile_subtitle => 'Utforsk lagrede krasjlogger.';

  @override
  String get crash_logs_empty_list_hint => 'Ingen krasj logget til nå.';

  @override
  String get crash_logs_clear_tile_title => 'Tøm logger';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Slett alle krasjlogger fra databasen.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Er du sikker på at du vil slette alle krasjlogger fra databasen?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Tydelig uansett';

  @override
  String get about_tab_title => 'Om';

  @override
  String get changelog_tile_title => 'Endringslogg';

  @override
  String get changelog_tile_subtitle => 'Finn ut hva som er nytt.';

  @override
  String get full_changelog_tile_title => 'Full endringslogg';

  @override
  String get redirected_to_github_subtitle =>
      'Du vil bli omdirigert til GitHub.';

  @override
  String get contribute_heading => 'Bidra';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Se kildekoden.';

  @override
  String get report_issue_tile_title => 'Rapporter et problem';

  @override
  String get suggest_idea_tile_title => 'Foreslå en idé';

  @override
  String get write_email_tile_title => 'Skriv til oss via e-post';

  @override
  String get write_email_tile_subtitle =>
      'Du vil bli omdirigert til E-post-appen.';

  @override
  String get privacy_policy_heading => 'Personvernerklæring';

  @override
  String get privacy_policy_info =>
      'NLP digitox er forpliktet til å beskytte personvernet ditt. Vi samler ikke inn, lagrer eller overfører noen form for brukerdata. Appen fungerer helt offline og krever ingen internettforbindelse, noe som sikrer at din personlige informasjon forblir privat og sikker på enheten din. Som en gratis og åpen kildekode-programvare (FOSS)-applikasjon garanterer NLP digitox fullstendig åpenhet og brukerkontroll over dataene deres.';

  @override
  String get more_details_button => 'Flere detaljer';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
