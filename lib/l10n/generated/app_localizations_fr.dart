// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get mindful_tagline => 'Concentrez-vous sur ce qui compte vraiment';

  @override
  String get unlock_button_label => 'Débloquer';

  @override
  String get permission_status_off => 'Désactivé';

  @override
  String get permission_status_allowed => 'Autorisé';

  @override
  String get permission_status_not_allowed => 'Accès non autorisé';

  @override
  String get permission_button_grant_permission => 'Donner l\'autorisation';

  @override
  String get permission_button_agree_and_continue => 'Accepter et continuer';

  @override
  String get permission_button_not_now => 'Pas maintenant';

  @override
  String get permission_button_help => 'Besoin d\'aide ?';

  @override
  String get permission_sheet_privacy_info =>
      'NLP digitox est 100% sécurisé et fonctionne hors ligne. Nous ne collectons ni stockons aucune donnée personnelle.';

  @override
  String permission_grant_step_one(String button_label) {
    return '1. Cliquez sur le bouton $button_label.';
  }

  @override
  String get permission_grant_step_two =>
      '2. Sélectionnez NLP digitox sur l\'écran suivant.';

  @override
  String get permission_grant_step_three =>
      '3. Cliquez sur le bouton et activez-le comme ci-dessous.';

  @override
  String get permission_notification_title => 'Envoyer des notifications';

  @override
  String get permission_alarms_title => 'Alarmes & Rappels';

  @override
  String get permission_alarms_info =>
      'Veuillez accorder la permission de régler les alarmes et les rappels. Cela permettra à NLP digitox de démarrer votre horaire de coucher à l\'heure, de réinitialiser les minuteurs de l\'application tous les jours à minuit et de vous aider à rester sur la bonne voie.';

  @override
  String get permission_alarms_device_tile_label =>
      'Autoriser à définir des alarmes et des rappels';

  @override
  String get permission_usage_title => 'Accès aux données d\'utilisation';

  @override
  String get permission_usage_info =>
      'Veuillez accorder l\'autorisation d\'accès aux données d\'utilisation. Cela permettra à NLP digitox de surveiller l\'utilisation des applications et de gérer l\'accès à certaines applications, pour un environnement numérique plus contrôlé et propice à la concentration.';

  @override
  String get permission_usage_device_tile_label =>
      'Autoriser l\'accès aux données d\'utilisation';

  @override
  String get permission_overlay_title => 'Afficher la superposition';

  @override
  String get permission_overlay_info =>
      'Veuillez accorder la permission d\'afficher la superposition. Cela permettra à NLP digitox d\'afficher une surcouche quand une application en pause est ouverte, ce qui vous aidera à rester concentré et à maintenir votre planning.';

  @override
  String get permission_overlay_device_tile_label =>
      'Autoriser la superposition sur d\'autres applis';

  @override
  String get permission_accessibility_title => 'Accessibilité';

  @override
  String get permission_accessibility_info =>
      'Veuillez accorder l\'autorisation d\'accessibilité. Cela permettra à NLP digitox de restreindre l\'accès au contenu vidéo court (ex : Reels, Shorts) dans les applications de réseaux sociaux et les navigateurs, et filtrer les sites Web inappropriés.';

  @override
  String get permission_accessibility_required =>
      'NLP digitox a besoin des permissions d\'accessibilité pour mieux bloquer les sites internet et les formats courts.';

  @override
  String get permission_accessibility_device_tile_label =>
      'Utiliser NLP digitox';

  @override
  String get permission_dnd_title => 'Ne pas déranger';

  @override
  String get permission_dnd_info =>
      'Veuillez autoriser l\'accès au mode Ne pas déranger. Cela permettra à NLP digitox de démarrer et d\'arrêter le mode Ne pas déranger pendant l\'horaire du sommeil.';

  @override
  String get permission_dnd_tile_title => 'Lancer Ne pas déranger';

  @override
  String get permission_dnd_tile_subtitle =>
      'Activer aussi le mode Ne pas déranger.';

  @override
  String get permission_battery_optimization_tile_title =>
      'Désactiver l\'optimisation de la batterie';

  @override
  String get permission_battery_optimization_status_enabled =>
      'Déjà non restreint';

  @override
  String get permission_battery_optimization_status_disabled =>
      'Désactiver la restriction d\'arrière-plan';

  @override
  String get permission_battery_optimization_allow_info =>
      'Autoriser la désactivation de l\'optimisation de la batterie accordera automatiquement la permission \'Alarmes & Rappels\' sur certains appareils.';

  @override
  String get permission_vpn_title => 'Créer un VPN';

  @override
  String get permission_vpn_info =>
      'Veuillez accorder la permission de créer une connexion au réseau privé virtuel (VPN). Cela permettra à NLP digitox de restreindre l\'accès à Internet pour les applications désignées en créant un VPN local sur le périphérique.';

  @override
  String get permission_admin_title => 'Admin';

  @override
  String get permission_admin_info =>
      'Les privilèges d\'administration ne sont nécessaires que pour les opérations essentielles afin de s\'assurer que l\'application fonctionne correctement et reste protégée contre les modifications.';

  @override
  String get permission_admin_snack_alert =>
      'La protection contre les modifications ne peut être désactivée que dans la plage horaire sélectionnée.';

  @override
  String get permission_notification_access_title => 'Accès aux notifications';

  @override
  String get permission_notification_access_info =>
      'Veuillez accorder l\'autorisation d\'accès aux notifications. Cela permettra à NLP digitox d\'organiser vos notifications et de les envoyer selon votre planning.';

  @override
  String get permission_notification_access_required =>
      'NLP digitox nécessite un accès aux notifications pour regrouper et planifier les notifications.';

  @override
  String get permission_notification_access_device_tile_label =>
      'Autoriser l\'accès aux notifications';

  @override
  String get day_today => 'Aujourd’hui';

  @override
  String get day_yesterday => 'Hier';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString jours',
      one: '1 jour',
      zero: '0 jour',
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
      other: '$countString heures',
      one: '1 heure',
      zero: '0 heure',
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
      other: '$countString minutes',
      one: '1 minute',
      zero: '0 minute',
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
      other: '$countString secondes',
      one: '1 seconde',
      zero: '0 secondes',
    );
    return '$_temp0';
  }

  @override
  String get time_separator_and => 'et';

  @override
  String get timer_status_active => 'Activé';

  @override
  String get timer_status_paused => 'En pause';

  @override
  String get create_button => 'Créer';

  @override
  String get update_button => 'Mettre à jour';

  @override
  String get dialog_button_cancel => 'Annuler';

  @override
  String get dialog_button_remove => 'Supprimer';

  @override
  String get dialog_button_set => 'Définir';

  @override
  String get dialog_button_reset => 'Réinitialiser';

  @override
  String get dialog_button_infinite => 'Infini';

  @override
  String get schedule_start_label => 'Démarrer';

  @override
  String get schedule_end_label => 'Fin';

  @override
  String get exit_without_saving_dialog_info =>
      'Êtes-vous sûr de vouloir quitter sans enregistrer ?';

  @override
  String get development_dialog_info =>
      'NLP digitox est actuellement en cours de développement et peut avoir des bugs ou des fonctionnalités incomplètes. Si vous rencontrez des problèmes, merci de les signaler pour nous aider à nous améliorer.\n\nMerci pour vos retours !';

  @override
  String get development_dialog_button_report_issue => 'Signaler un problème';

  @override
  String get development_dialog_button_close => 'Fermer';

  @override
  String get dnd_settings_tile_title => 'Paramètres \"Ne pas déranger\"';

  @override
  String get dnd_settings_tile_subtitle =>
      'Gérer quelles apps et notifications peuvent vous solliciter dans le mode Ne pas déranger.';

  @override
  String get quick_actions_heading => 'Actions rapides';

  @override
  String get select_distracting_apps_heading =>
      'Sélectionner les apps qui vous distraient';

  @override
  String get your_distracting_apps_heading => 'Apps qui vous distraient';

  @override
  String get select_more_apps_heading => 'Sélectionnez plus d\'apps';

  @override
  String get imp_distracting_apps_snack_alert =>
      'L\'ajout d\'applications système importantes à la liste des applications qui vous déconcentrent n\'est pas autorisé.';

  @override
  String get custom_apps_quick_actions_unavailable_warning =>
      'Le temps d\'écran et les restrictions ne sont pas disponibles pour cette application. Pour l\'instant, seulement la consommation de données est disponible';

  @override
  String get create_group_fab_button => 'Créer un groupe';

  @override
  String get active_period_info =>
      'Définissez une période pendant laquelle l\'accès sera autorisé. En dehors de cette période, l\'accès sera restreint.';

  @override
  String get minimum_distracting_apps_snack_alert =>
      'Sélectionnez au moins une app qui vous distrait.';

  @override
  String get donation_card_title => 'Soutenez-nous';

  @override
  String get donation_card_info =>
      'NLP digitox est une application gratuite et open-source, développée avec dévouement durant des mois. Si elle vous a aidé, votre don signifierait beaucoup pour nous. Chaque don nous permet de continuer à l\'améliorer et la maintenir pour tous.';

  @override
  String get operation_failed_snack_alert =>
      'L\'opération a échoué, une erreur s\'est produite !';

  @override
  String get donation_card_button_donate => 'Faire un don';

  @override
  String get app_restart_dialog_title => 'Redémarrage nécessaire';

  @override
  String get app_restart_dialog_info =>
      'NLP digitox redémarrera automatiquement à la fin du compte à rebours. Merci de patienter le temps que les modifications soient appliquées.';

  @override
  String get accessibility_tip =>
      'Vous souhaitez un blocage plus intelligent et plus économe en batterie ? Activez l’autorisation d’accessibilité pour NLP digitox.';

  @override
  String get battery_optimization_tip =>
      'NLP digitox ne fonctionne pas ? Autorisez « Ignorer l\'optimisation de la batterie » dans les paramètres pour assurer son bon fonctionnement.';

  @override
  String get invincible_mode_tip =>
      'Des restrictions supprimées accidentellement ? Utilisez le mode Invincible pour les verrouiller jusqu\'au lendemain ou à la fenêtre de réglage.';

  @override
  String get glance_usage_tip =>
      'Vous voulez des informations ? Consultez la section Coup d\'œil pour afficher vos habitudes d\'utilisation et le temps passé devant un écran.';

  @override
  String get tamper_protection_tip =>
      'Désinstallation de NLP digitox ? Activez la fenêtre de désinstallation pour désactiver en toute sécurité la protection contre les falsifications en premier.';

  @override
  String get notification_blocking_tip =>
      'Vous voulez réduire les distractions ? Utilisez le blocage des notifications pour faire taire les applications sélectionnées.';

  @override
  String get usage_history_tip =>
      'Envie de réfléchir à vos habitudes ? Vérifiez l\'historique d\'utilisation pour voir les modèles passés.';

  @override
  String get focus_mode_tip =>
      'Besoin d’une concentration profonde ? Activez le mode Focus pour bloquer les applications et les notifications pendant les tâches.';

  @override
  String get bedtime_reminder_tip =>
      'Vous souhaitez améliorer votre sommeil ? Définissez un rappel à l\'heure du coucher pour vous détendre la nuit.';

  @override
  String get custom_blocking_tip =>
      'Besoin d\'une expérience personnalisée ? Créez des règles de blocage d\'applications adaptées à vos besoins.';

  @override
  String get session_timeline_tip =>
      'Vous souhaitez suivre les séances de concentration ? Consultez la chronologie pour voir votre parcours de concentration.';

  @override
  String get short_content_blocking_tip =>
      'Distrait par les applications sociales ? Bloquez les contenus courts sur Instagram, YouTube, etc. pour rester concentré.';

  @override
  String get parental_controls_tip =>
      'Besoin d\'un contrôle parental ? Définissez des restrictions pour l\'appareil de votre enfant afin de garantir une expérience sécurisée.';

  @override
  String get notification_batching_tip =>
      'Vous voulez réduire les distractions ? Utilisez le traitement par lots de notifications pour regrouper les notifications et les vérifier immédiatement.';

  @override
  String get notification_scheduling_tip =>
      'Besoin de gérer les notifications ? Planifiez le moment où vous recevez des notifications pour des applications spécifiques.';

  @override
  String get quick_focus_tile_tip =>
      'Besoin d\'un accès rapide pour vous concentrer ? Ajoutez une vignette de mise au point rapide pour activer instantanément le mode de mise au point.';

  @override
  String get app_shortcuts_tip =>
      'Vous voulez un accès instantané aux applications ? Ajoutez des raccourcis en appuyant longuement sur l\'icône de l\'application pour des actions rapides.';

  @override
  String get backup_usage_db_tip =>
      'Vous souhaitez sauvegarder vos données ? Sauvegardez votre base de données d\'utilisation pour protéger vos enregistrements.';

  @override
  String get dynamic_material_color_tip =>
      'Vous voulez un thème personnalisé ? Activez le matériau dynamique. Vous colorez pour correspondre au thème de votre appareil.';

  @override
  String get amoled_dark_theme_tip =>
      'Vous voulez économiser la batterie ? Utilisez AMOLED Dark Theme pour réduire la consommation d\'énergie sur les écrans OLED.';

  @override
  String get customize_usage_history_tip =>
      'Vous souhaitez conserver l’historique d’utilisation ? Personnalisez le nombre de semaines de données à stocker dans l\'historique d\'utilisation.';

  @override
  String get grouped_apps_blocking_tip =>
      'Vous voulez bloquer des applications ensemble ? Utilisez les groupes de restriction pour regrouper les limites des applications et bloquer plusieurs applications à la fois.';

  @override
  String get websites_blocking_tip =>
      'Vous voulez une expérience de navigation plus propre ? Bloquez les sites Web personnalisés ou NSFW pour un temps en ligne plus ciblé.';

  @override
  String get data_usage_tip =>
      'Vous souhaitez suivre vos données ? Surveillez votre utilisation des données mobiles et Wi-Fi pour la consommation Internet.';

  @override
  String get block_internet_tip =>
      'Besoin de bloquer l\'Internet d\'une application ? Coupez Internet pour une application spécifique à partir du tableau de bord de l\'application.';

  @override
  String get emergency_passes_tip =>
      'Besoin d\'une pause ? Utilisez 3 passes d\'urgence par jour pour débloquer temporairement des applications pendant 5 minutes.';

  @override
  String get onboarding_skip_btn_label => 'Passer';

  @override
  String get onboarding_finish_setup_btn_label => 'Terminer la configuration';

  @override
  String get onboarding_page_welcome_title => 'Bienvenue sur NLP digitox.';

  @override
  String get onboarding_page_welcome_info =>
      'Reprenez le contrôle de votre vie numérique et adoptez de meilleures habitudes d\'écran. NLP digitox vous aide à rester concentré, à réduire les distractions et à faire des choix conscients chaque jour.';

  @override
  String get onboarding_page_statistics_title => 'Connaissez vos habitudes.';

  @override
  String get onboarding_page_statistics_info =>
      'Comprenez vos habitudes numériques grâce à des informations détaillées sur le temps d\'écran, l\'utilisation des applications et les tendances de concentration. Suivez vos progrès et voyez comment de petits changements mènent à de grandes améliorations.';

  @override
  String get onboarding_page_one_title => 'Maitriser votre concentration.';

  @override
  String get onboarding_page_one_info =>
      'Que vous travailliez, étudiiez, ou que vous reposiez, NLP digitox met en pause les distractions et vous permet de garder le contrôle avec des sessions de concentration personnalisables.';

  @override
  String get onboarding_page_two_title => 'Bloquer les distractions.';

  @override
  String get onboarding_page_two_info =>
      'Définissez des limites d\'utilisation, mettez automatiquement en pause les applications et créez des habitudes numériques plus saines. Utilisez le mode temps de sommeil pour vous détendre et profiter d\'une nuit sans distraction.';

  @override
  String get onboarding_page_three_title => 'Confidentialité avant tout.';

  @override
  String get onboarding_page_three_info =>
      'NLP digitox est 100% open-source et fonctionne entièrement hors ligne. Nous ne collectons ni ne partageons pas vos données personnelles — votre vie privée est garantie à tous les niveaux.';

  @override
  String get onboarding_page_permissions_title => 'Permissions indispensables.';

  @override
  String get onboarding_page_permissions_info =>
      'NLP digitox a besoin des autorisations suivantes pour suivre et gérer votre temps d\'écran, vous aider à réduire les distractions et améliorer votre concentration.';

  @override
  String get dashboard_tab_title => 'Tableau de bord';

  @override
  String get focus_now_fab_button => 'Se concentrer';

  @override
  String get welcome_greetings => 'Bienvenue à nouveau,';

  @override
  String get username_snack_alert =>
      'Appuyez longuement pour modifier le nom d\'utilisateur.';

  @override
  String get username_dialog_title => 'Nom d’utilisateur';

  @override
  String get username_dialog_info =>
      'Entrez le nom d\'utilisateur qui s\'affichera sur le tableau de bord.';

  @override
  String get username_dialog_button_apply => 'Confirmer';

  @override
  String get glance_tile_title => 'Coup d\'oeil';

  @override
  String get glance_tile_subtitle =>
      'Jetez un coup d\'œil à vos statistiques d\'utilisation.';

  @override
  String get parental_controls_tile_subtitle =>
      'Mode invincible et protection anti-modification.';

  @override
  String get restrictions_heading => 'Restrictions';

  @override
  String get apps_blocking_tile_title => 'Blocage des applications';

  @override
  String get apps_blocking_tile_subtitle =>
      'Limitez vos applications de plusieurs façons.';

  @override
  String get grouped_apps_blocking_tile_title => 'Blocage groupé';

  @override
  String get grouped_apps_blocking_tile_subtitle =>
      'Limitez plusieurs groupes simultanément.';

  @override
  String get shorts_blocking_tile_subtitle =>
      'Limitez le contenu court sur plusieurs plateformes.';

  @override
  String get websites_blocking_tile_subtitle =>
      'Limitez les sites Web pour adultes et personnalisés.';

  @override
  String get screen_time_label => 'Temps d\'écran';

  @override
  String get total_data_label => 'Total d\'utilisation des données mobiles';

  @override
  String get mobile_data_label => 'Données mobiles';

  @override
  String get wifi_data_label => 'Données Wifi';

  @override
  String get focus_today_label => 'Se concentrer aujourd\'hui';

  @override
  String get focus_weekly_label => 'Concentrez-vous chaque semaine';

  @override
  String get focus_monthly_label => 'Focus mensuel';

  @override
  String get focus_lifetime_label => 'Durée de vie de la concentration';

  @override
  String get longest_streak_label => 'Plus longue série';

  @override
  String get current_streak_label => 'Série en cours';

  @override
  String get successful_sessions_label => 'Sessions réussies';

  @override
  String get failed_sessions_label => 'Sessions échouées';

  @override
  String get statistics_tab_title => 'Statistiques';

  @override
  String get screen_segment_label => 'Écran';

  @override
  String get data_segment_label => 'Données';

  @override
  String get mobile_label => 'Mobile';

  @override
  String get wifi_label => 'Wi-Fi';

  @override
  String get most_used_apps_heading => 'Applications les plus utilisées';

  @override
  String get show_all_apps_tile_title => 'Afficher toutes les apps';

  @override
  String get search_apps_hint => 'Rechercher des applications...';

  @override
  String get notifications_tab_title => 'Notifications';

  @override
  String get notifications_tab_info =>
      'Notification par lots des applications et définissez des horaires comme le matin, midi, soir et nuit. Restez à jour sans interruption constante.';

  @override
  String get batched_apps_tile_title => 'Apps regroupées';

  @override
  String get batch_recap_dropdown_title => 'Type de récapitulatif de lot';

  @override
  String get batch_recap_dropdown_info =>
      'Choisissez ce que vous souhaitez envoyer lorsqu\'un planning se déclenche : toutes les notifications ou simplement un résumé.';

  @override
  String get batch_recap_option_summery_only => 'Résumé uniquement';

  @override
  String get batch_recap_option_all_notifications => 'Toutes les notifications';

  @override
  String get notification_history_tile_title => 'Historique des notifications';

  @override
  String get store_all_tile_title => 'Stocker toutes les notifications';

  @override
  String get store_all_tile_subtitle =>
      'Enregistrez également les notifications non groupées.';

  @override
  String get schedules_heading => 'Horaires';

  @override
  String get new_schedule_fab_button => 'Nouvel horaire';

  @override
  String get new_schedule_dialog_info =>
      'Entrez un nom pour l\'horaire de notification pour l\'identifier facilement.';

  @override
  String get new_schedule_dialog_field_label => 'Nom de l\'horaire';

  @override
  String get bedtime_tab_title => 'Dormir';

  @override
  String get bedtime_tab_info =>
      'Fixer l\'heure du coucher en sélectionnant une période et des jours de la semaine. Choisissez les applications qui vous distraient à bloquer et activer le mode Ne pas déranger pour une nuit paisible.';

  @override
  String get schedule_tile_title => 'Planifier';

  @override
  String get schedule_tile_subtitle =>
      'Activer ou désactiver la planification quotidienne.';

  @override
  String get bedtime_no_days_selected_snack_alert =>
      'Sélectionnez au moins un jour de la semaine.';

  @override
  String get bedtime_minimum_duration_snack_alert =>
      'La durée totale du temps de sommeil doit être d\'au moins 30 min.';

  @override
  String get distracting_apps_tile_title => 'Apps qui vous distraient';

  @override
  String get distracting_apps_tile_subtitle =>
      'Sélectionnez les applications qui vous distraient de votre routine du coucher.';

  @override
  String get bedtime_distracting_apps_modify_snack_alert =>
      'Les modifications de la liste des applications distrayantes ne sont pas autorisées lorsque l\'horaire du coucher est actif.';

  @override
  String get parental_controls_tab_title => 'Contrôle parental';

  @override
  String get invincible_mode_heading => 'Mode invincible';

  @override
  String get invincible_mode_tile_title => 'Activer le mode invincible';

  @override
  String get invincible_mode_info =>
      'Lorsque le mode Invincible est activé, vous ne pourrez pas ajuster les limites sélectionnées après avoir atteint votre quota quotidien. Cependant, vous pouvez apporter des modifications dans une fenêtre invincible sélectionnée de 10 minutes.';

  @override
  String get invincible_mode_snack_alert =>
      'En raison du mode invincible, les modifications des restrictions ne sont pas autorisées.';

  @override
  String get invincible_mode_dialog_info =>
      'Êtes-vous absolument sûr de vouloir activer le Mode Invincible ? Cette action est irréversible. Une fois que le Mode Invincible est activé, vous ne pouvez pas le désactiver tant que cette application est installée sur votre appareil.';

  @override
  String get invincible_mode_turn_off_snack_alert =>
      'Le mode invincible ne peut pas être désactivé tant que cette application reste installée sur votre appareil.';

  @override
  String get invincible_mode_dialog_button_start_anyway =>
      'Démarrer quand même';

  @override
  String get invincible_mode_include_timer_tile_title =>
      'Inclure une minuterie';

  @override
  String get invincible_mode_include_launch_limit_tile_title =>
      'Inclure la limite de lancement';

  @override
  String get invincible_mode_include_active_period_tile_title =>
      'Inclure la période active';

  @override
  String get invincible_mode_app_restrictions_tile_title =>
      'Restrictions d\'applications';

  @override
  String get invincible_mode_app_restrictions_tile_subtitle =>
      'Empêcher toute modification des restrictions de l\'application sélectionnée une fois les limites quotidiennes dépassées.';

  @override
  String get invincible_mode_group_restrictions_tile_title =>
      'Restrictions groupées';

  @override
  String get invincible_mode_group_restrictions_tile_subtitle =>
      'Empêcher toute modification des restrictions de du groupe d\'applications sélectionné une fois les limites quotidiennes dépassées.';

  @override
  String get invincible_mode_include_shorts_timer_tile_title =>
      'Inclure les temps de contenus courts';

  @override
  String get invincible_mode_include_shorts_timer_tile_subtitle =>
      'Empêcher toute modification une fois votre limite quotidienne de contenus courts dépassée.';

  @override
  String get invincible_mode_include_bedtime_tile_title =>
      'Inclure le temps de sommeil';

  @override
  String get invincible_mode_include_bedtime_tile_subtitle =>
      'Empêche les changements pendant l\'horaire de coucher actif.';

  @override
  String get protected_access_tile_title => 'Accès protégé';

  @override
  String get protected_access_tile_subtitle =>
      'Protégez NLP digitox avec le verrouillage de votre appareil.';

  @override
  String get protected_access_no_lock_snack_alert =>
      'Veuillez d\'abord configurer un verrouillage biométrique sur votre appareil pour activer cette fonctionnalité.';

  @override
  String get protected_access_removed_lock_snack_alert =>
      'Le verrouillage de votre appareil a été supprimé. Pour continuer, veuillez configurer un nouveau verrou.';

  @override
  String get protected_access_failed_lock_snack_alert =>
      'L\'authentification a échoué. Vous devez vérifier le verrouillage de votre appareil pour continuer.';

  @override
  String get tamper_protection_tile_title =>
      'Protection contre les manipulations';

  @override
  String get tamper_protection_tile_subtitle =>
      'Empêchez la désinstallation et forcez l\'arrêt de l\'application.';

  @override
  String get tamper_protection_confirmation_dialog_info =>
      'Une fois activé, vous ne pourrez plus désinstaller, forcer l\'arrêt ou effacer les données de NLP digitox, sauf pendant la fenêtre de désinstallation sélectionnée. Il n’existe aucune solution de contournement.\n\nProcédez à vos propres risques.';

  @override
  String get uninstall_window_tile_title => 'Fenêtre de désinstallation';

  @override
  String get uninstall_window_tile_subtitle =>
      'La protection anti-intrusion peut être désactivée dans les 10 minutes suivant l\'heure sélectionnée.';

  @override
  String get invincible_window_tile_title => 'Fenêtre invincible';

  @override
  String get invincible_window_tile_subtitle =>
      'Les limites sélectionnées peuvent être modifiées dans les 10 minutes suivant l\'heure sélectionnée.';

  @override
  String get shorts_blocking_tab_title => 'Blocage des shorts';

  @override
  String get shorts_blocking_tab_info =>
      'Contrôlez le temps que vous passez sur du contenu court sur des plateformes comme Instagram, YouTube, Snapchat et Facebook, y compris leurs sites Web.';

  @override
  String get short_content_heading => 'Contenu court';

  @override
  String shorts_time_left_from(String timeShortString) {
    return 'Temps restant sur $timeShortString';
  }

  @override
  String get short_content_timer_picker_dialog_info =>
      'Fixez une limite de temps quotidienne pour le contenu court. Une fois votre limite atteinte, le contenu court sera mis en pause jusqu\'à minuit.';

  @override
  String get instagram_features_tile_title => 'Instagram';

  @override
  String get instagram_features_tile_subtitle =>
      'Restreindre les fonctionnalités sur Instagram.';

  @override
  String get instagram_features_block_reels =>
      'Restreindre la section des bobines.';

  @override
  String get instagram_features_block_explore =>
      'Restreindre la section d\'exploration.';

  @override
  String get snapchat_features_tile_title => 'Snapchat';

  @override
  String get snapchat_features_tile_subtitle =>
      'Restreindre les fonctionnalités sur Snapchat.';

  @override
  String get snapchat_features_block_spotlight =>
      'Restreindre la section Spotlight.';

  @override
  String get snapchat_features_block_discover =>
      'Restreindre la section de découverte.';

  @override
  String get youtube_features_tile_title => 'YouTube';

  @override
  String get youtube_features_tile_subtitle =>
      'Restreindre les courts métrages sur YouTube.';

  @override
  String get facebook_features_tile_title => 'Facebook';

  @override
  String get facebook_features_tile_subtitle =>
      'Restreindre les bobines sur Facebook.';

  @override
  String get reddit_features_tile_title => 'Reddit';

  @override
  String get reddit_features_tile_subtitle =>
      'Restreindre les courts métrages sur Reddit.';

  @override
  String get x_features_tile_title => 'X';

  @override
  String get x_features_tile_subtitle => 'Restreindre le flux vidéo sur X.';

  @override
  String get threads_features_tile_title => 'Sujets';

  @override
  String get threads_features_tile_subtitle =>
      'Restreindre les vidéos/bobines sur les discussions.';

  @override
  String get websites_blocking_tab_title => 'Blocage de sites Web';

  @override
  String get websites_blocking_tab_info =>
      'Bloquez les sites Web pour adultes et tous les sites personnalisés que vous choisissez pour créer une expérience en ligne plus sûre et plus ciblée. Prenez en charge votre navigation et restez sans distraction.';

  @override
  String get adult_content_heading => 'Contenu pour adultes';

  @override
  String get block_nsfw_title => 'Bloquer le NSFW';

  @override
  String get block_nsfw_subtitle =>
      'Empêcher les navigateurs d\'ouvrir des sites pour adultes et pornographiques.';

  @override
  String get block_nsfw_dialog_info =>
      'Êtes-vous sûr(e) ? Cette action est irréversible. Une fois que le bloqueur de sites pour adultes est activé, vous ne pouvez pas le désactiver tant que cette application est installée sur votre appareil.';

  @override
  String get block_nsfw_dialog_button_block_anyway => 'Bloquer quand même';

  @override
  String get blocked_websites_heading => 'Sites web bloqués';

  @override
  String get blocked_websites_empty_list_hint =>
      'Cliquez sur le bouton « + Ajouter un site Web » pour ajouter des sites Web gênants que vous souhaitez bloquer.';

  @override
  String get add_website_fab_button => 'Ajouter un site web';

  @override
  String get add_website_dialog_title => 'Sites web qui vous distraient';

  @override
  String get add_website_dialog_info =>
      'Entrez l\'Url d\'un site web que vous voulez bloquer.';

  @override
  String get add_website_dialog_is_nsfw => 'Le site nsfw est-il ?';

  @override
  String get add_website_dialog_nsfw_warning =>
      'Attention : les sites Nsfw ne peuvent pas être supprimés une fois ajoutés.';

  @override
  String get add_website_dialog_button_block => 'Bloquer';

  @override
  String get add_website_already_exist_snack_alert =>
      'L\'URL a déjà été ajouté à la liste des sites web bloqués.';

  @override
  String get add_website_invalid_url_snack_alert =>
      'URL invalide ! Impossible d\'analyser le nom d\'hôte.';

  @override
  String get remove_website_dialog_title => 'Retirer le site web';

  @override
  String remove_website_dialog_info(String websitehost) {
    return 'Êtes-vous sûr(e) ? Vous voulez supprimer \'$websitehost\' des sites web bloqués.';
  }

  @override
  String get focus_tab_title => 'Se concentrer';

  @override
  String get focus_tab_info =>
      'Lorsque vous avez besoin de temps pour vous concentrer, démarrez une nouvelle session en sélectionnant le type, en choisissant les applications à mettre en pause, et en activant le mode Ne pas déranger pour une concentration ininterrompue.';

  @override
  String get active_session_card_title => 'Session active';

  @override
  String get active_session_card_info =>
      'Vous avez une session de concentration active en cours ! Cliquez sur \'Voir\' pour vérifier votre progression et voir combien de temps s\'est écoulé.';

  @override
  String get active_session_card_view_button => 'Voir';

  @override
  String get focus_distracting_apps_removal_snack_alert =>
      'La suppression d\'applications de la liste des applications qui vous distraient n\'est pas autorisée tant qu\'une session de concentration est active. Cependant, vous pouvez toujours ajouter des applications supplémentaires à la liste pendant cette période.';

  @override
  String get focus_profile_tile_title => 'Profil de mise au point';

  @override
  String get focus_session_duration_tile_title => 'Durée de la session';

  @override
  String get focus_session_duration_tile_subtitle =>
      'Infini (jusqu\'à ce que vous l\'arrêtiez)';

  @override
  String get focus_session_duration_dialog_info =>
      'Veuillez sélectionner la durée souhaitée pour cette session de concentration, en déterminant la durée pendant laquelle vous souhaitez rester concentré et sans distraction.';

  @override
  String get focus_profile_customization_tile_title =>
      'Personnalisation du profil';

  @override
  String get focus_profile_customization_tile_subtitle =>
      'Personnalisez les paramètres du profil sélectionné.';

  @override
  String get focus_enforce_tile_title => 'Appliquer la session';

  @override
  String get focus_enforce_tile_subtitle =>
      'Empêche de terminer une session avant la fin du temps imparti.';

  @override
  String get focus_session_start_button => 'Balayez pour démarrer la session';

  @override
  String get focus_session_minimum_apps_snack_alert =>
      'Sélectionnez au moins une application qui vous distrait pour démarrer la session de concentration';

  @override
  String get focus_session_already_active_snack_alert =>
      'Vous avez déjà une session de concentration active en cours d\'exécution. Veuillez terminer ou arrêter votre session actuelle avant d\'en commencer une nouvelle.';

  @override
  String get focus_session_type_study => 'Étude';

  @override
  String get focus_session_type_work => 'Travail';

  @override
  String get focus_session_type_exercise => 'Exercice';

  @override
  String get focus_session_type_meditation => 'Méditation';

  @override
  String get focus_session_type_creativeWriting => 'Écriture créative';

  @override
  String get focus_session_type_reading => 'Lecture';

  @override
  String get focus_session_type_programming => 'Programmation';

  @override
  String get focus_session_type_chores => 'Corvées';

  @override
  String get focus_session_type_projectPlanning => 'Planification du projet';

  @override
  String get focus_session_type_artAndDesign => 'Art et design';

  @override
  String get focus_session_type_languageLearning => 'Apprentissage des langues';

  @override
  String get focus_session_type_musicPractice => 'Pratique musicale';

  @override
  String get focus_session_type_selfCare => 'Soins personnels';

  @override
  String get focus_session_type_brainstorming => 'Remue-méninges';

  @override
  String get focus_session_type_skillDevelopment =>
      'Développement des compétences';

  @override
  String get focus_session_type_research => 'Recherche';

  @override
  String get focus_session_type_networking => 'Réseautage';

  @override
  String get focus_session_type_cooking => 'Cuisine';

  @override
  String get focus_session_type_sportsTraining => 'Entraînement sportif';

  @override
  String get focus_session_type_restAndRelaxation => 'Repos et détente';

  @override
  String get focus_session_type_other => 'Autre';

  @override
  String get timeline_tab_title => 'Chronologie';

  @override
  String get focus_timeline_tab_info =>
      'Explorez votre parcours de concentration en sélectionnant une date dans le calendrier. Suivez vos progrès, revisitez vos réussites et apprenez des défis.';

  @override
  String selected_month_productive_time_snack_alert(String timeString) {
    return 'Votre temps productif total pour le mois sélectionné est $timeString.';
  }

  @override
  String get selected_month_productive_days_label => 'Des journées productives';

  @override
  String selected_month_productive_days_snack_alert(num daysCount) {
    return 'Vous avez eu un total de jours productifs $daysCount au cours du mois sélectionné.';
  }

  @override
  String get selected_day_focused_time_label => 'Temps concentré';

  @override
  String selected_day_focused_time_snack_alert(String timeString) {
    return 'Votre temps total de concentration pour le jour sélectionné est $timeString.';
  }

  @override
  String get calender_heading => 'Calendrier';

  @override
  String get your_sessions_heading => 'Vos séances';

  @override
  String get your_sessions_empty_list_hint =>
      'Aucune séance de concentration enregistrée pour le jour sélectionné.';

  @override
  String get focus_session_tile_timestamp_label => 'Horodatage';

  @override
  String get focus_session_tile_duration_label => 'Durée';

  @override
  String get focus_session_tile_reflection_label => 'Réflexion';

  @override
  String get focus_session_state_active => 'Actif';

  @override
  String get focus_session_state_successful => 'Réussi';

  @override
  String get focus_session_state_failed => 'Échec';

  @override
  String get active_session_tab_title => 'Séance';

  @override
  String get active_session_none_warning =>
      'Aucune session active trouvée. Retour à l\'écran d\'accueil.';

  @override
  String get active_session_dialog_button_keep_pushing => 'Continuez à pousser';

  @override
  String get active_session_finish_dialog_title => 'Terminer';

  @override
  String get active_session_finish_dialog_info =>
      'Restez fort ! Vous développez une concentration précieuse. Êtes-vous sûr de vouloir mettre fin à cette session de discussion ? Chaque instant supplémentaire compte pour vos objectifs.';

  @override
  String get active_session_giveup_dialog_title => 'Abandonner';

  @override
  String get active_session_giveup_dialog_info =>
      'Attendez! Vous y êtes presque, n\'abandonnez pas maintenant ! Êtes-vous sûr de vouloir mettre fin à cette séance de discussion plus tôt ? Les progrès seront perdus.';

  @override
  String get active_session_reflection_dialog_title => 'Réflexion de la séance';

  @override
  String get active_session_reflection_dialog_info =>
      'Prenez un moment pour réfléchir à vos progrès. Quel est votre objectif pour cette séance ? Qu’avez-vous accompli lors de cette séance ?';

  @override
  String get active_session_reflection_dialog_tip =>
      'Astuce : Vous pouvez toujours modifier cela ultérieurement dans la chronologie de la session.';

  @override
  String get active_session_giveup_snack_alert =>
      'Vous avez abandonné ! Ne vous inquiétez pas, vous pourrez faire mieux la prochaine fois. Chaque effort compte - continuez simplement';

  @override
  String get active_session_quote_one =>
      'Chaque pas compte, reste fort et continue';

  @override
  String get active_session_quote_two =>
      'Restez concentré ! tu fais des progrès incroyables';

  @override
  String get active_session_quote_three =>
      'Vous l\'écrasez ! Maintenir l\'élan';

  @override
  String get active_session_quote_four =>
      'Il me reste encore un peu, tu te débrouilles à merveille';

  @override
  String active_session_quote_five(String durationString) {
    return 'Félicitations 🎉 \n Vous avez terminé votre session de concentration de $durationString.\n\nExcellent travail, continuez votre travail incroyable';
  }

  @override
  String get restriction_groups_tab_title => 'Groupes de restrictions';

  @override
  String get restriction_groups_tab_info =>
      'Définissez une limite de temps d\'écran combinée pour un groupe d\'applications. Une fois que l\'utilisation totale atteint votre limite, toutes les applications du groupe seront mises en pause pour vous aider à maintenir votre concentration et votre équilibre.';

  @override
  String get restriction_group_time_spent_label => 'Temps passé aujourd\'hui';

  @override
  String get restriction_group_time_left_label => 'Temps restant aujourd\'hui';

  @override
  String get restriction_group_name_tile_title => 'Nom du groupe';

  @override
  String get restriction_group_name_picker_dialog_info =>
      'Entrez un nom pour le groupe de restriction afin de l\'identifier et de le gérer facilement.';

  @override
  String get restriction_group_timer_tile_title => 'Minuteur pour le groupe';

  @override
  String get restriction_group_timer_picker_dialog_info =>
      'Définissez une limite de temps quotidienne pour ce groupe. Une fois votre limite atteinte, toutes les applications de ce groupe seront suspendues jusqu\'à minuit.';

  @override
  String get restriction_group_active_period_tile_title =>
      'Période d\'activité du groupe';

  @override
  String get remove_restriction_group_dialog_title => 'Supprimer groupe';

  @override
  String remove_restriction_group_dialog_info(String groupName) {
    return 'Êtes-vous sûr ? Vous voulez supprimer \'$groupName\' des groupes de restrictions.';
  }

  @override
  String get restriction_group_invalid_limits_snack_alert =>
      'Définissez une limite de temps ou une limite de période d\'activité.';

  @override
  String get notifications_empty_list_hint =>
      'Aucune notification n\'a été regroupée pour la journée.';

  @override
  String get conversations_label => 'Conversations';

  @override
  String get last_24_hours_heading => 'Dernières 24 heures';

  @override
  String get notification_timeline_tab_info =>
      'Parcourez votre historique de notifications en sélectionnant une date dans le calendrier. Découvrez quelles applications ont retenu votre attention et réfléchissez à vos habitudes numériques.';

  @override
  String get monthly_label => 'Mensuel';

  @override
  String get daily_label => 'Quotidiennement';

  @override
  String get search_notifications_sheet_info =>
      'Retrouvez facilement les notifications passées en recherchant leur titre ou leur contenu. Vous aide à localiser rapidement les alertes importantes.';

  @override
  String get search_notifications_hint => 'Rechercher des notifications...';

  @override
  String get search_notifications_empty_list_hint =>
      'Aucune notification trouvée correspondant à votre recherche.';

  @override
  String get app_info_none_warning =>
      'Impossible de trouver l\'application pour le package donné. Retour à l\'écran d\'accueil.';

  @override
  String get emergency_fab_button => 'Urgence';

  @override
  String emergency_dialog_info(num leftPassesCount) {
    return 'Cette action mettra en pause le bloqueur de l\'application pour les 5 prochaines minutes. Il vous reste $leftPassesCount délais. Après avoir utilisé tous les délais, l\'application restera bloquée jusqu\'à minuit, ou la session de concentration active se terminera.\n\nContinuer quand même ?';
  }

  @override
  String get emergency_dialog_button_use_anyway => 'Utiliser quand même';

  @override
  String get emergency_started_snack_alert =>
      'Le bloqueur d\'application est suspendu et reprendra le blocage dans 5 minutes.';

  @override
  String get emergency_already_active_snack_alert =>
      'Le bloqueur de l\'application est actuellement suspendu ou inactif. Si les notifications sont activées, vous recevrez informations concernant le temps restant.';

  @override
  String get emergency_no_pass_left_snack_alert =>
      'Vous avez utilisé tous vos délais d\'urgence. Les applications bloquées resteront bloquées jusqu\'à minuit, ou la session de concentration active se termine.';

  @override
  String get app_limit_status_not_set => 'Non défini';

  @override
  String get app_timer_tile_title => 'Minuteur de l\'application';

  @override
  String get app_timer_picker_dialog_info =>
      'Définissez une limite de temps quotidienne pour cette application. Une fois votre limite atteinte, l\'application sera suspendue jusqu\'à minuit.';

  @override
  String get usage_reminders_tile_title => 'Rappels d\'utilisation';

  @override
  String get usage_reminders_tile_subtitle =>
      'De légers coups de coude lors de l\'utilisation d\'applications chronométrées.';

  @override
  String get app_launch_limit_tile_title => 'Limite de lancements';

  @override
  String app_launch_limit_tile_subtitle(num count) {
    return 'Lancé $count fois aujourd\'hui.';
  }

  @override
  String get app_launch_limit_picker_dialog_info =>
      'Définissez combien de fois vous pouvez ouvrir cette application chaque jour. Une fois la limite atteinte, elle sera suspendue jusqu\'à minuit.';

  @override
  String get app_active_period_tile_title => 'Période d\'activité';

  @override
  String app_active_period_tile_subtitle(String startTime, String endTime) {
    return 'De $startTime à $endTime';
  }

  @override
  String get internet_access_tile_title => 'Accès internet';

  @override
  String get internet_access_tile_subtitle =>
      'Désactivez pour bloquer Internet pour l\'app.';

  @override
  String internet_access_blocked_snack_alert(String appName) {
    return 'Internet est bloqué pour $appName.';
  }

  @override
  String internet_access_unblocked_snack_alert(String appName) {
    return 'Internet est débloqué pour $appName.';
  }

  @override
  String get launch_app_tile_title => 'Lancer l\'application';

  @override
  String launch_app_tile_subtitle(String appName) {
    return 'Ouvrez $appName.';
  }

  @override
  String get go_to_app_settings_tile_title =>
      'Accédez aux paramètres de l\'application';

  @override
  String get go_to_app_settings_tile_subtitle =>
      'Gérez les paramètres de l\'application tels que les notifications, les autorisations, le stockage et bien plus encore.';

  @override
  String get include_in_stats_tile_title =>
      'Inclure dans l\'utilisation de l\'écran';

  @override
  String get include_in_stats_tile_subtitle =>
      'Désactivez-la pour exclure cette application de l\'utilisation totale de l\'écran.';

  @override
  String app_excluded_from_stats_snack_alert(String appName) {
    return '$appName est exclu de l’utilisation totale de l’écran.';
  }

  @override
  String app_include_to_stats_snack_alert(String appName) {
    return '$appName est inclus dans l’utilisation totale de l’écran.';
  }

  @override
  String get general_tab_title => 'Général';

  @override
  String get appearance_heading => 'Apparence';

  @override
  String get theme_mode_tile_title => 'Mode thème';

  @override
  String get theme_mode_system_label => 'Système';

  @override
  String get theme_mode_light_label => 'Lumière';

  @override
  String get theme_mode_dark_label => 'Sombre';

  @override
  String get material_color_tile_title => 'Couleur du matériau';

  @override
  String get amoled_dark_tile_title => 'AMOLED sombre';

  @override
  String get amoled_dark_tile_subtitle =>
      'Utilisez une couleur noire pure pour le thème sombre.';

  @override
  String get dynamic_colors_tile_title => 'Couleurs dynamiques';

  @override
  String get dynamic_colors_tile_subtitle =>
      'Utilisez les couleurs de l\'appareil si elles sont prises en charge.';

  @override
  String get defaults_heading => 'Valeurs par défaut';

  @override
  String get app_language_tile_title => 'Langue de l\'application';

  @override
  String get default_home_tab_tile_title => 'Onglet Accueil';

  @override
  String get usage_history_tile_title => 'Historique d\'utilisation';

  @override
  String get usage_history_15_days => '15 jours';

  @override
  String get usage_history_1_month => '1 mois';

  @override
  String get usage_history_3_month => '3 mois';

  @override
  String get usage_history_6_month => '6 mois';

  @override
  String get usage_history_1_year => '1 an';

  @override
  String get service_heading => 'Service';

  @override
  String get service_stopping_warning =>
      'Si NLP digitox cesse de fonctionner de manière inattendue, veuillez accorder l\'autorisation « Ignorer l\'optimisation de la batterie » pour qu\'il continue de fonctionner en arrière-plan. Si le problème persiste, essayez de mettre NLP digitox sur liste blanche pour des performances ininterrompues.';

  @override
  String get whitelist_app_tile_title => 'Liste blanche NLP digitox';

  @override
  String get whitelist_app_tile_subtitle =>
      'Autorisez NLP digitox à démarrer automatiquement.';

  @override
  String get whitelist_app_unsupported_snack_alert =>
      'Cet appareil ne prend pas en charge la gestion automatique du démarrage.';

  @override
  String get database_tab_title => 'Base de données';

  @override
  String get import_db_tile_title => 'Importer la base de données';

  @override
  String get import_db_tile_subtitle =>
      'Importer une base de données à partir d\'un fichier.';

  @override
  String get export_db_tile_title => 'Exporter la base de données';

  @override
  String get export_db_tile_subtitle =>
      'Exporter la base de données vers un fichier.';

  @override
  String get analysis_tab_title => 'Analyse';

  @override
  String get analysis_7_days => '7 jours';

  @override
  String get analysis_30_days => '30 jours';

  @override
  String get analysis_90_days => '90 jours';

  @override
  String get analysis_screen_time_trend => 'Tendance du temps d\'écran';

  @override
  String get analysis_no_data_info =>
      'Aucune donnée de temps d\'écran n\'est encore enregistrée pour cette période.';

  @override
  String get analysis_daily_average => 'Moyenne quotidienne';

  @override
  String get analysis_total => 'Total';

  @override
  String get analysis_no_change => 'Comme la semaine dernière';

  @override
  String analysis_trend_less(String percent) {
    return '$percent% de moins que la semaine dernière';
  }

  @override
  String analysis_trend_more(String percent) {
    return '$percent% de plus que la semaine dernière';
  }

  @override
  String get crash_logs_heading => 'Journaux de crash';

  @override
  String get crash_logs_info =>
      'Si vous rencontrez un problème, vous pouvez le signaler sur GitHub avec le fichier journal. Le fichier comprendra des détails tels que le fabricant de votre appareil, le modèle, la version Android, la version du SDK et les journaux de crash. Ces informations nous aideront à identifier et à résoudre le problème plus efficacement.';

  @override
  String get crash_logs_export_tile_title => 'Exporter les journaux de crash';

  @override
  String get crash_logs_export_tile_subtitle =>
      'Exportez les journaux de crash vers un fichier json.';

  @override
  String get crash_logs_view_tile_title => 'Afficher les journaux';

  @override
  String get crash_logs_view_tile_subtitle =>
      'Explorez les journaux de crash stockés.';

  @override
  String get crash_logs_empty_list_hint =>
      'Aucun crash enregistré jusqu\'à présent.';

  @override
  String get crash_logs_clear_tile_title => 'Effacer les journaux';

  @override
  String get crash_logs_clear_tile_subtitle =>
      'Supprimez tous les journaux de crash de la base de données.';

  @override
  String get crash_logs_clear_dialog_info =>
      'Êtes-vous sûr de vouloir effacer tous les journaux de crash de la base de données ?';

  @override
  String get crash_logs_clear_dialog_button_clear_anyway =>
      'Effacer quand même';

  @override
  String get about_tab_title => 'À propos';

  @override
  String get changelog_tile_title => 'Journal des modifications';

  @override
  String get changelog_tile_subtitle => 'Découvrez les nouveautés.';

  @override
  String get full_changelog_tile_title => 'Journal des modifications complet';

  @override
  String get redirected_to_github_subtitle =>
      'Vous serez redirigé vers GitHub.';

  @override
  String get contribute_heading => 'Contribuer';

  @override
  String get github_tile_title => 'GitHub';

  @override
  String get github_tile_subtitle => 'Afficher le code source.';

  @override
  String get report_issue_tile_title => 'Signaler un problème';

  @override
  String get suggest_idea_tile_title => 'Proposer une idée';

  @override
  String get write_email_tile_title => 'Écrivez-nous par email';

  @override
  String get write_email_tile_subtitle =>
      'Vous serez redirigé vers l\'application Email.';

  @override
  String get privacy_policy_heading => 'Politique de confidentialité';

  @override
  String get privacy_policy_info =>
      'NLP digitox s\'engage à protéger votre vie privée. Nous ne collectons, ne stockons ni ne transférons aucun type de données utilisateur. L\'application fonctionne entièrement hors ligne et ne nécessite pas de connexion Internet, garantissant ainsi que vos informations personnelles restent privées et sécurisées sur votre appareil. En tant qu\'application logicielle libre et open source (FOSS), NLP digitox garantit une transparence totale et un contrôle des utilisateurs sur leurs données.';

  @override
  String get more_details_button => 'Plus de détails';

  @override
  String get privacy_policy_coming_soon_title => 'Coming Soon';

  @override
  String get privacy_policy_coming_soon_info =>
      'Our full privacy policy page is on its way. In the meantime, know that NLP digitox works offline and does not collect or sell your personal data.';

  @override
  String get ok_button => 'OK';
}
