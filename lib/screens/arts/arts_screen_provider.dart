  import 'package:burn_tech/screens/camps/camp_screen_service.dart';
  import 'package:flutter/material.dart';
  import 'package:burn_tech/models/art_model.dart';

  class ArtProvider with ChangeNotifier {
    List<ArtModel> _allArts = [];
    List<ArtModel> _filteredArts = [];
    bool _isLoading = false;
    String? _error;

    List<ArtModel> get filteredArts => _filteredArts;
    bool get isLoading => _isLoading;
    String? get error => _error;

    Future<void> fetchArt() async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        DataProvider dataProvider = DataProvider();
        final fetchedArts = await dataProvider.fetchArt();
        _allArts = fetchedArts;
        _filteredArts = fetchedArts;
      } catch (e) {
        _error = e.toString();
      }

      _isLoading = false;
      notifyListeners();
    }

    void searchArts(String searchTerm) {
      if (searchTerm.isEmpty) {
        _filteredArts = _allArts;
      } else {
        _filteredArts = _allArts.where((art) {
          final nameMatches =
              art.name?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false;
          return nameMatches;
        }).toList();
      }
      notifyListeners();
    }
  }
