// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Afrikaans (`af`).
class AppLocalizationsAf extends AppLocalizations {
  AppLocalizationsAf([String locale = 'af']) : super(locale);

  @override
  String get mindful_tagline => 'Fokus op wat regtig saak maak';

  @override
  String get unlock_button_label => 'Ontsluit';

  @override
  String get permission_status_off => 'Af';

  @override
  String get permission_status_allowed => 'Toegelaat';

  @override
  String get permission_status_not_allowed => 'Nie toegelaat nie';

  @override
  String get permission_button_grant_permission => 'Gee toestemming';

  @override
  String get permission_button_agree_and_continue => 'Stem saam en gaan voort';

  @override
  String get permission_button_not_now => 'Nie nou nie';

  @override
  String get permission_button_help => 'Help?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox is 100% veilig en werk vanlyn. Ons versamel of stoor geen persoonlike data nie.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Klik op $button_label knoppie.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Kies NLP digitox in die volgende skerm.';

  @override
  String get permission_grant_step_three =>
      '3. Klik en skakel die skakelaar soos hieronder aan.';

  @override
  String get permission_notification_title => 'Stuur kennisgewings';

  @override
  String get permission_alarms_title => 'Alarms en onthounotas';

  @override
  String get permission_alarms_info =>
      'Gee asseblief toestemming om alarms en aanmanings in te stel. Dit sal NLP digitox toelaat om jou slaaptydskedule betyds te begin en app-tydtellers daagliks om middernag terug te stel en jou te help om op koers te bly.';

  @override
  String get permission_alarms_device_tile_label =>
      'Laat toe om alarms en onthounotas te stel';

  @override
  String get permission_usage_title => 'Gebruik Toegang';

  @override
  String get permission_usage_info =>
      'Gee asseblief toestemming vir gebruiktoegang. Dit sal NLP digitox in staat stel om toepassingsgebruik te monitor en toegang tot sekere toepassings te bestuur, wat \'n meer gefokusde en beheerde digitale omgewing verseker.';

  @override
  String get permission_usage_device_tile_label => 'Laat gebruiktoegang toe';

  @override
  String get permission_overlay_title => 'Vertoon oorleg';

  @override
  String get permission_overlay_info =>
      'Gee asseblief toestemming vir vertoon-oorleg. Dit sal NLP digitox toelaat om \'n oorleg te wys wanneer \'n onderbreekte toepassing oopgemaak word, wat jou help om gefokus te bly en jou skedule te handhaaf.';

  @override
  String get permission_overlay_device_tile_label =>
      'Laat vertoon bo ander programme toe';

  @override
  String get permission_accessibility_title => 'Toeganklikheid';

  @override
  String get permission_accessibility_info =>
      'Gee asseblief toeganklikheidtoestemming. Dit sal NLP digitox toelaat om toegang tot kortvorm-video-inhoud (bv. Reels, Shorts) binne sosialemedia-toepassings en blaaiers te beperk, en onvanpaste webwerwe te filter.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox vereis toeganklikheidstoestemming om kort inhoud en webwerwe effektief te blokkeer.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Gebruik NLP digitox';

  @override
  String get permission_dnd_title => 'Moenie steur nie';

  @override
  String get permission_dnd_info =>
      'Gee asseblief Moenie Steur Nie-toegang. Dit sal NLP digitox toelaat om Moenie Steur Nie-modus te begin en stop tydens die slaaptydskedule.';

  @override
  String get permission_dnd_tile_title => 'Begin DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Aktiveer ook Moenie Steur Nie-modus.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignoreer batteryoptimalisering';

  @override
  String get permission_battery_optimization_status_enabled => 'Reeds onbeperk';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Deaktiveer agtergrondbeperking';

  @override
  String get permission_battery_optimization_allow_info =>
      'Deur \'Ignoreer batteryoptimalisering\' toe te laat, sal die \'Alarms & Herinnerings\'-toestemming outomaties op sommige toestelle verleen word.';

  @override
  String get permission_vpn_title => 'Skep VPN';

  @override
  String get permission_vpn_info =>
      'Gee asseblief toestemming om \'n virtuele privaatnetwerk-verbinding (VPN) te skep. Dit sal NLP digitox in staat stel om internettoegang vir aangewese toepassings te beperk deur plaaslike VPN op toestel te skep.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Administratiewe voorregte word slegs benodig vir noodsaaklike bedrywighede om te verseker dat die toepassing behoorlik werk en peutervry bly.';

  @override
  String get permission_admin_snack_alert =>
      'Peuterbeskerming kan slegs gedurende die geselekteerde tydvenster gedeaktiveer word.';

  @override
  String get permission_notification_access_title => 'Toegang tot kennisgewing';

  @override
  String get permission_notification_access_info =>
      'Gee asseblief toestemming vir kennisgewingtoegang. Dit sal NLP digitox in staat stel om jou kennisgewings te organiseer en op jou skedule af te lewer.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox vereis kennisgewingtoegang tot bondel- en skedulekennisgewings.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Laat kennisgewingtoegang toe';

  @override
  String get day_today => 'Vandag';

  @override
  String get day_yesterday => 'Gister';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dae',
      one: '1 dag',
      zero: '0 dae',
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
      other: '$countString ure',
      one: '1 uur',
      zero: '0 ure',
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
      other: '$countString minute',
      one: '1 minuut',
      zero: '0 minute',
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
      other: '$countString sekondes',
      one: '1 sekonde',
      zero: '0 sekondes',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'en';

  @override
  String get timer_status_active => 'Aktief';

  @override
  String get timer_status_paused => 'Onderbreek';

  @override
  String get create_button => 'Skep';

  @override
  String get update_button => 'Dateer op';

  @override
  String get dialog_button_cancel => 'Kanselleer';

  @override
  String get dialog_button_remove => 'Verwyder';

  @override
  String get dialog_button_set => 'Stel';

  @override
  String get dialog_button_reset => 'Stel terug';

  @override
  String get dialog_button_infinite => 'Oneindig';

  @override
  String get schedule_start_label => 'Begin';

  @override
  String get schedule_end_label => 'Einde';

  @override
  String get exit_without_saving_dialog_info =>
      'Is jy seker jy wil verlaat sonder om te stoor?';

  @override
  String get development_dialog_info =>
      'NLP digitox is tans onder ontwikkeling en kan foute of onvolledige kenmerke hê. As jy enige probleme ondervind, rapporteer dit asseblief om ons te help verbeter.\n\nDankie vir jou terugvoer!';

  @override
  String get development_dialog_button_report_issue => 'Rapporteer kwessie';

  @override
  String get development_dialog_button_close => 'Maak toe';

  @override
  String get dnd_settings_tile_title => 'Moenie instellings steur nie';

  @override
  String get dnd_settings_tile_subtitle =>
      'Bestuur watter toepassings en kennisgewings jou in DND kan bereik.';

  @override
  String get quick_actions_heading => 'Vinnige aksies';

  @override
  String get select_distracting_apps_heading => 'Kies afleidende toepassings';

  @override
  String get your_distracting_apps_heading => 'Jou afleidende toepassings';

  @override
  String get select_more_apps_heading => 'Kies meer toepassings';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Dit word nie toegelaat om belangrike stelseltoepassings by die lys programme wat aandag aflei nie.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Skermgebruik en -beperkings is nie vir hierdie toepassing beskikbaar nie. Op die oomblik is slegs netwerkgebruik toeganklik';

  @override
  String get create_group_fab_button => 'Skep Groep';

  @override
  String get active_period_info =>
      'Stel \'n tydperk waartydens toegang toegelaat sal word. Buite hierdie tydsbestek sal toegang beperk word.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Kies ten minste een afleidende toepassing.';

  @override
  String get donation_card_title => 'Ondersteun ons';

  @override
  String get donation_card_info =>
      'NLP digitox is gratis en oopbron, ontwikkel met maande se toewyding. As dit jou gehelp het, sou jou skenking die wêreld vir ons beteken. Elke bydrae help ons om dit vir almal te verbeter en in stand te hou.';

  @override
  String get operation_failed_snack_alert =>
      'Operasie het misluk, iets het verkeerd geloop!';

  @override
  String get donation_card_button_donate => 'Skenk';

  @override
  String get app_restart_dialog_title => 'Benodig herbegin';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox sal outomaties herbegin sodra die aftelling klaar is. Wees asseblief geduldig aangesien veranderinge toegepas word.';

  @override
  String get accessibility_tip =>
      'Wil jy slimmer, meer batteryvriendelike blokkering hê? Aktiveer toeganklikheidtoestemming vir NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox werk nie? Laat \'Ignoreer batteryoptimalisering\' toe in Instellings om dit glad te laat loop.';

  @override
  String get invincible_mode_tip =>
      'Beperkings per ongeluk verwyder? Gebruik Invincible Mode om hulle te sluit tot die volgende dag of aanpassingsvenster.';

  @override
  String get glance_usage_tip =>
      'Wil jy insigte hê? Gaan die Glance-afdeling na om jou gebruikspatrone en skermtyd te sien.';

  @override
  String get tamper_protection_tip =>
      'Deïnstalleer NLP digitox? Aktiveer die Deïnstalleer-venster om peuterbeskerming eers veilig uit te skakel.';

  @override
  String get notification_blocking_tip =>
      'Wil jy afleiding verminder? Gebruik kennisgewingblokkering om geselekteerde programme stil te maak.';

  @override
  String get usage_history_tip =>
      'Wil jy nadink oor jou gewoontes? Gaan Gebruiksgeskiedenis na om vorige patrone te sien.';

  @override
  String get focus_mode_tip =>
      'Het jy diep fokus nodig? Skakel Fokusmodus aan om programme en kennisgewings tydens take te blokkeer.';

  @override
  String get bedtime_reminder_tip =>
      'Wil jy jou slaap verbeter? Stel \'n slaaptydherinnering om elke nag rustig te word.';

  @override
  String get custom_blocking_tip =>
      'Het u \'n pasgemaakte ervaring nodig? Skep programblokkeerreëls wat by jou behoeftes pas.';

  @override
  String get session_timeline_tip =>
      'Wil jy fokussessies dophou? Bekyk tydlyn om jou fokusreis te sien.';

  @override
  String get short_content_blocking_tip =>
      'Afgelei deur sosiale toepassings? Blokkeer kort inhoud op Instagram, YouTube, ens., om gefokus te bly.';

  @override
  String get parental_controls_tip =>
      'Benodig ouerbeheer? Stel beperkings vir jou kind se toestel om \'n veilige ervaring te verseker.';

  @override
  String get notification_batching_tip =>
      'Wil jy afleiding verminder? Gebruik Notification Batching om kennisgewings te groepeer en dit dadelik na te gaan.';

  @override
  String get notification_scheduling_tip =>
      'Moet jy kennisgewings bestuur? Beplan wanneer jy kennisgewings vir spesifieke programme ontvang.';

  @override
  String get quick_focus_tile_tip =>
      'Het jy vinnige toegang tot fokus nodig? Voeg \'n vinnige fokusteël by om die fokusmodus onmiddellik te aktiveer.';

  @override
  String get app_shortcuts_tip =>
      'Wil jy kitsprogramtoegang hê? Voeg kortpaaie by deur die toepassingikoon lank te druk vir vinnige aksies.';

  @override
  String get backup_usage_db_tip =>
      'Wil jy jou data stoor? Rugsteun jou gebruikdatabasis om jou rekords veilig te hou.';

  @override
  String get dynamic_material_color_tip =>
      'Wil jy \'n pasgemaakte tema hê? Aktiveer dinamiese materiaal wat jy kleur om by jou toestel se tema te pas.';

  @override
  String get amoled_dark_theme_tip =>
      'Wil jy battery spaar? Gebruik AMOLED Dark Theme om kragverbruik op OLED-skerms te verminder.';

  @override
  String get customize_usage_history_tip =>
      'Wil u gebruiksgeskiedenis behou? Pasmaak hoeveel weke se data om in Gebruiksgeskiedenis te stoor.';

  @override
  String get grouped_apps_blocking_tip =>
      'Wil jy programme saam blokkeer? Gebruik beperkingsgroepe om toepassingslimiete te groepeer en verskeie toepassings gelyktydig te blokkeer.';

  @override
  String get websites_blocking_tip =>
      'Wil jy \'n skoner blaai-ervaring hê? Blokkeer pasgemaakte of NSFW-webwerwe vir \'n meer gefokusde aanlyntyd.';

  @override
  String get data_usage_tip =>
      'Wil jy jou data opspoor? Monitor jou selfoon- en Wi-Fi-datagebruik vir internetverbruik.';

  @override
  String get block_internet_tip =>
      'Moet u \'n toepassing se internet blokkeer? Sny internet af vir spesifieke toepassing vanaf toepassing se dashboard.';

  @override
  String get emergency_passes_tip =>
      'Het jy \'n breek nodig? Gebruik daagliks 3 noodpasse om programme vir 5 minute tydelik te deblokkeer.';

  @override
  String get onboarding_skip_btn_label => 'Slaan oor';

  @override
  String get onboarding_finish_setup_btn_label => 'Voltooi opstelling';

  @override
  String get onboarding_page_welcome_title => 'Welkom by NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Neem beheer van jou digitale lewe en bou gesonder skermgewoontes. NLP digitox help jou om gefokus te bly, afleidings te verminder en elke dag bewuste keuses te maak.';

  @override
  String get onboarding_page_statistics_title => 'Ken jou gewoontes.';

  @override
  String get onboarding_page_statistics_info =>
      'Verstaan jou digitale patrone met gedetailleerde insigte oor skermtyd, app-gebruik en fokus-tendense. Volg jou vordering en sien hoe klein veranderinge tot groot verbeterings lei.';

  @override
  String get onboarding_page_one_title => 'Meester Fokus.';

  @override
  String get onboarding_page_one_info =>
      'Onderbreek afleidende toepassings, blokkeer kort inhoud en bly op koers met aanpasbare fokussessies. Of jy nou werk, studeer of ontspan, NLP digitox help jou om in beheer te bly.';

  @override
  String get onboarding_page_two_title => 'Blokkeer afleidings.';

  @override
  String get onboarding_page_two_info =>
      'Stel gebruikslimiete, onderbreek programme outomaties en skep gesonder digitale gewoontes. Gebruik Slaaptydmodus om te ontspan en \'n nag sonder afleiding te geniet.';

  @override
  String get onboarding_page_three_title => 'Privaatheid eerste.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox is 100% oopbron en werk heeltemal vanlyn. Ons versamel of deel nie jou persoonlike data nie – jou privaatheid word in alle opsigte gewaarborg.';

  @override
  String get onboarding_page_permissions_title => 'Noodsaaklike toestemmings.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox vereis die volgende noodsaaklike toestemmings om jou skermtyd op te spoor en te bestuur, wat help om afleidings te verminder en fokus te verbeter.';

  @override
  String get dashboard_tab_title => 'Dashboard';

  @override
  String get focus_now_fab_button => 'Fokus nou';

  @override
  String get welcome_greetings => 'Welkom terug,';

  @override
  String get username_snack_alert => 'Druk lank om gebruikersnaam te wysig.';

  @override
  String get username_dialog_title => 'Gebruikersnaam';

  @override
  String get username_dialog_info =>
      'Voer jou gebruikersnaam in wat op die dashboard vertoon sal word.';

  @override
  String get username_dialog_button_apply => 'Doen aansoek';

  @override
  String get glance_tile_title => 'Kyk';

  @override
  String get glance_tile_subtitle => 'Kyk vinnig na jou gebruik.';

  @override
  String get parental_controls_tile_subtitle =>
      'Onoorwinlike modus en peuterbeskerming.';

  @override
  String get restrictions_heading => 'Beperkings';

  @override
  String get apps_blocking_tile_title => 'Programme blokkeer';

  @override
  String get apps_blocking_tile_subtitle =>
      'Beperk programme op verskeie maniere.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Blokkering van gegroepeerde toepassings';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Beperk groep programme gelyktydig.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Beperk kort inhoud op verskeie platforms.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Beperk volwasse en pasgemaakte webwerwe.';

  @override
  String get screen_time_label => 'Skermtyd';

  @override
  String get total_data_label => 'Totale data';

  @override
  String get mobile_data_label => 'Mobiele data';

  @override
  String get wifi_data_label => 'Wifi data';

  @override
  String get focus_today_label => 'Fokus vandag';

  @override
  String get focus_weekly_label => 'Fokus weekliks';

  @override
  String get focus_monthly_label => 'Fokus maandeliks';

  @override
  String get focus_lifetime_label => 'Fokus leeftyd';

  @override
  String get longest_streak_label => 'Langste streep';

  @override
  String get current_streak_label => 'Huidige streep';

  @override
  String get successful_sessions_label => 'Suksesvolle sessies';

  @override
  String get failed_sessions_label => 'Mislukte sessies';

  @override
  String get statistics_tab_title => 'Statistiek';

  @override
  String get screen_segment_label => 'Skerm';

  @override
  String get data_segment_label => 'Data';

  @override
  String get mobile_label => 'Selfoon';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Mees gebruikte toepassings';

  @override
  String get show_all_apps_tile_title => 'Wys alle toepassings';

  @override
  String get search_apps_hint => 'Soek programme...';

  @override
  String get notifications_tab_title => 'Kennisgewings';

  @override
  String get notifications_tab_info =>
      'Bondelkennisgewing vanaf toepassings en stel skedules soos oggend, middag, aand en nag. Bly op hoogte sonder konstante onderbrekings.';

  @override
  String get batched_apps_tile_title => 'Gebundelde toepassings';

  @override
  String get batch_recap_dropdown_title => 'Groepopsomming tipe';

  @override
  String get batch_recap_dropdown_info =>
      'Kies wat om te druk wanneer \'n skedule aktiveer - alle kennisgewings of net \'n opsomming.';

  @override
  String get batch_recap_option_summery_only => 'Slegs opsomming';

  @override
  String get batch_recap_option_all_notifications => 'Alle kennisgewings';

  @override
  String get notification_history_tile_title => 'Kennisgewingsgeskiedenis';

  @override
  String get store_all_tile_title => 'Stoor alle kennisgewings';

  @override
  String get store_all_tile_subtitle =>
      'Stoor ook nie-samestelling kennisgewings.';

  @override
  String get schedules_heading => 'Skedules';

  @override
  String get new_schedule_fab_button => 'Nuwe skedule';

  @override
  String get new_schedule_dialog_info =>
      'Voer \'n naam vir die kennisgewingskedule in om dit maklik te identifiseer.';

  @override
  String get new_schedule_dialog_field_label => 'Bylae naam';

  @override
  String get bedtime_tab_title => 'Slaaptyd';

  @override
  String get bedtime_tab_info =>
      'Stel jou slaaptydskedule deur \'n tydperk en dae van die week te kies. Kies afleidende programme om Moenie Steur Nie (DND)-modus te blokkeer en aktiveer vir \'n rustige nag.';

  @override
  String get schedule_tile_title => 'Skedule';

  @override
  String get schedule_tile_subtitle =>
      'Aktiveer of deaktiveer daaglikse skedule.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Kies ten minste een dag van die week.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Die totale slaaptydsduur moet minstens 30 minute wees.';

  @override
  String get distracting_apps_tile_title => 'Afleidende toepassings';

  @override
  String get distracting_apps_tile_subtitle =>
      'Kies watter programme jou aandag van jou slaaptydroetine aflei.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Wysigings aan die lys programme wat aandag aflei word nie toegelaat terwyl die slaaptydskedule aktief is nie.';

  @override
  String get parental_controls_tab_title => 'Ouerkontroles';

  @override
  String get invincible_mode_heading => 'Onoorwinlike modus';

  @override
  String get invincible_mode_tile_title => 'Aktiveer die onoorwinlike modus';

  @override
  String get invincible_mode_info =>
      'Wanneer Invincible Mode aan is, sal jy nie geselekteerde limiete kan aanpas nadat jy jou daaglikse kwota bereik het nie. Jy kan egter veranderinge aanbring binne \'n geselekteerde 10-minute onoorwinlike venster.';

  @override
  String get invincible_mode_snack_alert =>
      'As gevolg van die onoorwinlike modus, word wysigings aan beperkings nie toegelaat nie.';

  @override
  String get invincible_mode_dialog_info =>
      'Is jy heeltemal seker jy wil die Invincible Mode aktiveer? Hierdie aksie is onomkeerbaar. Sodra Invincible Mode aangeskakel is, kan jy dit nie afskakel solank hierdie toepassing op jou toestel geïnstalleer is nie.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Mode kan nie afgeskakel word solank hierdie toepassing op jou toestel geïnstalleer bly nie.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Begin in elk geval';

  @override
  String get invincible_mode_include_timer_tile_title => 'Sluit timer in';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Sluit bekendstellingslimiet in';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Sluit aktiewe tydperk in';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Toepassingsbeperkings';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Voorkom veranderinge aan die toepassing se geselekteerde beperkings sodra die daaglikse limiete oorskry is.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Groepsbeperkings';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Voorkom veranderinge aan die groep se geselekteerde beperkings sodra die daaglikse limiete oorskry word.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Sluit kortbroek timer in';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Voorkom veranderinge nadat u u daaglikse kortbroeklimiet bereik het.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Sluit slaaptyd in';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Voorkom veranderinge tydens die aktiewe slaaptydskedule.';

  @override
  String get protected_access_tile_title => 'Beskermde toegang';

  @override
  String get protected_access_tile_subtitle =>
      'Beskerm NLP digitox met jou toestelslot.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Stel asseblief eers \'n biometriese slot op jou toestel op om hierdie kenmerk te aktiveer.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Jou toestelslot is verwyder. Stel asseblief \'n nuwe slot op om voort te gaan.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Kon nie stawing nie. Jy moet jou toestelslot verifieer om voort te gaan.';

  @override
  String get tamper_protection_tile_title => 'Peuterbeskerming';

  @override
  String get tamper_protection_tile_subtitle =>
      'Voorkom deïnstallering en dwing om die toepassing te stop.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Sodra dit geaktiveer is, sal jy nie NLP digitox se data kan deïnstalleer, forseer stop of uitvee nie, behalwe tydens die geselekteerde deïnstalleringsvenster. Daar is geen oplossings nie.\n\nGaan voort op eie risiko.';

  @override
  String get uninstall_window_tile_title => 'Verwyder venster';

  @override
  String get uninstall_window_tile_subtitle =>
      'Peuterbeskerming kan binne 10 minute vanaf die gekose tyd gedeaktiveer word.';

  @override
  String get invincible_window_tile_title => 'Onoorwinlike venster';

  @override
  String get invincible_window_tile_subtitle =>
      'Geselekteerde limiete kan binne 10 minute vanaf die gekose tyd verander word.';

  @override
  String get shorts_blocking_tab_title => 'Kortbroek blokkeer';

  @override
  String get shorts_blocking_tab_info =>
      'Beheer hoeveel tyd jy aan kort inhoud spandeer op platforms soos Instagram, YouTube, Snapchat en Facebook, insluitend hul webwerwe.';

  @override
  String get short_content_heading => 'Kort inhoud';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Links van $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Stel \'n daaglikse tydsbeperking vir kort inhoud. Sodra jou limiet bereik is, sal die kort inhoud tot middernag onderbreek word.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Beperk kenmerke op Instagram.';

  @override
  String get instagram_features_block_reels => 'Beperk rolle afdeling.';

  @override
  String get instagram_features_block_explore => 'Beperk verken-afdeling.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle => 'Beperk kenmerke op snapchat.';

  @override
  String get snapchat_features_block_spotlight => 'Beperk kolligafdeling.';

  @override
  String get snapchat_features_block_discover => 'Beperk ontdek-afdeling.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle => 'Beperk kortbroeke op YouTube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Beperk rolle op Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Beperk kortbroek op reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Beperk videostroom op X.';

  @override
  String get threads_features_tile_title => 'Drade';

  @override
  String get threads_features_tile_subtitle => 'Beperk video/rolle op Threads.';

  @override
  String get websites_blocking_tab_title => 'Webwerwe wat blokkeer';

  @override
  String get websites_blocking_tab_info =>
      'Blokkeer webwerwe vir volwassenes en enige pasgemaakte werwe wat jy kies om \'n veiliger en meer gefokusde aanlyn ervaring te skep. Neem beheer oor jou blaai en bly afleidingsvry.';

  @override
  String get adult_content_heading => 'Volwasse inhoud';

  @override
  String get block_nsfw_title => 'Blok Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Beperk blaaiers om webwerwe vir volwassenes en pornografie oop te maak.';

  @override
  String get block_nsfw_dialog_info =>
      'Is jy seker? Hierdie aksie is onomkeerbaar. Sodra volwasse werwe-blokkering AAN geskakel is, kan jy dit nie AFskakel solank hierdie toepassing op jou toestel geïnstalleer is nie.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Blok in elk geval';

  @override
  String get blocked_websites_heading => 'Geblokkeerde webwerwe';

  @override
  String get blocked_websites_empty_list_hint =>
      'Klik op \'+ Voeg webwerf by\'-knoppie om afleidende webwerwe by te voeg wat jy wil blokkeer.';

  @override
  String get add_website_fab_button => 'Voeg webwerf by';

  @override
  String get add_website_dialog_title => 'Afleidende webwerf';

  @override
  String get add_website_dialog_info =>
      'Voer url van \'n webwerf in wat jy wil blokkeer.';

  @override
  String get add_website_dialog_is_nsfw => 'Is nsfw webwerf?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Waarskuwing: Nsfw-werwe kan nie verwyder word sodra dit bygevoeg is nie.';

  @override
  String get add_website_dialog_button_block => 'Blok';

  @override
  String get add_website_already_exist_snack_alert =>
      'Die URL is reeds by die lys van geblokkeerde webwerwe gevoeg.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Ongeldige URL! Kan nie die gasheernaam ontleed nie.';

  @override
  String get remove_website_dialog_title => 'Verwyder webwerf';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Is jy seker? jy wil \'$websitehost\' van geblokkeerde webwerwe verwyder.';
  }

  @override
  String get focus_tab_title => 'Fokus';

  @override
  String get focus_tab_info =>
      'Wanneer jy tyd nodig het om te fokus, begin \'n nuwe sessie deur die tipe te kies, steurende programme te kies om te onderbreek, en Aktiveer Moenie Steur Nie vir ononderbroke konsentrasie.';

  @override
  String get active_session_card_title => 'Aktiewe sessie';

  @override
  String get active_session_card_info =>
      'Jy het \'n aktiewe fokussessie wat hardloop! Klik \'Bekyk\' om jou vordering na te gaan en te sien hoeveel tyd verloop het.';

  @override
  String get active_session_card_view_button => 'Uitsig';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Verwydering van toepassings van die afleidende toepassingslys word nie toegelaat terwyl \'n Fokussessie aktief is nie. Jy kan egter steeds bykomende programme by die lys voeg gedurende hierdie tyd.';

  @override
  String get focus_profile_tile_title => 'Fokus profiel';

  @override
  String get focus_session_duration_tile_title => 'Sessie duur';

  @override
  String get focus_session_duration_tile_subtitle => 'Oneindig (tensy jy stop)';

  @override
  String get focus_session_duration_dialog_info =>
      'Kies asseblief die verlangde tydsduur vir hierdie fokussessie, om te bepaal hoe lank jy gefokus en sonder afleiding wil bly.';

  @override
  String get focus_profile_customization_tile_title => 'Profielaanpassing';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Pasmaak instellings vir die geselekteerde profiel.';

  @override
  String get focus_enforce_tile_title => 'Dwing sessie af';

  @override
  String get focus_enforce_tile_subtitle =>
      'Verhoed dat \'n sessie beëindig word voordat die tyd verby is.';

  @override
  String get focus_session_start_button => 'Swaai om sessie te begin';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Kies ten minste een afleidende toepassing om fokussessie te begin';

  @override
  String get focus_session_already_active_snack_alert =>
      'Jy het reeds \'n aktiewe fokussessie aan die gang. Voltooi of stop asseblief jou huidige sessie voordat jy \'n nuwe een begin.';

  @override
  String get focus_session_type_study => 'Studie';

  @override
  String get focus_session_type_work => 'Werk';

  @override
  String get focus_session_type_exercise => 'Oefen';

  @override
  String get focus_session_type_meditation => 'Meditasie';

  @override
  String get focus_session_type_creativeWriting => 'Kreatiewe Skryfwerk';

  @override
  String get focus_session_type_reading => 'Lees';

  @override
  String get focus_session_type_programming => 'Programmering';

  @override
  String get focus_session_type_chores => 'Takies';

  @override
  String get focus_session_type_projectPlanning => 'Projek Beplanning';

  @override
  String get focus_session_type_artAndDesign => 'Kuns en Ontwerp';

  @override
  String get focus_session_type_languageLearning => 'Taalleer';

  @override
  String get focus_session_type_musicPractice => 'Musiek Oefening';

  @override
  String get focus_session_type_selfCare => 'Selfsorg';

  @override
  String get focus_session_type_brainstorming => 'Dinkskrum';

  @override
  String get focus_session_type_skillDevelopment => 'Vaardigheidsontwikkeling';

  @override
  String get focus_session_type_research => 'Navorsing';

  @override
  String get focus_session_type_networking => 'Netwerk';

  @override
  String get focus_session_type_cooking => 'Kook';

  @override
  String get focus_session_type_sportsTraining => 'Sport Opleiding';

  @override
  String get focus_session_type_restAndRelaxation => 'Rus en Ontspanning';

  @override
  String get focus_session_type_other => 'Ander';

  @override
  String get timeline_tab_title => 'Tydlyn';

  @override
  String get focus_timeline_tab_info =>
      'Verken jou fokusreis deur \'n datum op die kalender te kies. Volg jou vordering, hersien jou suksesse en leer uit die uitdagings.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Jou totale produktiewe tyd vir die geselekteerde maand is $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktiewe dae';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Jy het \'n totaal van $daysCount produktiewe dae in die geselekteerde maand gehad.';
  }

  @override
  String get selected_day_focused_time_label => 'Gefokusde tyd';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Jou totale gefokusde tyd vir die gekose dag is $timeString.';
  }

  @override
  String get calender_heading => 'Kalender';

  @override
  String get your_sessions_heading => 'Jou sessies';

  @override
  String get your_sessions_empty_list_hint =>
      'Geen fokussessies is vir die gekose dag aangeteken nie.';

  @override
  String get focus_session_tile_timestamp_label => 'Tydstempel';

  @override
  String get focus_session_tile_duration_label => 'Duur';

  @override
  String get focus_session_tile_reflection_label => 'Refleksie';

  @override
  String get focus_session_state_active => 'Aktief';

  @override
  String get focus_session_state_successful => 'Suksesvol';

  @override
  String get focus_session_state_failed => 'Misluk';

  @override
  String get active_session_tab_title => 'Sessie';

  @override
  String get active_session_none_warning =>
      'Geen aktiewe sessie gevind nie. Keer terug na die tuisskerm.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Hou aan druk';

  @override
  String get active_session_finish_dialog_title => 'Voltooi';

  @override
  String get active_session_finish_dialog_info =>
      'Bly sterk! Jy bou waardevolle fokus. Is jy seker jy wil hierdie fokussessie beëindig? Elke ekstra oomblik tel vir jou doelwitte.';

  @override
  String get active_session_giveup_dialog_title => 'Gee op';

  @override
  String get active_session_giveup_dialog_info =>
      'Hou vas! Jy is amper daar, moenie moed opgee nie! Is jy seker jy wil hierdie fokussessie vroeg beëindig? Vordering sal verlore gaan.';

  @override
  String get active_session_reflection_dialog_title => 'Sessie refleksie';

  @override
  String get active_session_reflection_dialog_info =>
      'Neem \'n oomblik om na te dink oor jou vordering. Wat is jou doelwit vir hierdie sessie? Wat het jy tydens hierdie sessie bereik?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Wenk: Jy kan dit altyd later in die sessietydlyn wysig.';

  @override
  String get active_session_giveup_snack_alert =>
      'Jy het opgegee! Moenie bekommerd wees nie, jy kan volgende keer beter doen. Elke poging tel – gaan net voort';

  @override
  String get active_session_quote_one => 'Elke tree tel, bly sterk en hou aan';

  @override
  String get active_session_quote_two =>
      'Bly gefokus! jy maak ongelooflike vordering';

  @override
  String get active_session_quote_three =>
      'Jy verpletter dit! Hou die momentum aan die gang';

  @override
  String get active_session_quote_four =>
      'Nog net \'n bietjie om te gaan, jy doen fantasties';

  @override
  String active_session_quote_five(String durationString) {
    return 'Baie geluk 🎉 \n Jy het jou fokussessie van $durationString voltooi.\n\n Puik werk, hou aan met die wonderlike werk';
  }

  @override
  String get restriction_groups_tab_title => 'Beperkingsgroepe';

  @override
  String get restriction_groups_tab_info =>
      'Stel \'n gekombineerde skermtydlimiet vir \'n groep programme. Sodra die totale gebruik jou limiet bereik, sal alle programme in die groep onderbreek word om te help om fokus en balans te behou.';

  @override
  String get restriction_group_time_spent_label => 'Tyd spandeer vandag';

  @override
  String get restriction_group_time_left_label => 'Tyd oor vandag';

  @override
  String get restriction_group_name_tile_title => 'Groepnaam';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Voer \'n naam vir die beperkingsgroep in om te help om dit maklik te identifiseer en te bestuur.';

  @override
  String get restriction_group_timer_tile_title => 'Groepafteller';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Stel \'n daaglikse tydsbeperking vir hierdie groep. Sodra jou limiet bereik is, sal al die programme in hierdie groep tot middernag onderbreek word.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Groep aktiewe tydperk';

  @override
  String get remove_restriction_group_dialog_title => 'Verwyder groep';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Is jy seker? jy wil \'$groupName\' van beperkingsgroepe verwyder.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Stel óf \'n timer óf \'n aktiewe tydperk limiet.';

  @override
  String get notifications_empty_list_hint =>
      'Geen kennisgewings is vir die dag saamgevoeg nie.';

  @override
  String get conversations_label => 'Gesprekke';

  @override
  String get last_24_hours_heading => 'Laaste 24 uur';

  @override
  String get notification_timeline_tab_info =>
      'Blaai deur jou kennisgewinggeskiedenis deur \'n datum op die kalender te kies. Kyk watter toepassings jou aandag getrek het en besin oor jou digitale gewoontes.';

  @override
  String get monthly_label => 'Maandeliks';

  @override
  String get daily_label => 'Daagliks';

  @override
  String get search_notifications_sheet_info =>
      'Vind maklik vorige kennisgewings deur deur hul titel of inhoud te soek. Help jou om vinnig belangrike waarskuwings op te spoor.';

  @override
  String get search_notifications_hint => 'Soek kennisgewings...';

  @override
  String get search_notifications_empty_list_hint =>
      'Geen kennisgewings gevind wat by jou soektog pas nie.';

  @override
  String get app_info_none_warning =>
      'Kon nie die toepassing vir die gegewe pakket kry nie. Keer terug na die tuisskerm.';

  @override
  String get emergency_fab_button => 'Noodgeval';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Hierdie handeling sal die programblokkering vir die volgende 5 minute onderbreek. Jy het $leftPassesCount-passe oor. Nadat alle passe gebruik is, sal die toepassing tot middernag geblokkeer bly, of die aktiewe fokussessie eindig.\n\nWil jy nog voortgaan?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Gebruik in elk geval';

  @override
  String get emergency_started_snack_alert =>
      'Die programblokkering word onderbreek en sal oor 5 minute hervat blokkeer.';

  @override
  String get emergency_already_active_snack_alert =>
      'Die programblokkering is tans óf onderbreek óf onaktief. As kennisgewings geaktiveer is, sal jy opdaterings ontvang oor die oorblywende tyd.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Jy het al jou noodpasse gebruik. Die geblokkeerde toepassings sal tot middernag geblokkeer bly, of die aktiewe fokussessie eindig.';

  @override
  String get app_limit_status_not_set => 'Nie gestel nie';

  @override
  String get app_timer_tile_title => 'App timer';

  @override
  String get app_timer_picker_dialog_info =>
      'Stel \'n daaglikse tydsbeperking vir hierdie toepassing. Sodra jou limiet bereik is, sal die toepassing tot middernag onderbreek word.';

  @override
  String get usage_reminders_tile_title => 'Gebruikherinnerings';

  @override
  String get usage_reminders_tile_subtitle =>
      'Sagte stokkies wanneer tydprogramme gebruik word.';

  @override
  String get app_launch_limit_tile_title => 'Begin limiet';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Het vandag $count keer bekendgestel.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Stel hoeveel keer jy hierdie toepassing elke dag kan oopmaak. Sodra die limiet bereik is, sal dit tot middernag onderbreek word.';

  @override
  String get app_active_period_tile_title => 'Aktiewe tydperk';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Van $startTime na $endTime';
  }

  @override
  String get internet_access_tile_title => 'Internettoegang';

  @override
  String get internet_access_tile_subtitle =>
      'Skakel af om app se internet te blokkeer.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '$appName se internet is geblokkeer.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '$appName se internet is gedeblokkeer.';
  }

  @override
  String get launch_app_tile_title => 'Begin toepassing';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Maak $appName oop.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Gaan na programinstellings';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Bestuur programinstellings soos kennisgewings, toestemmings, berging en meer.';

  @override
  String get include_in_stats_tile_title => 'Sluit by skermgebruik in';

  @override
  String get include_in_stats_tile_subtitle =>
      'Skakel af om hierdie toepassing van totale skermgebruik uit te sluit.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName is uitgesluit van totale skermgebruik.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName is ingesluit by die totale skermgebruik.';
  }

  @override
  String get general_tab_title => 'Algemeen';

  @override
  String get appearance_heading => 'Voorkoms';

  @override
  String get theme_mode_tile_title => 'Tema-modus';

  @override
  String get theme_mode_system_label => 'Stelsel';

  @override
  String get theme_mode_light_label => 'Lig';

  @override
  String get theme_mode_dark_label => 'Donker';

  @override
  String get material_color_tile_title => 'Materiaal kleur';

  @override
  String get amoled_dark_tile_title => 'AMOLED donker';

  @override
  String get amoled_dark_tile_subtitle =>
      'Gebruik suiwer swart kleur vir die donker tema.';

  @override
  String get dynamic_colors_tile_title => 'Dinamiese kleure';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Gebruik toestelkleure indien ondersteun.';

  @override
  String get defaults_heading => 'Verstek';

  @override
  String get app_language_tile_title => 'Toepassingstaal';

  @override
  String get default_home_tab_tile_title => 'Tuis-oortjie';

  @override
  String get usage_history_tile_title => 'Gebruik geskiedenis';

  @override
  String get usage_history_15_days => '15 dae';

  @override
  String get usage_history_1_month => '1 maand';

  @override
  String get usage_history_3_month => '3 maande';

  @override
  String get usage_history_6_month => '6 maande';

  @override
  String get usage_history_1_year => '1 jaar';

  @override
  String get service_heading => 'Diens';

  @override
  String get service_stopping_warning =>
      'As NLP digitox onverwags ophou werk, gee asseblief die \'Ignoreer batteryoptimering\' toestemming om dit op die agtergrond te laat loop. As die probleem voortduur, probeer om NLP digitox te witlys vir ononderbroke werkverrigting.';

  @override
  String get whitelist_app_tile_title => 'Witlys NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Laat NLP digitox toe om outomaties te begin.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Hierdie toestel ondersteun nie outomatiese opstartbestuur nie.';

  @override
  String get database_tab_title => 'Databasis';

  @override
  String get import_db_tile_title => 'Voer databasis in';

  @override
  String get import_db_tile_subtitle => 'Voer databasis vanaf \'n lêer in.';

  @override
  String get export_db_tile_title => 'Voer databasis uit';

  @override
  String get export_db_tile_subtitle => 'Voer databasis uit na \'n lêer.';

  @override
  String get analysis_tab_title => 'Ontleding';

  @override
  String get analysis_7_days => '7 dae';

  @override
  String get analysis_30_days => '30 dae';

  @override
  String get analysis_90_days => '90 dae';

  @override
  String get analysis_screen_time_trend => 'Skermtyd-tendens';

  @override
  String get analysis_no_data_info =>
      'Nog geen skermtyddata vir hierdie tydperk aangeteken nie.';

  @override
  String get analysis_daily_average => 'Daaglikse gemiddelde';

  @override
  String get analysis_total => 'Totaal';

  @override
  String get analysis_no_change => 'Dieselfde as verlede week';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% minder as verlede week';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% meer as verlede week';
  }

  @override
  String get crash_logs_heading => 'Crash logs';

  @override
  String get crash_logs_info =>
      'As u enige probleem ondervind, kan u dit saam met die loglêer op GitHub rapporteer. Die lêer sal besonderhede soos jou toestel se vervaardiger, model, Android-weergawe, SDK-weergawe en ongelukloglêers insluit. Hierdie inligting sal ons help om die probleem meer effektief te identifiseer en op te los.';

  @override
  String get crash_logs_export_tile_title => 'Voer ongeluklogboeke uit';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Voer ongeluklogboeke uit na \'n json-lêer.';

  @override
  String get crash_logs_view_tile_title => 'Bekyk logs';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Verken gestoorde ongeluklogboeke.';

  @override
  String get crash_logs_empty_list_hint =>
      'Geen ongeluk aangeteken tot nou toe nie.';

  @override
  String get crash_logs_clear_tile_title => 'Vee logs uit';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Vee alle crash logs uit databasis.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Is jy seker jy wil alle ongeluklogboeke van die databasis uitvee?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'Duidelik in elk geval';

  @override
  String get about_tab_title => 'Oor';

  @override
  String get changelog_tile_title => 'Veranderlogboek';

  @override
  String get changelog_tile_subtitle => 'Vind uit wat nuut is.';

  @override
  String get full_changelog_tile_title => 'Volledige veranderingslogboek';

  @override
  String get redirected_to_github_subtitle => 'Jy sal na GitHub herlei word.';

  @override
  String get contribute_heading => 'Dra by';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Kyk na die bronkode.';

  @override
  String get report_issue_tile_title => 'Rapporteer \'n probleem';

  @override
  String get suggest_idea_tile_title => 'Stel \'n idee voor';

  @override
  String get write_email_tile_title => 'Skryf aan ons per e-pos';

  @override
  String get write_email_tile_subtitle =>
      'Jy sal na die e-posprogram herlei word.';

  @override
  String get privacy_policy_heading => 'Privaatheidsbeleid';

  @override
  String get privacy_policy_info =>
      'NLP digitox is daartoe verbind om jou privaatheid te beskerm. Ons versamel, berg of dra geen tipe gebruikerdata oor nie. Die toepassing werk heeltemal vanlyn en vereis nie \'n internetverbinding nie, om te verseker dat u persoonlike inligting privaat en veilig op u toestel bly. As \'n gratis en oopbronsagteware-toepassing (FOSS) waarborg NLP digitox volledige deursigtigheid en gebruikersbeheer oor hul data.';

  @override
  String get more_details_button => 'Meer besonderhede';
}
