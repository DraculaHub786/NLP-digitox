
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
    final isAppLogo = appInfo.packageName == AppConstants.appPackageName;
    final useCustomIcon = appInfo.icon.isEmpty ||
        appInfo.packageName == AppConstants.removedAppPackage ||
        appInfo.packageName == AppConstants.tetheringAppPackage;

    /// For custom/fallback icons, don't use CircleAvatar+ClipRRect which
    /// clips icon widgets badly. Use a simple Container with the icon.
    if (useCustomIcon) {
      if (isAppLogo) {
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size),
            child: Image.asset(
              'assets/logo.png',
              width: size * 2,
              height: size * 2,
              fit: BoxFit.cover,
            ),
          ),
        );
      }

      final colorScheme = Theme.of(context).colorScheme;
      return Skeleton.replace(
        replacement: Bone.iconButton(size: size * 2),
        child: Container(
          width: size * 2,
          height: size * 2,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(size * 2),
          ),
          child: Icon(
            appInfo.icon.isEmpty
                ? FluentIcons.apps_20_filled
                : appInfo.packageName == AppConstants.tetheringAppPackage
                    ? FluentIcons.communication_20_filled
                    : FluentIcons.delete_20_filled,
            size: size,
            color: appInfo.icon.isEmpty
                ? colorScheme.onSurface.withValues(alpha: 0.55)
                : colorScheme.primary,
          ),
        ),
      );
    }

    /// For real app icons (image bytes), use CircleAvatar with ClipRRect
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: Skeleton.replace(
          replacement: Bone.iconButton(size: size * 2),
          child: Image.memory(
            appInfo.icon,
            fit: BoxFit.cover,
            color: isGrayedOut ? Colors.white : null,
            colorBlendMode: isGrayedOut ? BlendMode.saturation : null,
          ),
        ),
      ),
    );
  }
}
