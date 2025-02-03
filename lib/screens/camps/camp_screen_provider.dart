import 'package:burn_tech/screens/camps/camp_screen_service.dart';
import 'package:flutter/material.dart';
import 'package:burn_tech/models/camp_model.dart';

class CampProvider extends ChangeNotifier {
  final DataProvider _dataProvider = DataProvider();

  bool _isLoading = false;
  String? _error;
  List<CampModel> _allCamps = [];
  List<CampModel> _filteredCamps = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CampModel> get filteredCamps => _filteredCamps;

  /// Fetch camps from DataProvider and update both the complete and filtered lists.
  Future<void> fetchCamps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedCamps = await _dataProvider.fetchCamps();
      // Update both lists.
      _allCamps = fetchedCamps;
      _filteredCamps = fetchedCamps;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter the camp list based on the search term.
  void searchCamps(String searchTerm) {
    if (searchTerm.isEmpty) {
      // Reset filtered list to all camps when search is cleared.
      _filteredCamps = _allCamps;
    } else {
      _filteredCamps = _allCamps.where((camp) {
        // Filter based on the camp name (you can add more fields as needed).
        final nameMatches = camp.name?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false;
        return nameMatches;
      }).toList();
    }
    notifyListeners();
  }
}