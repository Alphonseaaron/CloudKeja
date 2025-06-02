import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/maps/cupertino_maps_page_stub.dart'; // Our new Cupertino screen (still named stub)
import 'package:cloudkeja/screens/maps_screen/maps_screen.dart'; // The existing Material screen

class MapsRouter extends StatelessWidget {
  const MapsRouter({super.key});

  // static const String routeName = '/maps_router'; // Optional

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      // TODO: Rename CupertinoMapsPageStub to CupertinoMapsScreen when file is actually renamed
      return const CupertinoMapsPageStub(); 
    } else {
      return const MapsScreen();
    }
  }
}
