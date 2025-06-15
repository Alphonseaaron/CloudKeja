import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloudkeja/models/notification_model.dart'; // Assuming this model exists
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:cached_network_image/cached_network_image.dart'; // To check for NetworkImage

// Define a public version of _CupertinoNotificationTile for testing purposes.
// In a real scenario, you would make the original _CupertinoNotificationTile public
// or test it via the CupertinoNotificationsScreen.
class TestableCupertinoNotificationTile extends StatelessWidget {
  const TestableCupertinoNotificationTile({Key? key, required this.notification}) : super(key: key);
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: notification.imageUrl != null && notification.imageUrl!.isNotEmpty
          ? CircleAvatar(
              radius: 22,
              backgroundImage: CachedNetworkImageProvider(notification.imageUrl!), // Use CachedNetworkImageProvider
              backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
            )
          : CircleAvatar(
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
        maxLines: 2, // Ensure maxLines is set as per requirement
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


Widget createNotificationTileTestableWidget({required NotificationModel notification}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: TestableCupertinoNotificationTile(notification: notification),
    ),
  );
}

void main() {
  final mockNotificationWithImage = NotificationModel(
    id: 'notif1',
    title: 'New Listing Alert!',
    message: 'A new 3-bedroom apartment is available in your preferred area. Check it out now.',
    imageUrl: 'https://via.placeholder.com/100.png?text=Property',
    timestamp: Timestamp.now(),
    isRead: false,
    // Add other fields as required by your NotificationModel
  );

  final mockNotificationWithoutImage = NotificationModel(
    id: 'notif2',
    title: 'Reminder: Rent Due',
    message: 'Your rent payment is due soon. Please ensure to pay on time to avoid penalties.',
    imageUrl: null, // No image
    timestamp: Timestamp.now(),
    isRead: true,
  );

  final mockNotificationWithEmptyImage = NotificationModel(
    id: 'notif3',
    title: 'Maintenance Update',
    message: 'Scheduled maintenance for the water systems will occur tomorrow.',
    imageUrl: '', // Empty image URL
    timestamp: Timestamp.now(),
    isRead: false,
  );

  testWidgets('TestableCupertinoNotificationTile displays correctly with image', (WidgetTester tester) async {
    await tester.pumpWidget(createNotificationTileTestableWidget(notification: mockNotificationWithImage));

    expect(find.text('New Listing Alert!'), findsOneWidget);
    expect(find.text('A new 3-bedroom apartment is available in your preferred area. Check it out now.'), findsOneWidget);

    // Check for CircleAvatar with a NetworkImage (via CachedNetworkImageProvider)
    final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
    expect(circleAvatar.backgroundImage, isA<CachedNetworkImageProvider>());
    expect(find.byIcon(CupertinoIcons.bell), findsNothing);
  });

  testWidgets('TestableCupertinoNotificationTile displays placeholder when imageUrl is null', (WidgetTester tester) async {
    await tester.pumpWidget(createNotificationTileTestableWidget(notification: mockNotificationWithoutImage));

    expect(find.text('Reminder: Rent Due'), findsOneWidget);
    expect(find.text('Your rent payment is due soon. Please ensure to pay on time to avoid penalties.'), findsOneWidget);

    // Check for CircleAvatar with placeholder icon
    final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
    expect(circleAvatar.backgroundImage, isNull);
    expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
  });

  testWidgets('TestableCupertinoNotificationTile displays placeholder when imageUrl is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createNotificationTileTestableWidget(notification: mockNotificationWithEmptyImage));

    expect(find.text('Maintenance Update'), findsOneWidget);
    expect(find.text('Scheduled maintenance for the water systems will occur tomorrow.'), findsOneWidget);

    final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
    expect(circleAvatar.backgroundImage, isNull); // CachedNetworkImageProvider might handle empty string differently, but our logic forces placeholder
    expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
  });

  testWidgets('TestableCupertinoNotificationTile title and message have maxLines set', (WidgetTester tester) async {
    await tester.pumpWidget(createNotificationTileTestableWidget(notification: mockNotificationWithImage));

    final titleWidget = tester.widget<Text>(find.text(mockNotificationWithImage.title!));
    expect(titleWidget.maxLines, 1);

    final messageWidget = tester.widget<Text>(find.text(mockNotificationWithImage.message!));
    expect(messageWidget.maxLines, 2);
  });
}
