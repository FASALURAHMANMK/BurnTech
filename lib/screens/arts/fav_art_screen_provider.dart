import 'package:burn_tech/models/art_model.dart';
import 'package:burn_tech/models/user_model.dart';
import 'package:burn_tech/screens/camps/camp_screen_service.dart';
import 'package:flutter/material.dart';

class favArtProvider extends ChangeNotifier {
  final DataProvider _dataProvider = DataProvider();

  bool _isLoading = false;
  String? _error;
  List<ArtModel> _allArts = [];
  List<ArtModel> _favArts = []; // Camps that are favorites for the user.
  List<ArtModel> _filteredArts = []; // Camps filtered by search term.

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ArtModel> get filteredArts => _filteredArts;

  /// Fetch camps from the DataProvider.
 Future<void> fetchArts() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final fetchedArts = await _dataProvider.fetchArt();
    _allArts = fetchedArts;

    // Do not default favorites to all camps.
    _favArts = [];       // Start with an empty favorites list.
    _filteredArts = [];  // Start with an empty filtered list.
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}

 void updateFavoriteArts(UserModel user) {
  final favIds = user.favArts ?? [];
  _favArts = _allArts.where((art) {
    // Ensure camp.uid is converted to a string for matching.
    return favIds.contains(art.uid.toString());
  }).toList();

  // Reset the filtered list to the updated favorites.
  _filteredArts = _favArts;
  notifyListeners();
}

  void searchArts(String searchTerm) {
    if (searchTerm.isEmpty) {
      _filteredArts = _favArts;
    } else {
      _filteredArts = _favArts.where((art) {
        final nameMatches = art.name
                ?.toLowerCase()
                .contains(searchTerm.toLowerCase()) ??
            false;
        return nameMatches;
      }).toList();
    }
    notifyListeners();
  }
}