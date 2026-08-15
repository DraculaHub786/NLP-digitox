// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get mindful_tagline => 'Tập trung vào những gì thực sự quan trọng';

  @override
  String get unlock_button_label => 'Mở khóa';

  @override
  String get permission_status_off => 'Tắt';

  @override
  String get permission_status_allowed => 'Được phép';

  @override
  String get permission_status_not_allowed => 'Không được phép';

  @override
  String get permission_button_grant_permission => 'Cấp quyền';

  @override
  String get permission_button_agree_and_continue => 'Đồng ý & Tiếp tục';

  @override
  String get permission_button_not_now => 'Không phải bây giờ';

  @override
  String get permission_button_help => 'Cần giúp?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox an toàn 100% và hoạt động ngoại tuyến. Chúng tôi không thu thập hoặc lưu trữ bất kỳ dữ liệu cá nhân nào.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Nhấp vào nút $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Chọn NLP digitox ở màn hình tiếp theo.';

  @override
  String get permission_grant_step_three =>
      '3. Nhấp và bật công tắc như bên dưới.';

  @override
  String get permission_notification_title => 'Gửi thông báo';

  @override
  String get permission_alarms_title => 'Báo thức & Nhắc nhở';

  @override
  String get permission_alarms_info =>
      'Vui lòng cấp quyền cài đặt báo thức và nhắc nhở. Điều này sẽ cho phép NLP digitox bắt đầu lịch trình đi ngủ đúng giờ và đặt lại bộ hẹn giờ ứng dụng hàng ngày vào lúc nửa đêm và giúp bạn duy trì đúng tiến độ.';

  @override
  String get permission_alarms_device_tile_label =>
      'Cho phép cài đặt báo thức và nhắc nhở';

  @override
  String get permission_usage_title => 'Quyền truy cập sử dụng';

  @override
  String get permission_usage_info =>
      'Vui lòng cấp quyền truy cập sử dụng. Điều này sẽ cho phép NLP digitox giám sát việc sử dụng ứng dụng và quản lý quyền truy cập vào một số ứng dụng nhất định, đảm bảo môi trường kỹ thuật số tập trung và được kiểm soát hơn.';

  @override
  String get permission_usage_device_tile_label => 'Cho phép truy cập sử dụng';

  @override
  String get permission_overlay_title => 'Lớp phủ hiển thị';

  @override
  String get permission_overlay_info =>
      'Vui lòng cấp quyền lớp phủ hiển thị. Điều này sẽ cho phép NLP digitox hiển thị lớp phủ khi mở ứng dụng bị tạm dừng, giúp bạn tập trung và duy trì lịch trình của mình.';

  @override
  String get permission_overlay_device_tile_label =>
      'Cho phép hiển thị trên các ứng dụng khác';

  @override
  String get permission_accessibility_title => 'Khả năng tiếp cận';

  @override
  String get permission_accessibility_info =>
      'Vui lòng cấp quyền truy cập. Điều này sẽ cho phép NLP digitox hạn chế quyền truy cập vào nội dung video dạng ngắn (ví dụ: Câu chuyện, Video ngắn) trong các ứng dụng và trình duyệt mạng xã hội, đồng thời lọc các trang web không phù hợp.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox yêu cầu quyền truy cập để chặn nội dung và trang web ngắn một cách hiệu quả.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Sử dụng NLP digitox';

  @override
  String get permission_dnd_title => 'Đừng làm phiền';

  @override
  String get permission_dnd_info =>
      'Vui lòng cấp quyền truy cập Không làm phiền. Điều này sẽ cho phép NLP digitox bắt đầu và dừng chế độ Không làm phiền trong lịch trình đi ngủ.';

  @override
  String get permission_dnd_tile_title => 'Bắt đầu DND';

  @override
  String get permission_dnd_tile_subtitle =>
      'Đồng thời bật chế độ Không làm phiền.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Bỏ qua tối ưu hóa pin';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Đã không bị hạn chế';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Vô hiệu hóa hạn chế nền';

  @override
  String get permission_battery_optimization_allow_info =>
      'Việc cho phép \'Bỏ qua tối ưu hóa pin\' sẽ tự động cấp quyền \'Báo thức & Lời nhắc\' trên một số thiết bị.';

  @override
  String get permission_vpn_title => 'Tạo VPN';

  @override
  String get permission_vpn_info =>
      'Vui lòng cấp quyền tạo kết nối mạng riêng ảo (VPN). Điều này sẽ cho phép NLP digitox hạn chế quyền truy cập internet đối với các ứng dụng được chỉ định bằng cách tạo VPN cục bộ trên thiết bị.';

  @override
  String get permission_admin_title => 'Quản trị viên';

  @override
  String get permission_admin_info =>
      'Đặc quyền quản trị chỉ cần thiết cho các hoạt động thiết yếu để đảm bảo ứng dụng hoạt động bình thường và không bị giả mạo.';

  @override
  String get permission_admin_snack_alert =>
      'Bảo vệ giả mạo chỉ có thể bị vô hiệu hóa trong khoảng thời gian đã chọn.';

  @override
  String get permission_notification_access_title => 'Truy cập thông báo';

  @override
  String get permission_notification_access_info =>
      'Vui lòng cấp quyền truy cập thông báo. Điều này sẽ cho phép NLP digitox sắp xếp các thông báo của bạn và gửi chúng theo lịch trình của bạn.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox yêu cầu quyền truy cập thông báo vào thông báo hàng loạt và lịch trình.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Cho phép truy cập thông báo';

  @override
  String get day_today => 'Hôm nay';

  @override
  String get day_yesterday => 'Hôm qua';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ngày',
      one: '1 ngày',
      zero: '0 ngày',
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
      other: '$countString giờ',
      one: '1 giờ',
      zero: '0 giờ',
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
      other: '$countString phút',
      one: '1 phút',
      zero: '0 phút',
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
      other: '$countString giây',
      one: '1 giây',
      zero: '0 giây',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'và';

  @override
  String get timer_status_active => 'Đang hoạt động';

  @override
  String get timer_status_paused => 'Đã tạm dừng';

  @override
  String get create_button => 'Tạo';

  @override
  String get update_button => 'cập nhật';

  @override
  String get dialog_button_cancel => 'Hủy bỏ';

  @override
  String get dialog_button_remove => 'Xóa';

  @override
  String get dialog_button_set => 'Đặt';

  @override
  String get dialog_button_reset => 'Đặt lại';

  @override
  String get dialog_button_infinite => 'vô hạn';

  @override
  String get schedule_start_label => 'Bắt đầu';

  @override
  String get schedule_end_label => 'Kết thúc';

  @override
  String get exit_without_saving_dialog_info =>
      'Bạn có chắc chắn muốn thoát mà không lưu không?';

  @override
  String get development_dialog_info =>
      'NLP digitox hiện đang được phát triển và có thể có lỗi hoặc tính năng chưa hoàn thiện. Nếu bạn gặp bất kỳ vấn đề nào, vui lòng báo cáo để giúp chúng tôi cải thiện.\n\nCảm ơn bạn đã phản hồi!';

  @override
  String get development_dialog_button_report_issue => 'Báo cáo vấn đề';

  @override
  String get development_dialog_button_close => 'Đóng';

  @override
  String get dnd_settings_tile_title => 'Cài đặt không làm phiền';

  @override
  String get dnd_settings_tile_subtitle =>
      'Quản lý những ứng dụng và thông báo nào có thể liên hệ với bạn trong DND.';

  @override
  String get quick_actions_heading => 'Hành động nhanh';

  @override
  String get select_distracting_apps_heading =>
      'Chọn ứng dụng gây mất tập trung';

  @override
  String get your_distracting_apps_heading =>
      'Ứng dụng gây mất tập trung của bạn';

  @override
  String get select_more_apps_heading => 'Chọn thêm ứng dụng';

  @override
  String get imp_distracting_apps_snack_alert =>
      'Không được phép thêm các ứng dụng hệ thống quan trọng vào danh sách các ứng dụng gây mất tập trung.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Việc sử dụng và hạn chế màn hình không có sẵn cho ứng dụng này. Hiện tại, chỉ có thể sử dụng mạng';

  @override
  String get create_group_fab_button => 'Tạo nhóm';

  @override
  String get active_period_info =>
      'Đặt khoảng thời gian trong đó quyền truy cập sẽ được cho phép. Ngoài khung thời gian này, quyền truy cập sẽ bị hạn chế.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Chọn ít nhất một ứng dụng gây mất tập trung.';

  @override
  String get donation_card_title => 'Hỗ trợ chúng tôi';

  @override
  String get donation_card_info =>
      'NLP digitox là mã nguồn mở và miễn phí, được phát triển sau nhiều tháng cống hiến. Nếu nó giúp ích được cho bạn thì khoản đóng góp của bạn sẽ có ý nghĩa rất lớn đối với chúng tôi. Mọi đóng góp đều giúp chúng tôi tiếp tục cải thiện và duy trì nó cho mọi người.';

  @override
  String get operation_failed_snack_alert =>
      'Thao tác không thành công, đã xảy ra lỗi!';

  @override
  String get donation_card_button_donate => 'Đóng góp';

  @override
  String get app_restart_dialog_title => 'Cần khởi động lại';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox sẽ tự động khởi động lại sau khi quá trình đếm ngược kết thúc. Hãy kiên nhẫn khi những thay đổi được áp dụng.';

  @override
  String get accessibility_tip =>
      'Bạn muốn chặn thông minh hơn, thân thiện với pin hơn? Bật quyền Trợ năng cho NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox không hoạt động? Cho phép \'Bỏ qua tối ưu hóa pin\' trong Cài đặt để giúp thiết bị hoạt động trơn tru.';

  @override
  String get invincible_mode_tip =>
      'Vô tình loại bỏ các hạn chế? Sử dụng Chế độ bất khả chiến bại để khóa chúng cho đến ngày hôm sau hoặc cửa sổ điều chỉnh.';

  @override
  String get glance_usage_tip =>
      'Muốn có thông tin chi tiết? Kiểm tra phần Glance để xem cách sử dụng và thời gian sử dụng thiết bị của bạn.';

  @override
  String get tamper_protection_tip =>
      'Gỡ cài đặt NLP digitox? Trước tiên, hãy bật Cửa sổ gỡ cài đặt để tắt tính năng bảo vệ chống giả mạo một cách an toàn.';

  @override
  String get notification_blocking_tip =>
      'Bạn muốn giảm phiền nhiễu? Sử dụng Chặn thông báo để tắt tiếng các ứng dụng đã chọn.';

  @override
  String get usage_history_tip =>
      'Bạn muốn suy ngẫm về thói quen của bạn? Kiểm tra Lịch sử sử dụng để xem các mẫu trong quá khứ.';

  @override
  String get focus_mode_tip =>
      'Cần tập trung sâu sắc? Bật Chế độ lấy nét để chặn ứng dụng và thông báo trong khi thực hiện tác vụ.';

  @override
  String get bedtime_reminder_tip =>
      'Bạn muốn cải thiện giấc ngủ của mình? Đặt Lời nhắc giờ đi ngủ để thư giãn hàng đêm.';

  @override
  String get custom_blocking_tip =>
      'Cần một trải nghiệm tùy chỉnh? Tạo quy tắc chặn ứng dụng phù hợp với nhu cầu của bạn.';

  @override
  String get session_timeline_tip =>
      'Bạn muốn theo dõi các phiên tập trung? Xem dòng thời gian để biết hành trình tập trung của bạn.';

  @override
  String get short_content_blocking_tip =>
      'Bị phân tâm bởi các ứng dụng xã hội? Chặn nội dung ngắn trên Instagram, YouTube, v.v. để duy trì sự tập trung.';

  @override
  String get parental_controls_tip =>
      'Cần sự kiểm soát của cha mẹ? Đặt giới hạn cho thiết bị của con bạn để đảm bảo trải nghiệm an toàn.';

  @override
  String get notification_batching_tip =>
      'Bạn muốn giảm phiền nhiễu? Sử dụng Thông báo hàng loạt để nhóm các thông báo và kiểm tra chúng cùng một lúc.';

  @override
  String get notification_scheduling_tip =>
      'Cần quản lý thông báo? Lên lịch khi bạn nhận được thông báo cho các ứng dụng cụ thể.';

  @override
  String get quick_focus_tile_tip =>
      'Cần truy cập nhanh để tập trung? Thêm Ô lấy nét nhanh để kích hoạt ngay Chế độ lấy nét.';

  @override
  String get app_shortcuts_tip =>
      'Bạn muốn truy cập ứng dụng ngay lập tức? Thêm phím tắt bằng cách nhấn và giữ biểu tượng ứng dụng để thao tác nhanh.';

  @override
  String get backup_usage_db_tip =>
      'Bạn muốn lưu dữ liệu của bạn? Sao lưu cơ sở dữ liệu sử dụng của bạn để giữ hồ sơ của bạn an toàn.';

  @override
  String get dynamic_material_color_tip =>
      'Muốn có một chủ đề tùy chỉnh? Bật Vật liệu động Màu sắc của bạn để phù hợp với chủ đề của thiết bị.';

  @override
  String get amoled_dark_theme_tip =>
      'Bạn muốn tiết kiệm pin? Sử dụng AMOLED Dark Theme để giảm mức tiêu thụ điện năng trên màn hình OLED.';

  @override
  String get customize_usage_history_tip =>
      'Bạn muốn giữ lịch sử sử dụng? Tùy chỉnh số tuần lưu trữ dữ liệu trong Lịch sử sử dụng.';

  @override
  String get grouped_apps_blocking_tip =>
      'Bạn muốn chặn các ứng dụng cùng nhau? Sử dụng Nhóm hạn chế để nhóm các giới hạn ứng dụng và chặn nhiều ứng dụng cùng một lúc.';

  @override
  String get websites_blocking_tip =>
      'Bạn muốn có trải nghiệm duyệt web sạch hơn? Chặn các trang web tùy chỉnh hoặc NSFW để có thời gian trực tuyến tập trung hơn.';

  @override
  String get data_usage_tip =>
      'Bạn muốn theo dõi dữ liệu của bạn? Giám sát việc sử dụng dữ liệu di động và Wi-Fi của bạn để sử dụng internet.';

  @override
  String get block_internet_tip =>
      'Cần chặn internet của ứng dụng? Cắt internet cho ứng dụng cụ thể từ bảng điều khiển của ứng dụng.';

  @override
  String get emergency_passes_tip =>
      'Cần nghỉ ngơi? Sử dụng 3 Thẻ khẩn cấp hàng ngày để tạm thời bỏ chặn ứng dụng trong 5 phút.';

  @override
  String get onboarding_skip_btn_label => 'Bỏ qua';

  @override
  String get onboarding_finish_setup_btn_label => 'Hoàn tất thiết lập';

  @override
  String get onboarding_page_welcome_title =>
      'Chào mừng bạn đến với NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Hãy làm chủ cuộc sống số của bạn và xây dựng thói quen sử dụng màn hình lành mạnh hơn. NLP digitox giúp bạn tập trung, giảm phiền nhiễu và đưa ra những lựa chọn có ý thức mỗi ngày.';

  @override
  String get onboarding_page_statistics_title => 'Hiểu thói quen của bạn.';

  @override
  String get onboarding_page_statistics_info =>
      'Hiểu các khuôn mẫu kỹ thuật số của bạn qua thông tin chi tiết về thời gian sử dụng màn hình, cách dùng ứng dụng và xu hướng tập trung. Theo dõi tiến trình và thấy những thay đổi nhỏ dẫn đến cải thiện lớn.';

  @override
  String get onboarding_page_one_title => 'Tập trung chính.';

  @override
  String get onboarding_page_one_info =>
      'Tạm dừng các ứng dụng gây mất tập trung, chặn nội dung ngắn và theo dõi các phiên tập trung có thể tùy chỉnh. Cho dù bạn đang làm việc, học tập hay thư giãn, NLP digitox đều giúp bạn luôn kiểm soát.';

  @override
  String get onboarding_page_two_title => 'Chặn phiền nhiễu.';

  @override
  String get onboarding_page_two_info =>
      'Đặt giới hạn sử dụng, tự động tạm dừng ứng dụng và tạo thói quen kỹ thuật số lành mạnh hơn. Sử dụng Chế độ giờ đi ngủ để thư giãn và tận hưởng một đêm không bị phân tâm.';

  @override
  String get onboarding_page_three_title => 'Quyền riêng tư đầu tiên.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox là nguồn mở 100% và hoạt động hoàn toàn ngoại tuyến. Chúng tôi không thu thập hoặc chia sẻ dữ liệu cá nhân của bạn - quyền riêng tư của bạn được đảm bảo bằng mọi cách.';

  @override
  String get onboarding_page_permissions_title => 'Quyền cần thiết.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox yêu cầu các quyền thiết yếu sau để theo dõi và quản lý thời gian sử dụng thiết bị của bạn, giúp giảm phiền nhiễu và cải thiện sự tập trung.';

  @override
  String get dashboard_tab_title => 'Trang tổng quan';

  @override
  String get focus_now_fab_button => 'Tập trung ngay bây giờ';

  @override
  String get welcome_greetings => 'Chào mừng trở lại,';

  @override
  String get username_snack_alert => 'Nhấn và giữ để chỉnh sửa tên người dùng.';

  @override
  String get username_dialog_title => 'Tên người dùng';

  @override
  String get username_dialog_info =>
      'Nhập tên người dùng của bạn sẽ được hiển thị trên bảng điều khiển.';

  @override
  String get username_dialog_button_apply => 'Áp dụng';

  @override
  String get glance_tile_title => 'Nhìn thoáng qua';

  @override
  String get glance_tile_subtitle => 'Hãy xem nhanh việc sử dụng của bạn.';

  @override
  String get parental_controls_tile_subtitle =>
      'Chế độ bất khả chiến bại và bảo vệ giả mạo.';

  @override
  String get restrictions_heading => 'Hạn chế';

  @override
  String get apps_blocking_tile_title => 'Chặn ứng dụng';

  @override
  String get apps_blocking_tile_subtitle =>
      'Giới hạn ứng dụng theo nhiều cách.';

  @override
  String get grouped_apps_blocking_tile_title => 'Chặn ứng dụng được nhóm';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Giới hạn nhóm ứng dụng cùng lúc.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Giới hạn nội dung ngắn trên nhiều nền tảng.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Hạn chế các trang web người lớn và tùy chỉnh.';

  @override
  String get screen_time_label => 'Thời gian sử dụng màn hình';

  @override
  String get total_data_label => 'Tổng số dữ liệu';

  @override
  String get mobile_data_label => 'Dữ liệu di động';

  @override
  String get wifi_data_label => 'Dữ liệu Wi-Fi';

  @override
  String get focus_today_label => 'Tập trung ngay hôm nay';

  @override
  String get focus_weekly_label => 'Tập trung hàng tuần';

  @override
  String get focus_monthly_label => 'Tập trung hàng tháng';

  @override
  String get focus_lifetime_label => 'tập trung trọn đời';

  @override
  String get longest_streak_label => 'Chuỗi dài nhất';

  @override
  String get current_streak_label => 'Chuỗi hiện tại';

  @override
  String get successful_sessions_label => 'Phiên thành công';

  @override
  String get failed_sessions_label => 'Phiên thất bại';

  @override
  String get statistics_tab_title => 'Thống kê';

  @override
  String get screen_segment_label => 'Màn hình';

  @override
  String get data_segment_label => 'dữ liệu';

  @override
  String get mobile_label => 'Điện thoại di động';

  @override
  String get wifi_label => 'Wifi';

  @override
  String get most_used_apps_heading => 'Ứng dụng được sử dụng nhiều nhất';

  @override
  String get show_all_apps_tile_title => 'Hiển thị tất cả ứng dụng';

  @override
  String get search_apps_hint => 'Tìm kiếm ứng dụng...';

  @override
  String get notifications_tab_title => 'Thông báo';

  @override
  String get notifications_tab_info =>
      'Thông báo hàng loạt từ các ứng dụng và đặt lịch như sáng, trưa, tối và tối. Luôn cập nhật mà không bị gián đoạn liên tục.';

  @override
  String get batched_apps_tile_title => 'Ứng dụng theo lô';

  @override
  String get batch_recap_dropdown_title => 'Loại tóm tắt hàng loạt';

  @override
  String get batch_recap_dropdown_info =>
      'Chọn nội dung cần đẩy khi lịch trình kích hoạt — tất cả thông báo hoặc chỉ là bản tóm tắt.';

  @override
  String get batch_recap_option_summery_only => 'Chỉ tóm tắt';

  @override
  String get batch_recap_option_all_notifications => 'Tất cả thông báo';

  @override
  String get notification_history_tile_title => 'Lịch sử thông báo';

  @override
  String get store_all_tile_title => 'Lưu trữ tất cả thông báo';

  @override
  String get store_all_tile_subtitle => 'Lưu thông báo không theo đợt.';

  @override
  String get schedules_heading => 'Lịch trình';

  @override
  String get new_schedule_fab_button => 'Lịch trình mới';

  @override
  String get new_schedule_dialog_info =>
      'Nhập tên cho lịch thông báo để giúp nhận biết dễ dàng.';

  @override
  String get new_schedule_dialog_field_label => 'Tên lịch trình';

  @override
  String get bedtime_tab_title => 'Giờ đi ngủ';

  @override
  String get bedtime_tab_info =>
      'Đặt lịch đi ngủ của bạn bằng cách chọn khoảng thời gian và các ngày trong tuần. Chọn các ứng dụng gây mất tập trung để chặn và bật chế độ Không làm phiền (DND) để có một đêm yên bình.';

  @override
  String get schedule_tile_title => 'lịch trình';

  @override
  String get schedule_tile_subtitle => 'Bật hoặc tắt lịch trình hàng ngày.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Chọn ít nhất một ngày trong tuần.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'Tổng thời gian đi ngủ phải ít nhất là 30 phút.';

  @override
  String get distracting_apps_tile_title => 'Ứng dụng gây mất tập trung';

  @override
  String get distracting_apps_tile_subtitle =>
      'Chọn những ứng dụng đang khiến bạn mất tập trung vào thói quen đi ngủ.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Không được phép sửa đổi danh sách các ứng dụng gây mất tập trung khi lịch đi ngủ đang hoạt động.';

  @override
  String get parental_controls_tab_title => 'Kiểm soát của phụ huynh';

  @override
  String get invincible_mode_heading => 'Chế độ bất khả chiến bại';

  @override
  String get invincible_mode_tile_title => 'Kích hoạt chế độ bất khả chiến bại';

  @override
  String get invincible_mode_info =>
      'Khi Chế độ Bất khả chiến bại được bật, bạn sẽ không thể điều chỉnh các giới hạn đã chọn sau khi đạt hạn mức hàng ngày của mình. Tuy nhiên, bạn có thể thực hiện các thay đổi trong khoảng thời gian bất khả chiến bại 10 phút đã chọn.';

  @override
  String get invincible_mode_snack_alert =>
      'Do chế độ bất khả chiến bại, không được phép sửa đổi các hạn chế.';

  @override
  String get invincible_mode_dialog_info =>
      'Bạn có chắc chắn muốn bật Chế độ bất khả chiến bại không? Hành động này là không thể đảo ngược. Khi Chế độ bất khả chiến bại được bật, bạn không thể tắt nó miễn là ứng dụng này được cài đặt trên thiết bị của bạn.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Không thể tắt Chế độ bất khả chiến bại miễn là ứng dụng này vẫn được cài đặt trên thiết bị của bạn.';

  @override
  String get invincible_mode_dialog_button_start_anyway => 'Vẫn bắt đầu';

  @override
  String get invincible_mode_include_timer_tile_title => 'Bao gồm bộ hẹn giờ';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Bao gồm giới hạn khởi chạy';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Bao gồm thời gian hoạt động';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'Hạn chế ứng dụng';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Ngăn chặn các thay đổi đối với các hạn chế đã chọn của ứng dụng sau khi vượt quá giới hạn hàng ngày.';

  @override
  String get invincible_mode_group_restrictions_tile_title => 'Hạn chế nhóm';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Ngăn chặn các thay đổi đối với các hạn chế đã chọn của nhóm khi vượt quá giới hạn hàng ngày.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Bao gồm bộ đếm thời gian ngắn';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Ngăn chặn những thay đổi sau khi đạt đến giới hạn bán khống hàng ngày của bạn.';

  @override
  String get invincible_mode_include_bedtime_tile_title => 'Bao gồm giờ đi ngủ';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Ngăn chặn những thay đổi trong lịch trình đi ngủ hoạt động.';

  @override
  String get protected_access_tile_title => 'Quyền truy cập được bảo vệ';

  @override
  String get protected_access_tile_subtitle =>
      'Bảo vệ NLP digitox bằng khóa thiết bị của bạn.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Trước tiên, hãy thiết lập khóa sinh trắc học trên thiết bị của bạn để bật tính năng này.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Khóa thiết bị của bạn đã bị xóa. Để tiếp tục, vui lòng thiết lập một khóa mới.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'Xác thực không thành công. Bạn cần xác minh khóa thiết bị của mình để tiếp tục.';

  @override
  String get tamper_protection_tile_title => 'Bảo vệ giả mạo';

  @override
  String get tamper_protection_tile_subtitle =>
      'Ngăn chặn việc gỡ cài đặt và buộc dừng ứng dụng.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Sau khi được bật, bạn sẽ không thể gỡ cài đặt, buộc dừng hoặc xóa dữ liệu của NLP digitox, ngoại trừ trong cửa sổ gỡ cài đặt đã chọn. Không có cách giải quyết nào.\n\nHãy tự chịu rủi ro khi tiếp tục.';

  @override
  String get uninstall_window_tile_title => 'Gỡ cài đặt cửa sổ';

  @override
  String get uninstall_window_tile_subtitle =>
      'Bảo vệ giả mạo có thể bị vô hiệu hóa trong vòng 10 phút kể từ thời gian đã chọn.';

  @override
  String get invincible_window_tile_title => 'Cửa sổ bất khả chiến bại';

  @override
  String get invincible_window_tile_subtitle =>
      'Giới hạn đã chọn có thể được sửa đổi trong vòng 10 phút kể từ thời điểm đã chọn.';

  @override
  String get shorts_blocking_tab_title => 'Chặn video ngắn';

  @override
  String get shorts_blocking_tab_info =>
      'Kiểm soát lượng thời gian bạn dành cho nội dung ngắn trên các nền tảng như Instagram, YouTube, Snapchat và Facebook, bao gồm cả trang web của họ.';

  @override
  String get short_content_heading => 'Nội dung ngắn';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Còn lại từ $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Đặt giới hạn thời gian hàng ngày cho nội dung ngắn. Sau khi đạt đến giới hạn của bạn, nội dung ngắn sẽ bị tạm dừng cho đến nửa đêm.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Hạn chế các tính năng trên instagram.';

  @override
  String get instagram_features_block_reels => 'Hạn chế phần cuộn.';

  @override
  String get instagram_features_block_explore => 'Hạn chế phần khám phá.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Hạn chế các tính năng trên Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Hạn chế phần ánh đèn sân khấu.';

  @override
  String get snapchat_features_block_discover => 'Hạn chế phần khám phá.';

  @override
  String get youtube_features_tile_title => 'Youtube';

  @override
  String get youtube_features_tile_subtitle =>
      'Hạn chế quần short trên youtube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Hạn chế quay phim trên facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle => 'Hạn chế quần short trên reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle =>
      'Hạn chế nguồn cấp dữ liệu video trên X.';

  @override
  String get threads_features_tile_title => 'chủ đề';

  @override
  String get threads_features_tile_subtitle =>
      'Hạn chế video/cuộn trên Chủ đề.';

  @override
  String get websites_blocking_tab_title => 'Chặn trang web';

  @override
  String get websites_blocking_tab_info =>
      'Chặn các trang web người lớn và bất kỳ trang web tùy chỉnh nào bạn chọn để tạo trải nghiệm trực tuyến an toàn hơn và tập trung hơn. Chịu trách nhiệm về việc duyệt web của bạn và không bị phân tâm.';

  @override
  String get adult_content_heading => 'Nội dung người lớn';

  @override
  String get block_nsfw_title => 'Chặn Nsfw';

  @override
  String get block_nsfw_subtitle =>
      'Hạn chế trình duyệt mở các trang web người lớn và khiêu dâm.';

  @override
  String get block_nsfw_dialog_info =>
      'Bạn có chắc không? Hành động này là không thể đảo ngược. Sau khi BẬT trình chặn trang web người lớn, bạn không thể TẮT nó miễn là ứng dụng này được cài đặt trên thiết bị của bạn.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Vẫn chặn';

  @override
  String get blocked_websites_heading => 'Trang web bị chặn';

  @override
  String get blocked_websites_empty_list_hint =>
      'Nhấp vào nút \'+ Thêm trang web\' để thêm các trang web gây mất tập trung mà bạn muốn chặn.';

  @override
  String get add_website_fab_button => 'Thêm trang web';

  @override
  String get add_website_dialog_title => 'Trang web gây mất tập trung';

  @override
  String get add_website_dialog_info => 'Nhập url của trang web bạn muốn chặn.';

  @override
  String get add_website_dialog_is_nsfw => 'Là trang web nsfw?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Cảnh báo: Không thể xóa các trang Nsfw sau khi đã thêm.';

  @override
  String get add_website_dialog_button_block => 'Chặn';

  @override
  String get add_website_already_exist_snack_alert =>
      'URL đã được thêm vào danh sách các trang web bị chặn.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'URL không hợp lệ! Không thể phân tích tên máy chủ.';

  @override
  String get remove_website_dialog_title => 'Xóa trang web';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Bạn có chắc không? bạn muốn xóa \'$websitehost\' khỏi các trang web bị chặn.';
  }

  @override
  String get focus_tab_title => 'Tập trung';

  @override
  String get focus_tab_info =>
      'Khi bạn cần thời gian để tập trung, hãy bắt đầu một phiên mới bằng cách chọn loại, chọn các ứng dụng gây mất tập trung để tạm dừng và bật Không làm phiền để không bị gián đoạn tập trung.';

  @override
  String get active_session_card_title => 'Phiên hoạt động';

  @override
  String get active_session_card_info =>
      'Bạn có một phiên tập trung đang hoạt động! Nhấp vào \'Xem\' để kiểm tra tiến trình của bạn và xem thời gian đã trôi qua.';

  @override
  String get active_session_card_view_button => 'Xem';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'Không được phép xóa ứng dụng khỏi danh sách ứng dụng gây mất tập trung khi Phiên tập trung đang hoạt động. Tuy nhiên, bạn vẫn có thể thêm ứng dụng bổ sung vào danh sách trong thời gian này.';

  @override
  String get focus_profile_tile_title => 'Hồ sơ tập trung';

  @override
  String get focus_session_duration_tile_title => 'Thời lượng phiên';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Vô hạn (trừ khi bạn dừng lại)';

  @override
  String get focus_session_duration_dialog_info =>
      'Vui lòng chọn thời lượng mong muốn cho phiên tập trung này, xác định xem bạn muốn duy trì sự tập trung và không bị phân tâm trong bao lâu.';

  @override
  String get focus_profile_customization_tile_title => 'Tùy chỉnh hồ sơ';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Tùy chỉnh cài đặt cho cấu hình đã chọn.';

  @override
  String get focus_enforce_tile_title => 'Thực thi phiên';

  @override
  String get focus_enforce_tile_subtitle =>
      'Ngăn chặn việc kết thúc phiên trước khi hết thời gian.';

  @override
  String get focus_session_start_button => 'Vuốt để bắt đầu phiên';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Chọn ít nhất một ứng dụng gây mất tập trung để bắt đầu phiên tập trung';

  @override
  String get focus_session_already_active_snack_alert =>
      'Bạn đã có một phiên tập trung đang hoạt động. Vui lòng hoàn thành hoặc dừng phiên hiện tại của bạn trước khi bắt đầu phiên mới.';

  @override
  String get focus_session_type_study => 'học tập';

  @override
  String get focus_session_type_work => 'công việc';

  @override
  String get focus_session_type_exercise => 'tập thể dục';

  @override
  String get focus_session_type_meditation => 'Thiền';

  @override
  String get focus_session_type_creativeWriting => 'Viết sáng tạo';

  @override
  String get focus_session_type_reading => 'Đọc';

  @override
  String get focus_session_type_programming => 'Lập trình';

  @override
  String get focus_session_type_chores => 'Công việc nhà';

  @override
  String get focus_session_type_projectPlanning => 'Lập kế hoạch dự án';

  @override
  String get focus_session_type_artAndDesign => 'Nghệ thuật và Thiết kế';

  @override
  String get focus_session_type_languageLearning => 'Học ngôn ngữ';

  @override
  String get focus_session_type_musicPractice => 'Luyện tập âm nhạc';

  @override
  String get focus_session_type_selfCare => 'Tự chăm sóc';

  @override
  String get focus_session_type_brainstorming => 'Động não';

  @override
  String get focus_session_type_skillDevelopment => 'Phát triển kỹ năng';

  @override
  String get focus_session_type_research => 'Nghiên cứu';

  @override
  String get focus_session_type_networking => 'Mạng';

  @override
  String get focus_session_type_cooking => 'nấu ăn';

  @override
  String get focus_session_type_sportsTraining => 'Huấn luyện thể thao';

  @override
  String get focus_session_type_restAndRelaxation => 'Nghỉ ngơi và thư giãn';

  @override
  String get focus_session_type_other => 'Khác';

  @override
  String get timeline_tab_title => 'Dòng thời gian';

  @override
  String get focus_timeline_tab_info =>
      'Khám phá hành trình tập trung của bạn bằng cách chọn một ngày từ lịch. Theo dõi tiến trình của bạn, xem lại những thành công của bạn và học hỏi từ những thử thách.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Tổng thời gian làm việc hiệu quả của bạn trong tháng đã chọn là $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Ngày năng suất';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Bạn đã có tổng cộng $daysCount ngày làm việc hiệu quả trong tháng đã chọn.';
  }

  @override
  String get selected_day_focused_time_label => 'thời gian tập trung';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Tổng thời gian tập trung của bạn cho ngày đã chọn là $timeString.';
  }

  @override
  String get calender_heading => 'Lịch';

  @override
  String get your_sessions_heading => 'Phiên của bạn';

  @override
  String get your_sessions_empty_list_hint =>
      'Không có phiên tập trung nào được ghi lại cho ngày đã chọn.';

  @override
  String get focus_session_tile_timestamp_label => 'Dấu thời gian';

  @override
  String get focus_session_tile_duration_label => 'Thời lượng';

  @override
  String get focus_session_tile_reflection_label => 'Sự phản chiếu';

  @override
  String get focus_session_state_active => 'Đang hoạt động';

  @override
  String get focus_session_state_successful => 'thành công';

  @override
  String get focus_session_state_failed => 'thất bại';

  @override
  String get active_session_tab_title => 'Phiên';

  @override
  String get active_session_none_warning =>
      'Không tìm thấy phiên hoạt động nào. Trở lại màn hình chính.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Tiếp tục đẩy';

  @override
  String get active_session_finish_dialog_title => 'Kết thúc';

  @override
  String get active_session_finish_dialog_info =>
      'Hãy mạnh mẽ lên! Bạn đang xây dựng sự tập trung có giá trị. Bạn có chắc chắn muốn kết thúc phiên tập trung này không? Mỗi khoảnh khắc thêm đều được tính vào mục tiêu của bạn.';

  @override
  String get active_session_giveup_dialog_title => 'từ bỏ';

  @override
  String get active_session_giveup_dialog_info =>
      'Đợi đã! Bạn sắp đến đích rồi, đừng bỏ cuộc ngay bây giờ! Bạn có chắc chắn muốn kết thúc sớm phiên tập trung này không? Sự tiến bộ sẽ bị mất.';

  @override
  String get active_session_reflection_dialog_title => 'Phản ánh phiên';

  @override
  String get active_session_reflection_dialog_info =>
      'Hãy dành một chút thời gian để suy ngẫm về sự tiến bộ của bạn. Mục tiêu của bạn cho buổi học này là gì? Bạn đã đạt được điều gì trong buổi học này?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Mẹo: Bạn luôn có thể chỉnh sửa phần này sau trong dòng thời gian của phiên.';

  @override
  String get active_session_giveup_snack_alert =>
      'Bạn đã bỏ cuộc! Đừng lo lắng, lần sau bạn có thể làm tốt hơn. Mọi nỗ lực đều có giá trị - hãy cứ tiếp tục';

  @override
  String get active_session_quote_one =>
      'Mỗi bước đều có giá trị, hãy mạnh mẽ và tiếp tục đi';

  @override
  String get active_session_quote_two =>
      'Hãy tập trung! bạn đang đạt được tiến bộ đáng kinh ngạc';

  @override
  String get active_session_quote_three =>
      'Bạn đang nghiền nát nó! Giữ đà phát triển';

  @override
  String get active_session_quote_four =>
      'Chỉ còn một chút nữa thôi, bạn đang làm rất tốt';

  @override
  String active_session_quote_five(String durationString) {
    return 'Xin chúc mừng 🎉 \n Bạn đã hoàn thành phiên tập trung của $durationString.\n\nLàm tốt lắm, hãy tiếp tục phát huy nhé';
  }

  @override
  String get restriction_groups_tab_title => 'Nhóm hạn chế';

  @override
  String get restriction_groups_tab_info =>
      'Đặt giới hạn thời gian sử dụng thiết bị kết hợp cho một nhóm ứng dụng. Sau khi tổng mức sử dụng đạt đến giới hạn của bạn, tất cả ứng dụng trong nhóm sẽ bị tạm dừng để giúp duy trì sự tập trung và cân bằng.';

  @override
  String get restriction_group_time_spent_label =>
      'Thời gian dành cho ngày hôm nay';

  @override
  String get restriction_group_time_left_label => 'Thời gian còn lại hôm nay';

  @override
  String get restriction_group_name_tile_title => 'Tên nhóm';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Nhập tên cho nhóm hạn chế để giúp nhận biết và quản lý dễ dàng.';

  @override
  String get restriction_group_timer_tile_title => 'Hẹn giờ nhóm';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Đặt giới hạn thời gian hàng ngày cho nhóm này. Sau khi đạt đến giới hạn của bạn, tất cả ứng dụng trong nhóm này sẽ bị tạm dừng cho đến nửa đêm.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Thời gian hoạt động nhóm';

  @override
  String get remove_restriction_group_dialog_title => 'Xóa nhóm';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Bạn có chắc không? bạn muốn xóa \'$groupName\' khỏi các nhóm hạn chế.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Đặt bộ hẹn giờ hoặc giới hạn thời gian hoạt động.';

  @override
  String get notifications_empty_list_hint =>
      'Không có thông báo nào được gửi theo đợt trong ngày.';

  @override
  String get conversations_label => 'Cuộc trò chuyện';

  @override
  String get last_24_hours_heading => '24 giờ qua';

  @override
  String get notification_timeline_tab_info =>
      'Duyệt lịch sử thông báo của bạn bằng cách chọn một ngày từ lịch. Xem ứng dụng nào đã thu hút sự chú ý của bạn và phản ánh thói quen sử dụng kỹ thuật số của bạn.';

  @override
  String get monthly_label => 'hàng tháng';

  @override
  String get daily_label => 'hàng ngày';

  @override
  String get search_notifications_sheet_info =>
      'Dễ dàng tìm thấy các thông báo trước đây bằng cách tìm kiếm thông qua tiêu đề hoặc nội dung của chúng. Giúp bạn nhanh chóng xác định vị trí các cảnh báo quan trọng.';

  @override
  String get search_notifications_hint => 'Tìm kiếm thông báo...';

  @override
  String get search_notifications_empty_list_hint =>
      'Không tìm thấy thông báo nào phù hợp với tìm kiếm của bạn.';

  @override
  String get app_info_none_warning =>
      'Không thể tìm thấy ứng dụng cho gói đã cho. Trở lại màn hình chính.';

  @override
  String get emergency_fab_button => 'khẩn cấp';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Hành động này sẽ tạm dừng trình chặn ứng dụng trong 5 phút tiếp theo. Bạn còn lại thẻ $leftPassesCount. Sau khi sử dụng tất cả các thẻ, ứng dụng sẽ bị chặn cho đến nửa đêm hoặc phiên tập trung hiện hoạt kết thúc.\n\nBạn vẫn muốn tiếp tục phải không?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Vẫn sử dụng';

  @override
  String get emergency_started_snack_alert =>
      'Trình chặn ứng dụng bị tạm dừng và sẽ tiếp tục chặn sau 5 phút.';

  @override
  String get emergency_already_active_snack_alert =>
      'Trình chặn ứng dụng hiện đang bị tạm dừng hoặc không hoạt động. Nếu thông báo được bật, bạn sẽ nhận được thông tin cập nhật về thời gian còn lại.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Bạn đã sử dụng tất cả thẻ khẩn cấp của mình. Các ứng dụng bị chặn sẽ vẫn bị chặn cho đến nửa đêm hoặc phiên tập trung hiện hoạt kết thúc.';

  @override
  String get app_limit_status_not_set => 'Chưa đặt';

  @override
  String get app_timer_tile_title => 'hẹn giờ ứng dụng';

  @override
  String get app_timer_picker_dialog_info =>
      'Đặt giới hạn thời gian hàng ngày cho ứng dụng này. Khi đạt đến giới hạn của bạn, ứng dụng sẽ bị tạm dừng cho đến nửa đêm.';

  @override
  String get usage_reminders_tile_title => 'Lời nhắc sử dụng';

  @override
  String get usage_reminders_tile_subtitle =>
      'Cú huých nhẹ nhàng khi sử dụng các ứng dụng hẹn giờ.';

  @override
  String get app_launch_limit_tile_title => 'Giới hạn khởi chạy';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Đã ra mắt $count lần hôm nay.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Đặt số lần bạn có thể mở ứng dụng này mỗi ngày. Khi đạt đến giới hạn, nó sẽ bị tạm dừng cho đến nửa đêm.';

  @override
  String get app_active_period_tile_title => 'Thời gian hoạt động';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'Từ $startTime đến $endTime';
  }

  @override
  String get internet_access_tile_title => 'truy cập Internet';

  @override
  String get internet_access_tile_subtitle =>
      'Tắt để chặn internet của ứng dụng.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Internet của $appName bị chặn.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Internet của $appName không bị chặn.';
  }

  @override
  String get launch_app_tile_title => 'Khởi chạy ứng dụng';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Mở $appName.';
  }

  @override
  String get go_to_app_settings_tile_title => 'Đi tới cài đặt ứng dụng';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Quản lý cài đặt ứng dụng như thông báo, quyền, bộ nhớ, v.v.';

  @override
  String get include_in_stats_tile_title => 'Bao gồm việc sử dụng màn hình';

  @override
  String get include_in_stats_tile_subtitle =>
      'Tắt để loại trừ ứng dụng này khỏi tổng mức sử dụng màn hình.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName bị loại trừ khỏi tổng mức sử dụng màn hình.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName được tính vào tổng mức sử dụng màn hình.';
  }

  @override
  String get general_tab_title => 'chung';

  @override
  String get appearance_heading => 'Ngoại hình';

  @override
  String get theme_mode_tile_title => 'Chế độ chủ đề';

  @override
  String get theme_mode_system_label => 'Hệ thống';

  @override
  String get theme_mode_light_label => 'Ánh sáng';

  @override
  String get theme_mode_dark_label => 'Tối';

  @override
  String get material_color_tile_title => 'Màu vật liệu';

  @override
  String get amoled_dark_tile_title => 'AMOLED tối';

  @override
  String get amoled_dark_tile_subtitle =>
      'Sử dụng màu đen thuần khiết cho chủ đề tối.';

  @override
  String get dynamic_colors_tile_title => 'Màu sắc năng động';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Sử dụng màu sắc của thiết bị nếu được hỗ trợ.';

  @override
  String get defaults_heading => 'Mặc định';

  @override
  String get app_language_tile_title => 'Ngôn ngữ ứng dụng';

  @override
  String get default_home_tab_tile_title => 'tab Trang chủ';

  @override
  String get usage_history_tile_title => 'Lịch sử sử dụng';

  @override
  String get usage_history_15_days => '15 ngày';

  @override
  String get usage_history_1_month => '1 tháng';

  @override
  String get usage_history_3_month => '3 tháng';

  @override
  String get usage_history_6_month => '6 tháng';

  @override
  String get usage_history_1_year => '1 năm';

  @override
  String get service_heading => 'Dịch vụ';

  @override
  String get service_stopping_warning =>
      'Nếu NLP digitox ngừng hoạt động đột ngột, vui lòng cấp quyền \'Bỏ qua tối ưu hóa pin\' để ứng dụng tiếp tục chạy ở chế độ nền. Nếu sự cố vẫn tiếp diễn, hãy thử đưa NLP digitox vào danh sách trắng để có hiệu suất không bị gián đoạn.';

  @override
  String get whitelist_app_tile_title => 'Danh sách trắng NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Cho phép NLP digitox tự động khởi động.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Thiết bị này không hỗ trợ quản lý khởi động tự động.';

  @override
  String get database_tab_title => 'Cơ sở dữ liệu';

  @override
  String get import_db_tile_title => 'Nhập cơ sở dữ liệu';

  @override
  String get import_db_tile_subtitle => 'Nhập cơ sở dữ liệu từ một tập tin.';

  @override
  String get export_db_tile_title => 'Xuất cơ sở dữ liệu';

  @override
  String get export_db_tile_subtitle => 'Xuất cơ sở dữ liệu sang một tập tin.';

  @override
  String get analysis_tab_title => 'Phân tích';

  @override
  String get analysis_7_days => '7 ngày';

  @override
  String get analysis_30_days => '30 ngày';

  @override
  String get analysis_90_days => '90 ngày';

  @override
  String get analysis_screen_time_trend =>
      'Xu hướng thời gian sử dụng màn hình';

  @override
  String get analysis_no_data_info =>
      'Chưa có dữ liệu thời gian sử dụng màn hình cho giai đoạn này.';

  @override
  String get analysis_daily_average => 'Trung bình mỗi ngày';

  @override
  String get analysis_total => 'Tổng';

  @override
  String get analysis_no_change => 'Giống tuần trước';

  @override
  String analysis_trend_less(String percent) {
    return 'ít hơn $percent% so với tuần trước';
  }

  @override
  String analysis_trend_more(String percent) {
    return 'nhiều hơn $percent% so với tuần trước';
  }

  @override
  String get crash_logs_heading => 'Nhật ký sự cố';

  @override
  String get crash_logs_info =>
      'Nếu gặp bất kỳ vấn đề nào, bạn có thể báo cáo trên GitHub cùng với tệp nhật ký. Tệp sẽ bao gồm các chi tiết như nhà sản xuất, kiểu máy, phiên bản Android, phiên bản SDK và nhật ký sự cố của thiết bị. Thông tin này sẽ giúp chúng tôi xác định và giải quyết vấn đề hiệu quả hơn.';

  @override
  String get crash_logs_export_tile_title => 'Xuất nhật ký sự cố';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Xuất nhật ký sự cố sang tệp json.';

  @override
  String get crash_logs_view_tile_title => 'Xem nhật ký';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Khám phá nhật ký sự cố được lưu trữ.';

  @override
  String get crash_logs_empty_list_hint =>
      'Không có sự cố nào được ghi lại cho đến bây giờ.';

  @override
  String get crash_logs_clear_tile_title => 'Xóa nhật ký';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Xóa tất cả nhật ký sự cố khỏi cơ sở dữ liệu.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Bạn có chắc chắn muốn xóa tất cả nhật ký sự cố khỏi cơ sở dữ liệu không?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => 'Vẫn xóa';

  @override
  String get about_tab_title => 'Giới thiệu';

  @override
  String get changelog_tile_title => 'Nhật ký thay đổi';

  @override
  String get changelog_tile_subtitle => 'Tìm hiểu những gì mới.';

  @override
  String get full_changelog_tile_title => 'Nhật ký thay đổi đầy đủ';

  @override
  String get redirected_to_github_subtitle =>
      'Bạn sẽ được chuyển hướng đến GitHub.';

  @override
  String get contribute_heading => 'Đóng góp';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Xem mã nguồn.';

  @override
  String get report_issue_tile_title => 'Báo cáo sự cố';

  @override
  String get suggest_idea_tile_title => 'Đề xuất một ý tưởng';

  @override
  String get write_email_tile_title => 'Viết thư cho chúng tôi qua email';

  @override
  String get write_email_tile_subtitle =>
      'Bạn sẽ được chuyển hướng đến ứng dụng Email.';

  @override
  String get privacy_policy_heading => 'Chính sách bảo mật';

  @override
  String get privacy_policy_info =>
      'NLP digitox cam kết bảo vệ quyền riêng tư của bạn. Chúng tôi không thu thập, lưu trữ hoặc chuyển bất kỳ loại dữ liệu người dùng nào. Ứng dụng hoạt động hoàn toàn ngoại tuyến và không yêu cầu kết nối internet, đảm bảo thông tin cá nhân của bạn được giữ riêng tư và an toàn trên thiết bị của bạn. Là một ứng dụng Phần mềm nguồn mở và miễn phí (FOSS), NLP digitox đảm bảo tính minh bạch hoàn toàn và quyền kiểm soát của người dùng đối với dữ liệu của họ.';

  @override
  String get more_details_button => 'Thêm chi tiết';
}
