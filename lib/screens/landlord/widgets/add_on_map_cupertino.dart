import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/location_provider.dart';

class AddOnMapCupertino extends StatefulWidget {
  final Function(LatLng loc) onChanged;
  final LatLng? initialLocation;
  final bool isEditing;

  const AddOnMapCupertino({
    Key? key,
    required this.onChanged,
    this.initialLocation,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _AddOnMapCupertinoState createState() => _AddOnMapCupertinoState();
}

class _AddOnMapCupertinoState extends State<AddOnMapCupertino> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
    }
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await DefaultAssetBundle.of(context)
          .loadString('assets/map_style.json');
    } catch (e) {
      print('Error loading map style for Cupertino: $e');
    }
  }


  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (_mapStyle != null) {
      try {
        _mapController!.setMapStyle(_mapStyle);
      } catch (e) {
        print('Error setting map style on controller (Cupertino): $e');
      }
    }
    if (_selectedLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final currentDeviceLocation = locationProvider.locationData;

    LatLng cameraTarget;
    if (_selectedLocation != null) {
      cameraTarget = _selectedLocation!;
    } else if (currentDeviceLocation?.latitude != null && currentDeviceLocation?.longitude != null) {
      cameraTarget = LatLng(currentDeviceLocation!.latitude!, currentDeviceLocation.longitude!);
    } else {
      cameraTarget = const LatLng(0.0, 0.0); // Default fallback
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'), // Standard cancel text
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text(widget.isEditing ? 'Update Location' : 'Set Location'),
        // Trailing could be a "Done" button if we want to confirm the _selectedLocation without a map tap
        // For this task, confirmation is on map tap.
      ),
      child: GoogleMap(
        onTap: (LatLng latLngValue) {
          // No need to setState here to update marker visually immediately on tap before confirmation,
          // as the dialog will handle the confirmation.
          // If visual feedback before confirmation is desired, then setState for _selectedLocation here.
          showCupertinoDialog(
            context: context,
            builder: (dialogContext) => CupertinoAlertDialog(
              title: const Text('Confirm Location'),
              content: Text('Use latitude: ${latLngValue.latitude.toStringAsFixed(5)}, longitude: ${latLngValue.longitude.toStringAsFixed(5)}?'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Confirm'),
                  onPressed: () {
                    widget.onChanged(latLngValue);
                    Navigator.pop(dialogContext); // Close dialog
                    Navigator.pop(context); // Pop map screen
                  },
                ),
              ],
            ),
          );
        },
        onMapCreated: _onMapCreated,
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: _selectedLocation!,
                  infoWindow: InfoWindow(title: widget.isEditing ? 'Current Location' : 'New Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                )
              }
            : {},
        compassEnabled: true,
        myLocationEnabled: true,
        zoomControlsEnabled: true, // Often true for maps where precise zoom is useful
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: cameraTarget,
          zoom: _selectedLocation != null ? 16 : (currentDeviceLocation != null ? 16: 6),
        ),
      ),
    );
  }
}
