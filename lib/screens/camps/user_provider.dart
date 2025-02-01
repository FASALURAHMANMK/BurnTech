import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Call this to fetch and cache user data
  Future<void> fetchUser(String uid) async {
  if (uid.isEmpty) {
    _error = "User ID is empty";
    notifyListeners();
    return;
  }

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception("User does not exist");
    }

    final data = doc.data()!;
    _user = UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      profileImage: data['profileImage'],
      favCamps: List<String>.from(data['favCamps'] ?? []),
    );
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// Toggle favorite camp in Firestore
  Future<void> toggleFavorite(CampModel camp) async {
    if (_user == null) return;

    final currentFavCamps = _user!.favCamps ?? [];
    final campIdString = camp.id.toString();
    bool isCurrentlyFav = currentFavCamps.contains(campIdString);

    // Locally update
    List<String> updatedFavCamps = List.from(currentFavCamps);
    if (isCurrentlyFav) {
      updatedFavCamps.remove(campIdString);
    } else {
      updatedFavCamps.add(campIdString);
    }

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'favCamps': updatedFavCamps});

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        profileImage: _user!.profileImage,
        favCamps: updatedFavCamps,
      );
      notifyListeners();
    } catch (e) {
      // In case of error, you might revert the change or show an error
      _error = e.toString();
      notifyListeners();
    }
  }
}