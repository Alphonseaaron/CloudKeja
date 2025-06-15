import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading asset
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';

class SpaceLocationMaterial extends StatefulWidget { // Renamed widget
  final LatLng? location;
  final String? imageUrl;
  final String? spaceName;

  const SpaceLocationMaterial({ // Renamed constructor
    Key? key,
    required this.location,
    this.imageUrl,
    this.spaceName,
  }) : super(key: key);

  @override
  _SpaceLocationMaterialState createState() => _SpaceLocationMaterialState(); // Renamed state class
}

class _SpaceLocationMaterialState extends State<SpaceLocationMaterial> { // Renamed state class
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMarkerReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _createMarker();
    }
  }

  @override
  void didUpdateWidget(covariant SpaceLocationMaterial oldWidget) { // Updated parameter type
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location || widget.imageUrl != oldWidget.imageUrl) {
      if (widget.location != null) {
        _createMarker();
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(widget.location!, 13),
          );
        }
      } else {
        setState(() {
          _markers.clear();
          _isMarkerReady = false;
        });
      }
    }
  }

  Future<void> _createMarker() async {
    if (widget.location == null || !mounted) return; // Added mounted check

    BitmapDescriptor markerIcon;
    try {
      markerIcon = await MarkerIcon.downloadResizePictureCircle(
        widget.imageUrl ?? 'https://via.placeholder.com/100/CCCCCC/FFFFFF?Text=Place',
        borderSize: 5,
        size: 120,
        addBorder: true,
        borderColor: Theme.of(context).colorScheme.primary,
      );
    } catch (e) {
      markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    final marker = Marker(
      markerId: const MarkerId('space_location'),
      icon: markerIcon,
      position: widget.location!,
      infoWindow: widget.spaceName != null ? InfoWindow(title: widget.spaceName) : InfoWindow.noText,
    );

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.add(marker);
        _isMarkerReady = true;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (!mounted) return; // Added mounted check
    try {
      String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
      await _mapController?.setMapStyle(style);
    } catch (e) {
      print('Error loading or setting map style: $e');
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
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.0),
                child: GoogleMap(
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  onMapCreated: _onMapCreated,
                  markers: _isMarkerReady ? _markers : {},
                  initialCameraPosition: CameraPosition(
                    target: widget.location!,
                    zoom: 14,
                  ),
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
