import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for CupertinoActivityIndicator
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
// import 'package:cloudkeja/helpers/color_loader.dart'; // ColorLoader4 is no longer used here

class MyLoader extends StatelessWidget {
  const MyLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      // For Cupertino, CupertinoActivityIndicator is standard.
      // It can be themed with a color or use its default.
      return CupertinoActivityIndicator(
        // radius: 15, // Optional: Adjust size
        // color: CupertinoTheme.of(context).primaryColor, // Optional: Apply theme color
      );
    } else {
      // For Material, CircularProgressIndicator is standard.
      return CircularProgressIndicator(
        // color: Theme.of(context).colorScheme.primary, // Optional: Apply theme color
        // strokeWidth: 3.0, // Optional: Adjust thickness
      );
    }
  }
}
