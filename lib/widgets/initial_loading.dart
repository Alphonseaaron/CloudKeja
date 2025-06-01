import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/cupertino_initial_loading_screen.dart';
import 'package:cloudkeja/widgets/initial_loading_material.dart';

class AppInitialLoadingRouter extends StatelessWidget {
  const AppInitialLoadingRouter({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoInitialLoadingScreen();
    } else {
      return const InitialLoadingScreenMaterial();
    }
  }
}
