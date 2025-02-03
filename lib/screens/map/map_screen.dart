import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/models/color.dart';
import 'package:burn_tech/screens/camps/camp_details_screen.dart';
import 'package:burn_tech/screens/chat/chat_screen.dart';
import 'package:burn_tech/screens/map/map_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapTab extends StatefulWidget {
  final List<CampModel> camps;

  const MapTab({Key? key, required this.camps}) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  // Holds the screen offset for the custom info window.
  Offset? _infoWindowOffset;

  /// Updates the custom info window's position using the map controller.
  Future<void> _updateInfoWindowOffset(MapProvider mapProvider) async {
    if (mapProvider.mapController != null && mapProvider.selectedMarkerPosition != null) {
      // Convert the selected marker's LatLng to screen coordinates.
      final ScreenCoordinate screenCoordinate = await mapProvider.mapController!
          .getScreenCoordinate(mapProvider.selectedMarkerPosition!);
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      setState(() {
        _infoWindowOffset = Offset(
          screenCoordinate.x.toDouble() / pixelRatio,
          screenCoordinate.y.toDouble() / pixelRatio,
        );
      });
    } else {
      if (_infoWindowOffset != null) {
        setState(() {
          _infoWindowOffset = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider()
        ..initMarkers(widget.camps)
        ..getCurrentLocation(),
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          // Schedule updating or clearing the info window offset after the build phase.
          if (mapProvider.isMarkerSelected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateInfoWindowOffset(mapProvider);
            });
          } else if (_infoWindowOffset != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _infoWindowOffset = null;
                });
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Map',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 28),
              ),
              backgroundColor: desertOrange,
              actions: [
  IconButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen()),
      );
    },
    icon: Image.asset(
      'assets/chat.png',
      width: 24, // Set appropriate width
      height: 24, // Set appropriate height
    ),
  ),
],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapProvider.setMapController(controller);
                    if (mapProvider.isMarkerSelected) {
                      _updateInfoWindowOffset(mapProvider);
                    }
                  },
                  onCameraMove: (position) {
                    // Update the info window position as the camera moves.
                    if (mapProvider.isMarkerSelected) {
                      _updateInfoWindowOffset(mapProvider);
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: mapProvider.defaultCenter,
                    zoom: mapProvider.defaultZoom,
                  ),
                  markers: mapProvider.markers,
                  polylines: mapProvider.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (_) {
                    mapProvider.clearSelectedMarker();
                    setState(() {
                      _infoWindowOffset = null;
                    });
                  },
                ),
                _buildSearchBar(context, mapProvider),
                // Custom Info Window overlay.
                if (mapProvider.isMarkerSelected && _infoWindowOffset != null)
                  Positioned(
                    left: _infoWindowOffset!.dx + 50, // Adjust horizontal offset (half of 150 width)
                    top: _infoWindowOffset!.dy + 100,  // Adjust vertical offset as needed
                    child: CustomInfoWindow(
                      title: mapProvider.selectedMarkerTitle ?? '',
                      id: mapProvider.selectedMarkerId??'',
                      isCamp: true,
                    ),
                  ),
                // Directions button overlay.
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
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await mapProvider.drawRoute();
                            mapProvider.startNavigation();
                          },
                          icon: const Icon(Icons.directions, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search camps & Arts...',
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

/// A simple custom info window widget.
class CustomInfoWindow extends StatelessWidget {
  final String title;
  final String id;
  final bool isCamp;
  const CustomInfoWindow({Key? key, required this.title,required this.id,required this.isCamp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // Use a transparent material so that any shadows show up properly.
      color: Colors.transparent,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            isCamp?
             Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampDetailsScreen(campId:id),
                      ),
                    ):
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampDetailsScreen(campId:id),
                      ),
                    );
          },
         child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Tap for details",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      ),
    );
  }
}