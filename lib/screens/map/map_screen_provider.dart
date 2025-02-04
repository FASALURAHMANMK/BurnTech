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
    bool? _selectedMarkerIsCamp;

    late List<CampModel> _camps;
    late List<ArtModel> _arts;

    static const LatLng _defaultCenter = LatLng(40.7864, -119.2065);
    static const double _defaultZoom = 14.0;

    Set<Marker> get markers => Set<Marker>.from(_markers);
    Set<Polyline> get polylines => Set<Polyline>.from(_polylines);
    LatLng get defaultCenter => _defaultCenter;
    double get defaultZoom => _defaultZoom;
    bool get isMarkerSelected => _selectedMarkerPosition != null;

    LatLng? get selectedMarkerPosition => _selectedMarkerPosition;
    String? get selectedMarkerTitle => _selectedMarkerTitle;
    String? get selectedMarkerId => _selectedMarkerId;
    bool? get selectedMarkerIsCamp => _selectedMarkerIsCamp;

    GoogleMapController? get mapController => _mapController;

    void setMapController(GoogleMapController controller) {
      _mapController = controller;
    }

    Future<void> initMarkers(List<CampModel> camps) async {
      _camps = camps;
      _markers.removeWhere((m) => m.markerId.value.startsWith('camp_'));
      for (final camp in _camps) {
        if (camp.latitude == null || camp.longitude == null) continue;
        final double lat = camp.latitude!;
        final double lng = camp.longitude!;
        if (lat == 0.0 && lng == 0.0) continue;

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
          infoWindow: InfoWindow.noText,
        );
        _markers.add(marker);
      }
      notifyListeners();
    }

    Future<void> initArtMarkers(List<ArtModel> arts) async {
      _arts = arts;

      _markers.removeWhere((m) => m.markerId.value.startsWith('art_'));
      for (final art in _arts) {
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

    void searchCamp(String query, BuildContext context) {
      final searchQuery = query.toLowerCase();

      final camp = _camps.firstWhere(
        (c) => (c.name?.toLowerCase() ?? '').contains(searchQuery),
        orElse: () => CampModel(name: '', latitude: 0, longitude: 0),
      );

      if (camp.name != null && camp.name!.isNotEmpty) {
        final double lat = camp.latitude ?? 0.0;
        final double lng = camp.longitude ?? 0.0;

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18.0),
        );

        _selectedMarkerPosition = LatLng(lat, lng);
        _selectedMarkerTitle = camp.name;
        _selectedMarkerId = camp.uid;

        _selectedMarkerIsCamp = true;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to camp: ${camp.name}')),
        );
        return;
      }

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

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18.0),
        );

        _selectedMarkerPosition = LatLng(lat, lng);
        _selectedMarkerTitle = art.name;
        _selectedMarkerId = art.uid;

        _selectedMarkerIsCamp = false;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to art: ${art.name}')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No camp or art found for "$query"')),
      );
    }

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
          if (await canLaunchUrl(webUri)) {
            await launchUrl(webUri, mode: LaunchMode.externalApplication);
          }
        }
      } catch (e) {
        debugPrint('Error launching navigation: $e');
      }
    }
  }
