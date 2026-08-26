// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get mindful_tagline => 'Arra összpontosíts, ami igazán számít';

  @override
  String get unlock_button_label => 'Oldja fel';

  @override
  String get permission_status_off => 'Ki';

  @override
  String get permission_status_allowed => 'Engedélyezett';

  @override
  String get permission_status_not_allowed => 'Nem engedélyezett';

  @override
  String get permission_button_grant_permission => 'Engedély megadása';

  @override
  String get permission_button_agree_and_continue => 'Egyetértek & Folytatás';

  @override
  String get permission_button_not_now => 'Most nem';

  @override
  String get permission_button_help => 'Segítség?';

  @override
  String get permission_sheet_privacy_info =>
      'A NLP digitox 100%-ban biztonságos, és offline is működik. Nem gyűjtünk és nem tárolunk személyes adatokat.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Kattintson a $button_label gombra.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Válassza a NLP digitox lehetőséget a következő képernyőn.';

  @override
  String get permission_grant_step_three =>
      '3. Kattintson és kapcsolja be a kapcsolót az alábbiak szerint.';

  @override
  String get permission_notification_title => 'Értesítések küldése';

  @override
  String get permission_alarms_title => 'Riasztások és emlékeztetők';

  @override
  String get permission_alarms_info =>
      'Kérjük, engedélyezze a riasztások és emlékeztetők beállítását. Ez lehetővé teszi a NLP digitox számára, hogy időben elindítsa lefekvésbeosztását, és minden nap éjfélkor alaphelyzetbe állítsa az alkalmazások időzítőit, és segít a pályán maradni.';

  @override
  String get permission_alarms_device_tile_label =>
      'Riasztások és emlékeztetők beállításának engedélyezése';

  @override
  String get permission_usage_title => 'Használati hozzáférés';

  @override
  String get permission_usage_info =>
      'Kérjük, adjon használati engedélyt. Ez lehetővé teszi a NLP digitox számára, hogy figyelemmel kísérje az alkalmazáshasználatot és kezelje a hozzáférést bizonyos alkalmazásokhoz, így fókuszáltabb és ellenőrzöttebb digitális környezetet biztosít.';

  @override
  String get permission_usage_device_tile_label =>
      'Engedélyezze a használati hozzáférést';

  @override
  String get permission_overlay_title => 'Display Overlay';

  @override
  String get permission_overlay_info =>
      'Kérjük, adja meg a megjelenítési fedvény engedélyét. Ez lehetővé teszi a NLP digitox számára, hogy fedvényt jelenítsen meg, amikor egy szüneteltetett alkalmazást megnyitnak, így segít koncentrálni és fenntartani az ütemtervet.';

  @override
  String get permission_overlay_device_tile_label =>
      'Megjelenítés engedélyezése más alkalmazások felett';

  @override
  String get permission_accessibility_title => 'Hozzáférhetőség';

  @override
  String get permission_accessibility_info =>
      'Kérjük, adjon hozzáférési engedélyt. Ez lehetővé teszi a NLP digitox számára, hogy korlátozza a hozzáférést a rövid formátumú videotartalmakhoz (pl. Reels, Shorts) a közösségimédia-alkalmazásokban és böngészőkben, és kiszűrje a nem megfelelő webhelyeket.';

  @override
  String get permission_accessibility_required =>
      'A NLP digitox akadálymentesítési engedélyt igényel a rövid tartalmak és webhelyek hatékony blokkolásához.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Használja a NLP digitox-t';

  @override
  String get permission_dnd_title => 'Ne zavarjon';

  @override
  String get permission_dnd_info =>
      'Kérjük, engedélyezze a Ne zavarjanak hozzáférést. Ez lehetővé teszi, hogy a NLP digitox elindítsa és leállítsa a Ne zavarjanak módot az alvásidő ütemezése alatt.';

  @override
  String get permission_dnd_tile_title => 'Indítsa el a DND-t';

  @override
  String get permission_dnd_tile_subtitle =>
      'Engedélyezze a Ne zavarjanak módot is.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Az akkumulátoroptimalizálás figyelmen kívül hagyása';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Már korlátlanul';

  @override
  String get permission_battery_optimization_status_disabled =>
      'A háttérkorlátozás letiltása';

  @override
  String get permission_battery_optimization_allow_info =>
      'Az „Akkumulátor-optimalizálás figyelmen kívül hagyása” engedélyezése bizonyos eszközökön automatikusan megadja a „Riasztások és emlékeztetők” engedélyt.';

  @override
  String get permission_vpn_title => 'VPN létrehozása';

  @override
  String get permission_vpn_info =>
      'Adjon engedélyt virtuális magánhálózati (VPN) kapcsolat létrehozására. Ez lehetővé teszi a NLP digitox számára, hogy az eszközön lévő helyi VPN létrehozásával korlátozza a kijelölt alkalmazások internet-hozzáférését.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Adminisztrátori jogosultságok csak az alapvető műveletekhez szükségesek, hogy biztosítsák az alkalmazás megfelelő működését és a hamisítás elleni védelmet.';

  @override
  String get permission_admin_snack_alert =>
      'A szabotázsvédelem csak a kiválasztott időintervallumban kapcsolható ki.';

  @override
  String get permission_notification_access_title => 'Értesítési hozzáférés';

  @override
  String get permission_notification_access_info =>
      'Kérjük, adjon hozzáférési engedélyt az értesítésekhez. Ez lehetővé teszi a NLP digitox számára, hogy rendszerezze az értesítéseket, és az Ön ütemezése szerint kézbesítse azokat.';

  @override
  String get permission_notification_access_required =>
      'A NLP digitox értesítési hozzáférést igényel a kötegelt és ütemezett értesítésekhez.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Az értesítésekhez való hozzáférés engedélyezése';

  @override
  String get day_today => 'Ma';

  @override
  String get day_yesterday => 'tegnap';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString nap',
      one: '1 napon',
      zero: '0 nap',
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
      other: '$countString óra',
      one: '1 óra',
      zero: '0 óra',
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
      other: '$countString perc',
      one: '1 perc',
      zero: '0 perc',
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
      other: '$countString másodperc',
      one: '1 másodperc',
      zero: '0 másodperc',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'és';

  @override
  String get timer_status_active => 'Aktív';

  @override
  String get timer_status_paused => 'Szüneteltetve';

  @override
  String get create_button => 'Létrehozása';

  @override
  String get update_button => 'Frissítés';

  @override
  String get dialog_button_cancel => 'Mégse';

  @override
  String get dialog_button_remove => 'Távolítsa el';

  @override
  String get dialog_button_set => 'Állítsa be';

  @override
  String get dialog_button_reset => 'Reset';

  @override
  String get dialog_button_infinite => 'Végtelen';

  @override
  String get schedule_start_label => 'Indítsa el';

  @override
  String get schedule_end_label => 'Vége';

  @override
  String get exit_without_saving_dialog_info =>
      'Biztos, hogy mentés nélkül szeretne kilépni?';

  @override
  String get development_dialog_info =>
      'A NLP digitox jelenleg fejlesztés alatt áll, és hibákat vagy hiányos funkciókat tartalmazhat. Ha bármilyen problémába ütközik, kérjük, jelentse azokat, hogy segítsen nekünk a fejlesztésben.\n\nKöszönjük visszajelzését!';

  @override
  String get development_dialog_button_report_issue => 'Probléma bejelentése';

  @override
  String get development_dialog_button_close => 'Bezárás';

  @override
  String get dnd_settings_tile_title => 'Ne zavarjanak beállítások';

  @override
  String get dnd_settings_tile_subtitle =>
      'Kezelheti, hogy mely alkalmazások és értesítések érhetnek el Önt a DND-ben.';

  @override
  String get quick_actions_heading => 'Gyors cselekvések';

  @override
  String get select_distracting_apps_heading =>
      'Válasszon zavaró alkalmazásokat';

  @override
  String get your_distracting_apps_heading => 'Az Ön zavaró alkalmazásai';

  @override
  String get select_more_apps_heading => 'Válasszon több alkalmazást';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Fontos rendszeralkalmazások hozzáadása a zavaró alkalmazások listájához nem megengedett.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'A képernyőhasználat és a korlátozások nem érhetők el ehhez az alkalmazáshoz. Jelenleg csak a hálózati használat érhető el';

  @override
  String get create_group_fab_button => 'Csoport létrehozása';

  @override
  String get active_period_info =>
      'Állítson be egy időtartamot, amely alatt a hozzáférés engedélyezett. Ezen az időn kívül a hozzáférés korlátozott lesz.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Válasszon ki legalább egy zavaró alkalmazást.';

  @override
  String get donation_card_title => 'Támogass minket';

  @override
  String get donation_card_info =>
      'A NLP digitox ingyenes és nyílt forráskódú, amelyet hónapokig tartó odaadással fejlesztettek ki. Ha segített neked, adományod a világot jelentené számunkra. Minden hozzájárulás segít abban, hogy továbbra is javítsuk és fenntartsuk azt mindenki számára.';

  @override
  String get operation_failed_snack_alert =>
      'A művelet nem sikerült, valami elromlott!';

  @override
  String get donation_card_button_donate => 'Adományozni';

  @override
  String get app_restart_dialog_title => 'Újraindítás szükséges';

  @override
  String get app_restart_dialog_info =>
      'A NLP digitox automatikusan újraindul, amint a visszaszámlálás véget ért. Kérjük, legyen türelemmel, mivel a változások hatályba lépnek.';

  @override
  String get accessibility_tip =>
      'Intelligensebb, akkumulátorbarátabb blokkolást szeretne? Kisegítő lehetőségek engedélyezése a NLP digitox számára.';

  @override
  String get battery_optimization_tip =>
      'A NLP digitox nem működik? A zökkenőmentes működés érdekében engedélyezze az „Akkumulátor-optimalizálás figyelmen kívül hagyása” lehetőséget a Beállításokban.';

  @override
  String get invincible_mode_tip =>
      'Véletlenül megszüntették a korlátozásokat? Az Invincible Mode használatával zárolhatja őket a következő napig vagy a beállítási ablakig.';

  @override
  String get glance_usage_tip =>
      'Betekintést szeretne? Tekintse meg a Pillantás részt a használati szokások és a képernyő előtt töltött idő megtekintéséhez.';

  @override
  String get tamper_protection_tip =>
      'Eltávolítja a NLP digitox-t? Engedélyezze az Eltávolítás ablakot a szabotázsvédelem biztonságos letiltásához.';

  @override
  String get notification_blocking_tip =>
      'Szeretné csökkenteni a zavaró tényezőket? Használja az Értesítések blokkolását a kiválasztott alkalmazások elnémításához.';

  @override
  String get usage_history_tip =>
      'Szeretnél átgondolni a szokásaidat? A múltbeli minták megtekintéséhez ellenőrizze a Használati előzményeket.';

  @override
  String get focus_mode_tip =>
      'Mély összpontosításra van szüksége? Kapcsolja be a Fókusz módot az alkalmazások és értesítések blokkolásához feladatok közben.';

  @override
  String get bedtime_reminder_tip =>
      'Szeretné javítani az alvását? Állítson be éjszakai lefekvésidő-emlékeztetőt.';

  @override
  String get custom_blocking_tip =>
      'Egyedi élményre van szüksége? Hozzon létre az Ön igényeinek megfelelő alkalmazásblokkolási szabályokat.';

  @override
  String get session_timeline_tip =>
      'Szeretné nyomon követni a fókusz üléseket? Tekintse meg az idővonalat a fókuszút megtekintéséhez.';

  @override
  String get short_content_blocking_tip =>
      'Elterelték a figyelmet a közösségi alkalmazások? Tiltsa le a rövid tartalmakat az Instagramon, a YouTube-on stb., hogy összpontosítson.';

  @override
  String get parental_controls_tip =>
      'Szülői felügyeletre van szüksége? Állítson be korlátozásokat gyermeke eszközére a biztonságos élmény érdekében.';

  @override
  String get notification_batching_tip =>
      'Szeretné csökkenteni a zavaró tényezőket? Az értesítések csoportosításával csoportosíthatja az értesítéseket, és egyszerre ellenőrizheti őket.';

  @override
  String get notification_scheduling_tip =>
      'Értesítéseket kell kezelnie? Ütemezze be, amikor értesítéseket kap bizonyos alkalmazásokról.';

  @override
  String get quick_focus_tile_tip =>
      'Gyors hozzáférésre van szüksége a fókuszáláshoz? Adjon hozzá egy gyorsfókuszlapkát a fókusz mód azonnali aktiválásához.';

  @override
  String get app_shortcuts_tip =>
      'Azonnali alkalmazás-hozzáférést szeretne? Parancsikonokat adhat hozzá az alkalmazás ikonjának hosszú megnyomásával a gyors műveletekhez.';

  @override
  String get backup_usage_db_tip =>
      'Szeretné menteni az adatait? Készítsen biztonsági másolatot használati adatbázisáról, hogy adatai biztonságban legyenek.';

  @override
  String get dynamic_material_color_tip =>
      'Egyedi témát szeretne? Dinamikus anyag engedélyezése Az Ön színe az eszköz témájának megfelelően.';

  @override
  String get amoled_dark_theme_tip =>
      'Szeretne kímélni az akkumulátort? Az AMOLED sötét témával csökkentheti az energiafogyasztást az OLED képernyőkön.';

  @override
  String get customize_usage_history_tip =>
      'Szeretné megőrizni a használati előzményeket? Testreszabhatja, hogy hány hét adatot tároljon a Használati előzményekben.';

  @override
  String get grouped_apps_blocking_tip =>
      'Együtt szeretnél blokkolni az alkalmazásokat? A Korlátozási csoportok használatával csoportosíthatja az alkalmazáskorlátokat, és egyszerre több alkalmazást is blokkolhat.';

  @override
  String get websites_blocking_tip =>
      'Tisztább böngészési élményt szeretne? Blokkolja az egyéni vagy NSFW webhelyeket a koncentráltabb online idő érdekében.';

  @override
  String get data_usage_tip =>
      'Szeretné nyomon követni adatait? Kövesse nyomon mobil- és Wi-Fi-adathasználatát az internetfogyasztáshoz.';

  @override
  String get block_internet_tip =>
      'Le kell tiltania egy alkalmazás internetkapcsolatát? Az alkalmazás irányítópultjáról egy adott alkalmazáshoz kapcsolja ki az internetet.';

  @override
  String get emergency_passes_tip =>
      'Kell egy kis szünet? Használjon napi 3 vészhelyzeti bérletet az alkalmazások blokkolásának ideiglenes feloldásához 5 percre.';

  @override
  String get onboarding_skip_btn_label => 'Kihagyás';

  @override
  String get onboarding_finish_setup_btn_label => 'Beállítás befejezése';

  @override
  String get onboarding_page_welcome_title =>
      'Üdvözlünk az NLP digitox alkalmazásban.';

  @override
  String get onboarding_page_welcome_info =>
      'Vedd kézbe a digitális életed, és alakíts ki egészségesebb képernyőhasználati szokásokat. Az NLP digitox segít összpontosítva maradni, csökkenteni a zavaró tényezőket, és minden nap tudatos döntéseket hozni.';

  @override
  String get onboarding_page_statistics_title => 'Ismerd meg a szokásaidat.';

  @override
  String get onboarding_page_statistics_info =>
      'Értsd meg digitális szokásmintáidat a képernyőidőről, az alkalmazáshasználatról és a fókusz-trendekről szóló részletes adatokkal. Kövesd a fejlődésed, és lásd, hogyan vezetnek a kis változások nagy javulásokhoz.';

  @override
  String get onboarding_page_one_title => 'Mester fókusz.';

  @override
  String get onboarding_page_one_info =>
      'Szüneteltesse a zavaró alkalmazásokat, blokkolja a rövid tartalmat, és maradjon a pályán a testreszabható fókuszmunkamenetekkel. Akár dolgozik, akár tanul, akár pihen, a NLP digitox segít kézben tartani az irányítást.';

  @override
  String get onboarding_page_two_title => 'Blokkolja a zavaró tényezőket.';

  @override
  String get onboarding_page_two_info =>
      'Állítson be használati korlátokat, automatikusan szüneteltesse az alkalmazásokat, és alakítson ki egészségesebb digitális szokásokat. Használja a Lefekvés módot a kikapcsolódáshoz, és élvezze a zavaró éjszakai kikapcsolódást.';

  @override
  String get onboarding_page_three_title => 'Első az adatvédelem.';

  @override
  String get onboarding_page_three_info =>
      'A NLP digitox 100%-ban nyílt forráskódú, és teljesen offline módban működik. Nem gyűjtjük és nem osztjuk meg személyes adatait – az Ön adatainak védelme minden módon garantált.';

  @override
  String get onboarding_page_permissions_title => 'Alapvető engedélyek.';

  @override
  String get onboarding_page_permissions_info =>
      'A NLP digitox alapvető engedélyeket követel a képernyőidő nyomon követéséhez és kezeléséhez, ami segít csökkenteni a zavaró tényezőket és javítani a fókuszt.';

  @override
  String get dashboard_tab_title => 'Irányítópult';

  @override
  String get focus_now_fab_button => 'Most koncentrálj';

  @override
  String get welcome_greetings => 'Isten hozott vissza,';

  @override
  String get username_snack_alert =>
      'A felhasználónév szerkesztéséhez nyomja meg hosszan.';

  @override
  String get username_dialog_title => 'Felhasználónév';

  @override
  String get username_dialog_info =>
      'Adja meg felhasználónevét, amely megjelenik az irányítópulton.';

  @override
  String get username_dialog_button_apply => 'Alkalmazni';

  @override
  String get glance_tile_title => 'Pillantás';

  @override
  String get glance_tile_subtitle =>
      'Vessen egy gyors pillantást a használatára.';

  @override
  String get parental_controls_tile_subtitle =>
      'Legyőzhetetlen üzemmód és szabotázsvédelem.';

  @override
  String get restrictions_heading => 'Korlátozások';

  @override
  String get apps_blocking_tile_title => 'Alkalmazások blokkolása';

  @override
  String get apps_blocking_tile_subtitle =>
      'Korlátozza az alkalmazásokat többféleképpen.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Csoportosított alkalmazások blokkolása';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Alkalmazások egyidejű korlátozása.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Korlátozza a rövid tartalmat több platformon.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Korlátozza a felnőtteknek szóló és egyéni webhelyeket.';

  @override
  String get screen_time_label => 'Képernyőidő';

  @override
  String get total_data_label => 'Összes adat';

  @override
  String get mobile_data_label => 'Mobil adatok';

  @override
  String get wifi_data_label => 'Wifi adat';

  @override
  String get focus_today_label => 'Koncentrálj a mai napra';

  @override
  String get focus_weekly_label => 'Hetente fókuszálj';

  @override
  String get focus_monthly_label => 'Fókuszban havonta';

  @override
  String get focus_lifetime_label => 'Fókuszban az élettartam';

  @override
  String get longest_streak_label => 'Leghosszabb sorozat';

  @override
  String get current_streak_label => 'Aktuális sorozat';

  @override
  String get successful_sessions_label => 'Sikeres ülések';

  @override
  String get failed_sessions_label => 'Sikertelen munkamenetek';

  @override
  String get statistics_tab_title => 'Statisztika';

  @override
  String get screen_segment_label => 'Képernyő';

  @override
  String get data_segment_label => 'Adatok';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Leggyakrabban használt alkalmazások';

  @override
  String get show_all_apps_tile_title => 'Az összes alkalmazás megjelenítése';

  @override
  String get search_apps_hint => 'Alkalmazások keresése...';

  @override
  String get notifications_tab_title => 'Értesítések';

  @override
  String get notifications_tab_info =>
      'Kötegelt értesítések az alkalmazásokból, és beállíthat menetrendeket, például reggel, délben, este és éjszaka. Legyen naprakész folyamatos megszakítások nélkül.';

  @override
  String get batched_apps_tile_title => 'Kötegelt alkalmazások';

  @override
  String get batch_recap_dropdown_title => 'Köteg-összefoglaló típus';

  @override
  String get batch_recap_dropdown_info =>
      'Válassza ki, hogy mit szeretne leküldeni egy ütemezés aktiválásakor – az összes értesítést vagy csak egy összefoglalót.';

  @override
  String get batch_recap_option_summery_only => 'Csak összefoglaló';

  @override
  String get batch_recap_option_all_notifications => 'Minden értesítés';

  @override
  String get notification_history_tile_title => 'Értesítési előzmények';

  @override
  String get store_all_tile_title => 'Tárolja az összes értesítést';

  @override
  String get store_all_tile_subtitle =>
      'Mentse el a nem kötegelt értesítéseket is.';

  @override
  String get schedules_heading => 'Menetrendek';

  @override
  String get new_schedule_fab_button => 'Új ütemterv';

  @override
  String get new_schedule_dialog_info =>
      'Adjon meg egy nevet az értesítési ütemezésnek, hogy megkönnyítse az azonosítást.';

  @override
  String get new_schedule_dialog_field_label => 'Ütemezés neve';

  @override
  String get bedtime_tab_title => 'Lefekvés';

  @override
  String get bedtime_tab_info =>
      'Állítsa be az alvásidő ütemezését az időszak és a hét napjainak kiválasztásával. Válasszon zavaró alkalmazásokat a blokkoláshoz, és engedélyezze a Ne zavarjanak (DND) módot a békés éjszaka érdekében.';

  @override
  String get schedule_tile_title => 'Ütemezés';

  @override
  String get schedule_tile_subtitle =>
      'A napi ütemezés engedélyezése vagy letiltása.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Válasszon ki legalább egy napot a hétből.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'A lefekvés teljes időtartamának legalább 30 percnek kell lennie.';

  @override
  String get distracting_apps_tile_title => 'Zavaró alkalmazások';

  @override
  String get distracting_apps_tile_subtitle =>
      'Válassza ki, mely alkalmazások vonják el a figyelmét a lefekvés előtti rutinról.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'A figyelemelterelő alkalmazások listájának módosítása nem engedélyezett, amíg az alvásidő aktív.';

  @override
  String get parental_controls_tab_title => 'Szülői felügyelet';

  @override
  String get invincible_mode_heading => 'Legyőzhetetlen mód';

  @override
  String get invincible_mode_tile_title => 'Aktiválja a legyőzhetetlen módot';

  @override
  String get invincible_mode_info =>
      'Ha a Legyőzhetetlen mód be van kapcsolva, a napi kvóta elérése után nem tudja módosítani a kiválasztott korlátokat. A kiválasztott 10 perces legyőzhetetlen ablakon belül azonban módosíthat.';

  @override
  String get invincible_mode_snack_alert =>
      'A legyőzhetetlen mód miatt a korlátozások módosítása nem megengedett.';

  @override
  String get invincible_mode_dialog_info =>
      'Teljesen biztos benne, hogy engedélyezi a Legyőzhetetlen módot? Ez a művelet visszafordíthatatlan. Az Invincible Mode bekapcsolása után nem kapcsolhatja ki mindaddig, amíg ez az alkalmazás telepítve van az eszközén.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Az Invincible Mode nem kapcsolható ki mindaddig, amíg ez az alkalmazás telepítve marad az eszközén.';

  @override
  String get invincible_mode_dialog_button_start_anyway =>
      'Mindenképpen kezdje el';

  @override
  String get invincible_mode_include_timer_tile_title =>
      'Tartalmazza az időzítőt';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Tartalmazza az indítási korlátot';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Aktív időszak szerepeltetése';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Alkalmazáskorlátozások';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'A napi korlátok túllépése után megakadályozza az alkalmazás kiválasztott korlátozásainak módosítását.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Csoportkorlátozások';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'A napi limitek túllépése után megakadályozza a csoport kiválasztott korlátozásainak módosítását.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Tartalmazza a rövidnadrág időzítőt';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Megakadályozza a napi rövidnadrágok korlátjának elérése utáni változásokat.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Tartalmazza a lefekvés idejét';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Megakadályozza a változásokat az aktív lefekvés ütemezése közben.';

  @override
  String get protected_access_tile_title => 'Védett hozzáférés';

  @override
  String get protected_access_tile_subtitle =>
      'Védje a NLP digitox-t az eszközzárral.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'A funkció engedélyezéséhez először állítson be biometrikus zárat eszközén.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Az eszköz zárolása eltávolítva. A folytatáshoz állítson be új zárat.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'A hitelesítés nem sikerült. A folytatáshoz igazolnia kell az eszköz zárolását.';

  @override
  String get tamper_protection_tile_title => 'Szabotázs elleni védelem';

  @override
  String get tamper_protection_tile_subtitle =>
      'Akadályozza meg az eltávolítást, és kényszerítse le az alkalmazást.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Ha engedélyezve van, nem tudja eltávolítani, kényszeríteni leállítani vagy törölni a NLP digitox adatait, kivéve a kiválasztott eltávolítási ablakban. Nincsenek megoldások.\n\nSaját felelősségére folytassa.';

  @override
  String get uninstall_window_tile_title => 'Az ablak eltávolítása';

  @override
  String get uninstall_window_tile_subtitle =>
      'A szabotázs elleni védelem a kiválasztott időponttól számított 10 percen belül kikapcsolható.';

  @override
  String get invincible_window_tile_title => 'Legyőzhetetlen ablak';

  @override
  String get invincible_window_tile_subtitle =>
      'A kiválasztott határértékek a kiválasztott időponttól számított 10 percen belül módosíthatók.';

  @override
  String get shorts_blocking_tab_title => 'Rövidnadrág blokkolás';

  @override
  String get shorts_blocking_tab_info =>
      'Szabályozhatja, hogy mennyi időt tölt rövid tartalmakkal olyan platformokon, mint az Instagram, a YouTube, a Snapchat és a Facebook, beleértve a webhelyeiket is.';

  @override
  String get short_content_heading => 'Rövid tartalom';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Balra a $timeShortString-ból';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Állítson be napi időkorlátot a rövid tartalomhoz. Ha eléri a korlátot, a rövid tartalom éjfélig szünetel.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Korlátozza a funkciókat az Instagramon.';

  @override
  String get instagram_features_block_reels =>
      'A tekercsek szakasz korlátozása.';

  @override
  String get instagram_features_block_explore =>
      'A felfedezés szakasz korlátozása.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Korlátozza a snapchat funkciókat.';

  @override
  String get snapchat_features_block_spotlight =>
      'A reflektorok szakaszának korlátozása.';

  @override
  String get snapchat_features_block_discover =>
      'Felfedezési szakasz korlátozása.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Korlátozza a rövidnadrágokat a youtube-on.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Korlátozza a tekercseket a Facebookon.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle =>
      'Korlátozza a rövidnadrágot a redditen.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Videofeed korlátozása X-en.';

  @override
  String get threads_features_tile_title => 'Szálak';

  @override
  String get threads_features_tile_subtitle =>
      'Korlátozza a videókat/tekercseket a szálakon.';

  @override
  String get websites_blocking_tab_title => 'Weboldalak blokkolása';

  @override
  String get websites_blocking_tab_info =>
      'Blokkolja a felnőtteknek szánt webhelyeket és az Ön által választott egyéni webhelyeket, hogy biztonságosabb és célzottabb online élményt teremtsen. Vedd kezedbe a böngészést, és ne tereld el a figyelmed.';

  @override
  String get adult_content_heading => 'Felnőtt tartalom';

  @override
  String get block_nsfw_title => 'Nsfw blokkolása';

  @override
  String get block_nsfw_subtitle =>
      'Korlátozza a böngészőket a felnőtteknek szóló és pornówebhelyek megnyitásában.';

  @override
  String get block_nsfw_dialog_info =>
      'Biztos vagy benne? Ez a művelet visszafordíthatatlan. Ha a felnőtt webhelyek blokkolása be van kapcsolva, nem kapcsolhatja KI, amíg ez az alkalmazás telepítve van az eszközén.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Mindenképpen blokkolja';

  @override
  String get blocked_websites_heading => 'Letiltott webhelyek';

  @override
  String get blocked_websites_empty_list_hint =>
      'Kattintson a „+ Webhely hozzáadása” gombra, ha olyan zavaró webhelyeket szeretne hozzáadni, amelyeket blokkolni szeretne.';

  @override
  String get add_website_fab_button => 'Webhely hozzáadása';

  @override
  String get add_website_dialog_title => 'Zavaró weboldal';

  @override
  String get add_website_dialog_info =>
      'Adja meg a blokkolni kívánt webhely URL-jét.';

  @override
  String get add_website_dialog_is_nsfw => 'Az nsfw oldal?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Figyelmeztetés: Az Nsfw webhelyek hozzáadása után nem távolíthatók el.';

  @override
  String get add_website_dialog_button_block => 'Blokk';

  @override
  String get add_website_already_exist_snack_alert =>
      'Az URL már felkerült a blokkolt webhelyek listájára.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Érvénytelen URL! Nem sikerült elemezni a gazdagép nevét.';

  @override
  String get remove_website_dialog_title => 'Webhely eltávolítása';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Biztos vagy benne? szeretné eltávolítani a „$websitehost” elemet a blokkolt webhelyekről.';
  }

  @override
  String get focus_tab_title => 'Fókusz';

  @override
  String get focus_tab_info =>
      'Ha időre van szüksége az összpontosításhoz, kezdjen új munkamenetet a típus kiválasztásával, a zavaró alkalmazások szüneteltetésével, és a Ne zavarjanak funkció engedélyezésével a zavartalan koncentráció érdekében.';

  @override
  String get active_session_card_title => 'Aktív munkamenet';

  @override
  String get active_session_card_info =>
      'Aktív fókuszmunka fut! Kattintson a \"Nézet\" gombra, hogy ellenőrizze a folyamatot, és megtudja, mennyi idő telt el.';

  @override
  String get active_session_card_view_button => 'Megtekintés';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Az alkalmazások eltávolítása a figyelemelterelő alkalmazások listájáról nem engedélyezett, amíg a Fókusz munkamenet aktív. Ez idő alatt azonban további alkalmazásokat is hozzáadhat a listához.';

  @override
  String get focus_profile_tile_title => 'Fókusz profil';

  @override
  String get focus_session_duration_tile_title => 'A munkamenet időtartama';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Végtelen (hacsak meg nem állsz)';

  @override
  String get focus_session_duration_dialog_info =>
      'Kérjük, válassza ki ennek a fókuszálásnak a kívánt időtartamát, és határozza meg, mennyi ideig szeretne koncentrálni és zavartalanul maradni.';

  @override
  String get focus_profile_customization_tile_title => 'Profil testreszabása';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'A kiválasztott profil beállításainak testreszabása.';

  @override
  String get focus_enforce_tile_title => 'Munkamenet végrehajtása';

  @override
  String get focus_enforce_tile_subtitle =>
      'Megakadályozza a munkamenet befejezését az idő lejárta előtt.';

  @override
  String get focus_session_start_button => 'Csúsztass az ülés indításához';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Válasszon ki legalább egy zavaró alkalmazást a fókuszálás elindításához';

  @override
  String get focus_session_already_active_snack_alert =>
      'Már fut egy aktív fókuszálási munkamenet. Kérjük, fejezze be vagy állítsa le a jelenlegi munkamenetet, mielőtt újat kezdene.';

  @override
  String get focus_session_type_study => 'Tanulmány';

  @override
  String get focus_session_type_work => 'Munka';

  @override
  String get focus_session_type_exercise => 'Gyakorlat';

  @override
  String get focus_session_type_meditation => 'Meditáció';

  @override
  String get focus_session_type_creativeWriting => 'Kreatív írás';

  @override
  String get focus_session_type_reading => 'Olvasás';

  @override
  String get focus_session_type_programming => 'Programozás';

  @override
  String get focus_session_type_chores => 'Házimunkák';

  @override
  String get focus_session_type_projectPlanning => 'Projekt tervezés';

  @override
  String get focus_session_type_artAndDesign => 'Művészet és Design';

  @override
  String get focus_session_type_languageLearning => 'Nyelvtanulás';

  @override
  String get focus_session_type_musicPractice => 'Zenei gyakorlat';

  @override
  String get focus_session_type_selfCare => 'Öngondoskodás';

  @override
  String get focus_session_type_brainstorming => 'Ötletbörze';

  @override
  String get focus_session_type_skillDevelopment => 'Képességfejlesztés';

  @override
  String get focus_session_type_research => 'Kutatás';

  @override
  String get focus_session_type_networking => 'Hálózatépítés';

  @override
  String get focus_session_type_cooking => 'Főzés';

  @override
  String get focus_session_type_sportsTraining => 'Sport Edzés';

  @override
  String get focus_session_type_restAndRelaxation => 'Pihenés és relaxáció';

  @override
  String get focus_session_type_other => 'Egyéb';

  @override
  String get timeline_tab_title => 'Idővonal';

  @override
  String get focus_timeline_tab_info =>
      'Fedezze fel a fókuszútját úgy, hogy kiválaszt egy dátumot a naptárból. Kövesse nyomon fejlődését, tekintse át újra a sikereit, és tanuljon a kihívásokból.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Az Ön teljes termelési ideje a kiválasztott hónapban $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Termékeny napok';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Összesen $daysCount eredményes napja volt a kiválasztott hónapban.';
  }

  @override
  String get selected_day_focused_time_label => 'Fókuszált idő';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Az Ön teljes fókuszálási ideje a kiválasztott napon $timeString.';
  }

  @override
  String get calender_heading => 'Naptár';

  @override
  String get your_sessions_heading => 'Az üléseid';

  @override
  String get your_sessions_empty_list_hint =>
      'A kiválasztott napon nem rögzítettek fókuszmunkameneteket.';

  @override
  String get focus_session_tile_timestamp_label => 'Időbélyeg';

  @override
  String get focus_session_tile_duration_label => 'Időtartam';

  @override
  String get focus_session_tile_reflection_label => 'Reflexió';

  @override
  String get focus_session_state_active => 'Aktív';

  @override
  String get focus_session_state_successful => 'Sikeres';

  @override
  String get focus_session_state_failed => 'Sikertelen';

  @override
  String get active_session_tab_title => 'Munkamenet';

  @override
  String get active_session_none_warning =>
      'Nem található aktív munkamenet. Visszatérés a kezdőképernyőre.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Nyomd tovább';

  @override
  String get active_session_finish_dialog_title => 'Befejezés';

  @override
  String get active_session_finish_dialog_info =>
      'Maradj erős! Értékes fókuszt építesz. Biztosan befejezi ezt a fókuszálási munkamenetet? Minden extra pillanat számít a céljaid elérésében.';

  @override
  String get active_session_giveup_dialog_title => 'Add fel';

  @override
  String get active_session_giveup_dialog_info =>
      'Tarts ki! Már majdnem ott vagy, ne add fel! Biztos benne, hogy korábban szeretné befejezni ezt a fókuszmenetet? A haladás elveszik.';

  @override
  String get active_session_reflection_dialog_title => 'Session reflexió';

  @override
  String get active_session_reflection_dialog_info =>
      'Szánj egy percet, hogy elgondolkodj a fejlődéseden. Mi a célod ezzel az üléssel? Mit értél el ezen a foglalkozáson?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tipp: Ezt később bármikor szerkesztheti a munkamenet idővonalán.';

  @override
  String get active_session_giveup_snack_alert =>
      'Feladtad! Ne aggódj, legközelebb jobban csinálod. Minden erőfeszítés számít – csak folytasd';

  @override
  String get active_session_quote_one =>
      'Minden lépés számít, maradj erős és menj tovább';

  @override
  String get active_session_quote_two =>
      'Maradj koncentrált! elképesztő fejlődést érsz el';

  @override
  String get active_session_quote_three => 'Összetöröd! Tartsd a lendületet';

  @override
  String get active_session_quote_four =>
      'Már csak egy kicsit van hátra, fantasztikusan csinálod';

  @override
  String active_session_quote_five(String durationString) {
    return 'Gratulálunk 🎉 \n Befejezte a $durationString.\n\n remek munka, csak így tovább';
  }

  @override
  String get restriction_groups_tab_title => 'Korlátozó csoportok';

  @override
  String get restriction_groups_tab_info =>
      'Állítson be kombinált képernyőidő-korlátot az alkalmazások egy csoportjához. Amint a teljes használat eléri a korlátot, a csoportban lévő összes alkalmazás szünetel, hogy segítsen fenntartani a fókuszt és az egyensúlyt.';

  @override
  String get restriction_group_time_spent_label => 'Ma eltöltött idő';

  @override
  String get restriction_group_time_left_label => 'Ma maradt idő';

  @override
  String get restriction_group_name_tile_title => 'Csoport neve';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Adjon meg egy nevet a korlátozási csoportnak, hogy könnyebben azonosíthassa és kezelje.';

  @override
  String get restriction_group_timer_tile_title => 'Csoport időzítő';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Állítson be napi időkorlátot ehhez a csoporthoz. Amint eléri a korlátot, a csoport összes alkalmazása éjfélig szünetel.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Csoportos aktív időszak';

  @override
  String get remove_restriction_group_dialog_title => 'Csoport eltávolítása';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Biztos vagy benne? el szeretné távolítani a \'$groupName\'-t a korlátozási csoportokból.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Állítson be időzítőt vagy aktív időszakkorlátot.';

  @override
  String get notifications_empty_list_hint =>
      'Aznap nem küldtek értesítéseket.';

  @override
  String get conversations_label => 'Beszélgetések';

  @override
  String get last_24_hours_heading => 'Az elmúlt 24 óra';

  @override
  String get notification_timeline_tab_info =>
      'Böngésszen az értesítési előzmények között úgy, hogy kiválaszt egy dátumot a naptárból. Tekintse meg, mely alkalmazások ragadták meg a figyelmét, és gondolja át digitális szokásait.';

  @override
  String get monthly_label => 'Havonta';

  @override
  String get daily_label => 'Naponta';

  @override
  String get search_notifications_sheet_info =>
      'Könnyen megtalálhatja a korábbi értesítéseket, ha a címükben vagy tartalmukban keres. Segít gyorsan megtalálni a fontos figyelmeztetéseket.';

  @override
  String get search_notifications_hint => 'Értesítések keresése...';

  @override
  String get search_notifications_empty_list_hint =>
      'Nem található a keresésnek megfelelő értesítés.';

  @override
  String get app_info_none_warning =>
      'Nem található az adott csomaghoz tartozó alkalmazás. Visszatérés a kezdőképernyőre.';

  @override
  String get emergency_fab_button => 'Vészhelyzet';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Ez a művelet szünetelteti az alkalmazásblokkolót a következő 5 percre. Még $leftPassesCount bérletei vannak. Az összes bérlet felhasználása után az alkalmazás éjfélig blokkolva marad, vagy az aktív fókusz munkamenet véget ér.\n\nTovábbra is folytatja?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Mindenképpen használd';

  @override
  String get emergency_started_snack_alert =>
      'Az alkalmazásblokkoló szünetel, és 5 perc múlva folytatja a blokkolást.';

  @override
  String get emergency_already_active_snack_alert =>
      'Az alkalmazásblokkoló jelenleg szünetel, vagy inaktív. Ha az értesítések engedélyezve vannak, frissítéseket fog kapni a hátralévő időről.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Felhasználta az összes vészhelyzeti bérletét. A blokkolt alkalmazások blokkolva maradnak éjfélig, vagy az aktív fókusz munkamenet végéig.';

  @override
  String get app_limit_status_not_set => 'Nincs beállítva';

  @override
  String get app_timer_tile_title => 'Alkalmazás időzítő';

  @override
  String get app_timer_picker_dialog_info =>
      'Állítson be napi időkorlátot ehhez az alkalmazáshoz. Ha eléri a korlátot, az alkalmazás éjfélig szünetel.';

  @override
  String get usage_reminders_tile_title => 'Használati emlékeztetők';

  @override
  String get usage_reminders_tile_subtitle =>
      'Gyengéd lökések időzített alkalmazások használatakor.';

  @override
  String get app_launch_limit_tile_title => 'Indítási korlát';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'A mai napon megjelent $count alkalommal.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Állítsa be, hogy naponta hányszor nyithatja meg ezt az alkalmazást. A limit elérése után éjfélig szünetel.';

  @override
  String get app_active_period_tile_title => 'Aktív időszak';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return '$startTime-tól $endTime-ig';
  }

  @override
  String get internet_access_tile_title => 'Internet hozzáférés';

  @override
  String get internet_access_tile_subtitle =>
      'Kapcsolja ki az alkalmazás internetes blokkolásához.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'A $appName internetje le van tiltva.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'A $appName internetje fel van oldva.';
  }

  @override
  String get launch_app_tile_title => 'Indítsa el az alkalmazást';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Nyissa meg a $appName-t.';
  }

  @override
  String get go_to_app_settings_tile_title =>
      'Nyissa meg az alkalmazás beállításait';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Kezelje az alkalmazásbeállításokat, például az értesítéseket, engedélyeket, tárhelyet és egyebeket.';

  @override
  String get include_in_stats_tile_title => 'Beleértve a képernyőhasználatba';

  @override
  String get include_in_stats_tile_subtitle =>
      'Kapcsolja ki, hogy kizárja ezt az alkalmazást a teljes képernyőhasználatból.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return 'A $appName ki van zárva a teljes képernyőhasználatból.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return 'A $appName a teljes képernyőhasználatba beletartozik.';
  }

  @override
  String get general_tab_title => 'tábornok';

  @override
  String get appearance_heading => 'Megjelenés';

  @override
  String get theme_mode_tile_title => 'Téma mód';

  @override
  String get theme_mode_system_label => 'Rendszer';

  @override
  String get theme_mode_light_label => 'Fény';

  @override
  String get theme_mode_dark_label => 'Sötét';

  @override
  String get material_color_tile_title => 'Anyag színe';

  @override
  String get amoled_dark_tile_title => 'AMOLED sötét';

  @override
  String get amoled_dark_tile_subtitle =>
      'Használjon tiszta fekete színt a sötét témához.';

  @override
  String get dynamic_colors_tile_title => 'Dinamikus színek';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Ha támogatott, használja az eszköz színeit.';

  @override
  String get defaults_heading => 'Alapértelmezések';

  @override
  String get app_language_tile_title => 'Alkalmazás nyelve';

  @override
  String get default_home_tab_tile_title => 'Kezdőlap lapon';

  @override
  String get usage_history_tile_title => 'Használati előzmények';

  @override
  String get usage_history_15_days => '15 nap';

  @override
  String get usage_history_1_month => '1 hónap';

  @override
  String get usage_history_3_month => '3 hónap';

  @override
  String get usage_history_6_month => '6 hónap';

  @override
  String get usage_history_1_year => '1 év';

  @override
  String get service_heading => 'Szolgáltatás';

  @override
  String get service_stopping_warning =>
      'Ha a NLP digitox váratlanul leáll, adja meg az „Akkumulátoroptimalizálás figyelmen kívül hagyása” engedélyt, hogy a háttérben futhasson. Ha a probléma továbbra is fennáll, próbálkozzon a NLP digitox engedélyezési listával a megszakítás nélküli teljesítmény érdekében.';

  @override
  String get whitelist_app_tile_title => 'A NLP digitox engedélyezési listája';

  @override
  String get whitelist_app_tile_subtitle =>
      'Engedélyezze a NLP digitox automatikus elindulását.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Ez az eszköz nem támogatja az automatikus indításkezelést.';

  @override
  String get database_tab_title => 'Adatbázis';

  @override
  String get import_db_tile_title => 'Adatbázis importálása';

  @override
  String get import_db_tile_subtitle => 'Adatbázis importálása fájlból.';

  @override
  String get export_db_tile_title => 'Adatbázis exportálása';

  @override
  String get export_db_tile_subtitle => 'Adatbázis exportálása fájlba.';

  @override
  String get analysis_tab_title => 'Elemzés';

  @override
  String get analysis_7_days => '7 nap';

  @override
  String get analysis_30_days => '30 nap';

  @override
  String get analysis_90_days => '90 nap';

  @override
  String get analysis_screen_time_trend => 'Képernyőidő-trend';

  @override
  String get analysis_no_data_info =>
      'Ehhez az időszakhoz még nincs rögzített képernyőidő-adat.';

  @override
  String get analysis_daily_average => 'Napi átlag';

  @override
  String get analysis_total => 'Összesen';

  @override
  String get analysis_no_change => 'Ugyanaz, mint a múlt héten';

  @override
  String analysis_trend_less(String percent) {
    return '$percent%-kal kevesebb, mint a múlt héten';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent%-kal több, mint a múlt héten';
  }

  @override
  String get crash_logs_heading => 'Összeomlási naplók';

  @override
  String get crash_logs_info =>
      'Ha bármilyen problémát tapasztal, jelentheti azt a GitHubon a naplófájllal együtt. A fájl olyan részleteket tartalmaz, mint az eszköz gyártója, modellje, Android-verziója, SDK-verziója és összeomlási naplók. Ez az információ segít a probléma hatékonyabb azonosításában és megoldásában.';

  @override
  String get crash_logs_export_tile_title => 'Összeomlási naplók exportálása';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Az összeomlási naplók exportálása json-fájlba.';

  @override
  String get crash_logs_view_tile_title => 'Naplók megtekintése';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Fedezze fel a tárolt összeomlási naplókat.';

  @override
  String get crash_logs_empty_list_hint => 'Eddig nem volt naplózott baleset.';

  @override
  String get crash_logs_clear_tile_title => 'Törölje a naplókat';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Törölje az összes összeomlási naplót az adatbázisból.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Biztosan törli az összes összeomlási naplót az adatbázisból?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'Mindenesetre tiszta';

  @override
  String get about_tab_title => 'Körülbelül';

  @override
  String get changelog_tile_title => 'Változásnapló';

  @override
  String get changelog_tile_subtitle => 'Ismerje meg az újdonságokat.';

  @override
  String get full_changelog_tile_title => 'Teljes változásnapló';

  @override
  String get redirected_to_github_subtitle =>
      'A rendszer átirányítja a GitHub oldalára.';

  @override
  String get contribute_heading => 'Hozzájárulni';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Tekintse meg a forráskódot.';

  @override
  String get report_issue_tile_title => 'Probléma bejelentése';

  @override
  String get suggest_idea_tile_title => 'Javasolj egy ötletet';

  @override
  String get write_email_tile_title => 'Írjon nekünk e-mailben';

  @override
  String get write_email_tile_subtitle =>
      'A rendszer átirányítja az E-mail alkalmazásba.';

  @override
  String get privacy_policy_heading => 'Adatvédelmi szabályzat';

  @override
  String get privacy_policy_info =>
      'A NLP digitox elkötelezett az Ön adatainak védelme mellett. Nem gyűjtünk, nem tárolunk vagy továbbítunk semmilyen felhasználói adatot. Az alkalmazás teljesen offline módban működik, és nem igényel internetkapcsolatot, így biztosítva, hogy személyes adatai privátak és biztonságosak maradjanak az eszközön. Ingyenes és nyílt forráskódú szoftver (FOSS) alkalmazásként a NLP digitox teljes átláthatóságot és felhasználói ellenőrzést garantál adataik felett.';

  @override
  String get more_details_button => 'További részletek';
}
