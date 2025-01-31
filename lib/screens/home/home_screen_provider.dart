import 'package:flutter/material.dart';
import 'package:burn_tech/models/camp_location.dart';

class HomeProvider extends ChangeNotifier {
  int _currentIndex = 0;

  final List<CampLocation> _camps = [
    CampLocation(name: 'Camp A', latitude: 40.787, longitude: -119.203),
    CampLocation(name: 'Camp B', latitude: 40.786, longitude: -119.208),
  ];

  int get currentIndex => _currentIndex;
  List<CampLocation> get camps => _camps;

  void onTabTapped(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}