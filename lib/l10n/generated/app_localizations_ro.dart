// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get mindful_tagline =>
      'Concentrează-te pe ceea ce contează cu adevărat';

  @override
  String get unlock_button_label => 'Deblocați';

  @override
  String get permission_status_off => 'Oprit';

  @override
  String get permission_status_allowed => 'Permis';

  @override
  String get permission_status_not_allowed => 'Nu este permis';

  @override
  String get permission_button_grant_permission => 'Acordați permisiunea';

  @override
  String get permission_button_agree_and_continue => 'De acord și continua';

  @override
  String get permission_button_not_now => 'Nu acum';

  @override
  String get permission_button_help => 'Ajutor?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox este 100% sigur și funcționează offline. Nu colectăm și nu stocăm date personale.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Faceți clic pe butonul $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Selectați NLP digitox în ecranul următor.';

  @override
  String get permission_grant_step_three =>
      '3. Faceți clic și porniți comutatorul ca mai jos.';

  @override
  String get permission_notification_title => 'Trimite notificări';

  @override
  String get permission_alarms_title => 'Alarme și memento-uri';

  @override
  String get permission_alarms_info =>
      'Vă rugăm să acordați permisiunea pentru setarea alarmelor și mementourilor. Acest lucru va permite lui NLP digitox să înceapă programul de culcare la timp și să resetați cronometrele aplicației zilnic la miezul nopții și vă va ajuta să rămâneți pe drumul cel bun.';

  @override
  String get permission_alarms_device_tile_label =>
      'Permite setarea alarmelor și mementourilor';

  @override
  String get permission_usage_title => 'Acces de utilizare';

  @override
  String get permission_usage_info =>
      'Vă rugăm să acordați permisiunea de acces de utilizare. Acest lucru va permite lui NLP digitox să monitorizeze utilizarea aplicațiilor și să gestioneze accesul la anumite aplicații, asigurând un mediu digital mai concentrat și controlat.';

  @override
  String get permission_usage_device_tile_label =>
      'Permite accesul de utilizare';

  @override
  String get permission_overlay_title => 'Afișare suprapunere';

  @override
  String get permission_overlay_info =>
      'Vă rugăm să acordați permisiunea de suprapunere de afișare. Acest lucru va permite NLP digitox să afișeze o suprapunere atunci când este deschisă o aplicație întreruptă, ajutându-vă să rămâneți concentrat și să vă mențineți programul.';

  @override
  String get permission_overlay_device_tile_label =>
      'Permite afișarea peste alte aplicații';

  @override
  String get permission_accessibility_title => 'Accesibilitate';

  @override
  String get permission_accessibility_info =>
      'Vă rugăm să acordați permisiunea de accesibilitate. Acest lucru va permite NLP digitox să restricționeze accesul la conținut video de scurtă durată (de exemplu, Reels, Shorts) în aplicațiile și browserele de rețele sociale și să filtreze site-urile web neadecvate.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox necesită permisiunea de accesibilitate pentru a bloca eficient conținutul scurt și site-urile web.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Utilizați NLP digitox';

  @override
  String get permission_dnd_title => 'Nu deranja';

  @override
  String get permission_dnd_info =>
      'Vă rugăm să acordați acces Nu deranja. Acest lucru va permite lui NLP digitox să pornească și să oprească modul Nu deranjați în timpul programului de culcare.';

  @override
  String get permission_dnd_tile_title => 'Începeți DND';

  @override
  String get permission_dnd_tile_subtitle => 'Activați și modul Nu deranja.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignorați optimizarea bateriei';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Deja nerestricționat';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Dezactivați restricția de fundal';

  @override
  String get permission_battery_optimization_allow_info =>
      'Permiterea „Ignorați optimizarea bateriei” va acorda automat permisiunea „Alarme și mementouri” pe unele dispozitive.';

  @override
  String get permission_vpn_title => 'Creați VPN';

  @override
  String get permission_vpn_info =>
      'Vă rugăm să acordați permisiunea de a crea o conexiune la rețea privată virtuală (VPN). Acest lucru va permite NLP digitox să restricționeze accesul la internet pentru aplicațiile desemnate prin crearea unui VPN local pe dispozitiv.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Privilegiile administrative sunt necesare numai pentru operațiunile esențiale pentru a se asigura că aplicația funcționează corect și rămâne inviolabilă.';

  @override
  String get permission_admin_snack_alert =>
      'Protecția împotriva manipularii poate fi dezactivată numai în intervalul de timp selectat.';

  @override
  String get permission_notification_access_title => 'Acces la notificare';

  @override
  String get permission_notification_access_info =>
      'Vă rugăm să acordați permisiunea de acces la notificări. Acest lucru va permite lui NLP digitox să vă organizeze notificările și să le livreze conform programului dvs.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox necesită acces la notificări la notificări de lot și de programare.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Permite accesul la notificări';

  @override
  String get day_today => 'Astăzi';

  @override
  String get day_yesterday => 'Ieri';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString zile',
      one: '1 zi',
      zero: '0 zile',
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
      other: '$countString ore',
      one: '1 oră',
      zero: '0 ore',
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
      one: '1 minut',
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
      other: '$countString secunde',
      one: '1 secundă',
      zero: '0 secunde',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'şi';

  @override
  String get timer_status_active => 'Activ';

  @override
  String get timer_status_paused => 'Întrerupt';

  @override
  String get create_button => 'Creați';

  @override
  String get update_button => 'Actualizare';

  @override
  String get dialog_button_cancel => 'Anulează';

  @override
  String get dialog_button_remove => 'Eliminați';

  @override
  String get dialog_button_set => 'Setați';

  @override
  String get dialog_button_reset => 'Resetați';

  @override
  String get dialog_button_infinite => 'Infinit';

  @override
  String get schedule_start_label => 'Începeți';

  @override
  String get schedule_end_label => 'Sfârșit';

  @override
  String get exit_without_saving_dialog_info =>
      'Sigur vrei să ieși fără a salva?';

  @override
  String get development_dialog_info =>
      'NLP digitox este în prezent în curs de dezvoltare și poate avea erori sau caracteristici incomplete. Dacă întâmpinați probleme, vă rugăm să le raportați pentru a ne ajuta să ne îmbunătățim.\n\nVă mulțumim pentru feedback!';

  @override
  String get development_dialog_button_report_issue => 'Raportați o problemă';

  @override
  String get development_dialog_button_close => 'Închide';

  @override
  String get dnd_settings_tile_title => 'Nu deranjați setările';

  @override
  String get dnd_settings_tile_subtitle =>
      'Gestionați aplicațiile și notificările care vă pot ajunge în DND.';

  @override
  String get quick_actions_heading => 'Acțiuni rapide';

  @override
  String get select_distracting_apps_heading =>
      'Selectați aplicații care vă distrag atenția';

  @override
  String get your_distracting_apps_heading =>
      'Aplicațiile dvs. care vă distrag atenția';

  @override
  String get select_more_apps_heading => 'Selectați mai multe aplicații';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Adăugarea de aplicații importante de sistem la lista de aplicații care distrag atenția nu este permisă.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Utilizarea ecranului și restricțiile nu sunt disponibile pentru această aplicație. În prezent, numai utilizarea rețelei este accesibilă';

  @override
  String get create_group_fab_button => 'Creați grup';

  @override
  String get active_period_info =>
      'Setați o perioadă de timp în care accesul va fi permis. În afara acestui interval de timp, accesul va fi restricționat.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Selectați cel puțin o aplicație care vă distrage atenția.';

  @override
  String get donation_card_title => 'Sprijină-ne';

  @override
  String get donation_card_info =>
      'NLP digitox este gratuit și open-source, dezvoltat cu luni de dedicare. Dacă te-a ajutat, donația ta ar însemna lumea pentru noi. Fiecare contribuție ne ajută să continuăm să o îmbunătățim și să o menținem pentru toată lumea.';

  @override
  String get operation_failed_snack_alert =>
      'Operațiunea a eșuat, ceva a mers prost!';

  @override
  String get donation_card_button_donate => 'Donează';

  @override
  String get app_restart_dialog_title => 'Trebuie repornit';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox va reporni automat odată ce numărătoarea inversă se termină. Vă rugăm să aveți răbdare, deoarece se aplică modificări.';

  @override
  String get accessibility_tip =>
      'Vrei o blocare mai inteligentă, mai ecologică pentru baterie? Activați permisiunea de accesibilitate pentru NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox nu funcționează? Permiteți „Ignorați optimizarea bateriei” în Setări pentru ca acesta să funcționeze fără probleme.';

  @override
  String get invincible_mode_tip =>
      'Restricții eliminate accidental? Utilizați modul Invincible pentru a le bloca până a doua zi sau în fereastra de ajustare.';

  @override
  String get glance_usage_tip =>
      'Doriți informații? Verificați secțiunea Privire pentru a vedea modelele de utilizare și timpul de utilizare.';

  @override
  String get tamper_protection_tip =>
      'Dezinstalați NLP digitox? Activați mai întâi fereastra de dezinstalare pentru a dezactiva în siguranță protecția împotriva manipulării.';

  @override
  String get notification_blocking_tip =>
      'Doriți să reduceți distracția? Utilizați Blocarea notificărilor pentru a opri aplicațiile selectate.';

  @override
  String get usage_history_tip =>
      'Vrei să reflectezi asupra obiceiurilor tale? Verificați Istoricul utilizării pentru a vedea modelele din trecut.';

  @override
  String get focus_mode_tip =>
      'Ai nevoie de concentrare profundă? Activați modul Focus pentru a bloca aplicațiile și notificările în timpul sarcinilor.';

  @override
  String get bedtime_reminder_tip =>
      'Vrei să-ți îmbunătățești somnul? Setați un memento pentru ora de culcare să se relaxeze noaptea.';

  @override
  String get custom_blocking_tip =>
      'Ai nevoie de o experiență personalizată? Creați reguli de blocare a aplicațiilor care se potrivesc nevoilor dvs.';

  @override
  String get session_timeline_tip =>
      'Doriți să urmăriți sesiunile de focalizare? Vizualizați cronologia pentru a vedea călătoria dvs. de focalizare.';

  @override
  String get short_content_blocking_tip =>
      'Distras de aplicațiile sociale? Blocați conținutul scurt de pe Instagram, YouTube etc., pentru a rămâne concentrat.';

  @override
  String get parental_controls_tip =>
      'Ai nevoie de control parental? Setați restricții pentru dispozitivul copilului dvs. pentru a asigura o experiență sigură.';

  @override
  String get notification_batching_tip =>
      'Doriți să reduceți distracția? Utilizați Notification Lotching pentru a grupa notificările și pentru a le verifica imediat.';

  @override
  String get notification_scheduling_tip =>
      'Trebuie să gestionați notificările? Programați când primiți notificări pentru anumite aplicații.';

  @override
  String get quick_focus_tile_tip =>
      'Aveți nevoie de acces rapid pentru a vă concentra? Adăugați o piesă de focalizare rapidă pentru a activa instantaneu modul de focalizare.';

  @override
  String get app_shortcuts_tip =>
      'Doriți acces instantaneu la aplicație? Adăugați comenzi rapide apăsând lung pe pictograma aplicației pentru acțiuni rapide.';

  @override
  String get backup_usage_db_tip =>
      'Doriți să vă salvați datele? Faceți o copie de rezervă a bazei de date de utilizare pentru a vă păstra în siguranță înregistrările.';

  @override
  String get dynamic_material_color_tip =>
      'Vrei o temă personalizată? Activați Materialul dinamic pe care îl colorați pentru a se potrivi cu tema dispozitivului dvs.';

  @override
  String get amoled_dark_theme_tip =>
      'Doriți să economisiți bateria? Utilizați tema întunecată AMOLED pentru a reduce consumul de energie pe ecranele OLED.';

  @override
  String get customize_usage_history_tip =>
      'Doriți să păstrați istoricul utilizării? Personalizați câte săptămâni de date de stocat în Istoricul utilizării.';

  @override
  String get grouped_apps_blocking_tip =>
      'Doriți să blocați aplicațiile împreună? Utilizați Grupuri de restricții pentru a grupa limitele aplicațiilor și pentru a bloca mai multe aplicații simultan.';

  @override
  String get websites_blocking_tip =>
      'Doriți o experiență de navigare mai curată? Blocați site-urile web personalizate sau NSFW pentru un timp online mai concentrat.';

  @override
  String get data_usage_tip =>
      'Doriți să vă urmăriți datele? Monitorizați utilizarea datelor mobile și Wi-Fi pentru consumul de internet.';

  @override
  String get block_internet_tip =>
      'Trebuie să blocați internetul unei aplicații? Opriți internetul pentru o anumită aplicație din tabloul de bord al aplicației.';

  @override
  String get emergency_passes_tip =>
      'Ai nevoie de o pauză? Utilizați 3 permise de urgență zilnic pentru a debloca temporar aplicațiile timp de 5 minute.';

  @override
  String get onboarding_skip_btn_label => 'Sari peste';

  @override
  String get onboarding_finish_setup_btn_label => 'Finalizați configurarea';

  @override
  String get onboarding_page_welcome_title => 'Bine ați venit la NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Preia controlul asupra vieții tale digitale și construiește obiceiuri mai sănătoase de utilizare a ecranului. NLP digitox te ajută să rămâi concentrat, să reduci distragerile și să faci alegeri conștiente în fiecare zi.';

  @override
  String get onboarding_page_statistics_title => 'Cunoaște-ți obiceiurile.';

  @override
  String get onboarding_page_statistics_info =>
      'Înțelege-ți tiparele digitale cu informații detaliate despre timpul petrecut pe ecran, utilizarea aplicațiilor și tendințele de concentrare. Urmărește-ți progresul și vezi cum mici schimbări duc la îmbunătățiri mari.';

  @override
  String get onboarding_page_one_title => 'Maestru Focus.';

  @override
  String get onboarding_page_one_info =>
      'Întrerupeți aplicațiile care vă distrag atenția, blocați conținutul scurt și rămâneți pe drumul cel bun cu sesiuni de focalizare personalizabile. Indiferent dacă lucrați, studiați sau vă relaxați, NLP digitox vă ajută să păstrați controlul.';

  @override
  String get onboarding_page_two_title => 'Blocați distragerile.';

  @override
  String get onboarding_page_two_info =>
      'Setați limite de utilizare, întrerupeți automat aplicațiile și creați obiceiuri digitale mai sănătoase. Utilizați modul Ora de culcare pentru a vă relaxa și a vă bucura de o noapte fără distrageri.';

  @override
  String get onboarding_page_three_title =>
      'În primul rând, confidențialitatea.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox este 100% open-source și funcționează în întregime offline. Nu colectăm și nu partajăm datele dumneavoastră cu caracter personal – confidențialitatea dumneavoastră este garantată în toate privințele.';

  @override
  String get onboarding_page_permissions_title => 'Permisiuni esențiale.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox necesită următoarele permisiuni esențiale pentru a urmări și gestiona timpul petrecut pe ecran, ajutând la reducerea distragerilor și la îmbunătățirea concentrării.';

  @override
  String get dashboard_tab_title => 'Tabloul de bord';

  @override
  String get focus_now_fab_button => 'Concentrează-te acum';

  @override
  String get welcome_greetings => 'Bine ai revenit,';

  @override
  String get username_snack_alert =>
      'Apăsați lung pentru a edita numele de utilizator.';

  @override
  String get username_dialog_title => 'Nume de utilizator';

  @override
  String get username_dialog_info =>
      'Introduceți numele de utilizator care va fi afișat pe tabloul de bord.';

  @override
  String get username_dialog_button_apply => 'Aplicați';

  @override
  String get glance_tile_title => 'Privire';

  @override
  String get glance_tile_subtitle =>
      'Aruncă o privire rapidă asupra utilizării tale.';

  @override
  String get parental_controls_tile_subtitle =>
      'Modul invincibil și protecție împotriva falsificării.';

  @override
  String get restrictions_heading => 'Restricții';

  @override
  String get apps_blocking_tile_title => 'Blocarea aplicațiilor';

  @override
  String get apps_blocking_tile_subtitle =>
      'Limitați aplicațiile în mai multe moduri.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Blocarea aplicațiilor grupate';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Limitați grupul de aplicații simultan.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Limitați conținutul scurt pe mai multe platforme.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Limitați site-urile web pentru adulți și personalizate.';

  @override
  String get screen_time_label => 'Timpul ecranului';

  @override
  String get total_data_label => 'Date totale';

  @override
  String get mobile_data_label => 'Date mobile';

  @override
  String get wifi_data_label => 'Date Wifi';

  @override
  String get focus_today_label => 'Concentrează-te astăzi';

  @override
  String get focus_weekly_label => 'Concentrați-vă săptămânal';

  @override
  String get focus_monthly_label => 'Concentrați-vă lunar';

  @override
  String get focus_lifetime_label => 'Concentrați-vă toată viața';

  @override
  String get longest_streak_label => 'Cea mai lungă serie';

  @override
  String get current_streak_label => 'Serie actuală';

  @override
  String get successful_sessions_label => 'Sesiuni de succes';

  @override
  String get failed_sessions_label => 'Sesiuni eșuate';

  @override
  String get statistics_tab_title => 'Statistici';

  @override
  String get screen_segment_label => 'Ecran';

  @override
  String get data_segment_label => 'Date';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Cele mai folosite aplicații';

  @override
  String get show_all_apps_tile_title => 'Afișați toate aplicațiile';

  @override
  String get search_apps_hint => 'Căutați aplicații...';

  @override
  String get notifications_tab_title => 'Notificări';

  @override
  String get notifications_tab_info =>
      'Notificări în lot din aplicații și setați programe precum dimineața, prânzul, seara și seara. Rămâneți la curent fără întreruperi constante.';

  @override
  String get batched_apps_tile_title => 'Aplicații grupate';

  @override
  String get batch_recap_dropdown_title => 'Tip de recapitulare lot';

  @override
  String get batch_recap_dropdown_info =>
      'Alegeți ce să împingeți când se declanșează o programare - toate notificările sau doar un rezumat.';

  @override
  String get batch_recap_option_summery_only => 'Numai rezumat';

  @override
  String get batch_recap_option_all_notifications => 'Toate notificările';

  @override
  String get notification_history_tile_title => 'Istoricul notificărilor';

  @override
  String get store_all_tile_title => 'Stocați toate notificările';

  @override
  String get store_all_tile_subtitle => 'Salvați și notificările negrupate.';

  @override
  String get schedules_heading => 'Programe';

  @override
  String get new_schedule_fab_button => 'Program nou';

  @override
  String get new_schedule_dialog_info =>
      'Introduceți un nume pentru programul de notificare pentru a ajuta la identificarea acestuia cu ușurință.';

  @override
  String get new_schedule_dialog_field_label => 'Numele programului';

  @override
  String get bedtime_tab_title => 'Ora de culcare';

  @override
  String get bedtime_tab_info =>
      'Setează-ți programul de culcare selectând o perioadă de timp și zile ale săptămânii. Alegeți aplicații care vă distrag atenția pe care să le blocați și să activați modul Nu deranjați (DND) pentru o noapte liniștită.';

  @override
  String get schedule_tile_title => 'Program';

  @override
  String get schedule_tile_subtitle =>
      'Activați sau dezactivați programul zilnic.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Selectați cel puțin o zi a săptămânii.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Durata totală de culcare trebuie să fie de cel puțin 30 de minute.';

  @override
  String get distracting_apps_tile_title => 'Aplicații care distrag atenția';

  @override
  String get distracting_apps_tile_subtitle =>
      'Selectați ce aplicații vă distrage atenția de la rutina de culcare.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Modificările la lista de aplicații care distrag atenția nu sunt permise în timp ce programul de culcare este activ.';

  @override
  String get parental_controls_tab_title => 'Control parental';

  @override
  String get invincible_mode_heading => 'Modul invincibil';

  @override
  String get invincible_mode_tile_title => 'Activați modul invincibil';

  @override
  String get invincible_mode_info =>
      'Când modul Invincible este activat, nu veți putea ajusta limitele selectate după ce ați atins cota zilnică. Cu toate acestea, puteți face modificări într-o fereastră invincibilă selectată de 10 minute.';

  @override
  String get invincible_mode_snack_alert =>
      'Din cauza modului invincibil, modificările restricțiilor nu sunt permise.';

  @override
  String get invincible_mode_dialog_info =>
      'Sunteți absolut sigur că doriți să activați modul Invincible? Această acțiune este ireversibilă. Odată ce modul Invincible este pornit, nu îl puteți dezactiva atâta timp cât această aplicație este instalată pe dispozitiv.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Modul Invincible nu poate fi dezactivat atâta timp cât această aplicație rămâne instalată pe dispozitiv.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Începe oricum';

  @override
  String get invincible_mode_include_timer_tile_title =>
      'Includeți cronometrul';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Includeți limita de lansare';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Includeți perioada activă';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Restricții ale aplicației';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Preveniți modificări ale restricțiilor selectate ale aplicației odată ce limitele zilnice sunt depășite.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Restricții de grup';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Preveniți modificări ale restricțiilor selectate ale grupului odată ce limitele zilnice sunt depășite.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Includeți cronometrul pentru pantaloni scurți';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Împiedică modificările după atingerea limitei zilnice de pantaloni scurți.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Include ora de culcare';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Previne schimbările în timpul programului activ de culcare.';

  @override
  String get protected_access_tile_title => 'Acces protejat';

  @override
  String get protected_access_tile_subtitle =>
      'Protejați NLP digitox cu blocarea dispozitivului.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Vă rugăm să configurați mai întâi o blocare biometrică pe dispozitiv pentru a activa această funcție.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Blocarea dispozitivului dvs. a fost eliminată. Pentru a continua, vă rugăm să configurați o nouă blocare.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Autentificarea eșuată. Trebuie să verificați blocarea dispozitivului pentru a continua.';

  @override
  String get tamper_protection_tile_title => 'Protecție împotriva manipulării';

  @override
  String get tamper_protection_tile_subtitle =>
      'Preveniți dezinstalarea și forțați oprirea aplicației.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Odată activat, nu veți putea să dezinstalați, să forțați oprirea sau să ștergeți datele NLP digitox, decât în ​​timpul ferestrei de dezinstalare selectate. Nu există soluții alternative.\n\nProcedați pe propriul risc.';

  @override
  String get uninstall_window_tile_title => 'Dezinstalează fereastra';

  @override
  String get uninstall_window_tile_subtitle =>
      'Protecția împotriva manipularii poate fi dezactivată în 10 minute de la ora selectată.';

  @override
  String get invincible_window_tile_title => 'Fereastra invincibilă';

  @override
  String get invincible_window_tile_subtitle =>
      'Limitele selectate pot fi modificate în 10 minute de la ora selectată.';

  @override
  String get shorts_blocking_tab_title => 'Blocarea pantalonilor scurți';

  @override
  String get shorts_blocking_tab_info =>
      'Controlați cât timp petreceți pentru conținut scurt pe platforme precum Instagram, YouTube, Snapchat și Facebook, inclusiv site-urile lor web.';

  @override
  String get short_content_heading => 'Conținut scurt';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'A plecat de la $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Setați o limită de timp zilnică pentru conținut scurt. Odată ce limita este atinsă, conținutul scurt va fi întrerupt până la miezul nopții.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Restricționați funcțiile pe instagram.';

  @override
  String get instagram_features_block_reels => 'Secțiunea Restricționați role.';

  @override
  String get instagram_features_block_explore =>
      'Restricționați secțiunea de explorare.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Restricționați funcțiile pe Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Restricționați secțiunea reflectoarelor.';

  @override
  String get snapchat_features_block_discover =>
      'Restricționați secțiunea descoperire.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Restricționați scurtmetraje pe youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Restricționați rolele pe Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle =>
      'Restricționați scurtmetraje pe reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Restricționați fluxul video pe X.';

  @override
  String get threads_features_tile_title => 'Fire';

  @override
  String get threads_features_tile_subtitle =>
      'Restricționați videoclipurile/bobinele pe fire.';

  @override
  String get websites_blocking_tab_title => 'Blocarea site-urilor web';

  @override
  String get websites_blocking_tab_info =>
      'Blocați site-urile web pentru adulți și orice site-uri personalizate pe care le alegeți pentru a crea o experiență online mai sigură și mai concentrată. Preluați-vă controlul asupra navigării dvs. și rămâneți fără distracție.';

  @override
  String get adult_content_heading => 'Conținut pentru adulți';

  @override
  String get block_nsfw_title => 'Bloc Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Limitați browserele să deschidă site-uri web pentru adulți și porno.';

  @override
  String get block_nsfw_dialog_info =>
      'esti sigur? Această acțiune este ireversibilă. Odată ce blocarea site-urilor pentru adulți este activată, nu o puteți dezactiva atâta timp cât această aplicație este instalată pe dispozitiv.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Blocați oricum';

  @override
  String get blocked_websites_heading => 'Site-uri web blocate';

  @override
  String get blocked_websites_empty_list_hint =>
      'Faceți clic pe butonul „+ Adăugați site web” pentru a adăuga site-uri web care vă distrag atenția pe care doriți să le blocați.';

  @override
  String get add_website_fab_button => 'Adăugați site-ul web';

  @override
  String get add_website_dialog_title => 'Site care distrag atenția';

  @override
  String get add_website_dialog_info =>
      'Introduceți adresa URL a unui site web pe care doriți să îl blocați.';

  @override
  String get add_website_dialog_is_nsfw => 'Este site-ul nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Avertisment: site-urile Nsfw nu pot fi eliminate odată adăugate.';

  @override
  String get add_website_dialog_button_block => 'Blocați';

  @override
  String get add_website_already_exist_snack_alert =>
      'Adresa URL a fost deja adăugată la lista de site-uri web blocate.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Adresă URL nevalidă! Nu se poate analiza numele gazdei.';

  @override
  String get remove_website_dialog_title => 'Eliminați site-ul web';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'esti sigur? doriți să eliminați „$websitehost” de pe site-urile web blocate.';
  }

  @override
  String get focus_tab_title => 'Concentrează-te';

  @override
  String get focus_tab_info =>
      'Când aveți nevoie de timp pentru a vă concentra, începeți o nouă sesiune selectând tipul, alegând aplicațiile care vă distrag atenția pe care să le întrerupeți și activând Nu deranjați pentru o concentrare neîntreruptă.';

  @override
  String get active_session_card_title => 'Sesiune activă';

  @override
  String get active_session_card_info =>
      'Ai o sesiune de focalizare activă care rulează! Faceți clic pe „Vizualizare” pentru a verifica progresul și pentru a vedea cât timp a trecut.';

  @override
  String get active_session_card_view_button => 'Vedeți';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Eliminarea aplicațiilor din lista de aplicații care distrag atenția nu este permisă în timp ce o sesiune Focus este activă. Cu toate acestea, puteți adăuga în continuare aplicații suplimentare la listă în acest timp.';

  @override
  String get focus_profile_tile_title => 'Profil de focalizare';

  @override
  String get focus_session_duration_tile_title => 'Durata sesiunii';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Infinit (dacă nu te oprești)';

  @override
  String get focus_session_duration_dialog_info =>
      'Vă rugăm să selectați durata dorită pentru această sesiune de concentrare, determinând cât timp doriți să rămâneți concentrat și fără distracție.';

  @override
  String get focus_profile_customization_tile_title =>
      'Personalizarea profilului';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Personalizați setările pentru profilul selectat.';

  @override
  String get focus_enforce_tile_title => 'Aplicați sesiunea';

  @override
  String get focus_enforce_tile_subtitle =>
      'Împiedică încheierea unei sesiuni înainte de încheierea timpului.';

  @override
  String get focus_session_start_button => 'Glisează pentru a începe sesiunea';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Selectați cel puțin o aplicație care vă distrage atenția pentru a începe sesiunea de focalizare';

  @override
  String get focus_session_already_active_snack_alert =>
      'Aveți deja o sesiune de focalizare activă în desfășurare. Vă rugăm să finalizați sau să opriți sesiunea curentă înainte de a începe una nouă.';

  @override
  String get focus_session_type_study => 'Studiază';

  @override
  String get focus_session_type_work => 'Munca';

  @override
  String get focus_session_type_exercise => 'Exercițiu';

  @override
  String get focus_session_type_meditation => 'Meditația';

  @override
  String get focus_session_type_creativeWriting => 'Scriere creativă';

  @override
  String get focus_session_type_reading => 'Citirea';

  @override
  String get focus_session_type_programming => 'Programare';

  @override
  String get focus_session_type_chores => 'Treburi';

  @override
  String get focus_session_type_projectPlanning => 'Planificarea Proiectului';

  @override
  String get focus_session_type_artAndDesign => 'Artă și Design';

  @override
  String get focus_session_type_languageLearning =>
      'Învățarea limbilor străine';

  @override
  String get focus_session_type_musicPractice => 'Practică muzicală';

  @override
  String get focus_session_type_selfCare => 'Îngrijire de sine';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Dezvoltarea aptitudinilor';

  @override
  String get focus_session_type_research => 'Cercetare';

  @override
  String get focus_session_type_networking => 'Rețele';

  @override
  String get focus_session_type_cooking => 'Gătit';

  @override
  String get focus_session_type_sportsTraining => 'Antrenament sportiv';

  @override
  String get focus_session_type_restAndRelaxation => 'Odihnă și Relaxare';

  @override
  String get focus_session_type_other => 'Altele';

  @override
  String get timeline_tab_title => 'Cronologie';

  @override
  String get focus_timeline_tab_info =>
      'Explorați călătoria dvs. de focalizare selectând o dată din calendar. Urmăriți-vă progresul, revizuiți-vă succesele și învățați din provocări.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Timpul total de productivitate pentru luna selectată este $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Zile productive';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Ați avut un total de $daysCount zile productive în luna selectată.';
  }

  @override
  String get selected_day_focused_time_label => 'Timp concentrat';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Timpul total de concentrare pentru ziua selectată este $timeString.';
  }

  @override
  String get calender_heading => 'Calendar';

  @override
  String get your_sessions_heading => 'Sesiunile tale';

  @override
  String get your_sessions_empty_list_hint =>
      'Nu au fost înregistrate sesiuni de focalizare pentru ziua selectată.';

  @override
  String get focus_session_tile_timestamp_label => 'Marca temporală';

  @override
  String get focus_session_tile_duration_label => 'Durata';

  @override
  String get focus_session_tile_reflection_label => 'Reflecție';

  @override
  String get focus_session_state_active => 'Activ';

  @override
  String get focus_session_state_successful => 'De succes';

  @override
  String get focus_session_state_failed => 'A eșuat';

  @override
  String get active_session_tab_title => 'Sesiune';

  @override
  String get active_session_none_warning =>
      'Nu a fost găsită nicio sesiune activă. Revenind la ecranul de start.';

  @override
  String get active_session_dialog_button_keep_pushing =>
      'Continuați să împingeți';

  @override
  String get active_session_finish_dialog_title => 'Termină';

  @override
  String get active_session_finish_dialog_info =>
      'Fii tare! Vă construiți o concentrare valoroasă. Sigur doriți să încheiați această sesiune de concentrare? Fiecare moment în plus contează pentru obiectivele tale.';

  @override
  String get active_session_giveup_dialog_title => 'Renunță';

  @override
  String get active_session_giveup_dialog_info =>
      'Stai bine! Aproape că ești acolo, nu te da bătut acum! Sigur doriți să încheiați această sesiune de focalizare mai devreme? Progresul va fi pierdut.';

  @override
  String get active_session_reflection_dialog_title => 'Reflecție de sesiune';

  @override
  String get active_session_reflection_dialog_info =>
      'Fă-ți un moment pentru a reflecta la progresul tău. Care este scopul tău pentru această sesiune? Ce ai realizat în această sesiune?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Sfat: puteți oricând să editați acest lucru mai târziu în cronologia sesiunii.';

  @override
  String get active_session_giveup_snack_alert =>
      'Ai renunțat! Nu-ți face griji, poți să faci mai bine data viitoare. Fiecare efort contează - continuați';

  @override
  String get active_session_quote_one =>
      'Fiecare pas contează, fii puternic și continuă';

  @override
  String get active_session_quote_two =>
      'Rămâi concentrat! faci progrese uimitoare';

  @override
  String get active_session_quote_three => 'Îl striviți! Păstrați impulsul';

  @override
  String get active_session_quote_four =>
      'Mai rămâne puțin, te descurci fantastic';

  @override
  String active_session_quote_five(String durationString) {
    return 'Felicitări 🎉 \n Ți-ai încheiat sesiunea de focalizare a $durationString.\n\nO treabă grozavă, ține tot așa';
  }

  @override
  String get restriction_groups_tab_title => 'Grupuri de restricții';

  @override
  String get restriction_groups_tab_info =>
      'Setați o limită de timp de utilizare combinată pentru un grup de aplicații. Odată ce utilizarea totală atinge limita dvs., toate aplicațiile din grup vor fi întrerupte pentru a vă menține concentrarea și echilibrul.';

  @override
  String get restriction_group_time_spent_label => 'Timpul petrecut astăzi';

  @override
  String get restriction_group_time_left_label => 'Timp rămas astăzi';

  @override
  String get restriction_group_name_tile_title => 'Numele grupului';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Introduceți un nume pentru grupul de restricții pentru a ajuta la identificarea și gestionarea acestuia cu ușurință.';

  @override
  String get restriction_group_timer_tile_title => 'Cronometru de grup';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Setați o limită de timp zilnică pentru acest grup. Odată ce limita dvs. este atinsă, toate aplicațiile din acest grup vor fi întrerupte până la miezul nopții.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Perioada activă a grupului';

  @override
  String get remove_restriction_group_dialog_title => 'Eliminați grupul';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'esti sigur? doriți să eliminați „$groupName” din grupurile de restricții.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Setați fie un cronometru, fie o limită de perioadă activă.';

  @override
  String get notifications_empty_list_hint =>
      'Nu au fost grupate notificări pentru ziua respectivă.';

  @override
  String get conversations_label => 'Conversații';

  @override
  String get last_24_hours_heading => 'Ultimele 24 de ore';

  @override
  String get notification_timeline_tab_info =>
      'Răsfoiți istoricul notificărilor selectând o dată din calendar. Vedeți ce aplicații v-au atras atenția și reflectați asupra obiceiurilor dvs. digitale.';

  @override
  String get monthly_label => 'Lunar';

  @override
  String get daily_label => 'Zilnic';

  @override
  String get search_notifications_sheet_info =>
      'Găsiți cu ușurință notificările anterioare căutând prin titlul sau conținutul acestora. Vă ajută să localizați rapid alertele importante.';

  @override
  String get search_notifications_hint => 'Caută notificări...';

  @override
  String get search_notifications_empty_list_hint =>
      'Nu s-au găsit notificări care să corespundă căutării dvs.';

  @override
  String get app_info_none_warning =>
      'Nu s-a putut găsi aplicația pentru pachetul dat. Revenind la ecranul de start.';

  @override
  String get emergency_fab_button => 'Urgență';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Această acțiune va întrerupe blocarea aplicației pentru următoarele 5 minute. Mai aveți permise $leftPassesCount. După folosirea tuturor permiselor, aplicația va rămâne blocată până la miezul nopții sau se termină sesiunea de focalizare activă.\n\nTotuși doriți să continuați?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Folosește oricum';

  @override
  String get emergency_started_snack_alert =>
      'Blocarea aplicației este întreruptă și va relua blocarea în 5 minute.';

  @override
  String get emergency_already_active_snack_alert =>
      'Blocarea aplicației este momentan fie întreruptă, fie inactivă. Dacă notificările sunt activate, veți primi actualizări cu privire la timpul rămas.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Ți-ai folosit toate permisele de urgență. Aplicațiile blocate vor rămâne blocate până la miezul nopții sau se încheie sesiunea de focalizare activă.';

  @override
  String get app_limit_status_not_set => 'Nu setat';

  @override
  String get app_timer_tile_title => 'Cronometru aplicație';

  @override
  String get app_timer_picker_dialog_info =>
      'Setați o limită de timp zilnică pentru această aplicație. Odată ce limita este atinsă, aplicația va fi întreruptă până la miezul nopții.';

  @override
  String get usage_reminders_tile_title => 'Mementouri de utilizare';

  @override
  String get usage_reminders_tile_subtitle =>
      'Apăsări blânde atunci când utilizați aplicații cronometrate.';

  @override
  String get app_launch_limit_tile_title => 'Limită de lansare';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Lansat $count ori astăzi.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Setați de câte ori puteți deschide această aplicație în fiecare zi. Odată atinsă limita, aceasta va fi întreruptă până la miezul nopții.';

  @override
  String get app_active_period_tile_title => 'Perioada activă';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'De la $startTime la $endTime';
  }

  @override
  String get internet_access_tile_title => 'Acces la internet';

  @override
  String get internet_access_tile_subtitle =>
      'Opriți pentru a bloca internetul aplicației.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Internetul lui $appName este blocat.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Internetul lui $appName este deblocat.';
  }

  @override
  String get launch_app_tile_title => 'Lansați aplicația';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Deschideți $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Accesați setările aplicației';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Gestionați setările aplicației, cum ar fi notificările, permisiunile, spațiul de stocare și multe altele.';

  @override
  String get include_in_stats_tile_title => 'Includeți în utilizarea ecranului';

  @override
  String get include_in_stats_tile_subtitle =>
      'Dezactivați pentru a exclude această aplicație din utilizarea totală a ecranului.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName este exclus din utilizarea totală a ecranului.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName este inclus în utilizarea totală a ecranului.';
  }

  @override
  String get general_tab_title => 'general';

  @override
  String get appearance_heading => 'Aspectul';

  @override
  String get theme_mode_tile_title => 'Modul temă';

  @override
  String get theme_mode_system_label => 'Sistem';

  @override
  String get theme_mode_light_label => 'Lumină';

  @override
  String get theme_mode_dark_label => 'Întuneric';

  @override
  String get material_color_tile_title => 'Culoarea materialului';

  @override
  String get amoled_dark_tile_title => 'AMOLED întunecat';

  @override
  String get amoled_dark_tile_subtitle =>
      'Utilizați culoarea neagră pură pentru tema întunecată.';

  @override
  String get dynamic_colors_tile_title => 'Culori dinamice';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Folosiți culorile dispozitivului dacă este acceptat.';

  @override
  String get defaults_heading => 'Valori implicite';

  @override
  String get app_language_tile_title => 'Limba aplicației';

  @override
  String get default_home_tab_tile_title => 'Fila Acasă';

  @override
  String get usage_history_tile_title => 'Istoricul utilizării';

  @override
  String get usage_history_15_days => '15 zile';

  @override
  String get usage_history_1_month => '1 luna';

  @override
  String get usage_history_3_month => '3 luni';

  @override
  String get usage_history_6_month => '6 luni';

  @override
  String get usage_history_1_year => '1 an';

  @override
  String get service_heading => 'Serviciu';

  @override
  String get service_stopping_warning =>
      'Dacă NLP digitox nu mai funcționează în mod neașteptat, acordați permisiunea „Ignorați optimizarea bateriei” pentru a-l menține să ruleze în fundal. Dacă problema continuă, încercați să adăugați NLP digitox pe lista albă pentru performanță neîntreruptă.';

  @override
  String get whitelist_app_tile_title => 'Lista albă NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Permiteți NLP digitox să pornească automat.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Acest dispozitiv nu acceptă gestionarea automată a pornirii.';

  @override
  String get database_tab_title => 'Baza de date';

  @override
  String get import_db_tile_title => 'Importă baza de date';

  @override
  String get import_db_tile_subtitle => 'Importă baza de date dintr-un fișier.';

  @override
  String get export_db_tile_title => 'Exportați baza de date';

  @override
  String get export_db_tile_subtitle =>
      'Exportați baza de date într-un fișier.';

  @override
  String get analysis_tab_title => 'Analiză';

  @override
  String get analysis_7_days => '7 zile';

  @override
  String get analysis_30_days => '30 de zile';

  @override
  String get analysis_90_days => '90 de zile';

  @override
  String get analysis_screen_time_trend => 'Tendința timpului pe ecran';

  @override
  String get analysis_no_data_info =>
      'Nu există încă date despre timpul pe ecran pentru această perioadă.';

  @override
  String get analysis_daily_average => 'Media zilnică';

  @override
  String get analysis_total => 'Total';

  @override
  String get analysis_no_change => 'La fel ca săptămâna trecută';

  @override
  String analysis_trend_less(String percent) {
    return 'cu $percent% mai puțin decât săptămâna trecută';
  }

  @override
  String analysis_trend_more(String percent) {
    return 'cu $percent% mai mult decât săptămâna trecută';
  }

  @override
  String get crash_logs_heading => 'Jurnalele de accidente';

  @override
  String get crash_logs_info =>
      'Dacă întâmpinați vreo problemă, o puteți raporta pe GitHub împreună cu fișierul jurnal. Fișierul va include detalii precum producătorul dispozitivului, modelul, versiunea Android, versiunea SDK și jurnalele de blocare. Aceste informații ne vor ajuta să identificăm și să rezolvăm problema mai eficient.';

  @override
  String get crash_logs_export_tile_title => 'Exportați jurnalele de blocare';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Exportați jurnalele de blocare într-un fișier json.';

  @override
  String get crash_logs_view_tile_title => 'Vizualizați jurnalele';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Explorați jurnalele de blocare stocate.';

  @override
  String get crash_logs_empty_list_hint =>
      'Niciun accident nu a fost înregistrat până acum.';

  @override
  String get crash_logs_clear_tile_title => 'Ștergeți jurnalele';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Ștergeți toate jurnalele de blocare din baza de date.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Sigur doriți să ștergeți toate jurnalele de blocare din baza de date?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Curata oricum';

  @override
  String get about_tab_title => 'Despre';

  @override
  String get changelog_tile_title => 'Jurnalul modificărilor';

  @override
  String get changelog_tile_subtitle => 'Află ce este nou.';

  @override
  String get full_changelog_tile_title => 'Jurnal complet de modificări';

  @override
  String get redirected_to_github_subtitle =>
      'Veți fi redirecționat către GitHub.';

  @override
  String get contribute_heading => 'Contribuie';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Vizualizați codul sursă.';

  @override
  String get report_issue_tile_title => 'Raportați o problemă';

  @override
  String get suggest_idea_tile_title => 'Propune o idee';

  @override
  String get write_email_tile_title => 'Scrie-ne prin e-mail';

  @override
  String get write_email_tile_subtitle =>
      'Veți fi redirecționat către aplicația de e-mail.';

  @override
  String get privacy_policy_heading => 'Politica de confidențialitate';

  @override
  String get privacy_policy_info =>
      'NLP digitox se angajează să vă protejeze confidențialitatea. Nu colectăm, stocăm și nu transferăm niciun tip de date despre utilizatori. Aplicația funcționează în întregime offline și nu necesită o conexiune la internet, asigurându-vă că informațiile dvs. personale rămân private și securizate pe dispozitiv. Fiind o aplicație software gratuită și cu sursă deschisă (FOSS), NLP digitox garantează transparență completă și control de utilizator asupra datelor lor.';

  @override
  String get more_details_button => 'Mai multe detalii';
}
