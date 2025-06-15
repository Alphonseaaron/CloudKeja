import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle; // For map style
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/details/details.dart';

class CupertinoMapsScreen extends StatefulWidget {
  const CupertinoMapsScreen({Key? key}) : super(key: key);

  @override
  State<CupertinoMapsScreen> createState() => _CupertinoMapsScreenState();
}

class _CupertinoMapsScreenState extends State<CupertinoMapsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = <Marker>{};
  bool _isLoadingMarkers = true;
  String? _mapStyle;
  final TextEditingController _searchController = TextEditingController();
  List<SpaceModel> _allSpaces = []; // To store all spaces for local filtering if needed

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _fetchSpacesAndSetMarkers();
    // Trigger location fetch, Map will use it once available
    Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      print('Error loading map style: $e');
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (_mapStyle != null) {
      try {
        await _mapController?.setMapStyle(_mapStyle);
      } catch (e) {
        print('Error setting map style on controller: $e');
      }
    }
  }

  Future<void> _fetchSpacesAndSetMarkers({String? searchQuery}) async {
    if (!mounted) return;
    setState(() {
      _isLoadingMarkers = true;
    });

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      List<SpaceModel> spaces;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        spaces = await postProvider.searchSpaces(searchQuery);
        if (spaces.isEmpty && mounted) { // Check mounted before showing dialog
          _showCupertinoDialog("No Results", "No spaces found for '$searchQuery'.");
        }
      } else {
        spaces = await postProvider.getSpaces();
        _allSpaces = spaces; // Store all spaces when no search query
      }

      if (!mounted) return;

      Set<Marker> tempMarkers = {};
      for (SpaceModel space in spaces) {
        if (space.location?.latitude != null && space.location?.longitude != null) {
          // Ensure context is available for CupertinoTheme before this loop or pass theme data
          final primaryColor = CupertinoTheme.of(context).primaryColor;
          tempMarkers.add(
            Marker(
              markerId: MarkerId(space.id!),
              onTap: () {
                Get.to(() => Details(space: space));
              },
              icon: await MarkerIcon.downloadResizePictureCircle(
                space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/100') ?? 'https://via.placeholder.com/100',
                size: 130,
                borderSize: 10,
                addBorder: true,
                borderColor: primaryColor, // Use fetched primary color
              ),
              position: LatLng(space.location!.latitude, space.location!.longitude),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _markers = tempMarkers;
          if (searchQuery != null && spaces.isNotEmpty && spaces.first.location != null) {
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(spaces.first.location!.latitude, spaces.first.location!.longitude),
                  zoom: 16,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Error fetching spaces or creating markers: $e');
      if(mounted){
        _showCupertinoDialog("Error", "Could not load spaces. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMarkers = false;
        });
      }
    }
  }

  void _showCupertinoDialog(String title, String content) {
    // Ensure this context is valid and has CupertinoLocalizations
    // It's generally safe if called from widget lifecycle methods or event handlers within the widget.
    if (!mounted) return;
    showCupertinoDialog(
      context: context, // Use the widget's context
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final initialLocationData = locationProvider.locationData;
    final initialCameraPosition = CameraPosition(
      target: initialLocationData != null && initialLocationData.latitude != null && initialLocationData.longitude != null
          ? LatLng(initialLocationData.latitude!, initialLocationData.longitude!)
          : const LatLng(-1.286389, 36.817223),
      zoom: 14,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Explore Spaces'),
      ),
      child: Stack(
        children: [
          GoogleMap(
            markers: _markers,
            onMapCreated: _onMapCreated,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: initialCameraPosition,
          ),
           Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0) ,
              // To make the search bar appear "on top" of the map, but below the true nav bar.
              // The actual CupertinoNavigationBar is opaque and has its own height.
              // This container is part of the scaffold's body (the Stack).
              // Effective top padding should be MediaQuery.of(context).padding.top + navBarHeight
              // For simplicity here, just placing at top of stack. Might need adjustment for visual perfection.
              color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.9),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search by name or location',
                onSubmitted: (String query) {
                  if (query.isEmpty) {
                     _fetchSpacesAndSetMarkers();
                  } else {
                    _fetchSpacesAndSetMarkers(searchQuery: query);
                  }
                },
                onSuffixTap: (){
                  _searchController.clear();
                  FocusScope.of(context).unfocus(); // Dismiss keyboard
                  _fetchSpacesAndSetMarkers();
                },
              ),
            ),
          ),
          if (_isLoadingMarkers)
            Container(
              color: CupertinoColors.systemBackground.withOpacity(0.3),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 20.0),
              ),
            ),
        ],
      ),
    );
  }
}
