import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/models/user_model.dart';
import 'package:burn_tech/screens/camps/camp_screen_service.dart';
import 'package:flutter/material.dart';

class favCampProvider extends ChangeNotifier {
  final DataProvider _dataProvider = DataProvider();

  bool _isLoading = false;
  String? _error;
  List<CampModel> _allCamps = [];
  List<CampModel> _favCamps = []; // Camps that are favorites for the user.
  List<CampModel> _filteredCamps = []; // Camps filtered by search term.

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CampModel> get filteredCamps => _filteredCamps;

  /// Fetch camps from the DataProvider.
 Future<void> fetchCamps() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final fetchedCamps = await _dataProvider.fetchCamps();
    _allCamps = fetchedCamps;

    // Do not default favorites to all camps.
    _favCamps = [];       // Start with an empty favorites list.
    _filteredCamps = [];  // Start with an empty filtered list.
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}

 void updateFavoriteCamps(UserModel user) {
  final favIds = user.favCamps ?? [];
  _favCamps = _allCamps.where((camp) {
    // Ensure camp.uid is converted to a string for matching.
    return favIds.contains(camp.uid.toString());
  }).toList();

  // Reset the filtered list to the updated favorites.
  _filteredCamps = _favCamps;
  notifyListeners();
}

  void searchCamps(String searchTerm) {
    if (searchTerm.isEmpty) {
      _filteredCamps = _favCamps;
    } else {
      _filteredCamps = _favCamps.where((camp) {
        final nameMatches = camp.name
                ?.toLowerCase()
                .contains(searchTerm.toLowerCase()) ??
            false;
        return nameMatches;
      }).toList();
    }
    notifyListeners();
  }
}