import 'package:burn_tech/models/event_model.dart';
import 'package:burn_tech/screens/camps/camp_screen_service.dart';
import 'package:flutter/foundation.dart';
import 'package:burn_tech/models/camp_model.dart';

class CampDetailProvider extends ChangeNotifier {
 final DataProvider _dataProvider = DataProvider();

  CampModel? _camp;
  CampModel? get camp => _camp;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<EventModel> _campEvents = [];
  List<EventModel> get campEvents => _campEvents;

  /// Fetch the camp details by ID.
  Future<void> fetchCampDetails(String campId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _camp = await _dataProvider.fetchCampById(campId);
    } catch (e) {
      _errorMessage = 'Failed to load camp details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
    Future<void> fetchCampAndEvents(String campId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch Camp
      final fetchedCamp = await _dataProvider.fetchCampById(campId);

      // 2. If camp exists, fetch events for that camp
      if (fetchedCamp != null) {
        final fetchedEvents =
            await _dataProvider.fetchEventsForCamp(fetchedCamp.uid ?? campId);
        _camp = fetchedCamp;
        _campEvents = fetchedEvents;
      } else {
        _errorMessage = 'Camp not found.';
      }
    } catch (e) {
      _errorMessage = 'Failed to load camp details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}