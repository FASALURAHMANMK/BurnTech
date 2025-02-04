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

    Future<void> fetchCamps() async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        final fetchedCamps = await _dataProvider.fetchCamps();
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

    void searchCamps(String searchTerm) {
      if (searchTerm.isEmpty) {
        _filteredCamps = _allCamps;
      } else {
        _filteredCamps = _allCamps.where((camp) {
          final nameMatches =
              camp.name?.toLowerCase().contains(searchTerm.toLowerCase()) ??
                  false;
          return nameMatches;
        }).toList();
      }
      notifyListeners();
    }
  }
