import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/models/notification_model.dart'; // Assuming this model exists and is correct

// TODO: Rename this file to cupertino_notifications_screen.dart after confirming functionality

class CupertinoNotificationsPageStub extends StatelessWidget {
  const CupertinoNotificationsPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notifications'),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true) // Assuming a timestamp field for ordering
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', style: TextStyle(color: CupertinoColors.destructiveRed)),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: theme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel),
              ),
            );
          }

          List<DocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final notification = NotificationModel.fromJson(docs[index]);
              return _CupertinoNotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _CupertinoNotificationTile extends StatelessWidget {
  const _CupertinoNotificationTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoListTile.notched( // Using notched for a slightly more distinct look
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: notification.imageUrl != null && notification.imageUrl!.isNotEmpty
          ? CircleAvatar(
              radius: 22, // Standard avatar size
              backgroundImage: NetworkImage(notification.imageUrl!),
              backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
            )
          : CircleAvatar( // Placeholder if no image
              radius: 22,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              child: Icon(CupertinoIcons.bell, color: theme.primaryColor, size: 20),
            ),
      title: Text(
        notification.title ?? 'No Title',
        style: theme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.message ?? 'No Message',
        style: theme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      // Trailing can be added if notifications are tappable to navigate somewhere
      // trailing: const CupertinoListTileChevron(),
      // onTap: () { /* Handle tap if notifications lead to details */ }
    );
  }
}
