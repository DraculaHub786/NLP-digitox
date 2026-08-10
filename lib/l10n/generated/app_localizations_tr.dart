// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get mindful_tagline => 'Neyin önemli olduğuna odaklan';

  @override
  String get unlock_button_label => 'Kilidi açın';

  @override
  String get permission_status_off => 'Kapalı';

  @override
  String get permission_status_allowed => 'İzin verildi';

  @override
  String get permission_status_not_allowed => 'İzin verilmedi';

  @override
  String get permission_button_grant_permission => 'İzin verin';

  @override
  String get permission_button_agree_and_continue => 'Kabul edin ve devam edin';

  @override
  String get permission_button_not_now => 'Şimdi değil';

  @override
  String get permission_button_help => 'Yardım?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox 100% güvenli ve çevrimdışı çalışır. Sizin kişisel verileriniz toplamıyor ve depolamıyoruz.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. $button_label\'a tıklayın.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Sonraki ekranda NLP digitox\'u seçin.';

  @override
  String get permission_grant_step_three =>
      '3. Tıklayın ve alttaki gibi dönüştürmeyi açın.';

  @override
  String get permission_notification_title => 'Bildirimleri gönder';

  @override
  String get permission_alarms_title => 'Alarm & hatırlatıcılar';

  @override
  String get permission_alarms_info =>
      'Lütfen alarm ve hatırlatıcı için izin verin. Bu sayede NLP digitox ';

  @override
  String get permission_alarms_device_tile_label =>
      'Alarm ve hatırlatıcılara izin verin';

  @override
  String get permission_usage_title => 'Kullanım erişimi';

  @override
  String get permission_usage_info =>
      'Lütfen kullanım erişim izni verin. Bu, NLP digitox\'un uygulama kullanımını izlemesine ve belirli uygulamalara erişimi yönetmesine olanak tanıyarak daha odaklı ve kontrollü bir dijital ortam sağlayacaktır.';

  @override
  String get permission_usage_device_tile_label => 'Kullanım erişimi verin';

  @override
  String get permission_overlay_title => 'Kaplamayı Görüntüle';

  @override
  String get permission_overlay_info =>
      'Lütfen diğer uygulamaların üzerinde gösterme izni verin. Bu, NLP digitox\'un duraklatılmış bir uygulama açıldığında bir kaplama göstermesine izin vererek odaklanmanıza ve programınızı sürdürmenize yardımcı olacaktır.';

  @override
  String get permission_overlay_device_tile_label =>
      'Diğer uygulamaların üzerinde gösterime izin ver';

  @override
  String get permission_accessibility_title => 'Erişilebilirlik';

  @override
  String get permission_accessibility_info =>
      'Lütfen erişilebilirlik izni verin. Bu, NLP digitox\'un sosyal medya uygulamaları ve tarayıcılarda kısa biçimli video içeriğine (ör. Reels, Shorts) erişimi kısıtlamasına ve uygunsuz web sitelerini filtrelemesine olanak tanıyacaktır.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox, kısa içerikleri ve internet sitelerini etkili bir şekilde engellemek için erişilebilirlik izni gerektirir.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Dikkatliyi kullanın';

  @override
  String get permission_dnd_title => 'Rahatsız etme';

  @override
  String get permission_dnd_info =>
      'Lütfen Rahatsız Etmeyin erişimine izin verin. Bu, NLP digitox\'un yatma zamanı programı sırasında Rahatsız Etmeyin modunu başlatmasına ve durdurmasına izin verecektir.';

  @override
  String get permission_dnd_tile_title => 'Rahatsız etmeyin';

  @override
  String get permission_dnd_tile_subtitle =>
      'Rahatsız etmeyin moduna izin verin.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Batarya optimizasyonu devre dışı bırakın';

  @override
  String get permission_battery_optimization_status_enabled => 'Zaten sınırsız';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Arka plan kısıtlamalarını devre dışı bırak';

  @override
  String get permission_battery_optimization_allow_info =>
      '\'Pil Optimizasyonunu Yoksay\'a izin vermek, bazı cihazlarda otomatik olarak \'Alarmlar ve Hatırlatıcılar\' iznini verecektir.';

  @override
  String get permission_vpn_title => 'Sanal özel ağ oluştur';

  @override
  String get permission_vpn_info =>
      'Lütfen sanal özel ağ(VPN) oluşturmaya izin veriniz. Bu sayede NLP digitox internetizi lokal bir şekilde kısıtlayacaktır.';

  @override
  String get permission_admin_title => 'Yönetici';

  @override
  String get permission_admin_info =>
      'Yönetici ayrıcalıkları, uygulamanın düzgün çalışmasını ve kurcalanmaya karşı korumalı kalmasını sağlamak için yalnızca temel işlemler için gereklidir.';

  @override
  String get permission_admin_snack_alert =>
      'Kurcalama koruması yalnızca seçilen zaman aralığında devre dışı bırakılabilir.';

  @override
  String get permission_notification_access_title => 'Bildirim izni';

  @override
  String get permission_notification_access_info =>
      'Lütfen bildirim erişim izni verin. Bu, NLP digitox\'un bildirimlerinizi düzenlemesine ve bunları programınıza göre göndermesine izin verecektir.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox, bildirimleri toplu hale getirmek ve zamanlamak için bildirim erişimi gerektirir.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Bildirimlere izin ver';

  @override
  String get day_today => 'Bugün';

  @override
  String get day_yesterday => 'Dün';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString gün',
      one: '1 gün',
      zero: '0 gün',
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
      other: '$countString saat',
      one: '1 saat',
      zero: '0 saat',
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
      other: '$countString dakika',
      one: '1 dakika',
      zero: '0 dakika',
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
      other: '$countString saniye',
      one: '1 saniye',
      zero: '0 saniye',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 've';

  @override
  String get timer_status_active => 'Aktif';

  @override
  String get timer_status_paused => 'Duraklatıldı';

  @override
  String get create_button => 'Oluştur';

  @override
  String get update_button => 'Güncelleme';

  @override
  String get dialog_button_cancel => 'İptal';

  @override
  String get dialog_button_remove => 'Kaldır';

  @override
  String get dialog_button_set => 'Ayarla';

  @override
  String get dialog_button_reset => 'Sıfırla';

  @override
  String get dialog_button_infinite => 'Sonsuz';

  @override
  String get schedule_start_label => 'Başlat';

  @override
  String get schedule_end_label => 'Bitir';

  @override
  String get exit_without_saving_dialog_info =>
      'Kaydetmeden çıkmak istediğinizden emin misiniz?';

  @override
  String get development_dialog_info =>
      'NLP digitox şu anda geliştirme aşamasındadır ve hatalar veya eksik özellikler içerebilir. Herhangi bir sorunla karşılaşırsanız, lütfen geliştirmemize yardımcı olmak için bunları bildirin.\n\nGeri bildiriminiz için teşekkür ederiz!';

  @override
  String get development_dialog_button_report_issue => 'Sorun Bildir';

  @override
  String get development_dialog_button_close => 'Kapat';

  @override
  String get dnd_settings_tile_title => 'Rahatsız etmeyin ayarları';

  @override
  String get dnd_settings_tile_subtitle =>
      'DND\'de hangi uygulamaların ve bildirimlerin size ulaşabileceğini yönetin.';

  @override
  String get quick_actions_heading => 'Kısayollar';

  @override
  String get select_distracting_apps_heading =>
      'Dikkat dağıtan uygulamaları seç';

  @override
  String get your_distracting_apps_heading =>
      'Dikkatinizi dağıtan uygulamalarınız';

  @override
  String get select_more_apps_heading => 'Daha fazla uygulama seçin';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Dikkat dağıtıcı uygulamalar listesine önemli sistem uygulamalarının eklenmesine izin verilmez.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Ekran süresi ve kısıtlama bu uygulama için kullanılamıyor. Sadece internet kullanımı erişilebilir';

  @override
  String get create_group_fab_button => 'Grup Oluştur';

  @override
  String get active_period_info =>
      'Erişime izin verilecek bir zaman aralığı belirleyin. Bu zaman diliminin dışında erişim kısıtlanacaktır.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'En az bir dikkat dağıtıcı uygulama seçin.';

  @override
  String get donation_card_title => 'Bizi destekleyin';

  @override
  String get donation_card_info =>
      'NLP digitox ücretsiz ve açık kaynak kodludur, aylar süren özverili çalışmalarla geliştirilmiştir. Eğer size yardımcı olduysa, bağışınız bizim için dünyalara bedeldir. Her katkı, onu herkes için geliştirmeye ve sürdürmeye devam etmemize yardımcı olur.';

  @override
  String get operation_failed_snack_alert =>
      'Operasyon başarısız oldu, bir şeyler ters gitti!';

  @override
  String get donation_card_button_donate => 'Bağış';

  @override
  String get app_restart_dialog_title => 'Yeniden Başlatma Gerekli';

  @override
  String get app_restart_dialog_info =>
      'Geri sayım bittiğinde NLP digitox otomatik olarak yeniden başlayacaktır. Değişiklikler uygulanırken lütfen sabırlı olun.';

  @override
  String get accessibility_tip =>
      'Daha akıllı, daha pil dostu engelleme mi istiyorsunuz? NLP digitox için Erişilebilirlik iznini etkinleştirin.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox çalışmıyor mu? Sorunsuz çalışmasını sağlamak için Ayarlar\'da \'Pil Optimizasyonunu Yoksay\'a izin verin.';

  @override
  String get invincible_mode_tip =>
      'Yanlışlıkla kısıtlamaları mı kaldırdınız? Bir sonraki güne veya ayar penceresine kadar kilitlemek için Yenilmez Modu kullanın.';

  @override
  String get glance_usage_tip =>
      'İçgörü mü istiyorsunuz? Kullanım kalıplarınızı ve ekran sürenizi görüntülemek için Glance bölümünü kontrol edin.';

  @override
  String get tamper_protection_tip =>
      'NLP digitox\'u kaldırıyor musunuz? Önce kurcalama korumasını güvenli bir şekilde devre dışı bırakmak için Kaldırma Penceresini etkinleştirin.';

  @override
  String get notification_blocking_tip =>
      'Dikkat dağıtıcı unsurları azaltmak mı istiyorsunuz? Seçili uygulamaları susturmak için Bildirim Engelleme özelliğini kullanın.';

  @override
  String get usage_history_tip =>
      'Alışkanlıklarınız üzerinde düşünmek ister misiniz? Geçmiş kalıpları görmek için Kullanım Geçmişi\'ni kontrol edin.';

  @override
  String get focus_mode_tip =>
      'Derin odaklanmaya mı ihtiyacınız var? Görevler sırasında uygulamaları ve bildirimleri engellemek için Odak Modunu açın.';

  @override
  String get bedtime_reminder_tip =>
      'Uykunuzu iyileştirmek mi istiyorsunuz? Geceleri rahatlamak için bir Yatma Zamanı Hatırlatıcısı ayarlayın.';

  @override
  String get custom_blocking_tip =>
      'Özel bir deneyime mi ihtiyacınız var? İhtiyaçlarınıza uyan uygulama engelleme kuralları oluşturun.';

  @override
  String get session_timeline_tip =>
      'Want to track focus sessions? View timeline to see your focus journey.';

  @override
  String get short_content_blocking_tip =>
      'Distracted by social apps? Block short content on Instagram, YouTube, etc., to stay focused.';

  @override
  String get parental_controls_tip =>
      'Need parental control? Set restrictions for your child\'s device to ensure a safe experience.';

  @override
  String get notification_batching_tip =>
      'Want to reduce distractions? Use Notification Batching to group notifications and check them at once.';

  @override
  String get notification_scheduling_tip =>
      'Need to manage notifications? Schedule when you receive notifications for specific apps.';

  @override
  String get quick_focus_tile_tip =>
      'Need quick access to focus? Add a Quick Focus Tile to instantly activate Focus Mode.';

  @override
  String get app_shortcuts_tip =>
      'Want instant app access? Add shortcuts by long-pressing the app icon for quick actions.';

  @override
  String get backup_usage_db_tip =>
      'Want to save your data? Backup your usage database to keep your records safe.';

  @override
  String get dynamic_material_color_tip =>
      'Want a custom theme? Enable Dynamic Material You color to match your device\'s theme.';

  @override
  String get amoled_dark_theme_tip =>
      'Pil tasarrufu yapmak ister misiniz? OLED ekranlarda güç tüketimini azaltmak için AMOLED Koyu Tema\'yı kullanın.';

  @override
  String get customize_usage_history_tip =>
      'Kullanım geçmişini korumak ister misiniz? Kullanım Geçmişinde kaç haftalık verinin saklanacağını özelleştirin.';

  @override
  String get grouped_apps_blocking_tip =>
      'Want to block apps together? Use Restriction Groups to group app limits and block multiple apps at once.';

  @override
  String get websites_blocking_tip =>
      'Want a cleaner browsing experience? Block custom or NSFW websites for a more focused online time.';

  @override
  String get data_usage_tip =>
      'Want to track your data? Monitor your mobile and Wi-Fi data usage for internet consumption.';

  @override
  String get block_internet_tip =>
      'Need to block an app\'s internet? Cut off internet for specific app from app\'s dashboard.';

  @override
  String get emergency_passes_tip =>
      'Need a break? Use 3 Emergency Passes daily to temporarily unblock apps for 5 minutes.';

  @override
  String get onboarding_skip_btn_label => 'Atla';

  @override
  String get onboarding_finish_setup_btn_label => 'Kurulumu bitirin';

  @override
  String get onboarding_page_welcome_title => 'Welcome to NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Take control of your digital life and build healthier screen habits. NLP digitox helps you stay focused, minimize distractions, and make mindful choices every day.';

  @override
  String get onboarding_page_statistics_title => 'Know Your Habits.';

  @override
  String get onboarding_page_statistics_info =>
      'Understand your digital patterns with detailed insights on screen time, app usage, and focus trends. Track your progress and see how small changes lead to big improvements.';

  @override
  String get onboarding_page_one_title => 'En iyi odak.';

  @override
  String get onboarding_page_one_info =>
      'Dikkatinizi dağıtan uygulamaları duraklatın, kısa içerikleri engelleyin ve özelleştirilebilir odaklanma oturumlarıyla yolunuzdan sapmayın. İster çalışıyor, ister ders çalışıyor veya dinleniyor olun, NLP digitox kontrolü elinizde tutmanıza yardımcı olur.';

  @override
  String get onboarding_page_two_title => 'Dikkat Dağıtıcıları Engelleyin.';

  @override
  String get onboarding_page_two_info =>
      'Kullanım sınırları belirleyin, uygulamaları otomatik olarak duraklatın ve daha sağlıklı dijital alışkanlıklar oluşturun. Gevşemek ve dikkatinizin dağılmadığı bir gecenin tadını çıkarmak için Yatma Zamanı Modu\'nu kullanın.';

  @override
  String get onboarding_page_three_title => 'Öncelik gizlilik.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox 100% açık kaynaklıdır ve tamamen çevrimdışı çalışır. Kişisel verilerinizi toplamıyor veya paylaşmıyoruz — gizliliğiniz her şekilde garanti altındadır.';

  @override
  String get onboarding_page_permissions_title => 'Temel İzinler.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox, ekran sürenizi takip etmek ve yönetmek için temel izinleri takip etmeyi gerektirir, dikkat dağıtıcı unsurları azaltmaya ve odaklanmayı geliştirmeye yardımcı olur.';

  @override
  String get dashboard_tab_title => 'Kontrol Paneli';

  @override
  String get focus_now_fab_button => 'Şimdi odaklan';

  @override
  String get welcome_greetings => 'Tekrar hoş geldin,';

  @override
  String get username_snack_alert => 'İsmi düzenlemek için uzun basın.';

  @override
  String get username_dialog_title => 'Kullanıcı adı';

  @override
  String get username_dialog_info =>
      'Kontrol panelinde görüntülenecek olan kullanıcı adınızı girin.';

  @override
  String get username_dialog_button_apply => 'Uygula';

  @override
  String get glance_tile_title => 'Bakış';

  @override
  String get glance_tile_subtitle => 'Kullanımınıza hızlıca bir göz atın.';

  @override
  String get parental_controls_tile_subtitle =>
      'Değiştirilemez mod ve kurcalamaya karşı koruma.';

  @override
  String get restrictions_heading => 'Kısıtlamalar';

  @override
  String get apps_blocking_tile_title => 'Uygulama engelleme';

  @override
  String get apps_blocking_tile_subtitle =>
      'Uygulamaları çeşitli şekillerde sınırlandırın.';

  @override
  String get grouped_apps_blocking_tile_title =>
      'Gruplandırılmış uygulama engelleme';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Uygulama gruplarını aynı anda sınırlandırın.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Kısa içeriği birden fazla platformda sınırlandırın.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Yetişkin ve özel web sitelerini sınırlayın.';

  @override
  String get screen_time_label => 'Ekran süresi';

  @override
  String get total_data_label => 'Toplam veri';

  @override
  String get mobile_data_label => 'Mobil veri';

  @override
  String get wifi_data_label => 'Wifi veri';

  @override
  String get focus_today_label => 'Günlük odaklanma';

  @override
  String get focus_weekly_label => 'Haftalık odaklanma';

  @override
  String get focus_monthly_label => 'Aylık odaklanma';

  @override
  String get focus_lifetime_label => 'Şimdiye kadarki odaklanma';

  @override
  String get longest_streak_label => 'En uzun seri';

  @override
  String get current_streak_label => 'Güncel seri';

  @override
  String get successful_sessions_label => 'Başarılı oturumlar';

  @override
  String get failed_sessions_label => 'Başarısız oturumlar';

  @override
  String get statistics_tab_title => 'İstatistikler';

  @override
  String get screen_segment_label => 'Ekran';

  @override
  String get data_segment_label => 'Veri';

  @override
  String get mobile_label => 'Mobil';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'En çok kullanılan uygulamalar';

  @override
  String get show_all_apps_tile_title => 'Tüm uygulamaları göster';

  @override
  String get search_apps_hint => 'Uygulama ara...';

  @override
  String get notifications_tab_title => 'Bildirimler';

  @override
  String get notifications_tab_info =>
      'Uygulamalardan toplu bildirim alın ve sabah, öğlen, akşam ve gece gibi programlar ayarlayın. Sürekli kesinti olmadan güncel kalın.';

  @override
  String get batched_apps_tile_title => 'Gruplanmış uygulamalar';

  @override
  String get batch_recap_dropdown_title => 'Batch recap type';

  @override
  String get batch_recap_dropdown_info =>
      'Choose what to push when a schedule triggers — all notifications or just a summary.';

  @override
  String get batch_recap_option_summery_only => 'Summary only';

  @override
  String get batch_recap_option_all_notifications => 'All notifications';

  @override
  String get notification_history_tile_title => 'Notification history';

  @override
  String get store_all_tile_title => 'Tüm bildirimleri sakla';

  @override
  String get store_all_tile_subtitle => 'Save non-batched notifications too.';

  @override
  String get schedules_heading => 'Program';

  @override
  String get new_schedule_fab_button => 'Yeni program';

  @override
  String get new_schedule_dialog_info =>
      'Kolayca tanımlanmasına yardımcı olmak için bildirim zamanlamasına bir ad girin.';

  @override
  String get new_schedule_dialog_field_label => 'Program adı';

  @override
  String get bedtime_tab_title => 'Uyku vakti';

  @override
  String get bedtime_tab_info =>
      'Bir zaman aralığı ve haftanın günlerini seçerek yatma zamanı programınızı ayarlayın. Engellenecek dikkat dağıtıcı uygulamaları seçin ve huzurlu bir gece için Rahatsız Etmeyin (DND) modunu etkinleştirin.';

  @override
  String get schedule_tile_title => 'Program';

  @override
  String get schedule_tile_subtitle =>
      'Günlük programı etkinleştirme veya devre dışı bırakma.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Haftanın en az bir gününü seçin.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Toplam yatma süresi en az 30 dakika olmalıdır.';

  @override
  String get distracting_apps_tile_title => 'Dikkat dağıtıcı uygulamalar';

  @override
  String get distracting_apps_tile_subtitle =>
      'Hangi uygulamaların sizi yatma zamanı rutininizden uzaklaştırdığını seçin.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Yatma zamanı programı aktifken dikkat dağıtıcı uygulamalar listesinde değişiklik yapılmasına izin verilmez.';

  @override
  String get parental_controls_tab_title => 'Ebeveyn Kontrolleri';

  @override
  String get invincible_mode_heading => 'Değiştirilemez mod';

  @override
  String get invincible_mode_tile_title => 'Değiştirilemez modu aktifleştir';

  @override
  String get invincible_mode_info =>
      'Değiştirilemez Mod açıkken, günlük kotanıza ulaştıktan sonra seçilen limitleri ayarlayamazsınız. Ancak, seçilen 10 dakikalık değiştirilemez pencere içinde değişiklik yapabilirsiniz.';

  @override
  String get invincible_mode_snack_alert =>
      'Değiştirilemez mod nedeniyle, kısıtlamalarda değişiklik yapılmasına izin verilmez.';

  @override
  String get invincible_mode_dialog_info =>
      'Değiştirilemez Modu etkinleştirmek istediğinizden kesinlikle emin misiniz? Bu işlem geri döndürülemez. Değiştirilemez Mod bir kez açıldığında, bu uygulama cihazınızda yüklü olduğu sürece kapatamazsınız.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Bu uygulama cihazınızda yüklü kaldığı sürece değiştirilemez mod kapatılamaz.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Yine de başlat';

  @override
  String get invincible_mode_include_timer_tile_title => 'Zamanlayıcı dahil et';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Başlatma limitini dahil edin';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Aktif dönemi dahil edin';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Uygulama kısıtlayıcı';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Günlük limitler aşıldığında uygulamanın seçilen kısıtlamalarında değişiklik yapılmasını önleyin.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Grup kısıtlamaları';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Günlük limitler aşıldığında grubun seçilen kısıtlamalarında değişiklik yapılmasını önleyin.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Kısa video zamanlayıcısını dahil edin';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Günlük kısa video limitinize ulaştıktan sonra değişiklik yapılmasını önler.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Uyku vaktini dahil edin';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Aktif uyku vakti programı sırasında değişiklikleri önler.';

  @override
  String get protected_access_tile_title => 'Korumalı erişim';

  @override
  String get protected_access_tile_subtitle =>
      'NLP digitox\'u cihaz kilidinizle koruyun.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Bu özelliği etkinleştirmek için lütfen önce cihazınızda bir biyometrik kilit ayarlayın.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Cihaz kilidiniz kaldırıldı. Devam etmek için lütfen yeni bir kilit ayarlayın.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Kimlik doğrulama başarısız oldu. Devam etmek için cihaz kilidinizi doğrulamanız gerekiyor.';

  @override
  String get tamper_protection_tile_title => 'Kurcalama koruması';

  @override
  String get tamper_protection_tile_subtitle =>
      'Kaldırmayı önleyin ve uygulamayı durdurmaya zorlayın.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Once enabled, you won\'t be able to uninstall, force stop, or clear NLP digitox\'s data, except during the selected uninstall window. There are no workarounds.\n\nProceed at your own risk.';

  @override
  String get uninstall_window_tile_title => 'Kaldırma penceresi';

  @override
  String get uninstall_window_tile_subtitle =>
      'Kurcalama koruması seçilen zamandan itibaren 10 dakika içinde devre dışı bırakılabilir.';

  @override
  String get invincible_window_tile_title => 'Değiştirilemez mod';

  @override
  String get invincible_window_tile_subtitle =>
      'Seçilen limitler, seçilen saatten itibaren 10 dakika içinde değiştirilebilir.';

  @override
  String get shorts_blocking_tab_title => 'Kısa video engelleyici';

  @override
  String get shorts_blocking_tab_info =>
      'Web siteleri de dahil olmak üzere Instagram, YouTube, Snapchat ve Facebook gibi platformlarda kısa içeriklere ne kadar zaman harcadığınızı kontrol edin.';

  @override
  String get short_content_heading => 'Kısa video içeriği';

  @override
  String shorts_time_left_from(String timeShortString) {
    return '$timeShortString \'den kalan süre';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Kısa içerik için günlük bir zaman sınırı belirleyin. Sınırınıza ulaşıldığında, kısa içerik gece yarısına kadar duraklatılacaktır.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Instagram\'daki içeriği kısıtlayın.';

  @override
  String get instagram_features_block_reels => 'Reels bölümünü kısıtlayın.';

  @override
  String get instagram_features_block_explore => 'Keşfet bölümünü kısıtlayın.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Snapchat\'teki içeriği kısıtlayın.';

  @override
  String get snapchat_features_block_spotlight =>
      'Spotlight bölümünü kısıtlayın.';

  @override
  String get snapchat_features_block_discover => 'Keşfet bölümünü kısıtlayın.';

  @override
  String get youtube_features_tile_title => 'YouTube';

  @override
  String get youtube_features_tile_subtitle =>
      'Youtube\'daki kısa içeriği kısıtla.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Facebook\'ta reelsları kısıtla.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle =>
      'Reddit\'teki kısa videoları kısıtla.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'X\'teki video akışını kısıtla.';

  @override
  String get threads_features_tile_title => 'Threads';

  @override
  String get threads_features_tile_subtitle =>
      'Threads\'teki video/reels içeriğini kısıtla.';

  @override
  String get websites_blocking_tab_title => 'Website engelleyici';

  @override
  String get websites_blocking_tab_info =>
      'Daha güvenli ve daha odaklı bir çevrimiçi deneyim oluşturmak için yetişkinlere yönelik web sitelerini ve seçtiğiniz tüm özel siteleri engelleyin. Gezinmenizin sorumluluğunu üstlenin ve dikkatiniz dağılmasın.';

  @override
  String get adult_content_heading => 'Yetişkin içeriği';

  @override
  String get block_nsfw_title => 'Nsfw içeriği engelle';

  @override
  String get block_nsfw_subtitle =>
      'Tarayıcıların yetişkin ve porno web sitelerini açmasını kısıtlayın.';

  @override
  String get block_nsfw_dialog_info =>
      'Emin misiniz? Bu işlem geri döndürülemez. Yetişkin siteleri engelleyici AÇIK konuma getirildikten sonra, bu uygulama cihazınızda yüklü olduğu sürece KAPALI konuma getiremezsiniz.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Yinede Engelle';

  @override
  String get blocked_websites_heading => 'Engellenen internet siteleri';

  @override
  String get blocked_websites_empty_list_hint =>
      'Engellemek istediğiniz dikkat dağıtıcı web sitelerini eklemek için \'+ Web Sitesi Ekle\' düğmesine tıklayın.';

  @override
  String get add_website_fab_button => 'Site ekle';

  @override
  String get add_website_dialog_title => 'Dikkat dağıtıcı siteler';

  @override
  String get add_website_dialog_info =>
      'Engellemek istediğiniz web sitesinin url\'sini girin.';

  @override
  String get add_website_dialog_is_nsfw => 'Nsfw sitesi mi?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Uyarı: Nsfw siteleri eklendikten sonra kaldırılamaz.';

  @override
  String get add_website_dialog_button_block => 'Engelle';

  @override
  String get add_website_already_exist_snack_alert =>
      'URL zaten engellenen web siteleri listesine eklenmiştir.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'Geçersiz URL! Sunucu adresi ayrıştırılamıyor.';

  @override
  String get remove_website_dialog_title => 'Web sitesini kaldırın';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Emin misiniz? \'$websitehost\'u engellenen web sitelerinden kaldırmak istiyorsunuz.';
  }

  @override
  String get focus_tab_title => 'Odak';

  @override
  String get focus_tab_info =>
      'Odaklanmak için zamana ihtiyacınız olduğunda, türü seçerek, duraklatılacak dikkat dağıtıcı uygulamaları seçerek ve kesintisiz konsantrasyon için Rahatsız Etmeyin özelliğini etkinleştirerek yeni bir oturum başlatın.';

  @override
  String get active_session_card_title => 'Aktif oturum';

  @override
  String get active_session_card_info =>
      'Aktif bir odaklanma oturumunuz devam ediyor! İlerlemenizi kontrol etmek ve ne kadar zaman geçtiğini görmek için \'Görüntüle\'ye tıklayın.';

  @override
  String get active_session_card_view_button => 'Görüntüle';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Odaklanma Oturumu etkinken dikkat dağıtıcı uygulamalar listesinden uygulama kaldırmaya izin verilmez. Ancak, bu süre zarfında listeye ek uygulamalar ekleyebilirsiniz.';

  @override
  String get focus_profile_tile_title => 'Odaklanma profili';

  @override
  String get focus_session_duration_tile_title => 'Oturum süresi';

  @override
  String get focus_session_duration_tile_subtitle => 'Sonsuz (durdurana kadar)';

  @override
  String get focus_session_duration_dialog_info =>
      'Lütfen bu odaklanma oturumu için istediğiniz süreyi seçin, ne kadar süre odaklanmış ve dikkatiniz dağılmadan kalmak istediğinizi belirleyin.';

  @override
  String get focus_profile_customization_tile_title => 'Profile customization';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Customize settings for the selected profile.';

  @override
  String get focus_enforce_tile_title => 'Enforce session';

  @override
  String get focus_enforce_tile_subtitle =>
      'Prevents ending a session before time ends.';

  @override
  String get focus_session_start_button => 'Swipe to start Session';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Odaklanma oturumunu başlatmak için en az bir dikkat dağıtıcı uygulama seçin';

  @override
  String get focus_session_already_active_snack_alert =>
      'Halihazırda aktif bir odaklanma oturumunuz var. Lütfen yeni bir oturum başlatmadan önce mevcut oturumunuzu tamamlayın veya durdurun.';

  @override
  String get focus_session_type_study => 'Ders çalışma';

  @override
  String get focus_session_type_work => 'İş';

  @override
  String get focus_session_type_exercise => 'Egzersiz';

  @override
  String get focus_session_type_meditation => 'Meditasyon';

  @override
  String get focus_session_type_creativeWriting => 'Yaratıcı Yazarlık';

  @override
  String get focus_session_type_reading => 'Okuma';

  @override
  String get focus_session_type_programming => 'Programlama';

  @override
  String get focus_session_type_chores => 'Ev İşleri';

  @override
  String get focus_session_type_projectPlanning => 'Proje Planlama';

  @override
  String get focus_session_type_artAndDesign => 'Sanat ve Tasarım';

  @override
  String get focus_session_type_languageLearning => 'Dil Öğrenimi';

  @override
  String get focus_session_type_musicPractice => 'Müzik Pratiği';

  @override
  String get focus_session_type_selfCare => 'Kişisel Bakım';

  @override
  String get focus_session_type_brainstorming => 'Beyin Fırtınası';

  @override
  String get focus_session_type_skillDevelopment => 'Beceri Geliştirme';

  @override
  String get focus_session_type_research => 'Araştırma';

  @override
  String get focus_session_type_networking => 'İlişki ağı oluşturma';

  @override
  String get focus_session_type_cooking => 'Yemek yapma';

  @override
  String get focus_session_type_sportsTraining => 'Spor antremanı';

  @override
  String get focus_session_type_restAndRelaxation => 'Dinlenme ve Rahatlama';

  @override
  String get focus_session_type_other => 'Diğer';

  @override
  String get timeline_tab_title => 'Zaman çizelgesi';

  @override
  String get focus_timeline_tab_info =>
      'Explore your focus journey by selecting a date from the calendar. Track your progress, revisit your successes, and learn from the challenges.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Seçilen ay için toplam üretkenlik süreniz $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Verimli günler';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Seçilen ayda toplam $daysCount verimli gün geçirdiniz.';
  }

  @override
  String get selected_day_focused_time_label => 'Odaklanmış zaman';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Seçilen gün için odaklandığınız toplam süre $timeString.';
  }

  @override
  String get calender_heading => 'Takvim';

  @override
  String get your_sessions_heading => 'Seanslarınız';

  @override
  String get your_sessions_empty_list_hint =>
      'Seçilen gün için hiçbir odak oturumu kaydedilmemiştir.';

  @override
  String get focus_session_tile_timestamp_label => 'Timestamp';

  @override
  String get focus_session_tile_duration_label => 'Süre';

  @override
  String get focus_session_tile_reflection_label => 'Reflection';

  @override
  String get focus_session_state_active => 'Aktif';

  @override
  String get focus_session_state_successful => 'Başarılı';

  @override
  String get focus_session_state_failed => 'Başarısız';

  @override
  String get active_session_tab_title => 'Oturum';

  @override
  String get active_session_none_warning =>
      'Aktif oturum bulunamadı. Ana ekrana dönülüyor.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Oturuma devam et';

  @override
  String get active_session_finish_dialog_title => 'Bitir';

  @override
  String get active_session_finish_dialog_info =>
      'Güçlü kalın! Değerli bir odaklanma oluşturuyorsunuz. Bu odaklanma seansını bitirmek istediğinize emin misiniz? Fazladan her an hedefleriniz için önemlidir.';

  @override
  String get active_session_giveup_dialog_title => 'Vazgeç';

  @override
  String get active_session_giveup_dialog_info =>
      'Bir saniye! Neredeyse tamamladın, şimdi pes etme! Bu odaklanma oturumunu erken bitirmek istediğinden emin misin? İlerleme kaybolacak.';

  @override
  String get active_session_reflection_dialog_title => 'Session reflection';

  @override
  String get active_session_reflection_dialog_info =>
      'Take a moment to reflect on your progress. What\'s your goal for this session? What did you accomplish during this session?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Tip: You can always edit this later in the session timeline.';

  @override
  String get active_session_giveup_snack_alert =>
      'Vazgeçtin! Endişelenme, bir dahaki sefere daha iyisini yapabilirsin. Her çaba önemli – sadece devam et';

  @override
  String get active_session_quote_one =>
      'Her adım önemlidir, güçlü kalın ve devam edin';

  @override
  String get active_session_quote_two =>
      'Odaklanmaya devam et! İnanılmaz bir ilerleme kaydediyorsun';

  @override
  String get active_session_quote_three => 'Eziyorsun! Momentumu devam ettir';

  @override
  String get active_session_quote_four =>
      'Sadece biraz daha kaldı, harika gidiyorsun';

  @override
  String active_session_quote_five(String durationString) {
    return 'Tebrikler 🎉 \n $durationString odaklanma seansınızı tamamladınız.\n\nHarika iş, harika çalışmaya devam edin';
  }

  @override
  String get restriction_groups_tab_title => 'Kısıtlama grupları';

  @override
  String get restriction_groups_tab_info =>
      'Bir grup uygulama için birleşik bir ekran süresi sınırı belirleyin. Toplam kullanım sınırınıza ulaştığında, odaklanmayı ve dengeyi korumaya yardımcı olmak için gruptaki tüm uygulamalar duraklatılacaktır.';

  @override
  String get restriction_group_time_spent_label => 'Bugün harcanan zaman';

  @override
  String get restriction_group_time_left_label => 'Bugün kalan zaman';

  @override
  String get restriction_group_name_tile_title => 'Grup adı';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Kısıtlama grubunun kolayca tanımlanmasına ve yönetilmesine yardımcı olmak için bir ad girin.';

  @override
  String get restriction_group_timer_tile_title => 'Grup zamanlayıcısı';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Bu grup için günlük bir zaman sınırı belirleyin. Sınırınıza ulaşıldığında, bu gruptaki tüm uygulamalar gece yarısına kadar duraklatılacaktır.';

  @override
  String get restriction_group_active_period_tile_title => 'Grup aktif dönemi';

  @override
  String get remove_restriction_group_dialog_title => 'Grubu sil';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Emin misiniz? \'$groupName\' öğesini kısıtlama gruplarından kaldırmak istiyorsunuz.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Bir zamanlayıcı ya da aktif süre sınırı belirleyin.';

  @override
  String get notifications_empty_list_hint =>
      'No notifications have been batched for the day.';

  @override
  String get conversations_label => 'Sohbetler';

  @override
  String get last_24_hours_heading => 'Son 24 Saat';

  @override
  String get notification_timeline_tab_info =>
      'Browse your notification history by selecting a date from the calendar. See which apps grabbed your attention and reflect on your digital habits.';

  @override
  String get monthly_label => 'Aylık';

  @override
  String get daily_label => 'Günlük';

  @override
  String get search_notifications_sheet_info =>
      'Easily find past notifications by searching through their title or content. Helps you quickly locate important alerts.';

  @override
  String get search_notifications_hint => 'Bildirimleri ara...';

  @override
  String get search_notifications_empty_list_hint =>
      'No notifications found matching your search.';

  @override
  String get app_info_none_warning =>
      'Verilen paket için uygulama bulunamadı. Ana ekrana dönülüyor.';

  @override
  String get emergency_fab_button => 'Acil durum';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Bu işlem, uygulama engelleyicisini bir sonraki 5 dakika için duraklatacaktır. $leftPassesCount geçişiniz kaldı. Tüm geçişleri kullandıktan sonra, uygulama gece yarısına kadar veya aktif odaklanma oturumu bitene kadar engellenmiş kalacaktır. \n\nDevam etmek istiyor musunuz?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Yine de kullan';

  @override
  String get emergency_started_snack_alert =>
      'Uygulama engelleyici duraklatıldı ve 5 dakika içinde engellemeye devam edecek.';

  @override
  String get emergency_already_active_snack_alert =>
      'Uygulama engelleyici şu anda ya duraklatılmış ya da etkin değil. Bildirimler etkinse, kalan süreyle ilgili güncellemeler alırsınız.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Tüm acil durum geçişlerinizi kullandınız. Engellenen uygulamalar gece yarısına veya etkin odaklanma oturumu sona erene kadar engellenmiş olarak kalacaktır.';

  @override
  String get app_limit_status_not_set => 'Belirlenmemiş';

  @override
  String get app_timer_tile_title => 'Uygulama zamanlayıcı';

  @override
  String get app_timer_picker_dialog_info =>
      'Bu uygulama için günlük bir zaman sınırı belirleyin. Sınırınıza ulaşıldığında, uygulama gece yarısına kadar duraklatılacaktır.';

  @override
  String get usage_reminders_tile_title => 'Usage reminders';

  @override
  String get usage_reminders_tile_subtitle =>
      'Gentle nudges when using timed apps.';

  @override
  String get app_launch_limit_tile_title => 'Başlatma limiti';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Bugün $count kez başlatıldı.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Bu uygulamayı her gün kaç kez açabileceğinizi ayarlayın. Sınıra ulaşıldığında, gece yarısına kadar duraklatılacaktır.';

  @override
  String get app_active_period_tile_title => 'Aktif dönem';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return '$startTime \'den $endTime \'e kadar';
  }

  @override
  String get internet_access_tile_title => 'Internet erişimi';

  @override
  String get internet_access_tile_subtitle =>
      'Uygulamanın internetini engellemek için kapatın.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '$appName\'in interneti engellendi.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '$appName\'in internet engeli kaldırıldı.';
  }

  @override
  String get launch_app_tile_title => 'Uygulamayı başlat';

  @override
  String launch_app_tile_subtitle(String appName) {
    return '$appName uygulamasını açın.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Uygulama ayarlarına gidin';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Bildirimler, izinler, depolama ve daha fazlası gibi uygulama ayarlarını yönetin.';

  @override
  String get include_in_stats_tile_title => 'Ekran kullanımına dahil et';

  @override
  String get include_in_stats_tile_subtitle =>
      'Bu uygulamayı toplam ekran kullanımından hariç tutmak için kapatın.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName toplam ekran kullanımından hariç tutulur.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return 'Toplam ekran kullanımına $appName dahildir.';
  }

  @override
  String get general_tab_title => 'Genel';

  @override
  String get appearance_heading => 'Görünüm';

  @override
  String get theme_mode_tile_title => 'Tema modu';

  @override
  String get theme_mode_system_label => 'Sistem';

  @override
  String get theme_mode_light_label => 'Aydınlık';

  @override
  String get theme_mode_dark_label => 'Karanlık';

  @override
  String get material_color_tile_title => 'Materyal rengi';

  @override
  String get amoled_dark_tile_title => 'AMOLED siyah';

  @override
  String get amoled_dark_tile_subtitle =>
      'Koyu tema için saf siyah rengini kullanın.';

  @override
  String get dynamic_colors_tile_title => 'Dinamik renkler';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Destekleniyorsa cihaz renklerini kullanın.';

  @override
  String get defaults_heading => 'Varsayılanlar';

  @override
  String get app_language_tile_title => 'Uygulama dili';

  @override
  String get default_home_tab_tile_title => 'Ana Sayfa';

  @override
  String get usage_history_tile_title => 'Kullanım Günlüğü';

  @override
  String get usage_history_15_days => '15 gün';

  @override
  String get usage_history_1_month => '1 ay';

  @override
  String get usage_history_3_month => '3 ay';

  @override
  String get usage_history_6_month => '6 ay';

  @override
  String get usage_history_1_year => '1 yıl';

  @override
  String get service_heading => 'Servis';

  @override
  String get service_stopping_warning =>
      'NLP digitox beklenmedik bir şekilde çalışmayı durdurursa, lütfen arka planda çalışmaya devam etmesi için \'Pil Optimizasyonunu Yoksay\' iznini verin. Sorun devam ederse, kesintisiz performans için NLP digitox\'u beyaz listeye almayı deneyin.';

  @override
  String get whitelist_app_tile_title => 'Beyaz Liste NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'NLP digitoxun otomatik başlatılmasına izin ver.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Bu cihaz, otomatik başlatma yönetimini desteklemiyor.';

  @override
  String get database_tab_title => 'Veritabanı';

  @override
  String get import_db_tile_title => 'Veritabanını içe aktar';

  @override
  String get import_db_tile_subtitle => 'Veritabanını dosyadan içeri aktar.';

  @override
  String get export_db_tile_title => 'Veritabanını dışa aktar';

  @override
  String get export_db_tile_subtitle => 'Veritabanını dosyadan dışarı aktar.';

  @override
  String get analysis_tab_title => 'Analysis';

  @override
  String get analysis_7_days => '7 days';

  @override
  String get analysis_30_days => '30 days';

  @override
  String get analysis_90_days => '90 days';

  @override
  String get analysis_screen_time_trend => 'Screen time trend';

  @override
  String get analysis_no_data_info =>
      'No screen time data recorded for this period yet.';

  @override
  String get analysis_daily_average => 'Daily average';

  @override
  String get analysis_total => 'Total';

  @override
  String get analysis_no_change => 'Same as last week';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% less than last week';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% more than last week';
  }

  @override
  String get crash_logs_heading => 'Çökme günlüğü';

  @override
  String get crash_logs_info =>
      'Herhangi bir sorunla karşılaşırsanız, bunu GitHub üzerinde log dosyasıyla birlikte rapor edebilirsiniz. Dosya, cihazınızın üreticisi, modeli, Android sürümü, SDK sürümü ve çökme günlükleri gibi detayları içerecektir. Bu bilgiler, problemi daha etkili bir şekilde tanımlamamıza ve çözmemize yardımcı olacaktır.';

  @override
  String get crash_logs_export_tile_title => 'Çökme günlüğünü dışarı aktar';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Çökme günlüğünü json dosyası olarak dışarı aktar.';

  @override
  String get crash_logs_view_tile_title => 'Günlüğü görüntüle';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Saklanan çökme günlüklerini inceleyin.';

  @override
  String get crash_logs_empty_list_hint =>
      'Şu ana kadar hiçbir çökme kaydedilmedi.';

  @override
  String get crash_logs_clear_tile_title => 'Günlükleri temizle';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Tüm çökme raporlarını veritabanından kaldırın.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Veritabanından tüm çökme günlüklerini silmek istediğinizden emin misiniz?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Temizle';

  @override
  String get about_tab_title => 'Hakkında';

  @override
  String get changelog_tile_title => 'Değişiklik Notları';

  @override
  String get changelog_tile_subtitle => 'Yenilikleri öğrenin.';

  @override
  String get full_changelog_tile_title => 'Tam değişiklik notları';

  @override
  String get redirected_to_github_subtitle =>
      'Şuraya yönlendirileceksiniz: GitHub.';

  @override
  String get contribute_heading => 'Katkıda bulunun';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Kaynak kodunu incele.';

  @override
  String get report_issue_tile_title => 'Sorun bildir';

  @override
  String get suggest_idea_tile_title => 'Bir fikir öner';

  @override
  String get write_email_tile_title => 'Bize e-posta ile yazın';

  @override
  String get write_email_tile_subtitle =>
      'E-posta uygulamasına yönlendirileceksiniz.';

  @override
  String get privacy_policy_heading => 'Gizlilik politikası';

  @override
  String get privacy_policy_info =>
      'NLP digitox, gizliliğinizi korumaya kararlıdır. Herhangi bir kullanıcı verisini toplamaz, depolamaz veya aktarmaz. Uygulama tamamen çevrimdışıdır ve internet bağlantısı gerektirmez, böylece kişisel bilgileriniz cihazınızda özel ve güvenli kalır. Ücretsiz ve Açık Kaynak Yazılım (FOSS) uygulaması olarak, NLP digitox, verileriniz üzerinde tam şeffaflık ve kullanıcı kontrolü sağlar.';

  @override
  String get more_details_button => 'Daha fazla bilgi';
}
