// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get mindful_tagline => 'Fokus auf das wirklich wichtige';

  @override
  String get unlock_button_label => 'Entsperren';

  @override
  String get permission_status_off => 'Aus';

  @override
  String get permission_status_allowed => 'Zugelassen';

  @override
  String get permission_status_not_allowed => 'Unzulässig';

  @override
  String get permission_button_grant_permission => 'Erlaubnis erteilen';

  @override
  String get permission_button_agree_and_continue => 'Zustimmen und fortfahren';

  @override
  String get permission_button_not_now => 'Nicht Jetzt';

  @override
  String get permission_button_help => 'Hilfe?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox ist 100% sicher und arbeitet offline. Wir sammeln und speichern keine persönlichen Daten.';

  @override
  String permission_grant_step_one(String button_label) {
    return 'Klicken Sie auf die Schaltfläche $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Wähle NLP digitox auf dem nächsten Bildschirm aus.';

  @override
  String get permission_grant_step_three =>
      '3. Klicken und schalten Sie den Schalter wie unten ein.';

  @override
  String get permission_notification_title => 'Benachrichtigung senden';

  @override
  String get permission_alarms_title => 'Alarme und Erinnerungen';

  @override
  String get permission_alarms_info =>
      'Bitte erteilen Sie die Erlaubnis zum Einstellen von Alarmen und Erinnerungen. Dadurch kann NLP digitox Ihre Schlafenszeit pünktlich starten und die App-Timer täglich um Mitternacht zurücksetzen und Ihnen helfen, auf Kurs zu bleiben.';

  @override
  String get permission_alarms_device_tile_label =>
      'Alarme und Erinnerungen erlauben';

  @override
  String get permission_usage_title => 'Nutzungszugriff';

  @override
  String get permission_usage_info =>
      'Bitte erteilen Sie Zugriffsberechtigung. Dies wird es NLP digitox ermöglichen, die App-Nutzung zu überwachen und den Zugriff auf bestimmte Apps zu verwalten, wodurch eine fokussiertere und kontrolliertere digitale Umgebung gewährleistet wird.';

  @override
  String get permission_usage_device_tile_label => 'Nutzungszugriff zulassen';

  @override
  String get permission_overlay_title => 'Overlay anzeigen';

  @override
  String get permission_overlay_info =>
      'Bitte erteilen Sie die Berechtigung zum Anzeigen von Overlays. Dadurch kann NLP digitox beim Öffnen einer pausierten App ein Overlay anzeigen, sodass Sie konzentriert bleiben und Ihren Zeitplan einhalten können.';

  @override
  String get permission_overlay_device_tile_label =>
      'Einblendung über anderen Apps zulassen';

  @override
  String get permission_accessibility_title => 'Barrierefreiheit';

  @override
  String get permission_accessibility_info =>
      'Bitte erteilen Sie die Erlaubnis zur Barrierefreiheit. Dadurch kann NLP digitox den Zugriff auf kurze Videoinhalte (z. B. Reels, Shorts) in Social-Media-Apps und Browsern einschränken und unangemessene Websites filtern.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox benötigt eine Barrierefreiheitsberechtigung, um kurze Inhalte und Websites effektiv zu blockieren.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Verwenden Sie NLP digitox';

  @override
  String get permission_dnd_title => 'Nicht stören';

  @override
  String get permission_dnd_info =>
      'Bitte gewähren Sie „Bitte nicht stören“-Zugriff. Dadurch kann NLP digitox den „Bitte nicht stören“-Modus während der Schlafenszeit starten und stoppen.';

  @override
  String get permission_dnd_tile_title => 'Starten Sie DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Aktivieren Sie außerdem den Modus „Nicht stören“.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Batterieoptimierung ignorieren';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Bereits uneingeschränkt';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Hintergrundbeschränkung deaktivieren';

  @override
  String get permission_battery_optimization_allow_info =>
      'Wenn Sie „Batterieoptimierung ignorieren“ zulassen, wird auf einigen Geräten automatisch die Berechtigung „Alarme und Erinnerungen“ erteilt.';

  @override
  String get permission_vpn_title => 'VPN erstellen';

  @override
  String get permission_vpn_info =>
      'Bitte erteilen Sie die Berechtigung zum Erstellen einer VPN-Verbindung (Virtual Private Network). Dadurch kann NLP digitox den Internetzugriff für bestimmte Anwendungen einschränken, indem es ein lokales VPN auf dem Gerät erstellt.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Administrative Rechte sind nur für wesentliche Vorgänge erforderlich, um sicherzustellen, dass die Anwendung ordnungsgemäß funktioniert und manipulationssicher ist.';

  @override
  String get permission_admin_snack_alert =>
      'Der Manipulationsschutz kann nur während des gewählten Zeitfensters deaktiviert werden.';

  @override
  String get permission_notification_access_title =>
      'Zugriff auf Benachrichtigungen';

  @override
  String get permission_notification_access_info =>
      'Bitte erteile die Erlaubnis für den Zugriff auf Benachrichtigungen. Dies ermöglicht NLP digitox, dir  Benachrichtigungen zu senden.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox benötigt Zugriff auf Benachrichtigungen, um Benachrichtigungen senden zu können.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Zugriff auf Benachrichtigungen zulassen';

  @override
  String get day_today => 'Heute';

  @override
  String get day_yesterday => 'Gestern';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Tage',
      one: '1 Tag',
      zero: '0 Tage',
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
      other: '$countString Stunden',
      one: '1 Stunde',
      zero: '0 Stunden',
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
      other: '$countString Minuten',
      one: '1 Minute',
      zero: '0 Minuten',
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
      other: '$countString Sekunden',
      one: '1 Sekunde',
      zero: '0 Sekunden',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'und';

  @override
  String get timer_status_active => 'Aktiv';

  @override
  String get timer_status_paused => 'Pausiert';

  @override
  String get create_button => 'Erstellen';

  @override
  String get update_button => 'Aktualisieren';

  @override
  String get dialog_button_cancel => 'Abbrechen';

  @override
  String get dialog_button_remove => 'Entfernen';

  @override
  String get dialog_button_set => 'Übernehmen';

  @override
  String get dialog_button_reset => 'Zurücksetzen';

  @override
  String get dialog_button_infinite => 'Unendlich';

  @override
  String get schedule_start_label => 'Starten';

  @override
  String get schedule_end_label => 'Beenden';

  @override
  String get exit_without_saving_dialog_info =>
      'Sind Sie sicher, dass Sie den Vorgang beenden möchten, ohne zu speichern?';

  @override
  String get development_dialog_info =>
      'NLP digitox befindet sich derzeit in der Entwicklung und kann Fehler oder unvollständige Funktionen aufweisen. Wenn Sie auf Probleme stoßen, melden Sie diese bitte, damit wir uns verbessern können.\n\nVielen Dank für Ihr Feedback!';

  @override
  String get development_dialog_button_report_issue => 'Problem melden';

  @override
  String get development_dialog_button_close => 'Schließen';

  @override
  String get dnd_settings_tile_title => 'Einstellungen nicht stören';

  @override
  String get dnd_settings_tile_subtitle =>
      'Verwalten Sie in DND, welche Apps und Benachrichtigungen Sie erreichen können.';

  @override
  String get quick_actions_heading => 'Schnelle Aktionen';

  @override
  String get select_distracting_apps_heading =>
      'Wählen Sie ablenkende Apps aus';

  @override
  String get your_distracting_apps_heading => 'Ihre ablenkenden Apps';

  @override
  String get select_more_apps_heading => 'Wählen Sie weitere Apps aus';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Das Hinzufügen wichtiger System-Apps zur Liste störender Apps ist nicht gestattet.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Für diese Anwendung sind keine Bildschirmnutzung und Einschränkungen verfügbar. Derzeit ist nur die Netzwerknutzung zugänglich';

  @override
  String get create_group_fab_button => 'Gruppe erstellen';

  @override
  String get active_period_info =>
      'Legen Sie einen Zeitraum fest, in dem der Zugriff erlaubt ist. Außerhalb dieses Zeitraums ist der Zugang eingeschränkt.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Wählen Sie mindestens eine ablenkende App aus.';

  @override
  String get donation_card_title => 'Unterstützen Sie uns';

  @override
  String get donation_card_info =>
      'NLP digitox ist kostenlos und Open Source und wurde mit monatelanger Hingabe entwickelt. Wenn es Ihnen geholfen hat, wäre Ihre Spende für uns von großer Bedeutung. Jeder Beitrag hilft uns, es für alle weiter zu verbessern und aufrechtzuerhalten.';

  @override
  String get operation_failed_snack_alert =>
      'Der Vorgang ist fehlgeschlagen, etwas ist schief gelaufen!';

  @override
  String get donation_card_button_donate => 'Spenden';

  @override
  String get app_restart_dialog_title => 'Neustart erforderlich';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox wird automatisch neu gestartet, sobald der Countdown abgelaufen ist. Bitte haben Sie etwas Geduld, da Änderungen vorgenommen werden.';

  @override
  String get accessibility_tip =>
      'Möchten Sie eine intelligentere und batterieschonendere Blockierung? Aktivieren Sie die Barrierefreiheitsberechtigung für NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox funktioniert nicht? Erlauben Sie in den Einstellungen „Batterieoptimierung ignorieren“, damit es reibungslos läuft.';

  @override
  String get invincible_mode_tip =>
      'Einschränkungen versehentlich entfernt? Verwenden Sie den Unbesiegbarkeitsmodus, um sie bis zum nächsten Tag oder Anpassungsfenster zu sperren.';

  @override
  String get glance_usage_tip =>
      'Möchten Sie Einblicke? Sehen Sie sich den Abschnitt „Überblick“ an, um Ihr Nutzungsverhalten und Ihre Bildschirmzeit anzuzeigen.';

  @override
  String get tamper_protection_tip =>
      'NLP digitox deinstallieren? Aktivieren Sie zunächst das Deinstallationsfenster, um den Manipulationsschutz sicher zu deaktivieren.';

  @override
  String get notification_blocking_tip =>
      'Möchten Sie Ablenkungen reduzieren? Verwenden Sie die Benachrichtigungsblockierung, um ausgewählte Apps stummzuschalten.';

  @override
  String get usage_history_tip =>
      'Möchten Sie über Ihre Gewohnheiten nachdenken? Überprüfen Sie den Nutzungsverlauf, um frühere Muster anzuzeigen.';

  @override
  String get focus_mode_tip =>
      'Brauchen Sie einen tiefen Fokus? Aktivieren Sie den Fokusmodus, um Apps und Benachrichtigungen während Aufgaben zu blockieren.';

  @override
  String get bedtime_reminder_tip =>
      'Möchten Sie Ihren Schlaf verbessern? Richten Sie eine Schlafenszeit-Erinnerung ein, um jeden Abend zur Ruhe zu kommen.';

  @override
  String get custom_blocking_tip =>
      'Benötigen Sie ein individuelles Erlebnis? Erstellen Sie App-Blockierungsregeln, die Ihren Anforderungen entsprechen.';

  @override
  String get session_timeline_tip =>
      'Möchten Sie Fokussitzungen verfolgen? Sehen Sie sich die Zeitleiste an, um Ihre Fokusreise zu sehen.';

  @override
  String get short_content_blocking_tip =>
      'Abgelenkt durch soziale Apps? Blockieren Sie kurze Inhalte auf Instagram, YouTube usw., um konzentriert zu bleiben.';

  @override
  String get parental_controls_tip =>
      'Benötigen Sie eine Kindersicherung? Legen Sie Einschränkungen für das Gerät Ihres Kindes fest, um ein sicheres Erlebnis zu gewährleisten.';

  @override
  String get notification_batching_tip =>
      'Möchten Sie Ablenkungen reduzieren? Verwenden Sie die Benachrichtigungsstapelverarbeitung, um Benachrichtigungen zu gruppieren und auf einmal zu überprüfen.';

  @override
  String get notification_scheduling_tip =>
      'Müssen Sie Benachrichtigungen verwalten? Planen Sie, wann Sie Benachrichtigungen für bestimmte Apps erhalten.';

  @override
  String get quick_focus_tile_tip =>
      'Benötigen Sie schnellen Zugriff, um sich zu konzentrieren? Fügen Sie eine Schnellfokus-Kachel hinzu, um den Fokusmodus sofort zu aktivieren.';

  @override
  String get app_shortcuts_tip =>
      'Möchten Sie sofortigen App-Zugriff? Fügen Sie Verknüpfungen hinzu, indem Sie lange auf das App-Symbol drücken, um schnelle Aktionen auszuführen.';

  @override
  String get backup_usage_db_tip =>
      'Möchten Sie Ihre Daten speichern? Sichern Sie Ihre Nutzungsdatenbank, um Ihre Aufzeichnungen zu schützen.';

  @override
  String get dynamic_material_color_tip =>
      'Möchten Sie ein individuelles Thema? Aktivieren Sie dynamisches Material. Passen Sie die Farbe an das Thema Ihres Geräts an.';

  @override
  String get amoled_dark_theme_tip =>
      'Möchten Sie Batterie sparen? Verwenden Sie das AMOLED Dark Theme, um den Stromverbrauch auf OLED-Bildschirmen zu reduzieren.';

  @override
  String get customize_usage_history_tip =>
      'Möchten Sie den Nutzungsverlauf behalten? Passen Sie an, wie viele Wochen Daten im Nutzungsverlauf gespeichert werden sollen.';

  @override
  String get grouped_apps_blocking_tip =>
      'Möchten Sie Apps gemeinsam blockieren? Verwenden Sie Einschränkungsgruppen, um App-Limits zu gruppieren und mehrere Apps gleichzeitig zu blockieren.';

  @override
  String get websites_blocking_tip =>
      'Möchten Sie ein saubereres Surferlebnis? Blockieren Sie benutzerdefinierte oder NSFW-Websites für eine konzentriertere Online-Zeit.';

  @override
  String get data_usage_tip =>
      'Möchten Sie Ihre Daten verfolgen? Überwachen Sie Ihre Mobil- und WLAN-Datennutzung für den Internetverbrauch.';

  @override
  String get block_internet_tip =>
      'Müssen Sie das Internet einer App blockieren? Trennen Sie die Internetverbindung für eine bestimmte App über das App-Dashboard.';

  @override
  String get emergency_passes_tip =>
      'Brauchen Sie eine Pause? Verwenden Sie täglich 3 Notfallpässe, um Apps vorübergehend für 5 Minuten freizugeben.';

  @override
  String get onboarding_skip_btn_label => 'Überspringen';

  @override
  String get onboarding_finish_setup_btn_label => 'Beenden Sie die Einrichtung';

  @override
  String get onboarding_page_welcome_title => 'Willkommen bei NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Übernimm die Kontrolle über dein digitales Leben und baue gesündere Bildschirmgewohnheiten auf. NLP digitox hilft dir, konzentriert zu bleiben, Ablenkungen zu minimieren und jeden Tag bewusste Entscheidungen zu treffen.';

  @override
  String get onboarding_page_statistics_title => 'Erkenne deine Gewohnheiten.';

  @override
  String get onboarding_page_statistics_info =>
      'Verstehe deine digitalen Muster mit detaillierten Einblicken in Bildschirmzeit, App-Nutzung und Fokustrends. Verfolge deinen Fortschritt und sieh, wie kleine Änderungen zu großen Verbesserungen führen.';

  @override
  String get onboarding_page_one_title => 'Meisterfokus.';

  @override
  String get onboarding_page_one_info =>
      'Unterbrechen Sie ablenkende Apps, blockieren Sie kurze Inhalte und bleiben Sie mit anpassbaren Fokussitzungen auf dem Laufenden. Egal, ob Sie arbeiten, lernen oder sich entspannen, NLP digitox hilft Ihnen, die Kontrolle zu behalten.';

  @override
  String get onboarding_page_two_title => 'Ablenkungen blockieren.';

  @override
  String get onboarding_page_two_info =>
      'Legen Sie Nutzungsbeschränkungen fest, pausieren Sie Apps automatisch und schaffen Sie gesündere digitale Gewohnheiten. Nutzen Sie den Schlafenszeitmodus, um sich zu entspannen und eine ablenkungsfreie Nacht zu genießen.';

  @override
  String get onboarding_page_three_title => 'Datenschutz zuerst.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox ist zu 100 % Open Source und läuft vollständig offline. Wir sammeln oder geben Ihre persönlichen Daten nicht weiter – Ihre Privatsphäre ist in jeder Hinsicht gewährleistet.';

  @override
  String get onboarding_page_permissions_title => 'Wesentliche Berechtigungen.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox erfordert die Befolgung wesentlicher Berechtigungen, um Ihre Bildschirmzeit zu verfolgen und zu verwalten und so Ablenkungen zu reduzieren und die Konzentration zu verbessern.';

  @override
  String get dashboard_tab_title => 'Armaturenbrett';

  @override
  String get focus_now_fab_button => 'Konzentrieren Sie sich jetzt';

  @override
  String get welcome_greetings => 'Willkommen zurück,';

  @override
  String get username_snack_alert =>
      'Lange drücken, um den Benutzernamen zu bearbeiten.';

  @override
  String get username_dialog_title => 'Benutzername';

  @override
  String get username_dialog_info =>
      'Geben Sie Ihren Benutzernamen ein, der im Dashboard angezeigt wird.';

  @override
  String get username_dialog_button_apply => 'Bewerben';

  @override
  String get glance_tile_title => 'Blick';

  @override
  String get glance_tile_subtitle =>
      'Werfen Sie einen kurzen Blick auf Ihre Nutzung.';

  @override
  String get parental_controls_tile_subtitle =>
      'Unbesiegbarer Modus und Manipulationsschutz.';

  @override
  String get restrictions_heading => 'Einschränkungen';

  @override
  String get apps_blocking_tile_title => 'Apps blockieren';

  @override
  String get apps_blocking_tile_subtitle =>
      'Beschränken Sie Apps auf verschiedene Weise.';

  @override
  String get grouped_apps_blocking_tile_title => 'Blockierung gruppierter Apps';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Begrenzen Sie die Gruppe gleichzeitiger Apps.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Begrenzen Sie kurze Inhalte auf mehreren Plattformen.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Beschränken Sie Websites für Erwachsene und benutzerdefinierte Websites.';

  @override
  String get screen_time_label => 'Bildschirmzeit';

  @override
  String get total_data_label => 'Gesamtdaten';

  @override
  String get mobile_data_label => 'Mobile Daten';

  @override
  String get wifi_data_label => 'WLAN-Daten';

  @override
  String get focus_today_label => 'Konzentrieren Sie sich heute';

  @override
  String get focus_weekly_label => 'Konzentrieren Sie sich wöchentlich';

  @override
  String get focus_monthly_label => 'Konzentrieren Sie sich monatlich';

  @override
  String get focus_lifetime_label =>
      'Konzentrieren Sie sich auf die Lebensdauer';

  @override
  String get longest_streak_label => 'Längste Serie';

  @override
  String get current_streak_label => 'Aktuelle Serie';

  @override
  String get successful_sessions_label => 'Erfolgreiche Sitzungen';

  @override
  String get failed_sessions_label => 'Fehlgeschlagene Sitzungen';

  @override
  String get statistics_tab_title => 'Statistiken';

  @override
  String get screen_segment_label => 'Bildschirm';

  @override
  String get data_segment_label => 'Daten';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'WLAN';

  @override
  String get most_used_apps_heading => 'Am häufigsten verwendete Apps';

  @override
  String get show_all_apps_tile_title => 'Alle Apps anzeigen';

  @override
  String get search_apps_hint => 'Apps suchen...';

  @override
  String get notifications_tab_title => 'Benachrichtigungen';

  @override
  String get notifications_tab_info =>
      'Batch-Benachrichtigungen von Apps und legen Sie Zeitpläne wie morgens, mittags, abends und nachts fest. Bleiben Sie ohne ständige Unterbrechungen auf dem Laufenden.';

  @override
  String get batched_apps_tile_title => 'Batch-Apps';

  @override
  String get batch_recap_dropdown_title => 'Batch-Zusammenfassungstyp';

  @override
  String get batch_recap_dropdown_info =>
      'Wählen Sie aus, was gesendet werden soll, wenn ein Zeitplan ausgelöst wird – alle Benachrichtigungen oder nur eine Zusammenfassung.';

  @override
  String get batch_recap_option_summery_only => 'Nur Zusammenfassung';

  @override
  String get batch_recap_option_all_notifications => 'Alle Benachrichtigungen';

  @override
  String get notification_history_tile_title => 'Benachrichtigungsverlauf';

  @override
  String get store_all_tile_title => 'Speichern Sie alle Benachrichtigungen';

  @override
  String get store_all_tile_subtitle =>
      'Speichern Sie auch nicht gestapelte Benachrichtigungen.';

  @override
  String get schedules_heading => 'Zeitpläne';

  @override
  String get new_schedule_fab_button => 'Neuer Zeitplan';

  @override
  String get new_schedule_dialog_info =>
      'Geben Sie einen Namen für den Benachrichtigungszeitplan ein, um ihn leichter identifizieren zu können.';

  @override
  String get new_schedule_dialog_field_label => 'Zeitplanname';

  @override
  String get bedtime_tab_title => 'Schlafenszeit';

  @override
  String get bedtime_tab_info =>
      'Legen Sie Ihren Schlafenszeitplan fest, indem Sie einen Zeitraum und Wochentage auswählen. Wählen Sie störende Apps zum Blockieren und aktivieren Sie den Modus „Bitte nicht stören“ (DND) für eine ruhige Nacht.';

  @override
  String get schedule_tile_title => 'Zeitplan';

  @override
  String get schedule_tile_subtitle =>
      'Tagesplan aktivieren oder deaktivieren.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Wählen Sie mindestens einen Wochentag aus.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Die gesamte Schlafenszeit muss mindestens 30 Minuten betragen.';

  @override
  String get distracting_apps_tile_title => 'Ablenkende Apps';

  @override
  String get distracting_apps_tile_subtitle =>
      'Wählen Sie aus, welche Apps Sie von Ihrer Schlafenszeitroutine ablenken.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Änderungen an der Liste ablenkender Apps sind nicht zulässig, während der Schlafenszeitplan aktiv ist.';

  @override
  String get parental_controls_tab_title => 'Kindersicherung';

  @override
  String get invincible_mode_heading => 'Unbesiegbarer Modus';

  @override
  String get invincible_mode_tile_title =>
      'Aktivieren Sie den Unbesiegbarkeitsmodus';

  @override
  String get invincible_mode_info =>
      'Wenn der Unbesiegbar-Modus aktiviert ist, können Sie ausgewählte Limits nach Erreichen Ihres Tageskontingents nicht mehr anpassen. Sie können jedoch innerhalb eines ausgewählten 10-minütigen unbesiegbaren Fensters Änderungen vornehmen.';

  @override
  String get invincible_mode_snack_alert =>
      'Aufgrund des Unbesiegbarkeitsmodus sind Änderungen an den Einschränkungen nicht zulässig.';

  @override
  String get invincible_mode_dialog_info =>
      'Sind Sie absolut sicher, dass Sie den Unbesiegbaren Modus aktivieren möchten? Diese Aktion ist irreversibel. Sobald der Unbesiegbarkeitsmodus aktiviert ist, können Sie ihn nicht mehr deaktivieren, solange diese App auf Ihrem Gerät installiert ist.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Der Unbesiegbare Modus kann nicht deaktiviert werden, solange diese App auf Ihrem Gerät installiert bleibt.';

  @override
  String get invincible_mode_dialog_button_start_anyway =>
      'Fangen Sie trotzdem an';

  @override
  String get invincible_mode_include_timer_tile_title => 'Timer einschließen';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Startlimit einbeziehen';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Aktiven Zeitraum einbeziehen';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'App-Einschränkungen';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Verhindern Sie Änderungen an den ausgewählten Einschränkungen der App, sobald die Tageslimits überschritten werden.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Gruppenbeschränkungen';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Verhindern Sie Änderungen an den ausgewählten Einschränkungen der Gruppe, sobald die Tageslimits überschritten werden.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Schließen Sie einen Shorts-Timer ein';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Verhindert Änderungen nach Erreichen Ihres täglichen Shorts-Limits.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Berücksichtigen Sie die Schlafenszeit';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Verhindert Änderungen während des aktiven Schlafenszeitplans.';

  @override
  String get protected_access_tile_title => 'Geschützter Zugang';

  @override
  String get protected_access_tile_subtitle =>
      'Schützen Sie NLP digitox mit Ihrer Gerätesperre.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Bitte richten Sie zunächst eine biometrische Sperre auf Ihrem Gerät ein, um diese Funktion zu aktivieren.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Ihre Gerätesperre wurde entfernt. Um fortzufahren, richten Sie bitte ein neues Schloss ein.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Authentifizierung fehlgeschlagen. Sie müssen Ihre Gerätesperre überprüfen, um fortzufahren.';

  @override
  String get tamper_protection_tile_title => 'Manipulationsschutz';

  @override
  String get tamper_protection_tile_subtitle =>
      'Verhindern Sie die Deinstallation und erzwingen Sie das Stoppen der App.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Nach der Aktivierung können Sie die Daten von NLP digitox nicht mehr deinstallieren, den Stopp erzwingen oder löschen, außer während des ausgewählten Deinstallationsfensters. Es gibt keine Problemumgehungen.\n\nVorgehen auf eigenes Risiko.';

  @override
  String get uninstall_window_tile_title => 'Deinstallationsfenster';

  @override
  String get uninstall_window_tile_subtitle =>
      'Der Manipulationsschutz kann innerhalb von 10 Minuten ab dem ausgewählten Zeitpunkt deaktiviert werden.';

  @override
  String get invincible_window_tile_title => 'Unbesiegbares Fenster';

  @override
  String get invincible_window_tile_subtitle =>
      'Ausgewählte Grenzwerte können innerhalb von 10 Minuten ab dem ausgewählten Zeitpunkt geändert werden.';

  @override
  String get shorts_blocking_tab_title => 'Shorts blockieren';

  @override
  String get shorts_blocking_tab_info =>
      'Kontrollieren Sie, wie viel Zeit Sie auf kurzen Inhalten auf Plattformen wie Instagram, YouTube, Snapchat und Facebook, einschließlich deren Websites, verbringen.';

  @override
  String get short_content_heading => 'Kurzer Inhalt';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Links von $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Legen Sie ein tägliches Zeitlimit für kurze Inhalte fest. Sobald Ihr Limit erreicht ist, wird der Kurzinhalt bis Mitternacht pausiert.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Funktionen auf Instagram einschränken.';

  @override
  String get instagram_features_block_reels =>
      'Beschränken Sie den Rollenbereich.';

  @override
  String get instagram_features_block_explore =>
      'Erkundungsbereich einschränken.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Beschränken Sie die Funktionen von Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Spotlight-Bereich einschränken.';

  @override
  String get snapchat_features_block_discover =>
      'Entdeckungsbereich einschränken.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Kurzfilme auf YouTube einschränken.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Beschränken Sie Reels auf Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle =>
      'Beschränken Sie Shorts auf Reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle =>
      'Beschränken Sie den Video-Feed auf X.';

  @override
  String get threads_features_tile_title => 'Themen';

  @override
  String get threads_features_tile_subtitle =>
      'Beschränken Sie Videos/Reels auf Threads.';

  @override
  String get websites_blocking_tab_title => 'Blockierung von Websites';

  @override
  String get websites_blocking_tab_info =>
      'Blockieren Sie Websites für Erwachsene und alle von Ihnen ausgewählten benutzerdefinierten Websites, um ein sichereres und fokussierteres Online-Erlebnis zu schaffen. Übernehmen Sie die Kontrolle über Ihr Surfen und bleiben Sie ablenkungsfrei.';

  @override
  String get adult_content_heading => 'Inhalte für Erwachsene';

  @override
  String get block_nsfw_title => 'Nsfw blockieren';

  @override
  String get block_nsfw_subtitle =>
      'Verhindern Sie, dass Browser Websites für Erwachsene und Pornos öffnen.';

  @override
  String get block_nsfw_dialog_info =>
      'Bist du sicher? Diese Aktion ist irreversibel. Sobald der Blocker für Websites für Erwachsene aktiviert ist, können Sie ihn nicht deaktivieren, solange diese App auf Ihrem Gerät installiert ist.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Blockiere trotzdem';

  @override
  String get blocked_websites_heading => 'Blockierte Websites';

  @override
  String get blocked_websites_empty_list_hint =>
      'Klicken Sie auf die Schaltfläche „+ Website hinzufügen“, um störende Websites hinzuzufügen, die Sie blockieren möchten.';

  @override
  String get add_website_fab_button => 'Website hinzufügen';

  @override
  String get add_website_dialog_title => 'Ablenkende Website';

  @override
  String get add_website_dialog_info =>
      'Geben Sie die URL einer Website ein, die Sie blockieren möchten.';

  @override
  String get add_website_dialog_is_nsfw => 'Ist NSFW-Site?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Warnung: Nsfw-Sites können nach dem Hinzufügen nicht mehr entfernt werden.';

  @override
  String get add_website_dialog_button_block => 'Blockieren';

  @override
  String get add_website_already_exist_snack_alert =>
      'Die URL wurde bereits zur Liste der blockierten Websites hinzugefügt.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Ungültige URL! Der Hostname kann nicht geparst werden.';

  @override
  String get remove_website_dialog_title => 'Website entfernen';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Bist du sicher? Sie möchten „$websitehost“ von blockierten Websites entfernen.';
  }

  @override
  String get focus_tab_title => 'Konzentrieren Sie sich';

  @override
  String get focus_tab_info =>
      'Wenn Sie Zeit zum Konzentrieren benötigen, starten Sie eine neue Sitzung, indem Sie den Typ auswählen, ablenkende Apps zum Anhalten auswählen und „Nicht stören“ für ununterbrochene Konzentration aktivieren.';

  @override
  String get active_session_card_title => 'Aktive Sitzung';

  @override
  String get active_session_card_info =>
      'Sie haben eine aktive Fokussitzung im Gange! Klicken Sie auf „Anzeigen“, um Ihren Fortschritt zu überprüfen und zu sehen, wie viel Zeit vergangen ist.';

  @override
  String get active_session_card_view_button => 'Ansicht';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Das Entfernen von Apps aus der Liste der ablenkenden Apps ist nicht zulässig, während eine Fokussitzung aktiv ist. Während dieser Zeit können Sie der Liste jedoch noch weitere Apps hinzufügen.';

  @override
  String get focus_profile_tile_title => 'Fokusprofil';

  @override
  String get focus_session_duration_tile_title => 'Sitzungsdauer';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Unendlich (es sei denn, du hörst auf)';

  @override
  String get focus_session_duration_dialog_info =>
      'Bitte wählen Sie die gewünschte Dauer für diese Fokussitzung aus und legen Sie fest, wie lange Sie konzentriert und ablenkungsfrei bleiben möchten.';

  @override
  String get focus_profile_customization_tile_title => 'Profilanpassung';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Passen Sie die Einstellungen für das ausgewählte Profil an.';

  @override
  String get focus_enforce_tile_title => 'Sitzung erzwingen';

  @override
  String get focus_enforce_tile_subtitle =>
      'Verhindert das vorzeitige Beenden einer Sitzung.';

  @override
  String get focus_session_start_button => 'Zum Starten der Sitzung streichen';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Wählen Sie mindestens eine ablenkende App aus, um die Fokussitzung zu starten';

  @override
  String get focus_session_already_active_snack_alert =>
      'Sie haben bereits eine aktive Fokussitzung im Gange. Bitte schließen Sie Ihre aktuelle Sitzung ab oder beenden Sie sie, bevor Sie eine neue beginnen.';

  @override
  String get focus_session_type_study => 'Studieren';

  @override
  String get focus_session_type_work => 'Arbeit';

  @override
  String get focus_session_type_exercise => 'Übung';

  @override
  String get focus_session_type_meditation => 'Meditation';

  @override
  String get focus_session_type_creativeWriting => 'Kreatives Schreiben';

  @override
  String get focus_session_type_reading => 'Lesen';

  @override
  String get focus_session_type_programming => 'Programmierung';

  @override
  String get focus_session_type_chores => 'Aufgaben';

  @override
  String get focus_session_type_projectPlanning => 'Projektplanung';

  @override
  String get focus_session_type_artAndDesign => 'Kunst und Design';

  @override
  String get focus_session_type_languageLearning => 'Sprachenlernen';

  @override
  String get focus_session_type_musicPractice => 'Musikpraxis';

  @override
  String get focus_session_type_selfCare => 'Selbstfürsorge';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Kompetenzentwicklung';

  @override
  String get focus_session_type_research => 'Forschung';

  @override
  String get focus_session_type_networking => 'Vernetzung';

  @override
  String get focus_session_type_cooking => 'Kochen';

  @override
  String get focus_session_type_sportsTraining => 'Sporttraining';

  @override
  String get focus_session_type_restAndRelaxation => 'Ruhe und Entspannung';

  @override
  String get focus_session_type_other => 'Andere';

  @override
  String get timeline_tab_title => 'Zeitleiste';

  @override
  String get focus_timeline_tab_info =>
      'Entdecken Sie Ihre Fokusreise, indem Sie ein Datum aus dem Kalender auswählen. Verfolgen Sie Ihre Fortschritte, überdenken Sie Ihre Erfolge und lernen Sie aus den Herausforderungen.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Ihre gesamte produktive Zeit für den ausgewählten Monat beträgt $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktive Tage';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Sie hatten im ausgewählten Monat insgesamt $daysCount produktive Tage.';
  }

  @override
  String get selected_day_focused_time_label => 'Konzentrierte Zeit';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Ihre gesamte konzentrierte Zeit für den ausgewählten Tag beträgt $timeString.';
  }

  @override
  String get calender_heading => 'Kalender';

  @override
  String get your_sessions_heading => 'Ihre Sitzungen';

  @override
  String get your_sessions_empty_list_hint =>
      'Für den ausgewählten Tag wurden keine Fokussitzungen aufgezeichnet.';

  @override
  String get focus_session_tile_timestamp_label => 'Zeitstempel';

  @override
  String get focus_session_tile_duration_label => 'Dauer';

  @override
  String get focus_session_tile_reflection_label => 'Reflexion';

  @override
  String get focus_session_state_active => 'Aktiv';

  @override
  String get focus_session_state_successful => 'Erfolgreich';

  @override
  String get focus_session_state_failed => 'Fehlgeschlagen';

  @override
  String get active_session_tab_title => 'Sitzung';

  @override
  String get active_session_none_warning =>
      'Keine aktive Sitzung gefunden. Rückkehr zum Startbildschirm.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Drücken Sie weiter';

  @override
  String get active_session_finish_dialog_title => 'Fertig';

  @override
  String get active_session_finish_dialog_info =>
      'Bleib stark! Sie bauen einen wertvollen Fokus auf. Sind Sie sicher, dass Sie diese Fokussitzung beenden möchten? Jeder zusätzliche Moment zählt für Ihre Ziele.';

  @override
  String get active_session_giveup_dialog_title => 'Gib auf';

  @override
  String get active_session_giveup_dialog_info =>
      'Warte! Du hast es fast geschafft, gib jetzt nicht auf! Sind Sie sicher, dass Sie diese Fokussitzung vorzeitig beenden möchten? Der Fortschritt geht verloren.';

  @override
  String get active_session_reflection_dialog_title => 'Sitzungsreflexion';

  @override
  String get active_session_reflection_dialog_info =>
      'Nehmen Sie sich einen Moment Zeit, um über Ihre Fortschritte nachzudenken. Was ist Ihr Ziel für diese Sitzung? Was haben Sie in dieser Sitzung erreicht?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tipp: Sie können dies später jederzeit in der Sitzungszeitleiste bearbeiten.';

  @override
  String get active_session_giveup_snack_alert =>
      'Du hast aufgegeben! Machen Sie sich keine Sorgen, beim nächsten Mal können Sie es besser machen. Jede Anstrengung zählt – machen Sie einfach weiter';

  @override
  String get active_session_quote_one =>
      'Jeder Schritt zählt, bleib stark und mach weiter';

  @override
  String get active_session_quote_two =>
      'Bleiben Sie konzentriert! Du machst erstaunliche Fortschritte';

  @override
  String get active_session_quote_three =>
      'Du machst es kaputt! Halten Sie den Schwung aufrecht';

  @override
  String get active_session_quote_four =>
      'Nur noch ein bisschen, du machst das großartig';

  @override
  String active_session_quote_five(String durationString) {
    return 'Herzlichen Glückwunsch 🎉 \n Sie haben Ihre Fokussitzung von $durationString abgeschlossen.\n\nGroßartige Arbeit, machen Sie weiter so';
  }

  @override
  String get restriction_groups_tab_title => 'Einschränkungsgruppen';

  @override
  String get restriction_groups_tab_info =>
      'Legen Sie ein kombiniertes Bildschirmzeitlimit für eine Gruppe von Apps fest. Sobald die Gesamtnutzung Ihr Limit erreicht, werden alle Apps in der Gruppe angehalten, um die Konzentration und das Gleichgewicht aufrechtzuerhalten.';

  @override
  String get restriction_group_time_spent_label => 'Heute verbrachte Zeit';

  @override
  String get restriction_group_time_left_label => 'Heute ist noch Zeit übrig';

  @override
  String get restriction_group_name_tile_title => 'Gruppenname';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Geben Sie einen Namen für die Einschränkungsgruppe ein, um sie leichter identifizieren und verwalten zu können.';

  @override
  String get restriction_group_timer_tile_title => 'Gruppentimer';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Legen Sie ein tägliches Zeitlimit für diese Gruppe fest. Sobald Ihr Limit erreicht ist, werden alle Apps in dieser Gruppe bis Mitternacht pausiert.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Gruppenaktiver Zeitraum';

  @override
  String get remove_restriction_group_dialog_title => 'Gruppe entfernen';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Bist du sicher? Sie möchten „$groupName“ aus Einschränkungsgruppen entfernen.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Legen Sie entweder einen Timer oder ein aktives Zeitlimit fest.';

  @override
  String get notifications_empty_list_hint =>
      'Für diesen Tag wurden keine Benachrichtigungen gebündelt.';

  @override
  String get conversations_label => 'Gespräche';

  @override
  String get last_24_hours_heading => 'Letzte 24 Stunden';

  @override
  String get notification_timeline_tab_info =>
      'Durchsuchen Sie Ihren Benachrichtigungsverlauf, indem Sie ein Datum aus dem Kalender auswählen. Sehen Sie, welche Apps Ihre Aufmerksamkeit erregt haben, und denken Sie über Ihre digitalen Gewohnheiten nach.';

  @override
  String get monthly_label => 'Monatlich';

  @override
  String get daily_label => 'Täglich';

  @override
  String get search_notifications_sheet_info =>
      'Finden Sie frühere Benachrichtigungen ganz einfach, indem Sie deren Titel oder Inhalt durchsuchen. Hilft Ihnen, wichtige Warnungen schnell zu finden.';

  @override
  String get search_notifications_hint => 'Suchbenachrichtigungen...';

  @override
  String get search_notifications_empty_list_hint =>
      'Es wurden keine Benachrichtigungen gefunden, die Ihrer Suche entsprechen.';

  @override
  String get app_info_none_warning =>
      'Die App für das angegebene Paket konnte nicht gefunden werden. Rückkehr zum Startbildschirm.';

  @override
  String get emergency_fab_button => 'Notfall';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Durch diese Aktion wird der App-Blocker für die nächsten 5 Minuten angehalten. Sie haben noch $leftPassesCount Pässe übrig. Nachdem alle Pässe verwendet wurden, bleibt die App bis Mitternacht gesperrt oder die aktive Fokussitzung endet.\n\nMöchten Sie trotzdem fortfahren?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Trotzdem verwenden';

  @override
  String get emergency_started_snack_alert =>
      'Der App-Blocker wird angehalten und setzt die Blockierung in 5 Minuten fort.';

  @override
  String get emergency_already_active_snack_alert =>
      'Der App-Blocker ist derzeit entweder pausiert oder inaktiv. Wenn Benachrichtigungen aktiviert sind, erhalten Sie Updates zur verbleibenden Zeit.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Sie haben alle Ihre Notfallausweise verwendet. Die blockierten Apps bleiben bis Mitternacht blockiert oder die aktive Fokussitzung endet.';

  @override
  String get app_limit_status_not_set => 'Nicht festgelegt';

  @override
  String get app_timer_tile_title => 'App-Timer';

  @override
  String get app_timer_picker_dialog_info =>
      'Legen Sie ein tägliches Zeitlimit für diese App fest. Sobald Ihr Limit erreicht ist, wird die App bis Mitternacht pausiert.';

  @override
  String get usage_reminders_tile_title => 'Nutzungserinnerungen';

  @override
  String get usage_reminders_tile_subtitle =>
      'Sanfte Anstöße bei der Verwendung zeitgesteuerter Apps.';

  @override
  String get app_launch_limit_tile_title => 'Startlimit';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Heute mal $count gestartet.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Legen Sie fest, wie oft Sie diese App täglich öffnen können. Sobald das Limit erreicht ist, wird es bis Mitternacht pausiert.';

  @override
  String get app_active_period_tile_title => 'Aktiver Zeitraum';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Von $startTime bis $endTime';
  }

  @override
  String get internet_access_tile_title => 'Internetzugang';

  @override
  String get internet_access_tile_subtitle =>
      'Ausschalten, um das Internet der App zu blockieren.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Das Internet von $appName ist blockiert.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Das Internet von $appName ist entsperrt.';
  }

  @override
  String get launch_app_tile_title => 'App starten';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Öffnen Sie $appName.';
  }

  @override
  String get go_to_app_settings_tile_title =>
      'Gehen Sie zu den App-Einstellungen';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Verwalten Sie App-Einstellungen wie Benachrichtigungen, Berechtigungen, Speicher und mehr.';

  @override
  String get include_in_stats_tile_title =>
      'In die Bildschirmnutzung einbeziehen';

  @override
  String get include_in_stats_tile_subtitle =>
      'Schalten Sie diese Option aus, um diese App von der gesamten Bildschirmnutzung auszuschließen.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName ist von der gesamten Bildschirmnutzung ausgeschlossen.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName ist in der gesamten Bildschirmnutzung enthalten.';
  }

  @override
  String get general_tab_title => 'Allgemein';

  @override
  String get appearance_heading => 'Aussehen';

  @override
  String get theme_mode_tile_title => 'Themenmodus';

  @override
  String get theme_mode_system_label => 'System';

  @override
  String get theme_mode_light_label => 'Licht';

  @override
  String get theme_mode_dark_label => 'Dunkel';

  @override
  String get material_color_tile_title => 'Materialfarbe';

  @override
  String get amoled_dark_tile_title => 'AMOLED dunkel';

  @override
  String get amoled_dark_tile_subtitle =>
      'Verwenden Sie für das dunkle Thema reines Schwarz.';

  @override
  String get dynamic_colors_tile_title => 'Dynamische Farben';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Verwenden Sie Gerätefarben, sofern unterstützt.';

  @override
  String get defaults_heading => 'Standardeinstellungen';

  @override
  String get app_language_tile_title => 'App-Sprache';

  @override
  String get default_home_tab_tile_title => 'Registerkarte „Startseite“.';

  @override
  String get usage_history_tile_title => 'Nutzungshistorie';

  @override
  String get usage_history_15_days => '15 Tage';

  @override
  String get usage_history_1_month => '1 Monat';

  @override
  String get usage_history_3_month => '3 Monate';

  @override
  String get usage_history_6_month => '6 Monate';

  @override
  String get usage_history_1_year => '1 Jahr';

  @override
  String get service_heading => 'Service';

  @override
  String get service_stopping_warning =>
      'Wenn NLP digitox unerwartet nicht mehr funktioniert, erteilen Sie bitte die Berechtigung „Batterieoptimierung ignorieren“, damit es im Hintergrund weiterläuft. Wenn das Problem weiterhin besteht, versuchen Sie, NLP digitox auf die Whitelist zu setzen, um eine unterbrechungsfreie Leistung zu gewährleisten.';

  @override
  String get whitelist_app_tile_title => 'Whitelist NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Lassen Sie NLP digitox automatisch starten.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Dieses Gerät unterstützt keine automatische Startverwaltung.';

  @override
  String get database_tab_title => 'Datenbank';

  @override
  String get import_db_tile_title => 'Datenbank importieren';

  @override
  String get import_db_tile_subtitle =>
      'Datenbank aus einer Datei importieren.';

  @override
  String get export_db_tile_title => 'Datenbank exportieren';

  @override
  String get export_db_tile_subtitle => 'Datenbank in eine Datei exportieren.';

  @override
  String get analysis_tab_title => 'Analyse';

  @override
  String get analysis_7_days => '7 Tage';

  @override
  String get analysis_30_days => '30 Tage';

  @override
  String get analysis_90_days => '90 Tage';

  @override
  String get analysis_screen_time_trend => 'Bildschirmzeit-Trend';

  @override
  String get analysis_no_data_info =>
      'Für diesen Zeitraum wurden noch keine Bildschirmzeitdaten erfasst.';

  @override
  String get analysis_daily_average => 'Tagesdurchschnitt';

  @override
  String get analysis_total => 'Gesamt';

  @override
  String get analysis_no_change => 'Gleich wie letzte Woche';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% weniger als letzte Woche';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% mehr als letzte Woche';
  }

  @override
  String get crash_logs_heading => 'Absturzprotokolle';

  @override
  String get crash_logs_info =>
      'Wenn Sie auf ein Problem stoßen, können Sie es zusammen mit der Protokolldatei auf GitHub melden. Die Datei enthält Details wie Hersteller, Modell, Android-Version, SDK-Version und Absturzprotokolle Ihres Geräts. Diese Informationen helfen uns, das Problem effektiver zu identifizieren und zu lösen.';

  @override
  String get crash_logs_export_tile_title => 'Absturzprotokolle exportieren';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Absturzprotokolle in eine JSON-Datei exportieren.';

  @override
  String get crash_logs_view_tile_title => 'Protokolle anzeigen';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Durchsuchen Sie gespeicherte Absturzprotokolle.';

  @override
  String get crash_logs_empty_list_hint =>
      'Bisher wurde kein Absturz protokolliert.';

  @override
  String get crash_logs_clear_tile_title => 'Protokolle löschen';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Löschen Sie alle Absturzprotokolle aus der Datenbank.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Sind Sie sicher, dass Sie alle Absturzprotokolle aus der Datenbank löschen möchten?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Klar jedenfalls';

  @override
  String get about_tab_title => 'Über';

  @override
  String get changelog_tile_title => 'Änderungsprotokoll';

  @override
  String get changelog_tile_subtitle => 'Erfahren Sie, was es Neues gibt.';

  @override
  String get full_changelog_tile_title => 'Vollständiges Änderungsprotokoll';

  @override
  String get redirected_to_github_subtitle =>
      'Sie werden zu GitHub weitergeleitet.';

  @override
  String get contribute_heading => 'Mitmachen';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Sehen Sie sich den Quellcode an.';

  @override
  String get report_issue_tile_title => 'Melden Sie ein Problem';

  @override
  String get suggest_idea_tile_title => 'Schlagen Sie eine Idee vor';

  @override
  String get write_email_tile_title => 'Schreiben Sie uns per E-Mail';

  @override
  String get write_email_tile_subtitle =>
      'Sie werden zur E-Mail-App weitergeleitet.';

  @override
  String get privacy_policy_heading => 'Datenschutzrichtlinie';

  @override
  String get privacy_policy_info =>
      'NLP digitox verpflichtet sich, Ihre Privatsphäre zu schützen. Wir erheben, speichern oder übermitteln keinerlei Benutzerdaten. Die App funktioniert vollständig offline und erfordert keine Internetverbindung, sodass Ihre persönlichen Daten auf Ihrem Gerät privat und sicher bleiben. Als Free and Open Source Software (FOSS)-Anwendung garantiert NLP digitox vollständige Transparenz und Benutzerkontrolle über ihre Daten.';

  @override
  String get more_details_button => 'Weitere Details';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
