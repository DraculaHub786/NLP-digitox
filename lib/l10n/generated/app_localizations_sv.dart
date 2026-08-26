// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get mindful_tagline => 'Fokusera på det som verkligen betyder något';

  @override
  String get unlock_button_label => 'Lås upp';

  @override
  String get permission_status_off => 'Av';

  @override
  String get permission_status_allowed => 'Tillåtet';

  @override
  String get permission_status_not_allowed => 'Inte tillåtet';

  @override
  String get permission_button_grant_permission => 'Ge tillstånd';

  @override
  String get permission_button_agree_and_continue => 'Håll med & fortsätt';

  @override
  String get permission_button_not_now => 'Inte nu';

  @override
  String get permission_button_help => 'Hjälp?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox är 100 % säker och fungerar offline. Vi samlar inte in eller lagrar några personuppgifter.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Klicka på knappen $button_label.';
  }

  @override
  String get permission_grant_step_two => '2. Välj NLP digitox på nästa skärm.';

  @override
  String get permission_grant_step_three =>
      '3. Klicka och slå på strömbrytaren enligt nedan.';

  @override
  String get permission_notification_title => 'Skicka meddelanden';

  @override
  String get permission_alarms_title => 'Larm och påminnelser';

  @override
  String get permission_alarms_info =>
      'Vänligen ge tillstånd för att ställa in larm och påminnelser. Detta gör att NLP digitox kan starta ditt läggdagsschema i tid och återställa apptimers dagligen vid midnatt och hjälpa dig att hålla dig på rätt spår.';

  @override
  String get permission_alarms_device_tile_label =>
      'Tillåt inställning av larm och påminnelser';

  @override
  String get permission_usage_title => 'Användningsåtkomst';

  @override
  String get permission_usage_info =>
      'Vänligen ge åtkomstbehörighet för användning. Detta gör att NLP digitox kan övervaka appanvändning och hantera åtkomst till vissa appar, vilket säkerställer en mer fokuserad och kontrollerad digital miljö.';

  @override
  String get permission_usage_device_tile_label => 'Tillåt användningsåtkomst';

  @override
  String get permission_overlay_title => 'Visa överlägg';

  @override
  String get permission_overlay_info =>
      'Vänligen ge visningsöverlagringsbehörighet. Detta gör att NLP digitox kan visa en överlagring när en pausad app öppnas, vilket hjälper dig att hålla fokus och behålla ditt schema.';

  @override
  String get permission_overlay_device_tile_label =>
      'Tillåt visning över andra appar';

  @override
  String get permission_accessibility_title => 'Tillgänglighet';

  @override
  String get permission_accessibility_info =>
      'Vänligen ge tillgänglighetstillstånd. Detta kommer att tillåta NLP digitox att begränsa åtkomsten till kortformat videoinnehåll (t.ex. Reels, Shorts) i appar och webbläsare för sociala medier och filtrera olämpliga webbplatser.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox kräver tillgänglighetstillstånd för att blockera kort innehåll och webbplatser effektivt.';

  @override
  String get permission_accessibility_device_tile_label => 'Använd NLP digitox';

  @override
  String get permission_dnd_title => 'Stör inte';

  @override
  String get permission_dnd_info =>
      'Vänligen ge Stör ej åtkomst. Detta gör att NLP digitox kan starta och stoppa Stör ej-läget under läggdagsschemat.';

  @override
  String get permission_dnd_tile_title => 'Starta DND';

  @override
  String get permission_dnd_tile_subtitle => 'Aktivera även Stör ej-läget.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ignorera batterioptimering';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Redan obegränsad';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Inaktivera bakgrundsbegränsning';

  @override
  String get permission_battery_optimization_allow_info =>
      'Om du tillåter \"Ignorera batterioptimering\" beviljas automatiskt behörigheten \"Larm och påminnelser\" på vissa enheter.';

  @override
  String get permission_vpn_title => 'Skapa VPN';

  @override
  String get permission_vpn_info =>
      'Vänligen ge tillstånd att skapa en anslutning till ett virtuellt privat nätverk (VPN). Detta gör det möjligt för NLP digitox att begränsa internetåtkomst för angivna applikationer genom att skapa lokal VPN på enheten.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Administrativa behörigheter behövs endast för väsentliga åtgärder för att säkerställa att appen fungerar korrekt och förblir manipuleringssäker.';

  @override
  String get permission_admin_snack_alert =>
      'Sabotageskydd kan endast inaktiveras under det valda tidsfönstret.';

  @override
  String get permission_notification_access_title => 'Aviseringsåtkomst';

  @override
  String get permission_notification_access_info =>
      'Vänligen ge åtkomstbehörighet för meddelanden. Detta gör att NLP digitox kan organisera dina aviseringar och leverera dem enligt ditt schema.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox kräver aviseringsåtkomst till batch- och schemameddelanden.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Tillåt åtkomst till aviseringar';

  @override
  String get day_today => 'Idag';

  @override
  String get day_yesterday => 'Igår';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dagar',
      one: '1 dag',
      zero: '0 dagar',
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
      other: '$countString timmar',
      one: '1 timme',
      zero: '0 timmar',
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
      other: '$countString minuter',
      one: '1 minut',
      zero: '0 minuter',
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
  String get time_separator_and => 'och';

  @override
  String get timer_status_active => 'Aktiv';

  @override
  String get timer_status_paused => 'Pausad';

  @override
  String get create_button => 'Skapa';

  @override
  String get update_button => 'Uppdatering';

  @override
  String get dialog_button_cancel => 'Avbryt';

  @override
  String get dialog_button_remove => 'Ta bort';

  @override
  String get dialog_button_set => 'Ställ in';

  @override
  String get dialog_button_reset => 'Återställ';

  @override
  String get dialog_button_infinite => 'Oändligt';

  @override
  String get schedule_start_label => 'Starta';

  @override
  String get schedule_end_label => 'Slut';

  @override
  String get exit_without_saving_dialog_info =>
      'Är du säker på att du vill avsluta utan att spara?';

  @override
  String get development_dialog_info =>
      'NLP digitox är för närvarande under utveckling och kan ha buggar eller ofullständiga funktioner. Om du stöter på några problem, vänligen rapportera dem för att hjälpa oss att förbättra.\n\nTack för din feedback!';

  @override
  String get development_dialog_button_report_issue => 'Rapportera problem';

  @override
  String get development_dialog_button_close => 'Stäng';

  @override
  String get dnd_settings_tile_title => 'Stör ej inställningar';

  @override
  String get dnd_settings_tile_subtitle =>
      'Hantera vilka appar och aviseringar som kan nå dig i DND.';

  @override
  String get quick_actions_heading => 'Snabba åtgärder';

  @override
  String get select_distracting_apps_heading => 'Välj distraherande appar';

  @override
  String get your_distracting_apps_heading => 'Dina distraherande appar';

  @override
  String get select_more_apps_heading => 'Välj fler appar';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Det är inte tillåtet att lägga till viktiga systemappar i listan över distraherande appar.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Skärmanvändning och begränsningar är inte tillgängliga för denna applikation. För närvarande är endast nätverksanvändning tillgänglig';

  @override
  String get create_group_fab_button => 'Skapa grupp';

  @override
  String get active_period_info =>
      'Ställ in en tidsperiod under vilken åtkomst tillåts. Utanför denna tidsram kommer åtkomsten att vara begränsad.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Välj minst en distraherande app.';

  @override
  String get donation_card_title => 'Stöd oss';

  @override
  String get donation_card_info =>
      'NLP digitox är gratis och öppen källkod, utvecklad med månader av engagemang. Om det har hjälpt dig skulle din donation betyda världen för oss. Varje bidrag hjälper oss att fortsätta att förbättra och underhålla det för alla.';

  @override
  String get operation_failed_snack_alert =>
      'Operation misslyckades, något gick fel!';

  @override
  String get donation_card_button_donate => 'Donera';

  @override
  String get app_restart_dialog_title => 'Behöver omstart';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox startar om automatiskt när nedräkningen är klar. Vänligen ha tålamod eftersom ändringar tillämpas.';

  @override
  String get accessibility_tip =>
      'Vill du ha smartare, mer batterivänlig blockering? Aktivera tillgänglighetsbehörighet för NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox fungerar inte? Tillåt \"Ignorera batterioptimering\" i Inställningar för att det ska fungera smidigt.';

  @override
  String get invincible_mode_tip =>
      'Av misstag tagit bort restriktioner? Använd Invincible Mode för att låsa dem till nästa dag eller justeringsfönster.';

  @override
  String get glance_usage_tip =>
      'Vill du ha insikter? Kolla avsnittet Glance för att se dina användningsmönster och skärmtid.';

  @override
  String get tamper_protection_tip =>
      'Avinstallera NLP digitox? Aktivera avinstallationsfönstret för att säkert inaktivera manipuleringsskyddet först.';

  @override
  String get notification_blocking_tip =>
      'Vill du minska distraktioner? Använd aviseringsblockering för att tysta valda appar.';

  @override
  String get usage_history_tip =>
      'Vill du reflektera över dina vanor? Kontrollera Användningshistorik för att se tidigare mönster.';

  @override
  String get focus_mode_tip =>
      'Behöver du djup fokus? Aktivera fokusläge för att blockera appar och aviseringar under uppgifter.';

  @override
  String get bedtime_reminder_tip =>
      'Vill du förbättra din sömn? Ställ in en läggdagspåminnelse för att varva ner varje kväll.';

  @override
  String get custom_blocking_tip =>
      'Behöver du en anpassad upplevelse? Skapa appblockeringsregler som passar dina behov.';

  @override
  String get session_timeline_tip =>
      'Vill du spåra fokussessioner? Se tidslinjen för att se din fokusresa.';

  @override
  String get short_content_blocking_tip =>
      'Distraherad av sociala appar? Blockera kort innehåll på Instagram, YouTube, etc. för att hålla fokus.';

  @override
  String get parental_controls_tip =>
      'Behöver du föräldrakontroll? Ställ in begränsningar för ditt barns enhet för att säkerställa en säker upplevelse.';

  @override
  String get notification_batching_tip =>
      'Vill du minska distraktioner? Använd Notification Batching för att gruppera aviseringar och kontrollera dem på en gång.';

  @override
  String get notification_scheduling_tip =>
      'Behöver du hantera aviseringar? Schemalägg när du får aviseringar för specifika appar.';

  @override
  String get quick_focus_tile_tip =>
      'Behöver du snabb tillgång till fokus? Lägg till en snabbfokusruta för att omedelbart aktivera fokusläget.';

  @override
  String get app_shortcuts_tip =>
      'Vill du ha åtkomst till appar direkt? Lägg till genvägar genom att trycka länge på appikonen för snabba åtgärder.';

  @override
  String get backup_usage_db_tip =>
      'Vill du spara din data? Säkerhetskopiera din användningsdatabasen för att hålla dina register säkra.';

  @override
  String get dynamic_material_color_tip =>
      'Vill du ha ett anpassat tema? Aktivera dynamiskt material Du färgar för att matcha enhetens tema.';

  @override
  String get amoled_dark_theme_tip =>
      'Vill du spara batteri? Använd AMOLED Dark Theme för att minska strömförbrukningen på OLED-skärmar.';

  @override
  String get customize_usage_history_tip =>
      'Vill du behålla användningshistoriken? Anpassa hur många veckors data som ska lagras i Användningshistorik.';

  @override
  String get grouped_apps_blocking_tip =>
      'Vill du blockera appar tillsammans? Använd begränsningsgrupper för att gruppera appgränser och blockera flera appar samtidigt.';

  @override
  String get websites_blocking_tip =>
      'Vill du ha en renare webbupplevelse? Blockera anpassade eller NSFW-webbplatser för en mer fokuserad onlinetid.';

  @override
  String get data_usage_tip =>
      'Vill du spåra din data? Övervaka din mobil- och Wi-Fi-dataanvändning för internetkonsumtion.';

  @override
  String get block_internet_tip =>
      'Behöver du blockera en apps internet? Stäng av internet för specifik app från appens instrumentpanel.';

  @override
  String get emergency_passes_tip =>
      'Behöver du en paus? Använd 3 nödpass dagligen för att tillfälligt avblockera appar i 5 minuter.';

  @override
  String get onboarding_skip_btn_label => 'Hoppa över';

  @override
  String get onboarding_finish_setup_btn_label => 'Slutför installationen';

  @override
  String get onboarding_page_welcome_title => 'Välkommen till NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Ta kontroll över ditt digitala liv och bygg hälsosammare skärmvanor. NLP digitox hjälper dig att hålla fokus, minska distraktioner och fatta medvetna val varje dag.';

  @override
  String get onboarding_page_statistics_title => 'Känn dina vanor.';

  @override
  String get onboarding_page_statistics_info =>
      'Förstå dina digitala mönster med detaljerade insikter om skärmtid, appanvändning och fokustrender. Följ dina framsteg och se hur små förändringar leder till stora förbättringar.';

  @override
  String get onboarding_page_one_title => 'Mästarfokus.';

  @override
  String get onboarding_page_one_info =>
      'Pausa distraherande appar, blockera kort innehåll och håll dig på rätt spår med anpassningsbara fokussessioner. Oavsett om du arbetar, studerar eller kopplar av, hjälper NLP digitox dig att behålla kontrollen.';

  @override
  String get onboarding_page_two_title => 'Blockera distraktioner.';

  @override
  String get onboarding_page_two_info =>
      'Ställ in användningsgränser, pausa appar automatiskt och skapa hälsosammare digitala vanor. Använd läggdagsläge för att varva ner och njuta av en natt utan distraktion.';

  @override
  String get onboarding_page_three_title => 'Sekretess först.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox är 100 % öppen källkod och fungerar helt offline. Vi samlar inte in eller delar dina personuppgifter – din integritet garanteras på alla sätt.';

  @override
  String get onboarding_page_permissions_title => 'Viktiga behörigheter.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox kräver följande viktiga behörigheter för att spåra och hantera din skärmtid, vilket hjälper till att minska distraktioner och förbättra fokus.';

  @override
  String get dashboard_tab_title => 'Instrumentbräda';

  @override
  String get focus_now_fab_button => 'Fokusera nu';

  @override
  String get welcome_greetings => 'Välkommen tillbaka,';

  @override
  String get username_snack_alert =>
      'Tryck länge för att redigera användarnamn.';

  @override
  String get username_dialog_title => 'Användarnamn';

  @override
  String get username_dialog_info =>
      'Ange ditt användarnamn som kommer att visas på instrumentpanelen.';

  @override
  String get username_dialog_button_apply => 'Ansök';

  @override
  String get glance_tile_title => 'Blicka';

  @override
  String get glance_tile_subtitle => 'Ta en snabb blick på din användning.';

  @override
  String get parental_controls_tile_subtitle =>
      'Oövervinnerligt läge och manipuleringsskydd.';

  @override
  String get restrictions_heading => 'Restriktioner';

  @override
  String get apps_blocking_tile_title => 'Appar blockerar';

  @override
  String get apps_blocking_tile_subtitle => 'Begränsa appar på flera sätt.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Blockering av grupperade appar';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Begränsa grupp av appar samtidigt.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Begränsa kort innehåll på flera plattformar.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Begränsa vuxna och anpassade webbplatser.';

  @override
  String get screen_time_label => 'Skärmtid';

  @override
  String get total_data_label => 'Totala data';

  @override
  String get mobile_data_label => 'Mobildata';

  @override
  String get wifi_data_label => 'Wifi-data';

  @override
  String get focus_today_label => 'Fokus idag';

  @override
  String get focus_weekly_label => 'Fokusera varje vecka';

  @override
  String get focus_monthly_label => 'Fokus varje månad';

  @override
  String get focus_lifetime_label => 'Fokus livstid';

  @override
  String get longest_streak_label => 'Längsta rad';

  @override
  String get current_streak_label => 'Nuvarande rad';

  @override
  String get successful_sessions_label => 'Framgångsrika sessioner';

  @override
  String get failed_sessions_label => 'Misslyckade sessioner';

  @override
  String get statistics_tab_title => 'Statistik';

  @override
  String get screen_segment_label => 'Skärm';

  @override
  String get data_segment_label => 'Data';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Mest använda appar';

  @override
  String get show_all_apps_tile_title => 'Visa alla appar';

  @override
  String get search_apps_hint => 'Sök appar...';

  @override
  String get notifications_tab_title => 'Aviseringar';

  @override
  String get notifications_tab_info =>
      'Gruppaviseringar från appar och ställ in scheman som morgon, middag, kväll och kväll. Håll dig uppdaterad utan ständiga avbrott.';

  @override
  String get batched_apps_tile_title => 'Batchade appar';

  @override
  String get batch_recap_dropdown_title => 'Batch-recap typ';

  @override
  String get batch_recap_dropdown_info =>
      'Välj vad som ska skickas när ett schema utlöses – alla aviseringar eller bara en sammanfattning.';

  @override
  String get batch_recap_option_summery_only => 'Endast sammanfattning';

  @override
  String get batch_recap_option_all_notifications => 'Alla aviseringar';

  @override
  String get notification_history_tile_title => 'Aviseringshistorik';

  @override
  String get store_all_tile_title => 'Lagra alla aviseringar';

  @override
  String get store_all_tile_subtitle =>
      'Spara icke-batchade meddelanden också.';

  @override
  String get schedules_heading => 'Scheman';

  @override
  String get new_schedule_fab_button => 'Nytt schema';

  @override
  String get new_schedule_dialog_info =>
      'Ange ett namn för aviseringsschemat för att lättare kunna identifiera det.';

  @override
  String get new_schedule_dialog_field_label => 'Schemanamn';

  @override
  String get bedtime_tab_title => 'Sovdags';

  @override
  String get bedtime_tab_info =>
      'Ställ in ditt läggdagsschema genom att välja en tidsperiod och veckodagar. Välj distraherande appar för att blockera och aktivera läget Stör ej (DND) för en lugn natt.';

  @override
  String get schedule_tile_title => 'Schema';

  @override
  String get schedule_tile_subtitle =>
      'Aktivera eller inaktivera dagligt schema.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Välj minst en dag i veckan.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Den totala läggdagstiden måste vara minst 30 minuter.';

  @override
  String get distracting_apps_tile_title => 'Distraherande appar';

  @override
  String get distracting_apps_tile_subtitle =>
      'Välj vilka appar som distraherar dig från din läggdagsrutin.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Ändringar av listan över distraherande appar är inte tillåtna medan läggdagsschemat är aktivt.';

  @override
  String get parental_controls_tab_title => 'Föräldrakontroll';

  @override
  String get invincible_mode_heading => 'Oövervinnerligt läge';

  @override
  String get invincible_mode_tile_title => 'Aktivera oövervinnerligt läge';

  @override
  String get invincible_mode_info =>
      'När Invincible Mode är på kommer du inte att kunna justera valda gränser efter att du har nått din dagliga kvot. Du kan dock göra ändringar inom ett valt 10-minuters oövervinnerligt fönster.';

  @override
  String get invincible_mode_snack_alert =>
      'På grund av oövervinnerligt läge är ändringar av restriktioner inte tillåtna.';

  @override
  String get invincible_mode_dialog_info =>
      'Är du helt säker på att du vill aktivera Invincible Mode? Denna åtgärd är oåterkallelig. När Invincible Mode är aktiverat kan du inte stänga av det så länge den här appen är installerad på din enhet.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Mode kan inte stängas av så länge den här appen förblir installerad på din enhet.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Börja ändå';

  @override
  String get invincible_mode_include_timer_tile_title => 'Inkludera timer';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Inkludera lanseringsgräns';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Inkludera aktiv period';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'Appbegränsningar';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Förhindra ändringar av appens valda begränsningar när de dagliga gränserna överskrids.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Grupprestriktioner';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Förhindra ändringar av gruppens valda begränsningar när de dagliga gränserna överskrids.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Inkludera shorts timer';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Förhindrar förändringar efter att du har nått din dagliga shorts-gräns.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Inkludera läggdags';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Förhindrar ändringar under det aktiva läggdagsschemat.';

  @override
  String get protected_access_tile_title => 'Skyddad åtkomst';

  @override
  String get protected_access_tile_subtitle =>
      'Skydda NLP digitox med ditt enhetslås.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Vänligen ställ in ett biometriskt lås på din enhet först för att aktivera den här funktionen.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Ditt enhetslås har tagits bort. För att fortsätta, ställ in ett nytt lås.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Autentiseringen misslyckades. Du måste verifiera ditt enhetslås för att fortsätta.';

  @override
  String get tamper_protection_tile_title => 'Sabotageskydd';

  @override
  String get tamper_protection_tile_subtitle =>
      'Förhindra avinstallation och tvinga fram stopp av appen.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'När det är aktiverat kommer du inte att kunna avinstallera, tvinga fram stopp eller rensa NLP digitoxs data, förutom under det valda avinstallationsfönstret. Det finns inga lösningar.\n\nFortsätt på egen risk.';

  @override
  String get uninstall_window_tile_title => 'Avinstallera fönstret';

  @override
  String get uninstall_window_tile_subtitle =>
      'Sabotageskydd kan inaktiveras inom 10 minuter från den valda tiden.';

  @override
  String get invincible_window_tile_title => 'Oövervinnerligt fönster';

  @override
  String get invincible_window_tile_subtitle =>
      'Valda gränser kan ändras inom 10 minuter från den valda tiden.';

  @override
  String get shorts_blocking_tab_title => 'Shorts som blockerar';

  @override
  String get shorts_blocking_tab_info =>
      'Kontrollera hur mycket tid du lägger på kort innehåll på plattformar som Instagram, YouTube, Snapchat och Facebook, inklusive deras webbplatser.';

  @override
  String get short_content_heading => 'Kort innehåll';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Vänster från $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Ställ in en daglig tidsgräns för kort innehåll. När din gräns har nåtts pausas det korta innehållet till midnatt.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Begränsa funktioner på instagram.';

  @override
  String get instagram_features_block_reels => 'Begränsa rullarna.';

  @override
  String get instagram_features_block_explore => 'Begränsa utforskandet.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Begränsa funktioner på snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Begränsa strålkastarsektionen.';

  @override
  String get snapchat_features_block_discover => 'Begränsa upptäckssektionen.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Begränsa kortfilmer på youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Begränsa rullar på facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Begränsa shorts på reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Begränsa videoflödet på X.';

  @override
  String get threads_features_tile_title => 'Trådar';

  @override
  String get threads_features_tile_subtitle =>
      'Begränsa video/rullar på trådar.';

  @override
  String get websites_blocking_tab_title => 'Webbplatser blockerar';

  @override
  String get websites_blocking_tab_info =>
      'Blockera webbplatser för vuxna och alla anpassade webbplatser du väljer för att skapa en säkrare och mer fokuserad onlineupplevelse. Ta hand om din surfning och förbli distraktionsfri.';

  @override
  String get adult_content_heading => 'Vuxet innehåll';

  @override
  String get block_nsfw_title => 'Blockera Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Begränsa webbläsare från att öppna vuxen- och porrwebbplatser.';

  @override
  String get block_nsfw_dialog_info =>
      'Är du säker? Denna åtgärd är oåterkallelig. När blockeraren för vuxna webbplatser är PÅ kan du inte stänga av den så länge den här appen är installerad på din enhet.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Blockera ändå';

  @override
  String get blocked_websites_heading => 'Blockerade webbplatser';

  @override
  String get blocked_websites_empty_list_hint =>
      'Klicka på knappen \"+ Lägg till webbplats\" för att lägga till distraherande webbplatser som du vill blockera.';

  @override
  String get add_website_fab_button => 'Lägg till webbplats';

  @override
  String get add_website_dialog_title => 'Distraherande webbplats';

  @override
  String get add_website_dialog_info =>
      'Ange webbadressen till en webbplats som du vill blockera.';

  @override
  String get add_website_dialog_is_nsfw => 'Är nsfw webbplats?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Varning: Nsfw-webbplatser kan inte tas bort när de väl har lagts till.';

  @override
  String get add_website_dialog_button_block => 'Block';

  @override
  String get add_website_already_exist_snack_alert =>
      'Webbadressen har redan lagts till i listan över blockerade webbplatser.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Ogiltig URL! Det går inte att analysera värdnamnet.';

  @override
  String get remove_website_dialog_title => 'Ta bort webbplats';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Är du säker? du vill ta bort \'$websitehost\' från blockerade webbplatser.';
  }

  @override
  String get focus_tab_title => 'Fokusera';

  @override
  String get focus_tab_info =>
      'När du behöver tid att fokusera, starta en ny session genom att välja typ, välja distraherande appar att pausa och aktivera Stör ej för oavbruten koncentration.';

  @override
  String get active_session_card_title => 'Aktiv session';

  @override
  String get active_session_card_info =>
      'Du har ett aktivt fokuspass igång! Klicka på \"Visa\" för att kontrollera dina framsteg och se hur lång tid som har gått.';

  @override
  String get active_session_card_view_button => 'Visa';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Det är inte tillåtet att ta bort appar från den distraherande applistan medan en fokussession är aktiv. Du kan dock fortfarande lägga till ytterligare appar till listan under denna tid.';

  @override
  String get focus_profile_tile_title => 'Fokus profil';

  @override
  String get focus_session_duration_tile_title => 'Sessionens längd';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Oändligt (om du inte slutar)';

  @override
  String get focus_session_duration_dialog_info =>
      'Vänligen välj önskad varaktighet för denna fokussession, och bestäm hur länge du vill förbli fokuserad och fri från distraktion.';

  @override
  String get focus_profile_customization_tile_title => 'Profilanpassning';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Anpassa inställningarna för den valda profilen.';

  @override
  String get focus_enforce_tile_title => 'Framtvinga session';

  @override
  String get focus_enforce_tile_subtitle =>
      'Förhindrar att en session avslutas innan tiden är slut.';

  @override
  String get focus_session_start_button => 'Svep för att starta sessionen';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Välj minst en distraherande app för att starta fokussessionen';

  @override
  String get focus_session_already_active_snack_alert =>
      'Du har redan en aktiv fokussession igång. Vänligen slutför eller stoppa din nuvarande session innan du startar en ny.';

  @override
  String get focus_session_type_study => 'Studera';

  @override
  String get focus_session_type_work => 'Arbete';

  @override
  String get focus_session_type_exercise => 'Träning';

  @override
  String get focus_session_type_meditation => 'Meditation';

  @override
  String get focus_session_type_creativeWriting => 'Kreativt skrivande';

  @override
  String get focus_session_type_reading => 'Läsning';

  @override
  String get focus_session_type_programming => 'Programmering';

  @override
  String get focus_session_type_chores => 'Sysslor';

  @override
  String get focus_session_type_projectPlanning => 'Projektering';

  @override
  String get focus_session_type_artAndDesign => 'Konst och design';

  @override
  String get focus_session_type_languageLearning => 'Språkinlärning';

  @override
  String get focus_session_type_musicPractice => 'Musikövningar';

  @override
  String get focus_session_type_selfCare => 'Egenvård';

  @override
  String get focus_session_type_brainstorming => 'Brainstorming';

  @override
  String get focus_session_type_skillDevelopment => 'Kompetensutveckling';

  @override
  String get focus_session_type_research => 'Forskning';

  @override
  String get focus_session_type_networking => 'Nätverk';

  @override
  String get focus_session_type_cooking => 'Matlagning';

  @override
  String get focus_session_type_sportsTraining => 'Idrottsträning';

  @override
  String get focus_session_type_restAndRelaxation => 'Vila och avkoppling';

  @override
  String get focus_session_type_other => 'Annat';

  @override
  String get timeline_tab_title => 'Tidslinje';

  @override
  String get focus_timeline_tab_info =>
      'Utforska din fokusresa genom att välja ett datum från kalendern. Spåra dina framsteg, se om dina framgångar och lär av utmaningarna.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Din totala produktiva tid för den valda månaden är $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Produktiva dagar';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Du har haft totalt $daysCount produktiva dagar under den valda månaden.';
  }

  @override
  String get selected_day_focused_time_label => 'Fokuserad tid';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Din totala fokuserade tid för den valda dagen är $timeString.';
  }

  @override
  String get calender_heading => 'Kalender';

  @override
  String get your_sessions_heading => 'Dina sessioner';

  @override
  String get your_sessions_empty_list_hint =>
      'Inga fokussessioner registrerades för den valda dagen.';

  @override
  String get focus_session_tile_timestamp_label => 'Tidsstämpel';

  @override
  String get focus_session_tile_duration_label => 'Varaktighet';

  @override
  String get focus_session_tile_reflection_label => 'Reflektion';

  @override
  String get focus_session_state_active => 'Aktiv';

  @override
  String get focus_session_state_successful => 'Framgångsrik';

  @override
  String get focus_session_state_failed => 'Misslyckades';

  @override
  String get active_session_tab_title => 'Session';

  @override
  String get active_session_none_warning =>
      'Ingen aktiv session hittades. Återgår till startskärmen.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Fortsätt trycka på';

  @override
  String get active_session_finish_dialog_title => 'Avsluta';

  @override
  String get active_session_finish_dialog_info =>
      'Håll dig stark! Du bygger värdefullt fokus. Är du säker på att du vill avsluta den här fokussessionen? Varje extra ögonblick räknas mot dina mål.';

  @override
  String get active_session_giveup_dialog_title => 'Ge upp';

  @override
  String get active_session_giveup_dialog_info =>
      'Håll ut! Du är nästan där, ge inte upp nu! Är du säker på att du vill avsluta den här fokussessionen tidigt? Framsteg kommer att gå förlorade.';

  @override
  String get active_session_reflection_dialog_title => 'Sessionsreflektion';

  @override
  String get active_session_reflection_dialog_info =>
      'Ta en stund att reflektera över dina framsteg. Vad är ditt mål för den här sessionen? Vad har du åstadkommit under denna session?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tips: Du kan alltid redigera detta senare i sessionens tidslinje.';

  @override
  String get active_session_giveup_snack_alert =>
      'Du gav upp! Oroa dig inte, du kan göra bättre nästa gång. Varje ansträngning räknas - det är bara att fortsätta';

  @override
  String get active_session_quote_one =>
      'Varje steg räknas, var stark och fortsätt';

  @override
  String get active_session_quote_two =>
      'Håll fokus! du gör fantastiska framsteg';

  @override
  String get active_session_quote_three => 'Du krossar det! Håll farten igång';

  @override
  String get active_session_quote_four =>
      'Bara lite till kvar, du gör det fantastiskt';

  @override
  String active_session_quote_five(String durationString) {
    return 'Grattis 🎉 \n Du har slutfört din fokussession med $durationString.\n\nBra jobbat, fortsätt med det fantastiska arbetet';
  }

  @override
  String get restriction_groups_tab_title => 'Restriktionsgrupper';

  @override
  String get restriction_groups_tab_info =>
      'Ställ in en kombinerad skärmtidsgräns för en grupp appar. När den totala användningen når din gräns kommer alla appar i gruppen att pausas för att bibehålla fokus och balans.';

  @override
  String get restriction_group_time_spent_label => 'Tillbringad tid idag';

  @override
  String get restriction_group_time_left_label => 'Tid kvar idag';

  @override
  String get restriction_group_name_tile_title => 'Gruppnamn';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Ange ett namn för begränsningsgruppen för att lättare kunna identifiera och hantera den.';

  @override
  String get restriction_group_timer_tile_title => 'Grupptimer';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Ställ in en daglig tidsgräns för den här gruppen. När din gräns har nåtts kommer alla appar i den här gruppen att pausas till midnatt.';

  @override
  String get restriction_group_active_period_tile_title => 'Grupp aktiv period';

  @override
  String get remove_restriction_group_dialog_title => 'Ta bort grupp';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Är du säker? du vill ta bort \'$groupName\' från restriktionsgrupper.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Ställ in antingen en timer eller en aktiv periodgräns.';

  @override
  String get notifications_empty_list_hint =>
      'Inga aviseringar har skickats för dagen.';

  @override
  String get conversations_label => 'Samtal';

  @override
  String get last_24_hours_heading => 'Senaste 24 timmarna';

  @override
  String get notification_timeline_tab_info =>
      'Bläddra i din aviseringshistorik genom att välja ett datum från kalendern. Se vilka appar som fångade din uppmärksamhet och reflektera över dina digitala vanor.';

  @override
  String get monthly_label => 'Månadsvis';

  @override
  String get daily_label => 'Dagligen';

  @override
  String get search_notifications_sheet_info =>
      'Hitta enkelt tidigare aviseringar genom att söka igenom deras titel eller innehåll. Hjälper dig att snabbt hitta viktiga varningar.';

  @override
  String get search_notifications_hint => 'Sök aviseringar...';

  @override
  String get search_notifications_empty_list_hint =>
      'Inga aviseringar hittades som matchar din sökning.';

  @override
  String get app_info_none_warning =>
      'Det gick inte att hitta appen för det givna paketet. Återgår till startskärmen.';

  @override
  String get emergency_fab_button => 'Nödsituation';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Den här åtgärden pausar appblockeraren under de kommande 5 minuterna. Du har $leftPassesCount-kort kvar. Efter att ha använt alla pass kommer appen att förbli blockerad till midnatt, eller den aktiva fokussessionen avslutas.\n\nVill du fortfarande fortsätta?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Använd ändå';

  @override
  String get emergency_started_snack_alert =>
      'Appblockeraren är pausad och kommer att återuppta blockeringen om 5 minuter.';

  @override
  String get emergency_already_active_snack_alert =>
      'Appblockeraren är för närvarande antingen pausad eller inaktiv. Om aviseringar är aktiverade kommer du att få uppdateringar om den återstående tiden.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Du har använt alla dina nödpass. De blockerade apparna förblir blockerade till midnatt, eller så avslutas den aktiva fokussessionen.';

  @override
  String get app_limit_status_not_set => 'Inte inställt';

  @override
  String get app_timer_tile_title => 'Apptimer';

  @override
  String get app_timer_picker_dialog_info =>
      'Ställ in en daglig tidsgräns för den här appen. När din gräns har nåtts pausas appen till midnatt.';

  @override
  String get usage_reminders_tile_title => 'Användningspåminnelser';

  @override
  String get usage_reminders_tile_subtitle =>
      'Milda knuffar när du använder tidsinställda appar.';

  @override
  String get app_launch_limit_tile_title => 'Startgräns';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Lanserade $count gånger idag.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Ställ in hur många gånger du kan öppna den här appen varje dag. När gränsen är nådd pausas den till midnatt.';

  @override
  String get app_active_period_tile_title => 'Aktiv period';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Från $startTime till $endTime';
  }

  @override
  String get internet_access_tile_title => 'Tillgång till Internet';

  @override
  String get internet_access_tile_subtitle =>
      'Stäng av för att blockera appens internet.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '${appName}s internet är blockerat.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '${appName}s internet är avblockerat.';
  }

  @override
  String get launch_app_tile_title => 'Starta appen';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Öppna $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Gå till appinställningar';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Hantera appinställningar som aviseringar, behörigheter, lagring och mer.';

  @override
  String get include_in_stats_tile_title => 'Inkludera i skärmanvändning';

  @override
  String get include_in_stats_tile_subtitle =>
      'Stäng av för att utesluta den här appen från total skärmanvändning.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName exkluderas från total skärmanvändning.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName ingår för total skärmanvändning.';
  }

  @override
  String get general_tab_title => 'Allmänt';

  @override
  String get appearance_heading => 'Utseende';

  @override
  String get theme_mode_tile_title => 'Temaläge';

  @override
  String get theme_mode_system_label => 'System';

  @override
  String get theme_mode_light_label => 'Ljus';

  @override
  String get theme_mode_dark_label => 'Mörkt';

  @override
  String get material_color_tile_title => 'Material färg';

  @override
  String get amoled_dark_tile_title => 'AMOLED mörk';

  @override
  String get amoled_dark_tile_subtitle =>
      'Använd ren svart färg för det mörka temat.';

  @override
  String get dynamic_colors_tile_title => 'Dynamiska färger';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Använd enhetsfärger om det stöds.';

  @override
  String get defaults_heading => 'Standardvärden';

  @override
  String get app_language_tile_title => 'Appens språk';

  @override
  String get default_home_tab_tile_title => 'Fliken Hem';

  @override
  String get usage_history_tile_title => 'Användningshistorik';

  @override
  String get usage_history_15_days => '15 dagar';

  @override
  String get usage_history_1_month => '1 månad';

  @override
  String get usage_history_3_month => '3 månader';

  @override
  String get usage_history_6_month => '6 månader';

  @override
  String get usage_history_1_year => '1 år';

  @override
  String get service_heading => 'Service';

  @override
  String get service_stopping_warning =>
      'Om NLP digitox slutar fungera oväntat, vänligen ge tillståndet \"Ignorera batterioptimering\" för att hålla den igång i bakgrunden. Om problemet kvarstår, försök att vitlista NLP digitox för oavbruten prestanda.';

  @override
  String get whitelist_app_tile_title => 'Vitlista NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Låt NLP digitox starta automatiskt.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Den här enheten stöder inte automatisk starthantering.';

  @override
  String get database_tab_title => 'Databas';

  @override
  String get import_db_tile_title => 'Importera databas';

  @override
  String get import_db_tile_subtitle => 'Importera databas från en fil.';

  @override
  String get export_db_tile_title => 'Exportera databas';

  @override
  String get export_db_tile_subtitle => 'Exportera databas till en fil.';

  @override
  String get analysis_tab_title => 'Analys';

  @override
  String get analysis_7_days => '7 dagar';

  @override
  String get analysis_30_days => '30 dagar';

  @override
  String get analysis_90_days => '90 dagar';

  @override
  String get analysis_screen_time_trend => 'Skärmtidstrend';

  @override
  String get analysis_no_data_info =>
      'Ingen skärmtiddata har registrerats för denna period ännu.';

  @override
  String get analysis_daily_average => 'Dagligt genomsnitt';

  @override
  String get analysis_total => 'Totalt';

  @override
  String get analysis_no_change => 'Samma som förra veckan';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% mindre än förra veckan';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% mer än förra veckan';
  }

  @override
  String get crash_logs_heading => 'Krockloggar';

  @override
  String get crash_logs_info =>
      'Om du stöter på något problem kan du rapportera det på GitHub tillsammans med loggfilen. Filen kommer att innehålla detaljer som enhetens tillverkare, modell, Android-version, SDK-version och kraschloggar. Denna information hjälper oss att identifiera och lösa problemet mer effektivt.';

  @override
  String get crash_logs_export_tile_title => 'Exportera kraschloggar';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Exportera kraschloggar till en json-fil.';

  @override
  String get crash_logs_view_tile_title => 'Visa loggar';

  @override
  String get crash_logs_view_tile_subtitle => 'Utforska lagrade kraschloggar.';

  @override
  String get crash_logs_empty_list_hint => 'Ingen kraschloggad förrän nu.';

  @override
  String get crash_logs_clear_tile_title => 'Rensa loggar';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Ta bort alla kraschloggar från databasen.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Är du säker på att du vill rensa alla kraschloggar från databasen?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Klart i alla fall';

  @override
  String get about_tab_title => 'Om';

  @override
  String get changelog_tile_title => 'Ändringslogg';

  @override
  String get changelog_tile_subtitle => 'Ta reda på vad som är nytt.';

  @override
  String get full_changelog_tile_title => 'Fullständig ändringslogg';

  @override
  String get redirected_to_github_subtitle =>
      'Du kommer att omdirigeras till GitHub.';

  @override
  String get contribute_heading => 'Bidra';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Se källkoden.';

  @override
  String get report_issue_tile_title => 'Rapportera ett problem';

  @override
  String get suggest_idea_tile_title => 'Föreslå en idé';

  @override
  String get write_email_tile_title => 'Skriv till oss via mejl';

  @override
  String get write_email_tile_subtitle =>
      'Du kommer att omdirigeras till e-postappen.';

  @override
  String get privacy_policy_heading => 'Integritetspolicy';

  @override
  String get privacy_policy_info =>
      'NLP digitox har åtagit sig att skydda din integritet. Vi samlar inte in, lagrar eller överför någon typ av användardata. Appen fungerar helt offline och kräver ingen internetanslutning, vilket säkerställer att din personliga information förblir privat och säker på din enhet. Som en gratis och öppen källkodsprogram (FOSS)-applikation garanterar NLP digitox fullständig transparens och användarkontroll över deras data.';

  @override
  String get more_details_button => 'Mer information';
}
