// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/ui/onboarding/onboarding_page.dart';
import 'package:nlp_digitox/ui/permissions/alarm_permission_tile.dart';
import 'package:nlp_digitox/ui/permissions/battery_permission_tile.dart';
import 'package:nlp_digitox/ui/permissions/display_overlay_permission_tile.dart';
import 'package:nlp_digitox/ui/permissions/notification_permission_tile.dart';
import 'package:nlp_digitox/ui/permissions/usage_access_permission_tile.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 24 is min sdk
    final sdkVersion = MethodChannelService.instance.deviceInfo.sdkVersion;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          OnboardingPage(
            bottomPadding: 0,
            title: context.locale.onboarding_page_permissions_title,
            imgArtPath: "assets/illustrations/onboarding_4.png",
            description: context.locale.onboarding_page_permissions_info,
          ),

          12.vBox,

          /// Permission tiles
          const NotificationPermissionTile(),
          const BatteryPermissionTile(),

          // Only SDK version Android(S [31]) and above need this permission
          if (sdkVersion >= 31) const AlarmPermissionTile(),

          const UsageAccessPermissionTile(),
          const DisplayOverlayPermissionTile(),

          108.vBox,
        ],
      ),
    );
  }
}
