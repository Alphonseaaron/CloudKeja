import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Required for LatLng, CameraPosition, etc. from google_maps_flutter and potentially for SnackBar if Get.snackbar is used.
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/details/details.dart'; // Assuming Details screen is adaptive or works for Cupertino

// TODO: Rename this file to cupertino_maps_screen.dart

class CupertinoMapsPageStub extends StatefulWidget {
  const CupertinoMapsPageStub({super.key});

  @override
  State<CupertinoMapsPageStub> createState() => _CupertinoMapsPageStubState();
}

class _CupertinoMapsPageStubState extends State<CupertinoMapsPageStub> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = <Marker>{};
  bool _isLoadingMarkers = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Note: getCurrentLocation is called before map created,
    // so initialCameraPosition might use default if provider hasn't updated yet.
    // Consider FutureBuilder for location if it's critical for first paint.
    Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    if (!mounted) return;
    setState(() {
      _isLoadingMarkers = true;
    });

    _mapController = controller;
    try {
      // Using a simplified map style for Cupertino or remove if default is preferred
      String mapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_style_silver.json'); // Example: using a silver style
      await _mapController?.setMapStyle(mapStyle);
    } catch (e) {
      print('Error setting Cupertino map style: $e');
    }

    final size = MediaQuery.of(context).size;
    // Using CupertinoTheme for primary color
    final cupertinoTheme = CupertinoTheme.of(context);

    try {
      final spaces = await Provider.of<PostProvider>(context, listen: false).getSpaces();
      if (!mounted) return;

      Set<Marker> tempMarkers = {};
      for (SpaceModel space in spaces) {
        if (space.location?.latitude != null && space.location?.longitude != null) {
          tempMarkers.add(
            Marker(
              markerId: MarkerId(space.id!),
              onTap: () {
                // TODO: Consider Cupertino-style navigation or modal for details
                Get.to(() => Details(space: space));
              },
              icon: await MarkerIcon.downloadResizePictureCircle(
                space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/100') ?? 'https://via.placeholder.com/100',
                size: (size.height * .12).toInt(), // Slightly smaller for Cupertino aesthetic
                borderSize: 8,
                addBorder: true,
                borderColor: cupertinoTheme.primaryColor, // Use Cupertino theme primary color
              ),
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
      print('Error fetching spaces or creating markers (Cupertino): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMarkers = false;
        });
      }
    }
  }
  
  void _onSearchSubmitted(String val) async {
    if (val.trim().isEmpty) return;
    try {
      final spaces = await Provider.of<PostProvider>(context, listen: false).searchSpaces(val.trim());
      if (spaces.isNotEmpty && spaces.first.location?.latitude != null && spaces.first.location?.longitude != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(spaces.first.location!.latitude, spaces.first.location!.longitude),
              zoom: 18,
            ),
          ),
        );
      } else {
        // Use CupertinoAlertDialog for feedback
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Search Result'),
            content: Text('No results found for "$val" or location is missing.'),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
      }
    } catch (e) {
       showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Search Error'),
            content: Text('Error during search: ${e.toString()}'),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final locationData = locationProvider.locationData;
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Map View'),
        // TODO: Consider adding a search icon here that reveals the search text field
        // Or, if using a persistent search bar below nav bar, this is fine.
      ),
      child: SafeArea( // SafeArea is important for content below nav bar
        child: Stack(
          children: [
            GoogleMap(
              markers: _markers,
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              myLocationButtonEnabled: true, // Shows the button, relies on location permissions
              myLocationEnabled: true,     // Shows the blue dot, relies on location permissions
              zoomControlsEnabled: false,  // Cupertino typically doesn't show +/- zoom buttons overlayed like Android
              initialCameraPosition: CameraPosition(
                target: locationData != null && locationData.latitude != null && locationData.longitude != null
                    ? LatLng(locationData.latitude!, locationData.longitude!)
                    : const LatLng(0.0, 0.0), // Default or last known
                zoom: 15,
              ),
            ),
            Positioned( // Search bar overlay
              top: 10, // Adjust as needed, considering SafeArea
              left: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: cupertinoTheme.barBackgroundColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: 'Search location...',
                  onSubmitted: _onSearchSubmitted,
                  backgroundColor: CupertinoColors.tertiarySystemFill.resolveFrom(context), // Light BG for text field itself
                ),
              )
            ),
            if (_isLoadingMarkers)
              Container(
                color: CupertinoColors.black.withOpacity(0.1), // Subtle loading overlay
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
