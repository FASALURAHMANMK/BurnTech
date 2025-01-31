import 'package:burn_tech/screens/map/map_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:burn_tech/models/camp_location.dart';

class MapTab extends StatelessWidget {
  final List<CampLocation> campLocations;

  const MapTab({super.key, required this.campLocations});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider()
        ..initMarkers(campLocations)
        ..getCurrentLocation(),
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          return Scaffold(
            body: Stack(
              children: [
                GoogleMap(
                  onMapCreated: mapProvider.setMapController,
                  initialCameraPosition: CameraPosition(
                    target: mapProvider.defaultCenter,
                    zoom: mapProvider.defaultZoom,
                  ),
                  markers: mapProvider.markers,
                  polylines: mapProvider.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (_) => mapProvider.clearSelectedMarker(),
                ),
                _buildSearchBar(context, mapProvider),
                if (mapProvider.isMarkerSelected)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await mapProvider.drawRoute();
                            mapProvider.startNavigation();
                          },
                          icon:
                              const Icon(Icons.directions, color: Colors.white),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, MapProvider mapProvider) {
    final TextEditingController searchController = TextEditingController();
    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search camp...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    mapProvider.searchCamp(value, context);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  mapProvider.searchCamp(searchController.text, context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
