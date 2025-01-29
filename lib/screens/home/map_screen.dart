import 'package:burn_tech/models/camp_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class MapTab extends StatefulWidget {
  final List<CampLocation> campLocations;

  const MapTab({
    Key? key,
    required this.campLocations,
  }) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const LatLng _defaultCenter = LatLng(40.7864, -119.2065);
  static const double _defaultZoom = 14.0;

  Position? _currentPosition;
  LatLng? _selectedMarkerPosition;

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _getCurrentLocation();
  }

  /// Initialize markers for camp locations
  void _initMarkers() {
    for (final camp in widget.campLocations) {
      final marker = Marker(
        markerId: MarkerId(camp.name),
        position: LatLng(camp.latitude, camp.longitude),
        infoWindow: InfoWindow(title: camp.name),
        onTap: () {
          setState(() {
            _selectedMarkerPosition = LatLng(camp.latitude, camp.longitude);
          });
        },
      );
      _markers.add(marker);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14));
  }

  /// Draw a route from current location to selected marker
Future<void> _drawRoute() async {
  if (_currentPosition == null || _selectedMarkerPosition == null) return;

  PolylinePoints polylinePoints = PolylinePoints();
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: "AIzaSyDKxB_P0K7oeME4KL5jpfxZA5N5IOxxSPE",
    request: PolylineRequest(
      origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      destination: PointLatLng(_selectedMarkerPosition!.latitude, _selectedMarkerPosition!.longitude),
      mode: TravelMode.driving,
    ),
  );

  if (result.points.isNotEmpty) {
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId("route"),
        points: result.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: Colors.blue,
        width: 5,
      ));
    });
  }
}

  /// Open Google Maps App for turn-by-turn navigation
  void _startNavigation() async {
    if (_selectedMarkerPosition == null) return;

    final Uri googleMapsUrl = Uri.parse(
        "google.navigation:q=${_selectedMarkerPosition!.latitude},${_selectedMarkerPosition!.longitude}&mode=d");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw "Could not launch $googleMapsUrl";
    }
  }

  /// Search for a camp and move camera to it
  void _searchCamp(String query) {
    final camp = widget.campLocations.firstWhere(
      (c) => c.name.toLowerCase() == query.toLowerCase(),
      orElse: () => CampLocation(name: '', latitude: 0, longitude: 0),
    );

    if (camp.name.isNotEmpty) {
      final position = LatLng(camp.latitude, camp.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16.0));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No camp found for "$query"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _defaultCenter,
              zoom: _defaultZoom,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (_) {
              // Hide navigation button when clicking outside markers
              setState(() {
                _selectedMarkerPosition = null;
              });
            },
          ),

          // Search Bar
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search camp...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _searchCamp(value);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _searchCamp(_searchController.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Navigation Button (Appears only when a marker is selected)
          if (_selectedMarkerPosition != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _drawRoute();
                  _startNavigation();
                },
                icon: Icon(Icons.navigation),
                label: Text("Navigate"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}