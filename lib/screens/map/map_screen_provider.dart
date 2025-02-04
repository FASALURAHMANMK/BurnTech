import 'dart:io';
import 'package:burn_tech/models/art_model.dart';
import 'package:burn_tech/models/camp_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Position? _currentPosition;
  LatLng? _selectedMarkerPosition;
  String? _selectedMarkerTitle;
  String? _selectedMarkerId;
  // New flag: true if the selected marker is a camp, false if it is an art location.
  bool? _selectedMarkerIsCamp;

  // List of camps and arts.
  late List<CampModel> _camps;
  late List<ArtModel> _arts;

  static const LatLng _defaultCenter = LatLng(40.7864, -119.2065);
  static const double _defaultZoom = 14.0;

  /// Expose copies of markers and polylines.
  Set<Marker> get markers => Set<Marker>.from(_markers);
  Set<Polyline> get polylines => Set<Polyline>.from(_polylines);
  LatLng get defaultCenter => _defaultCenter;
  double get defaultZoom => _defaultZoom;
  bool get isMarkerSelected => _selectedMarkerPosition != null;

  // Expose selected marker info.
  LatLng? get selectedMarkerPosition => _selectedMarkerPosition;
  String? get selectedMarkerTitle => _selectedMarkerTitle;
  String? get selectedMarkerId => _selectedMarkerId;
  bool? get selectedMarkerIsCamp => _selectedMarkerIsCamp;
  // Expose the map controller.
  GoogleMapController? get mapController => _mapController;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Initialize markers from a list of CampModel.
  Future<void> initMarkers(List<CampModel> camps) async {
    _camps = camps;
    // Remove existing camp markers if needed.
    _markers.removeWhere((m) => m.markerId.value.startsWith('camp_'));
    for (final camp in _camps) {
      if (camp.latitude == null || camp.longitude == null) continue;
      final double lat = camp.latitude!;
      final double lng = camp.longitude!;
      if (lat == 0.0 && lng == 0.0) continue;

      // Prefix the markerId to avoid conflicts.
      final markerId = MarkerId('camp_${camp.uid ?? camp.name ?? 'unknown'}');

      final marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        onTap: () {
          _selectedMarkerPosition = LatLng(lat, lng);
          _selectedMarkerTitle = camp.name ?? 'Unnamed Camp';
          _selectedMarkerId = camp.uid ?? 'Unnamed Camp';
          _selectedMarkerIsCamp = true;
          notifyListeners();
        },
        // Disable the native info window.
        infoWindow: InfoWindow.noText,
      );
      _markers.add(marker);
    }
    notifyListeners();
  }
Future<void> initArtMarkers(List<ArtModel> arts) async {
    _arts = arts;
    // Remove existing art markers if needed.
    _markers.removeWhere((m) => m.markerId.value.startsWith('art_'));
    for (final art in _arts) {
      // Ensure location exists and has valid coordinates.
      if (art.location == null ||
          art.location!.gpsLatitude == null ||
          art.location!.gpsLongitude == null) continue;

      final double lat = art.location!.gpsLatitude!;
      final double lng = art.location!.gpsLongitude!;
      if (lat == 0.0 && lng == 0.0) continue;

      final markerId = MarkerId('art_${art.uid ?? art.name ?? 'unknown'}');

      final marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        onTap: () {
          _selectedMarkerPosition = LatLng(lat, lng);
          _selectedMarkerTitle = art.name ?? 'Unnamed Art';
          _selectedMarkerId = art.uid ?? 'Unnamed Art';
          _selectedMarkerIsCamp = false;
          notifyListeners();
        },
        infoWindow: InfoWindow.noText,
        // Optionally, use a different icon for arts:
        // icon: BitmapDescriptor.fromAsset('assets/art_marker.png'),
      );
      _markers.add(marker);
    }
    notifyListeners();
  }
   void clearSelectedMarker() {
    _selectedMarkerPosition = null;
    _selectedMarkerTitle = null;
    _selectedMarkerId = null;
    _selectedMarkerIsCamp = null;
    notifyListeners();
  }
  /// Called when an info window is tapped.
  /// (Not used in the custom overlay, but left here for potential future use.

  Future<void> getCurrentLocation() async {
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
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = position;
    notifyListeners();
  }

  /// Search for a camp by name and move the camera to that camp's location.
  void searchCamp(String query, BuildContext context) {
  // Convert the query to lower case for a case-insensitive search.
  final searchQuery = query.toLowerCase();

  // First, try to find a matching camp.
  final camp = _camps.firstWhere(
    (c) => (c.name?.toLowerCase() ?? '').contains(searchQuery),
    orElse: () => CampModel(name: '', latitude: 0, longitude: 0),
  );

  if (camp.name != null && camp.name!.isNotEmpty) {
    final double lat = camp.latitude ?? 0.0;
    final double lng = camp.longitude ?? 0.0;

    // Animate the camera to the camp location.
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18.0),
    );

    // Set the selected marker info for the camp.
    _selectedMarkerPosition = LatLng(lat, lng);
    _selectedMarkerTitle = camp.name;
    _selectedMarkerId = camp.uid;
    // Set the marker type flag to true for a camp.
    _selectedMarkerIsCamp = true;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to camp: ${camp.name}')),
    );
    return;
  }

  // If no matching camp was found, try to find a matching art.
  final art = _arts.firstWhere(
    (a) => (a.name?.toLowerCase() ?? '').contains(searchQuery),
    orElse: () => ArtModel(name: '', location: null),
  );

  if (art.name != null &&
      art.name!.isNotEmpty &&
      art.location != null &&
      art.location!.gpsLatitude != null &&
      art.location!.gpsLongitude != null) {
    final double lat = art.location!.gpsLatitude!;
    final double lng = art.location!.gpsLongitude!;

    // Animate the camera to the art location.
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18.0),
    );

    // Set the selected marker info for the art.
    _selectedMarkerPosition = LatLng(lat, lng);
    _selectedMarkerTitle = art.name;
    _selectedMarkerId = art.uid;
    // Set the marker type flag to false for an art marker.
    _selectedMarkerIsCamp = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to art: ${art.name}')),
    );
    return;
  }

  // If no camp or art is found, show a message.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('No camp or art found for "$query"')),
  );
}

  /// Draw a route from current location to the selected marker.
  Future<void> drawRoute() async {
    await getCurrentLocation();
    if (_currentPosition == null || _selectedMarkerPosition == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyDKxB_P0K7oeME4KL5jpfxZA5N5IOxxSPE",
      request: PolylineRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(
          _selectedMarkerPosition!.latitude,
          _selectedMarkerPosition!.longitude,
        ),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          color: Colors.blue,
          width: 5,
        ),
      );
      notifyListeners();
    }
  }

  /// Start external navigation to the selected marker.
  Future<void> startNavigation() async {
    if (_selectedMarkerPosition == null) return;

    final double lat = _selectedMarkerPosition!.latitude;
    final double lng = _selectedMarkerPosition!.longitude;

    final Uri googleMapsAndroidUri =
        Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final Uri googleMapsIOSUri =
        Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
    final Uri appleMapsUri =
        Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      if (Platform.isAndroid) {
        if (await canLaunchUrl(googleMapsAndroidUri)) {
          await launchUrl(googleMapsAndroidUri);
        } else if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        if (await canLaunchUrl(googleMapsIOSUri)) {
          await launchUrl(googleMapsIOSUri);
        } else if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri);
        } else if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } else {
        // Fallback for other platforms (web, desktop)
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Error launching navigation: $e');
    }
  }
}