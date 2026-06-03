
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/models/app_info.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ApplicationIcon extends StatelessWidget {
  /// Display [AndroidApp]'s icon if found else custom icon for specified apps.
  const ApplicationIcon({
    super.key,
    required this.appInfo,
    this.size = 18,
    this.isGrayedOut = false,
  });

  final AppInfo appInfo;
  final double size;
  final bool isGrayedOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAppLogo = appInfo.packageName == AppConstants.appPackageName;
    final useCustomIcon = appInfo.icon.isEmpty ||
        appInfo.packageName == AppConstants.removedAppPackage ||
        appInfo.packageName == AppConstants.tetheringAppPackage;

    return CircleAvatar(
      backgroundColor:
          useCustomIcon && !isAppLogo ? theme.focusColor : Colors.transparent,
      radius: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: Skeleton.replace(
          replacement: Bone.iconButton(size: size * 2),
          child: useCustomIcon
              ? _resolveIcon(context, isAppLogo)
              : Image.memory(
                  appInfo.icon,
                  fit: BoxFit.cover,
                  color: isGrayedOut ? Colors.white : null,
                  colorBlendMode: isGrayedOut ? BlendMode.saturation : null,
                ),
        ),
      ),
    );
  }

  Widget _resolveIcon(BuildContext context, bool isAppLogo) {
    if (isAppLogo) {
      return Image.asset(
        'assets/logo.png',
        width: size * 2,
        height: size * 2,
        fit: BoxFit.cover,
      );
    }

    return Icon(
      appInfo.icon.isEmpty
          ? FluentIcons.question_circle_20_filled
          : appInfo.packageName == AppConstants.tetheringAppPackage
              ? FluentIcons.communication_20_filled
              : FluentIcons.delete_20_filled,
      size: size,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
