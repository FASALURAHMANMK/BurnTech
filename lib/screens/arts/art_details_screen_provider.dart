import 'package:burn_tech/models/art_model.dart';
import 'package:burn_tech/screens/camps/camp_screen_service.dart';
import 'package:flutter/foundation.dart';

class ArtDetailProvider extends ChangeNotifier {
 final DataProvider _dataProvider = DataProvider();

  ArtModel? _art;
  ArtModel? get art => _art;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch the camp details by ID.
  Future<void> fetchArtDetails(String artId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _art = await _dataProvider.fetchArtById(artId);
    } catch (e) {
      _errorMessage = 'Failed to load art details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } 
}