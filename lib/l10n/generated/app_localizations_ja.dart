// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get mindful_tagline => '本当に大切なことに集中しよう';

  @override
  String get unlock_button_label => 'ロック解除';

  @override
  String get permission_status_off => 'オフ';

  @override
  String get permission_status_allowed => 'アクセス可能';

  @override
  String get permission_status_not_allowed => 'アクセス不可';

  @override
  String get permission_button_grant_permission => 'アクセスを許可する';

  @override
  String get permission_button_agree_and_continue => '同意して続ける';

  @override
  String get permission_button_not_now => '後で';

  @override
  String get permission_button_help => 'ヘルプ';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox は100%安全で、オフラインでも動作します。個人情報の収集または保存をすることはありません。';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. $button_label を選択してください。';
  }

  @override
  String get permission_grant_step_two => '2. 次の画面で NLP digitox を選択してください。';

  @override
  String get permission_grant_step_three => '3. 下記を参考に、切り替えを選択して有効にしてください。';

  @override
  String get permission_notification_title => '通知を受け取る';

  @override
  String get permission_alarms_title => 'アラームとリマインダー';

  @override
  String get permission_alarms_info =>
      'NLP digitox が就寝スケジュールとアプリタイマーを管理できるように、アラームとリマインダーへのアクセスを許可してください。';

  @override
  String get permission_alarms_device_tile_label => 'アラームとリマインダーの設定を許可する';

  @override
  String get permission_usage_title => '使用状況';

  @override
  String get permission_usage_info =>
      'NLP digitox がアプリの使用状況を把握し、アプリの利用時間を管理できるように、使用状況へのアクセスを許可してください。';

  @override
  String get permission_usage_device_tile_label => '使用状況へのアクセス許可';

  @override
  String get permission_overlay_title => '他のアプリの上に重ねて表示';

  @override
  String get permission_overlay_info =>
      'NLP digitox が利用時間を超えたアプリを制限できるように、他のアプリの上に重ねて表示を許可してください。';

  @override
  String get permission_overlay_device_tile_label => '他のアプリの上に重ねて表示できるようにする';

  @override
  String get permission_accessibility_title => 'ユーザー補助';

  @override
  String get permission_accessibility_info =>
      'リール・ショート動画へのアクセス制限や不適切なSNS・ウェブサイトのブロックをするために、ユーザー補助を有効にしてください。';

  @override
  String get permission_accessibility_required =>
      'NLP digitox がショートコンテンツやウェブサイトを効果的にブロックするには、ユーザー補助の権限が必要です。';

  @override
  String get permission_accessibility_device_tile_label => 'NLP digitox の使用';

  @override
  String get permission_dnd_title => 'サイレントモード';

  @override
  String get permission_dnd_info =>
      'サイレントモードを利用すると、NLP digitox が就寝時間中の通知を自動的に管理し、快適な睡眠をサポートします。';

  @override
  String get permission_dnd_tile_title => 'サイレントモードを開始';

  @override
  String get permission_dnd_tile_subtitle => 'サイレントモードを有効にする必要があります。';

  @override
  String get permission_battery_optimization_tile_title => 'バッテリー最適化を無視する';

  @override
  String get permission_battery_optimization_status_enabled => 'バックグラウンドで動作中';

  @override
  String get permission_battery_optimization_status_disabled =>
      'バックグラウンドで動作していません';

  @override
  String get permission_battery_optimization_allow_info =>
      '「バッテリー最適化を無視する」を許可すると、一部のデバイスでは「アラームとリマインダー」の権限が自動的に付与されます。';

  @override
  String get permission_vpn_title => 'VPNを作成';

  @override
  String get permission_vpn_info =>
      'NLP digitox がアプリのインターネットアクセスを制限するために、仮想プライベートネットワーク（VPN）接続の作成を許可してください。';

  @override
  String get permission_admin_title => 'デバイス管理アプリの有効化';

  @override
  String get permission_admin_info =>
      'デバイス管理アプリの有効化は、アプリが正常に動作し、改ざん防止を維持するために必要な操作のみに使用されます。';

  @override
  String get permission_admin_snack_alert =>
      'デバイス管理アプリの有効化は、選択した時間帯以外では無効にすることができません。';

  @override
  String get permission_notification_access_title => '通知へのアクセス';

  @override
  String get permission_notification_access_info =>
      '通知へのアクセス権限を許可してください。これにより、NLP digitox が通知を整理し、あなたのスケジュールに合わせて通知を配信できるようになります。';

  @override
  String get permission_notification_access_required =>
      'NLP digitox が通知をまとめてスケジュール配信するには、通知へのアクセス権限が必要です。';

  @override
  String get permission_notification_access_device_tile_label => '通知へのアクセスを許可';

  @override
  String get day_today => '今日';

  @override
  String get day_yesterday => '昨日';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 日',
      one: '1 日',
      zero: '0 日',
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
      other: '$countString 時間',
      one: '1 時間',
      zero: '0 時間',
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
      other: '$countString 分',
      one: '1 分',
      zero: '0 分',
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
      other: '$countString 秒',
      one: '1 秒',
      zero: '0 秒',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'と';

  @override
  String get timer_status_active => '有効';

  @override
  String get timer_status_paused => '一時停止';

  @override
  String get create_button => '作成';

  @override
  String get update_button => '更新';

  @override
  String get dialog_button_cancel => 'キャンセル';

  @override
  String get dialog_button_remove => '削除';

  @override
  String get dialog_button_set => '設定';

  @override
  String get dialog_button_reset => 'リセット';

  @override
  String get dialog_button_infinite => '無制限';

  @override
  String get schedule_start_label => '開始';

  @override
  String get schedule_end_label => '終了';

  @override
  String get exit_without_saving_dialog_info => '保存せずに終了してもよろしいですか?';

  @override
  String get development_dialog_info =>
      'NLP digitoxは現在開発中のため、不具合や未完成の機能がある可能性があります。 問題が発生した場合は、改善のためご報告ください。\n\nご意見ありがとうございます！';

  @override
  String get development_dialog_button_report_issue => '問題を報告';

  @override
  String get development_dialog_button_close => '閉じる';

  @override
  String get dnd_settings_tile_title => 'サイレントモード設定';

  @override
  String get dnd_settings_tile_subtitle => 'サイレントモード中のアプリ通知を管理します。';

  @override
  String get quick_actions_heading => '簡単操作';

  @override
  String get select_distracting_apps_heading => '使用制限するアプリを選択';

  @override
  String get your_distracting_apps_heading => '使用制限中のアプリ';

  @override
  String get select_more_apps_heading => 'さらにアプリを選択';

  @override
  String get imp_distracting_apps_snack_alert => 'システムアプリは使用制限アプリに追加できません。';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'このアプリでは、ネットワークの使用状況のみ確認できます。画面の使用状況と制限機能は現在ご利用いただけません。';

  @override
  String get create_group_fab_button => 'グループを作成';

  @override
  String get active_period_info =>
      'アクセスを許可する時間帯を設定してください。この時間帯以外では、アクセスが制限されます。';

  @override
  String get minimum_distracting_apps_snack_alert =>
      '使用制限するアプリを少なくとも1つは選択してください。';

  @override
  String get donation_card_title => '開発を支援する';

  @override
  String get donation_card_info =>
      'NLP digitox は、数ヶ月の開発期間を経て、無料で公開しています。このアプリをより多くの人々に届け、改善し続けるために、皆様からの温かいご支援をお待ちしています。';

  @override
  String get operation_failed_snack_alert => 'エラーが発生し、操作を完了できませんでした。';

  @override
  String get donation_card_button_donate => '寄付する';

  @override
  String get app_restart_dialog_title => '再起動してください';

  @override
  String get app_restart_dialog_info =>
      'カウントダウン終了後、NLP digitox は自動的に再起動します。変更の適用には少し時間がかかりますので、お待ちください。';

  @override
  String get accessibility_tip =>
      'よりスマートでバッテリーに優しいブロックをご希望ですか? NLP digitox のアクセシビリティ権限を有効にします。';

  @override
  String get battery_optimization_tip =>
      'NLP digitox が予期せず停止する場合は、「設定>詳細設定」から「バッテリー最適化を無視する」権限を付与して、バックグラウンドでの動作を継続させることを検討してください。';

  @override
  String get invincible_mode_tip =>
      '誤って制限を解除してしまいましたか?無敵モードを使用して、翌日または調整ウィンドウまでロックします。';

  @override
  String get glance_usage_tip =>
      '洞察が必要ですか? 「一目」セクションをチェックして、使用パターンと使用時間を確認してください。';

  @override
  String get tamper_protection_tip =>
      'NLP digitox をアンインストールしますか?まずアンインストール ウィンドウを有効にして、タンパー プロテクションを安全に無効にします。';

  @override
  String get notification_blocking_tip =>
      '気を散らすものを減らしたいですか?通知ブロックを使用して、選択したアプリを沈黙させます。';

  @override
  String get usage_history_tip =>
      '自分の習慣を振り返ってみませんか?過去のパターンを確認するには、使用履歴を確認してください。';

  @override
  String get focus_mode_tip =>
      '深い集中力が必要ですか?タスク中のアプリと通知をブロックするには、フォーカス モードをオンにします。';

  @override
  String get bedtime_reminder_tip =>
      '睡眠を改善したいですか?就寝時間リマインダーを設定して、毎晩リラックスしましょう。';

  @override
  String get custom_blocking_tip =>
      'カスタムエクスペリエンスが必要ですか?ニーズに合ったアプリのブロック ルールを作成します。';

  @override
  String get session_timeline_tip =>
      'フォーカスセッションを追跡したいですか?タイムラインを表示して、集中の過程を確認します。';

  @override
  String get short_content_blocking_tip =>
      'ソーシャルアプリに気を取られていますか？集中力を保つために、Instagram や YouTube などの短いコンテンツをブロックします。';

  @override
  String get parental_controls_tip =>
      'ペアレンタルコントロールが必要ですか?お子様のデバイスに制限を設定して、安全な体験を確保してください。';

  @override
  String get notification_batching_tip =>
      '気を散らすものを減らしたいですか?通知のバッチ処理を使用して、通知をグループ化し、一度に確認します。';

  @override
  String get notification_scheduling_tip =>
      '通知を管理する必要がありますか?特定のアプリの通知をいつ受信するかをスケジュールします。';

  @override
  String get quick_focus_tile_tip =>
      'フォーカスにすばやくアクセスする必要がありますか?クイック フォーカス タイルを追加すると、フォーカス モードが即座に有効になります。';

  @override
  String get app_shortcuts_tip =>
      'インスタントアプリにアクセスしたいですか?アプリアイコンを長押ししてショートカットを追加すると、素早い操作が可能になります。';

  @override
  String get backup_usage_db_tip =>
      'データを保存したいですか?記録を安全に保つために、使用状況データベースをバックアップしてください。';

  @override
  String get dynamic_material_color_tip =>
      'カスタムテーマが必要ですか?ダイナミック マテリアルを有効にする デバイスのテーマに合わせて色を設定します。';

  @override
  String get amoled_dark_theme_tip =>
      'バッテリーを節約したいですか? AMOLED ダークテーマを使用して、OLED スクリーンの消費電力を削減します。';

  @override
  String get customize_usage_history_tip =>
      '使用履歴を残しておきたいですか？使用履歴に何週間分のデータを保存するかをカスタマイズします。';

  @override
  String get grouped_apps_blocking_tip =>
      'アプリをまとめてブロックしたいですか?制限グループを使用してアプリの制限をグループ化し、複数のアプリを一度にブロックします。';

  @override
  String get websites_blocking_tip =>
      'よりクリーンなブラウジング体験をご希望ですか?カスタム Web サイトや NSFW Web サイトをブロックして、オンライン時間をより集中させましょう。';

  @override
  String get data_usage_tip =>
      'データを追跡したいですか?インターネット消費のためにモバイルと Wi-Fi のデータ使用量を監視します。';

  @override
  String get block_internet_tip =>
      'アプリのインターネットをブロックする必要がありますか?アプリのダッシュボードから特定のアプリのインターネットを遮断します。';

  @override
  String get emergency_passes_tip =>
      '休憩が必要ですか?毎日 3 つの緊急パスを使用すると、5 分間アプリのブロックを一時的に解除できます。';

  @override
  String get onboarding_skip_btn_label => 'スキップ';

  @override
  String get onboarding_finish_setup_btn_label => '設定終了';

  @override
  String get onboarding_page_welcome_title => 'NLP digitox へようこそ。';

  @override
  String get onboarding_page_welcome_info =>
      'デジタルライフをコントロールし、より健全なスクリーン習慣を築きましょう。NLP digitox は、集中力を保ち、気を散らすものを減らし、毎日意識的な選択をするのに役立ちます。';

  @override
  String get onboarding_page_statistics_title => '習慣を知ろう。';

  @override
  String get onboarding_page_statistics_info =>
      'スクリーンタイム、アプリの使用状況、集中の傾向に関する詳細なインサイトで、自分のデジタルパターンを理解しましょう。進捗を追跡し、小さな変化が大きな改善につながることを実感できます。';

  @override
  String get onboarding_page_one_title => '集中力を持続させる';

  @override
  String get onboarding_page_one_info =>
      'NLP digitox で集中力をマスターしましょう。気が散るアプリやショートコンテンツをブロックし、あなただけの集中時間を作り出します。';

  @override
  String get onboarding_page_two_title => '邪魔をブロック';

  @override
  String get onboarding_page_two_info =>
      'アプリの使用制限を設定し、自動的にアプリを一時停止し、より健全なデジタル習慣を身につけましょう。サイレントモードを使用して、リラックスして邪魔のない夜を楽しみましょう。';

  @override
  String get onboarding_page_three_title => 'プライバシー重視';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox は、あなたのプライバシーを最優先に考えています。アプリは100%オープンソースで、オフラインで動作するため、個人情報は一切収集されません。';

  @override
  String get onboarding_page_permissions_title => '必要な権限';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox が画面の使用時間を追跡・管理し、集中力を高めるために必要な権限は以下のとおりです。';

  @override
  String get dashboard_tab_title => 'ダッシュボード';

  @override
  String get focus_now_fab_button => '今すぐ集中';

  @override
  String get welcome_greetings => 'おかえりなさい';

  @override
  String get username_snack_alert => 'ユーザー名を編集するには長押ししてください。';

  @override
  String get username_dialog_title => 'ユーザー名';

  @override
  String get username_dialog_info => 'ダッシュボードに表示されるユーザー名を入力してください。';

  @override
  String get username_dialog_button_apply => '保存';

  @override
  String get glance_tile_title => '概要';

  @override
  String get glance_tile_subtitle => '使用状況をひと目で確認できます。';

  @override
  String get parental_controls_tile_subtitle => '無敵モードと改ざん防止。';

  @override
  String get restrictions_heading => 'アプリの制限';

  @override
  String get apps_blocking_tile_title => 'アプリのブロック';

  @override
  String get apps_blocking_tile_subtitle => '複数の方法でアプリを制限します。';

  @override
  String get grouped_apps_blocking_tile_title => 'グループアプリのブロック';

  @override
  String get grouped_apps_blocking_tile_subtitle => '複数のアプリを同時に制限します。';

  @override
  String get shorts_blocking_tile_subtitle => '複数のプラットフォームでショート動画を制限します。';

  @override
  String get websites_blocking_tile_subtitle => 'アダルトサイトやカスタムウェブサイトを制限します。';

  @override
  String get screen_time_label => '使用時間';

  @override
  String get total_data_label => '総データ量';

  @override
  String get mobile_data_label => 'モバイルデータ';

  @override
  String get wifi_data_label => 'Wi-Fiデータ';

  @override
  String get focus_today_label => '今日の集中';

  @override
  String get focus_weekly_label => '週間集中';

  @override
  String get focus_monthly_label => '月間集中';

  @override
  String get focus_lifetime_label => '総集中時間';

  @override
  String get longest_streak_label => '最大連続記録';

  @override
  String get current_streak_label => '現在の連続記録';

  @override
  String get successful_sessions_label => '集中できた回数';

  @override
  String get failed_sessions_label => '集中できなかった回数';

  @override
  String get statistics_tab_title => '統計データ';

  @override
  String get screen_segment_label => '使用時間';

  @override
  String get data_segment_label => 'データ使用量';

  @override
  String get mobile_label => 'モバイル';

  @override
  String get wifi_label => 'Wi-Fi';

  @override
  String get most_used_apps_heading => 'よく使うアプリ';

  @override
  String get show_all_apps_tile_title => 'すべてのアプリを表示';

  @override
  String get search_apps_hint => 'アプリを検索...';

  @override
  String get notifications_tab_title => '通知';

  @override
  String get notifications_tab_info =>
      'アプリからの通知をまとめて、朝、昼、夕方、夜などのスケジュールを設定します。常に中断されることなく、必要な情報を得られます。';

  @override
  String get batched_apps_tile_title => '通知をまとめるアプリ';

  @override
  String get batch_recap_dropdown_title => 'バッチ要約タイプ';

  @override
  String get batch_recap_dropdown_info =>
      'スケジュールがトリガーされたときにプッシュする内容 (すべての通知または概要のみ) を選択します。';

  @override
  String get batch_recap_option_summery_only => '概要のみ';

  @override
  String get batch_recap_option_all_notifications => 'すべての通知';

  @override
  String get notification_history_tile_title => '通知履歴';

  @override
  String get store_all_tile_title => 'すべての通知を保存する';

  @override
  String get store_all_tile_subtitle => 'バッチではない通知も保存します。';

  @override
  String get schedules_heading => 'スケジュール';

  @override
  String get new_schedule_fab_button => '新しいスケジュール';

  @override
  String get new_schedule_dialog_info => '通知スケジュールの名前を入力して、簡単に識別できるようにしてください。';

  @override
  String get new_schedule_dialog_field_label => 'スケジュール名';

  @override
  String get bedtime_tab_title => '就寝モード';

  @override
  String get bedtime_tab_info =>
      '時間帯と曜日を選択して、就寝スケジュールを設定しましょう。集中を妨げるアプリをブロックし、サイレントモードを有効にして、穏やかな夜を過ごしましょう。';

  @override
  String get schedule_tile_title => 'スケジュール';

  @override
  String get schedule_tile_subtitle => '毎日のスケジュールを有効または無効にします。';

  @override
  String get bedtime_no_days_selected_snack_alert => '曜日を少なくとも1つ選択してください。';

  @override
  String get bedtime_minimum_duration_snack_alert => '就寝時間の合計は30分以上である必要があります。';

  @override
  String get distracting_apps_tile_title => '集中を妨げるアプリ';

  @override
  String get distracting_apps_tile_subtitle => '就寝前の集中を妨げるアプリを選択してください。';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      '就寝スケジュールが有効になっている間は、集中を妨げるアプリの一覧を変更することはできません。';

  @override
  String get parental_controls_tab_title => 'ペアレンタルコントロール';

  @override
  String get invincible_mode_heading => '無敵モード';

  @override
  String get invincible_mode_tile_title => '無敵モードの有効化';

  @override
  String get invincible_mode_info =>
      '無敵モードがオンになっている場合、1日の使用量上限に達すると、選択した制限を調整できなくなります。ただし、選択した10分間の無敵ウィンドウ内では変更が可能です。';

  @override
  String get invincible_mode_snack_alert => '無敵モードが有効になっているため、制限は変更できません。';

  @override
  String get invincible_mode_dialog_info =>
      '無敵モードを有効にすると、このアプリをアンインストールするまでオフにできません。本当に有効にしますか？';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'このアプリがデバイスにインストールされている限り、無敵モードをオフにすることはできません。';

  @override
  String get invincible_mode_dialog_button_start_anyway => '開始する';

  @override
  String get invincible_mode_include_timer_tile_title => 'タイマーを含める';

  @override
  String get invincible_mode_include_launch_limit_tile_title => '起動回数の制限を含める';

  @override
  String get invincible_mode_include_active_period_tile_title => '使用可能な時間を含める';

  @override
  String get invincible_mode_app_restrictions_tile_title => 'アプリの制限';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      '毎日の制限を超えると、アプリの制限設定を変更できなくなります。';

  @override
  String get invincible_mode_group_restrictions_tile_title => 'グループの制限';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      '毎日の制限を超えると、グループの制限設定を変更できなくなります。';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'ショート動画タイマーを含める';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      '毎日の制限を超えると、ショート動画の制限設定を変更できなくなります。';

  @override
  String get invincible_mode_include_bedtime_tile_title => '就寝時間を含める';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      '就寝時間中は制限設定を変更できなくなります。';

  @override
  String get protected_access_tile_title => 'アクセス保護';

  @override
  String get protected_access_tile_subtitle => 'デバイスロックで NLP digitox を保護する';

  @override
  String get protected_access_no_lock_snack_alert =>
      'この機能を有効にするには、まずデバイスに生体認証ロックを設定してください。';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'デバイスロックが解除されました。続行するには、新しいロックを設定してください。';

  @override
  String get protected_access_failed_lock_snack_alert =>
      '認証に失敗しました。続行するにはデバイスロックの確認が必要です。';

  @override
  String get tamper_protection_tile_title => '改ざん防止';

  @override
  String get tamper_protection_tile_subtitle => 'アプリのアンインストールと強制終了を制限する';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      '有効にすると、選択したアンインストール ウィンドウ中を除き、NLP digitox のデータをアンインストール、強制停止、またはクリアできなくなります。回避策はありません。\n\nご自身の責任で続行してください。';

  @override
  String get uninstall_window_tile_title => 'アンインストール画面';

  @override
  String get uninstall_window_tile_subtitle => '改ざん防止は、選択した時間から10分以内に無効にできます。';

  @override
  String get invincible_window_tile_title => '無敵ウィンドウ';

  @override
  String get invincible_window_tile_subtitle => '選択した制限は、指定時間から10分以内に変更できます。';

  @override
  String get shorts_blocking_tab_title => 'ショート動画ブロック';

  @override
  String get shorts_blocking_tab_info =>
      'Instagram、YouTube、Snapchat、Facebookなどのプラットフォームやそのウェブサイトで、ショート動画に費やす時間をコントロールできます。';

  @override
  String get short_content_heading => 'ショート動画';

  @override
  String shorts_time_left_from(String timeShortString) {
    return '残りあと $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'ショート動画の毎日の利用時間を制限できます。制限時間に達すると、深夜0時までショート動画は視聴できなくなります。';

  @override
  String get instagram_features_tile_title => 'インスタグラム';

  @override
  String get instagram_features_tile_subtitle => 'Instagramの機能を制限します。';

  @override
  String get instagram_features_block_reels => 'リールセクションを制限します。';

  @override
  String get instagram_features_block_explore => '探索セクションを制限します。';

  @override
  String get snapchat_features_tile_title => 'スナップチャット';

  @override
  String get snapchat_features_tile_subtitle => 'Snapchatの機能を制限します。';

  @override
  String get snapchat_features_block_spotlight => 'スポットライトセクションを制限します。';

  @override
  String get snapchat_features_block_discover => 'ディスカバーセクションを制限します。';

  @override
  String get youtube_features_tile_title => 'YouTube';

  @override
  String get youtube_features_tile_subtitle => 'YouTubeのショート動画を制限します。';

  @override
  String get facebook_features_tile_title => 'フェイスブック';

  @override
  String get facebook_features_tile_subtitle => 'Facebookのリールを制限します。';

  @override
  String get reddit_features_tile_title => 'レディット';

  @override
  String get reddit_features_tile_subtitle => 'Redditのショート動画を制限します。';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Xの動画フィードを制限します。';

  @override
  String get threads_features_tile_title => 'Threads';

  @override
  String get threads_features_tile_subtitle => 'Threadsの動画/リールを制限します。';

  @override
  String get websites_blocking_tab_title => 'ウェブサイトブロック';

  @override
  String get websites_blocking_tab_info =>
      'アダルトウェブサイトや任意のカスタムサイトをブロックして、より安全で集中できるオンライン環境を作成します。ブラウジングを管理し、気が散らないようにしましょう。';

  @override
  String get adult_content_heading => 'アダルトコンテンツ';

  @override
  String get block_nsfw_title => '職場閲覧注意をブロック';

  @override
  String get block_nsfw_subtitle => 'アダルトサイトやポルノサイトの閲覧を制限する';

  @override
  String get block_nsfw_dialog_info =>
      'この操作は元に戻せません。アダルトサイトブロッカーを有効にすると、このアプリがデバイスにインストールされている間は、無効にすることができなくなります。';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'ブロックする';

  @override
  String get blocked_websites_heading => 'ブロック済みのウェブサイト';

  @override
  String get blocked_websites_empty_list_hint =>
      '集中を妨げるウェブサイトをブロックするには、ウェブサイトを追加するボタンを選択してください。';

  @override
  String get add_website_fab_button => 'ウェブサイトを追加';

  @override
  String get add_website_dialog_title => '集中を妨げるウェブサイト';

  @override
  String get add_website_dialog_info => 'ブロックするウェブサイトのURLを入力してください。';

  @override
  String get add_website_dialog_is_nsfw => 'アダルトサイトですか？';

  @override
  String get add_website_dialog_nsfw_warning => '警告：アダルトサイトは一度追加すると削除できません。';

  @override
  String get add_website_dialog_button_block => 'ブロック';

  @override
  String get add_website_already_exist_snack_alert =>
      'このURLは既にブロック済みのウェブサイトに追加されています。';

  @override
  String get add_website_invalid_url_snack_alert => 'URLが無効です。ホスト名を確認してください。';

  @override
  String get remove_website_dialog_title => 'ウェブサイトを削除';

  @override
  String remove_website_dialog_info(String websitehost) {
    return '$websitehost のブロックを解除しますか？';
  }

  @override
  String get focus_tab_title => '集中記録';

  @override
  String get focus_tab_info =>
      '集中力を高めたい時は、新しい集中記録を開始しましょう。タイプを選択し、集中を妨げるアプリを一時停止し、サイレントモードを有効にすることで、邪魔されることなく集中できます。';

  @override
  String get active_session_card_title => '有効な記録';

  @override
  String get active_session_card_info =>
      '集中記録が開始されています。表示を選択して、現在の進捗状況を確認しましょう。';

  @override
  String get active_session_card_view_button => '表示';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      '集中記録が有効な間は、集中を妨げるアプリを削除することはできません。ただし、新しいアプリを追加することはできます。';

  @override
  String get focus_profile_tile_title => 'フォーカスプロファイル';

  @override
  String get focus_session_duration_tile_title => '集中する時間';

  @override
  String get focus_session_duration_tile_subtitle => '停止するまでずっと';

  @override
  String get focus_session_duration_dialog_info => '集中したい時間を選択してください。';

  @override
  String get focus_profile_customization_tile_title => 'プロファイルのカスタマイズ';

  @override
  String get focus_profile_customization_tile_subtitle =>
      '選択したプロファイルの設定をカスタマイズします。';

  @override
  String get focus_enforce_tile_title => 'セッションを強制する';

  @override
  String get focus_enforce_tile_subtitle => '時間が終了する前にセッションが終了することを防ぎます。';

  @override
  String get focus_session_start_button => 'スワイプしてセッションを開始';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      '集中記録を開始するには、少なくとも1つの集中を妨げるアプリを選択する必要があります。';

  @override
  String get focus_session_already_active_snack_alert =>
      '集中記録は既に開始されています。新しい記録を開始する前に、現在の記録を終了するか停止してください。';

  @override
  String get focus_session_type_study => '勉強';

  @override
  String get focus_session_type_work => '仕事';

  @override
  String get focus_session_type_exercise => 'エクササイズ';

  @override
  String get focus_session_type_meditation => '瞑想';

  @override
  String get focus_session_type_creativeWriting => '創作';

  @override
  String get focus_session_type_reading => '読書';

  @override
  String get focus_session_type_programming => 'プログラミング';

  @override
  String get focus_session_type_chores => '家事';

  @override
  String get focus_session_type_projectPlanning => 'プロジェクト計画';

  @override
  String get focus_session_type_artAndDesign => '芸術とデザイン';

  @override
  String get focus_session_type_languageLearning => '言語学習';

  @override
  String get focus_session_type_musicPractice => '音楽練習';

  @override
  String get focus_session_type_selfCare => '健康管理';

  @override
  String get focus_session_type_brainstorming => 'アイデア出し';

  @override
  String get focus_session_type_skillDevelopment => '技術';

  @override
  String get focus_session_type_research => '調査';

  @override
  String get focus_session_type_networking => '交流';

  @override
  String get focus_session_type_cooking => '料理';

  @override
  String get focus_session_type_sportsTraining => 'スポーツ';

  @override
  String get focus_session_type_restAndRelaxation => '休憩';

  @override
  String get focus_session_type_other => 'その他';

  @override
  String get timeline_tab_title => '使用履歴';

  @override
  String get focus_timeline_tab_info =>
      'カレンダーから日付を選択して、集中の旅を探索してください。進捗状況を追跡し、成功を振り返り、課題から学びましょう。';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return '選択した月の集中時間は合計 $timeString です。';
  }

  @override
  String get selected_month_productive_days_label => '集中できた日数';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return '選択した月に集中できた日数は $daysCount 日です。';
  }

  @override
  String get selected_day_focused_time_label => '集中した時間';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return '選択した日の集中時間の合計は $timeString です。';
  }

  @override
  String get calender_heading => 'カレンダー';

  @override
  String get your_sessions_heading => '活動記録';

  @override
  String get your_sessions_empty_list_hint => '選択した日は活動記録がありませんでした。';

  @override
  String get focus_session_tile_timestamp_label => 'タイムスタンプ';

  @override
  String get focus_session_tile_duration_label => '継続時間';

  @override
  String get focus_session_tile_reflection_label => '反射';

  @override
  String get focus_session_state_active => '有効';

  @override
  String get focus_session_state_successful => '成功';

  @override
  String get focus_session_state_failed => '失敗';

  @override
  String get active_session_tab_title => '記録';

  @override
  String get active_session_none_warning => '有効な集中記録が見つかりません。ホーム画面に戻ります。';

  @override
  String get active_session_dialog_button_keep_pushing => '諦めずに続けましょう';

  @override
  String get active_session_finish_dialog_title => '終了';

  @override
  String get active_session_finish_dialog_info =>
      '集中力が鍛えられています！このまま記録を終了しますか？少しの時間も無駄にせず、目標達成を目指しましょう。';

  @override
  String get active_session_giveup_dialog_title => '諦める';

  @override
  String get active_session_giveup_dialog_info =>
      'もう少しで目標達成です！本当にこの集中記録を途中で終了しますか？これまでの進捗は失われます。';

  @override
  String get active_session_reflection_dialog_title => 'セッションの振り返り';

  @override
  String get active_session_reflection_dialog_info =>
      '少し時間を取って自分の進歩を振り返ってください。このセッションの目標は何ですか?このセッション中に何を達成しましたか?';

  @override
  String get active_session_reflection_dialog_tip =>
      'ヒント: これは、後からセッション タイムラインでいつでも編集できます。';

  @override
  String get active_session_giveup_snack_alert =>
      '諦めてしまいましたか？大丈夫、次回はきっと集中できます。どんな努力も無駄にはなりません。諦めずに続けましょう！';

  @override
  String get active_session_quote_one =>
      'どんな小さな一歩も、目標達成に繋がっています。自信を持って、進み続けましょう。';

  @override
  String get active_session_quote_two => '素晴らしい！集中力が持続しています！';

  @override
  String get active_session_quote_three => 'すごい集中力！この調子で続けましょう！';

  @override
  String get active_session_quote_four => 'あと少し！最後まで集中力を維持しましょう！';

  @override
  String active_session_quote_five(String durationString) {
    return 'おめでとうございます🎉 \n$durationString の集中記録を完了しました！\n\nお疲れ様でした！これからも続けていきましょう。';
  }

  @override
  String get restriction_groups_tab_title => '制限グループ';

  @override
  String get restriction_groups_tab_info =>
      '複数のアプリをまとめて時間制限できます。制限時間に達すると、グループ内のすべてのアプリが一時停止され、集中とバランスを保てます。';

  @override
  String get restriction_group_time_spent_label => '今日の使用時間';

  @override
  String get restriction_group_time_left_label => '今日の残り時間';

  @override
  String get restriction_group_name_tile_title => 'グループ名';

  @override
  String get restriction_group_name_picker_dialog_info =>
      '制限グループの名前を入力すると、簡単に分類と管理ができます。';

  @override
  String get restriction_group_timer_tile_title => 'グループのタイマー';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'このグループに毎日の使用時間を制限できます。制限時間に達すると、グループ内のすべてのアプリは深夜0時まで使えなくなります。';

  @override
  String get restriction_group_active_period_tile_title => 'グループの使用時間帯';

  @override
  String get remove_restriction_group_dialog_title => 'グループを削除';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return '$groupName を制限グループから削除しますか？';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'タイマーを設定するか、使用時間帯を制限してください。';

  @override
  String get notifications_empty_list_hint => 'その日にバッチ通知された通知はありません。';

  @override
  String get conversations_label => '会話';

  @override
  String get last_24_hours_heading => '過去24時間';

  @override
  String get notification_timeline_tab_info =>
      'カレンダーから日付を選択して、通知履歴を参照します。どのアプリがあなたの注意を引いたかを確認し、デジタル習慣を振り返ってください。';

  @override
  String get monthly_label => '毎月';

  @override
  String get daily_label => '毎日';

  @override
  String get search_notifications_sheet_info =>
      'タイトルや内容を検索することで、過去の通知を簡単に見つけることができます。重要なアラートをすばやく見つけるのに役立ちます。';

  @override
  String get search_notifications_hint => '通知を検索...';

  @override
  String get search_notifications_empty_list_hint => '検索に一致する通知は見つかりませんでした。';

  @override
  String get app_info_none_warning => '指定されたパッケージのアプリが見つかりませんでした。ホーム画面に戻ります。';

  @override
  String get emergency_fab_button => '緊急時の使用';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'アプリブロッカーを5分間一時停止しますか？残りパスは $leftPassesCount 回です。すべてのパスを使用すると、アプリは深夜まで、または有効な集中記録が終了するまでブロックされたままになります。';
  }

  @override
  String get emergency_dialog_button_use_anyway => '使用する';

  @override
  String get emergency_started_snack_alert =>
      'アプリブロッカーは一時停止されました。5分後にブロックが再開されます。';

  @override
  String get emergency_already_active_snack_alert =>
      'アプリブロッカーは現在一時停止中、または無効になっています。通知が有効な場合は、残り時間についてお知らせします。';

  @override
  String get emergency_no_pass_left_snack_alert =>
      '緊急時パスは残り0回です。ブロックされたアプリは、深夜または集中記録終了まで使用できません。';

  @override
  String get app_limit_status_not_set => '未設定';

  @override
  String get app_timer_tile_title => 'アプリタイマー';

  @override
  String get app_timer_picker_dialog_info =>
      'このアプリに毎日の使用時間の制限を設定しましょう。制限時間に達すると、アプリは深夜0時まで一時停止します。';

  @override
  String get usage_reminders_tile_title => '使用リマインダー';

  @override
  String get usage_reminders_tile_subtitle => '時間制限のあるアプリを使用するときに優しくナッジします。';

  @override
  String get app_launch_limit_tile_title => '起動回数の制限';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return '今日は $count 回起動しました。';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      '毎日、アプリを起動できる回数を制限できます。制限回数を超えると、深夜0時までアプリは起動できなくなります。';

  @override
  String get app_active_period_tile_title => '使用可能な時間';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return '$startTime から $endTime まで';
  }

  @override
  String get internet_access_tile_title => 'インターネット接続';

  @override
  String get internet_access_tile_subtitle => 'オフにすると、アプリのインターネット接続を遮断します。';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return '$appName はインターネットに接続できません。';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return '$appName はインターネットに接続できます。';
  }

  @override
  String get launch_app_tile_title => 'アプリの起動';

  @override
  String launch_app_tile_subtitle(String appName) {
    return '$appName を開く';
  }

  @override
  String get go_to_app_settings_tile_title => '設定画面へ';

  @override
  String get go_to_app_settings_tile_subtitle => '通知や権限、ストレージなどのアプリ設定を管理します。';

  @override
  String get include_in_stats_tile_title => '使用時間に含める';

  @override
  String get include_in_stats_tile_subtitle =>
      'このアプリを合計使用時間から除外するには、オフにしてください。';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName は使用時間に含まれません。';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName は使用時間に含まれます。';
  }

  @override
  String get general_tab_title => '全般設定';

  @override
  String get appearance_heading => '外観';

  @override
  String get theme_mode_tile_title => 'カラーテーマ';

  @override
  String get theme_mode_system_label => 'システムに従う';

  @override
  String get theme_mode_light_label => 'ライトモード';

  @override
  String get theme_mode_dark_label => 'ダークモード';

  @override
  String get material_color_tile_title => '配色';

  @override
  String get amoled_dark_tile_title => 'AMOLED ダークモード';

  @override
  String get amoled_dark_tile_subtitle => 'ダークモードより深い黒色を使用';

  @override
  String get dynamic_colors_tile_title => 'ダイナミックカラー';

  @override
  String get dynamic_colors_tile_subtitle => '壁紙に合わせたカラーを使用';

  @override
  String get defaults_heading => '基本設定';

  @override
  String get app_language_tile_title => '言語設定';

  @override
  String get default_home_tab_tile_title => 'ホームタブ';

  @override
  String get usage_history_tile_title => '使用履歴';

  @override
  String get usage_history_15_days => '15日間';

  @override
  String get usage_history_1_month => '1ヶ月間';

  @override
  String get usage_history_3_month => '3ヶ月間';

  @override
  String get usage_history_6_month => '6ヶ月間';

  @override
  String get usage_history_1_year => '1年間';

  @override
  String get service_heading => 'サービス';

  @override
  String get service_stopping_warning =>
      'NLP digitoxが予期せず動作を停止した場合は、バッテリーの最適化を無視することを許可し、バックグラウンドで実行できるようにしてください。それでも問題が続く場合は、NLP digitoxを許可リストに登録して、動作を中断されないようにしてください。';

  @override
  String get whitelist_app_tile_title => 'NLP digitox を許可リストに追加';

  @override
  String get whitelist_app_tile_subtitle => 'NLP digitoxの自動起動を有効にする';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'このデバイスは自動起動の設定に対応していません。';

  @override
  String get database_tab_title => 'データベース';

  @override
  String get import_db_tile_title => 'データベースを読み込む';

  @override
  String get import_db_tile_subtitle => 'ファイルからデータベースを読み込む';

  @override
  String get export_db_tile_title => 'データベースを書き出す';

  @override
  String get export_db_tile_subtitle => 'データベースをファイルに保存';

  @override
  String get analysis_tab_title => '分析';

  @override
  String get analysis_7_days => '7日';

  @override
  String get analysis_30_days => '30日';

  @override
  String get analysis_90_days => '90日';

  @override
  String get analysis_screen_time_trend => 'スクリーンタイムの推移';

  @override
  String get analysis_no_data_info => 'この期間のスクリーンタイムデータはまだ記録されていません。';

  @override
  String get analysis_daily_average => '1日の平均';

  @override
  String get analysis_total => '合計';

  @override
  String get analysis_no_change => '先週と同じ';

  @override
  String analysis_trend_less(String percent) {
    return '先週より$percent%減';
  }

  @override
  String analysis_trend_more(String percent) {
    return '先週より$percent%増';
  }

  @override
  String get crash_logs_heading => 'クラッシュログ';

  @override
  String get crash_logs_info =>
      '問題が発生した場合は、GitHubにエラーレポートを添付して報告してください。エラーレポートには、デバイスのメーカー、モデル、Androidバージョン、SDKバージョン、クラッシュログなどの情報が含まれており、問題解決に役立ちます。';

  @override
  String get crash_logs_export_tile_title => 'エラーレポートを保存';

  @override
  String get crash_logs_export_tile_subtitle => 'エラーレポートをJSONファイルで書き出す';

  @override
  String get crash_logs_view_tile_title => 'ログを表示';

  @override
  String get crash_logs_view_tile_subtitle => '保存されたクラッシュログを確認します。';

  @override
  String get crash_logs_empty_list_hint => '現在までにクラッシュログはありません。';

  @override
  String get crash_logs_clear_tile_title => 'ログを削除';

  @override
  String get crash_logs_clear_tile_subtitle => 'すべてのクラッシュログを削除';

  @override
  String get crash_logs_clear_dialog_info =>
      'データベースからすべてのクラッシュログを削除してもよろしいですか？';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway => '削除する';

  @override
  String get about_tab_title => '概要';

  @override
  String get changelog_tile_title => '変更履歴';

  @override
  String get changelog_tile_subtitle => '最新の変更点を確認できます。';

  @override
  String get full_changelog_tile_title => '完全な変更履歴';

  @override
  String get redirected_to_github_subtitle => 'GitHubに移動';

  @override
  String get contribute_heading => '貢献';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'ソースコードを確認';

  @override
  String get report_issue_tile_title => '問題を報告';

  @override
  String get suggest_idea_tile_title => 'アイデアを提案';

  @override
  String get write_email_tile_title => 'メールでご連絡';

  @override
  String get write_email_tile_subtitle => 'メールアプリを開く';

  @override
  String get privacy_policy_heading => 'プライバシーポリシー';

  @override
  String get privacy_policy_info =>
      'NLP digitoxはプライバシー保護に最優先で取り組んでいます。ユーザーデータの収集、保存、または第三者に提供することはありません。アプリは完全にオフラインで動作し、インターネット接続を必要としないため、ユーザーの個人情報はデバイス上で安全に保護されます。無料でオープンソースのソフトウェア（FOSS）であり、完全な透明性とユーザーによるデータの制御を保証します。';

  @override
  String get more_details_button => '詳細情報';
}
