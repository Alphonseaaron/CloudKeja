import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/maps/cupertino_maps_screen.dart'; // Updated to actual Cupertino screen
import 'package:cloudkeja/screens/maps_screen/maps_screen.dart'; // The existing Material screen

class MapsRouter extends StatelessWidget {
  const MapsRouter({super.key});

  // static const String routeName = '/maps_router'; // Optional

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoMapsScreen(); // Use the implemented Cupertino screen
    } else {
      return const MapsScreen();
    }
  }
}
