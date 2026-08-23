// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get mindful_tagline => 'Concentrati sulle cose importanti';

  @override
  String get unlock_button_label => 'Sblocca';

  @override
  String get permission_status_off => 'Spento';

  @override
  String get permission_status_allowed => 'Concesso';

  @override
  String get permission_status_not_allowed => 'Non concesso';

  @override
  String get permission_button_grant_permission => 'Concedi permesso';

  @override
  String get permission_button_agree_and_continue => 'Accetta e Continua';

  @override
  String get permission_button_not_now => 'Non ora';

  @override
  String get permission_button_help => 'Aiuto?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox è sicura al 100% e funziona offline. Nessun dato personale viene raccolto o conservato.';

  @override
  String permission_grant_step_one(String button_label) {
    return 'Premi il pulsante $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      'Seleziona NLP digitox nella prossima schermata.';

  @override
  String get permission_grant_step_three =>
      'Premi per abilitare NLP digitox come mostrato qui.';

  @override
  String get permission_notification_title => 'Invia Notifiche';

  @override
  String get permission_alarms_title => 'Sveglie e Promemoria';

  @override
  String get permission_alarms_info =>
      'Per favore concedi l\'autorizzazione per l\'impostazione di avvisi e promemoria. Questo permetterà a NLP digitox di avviare la programmazione notturna e di resettare i timer delle app ogni giorno a mezzanotte.';

  @override
  String get permission_alarms_device_tile_label =>
      'Consenti l\'impostazione di sveglie e promemoria';

  @override
  String get permission_usage_title => 'Accesso ai dati di utilizzo';

  @override
  String get permission_usage_info =>
      'Si prega di concedere il permesso di accesso all\'uso. Questo consentirà a NLP digitox di monitorare l\'utilizzo delle app e gestire l\'accesso a determinate app, garantendo un ambiente digitale più mirato e controllato.';

  @override
  String get permission_usage_device_tile_label =>
      'Consenti accesso ai dati di utilizzo';

  @override
  String get permission_overlay_title => 'Overlay Schermo';

  @override
  String get permission_overlay_info =>
      'Concedi l\'autorizzazione per la sovrapposizione di visualizzazione. Ciò consentirà a NLP digitox di mostrare un overlay quando viene aperta un\'app in pausa, aiutandoti a rimanere concentrato e a mantenere il tuo programma.';

  @override
  String get permission_overlay_device_tile_label =>
      'Consenti la visualizzazione su altre app';

  @override
  String get permission_accessibility_title => 'Accessibilità';

  @override
  String get permission_accessibility_info =>
      'Si prega di concedere l\'autorizzazione di accessibilità. Ciò consentirà a NLP digitox di limitare l\'accesso ai contenuti video in formato breve (ad esempio, Reels, Shorts) all\'interno delle app e dei browser dei social media e di filtrare i siti Web inappropriati.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox richiede l\'autorizzazione di accessibilità per bloccare in modo efficace contenuti brevi e siti Web.';

  @override
  String get permission_accessibility_device_tile_label => 'Usa NLP digitox';

  @override
  String get permission_dnd_title => 'Non disturbare';

  @override
  String get permission_dnd_info =>
      'Concedere l\'accesso Non disturbare. Ciò consentirà a NLP digitox di avviare e interrompere la modalità Non disturbare durante la programmazione dell\'ora di andare a dormire.';

  @override
  String get permission_dnd_tile_title => 'Avvia DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Abilita anche la modalità Non disturbare.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignora Ottimizzazioni Batteria';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Già senza restrizioni';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Disabilita la restrizione dello sfondo';

  @override
  String get permission_battery_optimization_allow_info =>
      'Consentire \"Ignora ottimizzazione batteria\" concederà automaticamente l\'autorizzazione \"Allarmi e promemoria\" su alcuni dispositivi.';

  @override
  String get permission_vpn_title => 'Crea VPN';

  @override
  String get permission_vpn_info =>
      'Concedi l\'autorizzazione per creare una connessione VPN (rete privata virtuale). Ciò consentirà a NLP digitox di limitare l\'accesso a Internet per le applicazioni designate creando una VPN locale sul dispositivo.';

  @override
  String get permission_admin_title => 'Ammin';

  @override
  String get permission_admin_info =>
      'I privilegi amministrativi sono necessari solo per le operazioni essenziali per garantire che l\'app funzioni correttamente e rimanga a prova di manomissione.';

  @override
  String get permission_admin_snack_alert =>
      'La protezione antimanomissione può essere disabilitata solo durante la finestra temporale selezionata.';

  @override
  String get permission_notification_access_title => 'Accesso alle notifiche';

  @override
  String get permission_notification_access_info =>
      'Concedere l\'autorizzazione di accesso alle notifiche. Ciò consentirà a NLP digitox di organizzare le tue notifiche e consegnarle secondo il tuo programma.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox richiede l\'accesso alle notifiche batch e pianificate.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Consenti l\'accesso alle notifiche';

  @override
  String get day_today => 'Oggi';

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
      other: '$countString giorni',
      one: '1 giorno',
      zero: '0 giorni',
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
      one: '1 ora',
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
      other: '$countString minuti',
      one: '1 minuto',
      zero: '0 minuti',
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
      other: '$countString secondi',
      one: '1 secondo',
      zero: '0 secondi',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'e';

  @override
  String get timer_status_active => 'Attivo';

  @override
  String get timer_status_paused => 'In pausa';

  @override
  String get create_button => 'Crea';

  @override
  String get update_button => 'Aggiorna';

  @override
  String get dialog_button_cancel => 'Cancella';

  @override
  String get dialog_button_remove => 'Rimuovi';

  @override
  String get dialog_button_set => 'Impostato';

  @override
  String get dialog_button_reset => 'Ripristina';

  @override
  String get dialog_button_infinite => 'Infinito';

  @override
  String get schedule_start_label => 'Inizia';

  @override
  String get schedule_end_label => 'Termina';

  @override
  String get exit_without_saving_dialog_info =>
      'Sei sicuro di voler uscire senza salvare?';

  @override
  String get development_dialog_info =>
      'NLP digitox è attualmente in fase di sviluppo e potrebbe contenere bug o funzionalità incomplete. Se riscontri problemi, segnalali per aiutarci a migliorare.\n\nGrazie per il tuo feedback!';

  @override
  String get development_dialog_button_report_issue => 'Segnala un problema';

  @override
  String get development_dialog_button_close => 'Chiudi';

  @override
  String get dnd_settings_tile_title => 'Non disturbare le impostazioni';

  @override
  String get dnd_settings_tile_subtitle =>
      'Gestisci quali app e notifiche possono raggiungerti in DND.';

  @override
  String get quick_actions_heading => 'Azioni rapide';

  @override
  String get select_distracting_apps_heading =>
      'Seleziona le app che ti distraggono';

  @override
  String get your_distracting_apps_heading => 'Le tue app che distraggono';

  @override
  String get select_more_apps_heading => 'Seleziona altre app';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Non è consentito aggiungere app di sistema importanti all\'elenco delle app che distraggono.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'L\'utilizzo e le restrizioni dello schermo non sono disponibili per questa applicazione. Al momento è accessibile solo l\'utilizzo della rete';

  @override
  String get create_group_fab_button => 'Crea gruppo';

  @override
  String get active_period_info =>
      'Imposta un periodo di tempo durante il quale sarà consentito l\'accesso. Al di fuori di questo lasso di tempo l\'accesso sarà limitato.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Seleziona almeno un\'app che distrae.';

  @override
  String get donation_card_title => 'Sostienici';

  @override
  String get donation_card_info =>
      'NLP digitox è gratuito e open source, sviluppato con mesi di dedizione. Se ti ha aiutato, la tua donazione significherebbe moltissimo per noi. Ogni contributo ci aiuta a continuare a migliorarlo e a mantenerlo per tutti.';

  @override
  String get operation_failed_snack_alert =>
      'Operazione fallita, qualcosa è andato storto!';

  @override
  String get donation_card_button_donate => 'Dona';

  @override
  String get app_restart_dialog_title => 'È necessario riavviare';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox si riavvierà automaticamente al termine del conto alla rovescia. Si prega di pazientare mentre vengono applicate le modifiche.';

  @override
  String get accessibility_tip =>
      'Desideri un blocco più intelligente e più rispettoso della batteria? Abilita l\'autorizzazione di accessibilità per NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox non funziona? Consenti \"Ignora ottimizzazione batteria\" nelle Impostazioni per mantenerlo senza intoppi.';

  @override
  String get invincible_mode_tip =>
      'Restrizioni rimosse accidentalmente? Usa la modalità Invincibile per bloccarli fino al giorno successivo o alla finestra di aggiustamento.';

  @override
  String get glance_usage_tip =>
      'Vuoi approfondimenti? Controlla la sezione Sguardo per visualizzare i modelli di utilizzo e il tempo di utilizzo.';

  @override
  String get tamper_protection_tip =>
      'Disinstallare NLP digitox? Abilitare la finestra di disinstallazione per disattivare prima in modo sicuro la protezione antimanomissione.';

  @override
  String get notification_blocking_tip =>
      'Vuoi ridurre le distrazioni? Utilizza il blocco delle notifiche per silenziare le app selezionate.';

  @override
  String get usage_history_tip =>
      'Vuoi riflettere sulle tue abitudini? Controlla la cronologia di utilizzo per vedere i modelli passati.';

  @override
  String get focus_mode_tip =>
      'Hai bisogno di una concentrazione profonda? Attiva la modalità Focus per bloccare app e notifiche durante le attività.';

  @override
  String get bedtime_reminder_tip =>
      'Vuoi migliorare il tuo sonno? Imposta un promemoria per andare a dormire per rilassarti di notte.';

  @override
  String get custom_blocking_tip =>
      'Hai bisogno di un\'esperienza personalizzata? Crea regole di blocco delle app adatte alle tue esigenze.';

  @override
  String get session_timeline_tip =>
      'Vuoi monitorare le sessioni di focus? Visualizza la sequenza temporale per vedere il tuo percorso di concentrazione.';

  @override
  String get short_content_blocking_tip =>
      'Distratto dalle app social? Blocca contenuti brevi su Instagram, YouTube, ecc., per rimanere concentrato.';

  @override
  String get parental_controls_tip =>
      'Hai bisogno del controllo parentale? Imposta restrizioni per il dispositivo di tuo figlio per garantire un\'esperienza sicura.';

  @override
  String get notification_batching_tip =>
      'Vuoi ridurre le distrazioni? Utilizza Notification Batching per raggruppare le notifiche e controllarle contemporaneamente.';

  @override
  String get notification_scheduling_tip =>
      'Hai bisogno di gestire le notifiche? Pianifica la ricezione delle notifiche per app specifiche.';

  @override
  String get quick_focus_tile_tip =>
      'Hai bisogno di un accesso rapido per mettere a fuoco? Aggiungi una tessera Messa a fuoco rapida per attivare immediatamente la modalità Messa a fuoco.';

  @override
  String get app_shortcuts_tip =>
      'Desideri l\'accesso istantaneo all\'app? Aggiungi scorciatoie premendo a lungo l\'icona dell\'app per azioni rapide.';

  @override
  String get backup_usage_db_tip =>
      'Vuoi salvare i tuoi dati? Esegui il backup del database di utilizzo per mantenere i tuoi record al sicuro.';

  @override
  String get dynamic_material_color_tip =>
      'Vuoi un tema personalizzato? Abilita il colore dinamico del materiale in modo che corrisponda al tema del tuo dispositivo.';

  @override
  String get amoled_dark_theme_tip =>
      'Vuoi risparmiare batteria? Utilizza il tema scuro AMOLED per ridurre il consumo energetico sugli schermi OLED.';

  @override
  String get customize_usage_history_tip =>
      'Vuoi conservare la cronologia di utilizzo? Personalizza il numero di settimane di dati da archiviare nella Cronologia utilizzo.';

  @override
  String get grouped_apps_blocking_tip =>
      'Vuoi bloccare le app insieme? Utilizza i Gruppi di restrizione per raggruppare i limiti delle app e bloccare più app contemporaneamente.';

  @override
  String get websites_blocking_tip =>
      'Desideri un\'esperienza di navigazione più pulita? Blocca siti Web personalizzati o NSFW per un tempo online più mirato.';

  @override
  String get data_usage_tip =>
      'Vuoi tenere traccia dei tuoi dati? Monitora l\'utilizzo dei dati mobili e Wi-Fi per il consumo di Internet.';

  @override
  String get block_internet_tip =>
      'Hai bisogno di bloccare Internet di un\'app? Interrompi Internet per un\'app specifica dalla dashboard dell\'app.';

  @override
  String get emergency_passes_tip =>
      'Hai bisogno di una pausa? Utilizza 3 pass di emergenza al giorno per sbloccare temporaneamente le app per 5 minuti.';

  @override
  String get onboarding_skip_btn_label => 'Salta';

  @override
  String get onboarding_finish_setup_btn_label => 'Termina Setup';

  @override
  String get onboarding_page_welcome_title => 'Benvenuto/a in NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Prendi il controllo della tua vita digitale e costruisci abitudini di schermo più sane. NLP digitox ti aiuta a rimanere concentrato, ridurre le distrazioni e fare scelte consapevoli ogni giorno.';

  @override
  String get onboarding_page_statistics_title => 'Conosci le tue abitudini.';

  @override
  String get onboarding_page_statistics_info =>
      'Comprendi i tuoi schemi digitali con approfondimenti dettagliati su tempo di schermo, utilizzo delle app e tendenze di concentrazione. Monitora i tuoi progressi e scopri come piccoli cambiamenti portano a grandi miglioramenti.';

  @override
  String get onboarding_page_one_title => 'Maestro Focalizzato.';

  @override
  String get onboarding_page_one_info =>
      'Metti in pausa le app che ti distraggono, blocca i contenuti brevi e rimani aggiornato con sessioni di focus personalizzabili. Che tu stia lavorando, studiando o rilassandoti, NLP digitox ti aiuta a mantenere il controllo.';

  @override
  String get onboarding_page_two_title => 'Blocca distrazioni.';

  @override
  String get onboarding_page_two_info =>
      'Imposta limiti di utilizzo, metti in pausa automaticamente le app e crea abitudini digitali più sane. Utilizza la modalità Riposo per rilassarti e goderti una notte senza distrazioni.';

  @override
  String get onboarding_page_three_title => 'Privacy prima di tutto.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox è open source al 100% e funziona interamente offline. Non raccogliamo né condividiamo i tuoi dati personali: la tua privacy è garantita in ogni modo.';

  @override
  String get onboarding_page_permissions_title => 'Permessi essenziali.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox richiede il rispetto delle autorizzazioni essenziali per monitorare e gestire il tempo trascorso sullo schermo, contribuendo a ridurre le distrazioni e migliorare la concentrazione.';

  @override
  String get dashboard_tab_title => 'Cruscotto';

  @override
  String get focus_now_fab_button => 'Concentrati adesso';

  @override
  String get welcome_greetings => 'Felice di rivederti,';

  @override
  String get username_snack_alert =>
      'Premi a lungo per modificare il nome utente.';

  @override
  String get username_dialog_title => 'Nome utente';

  @override
  String get username_dialog_info =>
      'Inserisci il tuo nome utente che verrà visualizzato sulla dashboard.';

  @override
  String get username_dialog_button_apply => 'Applica';

  @override
  String get glance_tile_title => 'Sguardo';

  @override
  String get glance_tile_subtitle => 'Dai una rapida occhiata al tuo utilizzo.';

  @override
  String get parental_controls_tile_subtitle =>
      'Modalità invincibile e protezione antimanomissione.';

  @override
  String get restrictions_heading => 'Restrizioni';

  @override
  String get apps_blocking_tile_title => 'Blocco delle app';

  @override
  String get apps_blocking_tile_subtitle => 'Limita le app in più modi.';

  @override
  String get grouped_apps_blocking_tile_title => 'Blocco delle app raggruppate';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Limita gruppo di app contemporaneamente.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Limita i contenuti brevi su più piattaforme.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Limita i siti Web per adulti e personalizzati.';

  @override
  String get screen_time_label => 'Tempo sullo schermo';

  @override
  String get total_data_label => 'Dati totali';

  @override
  String get mobile_data_label => 'Dati mobili';

  @override
  String get wifi_data_label => 'Dati Wi-Fi';

  @override
  String get focus_today_label => 'Concentrati oggi';

  @override
  String get focus_weekly_label => 'Concentrati settimanalmente';

  @override
  String get focus_monthly_label => 'Concentrarsi mensilmente';

  @override
  String get focus_lifetime_label => 'Concentrati sulla vita';

  @override
  String get longest_streak_label => 'Serie più lunga';

  @override
  String get current_streak_label => 'Serie attuale';

  @override
  String get successful_sessions_label => 'Sessioni di successo';

  @override
  String get failed_sessions_label => 'Sessioni fallite';

  @override
  String get statistics_tab_title => 'Statistiche';

  @override
  String get screen_segment_label => 'Schermo';

  @override
  String get data_segment_label => 'Dati';

  @override
  String get mobile_label => 'Dati Mobili';

  @override
  String get wifi_label => 'Wi-Fi';

  @override
  String get most_used_apps_heading => 'App più usate';

  @override
  String get show_all_apps_tile_title => 'Mostra tutte le app';

  @override
  String get search_apps_hint => 'Cerca app...';

  @override
  String get notifications_tab_title => 'Notifiche';

  @override
  String get notifications_tab_info =>
      'Notifica in batch dalle app e orari impostati come mattina, mezzogiorno, sera e notte. Rimani aggiornato senza continue interruzioni.';

  @override
  String get batched_apps_tile_title => 'App in batch';

  @override
  String get batch_recap_dropdown_title => 'Tipo di riepilogo batch';

  @override
  String get batch_recap_dropdown_info =>
      'Scegli cosa inviare quando si attiva una pianificazione: tutte le notifiche o solo un riepilogo.';

  @override
  String get batch_recap_option_summery_only => 'Solo riepilogo';

  @override
  String get batch_recap_option_all_notifications => 'Tutte le notifiche';

  @override
  String get notification_history_tile_title => 'Cronologia delle notifiche';

  @override
  String get store_all_tile_title => 'Memorizza tutte le notifiche';

  @override
  String get store_all_tile_subtitle =>
      'Salva anche le notifiche non raggruppate.';

  @override
  String get schedules_heading => 'Orari';

  @override
  String get new_schedule_fab_button => 'Nuovo programma';

  @override
  String get new_schedule_dialog_info =>
      'Inserisci un nome per la pianificazione delle notifiche per identificarla facilmente.';

  @override
  String get new_schedule_dialog_field_label => 'Nome del programma';

  @override
  String get bedtime_tab_title => 'Ora di dormire';

  @override
  String get bedtime_tab_info =>
      'Imposta la programmazione dell\'ora di andare a dormire selezionando un periodo di tempo e i giorni della settimana. Scegli le app che ti distraggono per bloccare e abilitare la modalità Non disturbare (DND) per una notte tranquilla.';

  @override
  String get schedule_tile_title => 'Programma';

  @override
  String get schedule_tile_subtitle =>
      'Abilita o disabilita la programmazione giornaliera.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Seleziona almeno un giorno della settimana.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'La durata totale del momento di andare a dormire deve essere di almeno 30 minuti.';

  @override
  String get distracting_apps_tile_title => 'App che distraggono';

  @override
  String get distracting_apps_tile_subtitle =>
      'Seleziona quali app ti distraggono dalla routine della buonanotte.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Non sono consentite modifiche all\'elenco delle app che ti distraggono mentre è attiva la programmazione della buonanotte.';

  @override
  String get parental_controls_tab_title => 'Controlli parentali';

  @override
  String get invincible_mode_heading => 'Modalità invincibile';

  @override
  String get invincible_mode_tile_title => 'Attiva modalità invincibile';

  @override
  String get invincible_mode_info =>
      'Quando la Modalità Invincibile è attiva, non potrai modificare i limiti selezionati dopo aver raggiunto la tua quota giornaliera. Tuttavia, puoi apportare modifiche entro una finestra invincibile selezionata di 10 minuti.';

  @override
  String get invincible_mode_snack_alert =>
      'A causa della modalità invincibile, non sono consentite modifiche alle restrizioni.';

  @override
  String get invincible_mode_dialog_info =>
      'Sei assolutamente sicuro di voler abilitare la Modalità Invincibile? Questa azione è irreversibile. Una volta attivata la Modalità Invincibile, non puoi disattivarla finché questa app è installata sul tuo dispositivo.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'La Modalità Invincibile non può essere disattivata finché questa app rimane installata sul tuo dispositivo.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Inizia comunque';

  @override
  String get invincible_mode_include_timer_tile_title => 'Includi timer';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Includi limite di lancio';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Includi periodo attivo';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Restrizioni dell\'app';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Impedisci modifiche alle restrizioni selezionate dell\'app una volta superati i limiti giornalieri.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Restrizioni di gruppo';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Impedisci modifiche alle restrizioni selezionate del gruppo una volta superati i limiti giornalieri.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Includi timer per i pantaloncini';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Impedisce modifiche dopo aver raggiunto il limite giornaliero di shorts.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Includi l\'ora di andare a dormire';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Impedisce modifiche durante la programmazione attiva della buonanotte.';

  @override
  String get protected_access_tile_title => 'Accesso protetto';

  @override
  String get protected_access_tile_subtitle =>
      'Proteggi NLP digitox con il blocco del tuo dispositivo.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Configura prima un blocco biometrico sul tuo dispositivo per abilitare questa funzione.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Il blocco del tuo dispositivo è stato rimosso. Per continuare, imposta un nuovo blocco.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Autenticazione non riuscita. È necessario verificare il blocco del dispositivo per procedere.';

  @override
  String get tamper_protection_tile_title => 'Protezione antimanomissione';

  @override
  String get tamper_protection_tile_subtitle =>
      'Impedisci la disinstallazione e forza l\'arresto dell\'app.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Una volta abilitato, non sarai in grado di disinstallare, forzare l\'arresto o cancellare i dati di NLP digitox, tranne durante la finestra di disinstallazione selezionata. Non esistono soluzioni alternative.\n\nProcedi a tuo rischio e pericolo.';

  @override
  String get uninstall_window_tile_title => 'Finestra di disinstallazione';

  @override
  String get uninstall_window_tile_subtitle =>
      'La protezione antimanomissione può essere disabilitata entro 10 minuti dall\'orario selezionato.';

  @override
  String get invincible_window_tile_title => 'Finestra invincibile';

  @override
  String get invincible_window_tile_subtitle =>
      'I limiti selezionati possono essere modificati entro 10 minuti dall\'orario selezionato.';

  @override
  String get shorts_blocking_tab_title => 'Blocco dei pantaloncini';

  @override
  String get shorts_blocking_tab_info =>
      'Controlla quanto tempo dedichi ai contenuti brevi su piattaforme come Instagram, YouTube, Snapchat e Facebook, compresi i relativi siti web.';

  @override
  String get short_content_heading => 'Contenuti brevi';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'A sinistra di $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Imposta un limite di tempo giornaliero per i contenuti brevi. Una volta raggiunto il limite, il contenuto breve verrà messo in pausa fino a mezzanotte.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Limita le funzionalità su Instagram.';

  @override
  String get instagram_features_block_reels => 'Limita la sezione dei rulli.';

  @override
  String get instagram_features_block_explore => 'Limita la sezione Esplora.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Limita le funzionalità su Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Limita la sezione dei riflettori.';

  @override
  String get snapchat_features_block_discover =>
      'Limita la sezione di scoperta.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Limita i cortometraggi su YouTube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Limita i reel su Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle =>
      'Limita i cortometraggi su Reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Limita il feed video su X.';

  @override
  String get threads_features_tile_title => 'Discussioni';

  @override
  String get threads_features_tile_subtitle =>
      'Limita video/reels nelle discussioni.';

  @override
  String get websites_blocking_tab_title => 'Blocco dei siti web';

  @override
  String get websites_blocking_tab_info =>
      'Blocca i siti Web per adulti e tutti i siti personalizzati che scegli per creare un\'esperienza online più sicura e mirata. Prendi il controllo della tua navigazione e rimani libero da distrazioni.';

  @override
  String get adult_content_heading => 'Contenuti per adulti';

  @override
  String get block_nsfw_title => 'Blocca NSFW';

  @override
  String get block_nsfw_subtitle =>
      'Limita l\'apertura dei browser di siti Web per adulti e pornografici.';

  @override
  String get block_nsfw_dialog_info =>
      'Sei sicuro? Questa azione è irreversibile. Una volta attivato il blocco dei siti per adulti, non puoi disattivarlo finché questa app è installata sul tuo dispositivo.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Blocca comunque';

  @override
  String get blocked_websites_heading => 'Siti bloccati';

  @override
  String get blocked_websites_empty_list_hint =>
      'Fai clic sul pulsante \"+ Aggiungi sito web\" per aggiungere siti web che distraggono e che desideri bloccare.';

  @override
  String get add_website_fab_button => 'Aggiungi sito';

  @override
  String get add_website_dialog_title => 'Sito web che distrae';

  @override
  String get add_website_dialog_info =>
      'Inserisci l\'indirizzo del sito che vuoi bloccare.';

  @override
  String get add_website_dialog_is_nsfw => 'Il sito è nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Attenzione: i siti Nsfw non possono essere rimossi una volta aggiunti.';

  @override
  String get add_website_dialog_button_block => 'Blocca';

  @override
  String get add_website_already_exist_snack_alert =>
      'L\'URL è già stato aggiunto all\'elenco dei siti Web bloccati.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'URL non valido! Impossibile analizzare il nome host.';

  @override
  String get remove_website_dialog_title => 'Rimuovi sito';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Sei sicuro? desideri rimuovere \'$websitehost\' dai siti Web bloccati.';
  }

  @override
  String get focus_tab_title => 'Concentrati';

  @override
  String get focus_tab_info =>
      'Quando hai bisogno di tempo per concentrarti, avvia una nuova sessione selezionando il tipo, scegliendo le app che distraggono da mettere in pausa e abilitando Non disturbare per una concentrazione ininterrotta.';

  @override
  String get active_session_card_title => 'Sessione attiva';

  @override
  String get active_session_card_info =>
      'Hai una sessione di focus attiva in corso! Fai clic su \"Visualizza\" per verificare i tuoi progressi e vedere quanto tempo è trascorso.';

  @override
  String get active_session_card_view_button => 'Visualizza';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'La rimozione di app dall\'elenco delle app che distraggono non è consentita mentre è attiva una sessione Focus. Tuttavia, durante questo periodo potresti comunque aggiungere altre app all\'elenco.';

  @override
  String get focus_profile_tile_title => 'Profilo di messa a fuoco';

  @override
  String get focus_session_duration_tile_title => 'Durata della sessione';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Infinito (a meno che non ti fermi)';

  @override
  String get focus_session_duration_dialog_info =>
      'Seleziona la durata desiderata per questa sessione di concentrazione, determinando per quanto tempo desideri rimanere concentrato e privo di distrazioni.';

  @override
  String get focus_profile_customization_tile_title =>
      'Personalizzazione del profilo';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Personalizza le impostazioni per il profilo selezionato.';

  @override
  String get focus_enforce_tile_title => 'Forza sessione';

  @override
  String get focus_enforce_tile_subtitle =>
      'Impedisce di terminare una sessione prima dello scadere del tempo.';

  @override
  String get focus_session_start_button => 'Scorri per avviare la sessione';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Seleziona almeno un\'app che ti distrae per avviare la sessione di concentrazione';

  @override
  String get focus_session_already_active_snack_alert =>
      'Hai già una sessione di focus attiva in esecuzione. Completa o interrompi la sessione corrente prima di iniziarne una nuova.';

  @override
  String get focus_session_type_study => 'Studio';

  @override
  String get focus_session_type_work => 'Lavoro';

  @override
  String get focus_session_type_exercise => 'Esercizio';

  @override
  String get focus_session_type_meditation => 'Meditazione';

  @override
  String get focus_session_type_creativeWriting => 'Scrittura Creativa';

  @override
  String get focus_session_type_reading => 'Leggere';

  @override
  String get focus_session_type_programming => 'Programmazione';

  @override
  String get focus_session_type_chores => 'Compiti';

  @override
  String get focus_session_type_projectPlanning => 'Programmazione Progetto';

  @override
  String get focus_session_type_artAndDesign => 'Arte e Design';

  @override
  String get focus_session_type_languageLearning => 'Apprendimento Linguistico';

  @override
  String get focus_session_type_musicPractice => 'Pratica Musicale';

  @override
  String get focus_session_type_selfCare => 'Cura Personale';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Sviluppo delle competenze';

  @override
  String get focus_session_type_research => 'Ricerca';

  @override
  String get focus_session_type_networking => 'Rete';

  @override
  String get focus_session_type_cooking => 'Cucinare';

  @override
  String get focus_session_type_sportsTraining => 'Allenamento Sportivo';

  @override
  String get focus_session_type_restAndRelaxation => 'Riposo e Rilassamento';

  @override
  String get focus_session_type_other => 'Altro';

  @override
  String get timeline_tab_title => 'Cronologia';

  @override
  String get focus_timeline_tab_info =>
      'Esplora il tuo percorso di concentrazione selezionando una data dal calendario. Tieni traccia dei tuoi progressi, rivisita i tuoi successi e impara dalle sfide.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Il tuo tempo produttivo totale per il mese selezionato è $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Giorni produttivi';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Hai avuto un totale di $daysCount giorni produttivi nel mese selezionato.';
  }

  @override
  String get selected_day_focused_time_label => 'Tempo concentrato';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Il tuo tempo totale di concentrazione per il giorno selezionato è $timeString.';
  }

  @override
  String get calender_heading => 'Calendario';

  @override
  String get your_sessions_heading => 'Le tue sessioni';

  @override
  String get your_sessions_empty_list_hint =>
      'Nessuna sessione registrata nel giorno selezionato.';

  @override
  String get focus_session_tile_timestamp_label => 'Timestamp';

  @override
  String get focus_session_tile_duration_label => 'Durata';

  @override
  String get focus_session_tile_reflection_label => 'Riflessione';

  @override
  String get focus_session_state_active => 'Attiva';

  @override
  String get focus_session_state_successful => 'Completato';

  @override
  String get focus_session_state_failed => 'Fallita';

  @override
  String get active_session_tab_title => 'Sessione';

  @override
  String get active_session_none_warning =>
      'Nessuna sessione attiva. Ritorna alla schermata iniziale.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Continua così';

  @override
  String get active_session_finish_dialog_title => 'Finito';

  @override
  String get active_session_finish_dialog_info =>
      'Resisti! Stai andando forte. Sei sicuro che vuoi interrompere la sessione? Ogni passo ti porta sempre più vicino al tuo obiettivo.';

  @override
  String get active_session_giveup_dialog_title => 'Arrenditi';

  @override
  String get active_session_giveup_dialog_info =>
      'Resisti! Ce l\'hai quasi fatta, non ti arrendere adesso! Sei sicuro di voler interrompere prematuramente questa sessione? Tutti i progressi fatti saranno perduti.';

  @override
  String get active_session_reflection_dialog_title =>
      'Riflessione della sessione';

  @override
  String get active_session_reflection_dialog_info =>
      'Prenditi un momento per riflettere sui tuoi progressi. Qual è il tuo obiettivo per questa sessione? Cosa hai realizzato durante questa sessione?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Suggerimento: puoi sempre modificarlo in un secondo momento nella sequenza temporale della sessione.';

  @override
  String get active_session_giveup_snack_alert =>
      'Ti sei arreso! Non ti preoccupare, puoi fare meglio la prossima volta. Ogni sforzo conta - basta non fermarsi';

  @override
  String get active_session_quote_one =>
      'Ogni passo conta, resta forte e non ti fermare';

  @override
  String get active_session_quote_two =>
      'Rimani concentrato! Stai facendo dei progressi impressionanti';

  @override
  String get active_session_quote_three => 'Stai andando forte! Continua così';

  @override
  String get active_session_quote_four =>
      'Solo un altro po\', stai andando alla grande';

  @override
  String active_session_quote_five(String durationString) {
    return 'Congratulazioni! 🎉\nHai completato la tua sessione di concentrazione di $durationString.\n\nOttimo lavoro - continua così!';
  }

  @override
  String get restriction_groups_tab_title => 'Gruppi di limitazioni';

  @override
  String get restriction_groups_tab_info =>
      'Imposta un limite di tempo di utilizzo combinato per un gruppo di app. Una volta che l\'utilizzo totale raggiunge il limite, tutte le app del gruppo verranno messe in pausa per mantenere la concentrazione e l\'equilibrio.';

  @override
  String get restriction_group_time_spent_label => 'Tempo trascorso oggi';

  @override
  String get restriction_group_time_left_label => 'Tempo rimasto oggi';

  @override
  String get restriction_group_name_tile_title => 'Nome del gruppo';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Immettere un nome per il gruppo di restrizioni per identificarlo e gestirlo facilmente.';

  @override
  String get restriction_group_timer_tile_title => 'Temporizzatore di gruppo';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Imposta un limite di tempo giornaliero per questo gruppo. Una volta raggiunto il limite, tutte le app di questo gruppo verranno messe in pausa fino a mezzanotte.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Periodo attivo del gruppo';

  @override
  String get remove_restriction_group_dialog_title => 'Rimuovi gruppo';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Sei sicuro? vuoi rimuovere \'$groupName\' dai gruppi con restrizioni.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Imposta un timer o un limite di periodo attivo.';

  @override
  String get notifications_empty_list_hint =>
      'Nessuna notifica è stata raggruppata per la giornata.';

  @override
  String get conversations_label => 'Conversazioni';

  @override
  String get last_24_hours_heading => 'Ultime 24 ore';

  @override
  String get notification_timeline_tab_info =>
      'Sfoglia la cronologia delle notifiche selezionando una data dal calendario. Scopri quali app hanno attirato la tua attenzione e rifletti sulle tue abitudini digitali.';

  @override
  String get monthly_label => 'Mensile';

  @override
  String get daily_label => 'Ogni giorno';

  @override
  String get search_notifications_sheet_info =>
      'Trova facilmente le notifiche precedenti effettuando una ricerca nel titolo o nel contenuto. Ti aiuta a individuare rapidamente gli avvisi importanti.';

  @override
  String get search_notifications_hint => 'Cerca notifiche...';

  @override
  String get search_notifications_empty_list_hint =>
      'Nessuna notifica trovata corrispondente alla tua ricerca.';

  @override
  String get app_info_none_warning =>
      'Impossibile trovare l\'app per il pacchetto specificato. Ritorno alla schermata iniziale.';

  @override
  String get emergency_fab_button => 'Emergenza';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Questa azione metterà in pausa il blocco dell\'app per i prossimi 5 minuti. Ti restano $leftPassesCount passaggi. Dopo aver utilizzato tutti i pass, l\'app rimarrà bloccata fino a mezzanotte o fino al termine della sessione di focus attivo.\n\nVuoi continuare ancora?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Usa comunque';

  @override
  String get emergency_started_snack_alert =>
      'Il blocco delle app è in pausa e riprenderà il blocco tra 5 minuti.';

  @override
  String get emergency_already_active_snack_alert =>
      'Il blocco delle app è attualmente in pausa o inattivo. Se le notifiche sono abilitate, riceverai aggiornamenti riguardanti il ​​tempo rimanente.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Hai utilizzato tutti i tuoi pass di emergenza. Le app bloccate rimarranno bloccate fino a mezzanotte o al termine della sessione di focus attivo.';

  @override
  String get app_limit_status_not_set => 'Non impostato';

  @override
  String get app_timer_tile_title => 'Timer app';

  @override
  String get app_timer_picker_dialog_info =>
      'Imposta un limite di tempo giornaliero per questa app. Una volta raggiunto il limite, l\'app verrà messa in pausa fino a mezzanotte.';

  @override
  String get usage_reminders_tile_title => 'Promemoria sull\'utilizzo';

  @override
  String get usage_reminders_tile_subtitle =>
      'Delicate sollecitazioni quando si utilizzano app a tempo.';

  @override
  String get app_launch_limit_tile_title => 'Limite di avvii';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Lanciato $count volte oggi.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Imposta quante volte puoi aprire questa app ogni giorno. Una volta raggiunto il limite, verrà sospeso fino a mezzanotte.';

  @override
  String get app_active_period_tile_title => 'Periodo di attività';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Da $startTime a $endTime';
  }

  @override
  String get internet_access_tile_title => 'Accesso a Internet';

  @override
  String get internet_access_tile_subtitle =>
      'Disattiva per bloccare Internet dell\'app.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'La connessione Internet di $appName è bloccata.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'La connessione Internet di $appName è sbloccata.';
  }

  @override
  String get launch_app_tile_title => 'Lancia app';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Apri $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Vai alle impostazioni';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Gestisci le impostazioni dell\'app come notifiche, autorizzazioni, spazio di archiviazione e altro ancora.';

  @override
  String get include_in_stats_tile_title =>
      'Includi nell\'utilizzo dello schermo';

  @override
  String get include_in_stats_tile_subtitle =>
      'Disattiva per escludere questa app dall\'utilizzo totale dello schermo.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName è escluso dall\'utilizzo totale dello schermo.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName è incluso nell\'utilizzo totale dello schermo.';
  }

  @override
  String get general_tab_title => 'Generale';

  @override
  String get appearance_heading => 'Aspetto';

  @override
  String get theme_mode_tile_title => 'Modalità tema';

  @override
  String get theme_mode_system_label => 'Sistema';

  @override
  String get theme_mode_light_label => 'Chiaro';

  @override
  String get theme_mode_dark_label => 'Scuro';

  @override
  String get material_color_tile_title => 'Colore Material';

  @override
  String get amoled_dark_tile_title => 'Scuro AMOLED';

  @override
  String get amoled_dark_tile_subtitle =>
      'Usa il colore nero puro per il tema scuro.';

  @override
  String get dynamic_colors_tile_title => 'Colori dinamici';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Utilizza i colori del dispositivo se supportati.';

  @override
  String get defaults_heading => 'Default';

  @override
  String get app_language_tile_title => 'Lingua applicazione';

  @override
  String get default_home_tab_tile_title => 'Scheda Home';

  @override
  String get usage_history_tile_title => 'Cronologia dell\'utilizzo';

  @override
  String get usage_history_15_days => '15 giorni';

  @override
  String get usage_history_1_month => '1 mese';

  @override
  String get usage_history_3_month => '3 mesi';

  @override
  String get usage_history_6_month => '6 mesi';

  @override
  String get usage_history_1_year => '1 anno';

  @override
  String get service_heading => 'Servizio';

  @override
  String get service_stopping_warning =>
      'Se NLP digitox smette di funzionare in modo imprevisto, concedi l\'autorizzazione \"Ignora ottimizzazione batteria\" per mantenerlo in esecuzione in background. Se il problema persiste, prova a inserire NLP digitox nella whitelist per prestazioni ininterrotte.';

  @override
  String get whitelist_app_tile_title => 'Lista bianca NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Permetti a NLP digitox di avviarsi automaticamente.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Questo dispositivo non supporta la gestione dell\'avvio automatico.';

  @override
  String get database_tab_title => 'Banca dati';

  @override
  String get import_db_tile_title => 'Importa banca dati';

  @override
  String get import_db_tile_subtitle => 'Importa il database da un file.';

  @override
  String get export_db_tile_title => 'Esporta banca dati';

  @override
  String get export_db_tile_subtitle => 'Esporta il database in un file.';

  @override
  String get analysis_tab_title => 'Analisi';

  @override
  String get analysis_7_days => '7 giorni';

  @override
  String get analysis_30_days => '30 giorni';

  @override
  String get analysis_90_days => '90 giorni';

  @override
  String get analysis_screen_time_trend => 'Andamento del tempo di schermo';

  @override
  String get analysis_no_data_info =>
      'Nessun dato sul tempo di schermo registrato per questo periodo.';

  @override
  String get analysis_daily_average => 'Media giornaliera';

  @override
  String get analysis_total => 'Totale';

  @override
  String get analysis_no_change => 'Come la scorsa settimana';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% in meno rispetto alla scorsa settimana';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% in più rispetto alla scorsa settimana';
  }

  @override
  String get crash_logs_heading => 'Report di arresto';

  @override
  String get crash_logs_info =>
      'Se riscontri qualsiasi problema, puoi segnalarlo su GitHub insieme al file di registro. Il file includerà dettagli come produttore, modello, versione Android, versione SDK e registri degli arresti anomali del dispositivo. Queste informazioni ci aiuteranno a identificare e risolvere il problema in modo più efficace.';

  @override
  String get crash_logs_export_tile_title =>
      'Esporta i registri degli arresti anomali';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Esporta i registri degli arresti anomali in un file json.';

  @override
  String get crash_logs_view_tile_title => 'Visualizza i registri';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Esplora i registri degli arresti anomali archiviati.';

  @override
  String get crash_logs_empty_list_hint =>
      'Nessun arresto anomalo registrato fino ad ora.';

  @override
  String get crash_logs_clear_tile_title => 'Cancella report';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Cancella tutti i report di arresto dal database.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Confermi la cancellazione dei report dal database?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Pulisci comunque';

  @override
  String get about_tab_title => 'Su di noi';

  @override
  String get changelog_tile_title => 'Registro delle modifiche';

  @override
  String get changelog_tile_subtitle => 'Scopri cosa c\'è di nuovo.';

  @override
  String get full_changelog_tile_title => 'Registro delle modifiche completo';

  @override
  String get redirected_to_github_subtitle => 'Verrai reindirizzato su GitHub.';

  @override
  String get contribute_heading => 'Contribuisci';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Esplora il codice sorgente.';

  @override
  String get report_issue_tile_title => 'Segnala un problema';

  @override
  String get suggest_idea_tile_title => 'Suggerisci un\'idea';

  @override
  String get write_email_tile_title => 'Scrivici via e-mail';

  @override
  String get write_email_tile_subtitle =>
      'Sarai reindirizzato al tuo client mail.';

  @override
  String get privacy_policy_heading => 'Informativa sulla privacy';

  @override
  String get privacy_policy_info =>
      'NLP digitox si impegna a proteggere la tua privacy. Non raccogliamo, archiviamo o trasferiamo alcun tipo di dati dell\'utente. L\'app funziona interamente offline e non richiede una connessione Internet, garantendo che le tue informazioni personali rimangano private e sicure sul tuo dispositivo. Essendo un\'applicazione software gratuita e open source (FOSS), NLP digitox garantisce completa trasparenza e controllo da parte dell\'utente sui propri dati.';

  @override
  String get more_details_button => 'Più dettagli';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
