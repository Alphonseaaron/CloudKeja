import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/notifications/cupertino_notifications_page_stub.dart'; // Our new Cupertino screen
import 'package:cloudkeja/screens/notifications/notifications_screen.dart'; // The existing Material screen

class NotificationsRouter extends StatelessWidget {
  const NotificationsRouter({super.key});

  // static const String routeName = '/notifications_router'; // Optional

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoNotificationsPageStub(); // TODO: Rename this to CupertinoNotificationsScreen when file is renamed
    } else {
      return const NotificationsScreen();
    }
  }
}
