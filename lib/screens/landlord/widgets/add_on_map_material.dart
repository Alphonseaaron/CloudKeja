import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/location_provider.dart';

class AddOnMapMaterial extends StatefulWidget {
  final Function(LatLng loc) onChanged;
  final LatLng? initialLocation;
  final bool isEditing;

  const AddOnMapMaterial({
    Key? key,
    required this.onChanged,
    this.initialLocation,
    this.isEditing = false, // Default to false if not provided
  }) : super(key: key);

  @override
  _AddOnMapMaterialState createState() => _AddOnMapMaterialState();
}

class _AddOnMapMaterialState extends State<AddOnMapMaterial> {
  GoogleMapController? mapController;
  LatLng? _selectedLocation; // To hold the tapped location

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    // Apply map style if it exists
    try {
      String mapStyle = await DefaultAssetBundle.of(context)
          .loadString('assets/map_style.json');
      mapController!.setMapStyle(mapStyle);
    } catch (e) {
      print('Error loading map style: $e');
    }
    // If an initial location is provided, move camera there
    if (_selectedLocation != null) {
       mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final currentDeviceLocation = locationProvider.locationData;

    // Determine initial camera target: use initialLocation if provided, else device location, else a default
    LatLng cameraTarget;
    if (_selectedLocation != null) {
      cameraTarget = _selectedLocation!;
    } else if (currentDeviceLocation?.latitude != null && currentDeviceLocation?.longitude != null) {
      cameraTarget = LatLng(currentDeviceLocation!.latitude!, currentDeviceLocation.longitude!);
    } else {
      cameraTarget = const LatLng(0.0, 0.0); // Default fallback
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Update Location' : 'Set Location on Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea( // SafeArea might not be strictly needed if AppBar handles top padding
        child: GoogleMap(
          onTap: (LatLng latLngValue) {
            setState(() {
              _selectedLocation = latLngValue; // Update marker position visually
            });
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Location'), // Added title
                      content: Text('Use latitude: ${latLngValue.latitude.toStringAsFixed(5)}, longitude: ${latLngValue.longitude.toStringAsFixed(5)}?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(); // Close dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onChanged(latLngValue);
                            Navigator.of(ctx).pop(); // Close dialog
                            Navigator.of(context).pop(); // Pop map screen
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ));
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
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
              target: cameraTarget,
              zoom: _selectedLocation != null ? 16 : (currentDeviceLocation != null ? 16: 6) // Zoom further if a location is set
          ),
        ),
      ),
    );
  }
}
