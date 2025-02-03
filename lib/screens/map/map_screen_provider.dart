import 'dart:io';
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
  // List of CampModel (with latitude & longitude at top level).
  late List<CampModel> _camps;

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
  // Expose the map controller.
  GoogleMapController? get mapController => _mapController;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Initialize markers from a list of CampModel.
  Future<void> initMarkers(List<CampModel> camps) async {
    _camps = camps;
    _markers.clear();

    for (final camp in _camps) {
      // Skip camps with missing coordinates.
      if (camp.latitude == null || camp.longitude == null) continue;
      final double lat = camp.latitude!;
      final double lng = camp.longitude!;
      // Optionally skip if lat/lon are both zero.
      if (lat == 0.0 && lng == 0.0) continue;

      // Create a markerId using uid if available, else the camp name.
      final markerId = MarkerId(camp.uid ?? camp.name ?? 'unknown_camp');

      final marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        onTap: () {
          // Instead of showing the native info window,
          // set the selected marker (position and title) and notify.
          _selectedMarkerPosition = LatLng(lat, lng);
          _selectedMarkerTitle = camp.name ?? 'Unnamed Camp';
          _selectedMarkerId = camp.uid ?? 'Unnamed Camp';
          notifyListeners();
        },
        // Disable the native info window.
        infoWindow: InfoWindow.noText,
      );
      _markers.add(marker);
    }

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
    // Find the first matching camp by name (case-insensitive).
    final camp = _camps.firstWhere(
      (c) => (c.name?.toLowerCase() ?? '') == query.toLowerCase(),
      orElse: () => CampModel(name: '', latitude: 0, longitude: 0),
    );

    if (camp.name != null && camp.name!.isNotEmpty) {
      final double lat = camp.latitude ?? 0.0;
      final double lng = camp.longitude ?? 0.0;

      // Animate the camera to the camp location.
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18.0),
      );

      // Simulate marker tap by setting the selected marker info.
      _selectedMarkerPosition = LatLng(lat, lng);
      _selectedMarkerTitle = camp.name;
      _selectedMarkerId = camp.uid;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to ${camp.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No camp found for "$query"')),
      );
    }
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

  void clearSelectedMarker() {
    _selectedMarkerPosition = null;
    _selectedMarkerTitle = null;
    notifyListeners();
  }
}