
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/app_database.dart' as db;
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/default_slide_to_remove.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    this.leading,
    this.color,
    this.onDismissed,
    required this.notification,
    required this.position,
  });

  final Widget? leading;
  final db.Notification notification;
  final ItemPosition position;
  final Color? color;
  final void Function(db.Notification notification)? onDismissed;

  void _onPressed() async =>
      MethodChannelService.instance.openAppWithNotificationThread(notification);

  @override
  Widget build(BuildContext context) {
    final isFromLast24Hours =
        notification.timeStamp.isAfter(DateTime.now().last24Hours.start);

    return DefaultSlideToRemove(
      enabled: onDismissed != null,
      key: Key("${notification.key}:${notification.id}"),
      position: position,
      onDismiss: () => onDismissed?.call(notification),
      child: RoundedContainer(
        onPressed: _onPressed,
        circularRadius: 0,
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultListTile(
              position: ItemPosition.fit,
              margin: const EdgeInsets.all(0),
              leading: leading,
              color: Colors.transparent,
              title: StyledText(
                notification.title,
                fontSize: 16,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: StyledText(notification.timeStamp.timeString(context)),
              subtitle: Row(
                children: [
                  /// Today's notification indicator
                  if (!notification.isRead && isFromLast24Hours)
                    RoundedContainer(
                      height: 8,
                      width: 8,
                      margin: const EdgeInsets.only(right: 6),
                      color: Theme.of(context).colorScheme.primary,
                    ),

                  /// Date
                  StyledText(
                    notification.timeStamp.dateString(context),
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            ),

            /// Conversation or content
            Padding(
              padding: const EdgeInsets.all(12).copyWith(top: 0),
              child: StyledText(
                notification.content,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
