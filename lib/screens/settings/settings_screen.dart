import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/settings/settings_screen_cupertino.dart';
import 'package:cloudkeja/screens/settings/settings_screen_material.dart';

// No longer need cupertino_settings_page_stub
// import 'package:cloudkeja/screens/settings/cupertino_settings_page_stub.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Optional: Add a static routeName if direct navigation is needed
  // static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      // Points to the implemented Cupertino settings screen.
      return const SettingsScreenCupertino();
    } else {
      return const SettingsScreenMaterial();
    }
  }
}
