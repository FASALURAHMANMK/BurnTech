import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/screens/camps/camp_screen_service.dart';
import 'package:flutter/material.dart';
class HomeProvider extends ChangeNotifier {
  final DataProvider _dataProvider = DataProvider();
  
  int _currentIndex = 0;
  List<CampModel> _camps = [];

  HomeProvider() {
    // Call loadCamps() on initialization.
    loadCamps();
  }
  
  int get currentIndex => _currentIndex;

  /// Expose the camps to widgets
  List<CampModel> get camps => _camps;

  void onTabTapped(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> loadCamps() async {
  try {
    // Assume fetchCamps() now returns a List<CampModel>
    final List<CampModel> fetchedCamps = await _dataProvider.fetchCamps(); 
    _camps = fetchedCamps;
    notifyListeners();
  } catch (e) {
    rethrow;
  }
}
}