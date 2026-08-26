// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get mindful_tagline => '진정으로 중요한 것에 집중하세요';

  @override
  String get unlock_button_label => '잠금 해제';

  @override
  String get permission_status_off => '끄기';

  @override
  String get permission_status_allowed => '허용됨';

  @override
  String get permission_status_not_allowed => '허용되지 않음';

  @override
  String get permission_button_grant_permission => '권한 부여';

  @override
  String get permission_button_agree_and_continue => '동의 및 계속';

  @override
  String get permission_button_not_now => '지금은 아님';

  @override
  String get permission_button_help => '도움이 되나요?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox는 100% 안전하며 오프라인에서 작동합니다. 우리는 개인 데이터를 수집하거나 저장하지 않습니다.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. $button_label 버튼을 클릭합니다.';
  }

  @override
  String get permission_grant_step_two => '2. 다음 화면에서 NLP digitox를 선택하세요.';

  @override
  String get permission_grant_step_three => '3. 아래와 같이 스위치를 클릭하고 켜주세요.';

  @override
  String get permission_notification_title => '알림 보내기';

  @override
  String get permission_alarms_title => '알람 및 알림';

  @override
  String get permission_alarms_info =>
      '알람 및 알림 설정 권한을 부여해 주세요. 이렇게 하면 NLP digitox가 정시에 취침 시간 일정을 시작하고 매일 자정에 앱 타이머를 재설정하여 순조롭게 지내는 데 도움이 됩니다.';

  @override
  String get permission_alarms_device_tile_label => '알람 및 미리 알림 설정 허용';

  @override
  String get permission_usage_title => '사용 액세스';

  @override
  String get permission_usage_info =>
      '사용 접근 권한을 부여해주세요. 이를 통해 NLP digitox는 앱 사용을 모니터링하고 특정 앱에 대한 액세스를 관리하여 보다 집중적이고 통제된 디지털 환경을 보장할 수 있습니다.';

  @override
  String get permission_usage_device_tile_label => '사용 액세스 허용';

  @override
  String get permission_overlay_title => '디스플레이 오버레이';

  @override
  String get permission_overlay_info =>
      '디스플레이 오버레이 권한을 부여해 주세요. 이렇게 하면 일시 중지된 앱이 열릴 때 NLP digitox가 오버레이를 표시하여 집중력을 유지하고 일정을 유지하는 데 도움이 됩니다.';

  @override
  String get permission_overlay_device_tile_label => '다른 앱 위에 표시 허용';

  @override
  String get permission_accessibility_title => '접근성';

  @override
  String get permission_accessibility_info =>
      '접근성 권한을 부여해 주세요. 이를 통해 NLP digitox는 소셜 미디어 앱 및 브라우저 내에서 짧은 형식의 비디오 콘텐츠(예: 릴, 반바지)에 대한 액세스를 제한하고 부적절한 웹사이트를 필터링할 수 있습니다.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox는 짧은 콘텐츠와 웹사이트를 효과적으로 차단하려면 접근성 권한이 필요합니다.';

  @override
  String get permission_accessibility_device_tile_label => 'NLP digitox 사용';

  @override
  String get permission_dnd_title => '방해하지 마세요';

  @override
  String get permission_dnd_info =>
      '방해금지 액세스 권한을 부여해 주세요. 이렇게 하면 NLP digitox가 취침 시간 동안 방해 금지 모드를 시작하고 중지할 수 있습니다.';

  @override
  String get permission_dnd_tile_title => '방해 금지 모드 시작';

  @override
  String get permission_dnd_tile_subtitle => '방해금지 모드도 활성화하세요.';

  @override
  String get permission_battery_optimization_tile_title => '배터리 최적화 무시';

  @override
  String get permission_battery_optimization_status_enabled => '이미 제한이 없습니다.';

  @override
  String get permission_battery_optimization_status_disabled => '배경 제한 비활성화';

  @override
  String get permission_battery_optimization_allow_info =>
      '\'배터리 최적화 무시\'를 허용하면 일부 기기에서 \'알람 및 미리 알림\' 권한이 자동으로 부여됩니다.';

  @override
  String get permission_vpn_title => 'VPN 만들기';

  @override
  String get permission_vpn_info =>
      '가상 사설망(VPN) 연결을 생성할 수 있는 권한을 부여해 주세요. 이를 통해 NLP digitox는 장치 VPN에 로컬을 생성하여 지정된 애플리케이션에 대한 인터넷 액세스를 제한할 수 있습니다.';

  @override
  String get permission_admin_title => '관리자';

  @override
  String get permission_admin_info =>
      '관리자 권한은 앱이 제대로 작동하고 변조 방지를 유지하기 위해 필수적인 작업에만 필요합니다.';

  @override
  String get permission_admin_snack_alert => '변조 방지는 선택한 기간 동안에만 비활성화할 수 있습니다.';

  @override
  String get permission_notification_access_title => '알림 액세스';

  @override
  String get permission_notification_access_info =>
      '알림 접근 권한을 부여해 주세요. 이렇게 하면 NLP digitox가 알림을 구성하고 일정에 따라 전달할 수 있습니다.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox에는 일괄 및 일정 알림에 대한 알림 액세스가 필요합니다.';

  @override
  String get permission_notification_access_device_tile_label => '알림 액세스 허용';

  @override
  String get day_today => '오늘';

  @override
  String get day_yesterday => '어제';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 일',
      one: '1 일',
      zero: '0 일',
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
      other: '$countString 시간',
      one: '1 시간',
      zero: '0 시간',
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
      other: '$countString 분',
      one: '1 분',
      zero: '0 분',
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
      other: '$countString 초',
      one: '1 초',
      zero: '0 초',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => '그리고';

  @override
  String get timer_status_active => '활성';

  @override
  String get timer_status_paused => '일시중지됨';

  @override
  String get create_button => '만들기';

  @override
  String get update_button => '업데이트';

  @override
  String get dialog_button_cancel => '취소';

  @override
  String get dialog_button_remove => '제거';

  @override
  String get dialog_button_set => '세트';

  @override
  String get dialog_button_reset => '재설정';

  @override
  String get dialog_button_infinite => '무한';

  @override
  String get schedule_start_label => '시작';

  @override
  String get schedule_end_label => '끝';

  @override
  String get exit_without_saving_dialog_info => '저장하지 않고 종료하시겠습니까?';

  @override
  String get development_dialog_info =>
      'NLP digitox는 현재 개발 중이므로 버그나 불완전한 기능이 있을 수 있습니다. 문제가 발생하면 개선할 수 있도록 신고해 주세요.\n\n의견을 보내주셔서 감사합니다!';

  @override
  String get development_dialog_button_report_issue => '문제 보고';

  @override
  String get development_dialog_button_close => '닫기';

  @override
  String get dnd_settings_tile_title => '방해 금지 설정';

  @override
  String get dnd_settings_tile_subtitle => 'DND에서 나에게 연락할 수 있는 앱과 알림을 관리합니다.';

  @override
  String get quick_actions_heading => '빠른 작업';

  @override
  String get select_distracting_apps_heading => '방해가 되는 앱 선택';

  @override
  String get your_distracting_apps_heading => '방해가 되는 앱';

  @override
  String get select_more_apps_heading => '더 많은 앱 선택';

  @override
  String get imp_distracting_apps_snack_alert =>
      '방해가 되는 앱 목록에 중요한 시스템 앱을 추가하는 것은 허용되지 않습니다.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      '이 애플리케이션에서는 화면 사용 및 제한을 사용할 수 없습니다. 현재는 네트워크 사용만 가능합니다';

  @override
  String get create_group_fab_button => '그룹 만들기';

  @override
  String get active_period_info => '접근이 허용되는 기간을 설정하세요. 해당 시간 외에는 출입이 제한됩니다.';

  @override
  String get minimum_distracting_apps_snack_alert => '방해가 되는 앱을 하나 이상 선택하세요.';

  @override
  String get donation_card_title => '우리를 지원하세요';

  @override
  String get donation_card_info =>
      'NLP digitox는 수개월 간의 노력을 통해 개발된 무료 오픈 소스입니다. 그것이 당신에게 도움이 되었다면 당신의 기부는 우리에게 세상을 의미할 것입니다. 모든 기여는 우리가 모든 사람을 위해 이를 지속적으로 개선하고 유지하는 데 도움이 됩니다.';

  @override
  String get operation_failed_snack_alert => '작업이 실패했습니다. 문제가 발생했습니다.';

  @override
  String get donation_card_button_donate => '기부';

  @override
  String get app_restart_dialog_title => '다시 시작해야 함';

  @override
  String get app_restart_dialog_info =>
      '카운트다운이 완료되면 NLP digitox가 자동으로 다시 시작됩니다. 변경 사항이 적용되므로 기다려 주시기 바랍니다.';

  @override
  String get accessibility_tip =>
      '더 스마트하고 배터리 친화적인 차단을 원하시나요? NLP digitox에 대한 접근성 권한을 활성화합니다.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox가 작동하지 않나요? 원활한 실행을 유지하려면 설정에서 \'배터리 최적화 무시\'를 허용하세요.';

  @override
  String get invincible_mode_tip =>
      '실수로 제한사항을 제거했나요? 무적 모드를 사용하여 다음 날 또는 조정 기간까지 잠급니다.';

  @override
  String get glance_usage_tip =>
      '통찰력을 원하시나요? 사용 패턴과 화면 시간을 보려면 한눈에 보기 섹션을 확인하세요.';

  @override
  String get tamper_protection_tip =>
      'NLP digitox를 제거하시겠습니까? 먼저 변조 방지를 안전하게 비활성화하려면 제거 창을 활성화하십시오.';

  @override
  String get notification_blocking_tip =>
      '방해 요소를 줄이고 싶나요? 알림 차단을 사용하여 선택한 앱을 무음으로 설정하세요.';

  @override
  String get usage_history_tip =>
      '당신의 습관을 되돌아보고 싶습니까? 과거 패턴을 보려면 사용 내역을 확인하세요.';

  @override
  String get focus_mode_tip => '깊은 집중이 필요하신가요? 작업 중에 앱과 알림을 차단하려면 집중 모드를 켜세요.';

  @override
  String get bedtime_reminder_tip =>
      '수면을 개선하고 싶나요? 밤마다 긴장을 풀 수 있도록 취침 시간 알림을 설정하세요.';

  @override
  String get custom_blocking_tip => '맞춤형 경험이 필요하신가요? 필요에 맞는 앱 차단 규칙을 만드세요.';

  @override
  String get session_timeline_tip =>
      '집중 세션을 추적하고 싶으십니까? 타임라인을 보고 집중 여정을 확인하세요.';

  @override
  String get short_content_blocking_tip =>
      '소셜 앱 때문에 주의가 산만해졌나요? 집중할 수 있도록 Instagram, YouTube 등의 짧은 콘텐츠를 차단하세요.';

  @override
  String get parental_controls_tip =>
      '자녀 보호 기능이 필요하신가요? 안전한 환경을 보장하기 위해 자녀의 장치에 제한을 설정하세요.';

  @override
  String get notification_batching_tip =>
      '방해 요소를 줄이고 싶나요? 알림 일괄 처리를 사용하면 알림을 그룹화하여 한 번에 확인할 수 있습니다.';

  @override
  String get notification_scheduling_tip =>
      '알림을 관리해야 합니까? 특정 앱에 대한 알림을 언제 받을지 예약하세요.';

  @override
  String get quick_focus_tile_tip =>
      '집중하는 데 빠르게 접근해야 합니까? Quick Focus 타일을 추가하면 집중 모드가 즉시 활성화됩니다.';

  @override
  String get app_shortcuts_tip =>
      '즉각적인 앱 액세스를 원하시나요? 빠른 작업을 위해 앱 아이콘을 길게 눌러 바로가기를 추가하세요.';

  @override
  String get backup_usage_db_tip =>
      '데이터를 저장하고 싶나요? 기록을 안전하게 보관하려면 사용 데이터베이스를 백업하세요.';

  @override
  String get dynamic_material_color_tip =>
      '맞춤 테마를 원하시나요? 동적 소재 활성화 장치의 테마에 맞게 색상을 지정합니다.';

  @override
  String get amoled_dark_theme_tip =>
      '배터리를 절약하고 싶나요? AMOLED 다크 테마를 사용하여 OLED 화면의 전력 소비를 줄이세요.';

  @override
  String get customize_usage_history_tip =>
      '사용 내역을 보관하고 싶으신가요? 사용 내역에 몇 주 동안 데이터를 저장할지 사용자 정의하세요.';

  @override
  String get grouped_apps_blocking_tip =>
      '앱을 함께 차단하고 싶으신가요? 제한 그룹을 사용하면 앱 제한을 그룹화하고 여러 앱을 한 번에 차단할 수 있습니다.';

  @override
  String get websites_blocking_tip =>
      '더욱 깔끔한 브라우징 경험을 원하시나요? 보다 집중적인 온라인 시간을 위해 맞춤형 웹사이트 또는 NSFW 웹사이트를 차단하세요.';

  @override
  String get data_usage_tip =>
      '데이터를 추적하고 싶으십니까? 인터넷 소비를 위한 모바일 및 Wi-Fi 데이터 사용량을 모니터링하세요.';

  @override
  String get block_internet_tip =>
      '앱의 인터넷을 차단해야 합니까? 앱 대시보드에서 특정 앱의 인터넷을 차단합니다.';

  @override
  String get emergency_passes_tip =>
      '휴식이 필요하신가요? 매일 3개의 긴급 패스를 사용하여 5분 동안 일시적으로 앱 차단을 해제하세요.';

  @override
  String get onboarding_skip_btn_label => '건너뛰기';

  @override
  String get onboarding_finish_setup_btn_label => '설정 완료';

  @override
  String get onboarding_page_welcome_title => 'NLP digitox에 오신 것을 환영합니다.';

  @override
  String get onboarding_page_welcome_info =>
      '디지털 생활을 통제하고 더 건강한 화면 사용 습관을 기르세요. NLP digitox는 집중력을 유지하고 방해 요소를 줄이며 매일 의식적인 선택을 하도록 도와줍니다.';

  @override
  String get onboarding_page_statistics_title => '습관을 알아보세요.';

  @override
  String get onboarding_page_statistics_info =>
      '화면 사용 시간, 앱 사용, 집중 추세에 대한 상세한 인사이트로 디지털 패턴을 이해하세요. 진행 상황을 추적하고 작은 변화가 큰 개선으로 이어지는 것을 확인하세요.';

  @override
  String get onboarding_page_one_title => '마스터 포커스.';

  @override
  String get onboarding_page_one_info =>
      '방해가 되는 앱을 일시 중지하고, 짧은 콘텐츠를 차단하고, 맞춤형 집중 세션을 통해 순조롭게 진행하세요. 일하든, 공부하든, 휴식을 취하든 NLP digitox는 통제력을 유지하는 데 도움이 됩니다.';

  @override
  String get onboarding_page_two_title => '방해 요소를 차단하세요.';

  @override
  String get onboarding_page_two_info =>
      '사용 제한을 설정하고, 앱을 자동으로 일시 중지하고, 건강한 디지털 습관을 만드세요. 취침 모드를 사용하여 긴장을 풀고 방해 요소 없이 즐거운 밤을 보내세요.';

  @override
  String get onboarding_page_three_title => '개인 정보 보호 우선.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox는 100% 오픈 소스이며 완전히 오프라인으로 운영됩니다. 우리는 귀하의 개인정보를 수집하거나 공유하지 않습니다. 귀하의 개인정보는 모든 면에서 보장됩니다.';

  @override
  String get onboarding_page_permissions_title => '필수 권한.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox는 화면 시간을 추적하고 관리하여 방해 요소를 줄이고 집중력을 향상시키기 위해 다음과 같은 필수 권한이 ​​필요합니다.';

  @override
  String get dashboard_tab_title => '대시보드';

  @override
  String get focus_now_fab_button => '지금 집중하세요';

  @override
  String get welcome_greetings => '돌아온 것을 환영합니다.';

  @override
  String get username_snack_alert => '사용자 이름을 수정하려면 길게 누르세요.';

  @override
  String get username_dialog_title => '사용자 이름';

  @override
  String get username_dialog_info => '대시보드에 표시될 사용자 이름을 입력하세요.';

  @override
  String get username_dialog_button_apply => '적용';

  @override
  String get glance_tile_title => '한눈에';

  @override
  String get glance_tile_subtitle => '사용량을 빠르게 살펴보세요.';

  @override
  String get parental_controls_tile_subtitle => '무적 모드 및 변조 방지.';

  @override
  String get restrictions_heading => '제한 사항';

  @override
  String get apps_blocking_tile_title => '앱 차단';

  @override
  String get apps_blocking_tile_subtitle => '다양한 방법으로 앱을 제한하세요.';

  @override
  String get grouped_apps_blocking_tile_title => '그룹화된 앱 차단';

  @override
  String get grouped_apps_blocking_tile_subtitle => '동시에 앱 그룹을 제한합니다.';

  @override
  String get shorts_blocking_tile_subtitle => '여러 플랫폼에서 짧은 콘텐츠를 제한하세요.';

  @override
  String get websites_blocking_tile_subtitle => '성인용 웹사이트와 맞춤 웹사이트를 제한하세요.';

  @override
  String get screen_time_label => '화면 시간';

  @override
  String get total_data_label => '총 데이터';

  @override
  String get mobile_data_label => '모바일 데이터';

  @override
  String get wifi_data_label => 'Wi-Fi 데이터';

  @override
  String get focus_today_label => '오늘 집중하세요';

  @override
  String get focus_weekly_label => '매주 집중';

  @override
  String get focus_monthly_label => '월별 포커스';

  @override
  String get focus_lifetime_label => '초점 수명';

  @override
  String get longest_streak_label => '최장 연속 행진';

  @override
  String get current_streak_label => '현재 연속';

  @override
  String get successful_sessions_label => '성공적인 세션';

  @override
  String get failed_sessions_label => '실패한 세션';

  @override
  String get statistics_tab_title => '통계';

  @override
  String get screen_segment_label => '화면';

  @override
  String get data_segment_label => '데이터';

  @override
  String get mobile_label => '모바일';

  @override
  String get wifi_label => '와이파이';

  @override
  String get most_used_apps_heading => '가장 많이 사용되는 앱';

  @override
  String get show_all_apps_tile_title => '모든 앱 표시';

  @override
  String get search_apps_hint => '앱 검색...';

  @override
  String get notifications_tab_title => '알림';

  @override
  String get notifications_tab_info =>
      '앱에서 일괄 알림을 보내고 아침, 점심, 저녁, 밤과 같은 일정을 설정합니다. 지속적인 중단 없이 최신 정보를 받아보세요.';

  @override
  String get batched_apps_tile_title => '일괄 앱';

  @override
  String get batch_recap_dropdown_title => '일괄 요약 유형';

  @override
  String get batch_recap_dropdown_info =>
      '일정이 실행될 때 푸시할 항목(모든 알림 또는 요약)을 선택하세요.';

  @override
  String get batch_recap_option_summery_only => '요약만';

  @override
  String get batch_recap_option_all_notifications => '모든 알림';

  @override
  String get notification_history_tile_title => '알림 내역';

  @override
  String get store_all_tile_title => '모든 알림 저장';

  @override
  String get store_all_tile_subtitle => '일괄 처리되지 않은 알림도 저장하세요.';

  @override
  String get schedules_heading => '일정';

  @override
  String get new_schedule_fab_button => '새로운 일정';

  @override
  String get new_schedule_dialog_info => '쉽게 식별할 수 있도록 알림 일정의 이름을 입력합니다.';

  @override
  String get new_schedule_dialog_field_label => '일정 이름';

  @override
  String get bedtime_tab_title => '취침 시간';

  @override
  String get bedtime_tab_info =>
      '시간대와 요일을 선택하여 취침 시간 일정을 설정하세요. 방해가 되는 앱을 선택하여 차단하고 평화로운 밤을 위해 방해 금지(DND) 모드를 활성화하세요.';

  @override
  String get schedule_tile_title => '일정';

  @override
  String get schedule_tile_subtitle => '일일 일정을 활성화하거나 비활성화합니다.';

  @override
  String get bedtime_no_days_selected_snack_alert => '요일을 하나 이상 선택하세요.';

  @override
  String get bedtime_minimum_duration_snack_alert => '총 취침 시간은 30분 이상이어야 합니다.';

  @override
  String get distracting_apps_tile_title => '방해가 되는 앱';

  @override
  String get distracting_apps_tile_subtitle => '취침 시간 루틴에 방해가 되는 앱을 선택하세요.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      '취침 시간 일정이 활성화되어 있는 동안에는 방해가 되는 앱 목록을 수정하는 것이 허용되지 않습니다.';

  @override
  String get parental_controls_tab_title => '자녀 보호';

  @override
  String get invincible_mode_heading => '무적 모드';

  @override
  String get invincible_mode_tile_title => '무적 모드 활성화';

  @override
  String get invincible_mode_info =>
      '무적 모드가 켜져 있으면 일일 할당량에 도달한 후 선택한 한도를 조정할 수 없습니다. 그러나 선택한 10분 무적 기간 내에서는 변경할 수 있습니다.';

  @override
  String get invincible_mode_snack_alert => '무적 모드로 인해 제한 사항 수정이 불가능합니다.';

  @override
  String get invincible_mode_dialog_info =>
      '무적 모드를 활성화하시겠습니까? 이 작업은 되돌릴 수 없습니다. 무적 모드가 켜져 있으면 이 앱이 기기에 설치되어 있는 동안에는 끌 수 없습니다.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      '이 앱이 기기에 설치되어 있는 동안에는 무적 모드를 끌 수 없습니다.';

  @override
  String get invincible_mode_dialog_button_start_anyway => '어쨌든 시작하세요';

  @override
  String get invincible_mode_include_timer_tile_title => '타이머 포함';

  @override
  String get invincible_mode_include_launch_limit_tile_title => '실행 제한 포함';

  @override
  String get invincible_mode_include_active_period_tile_title => '활성 기간 포함';

  @override
  String get invincible_mode_app_restrictions_tile_title => '앱 제한사항';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      '일일 한도가 초과되면 앱에서 선택한 제한 사항이 변경되지 않도록 방지하세요.';

  @override
  String get invincible_mode_group_restrictions_tile_title => '그룹 제한';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      '일일 한도가 초과되면 그룹이 선택한 제한사항이 변경되지 않도록 방지하세요.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title => '반바지 타이머 포함';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      '일일 반바지 한도에 도달한 후 변경을 방지합니다.';

  @override
  String get invincible_mode_include_bedtime_tile_title => '취침 시간 포함';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      '활성 취침 시간 일정 중 변경을 방지합니다.';

  @override
  String get protected_access_tile_title => '보호된 액세스';

  @override
  String get protected_access_tile_subtitle => '장치 잠금 장치로 NLP digitox를 보호하세요.';

  @override
  String get protected_access_no_lock_snack_alert =>
      '이 기능을 활성화하려면 먼저 장치에 생체인식 잠금을 설정하세요.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      '장치 잠금이 제거되었습니다. 계속하려면 새 잠금을 설정하세요.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      '인증에 실패했습니다. 계속하려면 장치 잠금을 확인해야 합니다.';

  @override
  String get tamper_protection_tile_title => '변조 방지';

  @override
  String get tamper_protection_tile_subtitle => '앱 제거를 방지하고 강제로 종료하세요.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      '활성화되면 선택한 제거 기간 동안을 제외하고는 NLP digitox의 데이터를 제거, 강제 중지 또는 지울 수 없습니다. 해결 방법은 없습니다. \n\n진행에 따른 책임은 사용자 본인에게 있습니다.';

  @override
  String get uninstall_window_tile_title => '제거 창';

  @override
  String get uninstall_window_tile_subtitle =>
      '임의 변경 방지는 선택한 시간으로부터 10분 이내에 비활성화될 수 있습니다.';

  @override
  String get invincible_window_tile_title => '무적의 창';

  @override
  String get invincible_window_tile_subtitle =>
      '선택한 한도는 선택한 시간으로부터 10분 이내에 수정할 수 있습니다.';

  @override
  String get shorts_blocking_tab_title => '반바지 차단';

  @override
  String get shorts_blocking_tab_info =>
      '웹사이트를 포함하여 Instagram, YouTube, Snapchat, Facebook과 같은 플랫폼에서 짧은 콘텐츠에 소비하는 시간을 관리하세요.';

  @override
  String get short_content_heading => '짧은 콘텐츠';

  @override
  String shorts_time_left_from(String timeShortString) {
    return '$timeShortString에서 왼쪽';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      '짧은 콘텐츠에 대한 일일 시간 제한을 설정하세요. 한도에 도달하면 짧은 콘텐츠가 자정까지 일시중지됩니다.';

  @override
  String get instagram_features_tile_title => '인스타그램';

  @override
  String get instagram_features_tile_subtitle => '인스타그램의 기능을 제한합니다.';

  @override
  String get instagram_features_block_reels => '릴 섹션을 제한합니다.';

  @override
  String get instagram_features_block_explore => '탐색 섹션을 제한합니다.';

  @override
  String get snapchat_features_tile_title => '스냅챗';

  @override
  String get snapchat_features_tile_subtitle => 'Snapchat의 기능을 제한합니다.';

  @override
  String get snapchat_features_block_spotlight => '스포트라이트 섹션을 제한합니다.';

  @override
  String get snapchat_features_block_discover => '검색 섹션을 제한합니다.';

  @override
  String get youtube_features_tile_title => '유튜브';

  @override
  String get youtube_features_tile_subtitle => 'YouTube에서 단편영화를 제한합니다.';

  @override
  String get facebook_features_tile_title => '페이스북';

  @override
  String get facebook_features_tile_subtitle => 'Facebook에서 릴을 제한합니다.';

  @override
  String get reddit_features_tile_title => '레딧';

  @override
  String get reddit_features_tile_subtitle => 'Reddit에서는 반바지를 제한합니다.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'X에서 비디오 피드를 제한합니다.';

  @override
  String get threads_features_tile_title => '스레드';

  @override
  String get threads_features_tile_subtitle => '스레드에서 비디오/릴을 제한합니다.';

  @override
  String get websites_blocking_tab_title => '웹사이트 차단';

  @override
  String get websites_blocking_tab_info =>
      '보다 안전하고 집중적인 온라인 경험을 만들기 위해 성인 웹사이트와 사용자 정의 사이트를 차단하세요. 탐색을 주도하고 방해받지 않는 상태를 유지하세요.';

  @override
  String get adult_content_heading => '성인용 콘텐츠';

  @override
  String get block_nsfw_title => 'NSFW 차단';

  @override
  String get block_nsfw_subtitle => '브라우저가 성인 및 포르노 웹사이트를 열지 못하도록 제한합니다.';

  @override
  String get block_nsfw_dialog_info =>
      '확실합니까? 이 작업은 되돌릴 수 없습니다. 성인 사이트 차단기가 켜져 있으면 이 앱이 기기에 설치되어 있는 동안에는 끌 수 없습니다.';

  @override
  String get block_nsfw_dialog_button_block_anyway => '어쨌든 차단';

  @override
  String get blocked_websites_heading => '차단된 웹사이트';

  @override
  String get blocked_websites_empty_list_hint =>
      '차단하고 싶은 방해가 되는 웹사이트를 추가하려면 \'+ 웹사이트 추가\' 버튼을 클릭하세요.';

  @override
  String get add_website_fab_button => '웹사이트 추가';

  @override
  String get add_website_dialog_title => '주의를 산만하게 하는 웹사이트';

  @override
  String get add_website_dialog_info => '차단하려는 웹사이트의 URL을 입력하세요.';

  @override
  String get add_website_dialog_is_nsfw => 'nsfw 사이트인가요?';

  @override
  String get add_website_dialog_nsfw_warning =>
      '경고: Nsfw 사이트는 추가된 후에 제거할 수 없습니다.';

  @override
  String get add_website_dialog_button_block => '블록';

  @override
  String get add_website_already_exist_snack_alert =>
      '차단된 웹사이트 목록에 해당 URL이 이미 추가되었습니다.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'URL이 잘못되었습니다! 호스트 이름을 구문 분석할 수 없습니다.';

  @override
  String get remove_website_dialog_title => '웹사이트 삭제';

  @override
  String remove_website_dialog_info(String websitehost) {
    return '확실합니까? 차단된 웹사이트에서 \'$websitehost\'를 제거하고 싶습니다.';
  }

  @override
  String get focus_tab_title => '초점';

  @override
  String get focus_tab_info =>
      '집중할 시간이 필요할 때 유형을 선택하고, 일시 중지할 방해가 되는 앱을 선택하고, 방해받지 않고 집중할 수 있도록 방해 금지 모드를 활성화하여 새 세션을 시작하세요.';

  @override
  String get active_session_card_title => '활성 세션';

  @override
  String get active_session_card_info =>
      '활성 포커스 세션이 실행 중입니다! 진행 상황을 확인하고 경과된 시간을 확인하려면 \'보기\'를 클릭하세요.';

  @override
  String get active_session_card_view_button => '보기';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      '집중 세션이 활성화되어 있는 동안 방해가 되는 앱 목록에서 앱을 제거하는 것은 허용되지 않습니다. 하지만 이 기간 동안에도 목록에 앱을 더 추가할 수 있습니다.';

  @override
  String get focus_profile_tile_title => '포커스 프로필';

  @override
  String get focus_session_duration_tile_title => '세션 기간';

  @override
  String get focus_session_duration_tile_subtitle => '무한 (멈추지 않는 한)';

  @override
  String get focus_session_duration_dialog_info =>
      '이 집중 세션에 대해 원하는 기간을 선택하여 얼마나 오랫동안 집중력을 유지하고 방해 요소 없이 지내기를 원하는지 결정하십시오.';

  @override
  String get focus_profile_customization_tile_title => '프로필 맞춤설정';

  @override
  String get focus_profile_customization_tile_subtitle =>
      '선택한 프로필에 대한 설정을 사용자 정의합니다.';

  @override
  String get focus_enforce_tile_title => '세션 시행';

  @override
  String get focus_enforce_tile_subtitle => '시간이 끝나기 전에 세션이 종료되는 것을 방지합니다.';

  @override
  String get focus_session_start_button => '밀어서 세션 시작';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      '집중 세션을 시작하려면 방해가 되는 앱을 하나 이상 선택하세요.';

  @override
  String get focus_session_already_active_snack_alert =>
      '이미 활성 포커스 세션이 실행 중입니다. 새 세션을 시작하기 전에 현재 세션을 완료하거나 중지하세요.';

  @override
  String get focus_session_type_study => '연구';

  @override
  String get focus_session_type_work => '일';

  @override
  String get focus_session_type_exercise => '운동';

  @override
  String get focus_session_type_meditation => '명상';

  @override
  String get focus_session_type_creativeWriting => '문예창작';

  @override
  String get focus_session_type_reading => '독서';

  @override
  String get focus_session_type_programming => '프로그래밍';

  @override
  String get focus_session_type_chores => '집안일';

  @override
  String get focus_session_type_projectPlanning => '프로젝트 기획';

  @override
  String get focus_session_type_artAndDesign => '예술과 디자인';

  @override
  String get focus_session_type_languageLearning => '언어 학습';

  @override
  String get focus_session_type_musicPractice => '음악 연습';

  @override
  String get focus_session_type_selfCare => '셀프 케어';

  @override
  String get focus_session_type_brainstorming => '브레인스토밍';

  @override
  String get focus_session_type_skillDevelopment => '기술 개발';

  @override
  String get focus_session_type_research => '연구';

  @override
  String get focus_session_type_networking => '네트워킹';

  @override
  String get focus_session_type_cooking => '요리';

  @override
  String get focus_session_type_sportsTraining => '스포츠 훈련';

  @override
  String get focus_session_type_restAndRelaxation => '휴식과 휴식';

  @override
  String get focus_session_type_other => '기타';

  @override
  String get timeline_tab_title => '타임라인';

  @override
  String get focus_timeline_tab_info =>
      '달력에서 날짜를 선택하여 집중 여정을 살펴보세요. 진행 상황을 추적하고, 성공 사례를 다시 살펴보고, 과제로부터 배우십시오.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return '선택한 달의 총 생산 시간은 $timeString입니다.';
  }

  @override
  String get selected_month_productive_days_label => '생산적인 날';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return '선택한 달에 총 $daysCount개의 생산 일수가 있었습니다.';
  }

  @override
  String get selected_day_focused_time_label => '집중된 시간';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return '선택한 날의 총 집중 시간은 $timeString입니다.';
  }

  @override
  String get calender_heading => '캘린더';

  @override
  String get your_sessions_heading => '귀하의 세션';

  @override
  String get your_sessions_empty_list_hint => '선택한 날짜에 기록된 집중 세션이 없습니다.';

  @override
  String get focus_session_tile_timestamp_label => '타임스탬프';

  @override
  String get focus_session_tile_duration_label => '기간';

  @override
  String get focus_session_tile_reflection_label => '반사';

  @override
  String get focus_session_state_active => '활성';

  @override
  String get focus_session_state_successful => '성공';

  @override
  String get focus_session_state_failed => '실패';

  @override
  String get active_session_tab_title => '세션';

  @override
  String get active_session_none_warning => '활성 세션을 찾을 수 없습니다. 홈 화면으로 돌아갑니다.';

  @override
  String get active_session_dialog_button_keep_pushing => '계속 밀어붙여';

  @override
  String get active_session_finish_dialog_title => '마침';

  @override
  String get active_session_finish_dialog_info =>
      '힘내세요! 당신은 귀중한 초점을 맞추고 있습니다. 이 집중 세션을 종료하시겠습니까? 모든 추가 순간이 목표 달성에 중요합니다.';

  @override
  String get active_session_giveup_dialog_title => '포기하다';

  @override
  String get active_session_giveup_dialog_info =>
      '잠깐만요! 거의 다 왔습니다. 이제 포기하지 마세요! 이 집중 세션을 일찍 종료하시겠습니까? 진행 상황이 손실됩니다.';

  @override
  String get active_session_reflection_dialog_title => '세션 반영';

  @override
  String get active_session_reflection_dialog_info =>
      '잠시 시간을 내어 진행 상황을 되돌아보세요. 이번 세션의 목표는 무엇인가요? 이번 세션에서 무엇을 성취하셨나요?';

  @override
  String get active_session_reflection_dialog_tip =>
      '팁: 나중에 세션 타임라인에서 언제든지 편집할 수 있습니다.';

  @override
  String get active_session_giveup_snack_alert =>
      '당신은 포기했습니다! 걱정하지 마세요. 다음에는 더 잘할 수 있습니다. 모든 노력이 중요합니다. 계속 진행하세요.';

  @override
  String get active_session_quote_one => '모든 단계가 중요합니다. 힘차게 계속 나아가세요.';

  @override
  String get active_session_quote_two => '집중하세요! 당신은 놀라운 발전을 보이고 있습니다';

  @override
  String get active_session_quote_three => '당신은 그것을 분쇄하고 있습니다! 계속해서 기세를 이어가세요';

  @override
  String get active_session_quote_four => '조금만 더 하면 정말 환상적이네요';

  @override
  String active_session_quote_five(String durationString) {
    return '축하합니다 🎉 \n $durationString의 포커스 세션을 완료했습니다.\n\n훌륭합니다. 계속 놀라운 작업을 수행하세요.';
  }

  @override
  String get restriction_groups_tab_title => '제한 그룹';

  @override
  String get restriction_groups_tab_info =>
      '앱 그룹에 대한 통합 화면 시간 제한을 설정합니다. 총 사용량이 한도에 도달하면 집중력과 균형을 유지하기 위해 그룹의 모든 앱이 일시 중지됩니다.';

  @override
  String get restriction_group_time_spent_label => '오늘 보낸 시간';

  @override
  String get restriction_group_time_left_label => '오늘 남은 시간';

  @override
  String get restriction_group_name_tile_title => '그룹 이름';

  @override
  String get restriction_group_name_picker_dialog_info =>
      '쉽게 식별하고 관리할 수 있도록 제한 그룹의 이름을 입력합니다.';

  @override
  String get restriction_group_timer_tile_title => '그룹 타이머';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      '이 그룹에 대한 일일 시간 제한을 설정하십시오. 한도에 도달하면 이 그룹의 모든 앱이 자정까지 일시중지됩니다.';

  @override
  String get restriction_group_active_period_tile_title => '그룹 활동 기간';

  @override
  String get remove_restriction_group_dialog_title => '그룹 삭제';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return '확실합니까? 제한 그룹에서 \'$groupName\'를 제거하고 싶습니다.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      '타이머나 활동 기간 제한을 설정하세요.';

  @override
  String get notifications_empty_list_hint => '해당 날짜에 일괄 처리된 알림이 없습니다.';

  @override
  String get conversations_label => '대화';

  @override
  String get last_24_hours_heading => '지난 24시간';

  @override
  String get notification_timeline_tab_info =>
      '달력에서 날짜를 선택하여 알림 기록을 찾아보세요. 어떤 앱이 관심을 끌었는지 확인하고 디지털 습관을 되돌아보세요.';

  @override
  String get monthly_label => '월간';

  @override
  String get daily_label => '매일';

  @override
  String get search_notifications_sheet_info =>
      '제목이나 내용을 검색하여 과거 알림을 쉽게 찾을 수 있습니다. 중요한 경고를 빠르게 찾는 데 도움이 됩니다.';

  @override
  String get search_notifications_hint => '알림 검색...';

  @override
  String get search_notifications_empty_list_hint => '검색어와 일치하는 알림을 찾을 수 없습니다.';

  @override
  String get app_info_none_warning => '해당 패키지에 대한 앱을 찾을 수 없습니다. 홈 화면으로 돌아갑니다.';

  @override
  String get emergency_fab_button => '긴급상황';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return '이 작업을 수행하면 다음 5분 동안 앱 차단기가 일시중지됩니다. $leftPassesCount 패스가 남았습니다. 모든 패스를 사용한 후에는 자정까지 앱이 차단된 상태로 유지되거나 활성 포커스 세션이 종료됩니다.\n\n계속 진행하시겠습니까?';
  }

  @override
  String get emergency_dialog_button_use_anyway => '어쨌든 사용';

  @override
  String get emergency_started_snack_alert =>
      '앱 차단기가 일시중지되었으며 5분 후에 차단이 재개됩니다.';

  @override
  String get emergency_already_active_snack_alert =>
      '앱 차단기가 현재 일시중지되었거나 비활성 상태입니다. 알림이 활성화되면 남은 시간에 대한 업데이트를 받게 됩니다.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      '긴급패스를 모두 사용하셨습니다. 차단된 앱은 자정까지 차단된 상태로 유지되거나 활성 포커스 세션이 종료됩니다.';

  @override
  String get app_limit_status_not_set => '설정되지 않음';

  @override
  String get app_timer_tile_title => '앱 타이머';

  @override
  String get app_timer_picker_dialog_info =>
      '이 앱의 일일 시간 제한을 설정하세요. 한도에 도달하면 앱이 자정까지 일시 중지됩니다.';

  @override
  String get usage_reminders_tile_title => '사용 알림';

  @override
  String get usage_reminders_tile_subtitle => '시간이 지정된 앱을 사용할 때 부드럽게 살짝 움직입니다.';

  @override
  String get app_launch_limit_tile_title => '발사 제한';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return '오늘 $count 번 출시되었습니다.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      '하루에 이 앱을 열 수 있는 횟수를 설정하세요. 한도에 도달하면 자정까지 일시중지됩니다.';

  @override
  String get app_active_period_tile_title => '활동 기간';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return '$startTime에서 $endTime까지';
  }

  @override
  String get internet_access_tile_title => '인터넷 접속';

  @override
  String get internet_access_tile_subtitle => '앱의 인터넷을 차단하려면 스위치를 끄세요.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '$appName의 인터넷이 차단되었습니다.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '$appName의 인터넷이 차단 해제되었습니다.';
  }

  @override
  String get launch_app_tile_title => '앱 실행';

  @override
  String launch_app_tile_subtitle(String appName) {
    return '$appName를 엽니다.';
  }

  @override
  String get go_to_app_settings_tile_title => '앱 설정으로 이동';

  @override
  String get go_to_app_settings_tile_subtitle =>
      '알림, 권한, 저장 공간 등과 같은 앱 설정을 관리하세요.';

  @override
  String get include_in_stats_tile_title => '화면 사용량에 포함';

  @override
  String get include_in_stats_tile_subtitle => '전체 화면 사용량에서 이 앱을 제외하려면 끄세요.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName는 전체 화면 사용량에서 제외됩니다.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName는 전체 화면 사용량에 포함됩니다.';
  }

  @override
  String get general_tab_title => '일반';

  @override
  String get appearance_heading => '외관';

  @override
  String get theme_mode_tile_title => '테마 모드';

  @override
  String get theme_mode_system_label => '시스템';

  @override
  String get theme_mode_light_label => '빛';

  @override
  String get theme_mode_dark_label => '어둠';

  @override
  String get material_color_tile_title => '소재 색상';

  @override
  String get amoled_dark_tile_title => 'AMOLED 다크';

  @override
  String get amoled_dark_tile_subtitle => '어두운 테마에는 순수한 검정색을 사용합니다.';

  @override
  String get dynamic_colors_tile_title => '동적 색상';

  @override
  String get dynamic_colors_tile_subtitle => '지원되는 경우 장치 색상을 사용하십시오.';

  @override
  String get defaults_heading => '기본값';

  @override
  String get app_language_tile_title => '앱 언어';

  @override
  String get default_home_tab_tile_title => '홈 탭';

  @override
  String get usage_history_tile_title => '이용내역';

  @override
  String get usage_history_15_days => '15일';

  @override
  String get usage_history_1_month => '1개월';

  @override
  String get usage_history_3_month => '3개월';

  @override
  String get usage_history_6_month => '6개월';

  @override
  String get usage_history_1_year => '1년';

  @override
  String get service_heading => '서비스';

  @override
  String get service_stopping_warning =>
      'NLP digitox가 예기치 않게 작동하지 않는 경우 \'배터리 최적화 무시\' 권한을 부여하여 백그라운드에서 계속 실행되도록 하세요. 문제가 계속되면 중단 없는 성능을 위해 NLP digitox를 화이트리스트에 등록해 보세요.';

  @override
  String get whitelist_app_tile_title => '화이트리스트 NLP digitox';

  @override
  String get whitelist_app_tile_subtitle => 'NLP digitox가 자동 시작되도록 허용합니다.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      '이 장치는 자동 시작 관리를 지원하지 않습니다.';

  @override
  String get database_tab_title => '데이터베이스';

  @override
  String get import_db_tile_title => '데이터베이스 가져오기';

  @override
  String get import_db_tile_subtitle => '파일에서 데이터베이스를 가져옵니다.';

  @override
  String get export_db_tile_title => '데이터베이스 내보내기';

  @override
  String get export_db_tile_subtitle => '데이터베이스를 파일로 내보냅니다.';

  @override
  String get analysis_tab_title => '분석';

  @override
  String get analysis_7_days => '7일';

  @override
  String get analysis_30_days => '30일';

  @override
  String get analysis_90_days => '90일';

  @override
  String get analysis_screen_time_trend => '화면 사용 시간 추세';

  @override
  String get analysis_no_data_info => '이 기간 동안 기록된 화면 사용 시간 데이터가 없습니다.';

  @override
  String get analysis_daily_average => '일일 평균';

  @override
  String get analysis_total => '합계';

  @override
  String get analysis_no_change => '지난주와 동일';

  @override
  String analysis_trend_less(String percent) {
    return '지난주보다 $percent% 감소';
  }

  @override
  String analysis_trend_more(String percent) {
    return '지난주보다 $percent% 증가';
  }

  @override
  String get crash_logs_heading => '충돌 로그';

  @override
  String get crash_logs_info =>
      '문제가 발생하면 로그 파일과 함께 GitHub에 보고할 수 있습니다. 파일에는 기기 제조업체, 모델, Android 버전, SDK 버전, 충돌 로그 등의 세부정보가 포함됩니다. 이 정보는 문제를 보다 효과적으로 식별하고 해결하는 데 도움이 됩니다.';

  @override
  String get crash_logs_export_tile_title => '충돌 로그 내보내기';

  @override
  String get crash_logs_export_tile_subtitle => '충돌 로그를 json 파일로 내보냅니다.';

  @override
  String get crash_logs_view_tile_title => '로그 보기';

  @override
  String get crash_logs_view_tile_subtitle => '저장된 충돌 로그를 살펴보세요.';

  @override
  String get crash_logs_empty_list_hint => '지금까지 충돌이 기록되지 않았습니다.';

  @override
  String get crash_logs_clear_tile_title => '로그 지우기';

  @override
  String get crash_logs_clear_tile_subtitle => '데이터베이스에서 모든 충돌 로그를 삭제합니다.';

  @override
  String get crash_logs_clear_dialog_info => '데이터베이스에서 모든 충돌 로그를 지우시겠습니까?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => '어쨌든 삭제';

  @override
  String get about_tab_title => '소개';

  @override
  String get changelog_tile_title => '변경 내역';

  @override
  String get changelog_tile_subtitle => '새로운 소식을 알아보세요.';

  @override
  String get full_changelog_tile_title => '전체 변경 내역';

  @override
  String get redirected_to_github_subtitle => 'GitHub로 리디렉션됩니다.';

  @override
  String get contribute_heading => '기여';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => '소스 코드를 봅니다.';

  @override
  String get report_issue_tile_title => '문제 신고';

  @override
  String get suggest_idea_tile_title => '아이디어를 제안하세요';

  @override
  String get write_email_tile_title => '이메일을 통해 우리에게 편지 쓰기';

  @override
  String get write_email_tile_subtitle => '이메일 앱으로 리디렉션됩니다.';

  @override
  String get privacy_policy_heading => '개인 정보 보호 정책';

  @override
  String get privacy_policy_info =>
      'NLP digitox는 귀하의 개인 정보를 보호하기 위해 최선을 다하고 있습니다. 우리는 어떠한 유형의 사용자 데이터도 수집, 저장 또는 전송하지 않습니다. 이 앱은 완전히 오프라인으로 작동하며 인터넷 연결이 필요하지 않으므로 귀하의 개인 정보가 귀하의 기기에서 비공개로 안전하게 유지됩니다. FOSS(무료 및 오픈 소스 소프트웨어) 애플리케이션인 NLP digitox는 데이터에 대한 완전한 투명성과 사용자 제어를 보장합니다.';

  @override
  String get more_details_button => '자세한 내용';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
