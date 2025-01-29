import 'package:burn_tech/models/camp_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // <-- Import your CampLocation model

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

  // Default center on Black Rock City, NV (approx.)
  static const LatLng _defaultCenter = LatLng(40.7864, -119.2065);
  static const double _defaultZoom = 14.0;

  // Store markers in a set
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  void _initMarkers() {
    // Convert each CampLocation into a Marker
    for (final camp in widget.campLocations) {
      final marker = Marker(
        markerId: MarkerId(camp.name),
        position: LatLng(camp.latitude, camp.longitude),
        infoWindow: InfoWindow(title: camp.name),
      );
      _markers.add(marker);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Example search logic to highlight or move camera to a searched camp.
  /// You might want to refine this to do partial matches, etc.
  void _searchCamp(String query) {
    final camp = widget.campLocations.firstWhere(
      (c) => c.name.toLowerCase() == query.toLowerCase(),
      orElse: () => CampLocation(
        name: '',
        latitude: 0,
        longitude: 0,
      ),
    );

    if (camp.name.isNotEmpty) {
      final position = LatLng(camp.latitude, camp.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16.0));
    } else {
      // If not found, handle appropriately (show a snackbar, etc.)
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
          // Google Map in the background
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _defaultCenter,
              zoom: _defaultZoom,
            ),
            markers: _markers,
            myLocationEnabled: true,    // Optional: show user location
            myLocationButtonEnabled: true,
             // Optional: show "current location" button
          ),

          // Search Bar Positioned at the top
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
        ],
      ),
    );
  }
}
