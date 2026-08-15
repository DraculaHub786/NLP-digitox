// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get mindful_tagline => 'Keskity siihen, mikä todella merkitsee';

  @override
  String get unlock_button_label => 'Avaa lukitus';

  @override
  String get permission_status_off => 'Pois päältä';

  @override
  String get permission_status_allowed => 'Sallittu';

  @override
  String get permission_status_not_allowed => 'Ei sallittu';

  @override
  String get permission_button_grant_permission => 'Myönnä lupa';

  @override
  String get permission_button_agree_and_continue => 'Hyväksy & Jatka';

  @override
  String get permission_button_not_now => 'Ei nyt';

  @override
  String get permission_button_help => 'Apua?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox on 100 % turvallinen ja toimii offline-tilassa. Emme kerää tai tallenna henkilötietoja.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Napsauta $button_label-painiketta.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Valitse seuraavassa näytössä NLP digitox.';

  @override
  String get permission_grant_step_three =>
      '3. Napsauta ja kytke kytkin päälle kuten alla.';

  @override
  String get permission_notification_title => 'Lähetä ilmoituksia';

  @override
  String get permission_alarms_title => 'Hälytykset ja muistutukset';

  @override
  String get permission_alarms_info =>
      'Anna lupa hälytysten ja muistutusten asettamiseen. Näin NLP digitox voi aloittaa nukkumaanmenoaikataulusi ajoissa ja nollata sovellusten ajastimet päivittäin keskiyöllä ja auttaa sinua pysymään raiteilla.';

  @override
  String get permission_alarms_device_tile_label =>
      'Salli herätysten ja muistutusten asettaminen';

  @override
  String get permission_usage_title => 'Käyttöoikeus';

  @override
  String get permission_usage_info =>
      'Myönnä käyttöoikeus. Tämän ansiosta NLP digitox voi seurata sovellusten käyttöä ja hallita pääsyä tiettyihin sovelluksiin, mikä varmistaa keskittyneemmän ja kontrolloidumman digitaalisen ympäristön.';

  @override
  String get permission_usage_device_tile_label => 'Salli käyttöoikeus';

  @override
  String get permission_overlay_title => 'Näytön peittokuva';

  @override
  String get permission_overlay_info =>
      'Anna näytön peittokuvan käyttöoikeus. Näin NLP digitox voi näyttää peittokuvan, kun keskeytetty sovellus avataan, mikä auttaa sinua pysymään keskittyneenä ja ylläpitämään aikatauluasi.';

  @override
  String get permission_overlay_device_tile_label =>
      'Salli näyttö muiden sovellusten päällä';

  @override
  String get permission_accessibility_title => 'Esteettömyys';

  @override
  String get permission_accessibility_info =>
      'Anna esteettömyyslupa. Tämän ansiosta NLP digitox voi rajoittaa pääsyä lyhytmuotoiseen videosisältöön (esim. kelat, shortsit) sosiaalisen median sovelluksissa ja selaimissa ja suodattaa sopimattomia verkkosivustoja.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox vaatii esteettömyysluvan estääkseen lyhyen sisällön ja verkkosivustot tehokkaasti.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Käytä NLP digitox:ta';

  @override
  String get permission_dnd_title => 'Älä häiritse';

  @override
  String get permission_dnd_info =>
      'Anna Älä häiritse -käyttöoikeus. Näin NLP digitox voi käynnistää ja lopettaa Älä häiritse -tilan nukkumaanmenoaikataulun aikana.';

  @override
  String get permission_dnd_tile_title => 'Aloita DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Ota myös Älä häiritse -tila käyttöön.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Ohita akun optimointi';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Jo rajoittamaton';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Poista taustarajoitus käytöstä';

  @override
  String get permission_battery_optimization_allow_info =>
      '\"Ohita akun optimointi\" -toiminnon salliminen myöntää automaattisesti \"Hälytykset ja muistutukset\" -luvan joillekin laitteille.';

  @override
  String get permission_vpn_title => 'Luo VPN';

  @override
  String get permission_vpn_info =>
      'Anna lupa VPN-yhteyden luomiseen. Tämän ansiosta NLP digitox voi rajoittaa määritettyjen sovellusten Internet-yhteyttä luomalla laitteeseen paikallisen VPN:n.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Järjestelmänvalvojan oikeuksia tarvitaan vain välttämättömiin toimintoihin, jotta sovellus toimii oikein ja pysyy suojassa.';

  @override
  String get permission_admin_snack_alert =>
      'Peukalointisuojaus voidaan poistaa käytöstä vain valitun aikaikkunan aikana.';

  @override
  String get permission_notification_access_title => 'Ilmoitusten käyttöoikeus';

  @override
  String get permission_notification_access_info =>
      'Myönnä ilmoitusten käyttöoikeus. Näin NLP digitox voi järjestää ilmoituksesi ja toimittaa ne aikataulusi mukaan.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox vaatii ilmoitusten pääsyn erä- ja aikatauluilmoituksiin.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Salli ilmoitusten käyttöoikeus';

  @override
  String get day_today => 'Tänään';

  @override
  String get day_yesterday => 'eilen';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString päivää',
      one: '1 päivä',
      zero: '0 päivää',
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
      other: '$countString tuntia',
      one: '1 tunti',
      zero: '0 tuntia',
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
      other: '$countString minuuttia',
      one: '1 minuutti',
      zero: '0 minuuttia',
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
      other: '$countString sekuntia',
      one: '1 sekunti',
      zero: '0 sekuntia',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'ja';

  @override
  String get timer_status_active => 'Aktiivinen';

  @override
  String get timer_status_paused => 'Keskeytetty';

  @override
  String get create_button => 'Luo';

  @override
  String get update_button => 'Päivitä';

  @override
  String get dialog_button_cancel => 'Peruuta';

  @override
  String get dialog_button_remove => 'Poista';

  @override
  String get dialog_button_set => 'Aseta';

  @override
  String get dialog_button_reset => 'Nollaa';

  @override
  String get dialog_button_infinite => 'ääretön';

  @override
  String get schedule_start_label => 'Aloita';

  @override
  String get schedule_end_label => 'Loppu';

  @override
  String get exit_without_saving_dialog_info =>
      'Haluatko varmasti poistua tallentamatta?';

  @override
  String get development_dialog_info =>
      'NLP digitox on parhaillaan kehitteillä ja saattaa sisältää virheitä tai epätäydellisiä ominaisuuksia. Jos kohtaat ongelmia, ilmoita niistä, jotta voimme parantaa toimintaamme.\n\nQKiitos palautteestasi!';

  @override
  String get development_dialog_button_report_issue => 'Ilmoita ongelmasta';

  @override
  String get development_dialog_button_close => 'Sulje';

  @override
  String get dnd_settings_tile_title => 'Älä häiritse -asetukset';

  @override
  String get dnd_settings_tile_subtitle =>
      'Hallinnoi, mitkä sovellukset ja ilmoitukset voivat tavoittaa sinut DND:ssä.';

  @override
  String get quick_actions_heading => 'Nopeita toimia';

  @override
  String get select_distracting_apps_heading =>
      'Valitse häiritseviä sovelluksia';

  @override
  String get your_distracting_apps_heading => 'Häiritsevät sovelluksesi';

  @override
  String get select_more_apps_heading => 'Valitse lisää sovelluksia';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Tärkeiden järjestelmäsovellusten lisääminen häiritsevien sovellusten luetteloon ei ole sallittua.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Näytön käyttö ja rajoitukset eivät ole saatavilla tälle sovellukselle. Tällä hetkellä vain verkon käyttö on käytettävissä';

  @override
  String get create_group_fab_button => 'Luo ryhmä';

  @override
  String get active_period_info =>
      'Aseta aika, jonka aikana käyttö sallitaan. Tämän ajan ulkopuolella pääsyä rajoitetaan.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Valitse vähintään yksi häiritsevä sovellus.';

  @override
  String get donation_card_title => 'Tue meitä';

  @override
  String get donation_card_info =>
      'NLP digitox on ilmainen ja avoimen lähdekoodin, joka on kehitetty kuukausien omistautumalla. Jos se on auttanut sinua, lahjoituksesi merkitsisi meille maailmaa. Jokainen panos auttaa meitä parantamaan ja ylläpitämään sitä kaikkien kannalta.';

  @override
  String get operation_failed_snack_alert =>
      'Toiminta epäonnistui, jotain meni pieleen!';

  @override
  String get donation_card_button_donate => 'Lahjoita';

  @override
  String get app_restart_dialog_title => 'Tarvitsee uudelleenkäynnistyksen';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox käynnistyy automaattisesti uudelleen, kun lähtölaskenta on päättynyt. Ole kärsivällinen muutosten tullessa voimaan.';

  @override
  String get accessibility_tip =>
      'Haluatko älykkäämmän, akkuystävällisemmän eston? Ota käyttöön NLP digitox:n esteettömyysoikeus.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox ei toimi? Salli \"Ohita akun optimointi\" asetuksissa, jotta se toimii sujuvasti.';

  @override
  String get invincible_mode_tip =>
      'Poistettiinko rajoitukset vahingossa? Käytä Invincible Modea lukitaksesi ne seuraavaan päivään tai säätöikkunaan.';

  @override
  String get glance_usage_tip =>
      'Haluatko oivalluksia? Katso Glance-osiosta nähdäksesi käyttötavat ja käyttöaikasi.';

  @override
  String get tamper_protection_tip =>
      'Poistetaanko NLP digitox:n asennus? Ota Uninstall-ikkuna käyttöön, jotta peukalointisuojaus poistetaan turvallisesti käytöstä.';

  @override
  String get notification_blocking_tip =>
      'Haluatko vähentää häiriötekijöitä? Käytä ilmoitusten estoa hiljentämään valitut sovellukset.';

  @override
  String get usage_history_tip =>
      'Haluatko pohtia tapojasi? Tarkista käyttöhistoria nähdäksesi aikaisemmat mallit.';

  @override
  String get focus_mode_tip =>
      'Tarvitsetko syvää keskittymistä? Ota tarkennustila käyttöön estääksesi sovellukset ja ilmoitukset tehtävien aikana.';

  @override
  String get bedtime_reminder_tip =>
      'Haluatko parantaa untasi? Aseta nukkumaanmenoaikamuistutus rauhoittumaan iltaisin.';

  @override
  String get custom_blocking_tip =>
      'Tarvitsetko mukautetun kokemuksen? Luo tarpeisiisi sopivat sovellusten estosäännöt.';

  @override
  String get session_timeline_tip =>
      'Haluatko seurata keskittymisistuntoja? Tarkastele aikajanaa nähdäksesi keskittymismatkasi.';

  @override
  String get short_content_blocking_tip =>
      'Häiritsevätkö sosiaaliset sovellukset? Estä lyhyt sisältö Instagramissa, YouTubessa jne. pysyäksesi keskittyneenä.';

  @override
  String get parental_controls_tip =>
      'Tarvitsetko vanhempien valvontaa? Aseta rajoituksia lapsesi laitteelle varmistaaksesi turvallisen käyttökokemuksen.';

  @override
  String get notification_batching_tip =>
      'Haluatko vähentää häiriötekijöitä? Käytä Notification Batchingia ryhmittääksesi ilmoitukset ja tarkistaaksesi ne kerralla.';

  @override
  String get notification_scheduling_tip =>
      'Haluatko hallita ilmoituksia? Ajoita, kun saat ilmoituksia tietyistä sovelluksista.';

  @override
  String get quick_focus_tile_tip =>
      'Tarvitsetko nopean pääsyn keskittymiseen? Lisää Quick Focus Tile aktivoidaksesi tarkennustilan välittömästi.';

  @override
  String get app_shortcuts_tip =>
      'Haluatko pikasovelluksen pääsyn? Lisää pikakuvakkeita painamalla pitkään sovelluskuvaketta nopeaa toimintaa varten.';

  @override
  String get backup_usage_db_tip =>
      'Haluatko tallentaa tietosi? Varmuuskopioi käyttötietokantasi pitääksesi tietosi turvassa.';

  @override
  String get dynamic_material_color_tip =>
      'Haluatko mukautetun teeman? Ota käyttöön dynaaminen materiaali Värisi vastaamaan laitteesi teemaa.';

  @override
  String get amoled_dark_theme_tip =>
      'Haluatko säästää akkua? Käytä AMOLED Dark -teemaa vähentääksesi virrankulutusta OLED-näytöissä.';

  @override
  String get customize_usage_history_tip =>
      'Haluatko säilyttää käyttöhistorian? Mukauta, kuinka monta viikkoa käyttöhistoriaan tallennettavia tietoja.';

  @override
  String get grouped_apps_blocking_tip =>
      'Haluatko estää sovelluksia yhdessä? Rajoitusryhmien avulla voit ryhmitellä sovellusten rajoitukset ja estää useita sovelluksia kerralla.';

  @override
  String get websites_blocking_tip =>
      'Haluatko puhtaamman selauskokemuksen? Estä mukautetut tai NSFW-sivustot keskittyäksesi online-aikaan.';

  @override
  String get data_usage_tip =>
      'Haluatko seurata tietojasi? Tarkkaile mobiili- ja Wi-Fi-tiedonkäyttöäsi Internetin käytön suhteen.';

  @override
  String get block_internet_tip =>
      'Haluatko estää sovelluksen internetyhteyden? Katkaise Internet tietylle sovellukselle sovelluksen hallintapaneelista.';

  @override
  String get emergency_passes_tip =>
      'Tarvitsetko tauon? Käytä kolmea hätäkorttia päivittäin poistaaksesi sovellusten eston tilapäisesti 5 minuutiksi.';

  @override
  String get onboarding_skip_btn_label => 'Ohita';

  @override
  String get onboarding_finish_setup_btn_label => 'Viimeistele asennus';

  @override
  String get onboarding_page_welcome_title => 'Tervetuloa NLP digitoxiin.';

  @override
  String get onboarding_page_welcome_info =>
      'Ota hallintaan digitaalinen elämäsi ja rakenna terveellisempiä ruutuaikatottumuksia. NLP digitox auttaa sinua pysymään keskittyneenä, vähentämään häiriötekijöitä ja tekemään tietoisia valintoja joka päivä.';

  @override
  String get onboarding_page_statistics_title => 'Tunne tapasi.';

  @override
  String get onboarding_page_statistics_info =>
      'Ymmärrä digitaalisia käyttäytymismallejasi yksityiskohtaisten näkemysten avulla ruutuajasta, sovellusten käytöstä ja keskittymistrendeistä. Seuraa edistymistäsi ja huomaa, kuinka pienet muutokset johtavat suuriin parannuksiin.';

  @override
  String get onboarding_page_one_title => 'Master Focus.';

  @override
  String get onboarding_page_one_info =>
      'Keskeytä häiritsevät sovellukset, estä lyhyt sisältö ja pysy ajan tasalla mukautettavien tarkennusistuntojen avulla. Työskenteletpä, opiskelet tai rentoudut, NLP digitox auttaa sinua pysymään hallinnassa.';

  @override
  String get onboarding_page_two_title => 'Estä häiriötekijät.';

  @override
  String get onboarding_page_two_info =>
      'Aseta käyttörajoituksia, keskeytä sovellukset automaattisesti ja luo terveellisempiä digitaalisia tapoja. Käytä nukkumaanmenotilaa rentoutuaksesi ja nauttiaksesi häiriöttömästä yöstä.';

  @override
  String get onboarding_page_three_title => 'Yksityisyys ensin.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox on 100 % avoimen lähdekoodin ja toimii täysin offline-tilassa. Emme kerää tai jaa henkilötietojasi – yksityisyytesi on taattu kaikin tavoin.';

  @override
  String get onboarding_page_permissions_title => 'Olennaiset käyttöoikeudet.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox edellyttää välttämättömien lupien noudattamista, jotta voit seurata ja hallita näyttöaikaasi, mikä auttaa vähentämään häiriötekijöitä ja parantamaan keskittymistä.';

  @override
  String get dashboard_tab_title => 'Kojelauta';

  @override
  String get focus_now_fab_button => 'Keskity nyt';

  @override
  String get welcome_greetings => 'Tervetuloa takaisin,';

  @override
  String get username_snack_alert =>
      'Paina pitkään muokataksesi käyttäjätunnusta.';

  @override
  String get username_dialog_title => 'Käyttäjätunnus';

  @override
  String get username_dialog_info =>
      'Anna käyttäjätunnuksesi, joka näkyy kojelaudassa.';

  @override
  String get username_dialog_button_apply => 'Käytä';

  @override
  String get glance_tile_title => 'Vilkaise';

  @override
  String get glance_tile_subtitle => 'Vilkaise nopeasti käyttöäsi.';

  @override
  String get parental_controls_tile_subtitle =>
      'Voittamaton tila ja peukalointisuoja.';

  @override
  String get restrictions_heading => 'Rajoitukset';

  @override
  String get apps_blocking_tile_title => 'Sovellusten esto';

  @override
  String get apps_blocking_tile_subtitle =>
      'Rajoita sovelluksia useilla tavoilla.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Ryhmitettyjen sovellusten esto';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Rajoita sovellusten ryhmää samanaikaisesti.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Rajoita lyhyttä sisältöä useilla alustoilla.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Rajoita aikuisille tarkoitettuja ja mukautettuja verkkosivustoja.';

  @override
  String get screen_time_label => 'Ruutuaika';

  @override
  String get total_data_label => 'Tiedot yhteensä';

  @override
  String get mobile_data_label => 'Mobiilidata';

  @override
  String get wifi_data_label => 'Wifi-data';

  @override
  String get focus_today_label => 'Keskity tänään';

  @override
  String get focus_weekly_label => 'Keskity viikoittain';

  @override
  String get focus_monthly_label => 'Keskity kuukausittain';

  @override
  String get focus_lifetime_label => 'Keskity elinkaareen';

  @override
  String get longest_streak_label => 'Pisin putki';

  @override
  String get current_streak_label => 'Nykyinen sarja';

  @override
  String get successful_sessions_label => 'Onnistuneet istunnot';

  @override
  String get failed_sessions_label => 'Epäonnistuneet istunnot';

  @override
  String get statistics_tab_title => 'Tilastot';

  @override
  String get screen_segment_label => 'Näyttö';

  @override
  String get data_segment_label => 'Data';

  @override
  String get mobile_label => 'mobiili';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Eniten käytetyt sovellukset';

  @override
  String get show_all_apps_tile_title => 'Näytä kaikki sovellukset';

  @override
  String get search_apps_hint => 'Hae sovelluksia...';

  @override
  String get notifications_tab_title => 'Ilmoitukset';

  @override
  String get notifications_tab_info =>
      'Eräilmoitukset sovelluksista ja aikataulut, kuten aamulla, keskipäivällä, illalla ja yöllä. Pysy ajan tasalla ilman jatkuvia keskeytyksiä.';

  @override
  String get batched_apps_tile_title => 'Joukkosovellukset';

  @override
  String get batch_recap_dropdown_title => 'Erän yhteenvetotyyppi';

  @override
  String get batch_recap_dropdown_info =>
      'Valitse, mitä työntää aikataulun käynnistyessä – kaikki ilmoitukset vai vain yhteenveto.';

  @override
  String get batch_recap_option_summery_only => 'Vain yhteenveto';

  @override
  String get batch_recap_option_all_notifications => 'Kaikki ilmoitukset';

  @override
  String get notification_history_tile_title => 'Ilmoitushistoria';

  @override
  String get store_all_tile_title => 'Tallenna kaikki ilmoitukset';

  @override
  String get store_all_tile_subtitle =>
      'Tallenna myös eräämättömät ilmoitukset.';

  @override
  String get schedules_heading => 'Aikataulut';

  @override
  String get new_schedule_fab_button => 'Uusi aikataulu';

  @override
  String get new_schedule_dialog_info =>
      'Anna ilmoitusaikataululle nimi, jotta se on helppo tunnistaa.';

  @override
  String get new_schedule_dialog_field_label => 'Aikataulun nimi';

  @override
  String get bedtime_tab_title => 'Nukkumaanmenoaika';

  @override
  String get bedtime_tab_info =>
      'Aseta nukkumaanmenoaikataulu valitsemalla aikajakso ja viikonpäivät. Valitse häiritseviä sovelluksia estääksesi ja ota Älä häiritse (DND) -tila käyttöön rauhallisen yön takaamiseksi.';

  @override
  String get schedule_tile_title => 'Aikataulu';

  @override
  String get schedule_tile_subtitle =>
      'Ota käyttöön tai poista käytöstä päivittäinen aikataulu.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Valitse vähintään yksi viikonpäivä.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Nukkumaanmenon kokonaiskeston tulee olla vähintään 30 minuuttia.';

  @override
  String get distracting_apps_tile_title => 'Häiritsevät sovellukset';

  @override
  String get distracting_apps_tile_subtitle =>
      'Valitse, mitkä sovellukset häiritsevät sinua nukkumaanmeno-rutiinistasi.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Häiritsevien sovellusten luettelon muuttaminen ei ole sallittua nukkumaanmenoaikataulun ollessa aktiivinen.';

  @override
  String get parental_controls_tab_title => 'Lapsilukko';

  @override
  String get invincible_mode_heading => 'Voittamaton tila';

  @override
  String get invincible_mode_tile_title => 'Aktivoi voittamaton tila';

  @override
  String get invincible_mode_info =>
      'Kun Invincible Mode on käytössä, et voi muuttaa valittuja rajoja päivittäisen kiintiösi saavuttamisen jälkeen. Voit kuitenkin tehdä muutoksia valitun 10 minuutin voittamattoman ikkunan sisällä.';

  @override
  String get invincible_mode_snack_alert =>
      'Voittamattoman tilan vuoksi rajoitusten muuttaminen ei ole sallittua.';

  @override
  String get invincible_mode_dialog_info =>
      'Oletko aivan varma, että haluat ottaa Invincible Moden käyttöön? Tämä toimenpide on peruuttamaton. Kun Invincible Mode on käytössä, et voi sammuttaa sitä niin kauan kuin tämä sovellus on asennettuna laitteellesi.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Invincible Modea ei voi poistaa käytöstä niin kauan kuin tämä sovellus on asennettuna laitteellesi.';

  @override
  String get invincible_mode_dialog_button_start_anyway =>
      'Aloita joka tapauksessa';

  @override
  String get invincible_mode_include_timer_tile_title => 'Sisällytä ajastin';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Sisällytä laukaisuraja';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Sisällytä aktiivinen ajanjakso';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Sovellusrajoitukset';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Estä muutokset sovelluksen valittuihin rajoituksiin, kun päivittäiset rajat ylittyvät.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Ryhmärajoitukset';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Estä muutokset ryhmän valittuihin rajoituksiin, kun päivittäiset rajat ylittyvät.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Mukana shortsien ajastin';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Estää muutokset päivittäisen shortsirajan saavuttamisen jälkeen.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Sisällytä nukkumaanmenoaika';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Estää muutokset aktiivisen nukkumaanmenoaikataulun aikana.';

  @override
  String get protected_access_tile_title => 'Suojattu pääsy';

  @override
  String get protected_access_tile_subtitle =>
      'Suojaa NLP digitox laitteesi lukituksella.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Ota tämä ominaisuus käyttöön määrittämällä ensin laitteellesi biometrinen lukitus.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Laitteesi lukitus on poistettu. Jatka määrittämällä uusi lukko.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Todennus epäonnistui. Sinun on vahvistettava laitteesi lukitus jatkaaksesi.';

  @override
  String get tamper_protection_tile_title => 'Peukalointisuoja';

  @override
  String get tamper_protection_tile_subtitle =>
      'Estä asennuksen poistaminen ja pakota sovelluksen pysäyttäminen.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Kun tämä on otettu käyttöön, et voi poistaa asennusta, pakottaa pysäyttämään tai tyhjentämään NLP digitox:n tietoja, paitsi valitun asennuksen poistoikkunan aikana. Kiertotapoja ei ole.\n\nJatka omalla vastuullasi.';

  @override
  String get uninstall_window_tile_title => 'Poista ikkuna';

  @override
  String get uninstall_window_tile_subtitle =>
      'Suojaus voidaan kytkeä pois päältä 10 minuutin kuluessa valitusta ajasta.';

  @override
  String get invincible_window_tile_title => 'Voittamaton ikkuna';

  @override
  String get invincible_window_tile_subtitle =>
      'Valittuja rajoja voidaan muuttaa 10 minuutin sisällä valitusta ajasta.';

  @override
  String get shorts_blocking_tab_title => 'Shortsien esto';

  @override
  String get shorts_blocking_tab_info =>
      'Hallitse, kuinka paljon aikaa käytät lyhyeen sisältöön eri alustoilla, kuten Instagramissa, YouTubessa, Snapchatissa ja Facebookissa, mukaan lukien niiden verkkosivustot.';

  @override
  String get short_content_heading => 'Lyhyt sisältö';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Vasen mallista $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Aseta päivittäinen aikaraja lyhyelle sisällölle. Kun raja saavutetaan, lyhyt sisältö keskeytetään keskiyöhön asti.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Rajoita ominaisuuksia instagramissa.';

  @override
  String get instagram_features_block_reels => 'Rajoita rullien osio.';

  @override
  String get instagram_features_block_explore => 'Rajoita tutkimusosiota.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Rajoita snapchatin ominaisuuksia.';

  @override
  String get snapchat_features_block_spotlight => 'Rajoita kohdevaloosaa.';

  @override
  String get snapchat_features_block_discover => 'Rajoita etsintäosiota.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle => 'Rajoita shortsit youtubessa.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle => 'Rajoita keloja Facebookissa.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Rajoita shortsit redditissä.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Rajoita videosyötettä X:lle.';

  @override
  String get threads_features_tile_title => 'Kierteet';

  @override
  String get threads_features_tile_subtitle =>
      'Rajoita videoita/keloja säikeissä.';

  @override
  String get websites_blocking_tab_title => 'Verkkosivustojen esto';

  @override
  String get websites_blocking_tab_info =>
      'Estä aikuisille suunnatut sivustot ja kaikki valitsemasi mukautetut sivustot luodaksesi turvallisemman ja tarkemman verkkokokemuksen. Ota selaamisestasi vastuu ja pysy häiriöttömänä.';

  @override
  String get adult_content_heading => 'Aikuisille suunnattua sisältöä';

  @override
  String get block_nsfw_title => 'Estä Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Estä selaimia avaamasta aikuisille suunnattuja ja pornosivustoja.';

  @override
  String get block_nsfw_dialog_info =>
      'Oletko varma? Tämä toimenpide on peruuttamaton. Kun aikuisille tarkoitettujen sivustojen esto on otettu käyttöön, et voi kytkeä sitä pois päältä niin kauan kuin tämä sovellus on asennettu laitteellesi.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Estä joka tapauksessa';

  @override
  String get blocked_websites_heading => 'Estetyt verkkosivustot';

  @override
  String get blocked_websites_empty_list_hint =>
      'Napsauta + Lisää verkkosivusto -painiketta lisätäksesi häiritseviä verkkosivustoja, jotka haluat estää.';

  @override
  String get add_website_fab_button => 'Lisää verkkosivusto';

  @override
  String get add_website_dialog_title => 'Häiritsevä verkkosivusto';

  @override
  String get add_website_dialog_info =>
      'Anna sen verkkosivuston URL-osoite, jonka haluat estää.';

  @override
  String get add_website_dialog_is_nsfw => 'Onko nsfw-sivusto?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Varoitus: Nsfw-sivustoja ei voi poistaa lisättyään.';

  @override
  String get add_website_dialog_button_block => 'Estä';

  @override
  String get add_website_already_exist_snack_alert =>
      'URL-osoite on jo lisätty estettyjen verkkosivustojen luetteloon.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Virheellinen URL-osoite! Isäntänimeä ei voi jäsentää.';

  @override
  String get remove_website_dialog_title => 'Poista verkkosivusto';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Oletko varma? haluat poistaa \'$websitehost\' estetyiltä verkkosivustoilta.';
  }

  @override
  String get focus_tab_title => 'Keskity';

  @override
  String get focus_tab_info =>
      'Kun tarvitset aikaa keskittymiseen, aloita uusi istunto valitsemalla tyyppi, keskeytettävät häiritsevät sovellukset ja ottamalla Älä häiritse -toiminto käyttöön keskeytymätöntä keskittymistä varten.';

  @override
  String get active_session_card_title => 'Aktiivinen istunto';

  @override
  String get active_session_card_info =>
      'Sinulla on aktiivinen keskittymisistunto käynnissä! Napsauta \"Näytä\" nähdäksesi edistymisesi ja kuinka paljon aikaa on kulunut.';

  @override
  String get active_session_card_view_button => 'Näytä';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Sovellusten poistaminen häiritsevien sovellusten luettelosta ei ole sallittua, kun Focus Session on aktiivinen. Voit kuitenkin lisätä muita sovelluksia luetteloon tänä aikana.';

  @override
  String get focus_profile_tile_title => 'Tarkennusprofiili';

  @override
  String get focus_session_duration_tile_title => 'Istunnon kesto';

  @override
  String get focus_session_duration_tile_subtitle => 'ääretön (ellet lopeta)';

  @override
  String get focus_session_duration_dialog_info =>
      'Valitse haluttu kesto tälle keskittymisjaksolle ja määritä, kuinka kauan haluat pysyä keskittyneenä ja ilman häiriötekijöitä.';

  @override
  String get focus_profile_customization_tile_title =>
      'Profiilin mukauttaminen';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Mukauta valitun profiilin asetuksia.';

  @override
  String get focus_enforce_tile_title => 'Pakota istunto';

  @override
  String get focus_enforce_tile_subtitle =>
      'Estää istunnon lopettamisen ennen kuin aika loppuu.';

  @override
  String get focus_session_start_button => 'Pyyhkäise aloittaaksesi istunnon';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Valitse vähintään yksi häiritsevä sovellus aloittaaksesi tarkennusistunnon';

  @override
  String get focus_session_already_active_snack_alert =>
      'Sinulla on jo aktiivinen keskittymisistunto käynnissä. Viimeistele tai lopeta nykyinen istuntosi ennen kuin aloitat uuden.';

  @override
  String get focus_session_type_study => 'Opiskelu';

  @override
  String get focus_session_type_work => 'Työ';

  @override
  String get focus_session_type_exercise => 'Harjoittele';

  @override
  String get focus_session_type_meditation => 'Meditaatio';

  @override
  String get focus_session_type_creativeWriting => 'Luova kirjoittaminen';

  @override
  String get focus_session_type_reading => 'Lukeminen';

  @override
  String get focus_session_type_programming => 'Ohjelmointi';

  @override
  String get focus_session_type_chores => 'Askareita';

  @override
  String get focus_session_type_projectPlanning => 'Projektisuunnittelu';

  @override
  String get focus_session_type_artAndDesign => 'Taide ja muotoilu';

  @override
  String get focus_session_type_languageLearning => 'Kielten oppiminen';

  @override
  String get focus_session_type_musicPractice => 'Musiikin harjoitus';

  @override
  String get focus_session_type_selfCare => 'Itsehoito';

  @override
  String get focus_session_type_brainstorming => 'Aivoriihi';

  @override
  String get focus_session_type_skillDevelopment => 'Taitojen kehittäminen';

  @override
  String get focus_session_type_research => 'Tutkimus';

  @override
  String get focus_session_type_networking => 'Verkostoituminen';

  @override
  String get focus_session_type_cooking => 'Ruoanlaitto';

  @override
  String get focus_session_type_sportsTraining => 'Urheilu koulutus';

  @override
  String get focus_session_type_restAndRelaxation => 'Lepo ja rentoutuminen';

  @override
  String get focus_session_type_other => 'Muut';

  @override
  String get timeline_tab_title => 'Aikajana';

  @override
  String get focus_timeline_tab_info =>
      'Tutustu fokusmatkaasi valitsemalla päivämäärä kalenterista. Seuraa edistymistäsi, tarkastele onnistumisia ja opi haasteista.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Valitun kuukauden kokonaistuotantoaikasi on $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Tuottavia päiviä';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Sinulla on ollut yhteensä $daysCount tuottavia päiviä valitussa kuukaudessa.';
  }

  @override
  String get selected_day_focused_time_label => 'Keskitetty aika';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Valitun päivän keskittymisaikasi on yhteensä $timeString.';
  }

  @override
  String get calender_heading => 'Kalenteri';

  @override
  String get your_sessions_heading => 'Omat istunnot';

  @override
  String get your_sessions_empty_list_hint =>
      'Valitulle päivälle ei tallennettu kohdistusistuntoja.';

  @override
  String get focus_session_tile_timestamp_label => 'Aikaleima';

  @override
  String get focus_session_tile_duration_label => 'Kesto';

  @override
  String get focus_session_tile_reflection_label => 'Heijastus';

  @override
  String get focus_session_state_active => 'Aktiivinen';

  @override
  String get focus_session_state_successful => 'Onnistunut';

  @override
  String get focus_session_state_failed => 'Epäonnistui';

  @override
  String get active_session_tab_title => 'Istunto';

  @override
  String get active_session_none_warning =>
      'Aktiivista istuntoa ei löytynyt. Paluu aloitusnäyttöön.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Jatka työntämistä';

  @override
  String get active_session_finish_dialog_title => 'Valmis';

  @override
  String get active_session_finish_dialog_info =>
      'Pysy vahvana! Rakennat arvokasta keskittymistä. Haluatko varmasti lopettaa tämän keskittymisistunnon? Jokainen ylimääräinen hetki on tärkeä tavoitteidesi saavuttamisessa.';

  @override
  String get active_session_giveup_dialog_title => 'Luovuta';

  @override
  String get active_session_giveup_dialog_info =>
      'Pidä kiinni! Olet melkein perillä, älä luovuta nyt! Haluatko varmasti lopettaa tämän keskittymisistunnon aikaisin? Edistys menetetään.';

  @override
  String get active_session_reflection_dialog_title => 'Session reflektointi';

  @override
  String get active_session_reflection_dialog_info =>
      'Käytä hetki edistymisen pohtimiseen. Mikä on tavoitteesi tälle istunnolle? Mitä sait aikaan tämän istunnon aikana?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Vinkki: Voit aina muokata tätä myöhemmin istunnon aikajanalla.';

  @override
  String get active_session_giveup_snack_alert =>
      'Sinä luovutit! Älä huoli, voit tehdä paremmin ensi kerralla. Jokainen yritys on tärkeä - jatka vain';

  @override
  String get active_session_quote_one =>
      'Jokainen askel on tärkeä, pysy vahvana ja jatka eteenpäin';

  @override
  String get active_session_quote_two =>
      'Pysy keskittyneenä! edistyt hämmästyttävällä tavalla';

  @override
  String get active_session_quote_three => 'Murskaat sen! Pidä vauhti päällä';

  @override
  String get active_session_quote_four =>
      'Vielä vähän aikaa, sinulla menee upeasti';

  @override
  String active_session_quote_five(String durationString) {
    return 'Onnittelut 🎉 \n Olet suorittanut $durationString.\n\nUpeaa työtä, jatka samaan malliin';
  }

  @override
  String get restriction_groups_tab_title => 'Rajoitusryhmät';

  @override
  String get restriction_groups_tab_info =>
      'Aseta yhdistetty käyttöaikaraja sovellusten ryhmälle. Kun kokonaiskäyttö saavuttaa rajasi, kaikki ryhmän sovellukset keskeytetään keskittymisen ja tasapainon säilyttämiseksi.';

  @override
  String get restriction_group_time_spent_label => 'Tänään käytetty aika';

  @override
  String get restriction_group_time_left_label => 'Aikaa jäljellä tänään';

  @override
  String get restriction_group_name_tile_title => 'Ryhmän nimi';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Anna rajoitusryhmälle nimi, joka helpottaa sen tunnistamista ja hallintaa.';

  @override
  String get restriction_group_timer_tile_title => 'Ryhmäajastin';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Aseta tälle ryhmälle päivittäinen aikaraja. Kun raja saavutetaan, kaikki tämän ryhmän sovellukset keskeytetään keskiyöhön asti.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Ryhmän aktiivinen aika';

  @override
  String get remove_restriction_group_dialog_title => 'Poista ryhmä';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Oletko varma? haluat poistaa \'$groupName\' rajoitusryhmistä.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Aseta joko ajastin tai aktiivinen ajanjakso.';

  @override
  String get notifications_empty_list_hint =>
      'Päivältä ei ole lähetetty ilmoituksia.';

  @override
  String get conversations_label => 'Keskustelut';

  @override
  String get last_24_hours_heading => 'Viimeiset 24 tuntia';

  @override
  String get notification_timeline_tab_info =>
      'Selaa ilmoitushistoriaasi valitsemalla päivämäärä kalenterista. Katso, mitkä sovellukset kiinnittivät huomiosi, ja mieti digitaalisia tottumuksiasi.';

  @override
  String get monthly_label => 'Kuukausittain';

  @override
  String get daily_label => 'Päivittäin';

  @override
  String get search_notifications_sheet_info =>
      'Löydä aiemmat ilmoitukset helposti etsimällä niiden otsikkoa tai sisältöä. Auttaa sinua löytämään nopeasti tärkeät hälytykset.';

  @override
  String get search_notifications_hint => 'Hae ilmoituksia...';

  @override
  String get search_notifications_empty_list_hint =>
      'Hakuasi vastaavia ilmoituksia ei löytynyt.';

  @override
  String get app_info_none_warning =>
      'Annetun paketin sovellusta ei löytynyt. Paluu aloitusnäyttöön.';

  @override
  String get emergency_fab_button => 'Hätä';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Tämä toiminto keskeyttää sovellusten eston seuraavien 5 minuutin ajaksi. Sinulla on $leftPassesCount-kortteja jäljellä. Kun kaikki passit on käytetty, sovellus pysyy estettynä keskiyöhön asti tai aktiivinen tarkennusjakso päättyy.\n\nHaluatko silti jatkaa?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Käytä joka tapauksessa';

  @override
  String get emergency_started_snack_alert =>
      'Sovellusten esto on keskeytetty ja se jatkaa estämistä 5 minuutin kuluttua.';

  @override
  String get emergency_already_active_snack_alert =>
      'Sovellusten esto on tällä hetkellä joko keskeytetty tai ei-aktiivinen. Jos ilmoitukset ovat käytössä, saat päivityksiä jäljellä olevasta ajasta.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Olet käyttänyt kaikki hätäkorttisi. Estetyt sovellukset pysyvät estettyinä puoleenyöhön asti tai aktiivisen tarkennusjakson päättyessä.';

  @override
  String get app_limit_status_not_set => 'Ei asetettu';

  @override
  String get app_timer_tile_title => 'Sovelluksen ajastin';

  @override
  String get app_timer_picker_dialog_info =>
      'Aseta tälle sovellukselle päivittäinen aikaraja. Kun raja saavutetaan, sovellus keskeytetään keskiyöhön asti.';

  @override
  String get usage_reminders_tile_title => 'Käyttömuistutukset';

  @override
  String get usage_reminders_tile_subtitle =>
      'Hellävaraiset nyökytyksiä käytettäessä ajastettuja sovelluksia.';

  @override
  String get app_launch_limit_tile_title => 'Käynnistysraja';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Julkaistu $count kertaa tänään.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Aseta, kuinka monta kertaa voit avata tämän sovelluksen joka päivä. Kun raja saavutetaan, se keskeytetään keskiyöhön asti.';

  @override
  String get app_active_period_tile_title => 'Aktiivinen ajanjakso';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return '$startTime - $endTime';
  }

  @override
  String get internet_access_tile_title => 'Internet-yhteys';

  @override
  String get internet_access_tile_subtitle =>
      'Katkaise virta estääksesi sovelluksen internetyhteyden.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '$appName:n internetyhteys on estetty.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '$appName:n Internet on vapautettu.';
  }

  @override
  String get launch_app_tile_title => 'Käynnistä sovellus';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Avaa $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Siirry sovelluksen asetuksiin';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Hallinnoi sovellusasetuksia, kuten ilmoituksia, käyttöoikeuksia, tallennustilaa ja muuta.';

  @override
  String get include_in_stats_tile_title => 'Sisällytä näytön käyttöön';

  @override
  String get include_in_stats_tile_subtitle =>
      'Katkaise virta, jos haluat sulkea tämän sovelluksen näytön kokonaiskäytöstä.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName ei sisälly näytön kokonaiskäyttöön.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName sisältyy näytön kokonaiskäyttöön.';
  }

  @override
  String get general_tab_title => 'Kenraali';

  @override
  String get appearance_heading => 'Ulkonäkö';

  @override
  String get theme_mode_tile_title => 'Teematila';

  @override
  String get theme_mode_system_label => 'Järjestelmä';

  @override
  String get theme_mode_light_label => 'Kevyt';

  @override
  String get theme_mode_dark_label => 'Tumma';

  @override
  String get material_color_tile_title => 'Materiaalin väri';

  @override
  String get amoled_dark_tile_title => 'AMOLED tumma';

  @override
  String get amoled_dark_tile_subtitle =>
      'Käytä puhdasta mustaa väriä tummaan teemaan.';

  @override
  String get dynamic_colors_tile_title => 'Dynaamiset värit';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Käytä laitteen värejä, jos niitä tuetaan.';

  @override
  String get defaults_heading => 'Oletukset';

  @override
  String get app_language_tile_title => 'Sovelluksen kieli';

  @override
  String get default_home_tab_tile_title => 'Koti-välilehti';

  @override
  String get usage_history_tile_title => 'Käyttöhistoria';

  @override
  String get usage_history_15_days => '15 päivää';

  @override
  String get usage_history_1_month => '1 kuukausi';

  @override
  String get usage_history_3_month => '3 kuukautta';

  @override
  String get usage_history_6_month => '6 kuukautta';

  @override
  String get usage_history_1_year => '1 vuosi';

  @override
  String get service_heading => 'Palvelu';

  @override
  String get service_stopping_warning =>
      'Jos NLP digitox lakkaa toimimasta odottamatta, anna \"Ohita akun optimointi\" -oikeus, jotta se pysyy käynnissä taustalla. Jos ongelma jatkuu, kokeile lisätä NLP digitox sallittujen luetteloon keskeytymättömän toiminnan varmistamiseksi.';

  @override
  String get whitelist_app_tile_title => 'Luettelo NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Anna NLP digitox:n käynnistyä automaattisesti.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Tämä laite ei tue automaattista käynnistyksen hallintaa.';

  @override
  String get database_tab_title => 'Tietokanta';

  @override
  String get import_db_tile_title => 'Tuo tietokanta';

  @override
  String get import_db_tile_subtitle => 'Tuo tietokanta tiedostosta.';

  @override
  String get export_db_tile_title => 'Vie tietokanta';

  @override
  String get export_db_tile_subtitle => 'Vie tietokanta tiedostoon.';

  @override
  String get analysis_tab_title => 'Analyysi';

  @override
  String get analysis_7_days => '7 päivää';

  @override
  String get analysis_30_days => '30 päivää';

  @override
  String get analysis_90_days => '90 päivää';

  @override
  String get analysis_screen_time_trend => 'Ruutuajan trendi';

  @override
  String get analysis_no_data_info =>
      'Tälle ajanjaksolle ei ole vielä tallennettu ruutuaikatietoja.';

  @override
  String get analysis_daily_average => 'Päivittäinen keskiarvo';

  @override
  String get analysis_total => 'Yhteensä';

  @override
  String get analysis_no_change => 'Sama kuin viime viikolla';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% vähemmän kuin viime viikolla';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% enemmän kuin viime viikolla';
  }

  @override
  String get crash_logs_heading => 'Törmäyslokit';

  @override
  String get crash_logs_info =>
      'Jos kohtaat ongelmia, voit ilmoittaa siitä GitHubissa lokitiedoston kanssa. Tiedosto sisältää tietoja, kuten laitteesi valmistajan, mallin, Android-version, SDK-version ja kaatumislokit. Nämä tiedot auttavat meitä tunnistamaan ja ratkaisemaan ongelman tehokkaammin.';

  @override
  String get crash_logs_export_tile_title => 'Vie kaatumislokit';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Vie kaatumislokit json-tiedostoon.';

  @override
  String get crash_logs_view_tile_title => 'Näytä lokit';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Tutustu tallennettuihin kaatumislokeihin.';

  @override
  String get crash_logs_empty_list_hint =>
      'Yhtään törmäystä ei ole kirjattu tähän mennessä.';

  @override
  String get crash_logs_clear_tile_title => 'Tyhjennä lokit';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Poista kaikki kaatumislokit tietokannasta.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Oletko varma, että haluat tyhjentää kaikki kaatumislokit tietokannasta?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'Selkeä joka tapauksessa';

  @override
  String get about_tab_title => 'Tietoja';

  @override
  String get changelog_tile_title => 'Muutosloki';

  @override
  String get changelog_tile_subtitle => 'Ota selvää, mitä uutta.';

  @override
  String get full_changelog_tile_title => 'Täysi muutosloki';

  @override
  String get redirected_to_github_subtitle => 'Sinut ohjataan GitHubiin.';

  @override
  String get contribute_heading => 'Osallistu';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Katso lähdekoodi.';

  @override
  String get report_issue_tile_title => 'Ilmoita ongelmasta';

  @override
  String get suggest_idea_tile_title => 'Ehdota ideaa';

  @override
  String get write_email_tile_title => 'Kirjoita meille sähköpostitse';

  @override
  String get write_email_tile_subtitle =>
      'Sinut ohjataan sähköpostisovellukseen.';

  @override
  String get privacy_policy_heading => 'Tietosuojakäytäntö';

  @override
  String get privacy_policy_info =>
      'NLP digitox on sitoutunut suojaamaan yksityisyyttäsi. Emme kerää, tallenna tai siirrä minkäänlaisia ​​käyttäjätietoja. Sovellus toimii täysin offline-tilassa eikä vaadi Internet-yhteyttä, mikä varmistaa, että henkilökohtaiset tietosi pysyvät yksityisinä ja turvassa laitteellasi. Ilmaisen ja avoimen lähdekoodin ohjelmiston (FOSS) sovelluksena NLP digitox takaa täydellisen läpinäkyvyyden ja käyttäjän hallinnan tietojensa suhteen.';

  @override
  String get more_details_button => 'Lisätietoja';
}
