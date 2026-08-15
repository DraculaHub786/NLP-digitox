// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get mindful_tagline => 'Centra\'t en allò que realment importa';

  @override
  String get unlock_button_label => 'Desbloqueja';

  @override
  String get permission_status_off => 'Apagat';

  @override
  String get permission_status_allowed => 'Permès';

  @override
  String get permission_status_not_allowed => 'No es permet';

  @override
  String get permission_button_grant_permission => 'Concedir el permís';

  @override
  String get permission_button_agree_and_continue => 'D\'acord i continuar';

  @override
  String get permission_button_not_now => 'Ara no';

  @override
  String get permission_button_help => 'Ajuda?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox és 100% segur i funciona fora de línia. No recollim ni emmagatzemem cap dada personal.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Feu clic al botó $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Seleccioneu NLP digitox a la pantalla següent.';

  @override
  String get permission_grant_step_three =>
      '3. Feu clic i enceneu l\'interruptor com a continuació.';

  @override
  String get permission_notification_title => 'Enviar notificacions';

  @override
  String get permission_alarms_title => 'Alarmes i recordatoris';

  @override
  String get permission_alarms_info =>
      'Doneu permís per configurar alarmes i recordatoris. Això permetrà que NLP digitox iniciï el vostre horari d\'anar a dormir a temps i reinicialitzi els temporitzadors de l\'aplicació diàriament a mitjanit i us ajudarà a mantenir-vos al dia.';

  @override
  String get permission_alarms_device_tile_label =>
      'Permet configurar alarmes i recordatoris';

  @override
  String get permission_usage_title => 'Accés d\'ús';

  @override
  String get permission_usage_info =>
      'Concediu permís d\'accés d\'ús. Això permetrà a NLP digitox supervisar l\'ús de les aplicacions i gestionar l\'accés a determinades aplicacions, garantint un entorn digital més centrat i controlat.';

  @override
  String get permission_usage_device_tile_label => 'Permet l\'accés d\'ús';

  @override
  String get permission_overlay_title => 'Superposició de visualització';

  @override
  String get permission_overlay_info =>
      'Concediu permís de superposició de visualització. Això permetrà que NLP digitox mostri una superposició quan s\'obre una aplicació en pausa, ajudant-vos a mantenir-vos concentrat i mantenir la vostra programació.';

  @override
  String get permission_overlay_device_tile_label =>
      'Permet la visualització sobre altres aplicacions';

  @override
  String get permission_accessibility_title => 'Accessibilitat';

  @override
  String get permission_accessibility_info =>
      'Doneu permís d\'accessibilitat. Això permetrà a NLP digitox restringir l\'accés al contingut de vídeo de format breu (p. ex., rodets, curts) dins d\'aplicacions i navegadors de xarxes socials, i filtrar llocs web inadequats.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox requereix permís d\'accessibilitat per bloquejar contingut breu i llocs web de manera eficaç.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Utilitzeu NLP digitox';

  @override
  String get permission_dnd_title => 'No molesteu';

  @override
  String get permission_dnd_info =>
      'Concediu l\'accés a No Molestis. Això permetrà a NLP digitox iniciar i aturar el mode No Molestis durant l\'hora d\'anar a dormir.';

  @override
  String get permission_dnd_tile_title => 'Inicieu el DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Activeu també el mode No Molestis.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignora l\'optimització de la bateria';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Ja sense restriccions';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Desactiva la restricció de fons';

  @override
  String get permission_battery_optimization_allow_info =>
      'Si permets \"Ignora l\'optimització de la bateria\" s\'atorgarà automàticament el permís \"Alarmes i recordatoris\" en alguns dispositius.';

  @override
  String get permission_vpn_title => 'Crea una VPN';

  @override
  String get permission_vpn_info =>
      'Doneu permís per crear una connexió de xarxa privada virtual (VPN). Això permetrà a NLP digitox restringir l\'accés a Internet per a les aplicacions designades creant una VPN local al dispositiu.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Els privilegis administratius només són necessaris per a les operacions essencials per garantir que l\'aplicació funcioni correctament i es mantingui a prova de manipulacions.';

  @override
  String get permission_admin_snack_alert =>
      'La protecció contra manipulacions només es pot desactivar durant el període de temps seleccionat.';

  @override
  String get permission_notification_access_title => 'Accés a la notificació';

  @override
  String get permission_notification_access_info =>
      'Concediu permís d\'accés a notificacions. Això permetrà a NLP digitox organitzar les vostres notificacions i lliurar-les segons la vostra programació.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox requereix accés a notificacions per lots i notificacions de programació.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Permet l\'accés a les notificacions';

  @override
  String get day_today => 'Avui';

  @override
  String get day_yesterday => 'Ahir';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dies',
      one: '1 dia',
      zero: '0 dies',
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
      other: '$countString hores',
      one: '1 hora',
      zero: '0 hores',
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
      other: '$countString minuts',
      one: '1 minut',
      zero: '0 minuts',
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
      other: '$countString segons',
      one: '1 segon',
      zero: '0 segons',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'i';

  @override
  String get timer_status_active => 'Actius';

  @override
  String get timer_status_paused => 'En pausa';

  @override
  String get create_button => 'Crear';

  @override
  String get update_button => 'Actualització';

  @override
  String get dialog_button_cancel => 'Cancel·la';

  @override
  String get dialog_button_remove => 'Eliminar';

  @override
  String get dialog_button_set => 'Set';

  @override
  String get dialog_button_reset => 'Restableix';

  @override
  String get dialog_button_infinite => 'Infinit';

  @override
  String get schedule_start_label => 'Comença';

  @override
  String get schedule_end_label => 'Final';

  @override
  String get exit_without_saving_dialog_info =>
      'Esteu segur que voleu sortir sense desar?';

  @override
  String get development_dialog_info =>
      'NLP digitox està actualment en desenvolupament i pot tenir errors o funcions incompletes. Si trobeu algun problema, si us plau, informeu-nos per ajudar-nos a millorar. \n\nGràcies pels vostres comentaris!';

  @override
  String get development_dialog_button_report_issue =>
      'Informar d\'un problema';

  @override
  String get development_dialog_button_close => 'Tancar';

  @override
  String get dnd_settings_tile_title => 'No molesteu la configuració';

  @override
  String get dnd_settings_tile_subtitle =>
      'Gestioneu quines aplicacions i notificacions us poden arribar a DND.';

  @override
  String get quick_actions_heading => 'Accions ràpides';

  @override
  String get select_distracting_apps_heading =>
      'Seleccioneu aplicacions que distreguin';

  @override
  String get your_distracting_apps_heading =>
      'Les teves aplicacions que distreuen';

  @override
  String get select_more_apps_heading => 'Seleccioneu més aplicacions';

  @override
  String get imp_distracting_apps_snack_alert =>
      'No es permet afegir aplicacions importants del sistema a la llista d\'aplicacions que distreuen.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'L\'ús de la pantalla i les restriccions no estan disponibles per a aquesta aplicació. Actualment, només es pot accedir a l\'ús de la xarxa';

  @override
  String get create_group_fab_button => 'Crear grup';

  @override
  String get active_period_info =>
      'Estableix un període de temps durant el qual es permetrà l\'accés. Fora d\'aquest període de temps, l\'accés estarà restringit.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Seleccioneu almenys una aplicació que us distregui.';

  @override
  String get donation_card_title => 'Doneu-nos suport';

  @override
  String get donation_card_info =>
      'NLP digitox és gratuït i de codi obert, desenvolupat amb mesos de dedicació. Si t\'ha ajudat, la teva donació significaria el món per a nosaltres. Cada aportació ens ajuda a seguir millorant-la i mantenint-la per a tothom.';

  @override
  String get operation_failed_snack_alert =>
      'L\'operació ha fallat, alguna cosa ha anat malament!';

  @override
  String get donation_card_button_donate => 'Donar';

  @override
  String get app_restart_dialog_title => 'Cal reiniciar';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox es reiniciarà automàticament un cop finalitzi el compte enrere. Si us plau, tingueu paciència mentre s\'apliquen els canvis.';

  @override
  String get accessibility_tip =>
      'Vols un bloqueig més intel·ligent i compatible amb la bateria? Activa el permís d\'accessibilitat per a NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox no funciona? Permet que \"Ignora l\'optimització de la bateria\" a Configuració perquè funcioni sense problemes.';

  @override
  String get invincible_mode_tip =>
      'Restriccions eliminades per accident? Utilitzeu el mode invencible per bloquejar-los fins al dia següent o a la finestra d\'ajust.';

  @override
  String get glance_usage_tip =>
      'Voleu informació? Consulteu la secció Mirada per veure els vostres patrons d\'ús i el temps de connexió.';

  @override
  String get tamper_protection_tip =>
      'Vols desinstal·lar NLP digitox? Habiliteu la finestra de desinstal·lació per desactivar de manera segura la protecció contra manipulacions primer.';

  @override
  String get notification_blocking_tip =>
      'Vols reduir les distraccions? Utilitzeu el bloqueig de notificacions per silenciar les aplicacions seleccionades.';

  @override
  String get usage_history_tip =>
      'Vols reflexionar sobre els teus hàbits? Comproveu l\'historial d\'ús per veure patrons anteriors.';

  @override
  String get focus_mode_tip =>
      'Necessites un enfocament profund? Activa el mode Focus per bloquejar aplicacions i notificacions durant les tasques.';

  @override
  String get bedtime_reminder_tip =>
      'Vols millorar el teu son? Estableix un recordatori d\'hora d\'anar a dormir per relaxar-se cada nit.';

  @override
  String get custom_blocking_tip =>
      'Necessites una experiència personalitzada? Creeu regles de bloqueig d\'aplicacions que s\'adaptin a les vostres necessitats.';

  @override
  String get session_timeline_tip =>
      'Vols fer un seguiment de les sessions de focus? Consulteu la cronologia per veure el vostre viatge d\'enfocament.';

  @override
  String get short_content_blocking_tip =>
      'Distret amb les aplicacions socials? Bloqueja el contingut breu a Instagram, YouTube, etc., per mantenir la concentració.';

  @override
  String get parental_controls_tip =>
      'Necessites control parental? Estableix restriccions per al dispositiu del teu fill per garantir una experiència segura.';

  @override
  String get notification_batching_tip =>
      'Vols reduir les distraccions? Utilitzeu el lot de notificacions per agrupar les notificacions i comprovar-les alhora.';

  @override
  String get notification_scheduling_tip =>
      'Necessites gestionar les notificacions? Programeu quan rebeu notificacions d\'aplicacions específiques.';

  @override
  String get quick_focus_tile_tip =>
      'Necessites un accés ràpid per enfocar-te? Afegiu una fitxa d\'enfocament ràpid per activar instantàniament el mode d\'enfocament.';

  @override
  String get app_shortcuts_tip =>
      'Vols accedir a l\'aplicació instantània? Afegiu dreceres prement llargament la icona de l\'aplicació per a accions ràpides.';

  @override
  String get backup_usage_db_tip =>
      'Vols desar les teves dades? Feu una còpia de seguretat de la vostra base de dades d\'ús per mantenir els vostres registres segurs.';

  @override
  String get dynamic_material_color_tip =>
      'Vols un tema personalitzat? Activa el material dinàmic que tu colora perquè coincideixi amb el tema del teu dispositiu.';

  @override
  String get amoled_dark_theme_tip =>
      'Vols estalviar bateria? Utilitzeu AMOLED Dark Theme per reduir el consum d\'energia a les pantalles OLED.';

  @override
  String get customize_usage_history_tip =>
      'Voleu conservar l\'historial d\'ús? Personalitzeu quantes setmanes de dades s\'emmagatzemen a l\'historial d\'ús.';

  @override
  String get grouped_apps_blocking_tip =>
      'Voleu bloquejar aplicacions juntes? Utilitzeu els grups de restricció per agrupar els límits d\'aplicacions i bloquejar diverses aplicacions alhora.';

  @override
  String get websites_blocking_tip =>
      'Vols una experiència de navegació més neta? Bloqueja llocs web personalitzats o NSFW per a un temps en línia més centrat.';

  @override
  String get data_usage_tip =>
      'Vols fer un seguiment de les teves dades? Superviseu el vostre ús de dades mòbils i Wi-Fi per al consum d\'Internet.';

  @override
  String get block_internet_tip =>
      'Necessites bloquejar Internet d\'una aplicació? Talleu Internet per a una aplicació específica del tauler de control de l\'aplicació.';

  @override
  String get emergency_passes_tip =>
      'Necessites un descans? Fes servir 3 passis d\'emergència diaris per desbloquejar temporalment aplicacions durant 5 minuts.';

  @override
  String get onboarding_skip_btn_label => 'Saltar';

  @override
  String get onboarding_finish_setup_btn_label => 'Finalitza la configuració';

  @override
  String get onboarding_page_welcome_title => 'Benvingut/da a NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Pren el control de la teva vida digital i crea hàbits de pantalla més saludables. NLP digitox t\'ajuda a mantenir-te concentrat, reduir distraccions i prendre decisions conscients cada dia.';

  @override
  String get onboarding_page_statistics_title => 'Coneix els teus hàbits.';

  @override
  String get onboarding_page_statistics_info =>
      'Entén els teus patrons digitals amb informació detallada sobre temps de pantalla, ús d\'aplicacions i tendències de concentració. Fes un seguiment del teu progrés i veu com petits canvis porten a grans millores.';

  @override
  String get onboarding_page_one_title => 'Focus Mestre.';

  @override
  String get onboarding_page_one_info =>
      'Posa en pausa les aplicacions que distreuen, bloqueja el contingut breu i segueix el camí amb sessions d\'enfocament personalitzables. Tant si treballeu, estudieu o us relaxeu, NLP digitox us ajuda a mantenir el control.';

  @override
  String get onboarding_page_two_title => 'Bloqueja les distraccions.';

  @override
  String get onboarding_page_two_info =>
      'Estableix límits d\'ús, posa en pausa automàticament les aplicacions i crea hàbits digitals més saludables. Utilitza el mode d\'anar a dormir per relaxar-te i gaudir d\'una nit sense distraccions.';

  @override
  String get onboarding_page_three_title => 'La privadesa primer.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox és 100% de codi obert i funciona completament fora de línia. No recollim ni compartim les vostres dades personals; la vostra privadesa està garantida en tots els sentits.';

  @override
  String get onboarding_page_permissions_title => 'Permisos essencials.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox requereix els següents permisos essencials per fer un seguiment i gestionar el temps de connexió, ajudant a reduir les distraccions i millorar l\'enfocament.';

  @override
  String get dashboard_tab_title => 'Tauler de control';

  @override
  String get focus_now_fab_button => 'Centra\'t ara';

  @override
  String get welcome_greetings => 'Benvingut de nou,';

  @override
  String get username_snack_alert =>
      'Premeu llargament per editar el nom d\'usuari.';

  @override
  String get username_dialog_title => 'Nom d\'usuari';

  @override
  String get username_dialog_info =>
      'Introduïu el vostre nom d\'usuari que es mostrarà al tauler.';

  @override
  String get username_dialog_button_apply => 'Aplicar';

  @override
  String get glance_tile_title => 'Mirada';

  @override
  String get glance_tile_subtitle => 'Fes una ullada ràpida al teu ús.';

  @override
  String get parental_controls_tile_subtitle =>
      'Mode invencible i protecció contra manipulacions.';

  @override
  String get restrictions_heading => 'Restriccions';

  @override
  String get apps_blocking_tile_title => 'Bloqueig d\'aplicacions';

  @override
  String get apps_blocking_tile_subtitle =>
      'Limiteu les aplicacions de diverses maneres.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Bloqueig d\'aplicacions agrupades';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Limiteu el grup d\'aplicacions simultàniament.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Limiteu el contingut breu en diverses plataformes.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Limiteu els llocs web per a adults i personalitzats.';

  @override
  String get screen_time_label => 'Temps de pantalla';

  @override
  String get total_data_label => 'Dades totals';

  @override
  String get mobile_data_label => 'Dades mòbils';

  @override
  String get wifi_data_label => 'Dades wifi';

  @override
  String get focus_today_label => 'Centra\'t avui';

  @override
  String get focus_weekly_label => 'Focus setmanal';

  @override
  String get focus_monthly_label => 'Focus mensual';

  @override
  String get focus_lifetime_label => 'Centra la vida';

  @override
  String get longest_streak_label => 'Ratxa més llarga';

  @override
  String get current_streak_label => 'Ratxa actual';

  @override
  String get successful_sessions_label => 'Sessions reeixides';

  @override
  String get failed_sessions_label => 'Sessions fallides';

  @override
  String get statistics_tab_title => 'Estadístiques';

  @override
  String get screen_segment_label => 'Pantalla';

  @override
  String get data_segment_label => 'Dades';

  @override
  String get mobile_label => 'Mòbil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Aplicacions més utilitzades';

  @override
  String get show_all_apps_tile_title => 'Mostra totes les aplicacions';

  @override
  String get search_apps_hint => 'Cerca aplicacions...';

  @override
  String get notifications_tab_title => 'Notificacions';

  @override
  String get notifications_tab_info =>
      'Notificació per lots d\'aplicacions i establiu horaris com ara el matí, el migdia, el vespre i la nit. Manteniu-vos actualitzat sense interrupcions constants.';

  @override
  String get batched_apps_tile_title => 'Aplicacions per lots';

  @override
  String get batch_recap_dropdown_title => 'Tipus de resum del lot';

  @override
  String get batch_recap_dropdown_info =>
      'Trieu què voleu empènyer quan s\'activa una programació: totes les notificacions o només un resum.';

  @override
  String get batch_recap_option_summery_only => 'Només resum';

  @override
  String get batch_recap_option_all_notifications => 'Totes les notificacions';

  @override
  String get notification_history_tile_title => 'Historial de notificacions';

  @override
  String get store_all_tile_title => 'Emmagatzema totes les notificacions';

  @override
  String get store_all_tile_subtitle =>
      'Deseu també les notificacions no lotades.';

  @override
  String get schedules_heading => 'Horaris';

  @override
  String get new_schedule_fab_button => 'Nou Horari';

  @override
  String get new_schedule_dialog_info =>
      'Introduïu un nom per a la programació de notificacions per identificar-la fàcilment.';

  @override
  String get new_schedule_dialog_field_label => 'Nom de l\'horari';

  @override
  String get bedtime_tab_title => 'Hora d\'anar a dormir';

  @override
  String get bedtime_tab_info =>
      'Establiu el vostre horari d\'anar a dormir seleccionant un període i dies de la setmana. Trieu aplicacions que us distreguin per bloquejar i activar el mode No Molestis (DND) per a una nit tranquil·la.';

  @override
  String get schedule_tile_title => 'Horari';

  @override
  String get schedule_tile_subtitle => 'Activa o desactiva l\'horari diari.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Seleccioneu almenys un dia de la setmana.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'La durada total de l\'hora d\'anar a dormir ha de ser d\'almenys 30 minuts.';

  @override
  String get distracting_apps_tile_title => 'Aplicacions que distreuen';

  @override
  String get distracting_apps_tile_subtitle =>
      'Seleccioneu quines aplicacions us distreuen de la vostra rutina d\'anar a dormir.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'No es permeten modificacions a la llista d\'aplicacions que distreuen mentre l\'horari d\'anar a dormir estigui actiu.';

  @override
  String get parental_controls_tab_title => 'Controls parentals';

  @override
  String get invincible_mode_heading => 'Mode invencible';

  @override
  String get invincible_mode_tile_title => 'Activa el mode invencible';

  @override
  String get invincible_mode_info =>
      'Quan el mode invencible està activat, no podreu ajustar els límits seleccionats després d\'arribar a la vostra quota diària. Tanmateix, podeu fer canvis dins d\'una finestra invencible seleccionada de 10 minuts.';

  @override
  String get invincible_mode_snack_alert =>
      'A causa del mode invencible, no es permeten modificacions a les restriccions.';

  @override
  String get invincible_mode_dialog_info =>
      'Esteu absolutament segur que voleu activar el mode invencible? Aquesta acció és irreversible. Un cop activat el mode invencible, no el podreu desactivar sempre que aquesta aplicació estigui instal·lada al vostre dispositiu.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'El mode invencible no es pot desactivar mentre aquesta aplicació es mantingui instal·lada al dispositiu.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Comença igualment';

  @override
  String get invincible_mode_include_timer_tile_title => 'Inclou temporitzador';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Inclou el límit de llançament';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Inclou el període actiu';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Restriccions de l\'aplicació';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Eviteu els canvis a les restriccions seleccionades de l\'aplicació un cop superats els límits diaris.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Restriccions de grup';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Eviteu canvis a les restriccions seleccionades del grup un cop superats els límits diaris.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Inclou un temporitzador de curtmetratges';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Evita els canvis després d\'haver arribat al límit diari de pantalons curts.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Inclou l\'hora d\'anar a dormir';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Evita canvis durant l\'horari actiu d\'anar a dormir.';

  @override
  String get protected_access_tile_title => 'Accés protegit';

  @override
  String get protected_access_tile_subtitle =>
      'Protegiu NLP digitox amb el bloqueig del dispositiu.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Primer, configureu un bloqueig biomètric al vostre dispositiu per activar aquesta funció.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'S\'ha eliminat el bloqueig del dispositiu. Per continuar, configureu un nou bloqueig.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'L\'autenticació ha fallat. Heu de verificar el bloqueig del dispositiu per continuar.';

  @override
  String get tamper_protection_tile_title => 'Protecció contra manipulacions';

  @override
  String get tamper_protection_tile_subtitle =>
      'Eviteu la desinstal·lació i força l\'aturada de l\'aplicació.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Un cop habilitat, no podreu desinstal·lar, forçar l\'aturada o esborrar les dades de NLP digitox, excepte durant la finestra de desinstal·lació seleccionada. No hi ha cap solució alternativa.\n\nProcediu sota el vostre propi risc.';

  @override
  String get uninstall_window_tile_title => 'Finestra de desinstal·lació';

  @override
  String get uninstall_window_tile_subtitle =>
      'La protecció contra manipulacions es pot desactivar en 10 minuts a partir de l\'hora seleccionada.';

  @override
  String get invincible_window_tile_title => 'Finestra invencible';

  @override
  String get invincible_window_tile_subtitle =>
      'Els límits seleccionats es poden modificar en un termini de 10 minuts a partir de l\'hora seleccionada.';

  @override
  String get shorts_blocking_tab_title => 'Bloqueig de pantalons curts';

  @override
  String get shorts_blocking_tab_info =>
      'Controla quant de temps dediques a contingut breu a plataformes com Instagram, YouTube, Snapchat i Facebook, inclosos els seus llocs web.';

  @override
  String get short_content_heading => 'Contingut breu';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Sort de $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Estableix un límit de temps diari per a contingut breu. Un cop s\'arribi al vostre límit, el contingut breu es posarà en pausa fins a la mitjanit.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Restringeix les funcions a instagram.';

  @override
  String get instagram_features_block_reels =>
      'Restringeix la secció de rodets.';

  @override
  String get instagram_features_block_explore =>
      'Restringeix la secció d\'exploració.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Restringeix les funcions a Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Restringeix la secció de focus.';

  @override
  String get snapchat_features_block_discover =>
      'Restringeix la secció descoberta.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Restringeix els curts a youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Restringeix els rodets a Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Restringeix els curts a reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Restringeix el feed de vídeo a X.';

  @override
  String get threads_features_tile_title => 'Fils';

  @override
  String get threads_features_tile_subtitle =>
      'Restringeix el vídeo/els rodets als fils.';

  @override
  String get websites_blocking_tab_title => 'Bloqueig de llocs web';

  @override
  String get websites_blocking_tab_info =>
      'Bloqueja els llocs web per a adults i els llocs personalitzats que tries per crear una experiència en línia més segura i centrada. Fes-te càrrec de la teva navegació i mantén-te lliure de distraccions.';

  @override
  String get adult_content_heading => 'Contingut per a adults';

  @override
  String get block_nsfw_title => 'Bloc Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Restringeix els navegadors d\'obrir llocs web per a adults i porno.';

  @override
  String get block_nsfw_dialog_info =>
      'N\'estàs segur? Aquesta acció és irreversible. Un cop activat el bloquejador de llocs per a adults, no el podreu desactivar sempre que aquesta aplicació estigui instal·lada al vostre dispositiu.';

  @override
  String get block_nsfw_dialog_button_block_anyway =>
      'Bloqueja de totes maneres';

  @override
  String get blocked_websites_heading => 'Llocs web bloquejats';

  @override
  String get blocked_websites_empty_list_hint =>
      'Feu clic al botó \"+ Afegeix lloc web\" per afegir llocs web que distreuen que voleu bloquejar.';

  @override
  String get add_website_fab_button => 'Afegeix lloc web';

  @override
  String get add_website_dialog_title => 'Lloc web que distraeix';

  @override
  String get add_website_dialog_info =>
      'Introduïu l\'URL d\'un lloc web que voleu bloquejar.';

  @override
  String get add_website_dialog_is_nsfw => 'És el lloc nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Avís: els llocs Nsfw no es poden eliminar un cop afegits.';

  @override
  String get add_website_dialog_button_block => 'Bloc';

  @override
  String get add_website_already_exist_snack_alert =>
      'L\'URL ja s\'ha afegit a la llista de llocs web bloquejats.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'URL no vàlid! No es pot analitzar el nom d\'amfitrió.';

  @override
  String get remove_website_dialog_title => 'Elimina el lloc web';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'N\'estàs segur? voleu eliminar \"$websitehost\" dels llocs web bloquejats.';
  }

  @override
  String get focus_tab_title => 'Focus';

  @override
  String get focus_tab_info =>
      'Quan necessiteu temps per concentrar-vos, inicieu una nova sessió seleccionant el tipus, escollint les aplicacions que distreuen per posar en pausa i activant No molestar per a una concentració ininterrompuda.';

  @override
  String get active_session_card_title => 'Sessió activa';

  @override
  String get active_session_card_info =>
      'Tens una sessió de focus activa en marxa! Feu clic a \"Mostra\" per comprovar el vostre progrés i veure quant de temps ha passat.';

  @override
  String get active_session_card_view_button => 'Veure';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'No es permet l\'eliminació d\'aplicacions de la llista d\'aplicacions que distreuen mentre hi ha una sessió de focus activa. Tanmateix, encara podeu afegir aplicacions addicionals a la llista durant aquest temps.';

  @override
  String get focus_profile_tile_title => 'Perfil de focus';

  @override
  String get focus_session_duration_tile_title => 'Durada de la sessió';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Infinit (tret que t\'aturis)';

  @override
  String get focus_session_duration_dialog_info =>
      'Seleccioneu la durada desitjada per a aquesta sessió d\'enfocament, determinant quant de temps voleu mantenir-vos concentrat i sense distraccions.';

  @override
  String get focus_profile_customization_tile_title =>
      'Personalització del perfil';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Personalitza la configuració del perfil seleccionat.';

  @override
  String get focus_enforce_tile_title => 'Aplicar la sessió';

  @override
  String get focus_enforce_tile_subtitle =>
      'Impedeix finalitzar una sessió abans que acabi el temps.';

  @override
  String get focus_session_start_button => 'Llisca per iniciar la sessió';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Seleccioneu almenys una aplicació que distregui per iniciar la sessió de focus';

  @override
  String get focus_session_already_active_snack_alert =>
      'Ja teniu una sessió de focus activa en curs. Si us plau, completeu o atureu la vostra sessió actual abans d\'iniciar-ne una de nova.';

  @override
  String get focus_session_type_study => 'Estudiar';

  @override
  String get focus_session_type_work => 'Treballar';

  @override
  String get focus_session_type_exercise => 'Exercici';

  @override
  String get focus_session_type_meditation => 'Meditació';

  @override
  String get focus_session_type_creativeWriting => 'Escriptura creativa';

  @override
  String get focus_session_type_reading => 'Lectura';

  @override
  String get focus_session_type_programming => 'Programació';

  @override
  String get focus_session_type_chores => 'Feines';

  @override
  String get focus_session_type_projectPlanning => 'Planificació de projectes';

  @override
  String get focus_session_type_artAndDesign => 'Art i Disseny';

  @override
  String get focus_session_type_languageLearning => 'Aprenentatge d\'idiomes';

  @override
  String get focus_session_type_musicPractice => 'Pràctica musical';

  @override
  String get focus_session_type_selfCare => 'Autocura';

  @override
  String get focus_session_type_brainstorming => 'Pluja d\'idees';

  @override
  String get focus_session_type_skillDevelopment =>
      'Desenvolupament d\'habilitats';

  @override
  String get focus_session_type_research => 'Recerca';

  @override
  String get focus_session_type_networking => 'Treball en xarxa';

  @override
  String get focus_session_type_cooking => 'Cuinar';

  @override
  String get focus_session_type_sportsTraining => 'Entrenament esportiu';

  @override
  String get focus_session_type_restAndRelaxation => 'Descans i relaxació';

  @override
  String get focus_session_type_other => 'Altres';

  @override
  String get timeline_tab_title => 'Cronologia';

  @override
  String get focus_timeline_tab_info =>
      'Exploreu el vostre viatge d\'enfocament seleccionant una data del calendari. Feu un seguiment del vostre progrés, reviseu els vostres èxits i apreneu dels reptes.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'El vostre temps productiu total per al mes seleccionat és $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Dies productius';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Heu tingut un total de $daysCount dies productius durant el mes seleccionat.';
  }

  @override
  String get selected_day_focused_time_label => 'Temps concentrat';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'El temps total de concentració del dia seleccionat és $timeString.';
  }

  @override
  String get calender_heading => 'Calendari';

  @override
  String get your_sessions_heading => 'Les vostres sessions';

  @override
  String get your_sessions_empty_list_hint =>
      'No s\'han registrat sessions de focus per al dia seleccionat.';

  @override
  String get focus_session_tile_timestamp_label => 'Marca de temps';

  @override
  String get focus_session_tile_duration_label => 'Durada';

  @override
  String get focus_session_tile_reflection_label => 'Reflexió';

  @override
  String get focus_session_state_active => 'Actius';

  @override
  String get focus_session_state_successful => 'Encertat';

  @override
  String get focus_session_state_failed => 'Ha fallat';

  @override
  String get active_session_tab_title => 'Sessió';

  @override
  String get active_session_none_warning =>
      'No s\'ha trobat cap sessió activa. Tornant a la pantalla d\'inici.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Segueix pressionant';

  @override
  String get active_session_finish_dialog_title => 'Acabar';

  @override
  String get active_session_finish_dialog_info =>
      'Sigues fort! Estàs creant un enfocament valuós. Esteu segur que voleu acabar aquesta sessió de focus? Cada moment addicional compta per als teus objectius.';

  @override
  String get active_session_giveup_dialog_title => 'Rendir-se';

  @override
  String get active_session_giveup_dialog_info =>
      'Aguanta! Gairebé hi ets, no et rendis ara! Confirmes que vols acabar aquesta sessió d\'enfocament abans d\'hora? El progrés es perdrà.';

  @override
  String get active_session_reflection_dialog_title => 'Sessió de reflexió';

  @override
  String get active_session_reflection_dialog_info =>
      'Preneu-vos un moment per reflexionar sobre el vostre progrés. Quin és el teu objectiu per a aquesta sessió? Què has aconseguit durant aquesta sessió?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Consell: sempre podeu editar-ho més tard a la línia de temps de la sessió.';

  @override
  String get active_session_giveup_snack_alert =>
      'T\'has rendit! No et preocupis, pots fer-ho millor la propera vegada. Cada esforç compta, només segueix endavant';

  @override
  String get active_session_quote_one =>
      'Cada pas compta, sigueu fort i seguiu endavant';

  @override
  String get active_session_quote_two =>
      'Mantingueu-vos concentrats! estàs fent un progrés increïble';

  @override
  String get active_session_quote_three =>
      'L\'estàs aixafant! Mantingueu l\'impuls';

  @override
  String get active_session_quote_four =>
      'Queda una mica més, ho esteu fent fantàstic';

  @override
  String active_session_quote_five(String durationString) {
    return 'Enhorabona 🎉 \n Heu completat la vostra sessió d\'enfocament de $durationString.\n\nBon treball, seguiu així';
  }

  @override
  String get restriction_groups_tab_title => 'Grups de restricció';

  @override
  String get restriction_groups_tab_info =>
      'Estableix un límit de temps de pantalla combinat per a un grup d\'aplicacions. Un cop l\'ús total arribi al vostre límit, totes les aplicacions del grup es posaran en pausa per ajudar-vos a mantenir la concentració i l\'equilibri.';

  @override
  String get restriction_group_time_spent_label => 'Temps dedicat avui';

  @override
  String get restriction_group_time_left_label => 'Queda temps avui';

  @override
  String get restriction_group_name_tile_title => 'Nom del grup';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Introduïu un nom per al grup de restricció per identificar-lo i gestionar-lo fàcilment.';

  @override
  String get restriction_group_timer_tile_title => 'Temporitzador de grup';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Estableix un límit de temps diari per a aquest grup. Un cop s\'arribi al vostre límit, totes les aplicacions d\'aquest grup es posaran en pausa fins a la mitjanit.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Període actiu del grup';

  @override
  String get remove_restriction_group_dialog_title => 'Elimina el grup';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'N\'estàs segur? voleu eliminar \"$groupName\" dels grups de restricció.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Estableix un temporitzador o un límit de període actiu.';

  @override
  String get notifications_empty_list_hint =>
      'No s\'ha agrupat cap notificació per al dia.';

  @override
  String get conversations_label => 'Converses';

  @override
  String get last_24_hours_heading => 'Últimes 24 hores';

  @override
  String get notification_timeline_tab_info =>
      'Exploreu el vostre historial de notificacions seleccionant una data del calendari. Mira quines aplicacions t\'han cridat l\'atenció i reflexiona sobre els teus hàbits digitals.';

  @override
  String get monthly_label => 'Mensualment';

  @override
  String get daily_label => 'Diàriament';

  @override
  String get search_notifications_sheet_info =>
      'Trobeu fàcilment les notificacions anteriors cercant el seu títol o contingut. T\'ajuda a localitzar ràpidament alertes importants.';

  @override
  String get search_notifications_hint => 'Cerca notificacions...';

  @override
  String get search_notifications_empty_list_hint =>
      'No s\'ha trobat cap notificació que coincideixi amb la teva cerca.';

  @override
  String get app_info_none_warning =>
      'No s\'ha pogut trobar l\'aplicació per al paquet donat. Tornant a la pantalla d\'inici.';

  @override
  String get emergency_fab_button => 'Emergència';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Aquesta acció posarà en pausa el bloquejador d\'aplicacions durant els propers 5 minuts. Et queden passades $leftPassesCount. Després d\'utilitzar tots els passis, l\'aplicació romandrà bloquejada fins a la mitjanit o finalitzarà la sessió de focus activa.\n\nEncara voleu continuar?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Utilitza de totes maneres';

  @override
  String get emergency_started_snack_alert =>
      'El bloquejador d\'aplicacions està en pausa i es reprendrà amb el bloqueig d\'aquí a 5 minuts.';

  @override
  String get emergency_already_active_snack_alert =>
      'Actualment, el bloquejador d\'aplicacions està en pausa o inactiu. Si les notificacions estan habilitades, rebràs actualitzacions sobre el temps restant.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Heu utilitzat tots els vostres passis d\'emergència. Les aplicacions bloquejades romandran bloquejades fins a la mitjanit, o bé finalitza la sessió de focus activa.';

  @override
  String get app_limit_status_not_set => 'No configurat';

  @override
  String get app_timer_tile_title => 'Temporitzador d\'aplicacions';

  @override
  String get app_timer_picker_dialog_info =>
      'Estableix un límit de temps diari per a aquesta aplicació. Un cop s\'arribi al vostre límit, l\'aplicació es posarà en pausa fins a la mitjanit.';

  @override
  String get usage_reminders_tile_title => 'Recordatoris d\'ús';

  @override
  String get usage_reminders_tile_subtitle =>
      'Mots suaus quan utilitzeu aplicacions cronometrades.';

  @override
  String get app_launch_limit_tile_title => 'Límit de llançament';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'S\'ha llançat $count vegades avui.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Estableix quantes vegades pots obrir aquesta aplicació cada dia. Un cop arribat al límit, s\'aturarà fins a mitjanit.';

  @override
  String get app_active_period_tile_title => 'Període actiu';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'De $startTime a $endTime';
  }

  @override
  String get internet_access_tile_title => 'Accés a Internet';

  @override
  String get internet_access_tile_subtitle =>
      'Apagueu per bloquejar Internet de l\'aplicació.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Internet de $appName està bloquejat.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Internet de $appName està desbloquejat.';
  }

  @override
  String get launch_app_tile_title => 'Inicia l\'aplicació';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Obre $appName.';
  }

  @override
  String get go_to_app_settings_tile_title =>
      'Vés a la configuració de l\'aplicació';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Gestioneu la configuració de l\'aplicació, com ara notificacions, permisos, emmagatzematge i molt més.';

  @override
  String get include_in_stats_tile_title => 'Inclou l\'ús de la pantalla';

  @override
  String get include_in_stats_tile_subtitle =>
      'Desactiveu-lo per excloure aquesta aplicació de l\'ús total de la pantalla.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName està exclòs de l\'ús total de la pantalla.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName s\'inclou a l\'ús total de la pantalla.';
  }

  @override
  String get general_tab_title => 'General';

  @override
  String get appearance_heading => 'Aparença';

  @override
  String get theme_mode_tile_title => 'Mode de tema';

  @override
  String get theme_mode_system_label => 'Sistema';

  @override
  String get theme_mode_light_label => 'Llum';

  @override
  String get theme_mode_dark_label => 'Fosc';

  @override
  String get material_color_tile_title => 'Color material';

  @override
  String get amoled_dark_tile_title => 'AMOLED fosc';

  @override
  String get amoled_dark_tile_subtitle =>
      'Utilitzeu un color negre pur per al tema fosc.';

  @override
  String get dynamic_colors_tile_title => 'Colors dinàmics';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Utilitzeu els colors del dispositiu si s\'admet.';

  @override
  String get defaults_heading => 'Per defecte';

  @override
  String get app_language_tile_title => 'Idioma de l\'aplicació';

  @override
  String get default_home_tab_tile_title => 'Pestanya Inici';

  @override
  String get usage_history_tile_title => 'Historial d\'ús';

  @override
  String get usage_history_15_days => '15 dies';

  @override
  String get usage_history_1_month => '1 mes';

  @override
  String get usage_history_3_month => '3 mesos';

  @override
  String get usage_history_6_month => '6 mesos';

  @override
  String get usage_history_1_year => '1 any';

  @override
  String get service_heading => 'Servei';

  @override
  String get service_stopping_warning =>
      'Si NLP digitox deixa de funcionar de manera inesperada, concediu el permís \"Ignora l\'optimització de la bateria\" per mantenir-lo en segon pla. Si el problema continua, proveu d\'inscriure NLP digitox a la llista blanca per obtenir un rendiment ininterromput.';

  @override
  String get whitelist_app_tile_title => 'Llista blanca NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Permet que NLP digitox s\'iniciï automàticament.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Aquest dispositiu no admet la gestió d\'inici automàtica.';

  @override
  String get database_tab_title => 'Base de dades';

  @override
  String get import_db_tile_title => 'Importa la base de dades';

  @override
  String get import_db_tile_subtitle =>
      'Importa la base de dades d\'un fitxer.';

  @override
  String get export_db_tile_title => 'Exportar la base de dades';

  @override
  String get export_db_tile_subtitle => 'Exporta la base de dades a un fitxer.';

  @override
  String get analysis_tab_title => 'Anàlisi';

  @override
  String get analysis_7_days => '7 dies';

  @override
  String get analysis_30_days => '30 dies';

  @override
  String get analysis_90_days => '90 dies';

  @override
  String get analysis_screen_time_trend => 'Tendència del temps de pantalla';

  @override
  String get analysis_no_data_info =>
      'Encara no hi ha dades de temps de pantalla per a aquest període.';

  @override
  String get analysis_daily_average => 'Mitjana diària';

  @override
  String get analysis_total => 'Total';

  @override
  String get analysis_no_change => 'Igual que la setmana passada';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% menys que la setmana passada';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% més que la setmana passada';
  }

  @override
  String get crash_logs_heading => 'Registres d\'accidents';

  @override
  String get crash_logs_info =>
      'Si trobeu algun problema, podeu informar-lo a GitHub juntament amb el fitxer de registre. El fitxer inclourà detalls com ara el fabricant del dispositiu, el model, la versió d\'Android, la versió de l\'SDK i els registres d\'error. Aquesta informació ens ajudarà a identificar i resoldre el problema de manera més eficaç.';

  @override
  String get crash_logs_export_tile_title => 'Exporta els registres d\'error';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Exporta els registres d\'error a un fitxer json.';

  @override
  String get crash_logs_view_tile_title => 'Veure registres';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Exploreu els registres d\'error emmagatzemats.';

  @override
  String get crash_logs_empty_list_hint =>
      'No s\'ha registrat cap bloqueig fins ara.';

  @override
  String get crash_logs_clear_tile_title => 'Esborra els registres';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Suprimeix tots els registres d\'error de la base de dades.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Esteu segur que voleu esborrar tots els registres d\'error de la base de dades?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'Aclarir de totes maneres';

  @override
  String get about_tab_title => 'Sobre';

  @override
  String get changelog_tile_title => 'Registre de canvis';

  @override
  String get changelog_tile_subtitle => 'Descobriu les novetats.';

  @override
  String get full_changelog_tile_title => 'Registre de canvis complet';

  @override
  String get redirected_to_github_subtitle => 'Se us redirigirà a GitHub.';

  @override
  String get contribute_heading => 'Contribuir';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Veure el codi font.';

  @override
  String get report_issue_tile_title => 'Informar d\'un problema';

  @override
  String get suggest_idea_tile_title => 'Suggereix una idea';

  @override
  String get write_email_tile_title => 'Escriu-nos per correu electrònic';

  @override
  String get write_email_tile_subtitle =>
      'Se us redirigirà a l\'aplicació de correu electrònic.';

  @override
  String get privacy_policy_heading => 'Política de privadesa';

  @override
  String get privacy_policy_info =>
      'NLP digitox es compromet a protegir la vostra privadesa. No recollim, emmagatzemem ni transferim cap tipus de dades d\'usuari. L\'aplicació funciona completament fora de línia i no requereix connexió a Internet, assegurant-vos que la vostra informació personal es mantingui privada i segura al vostre dispositiu. Com a aplicació de programari lliure i de codi obert (FOSS), NLP digitox garanteix una transparència total i un control dels usuaris sobre les seves dades.';

  @override
  String get more_details_button => 'Més detalls';
}
