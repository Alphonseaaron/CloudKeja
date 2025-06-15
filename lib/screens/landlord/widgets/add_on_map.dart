import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng type
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/widgets/add_on_map_material.dart';
import 'package:cloudkeja/screens/landlord/widgets/add_on_map_cupertino.dart';

class AddOnMap extends StatelessWidget {
  // The routeName can be kept here if this router widget is registered in a route map.
  // However, often the router itself is not a route, but a decision maker for what to display.
  // static const routeName = '/add-on-map';

  final Function(LatLng loc) onChanged;
  final LatLng? initialLocation;
  final bool isEditing;

  const AddOnMap({
    Key? key,
    required this.onChanged,
    this.initialLocation,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return AddOnMapCupertino(
        key: key, // Pass key
        onChanged: onChanged,
        initialLocation: initialLocation,
        isEditing: isEditing,
      );
    } else {
      return AddOnMapMaterial(
        key: key, // Pass key
        onChanged: onChanged,
        initialLocation: initialLocation,
        isEditing: isEditing,
      );
    }
  }
}
