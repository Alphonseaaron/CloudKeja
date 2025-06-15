import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/notifications/cupertino_notifications_screen.dart'; // Updated import
import 'package:cloudkeja/screens/notifications/notifications_screen.dart'; // The existing Material screen

class NotificationsRouter extends StatelessWidget {
  const NotificationsRouter({super.key});

  // static const String routeName = '/notifications_router'; // Optional

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoNotificationsScreen(); // Use the renamed and updated screen
    } else {
      return const NotificationsScreen();
    }
  }
}
