import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:burn_tech/models/camp_location.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Position? _currentPosition;
  LatLng? _selectedMarkerPosition;
  late List<CampLocation> _campLocations;

  static const LatLng _defaultCenter = LatLng(40.7864, -119.2065);
  static const double _defaultZoom = 14.0;

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  LatLng get defaultCenter => _defaultCenter;
  double get defaultZoom => _defaultZoom;
  bool get isMarkerSelected => _selectedMarkerPosition != null;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> initMarkers(List<CampLocation> campLocations) async {
    _campLocations = campLocations;
    _markers.clear();
    for (final camp in _campLocations) {
      final marker = Marker(
        markerId: MarkerId(camp.name),
        position: LatLng(camp.latitude, camp.longitude),
        infoWindow: InfoWindow(title: camp.name),
        onTap: () {
          _selectedMarkerPosition = LatLng(camp.latitude, camp.longitude);
          notifyListeners();
        },
      );
      _markers.add(marker);
    }
    notifyListeners();
  }

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

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;

    notifyListeners();
  }

  /// **Search for a camp by name and move the camera to it**
  void searchCamp(String query, BuildContext context) {
    final camp = _campLocations.firstWhere(
      (c) => c.name.toLowerCase() == query.toLowerCase(),
      orElse: () => CampLocation(name: '', latitude: 0, longitude: 0),
    );

    if (camp.name.isNotEmpty) {
      final position = LatLng(camp.latitude, camp.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16.0));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to ${camp.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No camp found for "$query"')),
      );
    }
  }

  Future<void> drawRoute() async {
    await getCurrentLocation();
    if (_currentPosition == null || _selectedMarkerPosition == null) return;

   PolylinePoints polylinePoints = PolylinePoints();
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: "AIzaSyDKxB_P0K7oeME4KL5jpfxZA5N5IOxxSPE",
    request: PolylineRequest(
      origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      destination: PointLatLng(_selectedMarkerPosition!.latitude, _selectedMarkerPosition!.longitude),
      mode: TravelMode.walking,
    ),
  );

    if (result.points.isNotEmpty) {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: result.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          color: Colors.blue,
          width: 5,
        ),
      );
      notifyListeners();
    }
  }

  Future<void> startNavigation() async {
    if (_selectedMarkerPosition == null) return;

    final lat = _selectedMarkerPosition!.latitude;
    final lng = _selectedMarkerPosition!.longitude;
    final Uri googleMapsAndroidUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final Uri googleMapsIOSUri = Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
    final Uri appleMapsUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    final Uri webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

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
    notifyListeners();
  }
}