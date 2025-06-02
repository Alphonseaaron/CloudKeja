import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';

class SpaceLocationCupertino extends StatefulWidget {
  final LatLng? location;
  final String? imageUrl;
  final String? spaceName;

  const SpaceLocationCupertino({
    Key? key,
    required this.location,
    this.imageUrl,
    this.spaceName,
  }) : super(key: key);

  @override
  _SpaceLocationCupertinoState createState() => _SpaceLocationCupertinoState();
}

class _SpaceLocationCupertinoState extends State<SpaceLocationCupertino> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMarkerReady = false;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    if (widget.location != null) {
      _createMarker();
    }
  }
  
  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      print('Error loading map style for Cupertino: $e');
    }
  }


  @override
  void didUpdateWidget(covariant SpaceLocationCupertino oldWidget) {
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
        if (mounted) {
          setState(() {
            _markers.clear();
            _isMarkerReady = false;
          });
        }
      }
    }
  }

  Future<void> _createMarker() async {
    if (widget.location == null || !mounted) return;

    BitmapDescriptor markerIcon;
    try {
      // Ensure context is available for CupertinoTheme or pass the primary color directly
      final primaryColor = CupertinoTheme.of(context).primaryColor;
      markerIcon = await MarkerIcon.downloadResizePictureCircle(
        widget.imageUrl ?? 'https://via.placeholder.com/100/CCCCCC/FFFFFF?Text=Place',
        borderSize: 5,
        size: 120,
        addBorder: true,
        borderColor: primaryColor, // Use Cupertino themed primary color
      );
    } catch (e) {
      print('Error creating marker icon for Cupertino: $e');
      markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); // Fallback
    }

    final marker = Marker(
      markerId: const MarkerId('space_location_cupertino'),
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
    if (!mounted) return;
    if (_mapStyle != null) {
      try {
        await _mapController?.setMapStyle(_mapStyle);
      } catch (e) {
        print('Error setting map style on controller (Cupertino): $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    if (widget.location == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Text(
          'Location data not available.',
          style: cupertinoTheme.textTheme.textStyle.copyWith(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
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
            style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                // Making it a bit larger and bolder if navTitleTextStyle is too small for a section header
                fontSize: 20, 
                fontWeight: FontWeight.bold
            ), 
          ),
          const SizedBox(height: 12.0),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: CupertinoColors.separator.resolveFrom(context),
                  width: 0.5, // Standard Cupertino separator width
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.5), // Inner clip
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
