// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/app_database.dart' as db;
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/default_expandable_list_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/notifications/notification_tile.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.appName,
    required this.packageName,
    required this.leading,
    required this.conversations,
    required this.position,
  });

  final String packageName;
  final List<db.Notification> conversations;
  final Widget leading;
  final String appName;

  final ItemPosition position;

  @override
  Widget build(BuildContext context) {
    return DefaultExpandableListTile(
      titleText: appName,
      position: position,
      subtitle: StyledText(
        "${conversations.length} ${context.locale.conversations_label}",
        fontSize: 14,
        color: Theme.of(context).hintColor,
      ),
      leading: leading,
      content: ListView.builder(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.all(0),
        itemCount: conversations.length,
        itemBuilder: (context, index) => NotificationTile(
          notification: conversations[index],
          position: ItemPosition.mid,
        ),
      ),
    );
  }
}
