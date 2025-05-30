import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor will be replaced by theme
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/details/details.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? mapController;
  Set<Marker> _markers = <Marker>{};
  bool _isLoadingMarkers = true; // Added for loading state

  void _onMapCreated(GoogleMapController controller) async {
    if (!mounted) return;
    setState(() {
      _isLoadingMarkers = true;
    });

    mapController = controller;
    try {
      String value = await DefaultAssetBundle.of(context)
          .loadString('assets/map_style.json');
      await mapController?.setMapStyle(value);
    } catch (e) {
      print('Error setting map style: $e');
    }

    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme; // Get colorScheme

    try {
      final spaces =
          await Provider.of<PostProvider>(context, listen: false).getSpaces();

      if (!mounted) return;

      Set<Marker> tempMarkers = {};
      for (SpaceModel space in spaces) {
        if (space.location?.latitude != null && space.location?.longitude != null) {
          tempMarkers.add(
            Marker(
              markerId: MarkerId(space.id!),
              onTap: () {
                Get.to(() => Details(space: space));
              },
              icon: await MarkerIcon.downloadResizePictureCircle(
                  space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/100') ?? 'https://via.placeholder.com/100',
                  size: (size.height * .13).toInt(),
                  borderSize: 10,
                  addBorder: true,
                  borderColor: colorScheme.primary), // Use themed primary color
              position: LatLng(space.location!.latitude, space.location!.longitude),
            ),
          );
        }
      }
       if (mounted) {
        setState(() {
          _markers = tempMarkers;
        });
      }
    } catch (e) {
      print('Error fetching spaces or creating markers: $e');
      // Handle error appropriately
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMarkers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure locationData is fetched and available before building the map
    // This might require a FutureBuilder or similar if locationData is async
    // For simplicity, assuming locationData is available or handled by the provider
    Provider.of<LocationProvider>(context, listen: false).getCurrentLocation(); // Trigger fetch
    final locationProvider = Provider.of<LocationProvider>(context); // Listen for changes
    final _locationData = locationProvider.locationData;


    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            markers: _markers,
            onMapCreated: _onMapCreated,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
                target: _locationData != null && _locationData.latitude != null && _locationData.longitude != null
                    ? LatLng(_locationData.latitude!, _locationData.longitude!)
                    : const LatLng(0.0,0.0), // Default or last known good location
                zoom: 15),
          ),
          Positioned(
            top: 15,
            right: 15,
            left: 15,
            child: Material( // Added Material for elevation and shadow from theme
              elevation: Theme.of(context).inputDecorationTheme.floatingLabelStyle == null ? 4.0 : 0.0, // Example elevation
              borderRadius: BorderRadius.circular(kAppInputBorderRadius), // Use app config border radius
              child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  onFieldSubmitted: (val) async {
                    if (val.isEmpty) return;
                    try {
                      final spaces =
                          await Provider.of<PostProvider>(context, listen: false)
                              .searchSpaces(val);

                      if (spaces.isNotEmpty && spaces.first.location?.latitude != null && spaces.first.location?.longitude != null) {
                        mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(spaces.first.location!.latitude,
                                  spaces.first.location!.longitude),
                              zoom: 18,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('No results found for "$val" or location is missing.')),
                        );
                      }
                    } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Error during search: $e')),
                       );
                    }
                  },
                  decoration: InputDecoration( // Will adopt from theme via AppTheme.lightTheme.inputDecorationTheme
                    // contentPadding: EdgeInsets.symmetric(horizontal: 15), // Usually handled by theme
                    // border: InputBorder.none, // Handled by theme (e.g. OutlineInputBorder)
                    // fillColor: Colors.white, // Handled by theme
                    // filled: true, // Handled by theme
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20), // Size can be adjusted, color from theme
                    suffixIcon: const Icon(Icons.search, size: 20), // Color from theme
                    hintText: 'Search location',
                    // hintStyle: TextStyle(color: Colors.grey, fontSize: 14) // Handled by theme
                  ).applyDefaults(Theme.of(context).inputDecorationTheme)
              ),
            ),
          ),
          if (_isLoadingMarkers)
            Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.3), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(), // Themed by default ProgressIndicatorThemeData
              ),
            ),
        ],
      ),
    );
  }
}
