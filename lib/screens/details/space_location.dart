import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading asset
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme

class SpaceLocation extends StatefulWidget {
  final LatLng? location;
  final String? imageUrl; // For the marker icon
  final String? spaceName; // For marker info window (optional)

  const SpaceLocation({
    Key? key,
    required this.location, // Made location required for clarity
    this.imageUrl,
    this.spaceName,
  }) : super(key: key);

  @override
  _SpaceLocationState createState() => _SpaceLocationState();
}

class _SpaceLocationState extends State<SpaceLocation> {
  // GlobalKey is not used, can be removed if not needed for other purposes.
  // final GlobalKey globalKey = GlobalKey();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMarkerReady = false; // To track if marker has been processed

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _createMarker();
    }
  }

  @override
  void didUpdateWidget(covariant SpaceLocation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location || widget.imageUrl != oldWidget.imageUrl) {
      if (widget.location != null) {
        _createMarker();
         // If mapController is available, move camera to new location
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(widget.location!, 13),
          );
        }
      } else {
        // Clear markers if location becomes null
        setState(() {
          _markers.clear();
          _isMarkerReady = false;
        });
      }
    }
  }


  Future<void> _createMarker() async {
    if (widget.location == null) return;

    BitmapDescriptor markerIcon;
    try {
      markerIcon = await MarkerIcon.downloadResizePictureCircle(
        widget.imageUrl ?? 'https://via.placeholder.com/100/CCCCCC/FFFFFF?Text=Place', // Default placeholder
        borderSize: 5, // Reduced border size
        size: 120,    // Slightly smaller for better map visibility
        addBorder: true,
        borderColor: Theme.of(context).colorScheme.primary, // Use themed primary color
      );
    } catch (e) {
      // Fallback to default marker if image download fails
      markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure); // Themed fallback
    }

    final marker = Marker(
      markerId: const MarkerId('space_location'),
      icon: markerIcon,
      position: widget.location!,
      infoWindow: widget.spaceName != null ? InfoWindow(title: widget.spaceName) : InfoWindow.noText,
    );

    if (mounted) {
      setState(() {
        _markers.clear(); // Clear previous markers
        _markers.add(marker);
        _isMarkerReady = true;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    // If marker is already processed (e.g. location available on init), update map
    // The initialCameraPosition will handle the first view.
    // If location changes later, didUpdateWidget will handle camera movement.

    // Load and apply custom map style
    try {
      // Using DefaultAssetBundle.of(context) is also an option if context is readily available here,
      // but since _onMapCreated is a callback, ensuring context can be tricky without passing it.
      // rootBundle is simpler here.
      String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
      await _mapController?.setMapStyle(style);
    } catch (e) {
      print('Error loading or setting map style: $e');
      // Optionally, set a default style or do nothing if it fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (widget.location == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Text(
          'Location data not available.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          AspectRatio(
            aspectRatio: 16 / 10, // Slightly taller aspect ratio for better map display
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0), // Consistent with CardTheme
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5), // Themed border
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.0), // Inner clip slightly less than border
                child: GoogleMap(
                  mapToolbarEnabled: false, // Cleaner UI
                  zoomControlsEnabled: true, // Allow user to zoom
                  myLocationButtonEnabled: false, // Can be enabled if current user location is relevant context
                  myLocationEnabled: false, // Only if showing user's current location on map
                  onMapCreated: _onMapCreated,
                  markers: _isMarkerReady ? _markers : {}, // Show markers only when ready
                  initialCameraPosition: CameraPosition(
                    target: widget.location!,
                    zoom: 14, // Default zoom level
                  ),
                  // Lite mode can be an option for non-interactive maps
                  // liteModeEnabled: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
