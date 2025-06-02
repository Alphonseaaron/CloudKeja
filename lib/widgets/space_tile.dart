import 'package:flutter/material.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/services/platform_service.dart'; // Added
import 'package:cloudkeja/widgets/space_tile_material.dart'; // Added
import 'package:cloudkeja/widgets/space_tile_cupertino.dart'; // Added
import 'package:provider/provider.dart'; // Added to access PlatformService if needed via Provider

class SpaceTile extends StatelessWidget { // Changed to StatelessWidget
  const SpaceTile({Key? key, required this.space, this.isOwner = false})
      : super(key: key);
  final SpaceModel space;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    // Access PlatformService. We can get it from Provider if it's registered there,
    // or call a static method if PlatformService is designed that way.
    // Assuming PlatformService is available via Provider or has a static getter for useCupertino.
    // For this example, let's assume PlatformService is obtained via Provider.
    // If PlatformService.useCupertino is a static getter, you can call it directly:
    // final bool useCupertino = PlatformService.useCupertino;

    // If PlatformService needs context (e.g., InheritedWidget or Provider)
    // final platformService = Provider.of<PlatformService>(context);
    // final bool shouldUseCupertino = platformService.useCupertino;
    
    // Direct static access for simplicity, assuming PlatformService is set up for it.
    // Ensure PlatformService is initialized before this widget builds.
    // Example: PlatformService.init(); in main.dart

    // For the purpose of this refactor, we assume PlatformService.useCupertino is a static getter.
    // If it's instance-based and provided by Provider, the way to access it would be:
    // final platformService = Provider.of<PlatformService>(context, listen: false);
    // final bool isCupertino = platformService.isCupertino; // assuming a getter like this

    // Let's assume PlatformService has a static method `isCupertino()` or a static getter `useCupertino`
    // For this example, I will use a hypothetical static getter `PlatformService.useCupertino`.
    // You need to ensure `PlatformService` is correctly set up to provide this value.

    // Using Provider to get PlatformService instance
    final platformService = Provider.of<PlatformService>(context, listen: false);


    if (platformService.useCupertino) {
      return SpaceTileCupertino(
        key: key, // Pass the key
        space: space,
        isOwner: isOwner,
      );
    } else {
      return SpaceTileMaterial(
        key: key, // Pass the key
        space: space,
        isOwner: isOwner,
      );
    }
  }
}
